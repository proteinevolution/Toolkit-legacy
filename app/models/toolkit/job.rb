  class Job < ActiveRecord::Base
    acts_as_tree :order => "created_on"
    has_many :actions, :order => "created_on"

    # A job may be related to a stat, but does not need to. Letting rails handle this relation
    # produces too much overhead, i.e. it requires restarting the web server more often because
    # it gets type mismatches from different class versions otherwise. Workaround: getStat method.
    # belongs_to :stat

    #    Gibt Fehler beim speichern eines Jobs, wenn man eingeloggt ist (updated? not found...)
 #       belongs_to :user

    include Dbhack
    
    @@export_file_ext = 'export'
    @@export_basename = 'JOBID'
    @@export_type = 'application/octet-stream'

    def logger
      # max log file size: 100MB. Keep 6 of them.
      @logger ||= Logger.new("#{RAILS_ROOT}/log/#{self.class.name.to_us}.log", 6, 104857600)
    end

    def self.set_export_file_ext(val)
      @@export_file_ext = val
    end
    
    def self.set_export_basename(val)
      @@export_basename = val
    end

    def self.set_export_type(val)
      @@export_type = val
    end
    
    def self.export_file_ext
      @@export_file_ext
    end

    def self.export_basename
      @@export_basename
    end

    def self.export_type
      @@export_type
    end

    def self.create_id
      id = (rand(9)+1).to_s
      6.times { id << rand(10).to_s}
      while (Job.find(:first, :conditions => [ "jobid = ?", id])) do #Job.find statt self.find wegen unterschiedlicher typen!!!
        id = (rand(9)+1).to_s
        6.times { id << rand(10).to_s}
      end
      id
    end

    def self.create_increment_id(parent_id)
      id = parent_id
      if (id !~ /^\S+_\d+$/) then id += "_0" end
      begin
        id.scan(/^(\S+)_(\d+)$/) do |base,count|
          count = count.to_i + 1
          id = base + "_" + count.to_s
        end
      end while (Job.find(:first, :conditions => [ "jobid = ?", id]))
      id
    end

    def self.make(parameters, user)
      job = new
      job.init_on_create(parameters, user)
      job
    end

    def firstSave!()
      save!
      logger.debug "###### L78 Job-dir: #{job_dir}"
      if !File.exist?(job_dir)
      	Dir.mkdir(job_dir, 0755)
      end
    end

    def self.create(parameters, user)
      logger.debug "L85 CREATE JOB!"
      job = self.make(parameters, user)
      job.firstSave!
      job
    end

    def init_on_create(parameters, user)
      @user = user
      if parameters['jobid'].nil? || parameters['jobid'].empty? 
      	if parameters['parent'] && parameters['increment_id'] == 'true'
          parameters['jobid'] = self.class.create_increment_id(parameters['parent'])
      	else
          parameters['jobid'] = self.class.create_id 
      	end
      end
      parameters['mail_transmitted'] = false
      parameters = sanitize_params(parameters)
      
      self.jobid = parameters['jobid']
      self.tool = parameters[:controller]
      if parameters['parent']
        self.parent = Job.find(:first, :conditions => [ "jobid = ?", parameters['parent']])
      end
      self.status = STATUS_INIT

      if (!@user.nil?)
        logger.debug "###### L111 User: #{@user.id}"
        self.user_id = @user.id
      end
      
    end

    def sanitize_params(parameters)
      parameters.keys.each do |key|
        if parameters[key] == '' then parameters[key] = nil end
      end
      return parameters
    end

    def run(actiontype=nil, parameters={ })
      self.status = STATUS_RUNNING
      save!
      
      parameters = sanitize_params(parameters)
      
      #RAILS_DEFAULT_LOGGER.debug "############# L130 Running job! \n### " + parameters.inspect
      
      fw_c = parameters[:forward_controller] ? parameters[:forward_controller] : parameters[:controller]
      fw_a = parameters[:forward_action] ? parameters[:forward_action] : 'results'
      actiontype = actiontype.nil? ? stripped_class_name+"Action" : actiontype.to_cc+"Action"
      newaction = Object.const_get(actiontype).new(:params => parameters,
                                                   :job => self,
                                                   :status => STATUS_INIT,
                                                   :forward_controller => fw_c,
                                                   :forward_action => fw_a
                                                   )
      parameters.each do |key,value|                                                 
        if (key != "controller" && key != "action" && key != "job" && key != "parent" && key != "method" &&
            key != "forward_controller" && key != "forward_action" && newaction.respond_to?(key))
          #logger.debug "##### L144 eval mit key: #{key} und value: #{value}!"
          eval "newaction."+key+" = value"
        end
      end
      # check for genome checkboxes in the form, extract taxids
      # collect the corresponding db files in the action script - can be protein or dna files
      newaction.process_genomes
      if newaction.valid?
        
        # save uploaded files in job_dir under name of html element
        parameters.keys.each do |k|
          if parameters[k].instance_of?(StringIO) || parameters[k].instance_of?(Tempfile) || parameters[k].instance_of?(ActionController::UploadedTempfile) || parameters[k].instance_of?(ActionController::UploadedStringIO)
            parameters[k].rewind
            filename = File.join(job_dir, k)
            File.open(filename, "w") do |f|
              f.write(parameters[k].read)
            end
            newaction.params[k] = filename
          end
        end
        
        # save sequence input as file
        if (!parameters['sequence_input'].nil? && !parameters['sequence_input'].empty?)
          
          filename = File.join(job_dir, 'sequence_file')
          File.open(filename, "w") do |f|
            f.write(parameters['sequence_input'])
          end
          newaction.params['sequence_input'] = nil
          newaction.sequence_input = nil
          newaction.params['sequence_file'] = filename
          newaction.sequence_file = filename
        end
        
        # save result_textbox_to_file to file
        if (!parameters['result_textbox_to_file'].nil? && !parameters['result_textbox_to_file'].empty?)
          
          filename = File.join(job_dir, 'result_textbox_to_file')
          File.open(filename, "w") do |f|
            f.write(parameters['result_textbox_to_file'])
          end
          newaction.params['result_textbox_to_file'] = filename
        end
        
        newaction.save!
        newaction.run
      else
        logger.debug "######### L191  Errors found!!!\n";
        newaction.errors.each_full { |msg| logger.debug msg }
        error_hash = {}
        newaction.errors.each { |attr, msg| error_hash[attr] = msg }
        return error_hash
      end
      return nil
    end

    def stripped_class_name
      self.class.to_s.gsub!("Job", "")
    end

    def done?
      self.status == STATUS_DONE
    end

    def error?
      self.status == STATUS_ERROR
    end

    def finished?
      done? || error?
    end

    def statuslog
      File.new(statuslog_path, 'a+')
    end

    def statuslog_path
      File.join(job_dir, "status.log")
    end

    def render_statuslog
      if File.exists?(statuslog_path)
        lines = IO.readlines(statuslog_path)
        return lines.join('')
      else
        statuslog
        return ""
      end
    end
    
    def before_results(controller_params)
      self.viewed_on = Time.now
      self.save!
    end

    def config
      #    	RAILS_DEFAULT_LOGGER.debug "### L240: " + self.class.to_s.to_us
      #logger.debug " L241 Loading YAMLDATA for #{tool.to_us} "
      (YAML.load_file(File.join(TOOLKIT_ROOT, 'config', tool.to_us + '_jobs.yml')))[self.class.to_s.to_us]
    end

    def url_for_job_dir
      TMP_REL + "/#{self.id}"
    end

    def url_for_job_dir_abs
      DOC_ROOTURL + TMP_REL + "/#{self.id}"
    end

    def job_dir
      File.join(TMP, self.id.to_s)
    end

    def params
      actions.last.params
    end
    
    def params_main_action
      actions.first.params
    end
    
    def render_file(filename)
      lines = IO.readlines(File.join(job_dir, filename))
      return lines.join('')
    end

    def forward_params
      action = actions.last
      fw_p = action.forward_params
      action.active = false
      action.save!
      action.reload
      fw_p
    end

    def active?
      actions.last.active
    end

    def to_param
      self.jobid
    end

    def update_status
      self.reload
      # update_status may be called by still running workers after
      # the job has been removed. Then avoid exceptions because the
      # action list already is cleared.
      if actions.empty?
        return
      else
        newstate = actions.inject(STATUS_DONE)  do |s, action|
          STATUS_CMP[action.status] < STATUS_CMP[s] ? action.status : s
        end
      end
      self.status = newstate
      self.save!
      if (finished?)
      	logger.debug "L302 Job update status #{newstate}"
      	if (!params_main_action['mail'].nil?)# && params_main_action['mail_transmitted'] == false)
          if (done?)
            logger.debug "L305 Mailer with mail: #{params_main_action['mail']}"
            ToolkitMailer.deliver_mail_done(params_main_action)
          else
            logger.debug "L308 Error-mailer with mail: #{params_main_action['mail']}"
            ToolkitMailer.deliver_mail_error(params_main_action)
          end
          actions.first.params['mail_transmitted'] = true
          actions.first.save!
      	end
        if done?
          stat = getStat;
          if stat
            mytime = getTime()
            if (mytime >= 1)
              stat.addJob(mytime)
            end
            if (File.exists?(statuslog_path))
                File.open(statuslog_path, "a") do |file|
                  file.puts "#{tool} job completed (#{mytime}s cpu time)."
                end
            end
          end
        end
      end
    end

    def run_on
      if (actions.last)
        actions.last.created_on
      else
        0
      end
    end

    # returns the forward controller of the last action that has not yet
    # been forwarded. This happens to make it possible to get back to main results
    # after he has forwarded its results to another tool.
    def forward_controller
      action = actions.reverse.find() {|a| a.active } || actions.last
      action.forward_controller
    end

    # returns the forward action of the last action that has not yet
    # been forwarded. This happens to make it possible to get back to main results
    # after he has forwarded its results to another tool.
    def forward_action
      action = actions.reverse.find() {|a| a.active } || actions.last
      action.forward_action
    end
    
    def export
    end
    
    def remove
      logger.debug "L359 Stop queue_worker"    
      actions.each do |action| 
        action.queue_jobs.each do |qj|
          logger.debug "L362 Destroy worker!"
          AbstractWorker.destroy_all "queue_job_id = #{qj.id}"
        end
        logger.debug "L365 Destroy queue_jobs!"
        QueueJob.destroy_all "action_id = #{action.id}"
      end
      
      #logger.debug "L369 Destroy actions!"
      Action.delete_all "job_id = #{id}"
      # remove children
      children.each do |childJob|
        childJob.remove
      end

      # a job without actions will cause errors, so for consistence, delete it too.
      logger.debug "L377 destroy job #{id}"
      destroy

      cleanup_jobdir
    end

    def cleanup_jobdir
      begin
        logger.debug "L385 Cleaning up JobDir: #{job_dir}"
        directory_content = Dir.entries("#{job_dir}")
        #logger.debug "L387 Entries length: #{directory_content.length}"
        #logger.debug "L388 Entries: #{directory_content}"
        directory_content.each  do |file|
          if (file != ".." && file != ".")
            file = "#{job_dir}/#{file}"
            #if (File.exists? file)
              FileUtils.remove_entry_secure(file)
             # system ("rm -r #{file}")
            #end
          end
        end
        # do not delete jobdir, this is done be a daily sweep script
        #Dir.delete(job_dir)
 
      rescue SystemCallError => ex
        # Probably the directory or a file already has been deleted.
        # I.e., the sge engine already cleans up files after a queue job finishes.
        # Nothing more to do.
        logger.debug "L405 SystemCallError: #{ex}"
      end
    end

    def getTime
      total = 0
      actions.each do |action|
        total += action.getTime
      end

      # Add times of child jobs (jobs which have this job as a
      # parent), which not have an own stat reference to count them
      children.each do |childJob|
        unless childJob.getStat
          total += childJob.getTime
        end
      end
      total
    end

    # getToolShortcut determines the "code" of the tool, which the user
    # started.
    # This may be different from the tool attribute (i.e. an hhpred job started
    # for prescreening by tool hhsenser has tool hhpred but shortcut HHSE).
    # returns a tool name or nil, but never an empty string.
    def getToolShortcut
      if parent && !getStat # for compatibility with getTime method
        parent.getToolShortcut
        # the child tool property can be recognized by the id suffix. Without
        # adding its shortcut to the tool shortcut, log files can be parsed
        # with less overhead.
      else
        shortcut = config['code']
        if shortcut && !shortcut.empty?
          shortcut
        else
          nil
        end
      end
    end

    def getStat
      if self.stat_id
        Stat.find(self.stat_id)
      else
        nil
      end
    end

    def setStat(stat)
      if stat
        self.stat_id = stat.id
      else
        self.stat_id = nil
      end
    end

  def save!
    begin
      super
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L466 job.rb Job.save!: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      super
    end
  end
end
