# This file specifies environment constants that are specific for the local server.
# Therefore it is not version-controlled and has to be adapted by each developer.
# Adapt this file to your needs and copy it to local_environment.rb.

#global settings
ENV['RAILS_ENV'] = 'development'
LOCATION         = "Munich"
TOOLKIT_ROOT     = '/cluster/user/USER/toolkit'
DOC_ROOTHOST     = 'dev.lmb.uni-muenchen.de:4000'

#mail settings
TOOLKIT_MAIL = "toolkit@lmb.uni-muenchen.de"
MAIL_SERVER  = "pluto.lmb.uni-muenchen.de"
MAIL_PORT    = 25
MAIL_DOMAIN  = "lmb.uni-muenchen.de"

#queue settings
QUEUE_MODE = 'sge'
QUEUE_DIR = '. /cluster/opt/sge/default/common/settings.sh; /cluster/opt/sge/bin/lx24-amd64'
QUEUE_SETTINGS = '. /cluster/opt/sge/default/common/settings.sh'
QUEUES = {
  :normal => 'toolkit_normal',
  :long =>'toolkit_long',
  :immediate =>'toolkit_immediate'
}

#java
JAVA_EXEC = 'java'

#internal IPs
INTERNAL_IPS = [ "141.84.46.86/255.255.255.255",
                 "10.153.0.0/255.255.0.0",
                 "141.84.0.0/255.255.0.0" ]
