class HhrepidAction < Action
  HH      = File.join(BIOPROGS, 'hhpred')
  HHSUITE = File.join(BIOPROGS, 'hhsuite/bin')
  HHSUITELIB = File.join(BIOPROGS, 'hhsuite/lib/hh/scripts')
  HHBLITS_DB = File.join(DATABASES, 'hhblits','uniprot20')  
  HHREPID = File.join(BIOPROGS, 'hhrepid')
  PSIPRED = File.join(BIOPROGS, 'psipred')  
  CAL_HHM = File.join(HHREPID,'cal_small.hhm')
  TP_DATA = File.join(HHREPID,'tp.dat')
  FP_DATA = File.join(HHREPID,'fp.dat')
  QSCS    = [0.0, 0.2, 0.3, 0.4, 0.5]
 
  
  if LOCATION == "Munich" && LINUX == 'SL6'
      HHPERL   = "perl "+File.join(BIOPROGS, 'hhpred')
  else
      HHPERL = File.join(BIOPROGS, 'hhpred')
  end
  
  

  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail, :mode,:prefilter
  
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
    @maxhhblitsit = params['maxhhblitsit']
    @ss_scoring    = "-ssm " + params["ss_scoring"]
    @ptot          = "-T " + params["ptot"]
    @pself         = "-P " + params["pself"]
    @mergerounds   = "-mrgr " + params["mergerounds"]
    @mact          = "-mapt1 " + params["mact"] + " -mapt2 " + params["mact"] + " -mapt3 " + params["mact"]
    @domm          = params["domm"].nil? ? "-domm 0" : "" 
    
    @maxlines = "20"
    @v = 1
    
  end
  
   # Optional:
  # Put action initialization code that should be executed on forward here
  def before_perform_on_forward
    logger.debug "L 64 Running before_perform_on_forward with @mode=#{@mode}"
    case @mode
    when 'querymsa'
      logger.debug "L67 Running in Mode querymsa"
      pjob = job.parent
      files = Dir.entries("#{pjob.job_dir}")
      a3m_file = files.include?("#{pjob.jobid}.a3m") ? "#{pjob.jobid}.a3m" : files.detect {|f| f.match /#{pjob.jobid}.*\.a3m/}
      # Policy: Only copy the a3m file. The receiving tool is responsible for
      # creating the hhm file itself, if it needs it.
      #hhm_file = files.include?("#{pjob.jobid}.hhm") ? "#{pjob.jobid}.hhm" : files.detect {|f| f.match /#{pjob.jobid}.*\.hhm/}
      FileUtils.copy_file("#{pjob.job_dir}/#{a3m_file}", "#{@basename}.a3m")
      #FileUtils.copy_file("#{pjob.job_dir}/#{hhm_file}", "#{@basename}.hhm")
      
      logger.debug "L77 Copy  #{pjob.job_dir}/#{pjob.jobid}.a3m  to #{@basename}.a3m "
    end
    
  end
  
  
  

  # Put action code in here
  def perform

    cpus = 1
    # Setting new Prefilter 
    if @mode != 'querymsa'
              @commands << "#{HH}/reformat.pl #{@informat} a3m #{@basename}.in #{@basename}.a3m > #{job.statuslog_path}"
                if(@prefilter=='psiblast')
                   cpus = 2
                   @commands << "echo 'Running Psiblast for MSA Generation' >> #{job.statuslog_path}"
                   @commands << "#{HHPERL}/buildali.pl -cpu 2 -v #{@v} -bs 0.3 -maxres 800 -n  #{@maxhhblitsit}  #{@basename}.a3m &>> #{job.statuslog_path}"
                else
                    if @maxhhblitsit == '0'
                        @commands << "echo 'No MSA Generation Step... ...' >> #{job.statuslog_path}"
                        #@commands << "#{HHSUITELIB}/reformat.pl #{@informat} a3m #{@seqfile} #{@basename}.a3m"
                    else
                        cpus = 8
                        @commands << "echo 'Running HHblits for MSA Generation... ...' >> #{job.statuslog_path}"
                        @commands << "#{HHSUITE}/hhblits -cpu 8 -v 2 -i #{@seqfile} #{@E_hhblits} -d #{HHBLITS_DB} -psipred #{PSIPRED}/bin -psipred_data #{PSIPRED}/data -o #{@basename}.hhblits -oa3m #{@basename}.a3m -n #{@maxhhblitsit} -mact 0.35 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
                    end
                end
    else
        @commands <<"echo 'Using previously generated a3m MSA as Input Model' >> #{job.statuslog_path}  "
    end
    
    # Reformat query into fasta format ('full' alignment, i.e. 100 maximally diverse sequences, to limit amount of data to transfer)
    @commands << "#{HH}/hhfilter -i #{@basename}.a3m -o #{job.job_dir}/#{id}.reduced.a3m -diff 100"
    @commands << "#{HHPERL}/reformat.pl a3m fas #{job.job_dir}/#{id}.reduced.a3m #{@basename}.fas -d 160"  # max. 160 chars in description     
    # Reformat query into fasta format (reduced alignment)  (Careful: would need 32-bit version to execute on web server!!)
    @commands << "#{HH}/hhfilter -i #{@basename}.a3m -o #{job.job_dir}/#{id}.reduced.a3m -diff 50"
    @commands << "#{HHPERL}/reformat.pl a3m fas #{job.job_dir}/#{id}.reduced.a3m #{@basename}.reduced.fas -r"
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
    
    q = queue
    q.on_done = 'run_hhrepid'
    q.save!

    q.submit(@commands, false, { 'cpus' => cpus.to_s() })
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
      cmd = "ln -f -s #{@basename}.a3m #{@basename}.#{qsc}.a3m\n "

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




