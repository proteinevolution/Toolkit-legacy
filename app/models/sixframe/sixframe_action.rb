class SixframeAction < Action
  SIXFRAME = File.join(BIOPROGS, 'sixframe')	  

attr_accessor :sequence_input, :sequence_file, :jobid, :mail

validates_input(:sequence_input, :sequence_file, {:informat => 'nucfas',
																  :max_seqs => 10000,
										  						  :inputmode => 'sequences',
																  :on => :create })

validates_jobid(:jobid)

validates_email(:mail)

 
  def before_perform
	
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"
    @outfile = @basename+".aa"

    params_to_file(@infile,'sequence_input','sequence_file')
    @commands = []

    @showseq = params['showseqs'] ? 't' : 'f' 
    @relPrint = params['relative'] ? 't' : 'f'
    @mode = params['mode']
  
  end

  def perform
    params_dump

    @commands << "#{JAVA_EXEC} -Xmx3G -cp #{SIXFRAME}/ translate -i #{@infile} -o #{@outfile} -seq #{@showseq} -mode #{@mode} -annot #{@relPrint} &> #{job.statuslog_path}"
	  
	 logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end


end

