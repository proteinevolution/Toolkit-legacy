  class PerlJob < Job
    def method_missing(method_id, *args)
      begin
        super
      rescue
        command = File.join(File.dirname(__FILE__), "..",tool, method_id.to_s+".pl #{jobid} #{args}")
        RAILS_DEFAULT_LOGGER.debug command
        result = `perl #{command}`      
      end
    end
  end
