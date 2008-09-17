#!/usr/bin/ruby
require File.join(File.dirname(__FILE__), '../config/environment')

Dir.foreach(TMP) do |file|
	if( file =~ /^\.*$/ ) then next end
	if( File.symlink?(file) )
		#File.delete(file)
	end
end

entries = Dir.entries(TMP)

entries.each do |file|

	if( file =~ /^\.*$/ ) then next end
	
	job1 = Job.find( :first, :conditions => "jobid='#{file}'" )
	if( file =~ /^\d*$/ )
		job2 = Job.find( :first, :conditions => "id='#{file}'" )
	end
	
	if( (job1.nil?) && (job2.nil?) )
		cmd = "rm -rfv #{File.join(TMP, file)}"
		#system(cmd);
	end	
	
	if( !job1.nil?  )
		cmd = "cd #{TMP}; mv #{job1[:jobid]} #{job1[:id]}; ln -s #{job1[:id]} #{job1[:jobid]}"
		puts cmd
		#system(cmd);
	end

end