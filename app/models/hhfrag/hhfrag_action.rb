class HhfragAction < Action
  HHFRAG = File.join(BIOPROGS, 'hhfrag')

  attr_accessor :sequence_input, :sequence_file, :informat, :mail, :jobid

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :inputmode => 'sequence',
                                                    :max_seqs => 1,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, {:on => :create})
  
  
  #########################
  # Load the input Data into file and init Vars
  #
  ##########################
  def before_perform
    @outdir  = job.job_dir.to_s
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"   
    # still has to be generated
    @outfile = @basename+".frags"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    @predict_ta = params['ta']
    reformat(@informat, "fas", @infile)
    @commands = []
    
 
  end

  def perform
    params_dump
    
      # Just run hhfrag
      @commands << "#{HHFRAG}/hhfrag.sh #{@infile} #{@outdir} #{@predict_ta}  >>#{job.statuslog_path}"
      # Fire up method to copy file from temp to folder


   
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
  
end

