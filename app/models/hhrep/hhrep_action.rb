class HhrepAction < Action
  HH = File.join(BIOPROGS, 'hhpred')
  HHSUITE = File.join(BIOPROGS, 'hhsuite/bin')
  HHSUITELIB = File.join(BIOPROGS, 'hhsuite/lib/hh/scripts')
  HHBLITS_DB = File.join(DATABASES, 'hhblits','uniprot20')  
  CAL_HHM = File.join(DATABASES,'hhpred','cal.hhm')
  PSIPRED = File.join(BIOPROGS, 'psipred')  
  
  if LOCATION == "Munich" && LINUX == 'SL6'
      HHPERL   = "perl "+File.join(BIOPROGS, 'hhpred')
  else
      HHPERL = File.join(BIOPROGS, 'hhpred')
  end
  
  
  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail, :width, :prefilter, :mode
  
  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                    :informat => 'fas', 
                    :inputmode => 'alignment',
                    :max_seqs => 10000,
                    :on => :create })
  
  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, :width, {:on => :create})
  
  validates_format_of(:width, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 
  
  # Put action initialisation code in here
  def before_perform
   
    @basename = File.join(job.job_dir, job.jobid)
    @seqfile = @basename+".in"
    params_to_file(@seqfile, 'sequence_input', 'sequence_file')
    @commands = []
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @seqfile)
    @informat = "fas"
    @maxhhblitsit = params['maxhhblitsit']
    @maxpsiblastit = params['maxpsiblastit']
    @ss_scoring = "-ssm " + params["ss_scoring"]
    @max_seqs = params["maxseq"]
    @aliwidth = params["width"].to_i < 20 ? "20" : params['width']
    @inputmode = params["inputmode"]
    
   
    @maxlines = "20"
    @v = 1
    
  end
  
  
  # Optional:
  # Put action initialization code that should be executed on forward here
  def before_perform_on_forward
    logger.debug "L 59 Running before_perform_on_forward with @mode=#{@mode}"
    case @mode
    when 'querymsa'
      logger.debug "L62 Running in Mode querymsa"
      pjob = job.parent
      files = Dir.entries("#{pjob.job_dir}")
      a3m_file = files.include?("#{pjob.jobid}.a3m") ? "#{pjob.jobid}.a3m" : files.detect {|f| f.match /#{pjob.jobid}.*\.a3m/}
      FileUtils.copy_file("#{pjob.job_dir}/#{a3m_file}", "#{@basename}.a3m")
      
      logger.debug "L68 Copy  #{pjob.job_dir}/#{pjob.jobid}.a3m  to #{@basename}.a3m "

    end
    
  end
  
  
  # Put action code in here
  def perform
    
    logger.debug "L78 Mode set to #{@mode} !"
    cpus = 1
    
    @commands << "source #{SETENV}"

    if @mode != 'querymsa'
      @commands << "reformat.pl #{@informat} a3m #{@basename}.in #{@basename}.a3m > #{job.statuslog_path}"
    end
    if @maxpsiblastit.to_i > 0 || @mode != 'querymsa'
             #cpus = 2
             #@commands << "#{HH}/buildali.pl -cpu 2 -v #{@v} -bs 0.3 -maxres 800 -n #{@maxpsiblastit} #{@basename}.a3m  1>>#{job.statuslog_path} 2>&1"
    end
    
    
    # Settin new Prefilter 
    if @mode != 'querymsa'
              if(@prefilter=='psiblast')
                   cpus = 2
                   @commands << "echo 'Running Psiblast for MSA Generation' >> #{job.statuslog_path}"
                   @commands << "buildali.pl -cpu 2 -v #{@v} -bs 0.3 -maxres 800 -n  #{@maxhhblitsit}  #{@basename}.a3m &> #{job.statuslog_path}"
                else
                    # Export variable needed for HHSuite
                    #@commands << "export  HHLIB=#{HHLIB}"

                    if @maxhhblitsit == '0'
                        @commands << "echo 'No MSA Generation Set... ...' >> #{job.statuslog_path}"
                        @commands << "reformat.pl #{@informat} a3m #{@seqfile} #{@basename}.a3m"
                    else
                        cpus = 8
                        @commands << "echo 'Running HHblits for MSA Generation... ...' >> #{job.statuslog_path}"
                        @commands << "hhblits -cpu 8 -v 2 -i #{@seqfile} #{@E_hhblits} -d #{HHBLITS_DB}  -o #{@basename}.hhblits -oa3m #{@basename}.a3m -n #{@maxhhblitsit} -mact 0.35 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
                    end
                end
    else
        @commands <<"echo 'Using previously generated a3m MSA as Input Model' >> #{job.statuslog_path}  "
    end

    @hash = {}
    @hash['maxlines'] = @maxlines
    @hash['width'] = @aliwidth
    @hash['ss_scoring'] = @ss_scoring
    
    self.flash = @hash
    self.save!
    
    logger.debug "L121 Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'makemodel'

    @commands << "source #{UNSETENV}"

    q.save!
    q.submit(@commands, false, { 'cpus' => cpus.to_s() })
    
  end
  
  def makemodel
    
    @basename = File.join(job.job_dir, job.jobid)
    @ss_scoring = flash["ss_scoring"]
    @maxlines = flash["maxlines"]
    @aliwidth = flash["width"]
    
    ['30', '40', '50', '0'].each do |qid|
      @commands = []
      @commands << "source #{SETENV}"
      # Filter alignment
      @commands << "hhfilter -diff 500 -qid #{qid} -i #{@basename}.a3m -o #{@basename}.#{qid}.a3m 1>>#{job.statuslog_path} 2>&1"
      # Make HMM from alignment
      @commands << "hhmake -i #{@basename}.#{qid}.a3m -o #{@basename}.#{qid}.hhm 1>>#{job.statuslog_path} 2>&1"
      # Calibrate hhm file
      @commands << "hhsearch -cpu 2 -v 1 -i #{@basename}.#{qid}.hhm -d #{CAL_HHM} #{@ss_scoring} -cal 1>>#{job.statuslog_path} 2>&1"

      # hhalign HMM with itself
      @commands << "hhalign -aliw #{@aliwidth} -local -p 10 -alt #{@maxlines} -v 1 -i #{@basename}.#{qid}.hhm -o #{@basename}.#{qid}.hhr #{@ss_scoring} 1>>#{job.statuslog_path} 2>&1"
      # Prepare FASTA files for 'Show Query Alignemt', and HMM histograms
      prepare_fasta_hhviz_histograms_etc("#{@basename}.#{qid}", "#{job.jobid}.#{qid}")
      
      logger.debug "L150 Commands:\n"+@commands.join("\n")
      q = queue
      if qid == '0'
        q.on_done = 'create_links'
        q.save!
      end
      @commands << "source #{UNSETENV}"
      q.submit(@commands, false, { 'cpus' => '2' })
      
    end
    
  end
  
  def create_links
    
    @basename = File.join(job.job_dir, job.jobid)
    @ss_scoring = flash["ss_scoring"]
    @maxlines = flash["maxlines"]
    @aliwidth = flash["width"]
    @commands = []
    @commands << "source #{SETENV}"
    
    # Links to file
    @commands << "rm -f #{@basename}.a3m; ln -s #{@basename}.0.a3m #{@basename}.a3m"
    @commands << "rm -f #{@basename}.hhm; ln -s #{@basename}.0.hhm #{@basename}.hhm"
    @commands << "rm -f #{@basename}.tar.gz; ln -s #{@basename}.0.tar.gz #{@basename}.tar.gz"
    @commands << "rm -f #{@basename}.fas; ln -s #{@basename}.0.fas #{@basename}.fas"
    @commands << "rm -f #{@basename}.reduced.fas; ln -s #{@basename}.0.reduced.fas #{@basename}.reduced.fas"

    # hhalign HMM with itself
    @commands << "hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt #{@maxlines} -dsca 600 -v 1 -i #{@basename}.0.hhm -o #{@basename}.hhr -dmap #{@basename}.dmap -png #{@basename}.png -dwin 10 -dthr 0.4 -dali all 1>>#{job.statuslog_path} 2>&1"
    # create png-file with factor 3
    @commands << "hhalign -aliw #{@aliwidth} -local -alt 1 -dsca 3 -i #{@basename}.0.hhm -png #{@basename}_factor3.png -dwin 10 -dthr 0.4 -dali all 1>>#{job.statuslog_path} 2>&1"

    logger.debug "L182 Commands:\n"+@commands.join("\n")
    @commands << "source #{UNSETENV}"
    queue.submit(@commands)
    
  end
  
  # Prepare FASTA files for 'Show Query Alignemt', HHviz bar graph, and HMM histograms 
  def prepare_fasta_hhviz_histograms_etc(basename, id)
    @local_dir = '/tmp'
    # Reformat query into fasta format ('full' alignment, i.e. 100 maximally diverse sequences, to limit amount of data to transfer)
    @commands << "hhfilter -i #{basename}.a3m -o #{@local_dir}/#{id}.reduced.a3m -diff 100"
    @commands << "reformat.pl a3m fas #{@local_dir}/#{id}.reduced.a3m #{basename}.fas -d 160"  # max. 160 chars in description 
    
    # Reformat query into fasta format (reduced alignment)  (Careful: would need 32-bit version to execute on web server!!)
    @commands << "hhfilter -i #{basename}.a3m -o #{@local_dir}/#{id}.reduced.a3m -diff 50"
    @commands << "reformat.pl a3m fas #{@local_dir}/#{id}.reduced.a3m #{basename}.reduced.fas -r"
    @commands << "rm #{@local_dir}/#{id}.reduced.a3m"
    
    # Generate graphical display of hits
    @commands << "hhviz.pl #{id} #{job.job_dir} #{job.url_for_job_dir} &> /dev/null"
    
    # Generate profile histograms
    @commands << "profile_logos.pl #{id} #{job.job_dir} #{job.url_for_job_dir} > /dev/null"
  end

end



