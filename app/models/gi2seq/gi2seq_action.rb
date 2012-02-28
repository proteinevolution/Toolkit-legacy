class Gi2seqAction < Action
  

  if LOCATION == "Munich" && LINUX == 'SL6'
      UTILS   = "perl "+File.join(BIOPROGS, 'perl')
  else
      UTILS = File.join(BIOPROGS, 'perl')
  end

  include GenomesModule

  attr_accessor :sequence_input, :sequence_file , :std_dbs, :user_dbs
 
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
    @db_path = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    # getDBs is part of the GenomesModule                                                                                                                                                
    gdbs = getDBs('pep')
    logger.debug gdbs.join('\n')
    @db_path = @db_path+ ' ' + gdbs.join(' ')

   
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @unique = params['unique'] ? "-unique" : ""
  
  end

  def perform
    params_dump

   
    @commands << "#{UTILS}/seq_retrieve.pl -i #{@infile} -o #{@outfile} -d \"#{@db_path}\" #{@unique} > #{@mainlog} 2> #{@mainlog}"
 
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end
