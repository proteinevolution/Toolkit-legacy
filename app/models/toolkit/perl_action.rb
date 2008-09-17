  class PerlAction < Action
    def run
      command = File.join(File.dirname(__FILE__), "..", job.tool,  self.class.to_s.to_us+'.pl') + " #{id}"
      logger.debug "###: #{command}"
      p = fork { system(command)}

      if do_fork?
      	Process.detach(p) 
      else 
      	Process.wait 
      	while (job.status != STATUS_DONE) do
      		reload
      		sleep(1)
      	end
      end

    end
  end
