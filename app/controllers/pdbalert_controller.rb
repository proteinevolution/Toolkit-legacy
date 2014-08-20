class PdbalertController < ApplicationController

  before_filter :prepare

  def prepare
    @meta_section = params[:action]
    @page_title = "<b>PDBalert</b>: automatic remote homology tracking and structure prediction" 
  end

  def index
    if !@user.nil?
      redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home')
    end
  end

  def logger
    # max log file size: 10MB, Keep 6 of them.
    @logger ||= Logger.new("#{RAILS_ROOT}/log/pdbalert_controller.log", 6, 10485760)
  end

  def help_ov
    @tool = {'name' => 'pdbalert'}
    @section = {'theme' => 'darkred'}
    render(:layout => "help")
  end

  def help_params
    @tool = {'name' => 'pdbalert'}
    @section = {'theme' => 'darkred'}
    render(:layout => "help")
  end

  def help_results
    @tool = {'name' => 'pdbalert'}
    @section = {'theme' => 'darkred'}
    render(:layout => "help")
  end

  def home
    if @user.nil?
   	redirect_to :action => "index"
    end
    @include_js = ['pdbalert','userdbs','hhpred']
    if flash[:notice] && flash[:notice] =~ /Upload/ 
      @upload_on = true;
    else
      @upload_on = false;
    end
    @userdbs = Watchlist.find(:all, :conditions => ["user_id = ?",@user.id], :order => "created_on DESC") 
    @userdbs.each do |userdb|
      userdb.warning_key = 0
      userdb.save!
    end

    #for Upload Section
    @inputmode_values = ["sequence", "alignment"]
    @inputmode_labels = ["Independent FASTA sequence(s)", "Alignment"]
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @maxpsiblastit = ['0','1','2','3','4','5','6','8','10']
    @epsiblastval = ['1E-3', '1E-4', '1E-6', '1E-8', '1E-10', '1E-15', '1E-20', '1E-30', '1E-40', '1E-50']
    @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
    @qid_minval = ['0', '20', '25', '30', '35', '40', '45', '50']
    @maptval = ['0.0', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '0.95']
    @ss_scoring_values = ['2', '0', '4']
    @ss_scoring_labels = ['yes', 'no', 'predicted vs predicted only']
    @compbiascorr_values = ['1', '0']
    @compbiascorr_labels = ['yes', 'no']
    @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
    @confirm = params['confirm'] ? params['confirm'] : "unconfirmed"

    # do we need to show output options part of the form?
    @show_more_options = (@error_params['more_options_on'] == "true")
  end

  def confirm_upload
    @include_js = ['pdbalert']
    @file = params['db_file']
    @inputmode = params['inputmode']
    @dbseq = params['db_seq']
    if !@file.nil? && !@file.blank?
      @db_content = @file.read
    else
      @db_content = @dbseq
    end
    session['db_seq'] = @db_content
    params['db_file'] = ""
    params['db_seq'] = ""

    alignment_possible = false;
    common_length = 0
    @sequences = Array.new
    if(@inputmode == 'sequence')
      @sequences = @db_content.split('>')
      @sequences.delete_at(0)
      if (@sequences.length > 2)
        alignment_possible = true
        @sequences.each do |seq|
           length = 0
           increment = 1
           @parts = seq.split(/\n/,2)
           @parts2 = @parts[1].split(/\s*/)
           @parts2.each do |part|
             if (part =~ />/)
               increment = 0
             end
             length = length + increment
           end
           if (common_length == 0)
             common_length == length
           elsif (common_length != length)
             alignment_possible = false
           end
        end
      end
    end

    if(alignment_possible)
      @url_seq = url_for(:action => 'upload', :parameters => params)
      params['inputmode'] = 'alignment'
      params['informat'] = 'fas'
      @url_align = url_for(:action => 'upload', :parameters => params, :only_path => true)
      @js_onload = "alert_possible_alignment('#{@url_seq}','#{@url_align}');"
    else
      @url_seq = url_for(:action => 'upload', :parameters => params)
      @js_onload = "redir('#{@url_seq}');"
    end
  end

  def upload
    if @user.nil?
       redirect_to :action => "index"
    end

    params['parameters'].each do |attr, value|
      params[attr] = value
    end
    params.delete_if {|attr, value| attr == "parameters"}
    @file = params['db_file']
    params['db_file'] = ""
    @dbseq = session['db_seq']
    params['db_seq'] = ""
    @inputmode = params['inputmode']
    if !@file.nil? && !@file.blank?
      @db_content = @file.read
    else
      @db_content = @dbseq
    end
   
    @sequences = Array.new
    @sequences[0] = @db_content
    alignment_possible = false;
    if(@inputmode == 'sequence')
      @sequences = @db_content.split('>')
      @sequences.delete_at(0)
    end

    error_hash = {}
    if !@sequences.nil? && !@sequences.empty? && error_hash["db_seq"].nil?
      @sequences.each do |seq|
        res = true;
        if(@inputmode == 'sequence')
          seq = ">" + seq
	else
	  tempf = Tempfile.new("pdbalert")
	  tempf.write(seq)
	  tempf.close
	  res = system(File.join(BIOPROGS, 'perl') + "/reformat.pl -f=#{tempf.path} -a=#{tempf.path} -i=#{params['informat']} -o=fas")
	  tempf.open
	  seq = tempf.read
	  tempf.unlink
	end
        
	length = 0
	if( res )
	  #for getting name
	  @parts = seq.split(/\n/,2)
	  @name = @parts[0].chomp.gsub(/>/,'')[0..49]

          #for finding sequence length
          increment = 1
          @parts2 = @parts[1].split(/\s*/)
          @parts2.each do |part|
            if (part =~ />/)
              increment = 0
            end
            length = length + increment
          end												      
	else
	  error_hash["db_seq"] = "Incorrect Input format"
	end
	if (length == 0)
	  error_hash["db_seq"] = "Incorrect Input format"
	end
        userdb = Watchlist.new(:name => @name, :params => params)
        eval "userdb.db_name = @name"
        eval "userdb.db_file = @file"
        eval "userdb.db_seq  = @dbseq"
	eval "userdb.userid = params['userid']"
        eval "userdb.Pmin = params['Pmin']"
	eval "userdb.width = params['width']"
	eval "userdb.informat = params['informat']"
        eval "userdb.maxlines = params['maxlines']"

        if userdb.valid? && error_hash["db_seq"].nil?
          if !File.exist?(File.join(DATABASES, 'pdbwatchlist', @user.login))
            Dir.mkdir(File.join(DATABASES, 'pdbwatchlist', @user.login), 0755)
          end
  	  filename = File.join(DATABASES, 'pdbwatchlist', @user.login, @name.gsub(/\W+/, '_'))+".fas"
          userdb.user_id = @user.id
          File.open(filename, "w") do |f|
            f.write(seq)
          end
          
          #for finding sequence length
          length = 0
	  increment = 1
          @parts2 = @parts[1].split(/\s*/)
          @parts2.each do |part|
	    if (part =~ />/) 
	      increment = 0
	    end
	    length = length + increment
          end
          userdb.length = length
          userdb.path = filename
	  userdb.probability = params['Pmin']
          userdb.save!

	  p = fork do
	    command = "#{TOOLKIT_ROOT}/script/pdb_alert.rb #{userdb.id} >> #{TOOLKIT_ROOT}/log/pdbalert.log 2>&1"
  	    `#{command}`
	  end
	  Process.detach(p)
	else
          userdb.errors.each do |attr, msg|
	    if( error_hash[attr].nil? )
	      error_hash[attr] = msg
	    else 
	      unless (error_hash[attr] =~ /#{Regexp.escape(msg)}/)
                error_hash[attr] = "#{error_hash[attr]}<br />#{msg}"
	      end
	    end
          end
	  session[:errors] = error_hash
	  logger.info "#{error_hash}"
          flash[:notice] = "Upload unsuccessful!"
	end
      end	
    else
      @name  = "none"
      userdb = Watchlist.new(:name => @name)
      eval "userdb.db_name = @name"
      eval "userdb.db_file = @file"
      eval "userdb.db_seq  = @dbseq"
      eval "userdb.userid = params['userid']"
      eval "userdb.Pmin = params['Pmin']"
      eval "userdb.width = params['width']"
      eval "userdb.informat = params['informat']"
      eval "userdb.maxlines = params['maxlines']"
					 
      if !userdb.valid?
	userdb.errors.each do |attr, msg|
          if( error_hash[attr].nil? )
            error_hash[attr] = msg
          else
            unless (error_hash[attr] =~ /#{Regexp.escape(msg)}/)
              error_hash[attr] = "#{error_hash[attr]}<br />#{msg}"
            end
          end
        end
      end
      if(error_hash["db_seq"].nil?)
	error_hash["db_seq"] = "Incorrect input mode"
      end
      session[:errors] = error_hash
      flash[:notice] = "Upload unsuccessful!"
    end
    if(flash[:notice])
      redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home')
    else
      flash[:notice] = "Successfully uploaded your sequence(s). PDBalert will now check your uploaded sequence(s) for homology with PDB proteins and will alert you by email within next few minutes if a significant hit is found."
      redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home' )
    end
  end

  def seq_detail
    if @user.nil?
      redirect_to :action => "index"
    end

    @id = params['id']
    @userdb = Watchlist.find(:first, :conditions => [ "id = ?", @id])
    if @userdb.nil?
      flash[:notice] = "No such record"
      redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home' )
    elsif @userdb.user_id != @user.id
      flash[:notice] = "Permission Denied"
      redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home' )
    else
      @maxpsiblastit = ['0','1','2','3','4','5','6','8','10']
      @epsiblastval = ['1E-3', '1E-4', '1E-6', '1E-8', '1E-10', '1E-15', '1E-20', '1E-30', '1E-40', '1E-50']
      @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
      @qid_minval = ['0', '20', '25', '30', '35', '40', '45', '50']
      @maptval = ['0.0', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '0.95']
      @ss_scoring_values = ['2', '0', '4']
      @ss_scoring_labels = ['yes', 'no', 'predicted vs predicted only']
      @compbiascorr_values = ['1', '0']
      @compbiascorr_labels = ['yes', 'no']
      @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
      
      @file = File.new(@userdb.path)
      @content = ""
      @parts = @file.read.split(/\n/)
      @parts.each do |part|
	part.gsub(/\n/,'')
	if(part =~ />/)
	  part = "\n<b>#{part}</b>\n"
	end
	@content = @content+part
      end
      @content = @content.gsub(/(.{100})/,'\1'+"\n")
#      @parts = @file.read.split(/\n/,2)
#      @parts[1] = @parts[1].gsub(/\n/,'').gsub(/>/,"\n>")
#      @content = @parts[0]+"\n"+@parts[1].gsub(/(.{70})/,'\1'+"\n")
    end
  end

  def automatic_upload
    @job = Job.find(params['id'])
    if(@job.user_id != @user.id)
      flash[:notice] = "Permission Denied"
      redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home' )
    else
      @action = Action.find(:first, :conditions => ["job_id = ?", params['id']])
      @file = File.open(@action.params['sequence_file'])
      @content = @file.read
      @parts = @content.split(/\n/,2)
      @name = @parts[0].chomp.gsub(/>/,'')[0..49]
      length = 0
      increment = 1
      @parts2 = @parts[1].split(/\s*/)
      @parts2.each do |part|
        if (part =~ />/)
          increment = 0
        end
        length = length + increment
      end
										  
      @userdb = Watchlist.create( :informat => 'fas',
			          :db_file  => '',
			  	  :db_seq   => @content,
				  :userid   => @user.id,
				  :user_id  => @user.id,
				  :db_name  => @name,
				  :name     => @name,
				  :path     => File.join(DATABASES, 'pdbwatchlist', @user.login, @name.gsub(/\W+/, '_'))+".fas",
				  :length   => length,
				  :width    => @action.params['width'],
				  :Pmin     => @action.params['Pmin'],
				  :maxlines => @action.params['maxlines'],
				  :params   => @action.params,
				  :probability => @action.params['Pmin']
      				)
      
      if @userdb.valid?
	`cp #{@action.params['sequence_file']} #{@userdb.path}`
	hhm_file = @action.params['sequence_file'].gsub(/sequence_file/,"#{@action.params['jobid']}.hhm")
	command = "cp #{hhm_file} #{TMP}/pdbalert/hhm/#{@user.login}:,#{@name.gsub(/\W+/, '_')}.hhm"
	logger.info "COMMAND: #{command}"
	`#{command}`
      else
        error_hash = { 'db_seq' => 'Nothing'}
        @userdb.errors.each do |attr, msg|
	  unless (error_hash[attr] =~ /#{Regexp.escape(msg)}/)
            error_hash[attr] = "#{error_hash[attr]}<br />#{msg}"
          end
	end
        session[:errors] = error_hash
        flash[:notice] = "Upload unsuccessful!"
      end
																			       
      redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home' )
    end
  end

  def update
    if @user.nil?
      redirect_to :action => "index"
    end

    @userdb = Watchlist.find(:first, :conditions => [ "id = ?", params['id']])
    if @userdb.nil?
      flash[:notice] = "No such record"
    elsif @userdb.user_id != @user.id
      flash[:notice] = "Permission Denied"
    else
      params.each do |attr, value|
	  @userdb.params[attr] = value
      end
      @userdb.probability = params['Pmin']
      @userdb.save
      flash[:notice] = "Parameters Updated"
    end

    redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home' )
  end

  def delete_userdbs
    if @user.nil?
      redirect_to :action => "index"
    end         
   
    @userdbs = params['userdb']
    if !@userdbs.nil?
      @userdbs.each do |userdb|
        db = Watchlist.find(:first, :conditions => [ "user_id = ? AND id = ?", @user.id, userdb ])
        command = "rm -f #{db.path}"
        system(command)
        hhmfile = File.join(TMP, 'pdbalert', 'hhm', "#{@user.login}:,#{db.name.gsub(/\W+/, '_')}.hhm")
        if File.exists?(hhmfile)
          system("rm -f #{hhmfile}")
        end
        hhrfile = File.join(TMP, 'pdbalert', 'hhr', "#{@user.login}:,#{db.name.gsub(/\W+/, '_')}.hhr")
        if File.exists?(hhrfile)
          system("rm -f #{hhrfile}")
        end
        hhrfile = File.join(TMP, 'pdbalert', 'hhr2', "#{@user.login}:,#{db.name.gsub(/\W+/, '_')}.hhr")
        if File.exists?(hhrfile)
          system("rm -f #{hhrfile}")
        end

        Watchlist.delete(db.id)
      end
    else
      flash[:notice] = "No Database is selected"
    end
    redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home')
  end

  def unsatisfactory_result
    if @user.nil?
      redirect_to :action => "index"
    end

    @userdbs = params['userdb']
    if @userdbs.nil?
      flash[:notice] = "No Database is selected"
    else
      db = Watchlist.find(:first, :conditions => [ "user_id = ? AND id = ?", @user.id, @userdbs ])
      if !db.nil?
        db.job_id = 0
        db.save!
      else
	flash[:notice] = "Permission Denied"
      end
    end
    redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home')
  end

  def confirm
    key = params['key']
    userdb = Watchlist.find(:first, :conditions => ["warning_key = ?",key])
    @userdbs = Watchlist.find(:all, :conditions => ["user_id = ?",userdb.user_id])
    @userdbs.each do |db|
      db.warning_key = 0
      db.save!
    end
    redirect_to(:host => DOC_ROOTHOST, :controller => 'pdbalert', :action => 'home')
  end

  def result
    @userdb = Watchlist.find(:first, :conditions => [ "id = ?", params['id']])
    if @userdb.nil?
      flash[:notice] = "No such record"
    elsif @userdb.user_id != @user.id
      flash[:notice] = "Permission Denied"
    else
      @path = @userdb.path
      @parts = @path.split('/')
      @file = @parts.pop
      @username = @parts.pop
      @hhr_file = File.join(TMP,'pdbalert','hhr',@username+':,'+@file.gsub(/\.fas/,'.hhr'))
      if File.exists?(@hhr_file)
        @infile = File.new(@hhr_file)
        @content = @infile.read
      else
        @content = "No previous results found"
      end
    end

    render(:layout => "plain")
  end

end


