class ClustalwAction < Action
  CLUSTALW = File.join(BIOPROGS, 'clustalw-2.1')
  CLUSTALO = File.join(BIOPROGS, 'clustal-omega')


  attr_accessor :sequence_input, :sequence_file, :otheradvanced
 
  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
  																	 :on => :create, 
  																	 :min_seqs => 2,
  																	 :max_seqs => 5000,
                                     :header_length => 2000,
  																	 :inputmode => 'sequences'})
  																	 
  validates_shell_params(:jobid, :mail, :otheradvanced, {:on => :create})

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"
    @outfile = @basename+".aln"
    @version = params['version']   

    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @otheradvanced = params['otheradvanced'] ? params['otheradvanced'] : ""
  
  end

  def perform
    params_dump

    if (@version == '-o')
	@commands << "#{CLUSTALO}/clustalo -i #{@infile} -o #{@outfile} --outfmt=clustal -v --force #{@otheradvanced}  &> #{job.statuslog_path}"	
    else
    	@commands << "#{CLUSTALW}/clustalw2 -infile=#{@infile} -align #{@otheradvanced} &> #{job.statuslog_path}"
    end

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end

