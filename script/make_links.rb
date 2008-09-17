#!/usr/bin/ruby
require File.join(File.dirname(__FILE__), '../config/environment')

STIME = Time.local(2006, 10, 22, 0, 0, 0, 0)

Dir.foreach(TMP) do |file|
	if( file =~ /^\.*$/ ) then next end
	if( File.symlink?(file) )
		#File.delete(file)
	end
end

Dir.foreach(TMP) do |file|
	if( file =~ /^\.*$/ ) then next end
	job1 = Job.find( :first, :conditions => "jobid='#{file}'" )
	if( file =~ /^\d*$/ )
		job2 = Job.find( :first, :conditions => "id='#{file}'" )
	end
	if( (job1.nil?) && (job2.nil?) )
		cmd = "rm -rfv #{File.join(TMP, file)}"
		system(cmd);
	end	
	
	if( !job1.nil?  )
		puts "FILE:#{file} JOBDIR:#{job1.jobdir}"
	elsif( !job2.nil? )
		if( job2[:created_on] < STIME )
			puts "FILE:#{file} was created on #{job2[:created_on]}!"
			cmd = "cd #{TMP}; ln -s #{job2[:id]} #{job2[:jobid]}"
			puts cmd
			system(cmd);
		end
	end

end

#jobs = Job.find( :all )
#jobs.each do |job|
	#jobdir_old = job.jobid
	#jobdir_new = job.id
	#if( File.exists?(jobdir_old) )
#		cmd = "ln -s #{jobdir_old} #{jobdir_new}"#
	#	puts cmd		
#		system(cmd)
#	end
#end
