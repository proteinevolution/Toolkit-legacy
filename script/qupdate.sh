#!/bin/bash
#source /etc/profile

ruby ${TK_ROOT?"Need to set TK_ROOT"}/script/qupdate.rb $*
