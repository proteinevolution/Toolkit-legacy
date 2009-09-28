class Watchlist < ActiveRecord::Base

  MAX_SEQS=1000

  include Dbhack
  belongs_to :user, :dependent => false
  serialize :params

  attr_accessor :informat, :db_seq, :db_file, :db_name, :userid, :width, :Pmin, :maxlines

  validates_db_seq(:db_seq, :db_file, {:informat_field => :informat,
                                                    :informat => 'fas',
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 50,
                                                    :on => :create })

  validates_format_of(:width, :Pmin, :maxlines, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'})
  
  validates_presence_of(:db_name, {:on => :create})
  
  def validate_on_create
    logger.info "USERID:#{informat} #{db_name} #{userid} #{width} #{maxlines}"
    if (userid.to_i > 0)
      userdbs = Watchlist.find(:all, :conditions => [ "user_id = ?", userid.to_i ])
    end

    # check size
    dbs_size = userdbs.length+1
    if (dbs_size > MAX_SEQS)
      errors.add("db_seq","Size limit reached! You can upload maximum #{MAX_SEQS} sequences.")
    end

    # check name
    userdbs.each do |db|
      if (db_name == db.name)
        errors.add("db_seq", "Already used name: #{db_name}")
      end
    end

    if db_file.blank? && db_seq.blank?
      errors.add("db_seq","Either enter the sequence or upload the file! Can't leave both empty")
    elsif !db_file.blank? && !db_seq.blank?
      errors.add("db_seq","Either enter the sequence or upload the file! Can't fill both")
    end
  end
  
end
