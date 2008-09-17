class UserController < ApplicationController
#  before_filter :login_required, :only => [:welcome,:change_password]
#  layout  'scaffold'

  def login
    @meta_section = "login"
    return if generate_blank
    @user = User.new(params['user'])
    if session['user'] = User.authenticate(params['user']['login'], params['user']['password'])
      flash['notice'] = l(:user_login_succeeded)
      @user = session['user']
		@user.jobs.each do |job|
			if (!@jobs_cart.include?(job.jobid) && job.config['hidden'] == false ) 
				@jobs_cart.push(job.jobid)
			end
		end
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
    @user.jobs.each do |job|
	   if @jobs_cart.include?(job.jobid)
	     @jobs_cart.delete(job.jobid)
	   end
    end
    session['user'] = nil
    redirect_to :host => DOC_ROOTHOST, :action => 'login'
  end

  def change_password
    @meta_section = "change_password"  
    return if generate_filled_in
    params['user'].delete('form')
    begin
      User.transaction do
        @user.change_password(params['user']['password'], params['user']['password_confirmation'])
        if @user.save
          UserNotify.deliver_change_password(@user, params['user']['password'])
          flash.now['notice'] = l(:user_updated_password, "#{@user.login}")
        end
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
    elsif (user = User.find_by_login(params['user']['login'])).nil?
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
    @user = User.find_by_id(params['user']['id'])
    if(@user) 
      @user.deleted = 0
      if @user.token_expired? or params['key'] != @user.security_token or not @user.save
        flash.now['notice'] = l(:user_restore_deleted_error, "#{@user['login']}")
        redirect_to :host => DOC_ROOTHOST, :action => 'login'
      else
        session['user'] = @user
        redirect_to :host => DOC_ROOTHOST, :action => 'welcome'
      end
    else
      flash.now['notice'] = l(:user_restore_deleted_error, "")
      redirect_to :host => DOC_ROOTHOST, :action => 'login'      
    end
  end

  def welcome
    @meta_section = "welcome"
  end
  
  def confirm_note
    @meta_section = "confirm"
  end

  def confirm
    @meta_section = "confirm"
    @key = params['key']
    @user = User.find(params['user']['id']) 
    if @user.security_token == @key
      @user.verified = 1
      @user.save
    end
    session['user'] = @user               
  end
  
  protected

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
