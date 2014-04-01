class Dbstat < ActiveRecord::Base
   def Dbstat.normalizeDBName(dbname)
     # remove path and date, i.e.
     # /ebio/abt1/kfaidt/toolkit/databases/hhpred/new_dbs/pdb70_9Jan14 to
     # pdb70
     basename = File.basename(dbname); # keep extension, if exists
     
     versionNumberPattern = '_v?(\d+\.)+\d+\w?'
     datePattern = '_\d?\d\w\w\w\d\d'
     endPattern = '\z'

     # database names containing both version number and date are
     # considered distinguished special versions and not normalized.
     if ((basename=~Regexp.new(versionNumberPattern+datePattern+endPattern)) \
         or (basename=~Regexp.new(datePattern+versionNumberPattern+endPattern)))
       return basename
     end

     # remove date
     basename.sub!(Regexp.new(datePattern + endPattern), '')

     # remove version number
     basename.sub!(Regexp.new(versionNumberPattern + endPattern), '')

     basename
   end

   def Dbstat.checkDatabasesForUsage(params)
     # check if params-Hash contains databases for usage recording.
     # plausibility: The total of databases given by params does not
     #               contain nr70 as well as nr90 and contains less
     #               then 6 databases.
     #               Only certain hash keys are considered to supply
     #               an array of databases.
     # params: hash, at least one entry of which has to supply the database
     #         names to check.
     # returns a plausible array of database names to record or nil, if no
     #         database is subject to usage recording (i.e. if params
     #         does not match the plausibility conditions).
     
     # the kind of databases to consider
     db_keys = [ "std_dbs", "hhpred_dbs", "hhblits_dbs" ]

     # if these databases are used at once, the usage is considered nonsense
     # and not recorded
     nonsense_combination = [ "nr70", "nr90" ]

     # if more than maxdb_count databases are used, the usage is considered
     # as bulk database usage and not recorded
     maxdb_count = 5

     nonsense = (not nonsense_combination.empty?)
     found_dbnames = Array.new
     db_keys.each do |db_key|
       db_list = params[db_key]
       if (db_list)
         db_list.each do |db|
           if (found_dbnames.length >= maxdb_count)
             return nil
           end
           new_dbname = Dbstat.normalizeDBName(db)
           unless found_dbnames.include?(new_dbname)
             found_dbnames.push(new_dbname)
             if (nonsense and (not nonsense_combination.include?(new_dbname)))
               nonsense = false
             end
           end
         end
       end
     end
     if (nonsense)
       nonsense_combination.each do |ndb|
         unless found_dbnames.include?(ndb)
           nonsense = false
           break
         end
       end
       if (nonsense)
         return nil
       end
     end

     if found_dbnames.empty?
       return nil
     end

     found_dbnames
   end

end