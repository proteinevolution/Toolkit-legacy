class Gi2proAction < Action
  GI2PRO = File.join(BIOPROGS, 'gi2promotors')

  attr_accessor :sequence_input, :sequence_file
 
  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat => 'gi', 
  																	 :on => :create, 
  																	 :max_seqs => 100000,
  																	 :inputmode => 'sequences'})
  																	 
  validates_shell_params(:jobid, :mail, {:on => :create})

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile  = @basename+".in"
    @outfile = @basename+".out"
   
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @num_lead = params['num_lead'] ? params['num_lead'] : "200"
    @num_trail = params['num_trail'] ? params['num_trail'] : "100"

    @database_path = File.join(DATABASES, 'genomes', 'current', 'distfiles', 'ncbi', 'Bacteria')
  
  end

  def perform
    params_dump

   
    @commands << "#{GI2PRO}/getpromotors.pl #{@infile} #{@database_path} #{@num_lead} #{@num_trail} #{@outfile} &> #{job.statuslog_path}"
 
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end
