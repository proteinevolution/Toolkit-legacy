class UserController < ApplicationController
#  before_filter :login_required, :only => [:welcome,:change_password]
#  layout  'scaffold'

  # most flash notices and messages are not displayed because
  # it's turned off in the view (head_helper).
  # Because flash is stored in the session, execpt of flash.now it only works
  # if cookies are enabled.

  def logger
    # Be careful of what to log because of protection of data privacy.
    # max log file size: 10M. Keep 2 of them.
    @logger ||= Logger.new("#{RAILS_ROOT}/log/user_controller.log", 2, 10485670)
  end

  def login
    @meta_section = "login"
    return if generate_blank
    @user = User.new(params['user'])
    if session['user'] = User.authenticate(params['user']['login'], params['user']['password'])
      flash['notice'] = l(:user_login_succeeded)
      @user = session['user']
      protected_fill_jobs_cart
      redirect_to :host => DOC_ROOTHOST, :action => 'welcome'
    else
      @login = params['user']['login']
      flash.now['message'] = l(:user_login_failed)
    end
  end

  def signup
    @meta_section = "signup" 
    return if generate_blank
    session['user'] = nil
    params['user'].delete('form')
    @user = User.new(params['user'])
    begin
      User.transaction do
        @user.new_password = true
        if @user.save
          key = @user.generate_security_token
          url = url_for(:host => DOC_ROOTHOST, :action => 'confirm')
          url += "?user[id]=#{@user.id}&key=#{key}"
          UserNotify.deliver_signup(@user, params['user']['password'], url)
          flash['notice'] = l(:user_signup_succeeded)
          redirect_to :host => DOC_ROOTHOST, :action => 'confirm_note'
        end
      end
    rescue
      flash.now['message'] = l(:user_confirmation_email_error)
    end
  end  
  
  def logout
    @meta_section = "logout"
    protected_clear_jobs_cart
    session['user'] = nil
    redirect_to :host => DOC_ROOTHOST, :action => 'login'
  end

  def change_password
    @meta_section = "change_password"  
    return if generate_filled_in
    if session['user'].nil?
      @key = params['key']
      @user = User.protected_find(params['user']['id']) 
      if @user.security_token != @key
        flash.now['message'] = l(:user_change_password_key_error)
        return
      end    
    end

    params['user'].delete('form')
    begin
      User.transaction do
        # logger.debug "L76 User #{@user}" # don't log because of privacy
        @user.change_password(params['user']['password'], params['user']['password_confirmation'])
        logger.debug "L78 Password changed"
        if @user.save
          UserNotify.deliver_change_password(@user, params['user']['password'])
          flash.now['notice'] = l(:user_updated_password, "#{@user.login}")
        end
        logger.debug "L83 User saved"
      end
    rescue
      flash.now['message'] = l(:user_change_password_email_error)
    end
  end

  def forgot_password
    @meta_section = "forgot_password" 
    # Always redirect if logged in
    if user?
      flash['message'] = l(:user_forgot_password_logged_in)
      redirect_to :host => DOC_ROOTHOST, :action => 'change_password'
      return
    end

    # Render on :get and render
    return if generate_blank

    # Handle the :post
    if params['user']['login'].nil?
      flash.now['message'] = l(:user_enter_valid_email_address)
    elsif (user = User.protected_find_by_login(params['user']['login'])).nil?
      flash.now['message'] = l(:user_email_address_not_found, "#{params['user']['login']}")
    else
      begin
        User.transaction do
          key = user.generate_security_token
          url = url_for(:host => DOC_ROOTHOST, :action => 'change_password')
          url += "?user[id]=#{user.id}&key=#{key}"
          UserNotify.deliver_forgot_password(user, url)
          flash['notice'] = l(:user_forgotten_password_emailed, "#{params['user']['login']}")
          unless user?
            redirect_to :host => DOC_ROOTHOST, :action => 'login'
            return
          end
          redirect_to :host => DOC_ROOTHOST, :action => 'welcome'
        end
      rescue
        flash.now['message'] = l(:user_forgotten_password_email_error, "#{params['user']['login']}")
      end
    end
  end

  def edit
  	 @meta_section = "edit"  
    return if generate_filled_in
    if params['user']['form']
      form = params['user'].delete('form')
      begin
        case form
        when "edit"
          changeable_fields = UserSystem::CONFIG[:changeable_fields]
          p = params['user'].delete_if { |k,v| not changeable_fields.include?(k) }
          @user.attributes = p
          @user.save
        when "change_password"
          change_password
        when "delete"
          delete
        else
          raise "unknown edit action"
        end
      end
    end
  end

  def delete
    @meta_section = "delete"  
    @user = session['user']
    begin
      if UserSystem::CONFIG[:delayed_delete]
        User.transaction do
          key = @user.set_delete_after
          url =  url_for(:host => DOC_ROOTHOST, :action => 'restore_deleted')
          url += "?user[id]=#{@user.id}&key=#{key}"
          UserNotify.deliver_pending_delete(@user, url)
        end
      else
        session['user'] = nil;
        destroy(@user)
      end
      logout
    rescue
      flash.now['message'] = l(:user_delete_email_error, "#{@user['login']}")
      redirect_to :host => DOC_ROOTHOST,  :action => 'welcome'
    end
  end

  def restore_deleted
    @meta_section = "restore_delete" 
    @user = User.protected_find_by_id(params['user']['id'])
    if(@user) 
      @user.deleted = 0
      if @user.token_expired? or params['key'] != @user.security_token or not @user.save
        flash['notice'] = l(:user_restore_deleted_error, "#{@user['login']}")
        redirect_to :host => DOC_ROOTHOST, :action => 'login'
      else
        session['user'] = @user
        redirect_to :host => DOC_ROOTHOST, :action => 'welcome'
      end
    else
      flash['notice'] = l(:user_restore_deleted_error, "")
      redirect_to :host => DOC_ROOTHOST, :action => 'login'      
    end
  end

  def welcome
    @meta_section = "welcome"
    if @user.nil?
      logger.debug("L193 welcome with undefined user")
      # with session errors, flash does not work.
      flash['message'] = l(:user_session_error)
      redirect_to :host => DOC_ROOTHOST, :action => 'nosession'
    end
  end

  def nosession
    @meta_section = "nosession"
  end
  
  def confirm_note
    @meta_section = "confirm"
  end

  def confirm
    # params['user'] sometimes is nil.
    # Propably no session information? Remind user to allow cookies?
    if (params.nil? || params['user'].nil?)
      logger.debug("L212 No user parameter in session")
      # with session errors, flash does not work.
      flash['message'] = l(:user_confirm_error)
      redirect_to :host => DOC_ROOTHOST, :action => 'nosession'
      return;
    end
    @meta_section = "confirm"
    @key = params['key']
    @user = User.protected_find(params['user']['id']) 
    if @user.security_token == @key
      @user.verified = 1
      @user.save
    end
    session['user'] = @user
  end

  def protected_fill_jobs_cart
    begin
      fill_jobs_cart
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L232 User.protected_fill_jobs_cart: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      fill_jobs_cart
    end
  end

  def protected_clear_jobs_cart
    begin
      clear_jobs_cart
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L242 User.protected_clear_jobs_cart: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      clear_jobs_cart
    end
  end
  
  protected

  def fill_jobs_cart
    begin
      @user.jobs.each do |job|
        if (!@jobs_cart.include?(job.jobid))
          if (job.config.nil?)
            logger.debug("L255 Missing config of #{job.type}:#{job.jobid} in #{job.tool.to_us}_jobs.yml")
          elsif (job.config['hidden'] == false)
            @jobs_cart.push(job.jobid)
          end
        end
      end
    rescue ActiveRecord::SubclassNotFound
      # enable login even if some job class does not exist in the current system.
    end
  end

  def clear_jobs_cart
    if @user.nil?
      logger.debug("L268 Cannot remove user's jobs from jobs cart, because there is no user information. Probably cookies/session information disabled.")
      return
    end
    begin
      @user.jobs.each do |job|
        if @jobs_cart.include?(job.jobid)
          @jobs_cart.delete(job.jobid)
        end
      end
    rescue ActiveRecord::SubclassNotFound
      # enable logout even if some job class doesn't exist on this toolkit installation.
    end
  end

  def destroy(user)
    UserNotify.deliver_delete(user)
    flash['notice'] = l(:user_delete_finished, "#{user['login']}")
    user.destroy()
  end

  def protect?(action)
    if ['login', 'signup', 'forgot_password'].include?(action)
      return false
    else
      return true
    end
  end

  # Generate a template user for certain actions on get
  def generate_blank
    case request.method
    when :get
      @user = User.new
      render
      return true
    end
    return false
  end

  # Generate a template user for certain actions on get
  def generate_filled_in
    @user = session['user']
    case request.method
    when :get
      render
      return true
    end
    return false
  end
end
