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

  def self.time2string(time, count)
    return "" unless count > 0
    s = time / count
    return "0s" unless s > 0

    m = s / 60
    s = s % 60
    h = m / 60
    m = m % 60
    d = h / 24
    h = h % 24

    result = ""
    result += "#{d}d" if d > 0
    result += "#{h}h" if h > 0
    result += "#{m}m" if m > 0
    result += "#{s}s" if s > 0
    result
  end

  def time2string()
    Stat.time2string(jobs_time, jobs_count)
  end

end
