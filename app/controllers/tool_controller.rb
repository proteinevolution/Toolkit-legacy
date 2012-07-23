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
    logger.debug  " -> Running current Application"
    job = Job.find(:first, :conditions => [ "jobid = ?", params[:job]])
    if (job.nil?)
      logger.debug "Job has not yet been initialized, creating new id"
      job = Object.const_get(params[:job].to_cc+"Job").create(params, @user)
      logger.debug "Created new Job .... "
      if (job.config['hidden'] == false && @jobs_cart.index(job.jobid).nil?)
      	@jobs_cart.push(job.jobid) 
        logger.debug "Pushing Job into Job Cart : "+job.jobid.to_s
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
    
    if ((@job.jobid !~ /^tu_/ && @job.jobid !~ /^HH_/) || (!@job.user_id.nil? && !@user.nil? && @user.id == @job.user_id) || (!@user.nil? && @user.groups.include?('admin')) ) 
      logger.debug "Delete job in jobs_cart"
     if @jobs_cart.delete(@job.jobid).nil?
        logger.debug "L 139 Could not delete #{@job.jobid} from Cart"
     end  
      @job.remove
      if Job.exists?(@job.id)
        logger.debug "L145 Destroy job #{@job.id} in database"
        #Job.remove(@job.id)
      end

    end
    redirect_to(:host => DOC_ROOTHOST, :controller => tool)
  end

  def forward
    logger.debug "Forward!"
    logger.debug "Toolkit Job: #{params['controller']}"
    logger.debug "Parent Toolkit Job: #{@parent_job.tool}"

    if (params['controller']==@parent_job.tool)
      job_params = @parent_job.actions.first.params
      job_params.each_key do |key|
        if (key =~ /^(\S+)_file$/)
          if !job_params[key].nil? && File.exists?(job_params[key]) && File.readable?(job_params[key]) && !File.zero?(job_params[key])
            params[$1+'_input'] = IO.readlines(job_params[key]).join
          end
        else
          params[key] = job_params[key]
        end
      end
    end
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
      @tmp_sequence ='XX'
      logger.debug "L 173 Rendering Resubmit!"
      job_params = @job.actions.first.params
      tmp_params = job_params.keys
      tmp_params.sort!
      tmp_params.each do |key|
      #job_params.each_key do |key|
        if (key =~ /^(\S+)_file$/) 
              if !job_params[key].nil? && File.exists?(job_params[key]) && File.readable?(job_params[key]) && !File.zero?(job_params[key])
                @tmp_sequence = IO.readlines(job_params[key]).join
                @tmp_sequence.chomp!
                params['sequence_input'] = @tmp_sequence
              end         
        else
          params[key] = job_params[key]
          if (key=~ /sequence_input/)
                logger.debug "L 202 Processing Param sequence_input "
                params['sequence_input'] = @tmp_sequence
          end
        end
    end
      #params['input_sequence']= @tmp_sequence
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
  
  ######
  # Workaround to modify our std dbs 
  # Add the databases to rank up on list 
  # dbs : the dbs found by searching the Standard db directory
  #
  # order_up_dbs : Array of DBs (only names) that shall be ordered up 
  # default : Uniprot, nr70, nr90, nr  
  ######
  def order_std_dbs(dbs, order_up_dbs = nil)
    if order_up_dbs == nil
      order_up_dbs =["uniprot", "nr70","nr90", "nr"]
    end
    order_up_dbs.each do |dbshort|
      dbs.each do |value|
         if File.basename(value) == dbshort
          dbs = dbs -[value]
          dbs = [value] + dbs
        end
      end
    end
   
    
    return dbs
    
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
