#!/bin/bash
source /etc/profile

# for compatibility of old job scripts (may be removed from June 2014)
: ${TK_ROOT:=/cluster/toolkit/production}

${TK_ROOT?"Need to set TK_ROOT"}/script/qupdate.rb $1 $2
