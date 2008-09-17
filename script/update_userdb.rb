#!/usr/bin/ruby
require File.join(File.dirname(__FILE__), '../config/environment')

db = Userdb.find(ARGV[0])
db.formatted = true
db.save!

