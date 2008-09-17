#!/usr/bin/ruby
require File.join(File.dirname(__FILE__), '../config/environment')
if( ARGV.length<2 )
	puts "\nUsage: ./qupdate.rb jobid status"
	puts "\n"
	puts "Possible values for status are"
	puts "   i  (initialized)"
	puts "   r  (running)"
	puts "   d  (done)"
	puts "   e  (error)"
	puts "   q  (queued)"
	puts "\n"
	exit(1)
end

jobid  = ARGV[0]
status = ARGV[1]

if( !(status=="i" || status=="d" || status=="r" || status=="e" || status=="q") )
	puts "\nInvalid value for status found!"
	puts "Possible values for status are"
	puts "   i  (initialized)"
	puts "   r  (running)"
	puts "   d  (done)"
	puts "   e  (error)"
	puts "   q  (queued)"
	puts "\n"
	exit(1)
end

w = AbstractWorker.find(jobid)
w.status = status
w.save!
w.queue_job.update_status

exit(0)