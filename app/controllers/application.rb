require 'localization'
require 'user_system'

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include Localization
  include UserSystem

#patch functions for user/group managment to this class
  include UserGroupModule

# Comment out on 1.4.08 because of rails error !!!!!!!
#  helper :user
#  model  :user

  before_filter :setup
    
  def save_params
    params[:action] = "index"
    #create new action object for current controller and set params
    actiontype = actiontype.nil? ? params[:controller].capitalize+"Action" : actiontype.to_cc+"Action"
    newaction = Object.const_get(actiontype).new
    newaction.params = params.clone
    #params that should not be saved
    newaction.params['jobid'] = ""
    newaction.params['sequence_input'] = ""
    newaction.params['mail'] = ""
    #save params
    tool = params[:controller]
    newaction.saveparams(@user.id, tool)
    #newaction.saveparams(-1, tool)
    #redirect to index page
    redirect_to(:params => params)
  end
  
  def load_params(id = @user.id)
    #create new action object for current controller and set params
    actiontype = actiontype.nil? ? params[:controller].capitalize+"Action" : actiontype.to_cc+"Action"
    newaction = Object.const_get(actiontype).new
    #load params from action object and redirect to index page
    tool_params = newaction.loadparams(id, params[:controller])
    if tool_params.first.nil?
      #no entry in db
      load_default_params
    else
      params_tmp = tool_params.first['glob']
      #params_tmp[:action] = "index"
      params_tmp[:redirected] = true
      redirect_to :params => params_tmp#, :controller => params[:controller]
    end
  end
  
  def load_default_params
    load_params(-1)
  end

  def setup
    require 'yaml'
    @sections = YAML.load_file(::CONFIG + "/sections.yml")
    @sections_hash = array_to_hash(@sections, 'name')
    @tools = YAML.load_file(::CONFIG + "/tools.yml").sort {|a,b| a['title'].downcase <=> b['title'].downcase}
    @tools_hash = array_to_hash(@tools, 'name')
    @jobs_cart = find_cart()
    @tool = nil
    @section = nil
    @meta_section = nil
    @errors = session[:errors] ? session[:errors] : {}
    @error_params = session[:params] ? session[:params] : {}
    #session['user'] = session['user'].nil? ? nil : session['user'].reload
    unless session['user'].nil?
      begin
        session['user'] = session['user'].reload
      rescue ActiveRecord::StatementInvalid => e
        logger.debug("L75 application.rb ApplicationController.setup: Got statement invalid #{e.message} ... trying again")
        ActiveRecord::Base.verify_active_connections!
        session['user'] = session['user'].reload
      end
    end
    @user = session['user']
    session[:errors] = nil
    session[:params] = nil

    sessionfile = File.join(TMP, "sequence_input_"+session.session_id)
    if File.exists?(sessionfile)
      File.open(sessionfile, 'r') do |f|
        @error_params['sequence_input'] = f.read
      end
      File.delete(sessionfile)
    end

  end
  
  def find_cart
    session[:jobs_cart] ||= JobsCart.new  
  end
  
  def array_to_hash(array, key)
    hash = Hash.new
    for elem in array do
      hash[elem[key]] = elem
    end
    return hash
  end
 
  def check
    @job = Job.find(:first, :conditions => [ "jobid = ?", params[:jobid]])
    if @job.nil?
      @error = {'check_jobid' => 'Unknown jobid!'}
      session[:errors] = @error
      redirect_to :back
    else
      if ((@user.nil? && @job.user_id.nil?) || (!@user.nil? && 
          (@user.groups.include?('admin') || @job.user_id.nil? || @user.id == @job.user_id)))
        if (@jobs_cart.index(@job.jobid).nil? && @job.config['hidden'] == false)
          @jobs_cart.push(@job.jobid) 
        end	     
	     if @job.done?
          fw_c = @job.forward_controller || params[:controller]
          fw_a = @job.forward_action || "results"
          redirect_to(:host => DOC_ROOTHOST, :controller => fw_c, :action => fw_a, :jobid => @job)
        else
          redirect_to(:host => DOC_ROOTHOST, :controller => @job.tool, :action => "waiting", :jobid => @job)
        end
      else
        @error = {'check_jobid' => 'Permission denied!'}
        session[:errors] = @error
        redirect_to :back
      end
    end
  end
  
  def clear
    if (!(params[:jobid].nil? || params[:jobid].empty?))
      params[:jobid].each do |jobid| 
        @jobs_cart.delete(jobid)
      end
    end
    redirect_to(:host => DOC_ROOTHOST, :controller => 'common')
  end
  
  def removeJobs
    if (!(params[:jobid].nil? || params[:jobid].empty?))
      params[:jobid].each do |jobid| 
        @job = Job.find(:first, :conditions => [ "jobid = ?", jobid])
        if (!@job.nil? && ((@job.jobid !~ /^tu_/ && @job.jobid !~ /^HH_/) || (!@job.user_id.nil? && !@user.nil? && @user.id == @job.user_id) || (!@user.nil? && @user.groups.include?('admin'))) )        
          @job.remove
          logger.debug "Delete job in jobs_cart"
          @jobs_cart.delete(@job.id)
          logger.debug "Destroy job #{@job.id} in database"
          Job.delete(@job.id)
        end
      end
    end
    redirect_to(:host => DOC_ROOTHOST, :controller => 'common')
  end
  # Testing Commit to WYE
  # sorts jobs by comparing their ids lexicographically 
  # use factor -1 to reverse result 
  def sort_jobids(factor)
    @jobs_cart.sort! do | jobid1, jobid2 |
      factor * (jobid1 <=> jobid2)
    end
    redirect_to(:back)
  end
   
  # sorts jobs by their ids in ascending order by calling sort_jobids with factor -1
  def sort_jobids_asc
    sort_jobids(-1)
  end
  
  # sorts jobs by their ids in descending order by calling sort_jobids with factor 1
  def sort_jobids_desc
    sort_jobids(1)
  end
 
  # sorts jobs by their status
  # order: e > q > r > d
  def sort_jobstatus(factor)
    @jobs_cart.sort! do | jobid1, jobid2 |
      job1 = Job.find(:first, :conditions => [ "jobid = ?", jobid1])
      job2 = Job.find(:first, :conditions => [ "jobid = ?", jobid2])
      status1 = job1.status unless job1.nil?
      status2 = job2.status unless job2.nil?
      res = 0
      case status1
      when 'q'
        case status2
        when 'r'
          res = 1
        when 'd'
          res = 1
        when 'e'
          res = -1
        when nil
          res = 1
        end
      when 'r'
        case status2
        when 'q'
          res = -1        
        when 'd'
          res = 1
        when 'e'
          res = -1
        when nil
          res = 1
        end
      when 'd'
        case status2
        when 'q'
          res = -1
        when 'r'
          res = -1
        when 'e'
          res = -1
        when nil
          res = 1
        end
      when 'e'
        case status2
        when 'q'
          res = 1
        when 'r'
          res = 1
        when 'd'
          res = 1
        when nil
          res = 1
        end
      when nil
        res = status2.nil? ? 0 : -1
      else
        res = 0
      end
      res * factor
    end
    redirect_to(:back)
  end
  
  # sorts jobs by their status in ascending order by calling sort_jobstatus
  def sort_status_asc
    sort_jobstatus(-1)
  end
  
  # sorts jobs by their status in descending order by calling sort_jobstatus
  def sort_status_desc
    sort_jobstatus(1)
  end
  
  # sorts jobs by lexicographic order of their tool-name
  # use factor -1 to reverse result
  def sort_jobtool(factor)
    @jobs_cart.sort! do | jobid1, jobid2 |
      job1 = Job.find(:first, :conditions => [ "jobid = ?", jobid1])
      job2 = Job.find(:first, :conditions => [ "jobid = ?", jobid2])
      if job1.nil? && job2.nil?
        0
      elsif job1.nil? && !job2.nil?
        -1
      elsif !job1.nil? && job2.nil?
        1
      else
        tool1 = job1.tool
        tool2 = job2.tool
        factor * (tool1 <=> tool2)
      end
    end
    redirect_to(:back)
  end
  
  # sorts jobs by their toolname in ascending lexicographic order by calling sort_jobtool
  def sort_tool_asc
    sort_jobtool(-1)
  end
  
  # sorts jobs by their toolname in descending lexicographic order by calling sort_jobtool
  def sort_tool_desc
    sort_jobtool(1)
  end
  
end
