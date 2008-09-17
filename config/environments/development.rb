# Settings specified here will take precedence over those in config/environment.rb

# Set Location (Munich or Tuebingen)
LOCATION = "Tuebingen"

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes     = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils        = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.log_level = :debug

if (LOCATION == "Munich")

  ActionMailer::Base.smtp_settings = {
    :address  => "pluto.lmb.uni-muenchen.de",
    :port  => 25,
    :domain => "lmb.uni-muenchen.de"
  } 

  TOOLKIT_MAIL = "toolkit@lmb.uni-muenchen.de"

else
  
  ActionMailer::Base.smtp_settings = {
    :address => "mailhost.tuebingen.mpg.de",
    :port => 25
  }

  TOOLKIT_MAIL = "mpi-toolkit@tuebingen.mpg.de"

end

ActionMailer::Base.raise_delivery_errors = true

TOOLKIT_ROOT = '/cluster/toolkit/development'

BIOPROGS = TOOLKIT_ROOT+'/bioprogs'
TMP = TOOLKIT_ROOT+'/tmp/development'
TMP_REL = '/tmp/development'
DATABASES = TOOLKIT_ROOT+'/databases'
CONFIG = TOOLKIT_ROOT+'/config'
LIB = TOOLKIT_ROOT+'/lib'
IMAGES = TOOLKIT_ROOT+'/public/images'

if (LOCATION == "Munich")

  QUEUE_MODE = 'sge'
  QUEUE_DIR = '. /cluster/opt/sge/default/common/settings.sh; /cluster/opt/sge/bin/lx24-amd64'

else

  QUEUE_MODE = 'sge'
  QUEUE_DIR = '. /usr/local/sge/default/common/settings.sh; /usr/local/sge/bin/lx26-amd64'

end

# In ein yml-fiel exportieren?

STATUS_INIT = 'i'
STATUS_RUNNING = 'r'
STATUS_DONE = 'd'
STATUS_ERROR = 'e'
STATUS_QUEUED = 'q'

if (LOCATION == "Munich")
  DOC_ROOTHOST = 'toolkit.lmb.uni-muenchen.de:4000'
  #DOC_ROOTHOST = 'toolkit.lmb.uni-muenchen.de'
else
  DOC_ROOTHOST = 'wye.eb.tuebingen.mpg.de'
end

DOC_ROOTURL = 'http://' + DOC_ROOTHOST
#JAVA_EXEC = '/opt/j2sdk/bin/java'
JAVA_EXEC = 'java'
#JAVA_1_5_EXEC = '/opt/jdk/bin/java'
JAVA_1_5_EXEC = 'java'
DATA = '/cluster/data'
PBS = '/usr/local/PBS/bin'

HHCLUSTER_DB = "scop25_1.69"
HHCLUSTER_DB_PATH = DATABASES + "/hhcluster/" + HHCLUSTER_DB

if( !ENV['USER'].nil? && ENV['USER']=="toolkit" )
	system("chmod 666 #{TOOLKIT_ROOT}/log/*.log")
end	

