# Be sure to restart your web server when you modify this file.

#include local environment settings
local_environment_path = File.join(File.dirname(__FILE__), 'local_environment.rb')
eval(IO.read(local_environment_path), binding, local_environment_path)

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#setup memcache part 2
require 'memcache'

memcache_options = {
   :compression => false,
   :debug => false,
   :namespace => "app-#{RAILS_ENV}",
   :readonly => false,
   :urlencode => false
}
memcache_servers = [ '127.0.0.1:11211' ]

#global settings
TOOLKIT_RELEASE = '2.7.9'
DOC_ROOTURL     = 'http://' + DOC_ROOTHOST
BIOPROGS        = TOOLKIT_ROOT+'/bioprogs'
TMP             = TOOLKIT_ROOT+'/tmp/'+RAILS_ENV
TMP_REL         = '/tmp/'+RAILS_ENV
DATABASES       = TOOLKIT_ROOT+'/databases'
CONFIG          = TOOLKIT_ROOT+'/config'
LIB             = TOOLKIT_ROOT+'/lib'
IMAGES          = TOOLKIT_ROOT+'/public/images'

#queue status identifiers
STATUS_INIT    = 'i'
STATUS_RUNNING = 'r'
STATUS_DONE    = 'd'
STATUS_ERROR   = 'e'
STATUS_QUEUED  = 'q'

#FIXME: should be removed!
JAVA_1_5_EXEC = JAVA_EXEC

#hhcluster settings
HHCLUSTER_DB      = "scop25_1.69"
HHCLUSTER_DB_PATH = DATABASES + "/hhcluster/" + HHCLUSTER_DB

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  Dir.foreach("#{RAILS_ROOT}/app/models") do |subdir|
    dir = File.join("#{RAILS_ROOT}/app/models", subdir)
    if File.directory?(dir) && dir.index('.').nil?
      config.load_paths += %W( #{dir} )
    end
  end

  config.load_paths += %W( #{RAILS_ROOT}/lib/modules )

  ENV['TK_ROOT'] = (Pathname.new(RAILS_ROOT)).realpath

  #config.load_paths += %W( #{RAILS_ROOT}/app/models/prot_blast )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store
  config.action_controller.session_store = :mem_cache_store
  config.action_controller.fragment_cache_store = :mem_cache_store, memcache_servers, memcache_options

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# This will force Rails to reconnect to the database before MySQL can get a chance to timeout.
ActiveRecord::Base.verification_timeout = 14400

ActiveRecord::Base.allow_concurrency = true

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

#FIXME: really needed?
class String
  alias_method  :to_cc,  :camelize
  alias_method  :to_us,  :underscore
end

require 'ipaddr'
require 'toolkit/init'
require 'environments/localization_environment'
require 'localization'
Localization::load_localized_strings
require 'environments/user_environment'

# avoid 'application error(rails)' message
require File.join(File.dirname(__FILE__), '..', 'lib', 'modules', 'rescue')

#memcache
cache_params = *([memcache_servers, memcache_options].flatten)
CACHE = MemCache.new *cache_params
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.merge!({ 'cache' => CACHE })

#specify internal IPs
INT_IPS = INTERNAL_IPS.map {|ip| IPAddr.new(ip) }

#mail settings
ActionMailer::Base.smtp_settings = {
  :address => MAIL_SERVER,
  :port    => MAIL_PORT,
  :domain  => MAIL_DOMAIN
}
