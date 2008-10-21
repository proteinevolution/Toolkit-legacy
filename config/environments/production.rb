# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger        = SyslogLogger.new


# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
#config.action_mailer.raise_delivery_errors = false

config.log_level = :error

if (LOCATION == "Munich")

  ActionMailer::Base.smtp_settings = {
    :address  => "pluto.lmb.uni-muenchen.de",
    :port  => 25,
    :domain => "lmb.uni-muenchen.de"
  } 

  TOOLKIT_MAIL = "toolkit@lmb.uni-muenchen.de"

else
  
  ActionMailer::Base.smtp_settings = {
#    :address => "mailhost.tuebingen.mpg.de",
#    :address => "wye.eb.tuebingen.mpg.de",
    :address => "172.18.1.254",
    :port => 25,
    :domain => "tuebingen.mpg.de"
  }

  TOOLKIT_MAIL = "mpi-toolkit@tuebingen.mpg.de"

end

ActionMailer::Base.raise_delivery_errors = true

TOOLKIT_ROOT = '/cluster/toolkit/production'

BIOPROGS = TOOLKIT_ROOT+'/bioprogs'
TMP = TOOLKIT_ROOT+'/tmp/production'
TMP_REL = '/tmp/production'
DATABASES = TOOLKIT_ROOT+'/databases'
CONFIG = TOOLKIT_ROOT+'/config'
LIB = TOOLKIT_ROOT+'/lib'
IMAGES = TOOLKIT_ROOT+'/public/images'

if (LOCATION == "Munich")

  QUEUE_MODE = 'sge'
  QUEUE_DIR = '. /cluster/opt/sge/default/common/settings.sh; /cluster/opt/sge/bin/lx24-amd64'
  QUEUE_SETTINGS = '. /cluster/opt/sge/default/common/settings.sh'

else

  QUEUE_MODE = 'sge'
  QUEUE_DIR = '. /usr/local/sge/default/common/settings.sh; /usr/local/sge/bin/lx26-amd64'
  QUEUE_SETTINGS = '. /usr/local/sge/default/common/settings.sh'

end

# In ein yml-fiel exportieren?

STATUS_INIT = 'i'
STATUS_RUNNING = 'r'
STATUS_DONE = 'd'
STATUS_ERROR = 'e'
STATUS_QUEUED = 'q'

if (LOCATION == "Munich")
  DOC_ROOTHOST = 'toolkit.lmb.uni-muenchen.de'
else
#  DOC_ROOTHOST = 'wye.eb.tuebingen.mpg.de'
  DOC_ROOTHOST = 'toolkit.tuebingen.mpg.de'
end

DOC_ROOTURL = 'http://' + DOC_ROOTHOST
#JAVA_EXEC = '/opt/j2sdk/bin/java'
JAVA_EXEC = 'java'
#JAVA_1_5_EXEC = '/opt/jdk/bin/java'
JAVA_1_5_EXEC = 'java'

DATA = '/cluster/data'

HHCLUSTER_DB = "scop25_1.69"
HHCLUSTER_DB_PATH = DATABASES + "/hhcluster/" + HHCLUSTER_DB

if( !ENV['USER'].nil? && ENV['USER']=="toolkit" )
	system("chmod 666 #{TOOLKIT_ROOT}/log/*.log")
end
