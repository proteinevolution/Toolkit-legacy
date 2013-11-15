  class Job < ActiveRecord::Base
    acts_as_tree :order => "created_on"
    has_many :actions, :order => "created_on"
    #    Gibt Fehler beim speichern eines Jobs, wenn man eingeloggt ist (updated? not found...)
 #       belongs_to :user

    include Dbhack
    
    @@export_file_ext = 'export'
    @@export_basename = 'JOBID'
    @@export_type = 'application/octet-stream'

    def logger
      @logger ||= Logger.new("#{RAILS_ROOT}/log/#{self.class.name.to_us}.log")
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

    def self.create(parameters, user)
      logger.debug "CREATE JOB!"
      job = new
      job.init_on_create(parameters, user)
      job.save!
      logger.debug "###### Job-dir: #{job.job_dir}"
      if !File.exist?(job.job_dir)
      	Dir.mkdir(job.job_dir, 0755)
      end
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
      self.parent = Job.find(:first, :conditions => [ "jobid = ?", parameters['parent']])
      self.status = STATUS_INIT

      if (!@user.nil?)
        logger.debug "###### User: #{@user.id}"
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
      
      #RAILS_DEFAULT_LOGGER.debug "############# Running job! \n### " + parameters.inspect
      
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
          #logger.debug "##### eval mit key: #{key} und value: #{value}!"
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
        logger.debug "#########   Errors found!!!\n";
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
      #    	RAILS_DEFAULT_LOGGER.debug "###: " + self.class.to_s.to_us
      #logger.debug " L219 Loading YAMLDATA for #{tool.to_us} "
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
      stat = actions.inject(STATUS_DONE)  do |s, action|
        STATUS_CMP[action.status] < STATUS_CMP[s] ? action.status : s
      end
      self.status = stat
      self.save!
      if (done? || error?)
      	logger.debug "Job update status done"
      	if (!params_main_action['mail'].nil?)# && params_main_action['mail_transmitted'] == false)
          logger.debug "mail founded!"
          if (done?)
            logger.debug "Mailer with mail: #{params_main_action['mail']}"
            ToolkitMailer.deliver_mail_done(params_main_action)
          else
            logger.debug "Error-mailer with mail: #{params_main_action['mail']}"
            ToolkitMailer.deliver_mail_error(params_main_action)
          end
          actions.first.params['mail_transmitted'] = true
          actions.first.save!
          
      	end
      end
    end

    def run_on
      actions.last.created_on
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
      logger.debug "Stop queue_worker"    
      actions.each do |action| 
        action.queue_jobs.each do |qj|
          qj.workers.each do |worker|
            if worker.status != STATUS_DONE
              #worker.delete
          end
          end
          logger.debug "L322 Destroy worker!"
          AbstractWorker.destroy_all "queue_job_id = #{qj.id}"
        end
        logger.debug "L325 Destroy queue_jobs!"
        QueueJob.destroy_all "action_id = #{action.id}"
      end
      
      #logger.debug "Destroy actions!"
      Action.delete_all "job_id = #{id}"
      logger.debug "L331 JobDir: #{job_dir}"
      directory_content = Dir.entries("#{job_dir}")
      #logger.debug "Entries length: #{directory_content.length}"
      #logger.debug "Entries: #{directory_content}"
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
    end

  end
