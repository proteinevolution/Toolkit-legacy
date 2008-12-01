#!/usr/bin/ruby

# chris 25.20.2006
# this script cleans 
# - the toolkit db (development or production depending on the environment)
# - tmp directory (development or production depending on the environment)
# - userdbs of not logged in users (development or production depending on the environment)

# updated 1.12.2008 by Michael
# - do not delete PDBalert jobs

require File.join(File.dirname(__FILE__), '../config/environment')

DAY       = 60*60*24
WEEK      = 7*DAY
TWOWEEKS  = 14*DAY
TWOMONTHS = 60*DAY

NOW   = Time.now

USERDBDIR = File.join(DATABASES, 'userdbs', 'not_login')

logger = Logger.new( File.join(File.dirname(__FILE__), '..', 'log' ,'sweep.log') )

def delete_job(job, logger)
  if( job[:jobid]=~/^tu_/ ) then return end
  logger.debug("DELETING JOB ID:#{job[:id]} JOBID: #{job[:jobid]}")
  job.actions.each do |action|
    action.queue_jobs.each do |qj|
      logger.debug "Destroy workers!"
      AbstractWorker.destroy_all "queue_job_id = #{qj[:id]}"
    end
    logger.debug "Destroy queue_jobs!"
    QueueJob.destroy_all "action_id = #{action[:id]}"        
  end
  logger.debug "Destroy actions!"
  Action.delete_all "job_id = #{job[:id]}"
  logger.debug "Destroy job!"
  Job.delete(job[:id]) 	
  logger.debug "Delete #{job.job_dir}"
  system("rm -rf #{job.job_dir}")   
end


#delete all jobs of not logged in users that are older than 2 weeks
jobs = Job.find( :all, :conditions => "user_id IS NULL" )
jobs.each do |job|
  if( !(Watchlist.find(:first, :conditions => [ "job_id = ?", job.jobid])).nil? || !(Watchlist.find(:first, :conditions => [ "str_id = ?", job.jobid])).nil?)
    next
  end
  if( (NOW-job[:updated_on]) > TWOWEEKS )
    logger.debug("Deleting job(id='#{job[:id]}') - older than 2 weeks and not owned by a user")
    puts "Deleting job(id='#{job[:id]}') - older than 2 weeks and not owned by a user"
    delete_job(job, logger)
  end	
end

#delete all jobs of useres that are older than 2 months
jobs = Job.find( :all, :conditions => "user_id IS NOT NULL" )
jobs.each do |job|
  if( !(Watchlist.find(:first, :conditions => [ "job_id = ?", job.jobid])).nil? || !(Watchlist.find(:first, :conditions => [ "str_id = ?", job.jobid])).nil?)
    next
  end
  if( (NOW-job[:updated_on]) > TWOMONTHS )
    user = User.find(:first, :conditions=>"id='#{job[:user_id]}'")
    logger.debug("Deleting job(id='#{job[:id]}') - older than 2 months and owned by user: #{user.login}")
    puts "Deleting job(id='#{job[:id]}') - older than 2 months and owned by user: #{user.login}"		
    delete_job(job, logger)
  end	
end

#delete all userdbs of not logged in users that are older than 1 week
Dir.foreach(USERDBDIR) do |dir| 
  if(dir =~ /^\.+$/) then next end
  file = File.join(USERDBDIR, dir)
  if( (NOW-File.ctime(file))>WEEK )
    logger.debug("Deleting userdb #{dir} - older than 1 week")
    puts "Deleting userdb #{dir} - older than 1 week"
    system("rm -f #{file}")
  end
end


#delete all directories in tmp that have no associated job object in the database
EXCLUDE=["pdbalert","rsub"]
Dir.foreach(TMP) do |id| 
  if(id =~ /^\.+$/) then next end 
  if(EXCLUDE.include?(id)) then next end 
  file = File.join(TMP, id)
  if( File.directory?(file) && !File.symlink?(file) )
    res = Job.find(:first, :conditions => "id='#{id}'")
    if( res.nil? )
      logger.debug("Deleting #{file} - no job for id='#{id}' in the db")
      puts "Deleting #{file} - no job for id='#{id}' in the db"
      system("rm -rf #{file}")
    end
  end
end



exit(0)








