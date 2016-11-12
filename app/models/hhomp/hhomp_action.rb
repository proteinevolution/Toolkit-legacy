class HhompAction < Action
  HHOMP = File.join(BIOPROGS, 'hhomp')
  CAL_HHM = File.join(DATABASES,'hhpred','cal.hhm')
  BLAST = File.join(BIOPROGS, 'blast')

   if LOCATION == "Munich" && LINUX == 'SL6'
    HHOMPPERL = "perl "+File.join(BIOPROGS, 'hhomp')
    UTILS    = "perl "+File.join(BIOPROGS, 'perl')
  else
    HHOMPPERL = File.join(BIOPROGS, 'hhomp')
    UTILS  = File.join(BIOPROGS, 'perl')
      
  end

  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail,
                :width, :Pmin, :maxlines, :hhomp_dbs

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 10000,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_db(:hhomp_dbs)
  
  validates_shell_params(:jobid, :mail, :width, :Pmin, :maxlines, {:on => :create})
  
  validates_format_of(:width, :Pmin, :maxlines, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @seqfile = @basename+".in"
    params_to_file(@seqfile, 'sequence_input', 'sequence_file')
    @commands = []
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @seqfile)
    @informat = "fas"
    
    @dbs = params['hhomp_dbs'].nil? ? "" : params['hhomp_dbs']
    if @dbs.kind_of?(Array) then @dbs = @dbs.join(' ') end
    @maxpsiblastit = params['maxpsiblastit']
    @E_psiblast = params["Epsiblastval"].nil? ? '' : "-e "+params["Epsiblastval"]
    @cov_min = params["cov_min"].nil? ? '' : '-cov '+params["cov_min"]
    @qid_min = params["qid_min"].nil? ? '' : '-qid '+params["qid_min"]
    @ali_mode = params["alignmode"]
    @bb_scoring = params["score_bb"] == "yes" ? "" : "-bbm 0"
    @Pmin = params["Pmin"]
    @max_lines = params["maxlines"]
    @max_seqs = params["maxseq"]
    @aliwidth = params["width"]
    @inputmode = params["inputmode"]
    @sequences = []
    @seqnames  = []
    @v = 1
    @local_dir = '/tmp'
    @blast_db = File.join(DATABASES, 'hhomp', 'blast-db', 'HHompDB70')

  end

  # Prepare FASTA files for 'Show Query Alignemt', HHviz bar graph, and HMM histograms 
  def prepare_fasta_hhviz_histograms_etc
    # Reformat query into fasta format ('full' alignment, i.e. 100 maximally diverse sequences, to limit amount of data to transfer)
    @commands << "#{HHOMP}/hhfilter -i #{@basename}.a3m -o #{@local_dir}/#{job.jobid}.reduced.a3m -diff 100"
    @commands << "#{HHOMPPERL}/reformat.pl a3m fas #{@local_dir}/#{job.jobid}.reduced.a3m #{@basename}.fas -d 160"  # max. 160 chars in description 
    
    # Reformat query into fasta format (reduced alignment)
    @commands << "#{HHOMP}/hhfilter -i #{@basename}.a3m -o #{@local_dir}/#{job.jobid}.reduced.a3m -diff 50"
    @commands << "#{HHOMPPERL}/reformat.pl -r a3m fas #{@local_dir}/#{job.jobid}.reduced.a3m #{@basename}.reduced.fas"
    @commands << "rm #{@local_dir}/#{job.jobid}.reduced.a3m"
    
    # Generate graphical display of hits
    @commands << "#{HHOMPPERL}/hhviz.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} &> /dev/null"
    
    # Generate profile histograms
    @commands << "#{HHOMPPERL}/profile_logos.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} > /dev/null"
  end

  def before_perform_on_forward
    pjob = job.parent
  end

  def perform
    params_dump
    cpus = 2
    
    # Create alignment
    @commands << "#{HHOMPPERL}/buildali.pl -nodssp -bb -cpu 2 -v #{@v} -n #{@maxpsiblastit} #{@E_psiblast} #{@cov_min} -diff 100 -bl 0 -bs 0.5 -p 1E-7 -#{@informat} #{@seqfile} &> #{job.statuslog_path}"
    # Make HMM file
    @commands << "echo 'Making profile HMM from alignment ...' >> #{job.statuslog_path}"
    @commands << "#{HHOMP}/hhmake -v #{@v} #{@cov_min} #{@qid_min} -diff 100 -i #{@basename}.a3m -o #{@basename}.hhm 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    
    # Calibrate HMM file
    @commands << "echo 'Calibrating query HMM ...' >> #{job.statuslog_path}"
    @commands << "#{HHOMP}/hhomp -cpu 2 -v #{@v} -i #{@basename}.hhm -d #{CAL_HHM} -cal -#{@ali_mode} #{@bb_scoring} 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"

    # HHomp with query HMM against HMM database
    @commands << "echo 'Searching #{@dbs} ...' >> #{job.statuslog_path}"
    @commands << "#{HHOMP}/hhomp -cpu 2 -v #{@v} -i #{@basename}.hhm -d '#{@dbs}' -o #{@basename}.hhr -p #{@Pmin} -P #{@Pmin} -Z #{@max_lines} -B #{@max_lines} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@bb_scoring} 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}; echo 'Finished search'";
    
    @commands << "#{BLAST}/blastpgp -i #{@seqfile} -e 10 -F F -M BLOSUM62 -G 11 -E 1 -v 100 -b 100 -T T -o #{@basename}.blast -d \"#{@blast_db}\" -I T -a 1 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    @commands << "#{UTILS}/fix_blast_errors.pl -i #{@basename}.blast &>#{@basename}.log_fix_errors"

    prepare_fasta_hhviz_histograms_etc    

    logger.debug "Commands:\n"+@commands.join("\n") 
    # optimization: why give blastpgp above only one cpu?
    queue.submit(@commands, nil, { 'cpus' => cpus.to_s() })
  end

end
