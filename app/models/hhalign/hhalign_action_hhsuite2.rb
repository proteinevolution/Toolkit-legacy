class HhalignAction < Action
  HH = File.join(BIOPROGS, 'hhpred')
  HHSUITE = File.join(BIOPROGS, 'hhsuite/bin')
   if LOCATION == "Munich" && LINUX == 'SL6'
    HHPERL   = "perl "+File.join(BIOPROGS, 'hhpred')
  else
     HHPERL = File.join(BIOPROGS, 'hhpred')
  end
  
  attr_accessor :sequence_input, :sequence_file, :informat, :seqid, :qid, :dwin, :dthr
  attr_accessor :target_input, :target_file, :target_informat
  attr_accessor :jobid, :mail, :otheradvanced

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, :on => :create, :max_seqs => 5000, :min_seqs => 2, :inputmode => 'alignment'})

  validates_input(:target_input, :target_file, {:informat_field => :target_informat, :on => :create, :allow_nil => true, :max_seqs => 5000, :inputmode => 'alignment'})
  
  validates_shell_params(:jobid, :mail, :otheradvanced, :seqid, :qid, :dwin, :dthr, {:on => :create})

  validates_format_of(:seqid, :qid, :dwin, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 
	
  validates_format_of(:dthr, {:with => /^\d+\.?\d*$/, :on => :create, :message => 'Invalid value!'}) 
  
  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @inbasename = @basename+".1"
    @infile = @inbasename + ".in"
    @targetbasename = @basename+".2"    
    @targetfile = @targetbasename + ".in"
    @outfile = @basename+".hhr"
    
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @target = params_to_file(@targetfile, 'target_input', 'target_file')
    
    logger.debug "Target: #{@target}"
    
    @informat = params['informat']
    reformat(@informat, "fas", @infile)
    
    if (@target)
      @target_informat = params['target_informat']
      reformat(@target_informat, "fas", @targetfile)
    end
    
    @commands = []
    
    @v = 1
    
    @seqid = params['seqid']
    @qid = params['qid']
    @dwin = params['dwin']
    @dthr = params['dthr']
    @score2struct = params['score2struct'] ? "" : "-ssm 0"
    @otheradvanced = params['otheradvanced'] ? params['otheradvanced'] : ""
    
  end
  
  def perform
    params_dump
    
    @commands << "export  HHLIB=#{HHLIB} "
    @commands << "export  PATH=$PATH:#{HHSUITE} "
    # Add secondary structure prediction
    @commands << "#{HHPERL}/buildali.pl -v #{@v} -fas -n 0 #{@infile} &> #{job.statuslog_path}"
    
    if (@target)
      @target = "-t #{@targetbasename}.hhm"
      # Add secondary structure prediction
      @commands << "#{HHPERL}/buildali.pl -v #{@v} -fas -n 0 #{@targetfile} 2>&1 1>> #{job.statuslog_path}"
    else
      @target = ""
    end
    
    # build hmm for the query sequence
    @commands << "#{HHSUITE}/hhmake -i #{@inbasename}.a3m -qid #{@qid} -id #{@seqid} -o #{@inbasename}.hhm 2>&1 1>> #{job.statuslog_path}"
    
    # if target-sequence exist, build hmm for the target sequence
    if (!@target.empty?)
      @commands << "#{HHSUITE}/hhmake -i #{@targetbasename}.a3m -qid #{@qid} -id #{@seqid} -o #{@targetbasename}.hhm 2>&1 1>> #{job.statuslog_path}"
    end
    
    @commands << "#{HHSUITE}/hhsearch -i #{@inbasename}.hhm -d #{DATABASES}/hhpred/cal.hhm -cal"
    
    @commands << "#{HHSUITE}/hhalign -v #{@v} -i #{@inbasename}.hhm #{@target} -o #{@outfile} -png #{@basename}.png -qid #{@qid} -id #{@seqid} -dwin #{@dwin} -dthr #{@dthr} #{@score2struct} #{@otheradvanced} 2>&1 1>> #{job.statuslog_path}"		
    
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
    
  end
  
end




