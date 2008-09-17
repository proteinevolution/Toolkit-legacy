#!/usr/bin/ruby
require File.join(File.dirname(__FILE__), '../config/environment')

jobs = Job.find( :all )
Dir.chdir(TMP)
jobs.each do |job|
	jobdir_old = job.jobid
	jobdir_new = job.id
	if( File.exists?(jobdir_old) )
		cmd = "ln -s #{jobdir_old} #{jobdir_new}"
		puts cmd		
		system(cmd)
	end
end
