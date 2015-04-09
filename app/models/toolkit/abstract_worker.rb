require "protected_sql.rb"

  class AbstractWorker < ActiveRecord::Base
    set_table_name "queue_workers"
    belongs_to :queue_job

    include ProtectedSql

    def execute
      # Implement this method in derived classes
    end

    def stop
      # Implement this method in derived classes    
    end

    def before_destroy
      stop unless status == STATUS_DONE || status == STATUS_INIT || status == STATUS_ERROR
    end

    def logger
      # max log file size: 100MB. Keep 6 of them.
      name = self.class.name.to_us
      name.gsub!(/toolkit\//, '')
      @logger ||= Logger.new("#{RAILS_ROOT}/log/#{name}.log", 6, 104857600)
    end

    def getTime
      exec_time
    end

    def getToolShortcut
      if queue_job
        queue_job.getToolShortcut
      else
        nil
      end
    end

  end

