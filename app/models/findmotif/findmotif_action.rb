class FindMotifAction < Action

   FINDMOTIF = File.join(BIOPROGS, "findmotif")
   
  # top down: protblast/index.rhtml
  attr_accessor :
  # shared/joboptions.rhtml
  attr_accessor :jobid, :mail 
  
  validates_input()

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail)
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    
  end

  def perform
    params_dump

    @commands << "#{FINDMOTIF}/run.pl ... &> #{job.statuslog_path}"
 
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end
end

