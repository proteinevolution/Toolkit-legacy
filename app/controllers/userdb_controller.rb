class UserdbController < ApplicationController

  before_filter :prepare

  def prepare
    @meta_section = params[:action]
  end

  def admin_userdbs
    @upload_url = url_for(:host => DOC_ROOTHOST, :controller => 'userdb', :action => 'upload_userdb')
    @userdbs = []
    if !@user.nil?
      @userdbs = @user.userdbs ? @user.userdbs : []
    else
      @userdbs = Userdb.find(:all, :conditions => [ "user_id = ? AND sessionid = ?", 0, session.session_id ])
    end
    @size = 0
    @userdbs.each do |db|
      @size += db.size
    end
    if @size > 0
    	@size = @size / (1024*1024)
    end
  end
  
  def upload_userdb
    @uploaded_db = params['uploaded'] ? params['uploaded'] : nil
    @uploaded_db_path = params['uploaded_path'] ? params['uploaded_path'] : nil
    @type = params['type'] ? params['type'] : "p"
    @dbtype_labels = ["Protein", "Nucleotide"]
    @dbtype_values = ["p", "n"]
    
    @include_js = 'userdbs'
    if !@uploaded_db.nil?
      @js_onload = "updateUserDB();"
      @include_js_text = "var uploaded_db = '#{@uploaded_db}'; var uploaded_db_path = '#{@uploaded_db_path}';"
    end
    
    render(:layout => "plain")     
  end

  def upload
    @name = params['dbname']
    @file = params['dbfile']
    @dbtype = params['dbtype']
    userdb = Userdb.new(:name => @name, :dbtype => @dbtype, :sessionid => session.session_id)

    eval "userdb.dbname = params['dbname']"
    eval "userdb.dbfile = params['dbfile']"    
    eval "userdb.userid = params['userid']"    
    
    if userdb.valid?
      if @user.nil?
        if !File.exist?(File.join(DATABASES, 'userdbs', 'not_login'))
          Dir.mkdir(File.join(DATABASES, 'userdbs', 'not_login'), 0755)
        end
        filename = File.join(DATABASES, 'userdbs', 'not_login', session.session_id + "_" + @name.gsub(/\s+/, '_'))
        userdb.user_id = 0
      else
        if !File.exist?(File.join(DATABASES, 'userdbs', @user.login))
          Dir.mkdir(File.join(DATABASES, 'userdbs', @user.login), 0755)
        end
        filename = File.join(DATABASES, 'userdbs', @user.login, @name.gsub(/\s+/, '_'))
        userdb.user_id = @user.id
      end
      
      file = File.open(userdb.tempfile)
      File.open(filename, "w") do |f|
        f.write(file.read)
      end
      userdb.path = filename
      userdb.size = File.size(filename)
      userdb.save!

      formatdb(@dbtype, filename, userdb.id)
	   redirect_to(:host => DOC_ROOTHOST, :controller => 'userdb', :action => 'upload_userdb', 'uploaded' => @name, 'uploaded_path' => filename)
    else
#      userdb.errors.each_full { |msg| logger.debug "###### #{msg}" }
      error_hash = {}
      userdb.errors.each { |attr, msg| error_hash[attr] = msg }
      session[:errors] = error_hash
      redirect_to(:host => DOC_ROOTHOST, :controller => 'userdb', :action => 'upload_userdb')
    end
  end
  
  def formatdb(type, path, db_id)
    if (type == 'p')
	   type = 'T';				
	 else
	   type = 'F';
    end

    
    format_command = File.join(BIOPROGS,'blast') + "/formatdb -i #{path} -p #{type};"
    updatedb_commmand = File.join(TOOLKIT_ROOT,"script","update_userdb.rb")+" #{db_id};"

    command_file = path + ".sh"
    path.sub!(/^(.*)\/.+?$/, '\1')

    queue = QUEUES[:immediate]
    usequeue = queue && queue != "" && queue[0] != "-"[0]
    timelimit = nil
    if (defined? QUEUETIMELIMITS && QUEUETIMELIMITS) then
      timelimit = QUEUETIMELIMITS[:immediate]
    end

    File.open(command_file, "w") do |f|
      f.write "#!/bin/sh\n"
      f.write '#$' + " -N TOOLKIT_userdb\n"
      if usequeue
        f.write '#$' + " -q #{queue}\n"
        f.write '#$' + " -l immediate\n"
      end
      if timelimit
        f.write '#$' + " -l h_rt=#{timelimit}\n"
      end
      f.write '#$' + " -o /dev/null\n"
      f.write '#$' + " -e /dev/null\n"
      f.write '#$' + " -w n\n"
      f.write '#$' + " -wd #{path}\n\n"
      f.write("#{format_command} #{updatedb_commmand}")
    end

    system("#{QUEUE_DIR}/qsub #{command_file}")
  end
  
  def delete_userdbs
    @userdbs = params['userdb']  
    @userdbs.each do |userdb|
      if @user.nil?
    	  db = Userdb.find(:first, :conditions => [ "user_id = ? AND sessionid = ? AND name = ?", 0, session.session_id, userdb ])
    	else
    	  db = Userdb.find(:first, :conditions => [ "user_id = ? AND name = ?", @user.id, userdb ])
    	end
    	command = "rm #{db.path}*"
#    	logger.debug "###### Command: #{command}"
    	system(command)
    	Userdb.delete(db.id)    
    end
    redirect_to(:host => DOC_ROOTHOST, :controller => 'userdb', :action => 'admin_userdbs')
  end

end
