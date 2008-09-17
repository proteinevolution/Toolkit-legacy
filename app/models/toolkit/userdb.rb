class Userdb < ActiveRecord::Base
  belongs_to :user, :dependent => false
  
  include Dbhack
  
  @@tmpfile = ""
  
  def setTempfile(val)
    @@tmpfile = val
  end
  
  def tempfile
    @@tmpfile
  end
  
  attr_accessor :dbname, :dbfile, :userid

  validates_presence_of(:dbname, {:on => :create})
  
  def validate_on_create
 
    if (userid.to_i > 0)
      userdbs = Userdb.find(:all, :conditions => [ "user_id = ?", userid.to_i ])
      max_size = (1024*1024*100)
    else
      userdbs = Userdb.find(:all, :conditions => [ "user_id = ? AND sessionid = ?", 0, sessionid ])
      max_size = (1024*1024*10)
    end

    # check size
    dbs_size = 0
    userdbs.each do |db|
      dbs_size += db.size
    end
    if ((dbfile.size + dbs_size) > max_size)
      errors.add("dbfile", "File is to large! Size limit reached!")
    end          

    # check name
    userdbs.each do |db|
      if (dbname == db.name)
        errors.add("dbname", "Name is already used!")
      end
    end

  end
  
  validates_userdb(:dbfile, {:max_seqs => 1000000, :on => :create })
  
end
