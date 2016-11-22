class Hh3dTemplAction < Action
  
  def do_fork?
    return false
  end
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    
    @commands = []
    
    @templpdb = params["templpdb"]
    
  end
  
  def before_perform_on_forward
    
    pjob = job.parent
    
  end
  
  def perform
    params_dump
    
    system("cp #{@templpdb} #{@basename}.templ.pdb")
    self.status = STATUS_DONE
    self.save!
    job.update_status			
  end
  
end


