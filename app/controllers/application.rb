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
    session['user'] = session['user'].nil? ? nil : session['user'].reload
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
  
end
