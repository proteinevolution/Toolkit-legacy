#!/bin/bash
source /etc/profile

${TK_ROOT?"Need to set TK_ROOT"}/script/qupdate.rb $*
