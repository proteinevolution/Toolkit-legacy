  class AbstractWorker < ActiveRecord::Base
    set_table_name "queue_workers"
    belongs_to :queue_job

    def execute
      # Implement this method in derived classes
    end

    def delete
      # Implement this method in derived classes    
    end

    def logger
      # max log file size: 100MB. Keep 6 of them.
      name = self.class.name.to_us
      name.gsub!(/toolkit\//, '')
      @logger ||= Logger.new("#{RAILS_ROOT}/log/#{name}.log", 6, 104857600)
    end

  end

