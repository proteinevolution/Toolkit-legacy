  class LocalWorker < AbstractWorker
    set_table_name "queue_workers"
    belongs_to :queue_job, :order => "created_on"

    def execute
      commandfile = File.join(queue_job.action.job.job_dir, id.to_s+".sh")
      begin
        f = File.open(commandfile, 'w')
        f.write("#!/bin/sh\n"+commands)
        f.chmod(0755)
        f.close
      rescue
        raise "Unable to create Commandfile #{commandfile}in #{self.class} id: #{id}."
      end
      self.commandfile = commandfile
      save!

		# TODO: Save PID of command
      p = fork do
        if system(commandfile) 
          self.status = STATUS_DONE
        else
          self.status = STATUS_ERROR
        end
        save!
        queue_job.update_status
      end
      if options[:sync] then Process.wait else Process.detach(p) end
    end
    
    def delete
      # TODO: Kill job by PID
    end
    
  end

