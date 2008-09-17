class ClustalwAction < Action
  CLUSTALW = File.join(BIOPROGS, 'clustal', 'clustalw')

  attr_accessor :sequence_input, :sequence_file, :otheradvanced
 
  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
  																	 :on => :create, 
  																	 :min_seqs => 2,
  																	 :max_seqs => 5000,
  																	 :inputmode => 'sequences'})
  																	 
  validates_shell_params(:jobid, :mail, :otheradvanced, {:on => :create})

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"
    @outfile = @basename+".aln"
   
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @otheradvanced = params['otheradvanced'] ? params['otheradvanced'] : ""
  
  end

  def perform
    params_dump

   
    @commands << "#{CLUSTALW}/clustalw -infile=#{@infile} -align #{@otheradvanced} &> #{job.statuslog_path}"
 

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end

