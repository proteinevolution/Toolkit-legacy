module ProtectedSql

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    def protected_find(*args)
      begin
        find(*args)
      rescue ActiveRecord::StatementInvalid => e
        logger.debug("L6 ProtectedSql.find: Got statement invalid #{e.message} ... trying again")
        ActiveRecord::Base.verify_active_connections!
        find(*args)
      end
    end
  end
end
