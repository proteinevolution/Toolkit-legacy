 class SgeWorker < AbstractWorker
    set_table_name "queue_workers"
    belongs_to :queue_job  
    
    def execute
      basename = File.join(queue_job.action.job.job_dir, id.to_s)
      self.commandfile = basename+".sh"
      self.wrapperfile = basename+"wrapper.sh"    
      writeShWrapperFile
      writeShCmdsFile
      self.status = STATUS_QUEUED
      save!
      self.queue_job.update_status
      
      tries = 0
      if LOCATION == "Tuebingen" && RAILS_ENV == "development"
        command = "#{QUEUE_DIR}/qsub -l h_vmem=6G #{self.wrapperfile}"
	logger.debug "qsub command: #{command}"
      else
        command = "#{QUEUE_DIR}/qsub #{self.wrapperfile}"
      end
      res = `#{command}`.chomp
      self.qid = res.gsub(/Your job (\d+) .*$/, '\1')
      while (!$?.success? && tries < 3)
      	res = `#{command}`.chomp
        self.qid = res.gsub(/Your job (\d+) .*$/, '\1')
      	tries += 1
      end
      if (!$?.success? && tries == 3)
      	raise "Unable to submit job!"
      end

      save!
    end
    
    def delete
      command = "#{QUEUE_DIR}/qdel #{qid}"
      logger.debug "Worker command: #{command}"
      system(command)
    end
    
    # creates a shell wrapper file for all jobcomputations-commands that are executed on the queue, sets the status of the job
    # this must be a wrapper to be able to print to stdout and stderr files when disk file size limit is reached in the subshell.
    def writeShWrapperFile
      queue = QUEUES[:normal]
      cpus = nil
      additional = false

      if (!options.nil? || !options.empty?)
        if (options['queue']) then queue = QUEUES[options['queue'].to_sym] end
        if (options['cpus']) then cpus = options['cpus'] end
        if (options['additional']) then additional = true end
      end

      begin
        f = File.open(self.wrapperfile, 'w')
        f.write "#!/bin/sh\n"

        # SGE options
        f.write '#$' + " -N TOOLKIT_#{queue_job.action.job.jobid}\n"
        if LOCATION != "Tuebingen" && RAILS_ENV != "development"
          f.write '#$' + " -q #{queue}\n"
          if RAILS_ENV == "development"
            if queue == "express.q"
	      f.write '#$' + " -l express=TRUE\n"
	    end
	  end
	end
        f.write '#$' + " -wd #{queue_job.action.job.job_dir}\n"
        f.write '#$' + " -o #{queue_job.action.job.job_dir}\n"
        f.write '#$' + " -e #{queue_job.action.job.job_dir}\n"
#        f.write '#$' + " -j y\n";
        f.write '#$' + " -w n\n"

        if LOCATION != "Tuebingen" && RAILS_ENV != "development"
          if (queue == "toolkit_long")
            f.write '#$' + " -l long\n"
          end

          if (queue == "toolkit_immediate")
            f.write '#$' + " -l immediate\n"
          end
        end
        #f.write "-l h_vmem=2G\n"

#        if (!cpus.nil?)
#        f.write "#PBS -l nodes=1:ppn=#{cpus}\n"
#        end

        f.write "hostname > #{queue_job.action.job.job_dir}/#{id.to_s}.exec_host\n"
        if RAILS_ENV == "development"
          f.write "echo 'Starting job #{id.to_s}...' >> #{queue_job.action.job.statuslog_path}\n"
        end

        # SET STATUS OF THIS JOB TO RUNNING
        f.write File.join(TOOLKIT_ROOT,"script","qupdate.rb")+" #{id} #{STATUS_RUNNING}\n"
        if RAILS_ENV == "development"
          f.write "echo 'Status set to running...' >> #{queue_job.action.job.statuslog_path}\n"
        end

        # ALL THE SUBSHELL SCRIPT 
        if RAILS_ENV == "development"
          f.write "echo 'Before executing the commandfile...' #{self.commandfile} >> #{queue_job.action.job.statuslog_path}\n"
        end

        f.write "#{self.commandfile}\n"
        # CAPTURE EXTISTATUS OF THE 'CHILD'-SHELL SCRIPT WHICH IS SAVED IN $? INTO A VARIABLE WITH THE SAME NAME IN THIS SHELL 
        f.write "exitstatus=$?\n"
        # were there any errors?
        if (additional == true)
          if (LOCATION == "Munich")
            f.write "ssh ws01 '" + File.join(TOOLKIT_ROOT,"script","qupdate.rb")+" #{id} #{STATUS_DONE}'\n"
          else
            f.write File.join(TOOLKIT_ROOT,"script","qupdate.rb")+" #{id} #{STATUS_DONE}\n"
          end
          if RAILS_ENV == "development"
          f.write "echo 'Scheint prima zu funktionieren ... .' >> #{queue_job.action.job.statuslog_path}\n"
          end

        else
          f.write "if [ ${exitstatus} -eq 0 ] ; then\n"
          if (LOCATION == "Munich")
            f.write "ssh ws01 '" + File.join(TOOLKIT_ROOT,"script","qupdate.rb")+" #{id} #{STATUS_DONE}'\n"
          else
            f.write File.join(TOOLKIT_ROOT,"script","qupdate.rb")+" #{id} #{STATUS_DONE}\n"
          end
          if RAILS_ENV == "development"
            f.write "echo 'Job #{id.to_s} DONE!' >> #{queue_job.action.job.statuslog_path}\n"
          end
          f.write "else\n"
          if (LOCATION == "Munich")
            f.write "ssh ws01 '" + File.join(TOOLKIT_ROOT,"script","qupdate.rb")+" #{id} #{STATUS_ERROR}'\n"
          else
            f.write File.join(TOOLKIT_ROOT,"script","qupdate.rb")+" #{id} #{STATUS_ERROR}\n"
          end
          f.write "echo 'Error while executing Job!' >> #{queue_job.action.job.statuslog_path}\n"
          if RAILS_ENV == "development"
            f.write "echo 'Exit status '${exitstatus} >> #{queue_job.action.job.statuslog_path}\n"
          end
          f.write "fi\n"
        end
        f.chmod(0755)
        f.close
      rescue  Exception => e
        raise "Unable to create Wrapperfile #{self.wrapperfile} in #{self.class} id: #{id}.\n e.message\n"
      end
    end
    
    # creates a jobcomputation-commands file (sh script) + minimal errorhandling and limiting of memory and disk-file-size
    # if a program does not return 0 the subsequent commands are not executed and the script exits
    def writeShCmdsFile
      begin
        f = File.open(self.commandfile, 'w')
        f.write "#!/bin/sh\n"
        # FILE SIZE LIMIT 1Gb (1024 * 1000000), MEMORY LIMIT 6Gb (see man bash -> ulimit)
        #f.write "ulimit -f 1000000 -m 6000000\n"
        f.write "export TK_ROOT=#{ENV['TK_ROOT']}\n"
        # print the process id of this shell execution
        f.write "echo $$ >> #{queue_job.action.job.job_dir}/#{id.to_s}.exec_host\n" 
         
        f.write "exitstatus=0;\n"

        commands.each do |cmd|
          f.write"if [ ${exitstatus} -eq 0 ] ; then\n"
          f.write"#{cmd}\n"
          f.write"exitstatus=$?\n"
          f.write"if [ ${exitstatus} -ne 0 ] ; then\n"
          f.write"echo 'Error executing #{cmd} ' >> #{queue_job.action.job.statuslog_path}\n"   
          f.write"echo 'Exit status '${exitstatus} >> #{queue_job.action.job.statuslog_path}\n"
          f.write"fi\n"
          f.write"fi\n"
        end
        
        # RETURN EXITSTATUS OF THE 'CHILD'-SHELL SCRIPT
        f.write"exit ${exitstatus}\n"
        f.chmod(0755)
        f.close
      rescue  Exception => e
        raise "Unable to create Commandfile #{self.commandfile} in #{self.class} id: #{id}.\n e.message \n"
      end
    end

  end

