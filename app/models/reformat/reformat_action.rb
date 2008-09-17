class ReformatAction < Action
  REFORMAT = File.join(BIOPROGS, 'reformat')

  attr_accessor :sequence_input, :sequence_file, :informat
 
  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :on => :create, 
                                                    :max_seqs => 5000, 
                                                    :inputmode => 'sequences'})

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  def before_perform
    @informat	 = params['informat']
    @outformat  = params['outformat']
    @numprefix	 = params['numprefix'] ? "-num" : ""
    @transform	 = params['character']   
    
    @basename   = File.join(job.job_dir, job.jobid)
    @infile     = @basename+".in"
    @outfile    = @basename+"."+@outformat
   
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []
  
  end

  def perform
    #params_dump

    @commands << "#{REFORMAT}/reformat.pl -i=#{@informat} -o=#{@outformat} -f=#{@infile} -a=#{@outfile} #{@numprefix} #{@transform} &> #{job.statuslog_path}"
 

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end




