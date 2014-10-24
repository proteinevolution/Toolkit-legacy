class Stat < ActiveRecord::Base
  def addJob(jobTime)
    Stat.transaction do
      self.jobs_time += jobTime
      self.jobs_count += 1
      save!
    end
  end

  def save!
    begin
      super
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L14 stat.rb Stat.save!: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      super
    end
  end

end
