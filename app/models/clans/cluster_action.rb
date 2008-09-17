class ClusterAction < Action

  CLANS = File.join(BIOPROGS, 'clans')
   
  attr_accessor :xcutoff, :cluster, :minLinks, :stdev, :globalaverage, :offset, :minseqs

  validates_format_of(:xcutoff, :minLinks, :stdev, {:with => /^\d+(\.\d+)?$/, :allow_nil => true, :on => :create})
  
  validates_format_of(:minseqs, {:with => /^\d+$/, :on => :create})
  
  validates_shell_params(:xcutoff, :minLinks, :stdev, :minseqs, {:on=>:create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    @outfile = @basename + ".clusters"
    @infile = @basename + ".nxnblast"
    
    @cutoff = params['xcutoff'].to_f.round
    @cluster = params['cluster']
    @minLinks = params['minLinks'] ? params['minLinks'] : "1"
    @stdev = params['stdev'] ? params['stdev'] : "0.5"
    @globalaverage = params['globalaverage'] ? "T" : "F"
    @offset = params['offset'] ? "T" : "F"
    @minseqs = params['minseqs']
    
  end
  
  def before_perform_on_forward
    pjob = job.parent
    FileUtils.cp(File.join(pjob.job_dir, pjob.jobid + ".nxnblast"), @infile)
  end

  def perform
    params_dump
    
    @commands << "#{JAVA_1_5_EXEC} -Xmx500m -jar #{CLANS}/clustering.jar -i #{@infile} -o #{@outfile} -blast T -cluster #{@cluster} -reformat F -linkage #{@minLinks} -stdev #{@stdev} -pval 1e-#{@cutoff} -dooffset #{@offset} -globalaverage #{@globalaverage} &> #{job.statuslog_path}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
    
  end
    
end