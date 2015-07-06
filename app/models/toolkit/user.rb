require 'digest/sha1'
require "protected_sql.rb"

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  include ProtectedSql

  has_many :jobs, :dependent => :destroy, :order =>"created_on"
  has_many :userdbs, :dependent => :destroy

  attr_accessor :new_password

  def logger
    # max log file size: 10MB. Keep 6 of them.
    @logger ||= Logger.new("#{RAILS_ROOT}/log/#{self.class.name.to_us}.log", 6, 10485760)
  end
  
  def initialize(attributes = nil)
    begin
      super
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L22 User.initialize: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      super
    end
    @new_password = false
  end

  def self.authenticate(login, pass)
    begin
      u = protected_find(:first, :conditions => ["login = ? AND verified = 1 AND deleted = 0", login])    
      return protected_find(:first, :conditions => ["login = ? AND salted_password = ? AND verified = 1", login, salted_password(u.salt, hashed(pass))])
    rescue
      return nil
    end
  end

  def self.authenticate_by_token(id, token)
    # Allow logins for deleted accounts, but only via this method (and
    # not the regular authenticate call)
    u = protected_find(:first, :conditions => ["id = ? AND security_token = ?", id, token])
    return nil if u.nil? or u.token_expired?
    return nil if false == u.update_expiry
    u
  end

  def token_expired?
    self.security_token and self.token_expiry and (Time.now > self.token_expiry)
  end

  def update_expiry
    write_attribute('token_expiry', [self.token_expiry, Time.at(Time.now.to_i + 600 * 1000)].min)
    # authenticated_by_token does not exist in the database and isn't used.
    # write_attribute('authenticated_by_token', true)
    write_attribute("verified", 1)
    protected_update_without_callbacks
  end

  def generate_security_token(hours = nil)
    if not hours.nil? or self.security_token.nil? or self.token_expiry.nil? or 
        (Time.now.to_i + token_lifetime / 2) >= self.token_expiry.to_i
      return new_security_token(hours)
    else
      return self.security_token
    end
  end

  def set_delete_after
    hours = UserSystem::CONFIG[:delayed_delete_days] * 24
    write_attribute('deleted', 1)
    write_attribute('delete_after', Time.at(Time.now.to_i + hours * 60 * 60))

    # Generate and return a token here, so that it expires at
    # the same time that the account deletion takes effect.
    return generate_security_token(hours)
  end

  def change_password(pass, confirm = nil)
    self.password = pass
    self.password_confirmation = confirm.nil? ? pass : confirm
    @new_password = true
  end
    
  protected

  attr_accessor :password, :password_confirmation

  def validate_password?
    @new_password
  end

  def self.hashed(str)
    return Digest::SHA1.hexdigest("change-me--#{str}--")[0..39]
  end

  after_save '@new_password = false'
  after_validation :crypt_password
  def crypt_password
    if @new_password
      write_attribute("salt", self.class.hashed("salt-#{Time.now}"))
      write_attribute("salted_password", self.class.salted_password(salt, self.class.hashed(@password)))
    end
  end

  def new_security_token(hours = nil)
    write_attribute('security_token', self.class.hashed(self.salted_password + Time.now.to_i.to_s + rand.to_s))
    write_attribute('token_expiry', Time.at(Time.now.to_i + token_lifetime(hours)))
    protected_update_without_callbacks
    return self.security_token
  end

  def token_lifetime(hours = nil)
    if hours.nil?
      UserSystem::CONFIG[:security_token_life_hours] * 60 * 60
    else
      hours * 60 * 60
    end
  end

  def self.salted_password(salt, hashed_password)
    hashed(salt + hashed_password)
  end

  def protected_update_without_callbacks
    begin
      update_without_callbacks
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L128 User.protected_update_without_callbacks: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      update_without_callbacks
    end
  end

  def self.protected_find_by_id(id)
    begin
      User.find_by_id(id)
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L138 User.protected_find_by_id: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      User.find_by_id(id)
    end
  end

  def self.protected_find_by_login(login)
    begin
      User.find_by_login(login)
    rescue ActiveRecord::StatementInvalid => e
      logger.debug("L148 User.protected_find_by_login: Got statement invalid #{e.message} ... trying again")
      ActiveRecord::Base.verify_active_connections!
      User.find_by_login(login)
    end
  end

  validates_presence_of :login, :on => :create
  validates_length_of :login, :within => 3..80, :on => :create
  validates_uniqueness_of :login, :on => :create

  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  validates_length_of :password, { :minimum => 5, :if => :validate_password? }
  validates_length_of :password, { :maximum => 40, :if => :validate_password? }
  
  validates_presence_of :lastname, :on => :create
end
