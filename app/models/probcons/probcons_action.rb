class ProbconsAction < Action
  PROBCONS = File.join(BIOPROGS, 'probcons')

  attr_accessor :sequence_input, :sequence_file, :otheradvanced, :consistency, :itrefine, :pretrain
 
  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
  																	 :on => :create, 
  																	 :max_seqs => 5000,
  																	 :min_seqs => 2,
  																	 :inputmode => 'sequences'})
  																	 
  validates_shell_params(:jobid, :mail, :otheradvanced, :consistency, :itrefine, :pretrain, {:on => :create})
  
  validates_format_of(:consistency, :itrefine, :pretrain, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"
    @outfile = @basename+".aln"
   
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @clustalw = params['clustalw'] ? "-clustalw" : ""
    @alnorder = params['alnorder'] ? "-a" : ""
    @pairs = params['pairs'] ? "-pairs" : ""
    @viterbi = params['viterbi'] ? "-viterbi" : ""      
    @consistency = params['consistency'] ? params['consistency'].to_i : 2
    @itrefine = params['itrefine'] ? params['itrefine'].to_i : 100
    @pretrain = params['pretrain'] ? params['pretrain'].to_i : 0
    @otheradvanced = params['otheradvanced'] ? params['otheradvanced'] : ""

    if (@pretrain < 0) then @pretrain = 0 end
    if (@pretrain > 20) then @pretrain = 20 end
    
    if (@itrefine < 0) then @itrefine = 0 end
    if (@itrefine > 1000) then @itrefine = 1000 end
    
    if (@consistency < 0) then @consistency = 0 end
    if (@consistency > 5) then @consistency = 5 end
  end

  def perform
    params_dump

    @commands << "#{PROBCONS}/probcons -v -c #{@consistency} -ir #{@itrefine} #{@alnorder} #{@viterbi} #{@pairs} #{@clustalw} -pre #{@pretrain} #{@other_advanced} #{@infile} > #{@outfile} 2> #{job.statuslog_path}"
 
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end





