#!/usr/bin/ruby
require File.join(File.dirname(__FILE__), '../config/environment')

puts "ENVIRONMENT: #{RAILS_ENV}"

def print_related_table_entries(job, verbose)
	print "\nRelated table entries:\n\n"	
	job.actions.each do |action|
		puts "   #{action[:id]} #{action[:type]} status=#{action[:status]} active=#{action[:active]}"	
		action.queue_jobs.each do |qjob|
			puts "      #{qjob[:id]} status=#{qjob[:status]} final=#{qjob[:final]} on_done=#{qjob[:on_done]}"			
			qjob.workers.each do |w|				
				puts "         #{w[:id]} #{w[:type]} status=#{w[:status]} #{w[:pbsid]}"
				cmds = w[:commands]
				i=0
				cmds.each do |cmd|
					if(verbose>1)
						cmd = cmd[0..50]+"..."
					end
					puts "           #{i} #{cmd}"
					i+=1
				end
			end
		end
	end
end


def display_jobs(status, verbose)
	jobs = Job.find( :all, :conditions => "status='#{status}'" )
	if( jobs.nil? )
		puts "There are no running jobs!"
		return
	end
	
	print "\n"	
		print( "+" + ("-"*118) + "+" +"\n" )
	printf( "| %-20s |", "Type" )
	printf( " %-20s |", "JobID" )
	printf( " %-7s |" , "ID" )
	printf( " %-6s |" , "Status" )
	printf( " %-8s |", "ParentID" ) 
	printf( " %-6s |", "UserID" ) 
	printf( " %-17s |", "Created on" ) 
	printf( " %-11s |\n", "Status for" ) 
	print( "+" + ("-"*118) + "+" +"\n" )
	jobs.each do |job|	
		printf( "| %-20s |", job[:type] )
		printf( " %-20s |", job[:jobid] )
		printf( " %-7s |" , job[:id] )
		printf( " %-6s |" , job[:status] )
		printf( " %-8s |", job[:parent_id] ) 	
		printf( " %-6s |", job[:user_id] ) 
		printf( " %-17s |", job[:created_on].strftime("%d.%m.%y %H:%M:%S") ) 
		
		printf( " %10.2fh |\n", (Time.now-job[:created_on])/3600.0 ) 
		print( "+" + ("-"*118) + "+" +"\n" )	
		if(verbose>0)  
			print_related_table_entries(job, verbose)
			print( "\n+" + ("-"*84) + "+" +"\n" )
		end
	end
	puts "\n\nThere are #{jobs.size} jobs in the '#{RAILS_ENV}' environment with status='#{status}' !"
end



def jobexpl(jobid, verbose)	
	job = Job.find( :first, :conditions => "jobid='#{jobid}'" )
	if( job.nil? )
			puts "There is no job with jobid:#{jobid} in the '#{RAILS_ENV}' environment!"
		return
	end	
	puts job.inspect	
	print "\n"
	print( "+" + ("-"*104) + "+" +"\n" )
	printf( "| %-20s |", "Type" )
	printf( " %-20s |", "JobID" )
	printf( " %-7s |" , "ID" )
	printf( " %-6s |" , "Status" )
	printf( " %-8s |", "ParentID" ) 
	printf( " %-6s |", "UserID" ) 
	printf( " %-17s |\n", "Created on" ) 
	print( "+" + ("-"*104) + "+" +"\n" )
	printf( "| %-20s |", job[:type] )
	printf( " %-20s |", job[:jobid] )
	printf( " %-7s |" , job[:id] )
	printf( " %-6s |" , job[:status] )
	printf( " %-8s |", job[:parent_id] ) 	
	printf( " %-6s |", job[:user_id] ) 
	printf( " %-17s |\n", job[:created_on].strftime("%d.%m.%y %H:%M:%S") ) 
	print( "+" + ("-"*104) + "+" +"\n" )	
	print_related_table_entries(job, verbose)
end


def display_jobs_of_type(type, verbose)                                                                                                                                  
  jobs = Job.find( :all, :conditions => "type='#{type}'" )                                                                                          
  if( jobs.length==0 ) 
    puts "There is no job with type: '#{type}' in the '#{RAILS_ENV}' environment!"                                                        
    return                                                                                                                                       
  end                                                                                                                                                  
  print( "\n+" + ("-"*104) + "+" +"\n" )                                                                                                                   
  printf( "| %-20s |", "Type" )                                                                                                                            
  printf( " %-20s |", "JobID" )                                                                                                                            
  printf( " %-7s |" , "ID" )                                                                                                                               
  printf( " %-6s |" , "Status" )                                                                                                                           
  printf( " %-8s |", "ParentID" )                                                                                                                          
  printf( " %-6s |", "UserID" )                                                                                                                            
  printf( " %-17s |\n", "Created on" )  
  print( "+" + ("-"*104) + "+" +"\n" )                                                                                                                 
  jobs.each do |job|                                                                                                                                     
    printf( "| %-20s |", job[:type] )                                                                                                                    
    printf( " %-20s |", job[:jobid] )                                                                                                                    
    printf( " %-7s |" , job[:id] )                                                                                                                       
    printf( " %-6s |" , job[:status] )                                                                                                                   
    printf( " %-8s |", job[:parent_id] )                                                                                                                 
    printf( " %-6s |", job[:user_id] )                                                                                                                   
    printf( " %-17s |\n", job[:created_on].strftime("%d.%m.%y %H:%M:%S") )                                                                               
    print( "+" + ("-"*104) + "+" +"\n" )                                                                                                                 
  end
end         





####
#    MAIN
####

if( ARGV.length<1 )
	puts "\nUsage: ./job_explorer.rb jobid"
	puts "    -v=[0..9]  0:default\n\n"
	puts "    -r  show running jobs\n\n"
        puts "    -t 'job-type' (e.g. HhsenserJob, HhpredJob, PsiblastJob)\n"
	exit(1)
end

verbose = 0
initialized = false
running = false
error   = false
queued  = false
jobid   = nil
type    = nil

0.upto(ARGV.length-1) do |i|
  
  arg = ARGV[i]
  if( arg !~ /-\S/ )
    jobid = arg
  elsif( arg =~ /-v=(\d)/ )
    verbose = $1.to_i
  elsif( arg == "-r" )
    running = true
  elsif( arg == "-e" )
    error = true
  elsif( arg == "-q" )
    queued = true
  elsif( arg == "-i" )
    initialized = true
  elsif( arg == "-t" )
    i = i+1
    if( i==ARGV.length )
      puts "No argument given for '-t'\n"
      exit(1)
    end 
    type = ARGV[i]
  end
end

jobexpl(jobid, verbose)     if !jobid.nil?
display_jobs("r", verbose)  if running
display_jobs("e", verbose)  if error
display_jobs("q", verbose)  if queued
display_jobs("i", verbose)  if initialized
display_jobs_of_type( type, verbose) if (!type.nil?)

exit(0)

