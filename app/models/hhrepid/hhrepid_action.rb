class HhrepidAction < Action
  HH      = File.join(BIOPROGS, 'hhpred')
  HHREPID = File.join(BIOPROGS, 'hhrepid')
  CAL_HHM = File.join(HHREPID,'cal_small.hhm')
  TP_DATA = File.join(HHREPID,'tp.dat')
  FP_DATA = File.join(HHREPID,'fp.dat')
  QSCS    = [0.0, 0.2, 0.3, 0.4, 0.5]

  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail
  
  validates_input(:sequence_input, :sequence_file, {
                    :informat_field => :informat, 
                    :informat => 'fas', 
                    :inputmode => 'alignment',
                    :max_seqs => 10000,
                    :on => :create 
                  })
  
  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  # Put action initialisation code in here
  def before_perform
    
    @basename = File.join(job.job_dir, job.jobid)
    @seqfile = @basename+".in"
    params_to_file(@seqfile, 'sequence_input', 'sequence_file')
    @commands = []
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @seqfile)
    @informat = "fas"

    @maxpsiblastit = params['maxpsiblastit']
    @ss_scoring    = "-ssm " + params["ss_scoring"]
    @ptot          = "-T " + params["ptot"]
    @pself         = "-P " + params["pself"]
    @mergerounds   = "-mrgr " + params["mergerounds"]
    @mact          = "-mapt1 " + params["mact"] + " -mapt2 " + params["mact"] + " -mapt3 " + params["mact"]
    @domm          = params["domm"].nil? ? "-domm 0" : "" 
    
    @mode = nil
    @maxlines = "20"
    @v = 1
    
  end

  # Put action code in here
  def perform

    # Build query alignment and prepare FASTA files for 'Show Query Alignemt'    
    @commands << "#{HH}/reformat.pl #{@informat} a3m #{@basename}.in #{@basename}.a3m > #{job.statuslog_path}"
    if @maxpsiblastit.to_i > 0
      @commands << "#{HH}/buildali.pl -cpu 2 -v #{@v} -bs 0.3 -maxres 2000 -n #{@maxpsiblastit} #{@basename}.a3m  1>>#{job.statuslog_path} 2>&1"
    end
    # Reformat query into fasta format ('full' alignment, i.e. 100 maximally diverse sequences, to limit amount of data to transfer)
    @commands << "#{HH}/hhfilter -i #{@basename}.a3m -o #{job.job_dir}/#{id}.reduced.a3m -diff 100"
    @commands << "#{HH}/reformat.pl a3m fas #{job.job_dir}/#{id}.reduced.a3m #{@basename}.fas -d 160"  # max. 160 chars in description     
    # Reformat query into fasta format (reduced alignment)  (Careful: would need 32-bit version to execute on web server!!)
    @commands << "#{HH}/hhfilter -i #{@basename}.a3m -o #{job.job_dir}/#{id}.reduced.a3m -diff 50"
    @commands << "#{HH}/reformat.pl a3m fas #{job.job_dir}/#{id}.reduced.a3m #{@basename}.reduced.fas -r"
    @commands << "rm #{job.job_dir}/#{id}.reduced.a3m"

    # save input params for later use in run_hhrepid
    @hash = {}
    @hash['ss_scoring']  	= @ss_scoring
    @hash['ptot']        	= @ptot
    @hash['pself']       	= @pself
    @hash['mergerounds'] 	= @mergerounds
    @hash['mact']        	= @mact
    @hash['domm']        	= @domm

    self.flash = @hash
    self.save!
    
    logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'run_hhrepid'
    q.save!

    q.submit(@commands, false)
  end

  def run_hhrepid
    @basename    	= File.join(job.job_dir, job.jobid)
    @ss_scoring  	= flash["ss_scoring"]
    @ptot        	= flash["ptot"]
    @pself       	= flash["pself"]
    @mergerounds 	= flash["mergerounds"]
    @mact        	= flash["mact"]
    @domm        	= flash["domm"]

    # Run HHrepID with different qsc settings
    @commands = []
    QSCS.each do |qsc|
      cmd = "ln -s #{@basename}.a3m #{@basename}.#{qsc}.a3m\n "

      args = "-qsc #{qsc.to_s} -i #{@basename}.#{qsc}.a3m -o #{@basename}.#{qsc}.hhrepid -d #{CAL_HHM} -pdir #{job.job_dir} -tp #{TP_DATA} -fp #{FP_DATA} #{@pself} #{@ptot} #{@mergerounds} #{@ss_scoring} #{@domm} #{@mact}"
      if qsc==0.3
        cmd << "#{HHREPID}/bin/hhrepid #{args} 1>>#{job.statuslog_path} 2>&1"
      else
        cmd << "#{HHREPID}/bin/hhrepid #{args}"
      end
      @commands << cmd
    end

    q = queue
    q.on_done = 'run_graphrepeats'
    q.save!
    q.submit_parallel(@commands, false)
  end

  def run_graphrepeats
    @basename   = File.join(job.job_dir, job.jobid)
    
    # Create repeat graph for all runs in which repeats were detected
    @commands = []
    QSCS.each do |qsc|
      if File.exists?("#{@basename}.#{qsc}.hhrepid")
        @commands << "#{HHREPID}/script/graphrepeats -i #{@basename}.#{qsc}.hhrepid -q #{@basename}.fas -o #{@basename}.#{qsc}.png -m #{@basename}.#{qsc}.map 1>>#{job.statuslog_path} 2>&1"
      end      
    end
    queue.submit(@commands)
  end
  
end




