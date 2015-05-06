# Mixin ProtectedSql
# Module ProtectedSql is a mixin, that
# a) defines protected_<xy> methods, which distinguish themselves from
#    method <xy> by handling exception ActiveRecord::StatementInvalid.
#    Handling this exception is essential with the unstable MySQL database
#    driver of ruby 1.8.
#    Currently, <xy> may be: find
# b) defines local methods save and save! which also do this checking.
#
# Prerequisite: The class which is extended by this mixin (the "extended class")
#               has to understand calls of <xy> (see above), logger, reload,
#               save and save!, the latter two beeing overloaded by this mixin.
#
#               logger in most cases should be directly defined in the extended
#               class. The other methods can be inherited from class
#               ActiveRecord, which was in mind when this mixin was developed.
#               Calls of inherited save and save! methods are checked for
#               ActiveRecord::StatementInvalid exceptions. If the message
#               belonging to that exception indicates a database insert,
#               the overloading methods try to reload the object from
#               the database to check if the insert was successful despite
#               of the exception. This is assumed, if reload didn't throw
#               an exception.
module ProtectedSql

  # Assumption: insert successful despite of StatementInvalid exception
  # only happens if error message contains string "INSERT INTO "
  INSERT_MARKER = "INSERT INTO "

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    def protected_find(*args)
      begin
        find(*args)
      rescue ActiveRecord::StatementInvalid => e
        logger.debug("L39 protected_sql.rb #{self.class.name}.find: Got statement invalid #{e.message} ... trying again")
        ActiveRecord::Base.verify_active_connections!
        find(*args)
      end
    end
  end

  # protected classes' save methods always are overloaded here,
  # because saving is an essential operation.

  # save and save! don't call each other. save! i.e. is called in Job.run.

  def save!
    begin
      super
    rescue ActiveRecord::StatementInvalid => e
      if (successfulInsert?(e.message))
        # object already reloaded by successfulInsert?
        self
      else
        logger.debug("L58 protected_sql.rb #{self.class.name}.save!: Got statement invalid #{e.message} ... trying again")
        ActiveRecord::Base.verify_active_connections!
        super
      end
    end
  end

  # save method also overloaded, because it also throws the
  # ActiveRecord::StatementInvalid exception
  def save
    begin
      super
    rescue ActiveRecord::StatementInvalid => e
      if (successfulInsert?(e.message))
        # object already reloaded by successfulInsert?
        self
      else
        logger.debug("L76 protected_sql.rb #{self.class.name}.save: Got statement invalid #{e.message} ... trying again")
        ActiveRecord::Base.verify_active_connections!
        super
      end
    end
  end

  private

  def successfulInsert?(message)
    if message.include? INSERT_MARKER
      begin
        reload
        # reload successful
        logger.debug("L90 protected_sql.rb #{self.class.name}.successfulInsert? is true despite getting statement invalid #{message} ... not trying again!")
        return true
      rescue Exception => e
        # remove logging, after specializing Exception
        logger.debug("L94 protected_sql.rb #{self.class.name}.successfulInsert? Exception should indicate that object wasn't inserted into database: #{e.message}")
      end
    end
    false
  end

end
