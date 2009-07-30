class ToolController < ApplicationController
  before_filter :prepare, :run_callbacks  
  
  def prepare
    @tool = @tools_hash[params[:controller]]
    
    # check if user is allowed to view tool
    if (!is_active?(@tool))
      logger.debug "Wrong group!"
      redirect_to(:host => DOC_ROOTHOST, :controller => 'common', :action => 'notallowed')
    end
    
    @section = @sections_hash[@tool["section"]]
    @layout_page_title = @tool["title_long"]
    @page_title = @layout_page_title
    if (@page_title =~ /^(.*) - (.*)$/)
      @page_title = $1 + " <span style=\"font-size: 15px; font-weight: bold;\"> - " + $2 + "</span>"
    end
    if params[:jobid].kind_of?(String)
      if params[:action] == 'forward'
        @parent_job = Job.find(:first, :conditions => [ "jobid = ?", params[:jobid]])
      else
        @job = Job.find(:first, :conditions => [ "jobid = ?", params[:jobid]])
      end      
    end
  end
  
  def logger
    @logger ||= Logger.new("#{RAILS_ROOT}/log/tool_controller.log")
  end
  
  def run_callbacks(action=params[:action])
    if action =~ /^results/
      @job.before_results(params)
    else
      if @job.respond_to?("before_#{action}") then @job.send("before_#{action}") end
    end
  end
  
  def index
  end

  def run
    # Allgemeines param-Feld setzen (für resubmit, usw...)
    params['reviewing'] = true

    job = Job.find(:first, :conditions => [ "jobid = ?", params[:job]])
    if (job.nil?)
      job = Object.const_get(params[:job].to_cc+"Job").create(params, @user)
      if (job.config['hidden'] == false && @jobs_cart.index(job.jobid).nil?)
      	@jobs_cart.push(job.jobid) 
      end
      
      # write statistics
      if (job.tool.camelize == job.class.to_s.gsub(/Job/, '').camelize)
        toolname = job.tool.camelize
        day = sprintf("%04d-%02d-%02d", DateTime.now.year, DateTime.now.month, DateTime.now.day)
        stats = Stat.find(:first, :conditions => [ "toolname=? AND day=?", toolname, day ])
        if stats.nil?
          stats = Stat.new(:toolname => toolname, :day => day)
        end
        if @user.nil?
          if is_internal?(request.remote_ip)
            stats.visits_int = (stats.visits_int || 0) + 1
          else
            stats.visits_ext = (stats.visits_ext || 0) + 1
          end
        else
          stats.visits_user = (stats.visits_user || 0) + 1
        end
        stats.save!
      end
      
    end
    errors = job.run(params[:jobaction], params)
    # Errors while validation?
    if (!errors.nil?)
      session[:errors] = errors.dup
      params.keys.each do |k|
        if params[k].instance_of?(StringIO) || params[k].instance_of?(Tempfile) || params[k].instance_of?(ActionController::UploadedStringIO) || params[k].instance_of?(ActionController::UploadedTempfile)
          params.delete(k)
        elsif k=='sequence_input'
          sessionfile = File.join(TMP, "sequence_input_"+session.session_id)
          File.open(sessionfile, 'w') do |f|
            f.write params[k]
          end
          params.delete(k)
        end
      end
      session[:params] = params
      if (params.has_key?('taxids'))
        process_genomes   
      end
      a = job.actions
      if (a.length == 0)
        j = Job.find(:all, :conditions => [ "jobid = ?", job.jobid])
        if (j.length == 1)
          @jobs_cart.delete(job.jobid)
        end
        Job.delete(job.id)
      else
        job.status = STATUS_DONE
        job.save!
      end
      redirect_to :back
    else
      job.reload
      if job.done?
        redirect_to(:host => DOC_ROOTHOST, :controller => job.forward_controller, :action => job.forward_action, :jobid => job)
      else
        redirect_to(:host => DOC_ROOTHOST, :action => "waiting", :jobid => job)
      end
    end
  end

  def waiting
    @job = Job.find(:first, :conditions => [ "jobid = ?", params[:jobid]])
    @nextcheck = [(Time.now-@job.run_on).to_i, 30].min
    checkurl = url_for :host => DOC_ROOTHOST, :action => 'check', :jobid => @job 
    @meta = "<meta http-equiv=\"refresh\" content=\"#{@nextcheck}; URL='#{checkurl}'\">";
  end

  def destroy
    @job = Job.find(:first, :conditions => [ "jobid = ?", params[:jobid]])
    tool = @job.tool
    
    if (@job.jobid !~ /^tu_/ || (!@job.user_id.nil? && !@user.nil? && @user.id == @job.user_id) || (!@user.nil? && @user.groups.include?('admin')) ) 
      
      @job.remove
      
      logger.debug "Delete job in jobs_cart"
      @jobs_cart.delete(@job.id)
      
      logger.debug "Destroy job #{@job.id} in database"
      Job.delete(@job.id)
      
    end
    redirect_to(:host => DOC_ROOTHOST, :controller => tool)
  end

  def forward
    logger.debug "Forward!"
    fw_params = @parent_job.forward_params
#    logger.debug "forward_params: #{fw_params.inspect}"
    fw_params.each_key do |key|
      params[key] = fw_params[key]
    end
    params[:jobid] = ''
    index
    render(:action => 'index')
  end
  
  def resubmit
    logger.debug "Resubmit!"
    job_params = @job.actions.first.params
    job_params.each_key do |key|
      if (key =~ /^(\S+)_file$/) 
        if !job_params[key].nil? && File.exists?(job_params[key]) && File.readable?(job_params[key]) && !File.zero?(job_params[key])
          params[$1+'_input'] = IO.readlines(job_params[key]).join
        end
      else
        params[key] = job_params[key]
      end
    end
    params[:jobid] = ''
    index
    render(:action => 'index')
  end
  
  def log
    render(:partial => "shared/log")
  end
  
  def input_params
    render(:partial => "shared/input_params")
  end
  
  def export_to_file
    function_name = @job.stripped_class_name.to_us + '_export_file'
    if self.respond_to?(function_name) then send(function_name) end
    ret = render_to_string(:action => function_name, :layout => false)
    #changed the following line to be able to set own extension /Chris
    #filename = @job.class.export_basename + "." + @job.class.export_file_ext
    #Orginal: filename = @job.class.export_basename + "." + @job.get_export_ext
    filename = @job.class.export_basename + @job.get_export_ext
    filename.gsub!(/JOBID/, @job.jobid)
    send_data(ret, :filename => filename, :type => @job.class.export_type)
  end
  
  def export_to_browser
    function_name = @job.stripped_class_name.to_us + '_export_browser'
    if self.respond_to?(function_name) then send(function_name) end
    ret = render_to_string(:action => function_name, :layout => false)
    render :text => ret
  end
  
  def help_ov
    render(:layout => "help")
  end
  
  def help_params
    render(:layout => "help")
  end
  
  def help_results
   render(:action => 'help_ov', :layout => "help")
  end
  
  def help_faq
    render(:layout => "help")
  end
  
  protected
  def results_forward
  end

  def results
  end
  
  def before_results
  end
  
  def tool_title(tool)
    @tools_hash[tool]['title']
  end
  
  def fw_to_tool_url(from, to)
    url_for(:host => DOC_ROOTHOST, :action => :run, :jobaction => from+'_forward', :jobid => @job, :forward_action => "forward", :forward_controller => to)
  end
  
  def process_genomes
    res = ""
    params.keys.each do |key|
      if( key =~ /^(\d+)gchk$/ )
        res += $1 + " "
        params.delete(key)          
      end
    end
    params['taxids']=res if (res!="")
  end  
  
end
