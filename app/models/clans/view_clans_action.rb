class ViewClansAction < Action

  CLANS = File.join(BIOPROGS, 'clans')
   
  attr_accessor :xcutoff

  validates_format_of(:xcutoff, {:with => /^\d+(\.\d+)?$/, :on => :create})
  
  validates_shell_params(:xcutoff, {:on=>:create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    @outfile = @basename + ".clans"
    @infile = @basename + ".nxnblast"
    
    @cutoff = params['xcutoff'].to_f.round
    @savetype = params['savetype']
    
  end
  
  def before_perform_on_forward
    pjob = job.parent
    FileUtils.cp(File.join(pjob.job_dir, pjob.jobid + ".nxnblast"), @infile)
  end

  def perform
    params_dump
    
    @commands << "#{JAVA_1_5_EXEC} -Xmx2000m -jar #{CLANS}/blast2clans.jar -i #{@infile} -o #{@outfile} -savetype #{@savetype} -pval 1e-#{@cutoff} &> #{job.statuslog_path}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
    
  end
    
end