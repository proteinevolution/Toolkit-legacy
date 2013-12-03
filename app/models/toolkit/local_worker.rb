  class LocalWorker < AbstractWorker
    set_table_name "queue_workers"
    belongs_to :queue_job, :order => "created_on"
    #has_one :queue_job, :order => "created_on"

    def execute
      commandfile = File.join(queue_job.action.job.job_dir, id.to_s+".sh")
      logger.debug "L8 #{commandfile}"
      begin
        logger.debug "L10 open File "
        f = File.open(commandfile, 'w')
        
        logger.debug "L12 write File with commands #{commands}"
        
        f.write "#!/bin/bash\n"
        # f.write("#!/bin/sh\n")
        f.write "ulimit -f 1000000\n" #-m 6000000\n"
        f.write "export TK_ROOT=#{ENV['TK_ROOT']}\n"
        f.write "source /etc/profile\n"
        
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
            f.write "echo 'Job orig #{id.to_s} DONE!' >> #{queue_job.action.job.statuslog_path}\n"
            f.write "ssh ws04 '" + File.join(TOOLKIT_ROOT,"script","qupdate.sh")+" #{id} #{STATUS_DONE}'\n"
        logger.debug "L14 chmod File "
        f.chmod(0755)
        logger.debug "L16 close File "
        f.close
      rescue
        raise "Unable to create Commandfile #{commandfile}in #{self.class} id: #{id}."
      end
      self.commandfile = commandfile
      save!
      job_call = "cd #{queue_job.action.job.job_dir};/bin/bash #{commandfile}"
      # job_call = "cd #{queue_job.action.job.job_dir};/bin/sh #{commandfile}"
      logger.debug "L26 CMD :#{job_call}"
      output = `#{job_call}`   
      logger.debug "L28 #{output} "
   end


#		# TODO: Save PID of command
#      p = fork do
#        if system(commandfile) 
#          self.status = STATUS_DONE
#        else
#          self.status = STATUS_ERROR
#        end
#        save!
#        queue_job.update_status
#      end
#      if options[:sync] then Process.wait else Process.detach(p) end
#    end
    
    def delete
      # TODO: Kill job by PID
    end
    
  end

