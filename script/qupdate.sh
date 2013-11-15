#!/bin/bash
#export RUBYLIB=/usr/lib/ruby/1.8:/cluster/user/marialke/lib/:/usr/lib/ruby/1.8/x86_64-linux/
#export GEM_HOME=/cluster/user/joern/gems
source /etc/profile
exitstatus=0;
if [ ${exitstatus} -eq 0 ] ; then
 /cluster/toolkit/production/script/qupdate.rb $1 $2
fi

