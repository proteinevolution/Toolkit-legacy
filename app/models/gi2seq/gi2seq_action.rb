class Gi2seqAction < Action
  UTILS = File.join(BIOPROGS, 'perl')

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
    @mainlog = @basename+".mainlog"
   
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @unique = params['unique'] ? "-unique" : ""
  
  end

  def perform
    params_dump

   
    @commands << "#{UTILS}/seq_retrieve.pl -i #{@infile} -o #{@outfile} #{@unique} > #{@mainlog} 2> #{job.statuslog_path}"
 
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end