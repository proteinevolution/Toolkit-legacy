class HhblitsAction < Action
  HHBLITS = File.join(BIOPROGS, 'hhblits')
  RUBY_UTILS = File.join(BIOPROGS, 'ruby')
  HH = File.join(BIOPROGS, 'hhpred')
  BLAST = File.join(BIOPROGS, 'blast')
  CSBLAST = File.join(BIOPROGS, 'hhblits')
  CSBLASTDB = File.join(BIOPROGS, 'hhblits', 'K4000.lib')
  PSIPRED = File.join(BIOPROGS, 'psipred')

  
  attr_accessor :jobid, :hhblits_dbs, :informat, :inputmode, :maxit, :ss_scoring,
  					 :alignmode, :realign, :Epsiblastval, :mact, :maxseq, :width, :Pmin, :maxlines,
                :sequence_input, :sequence_file, :mail, :otheradvanced

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => :inputmode,
                                                    :max_seqs => 9999,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_db(:hhblits_dbs, {:on => :create})
  
  validates_shell_params(:jobid, :mail, :width, :Pmin, :maxlines, {:on => :create})
  
  validates_format_of(:width, :Pmin, :maxlines, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"    
    @outfile = @basename+".hhr"
    @a3m_outfile = @basename+"_out.a3m"
    @hhm_outfile = @basename+"_out.hhm"
    @a3mfile = @basename+".a3m"
    @hhmfile = @basename+".hhm"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)
    @commands = []

    @dbs = params['hhblits_dbs']
    @dbhhm = params['dbhhm']
        
    @maxit = params['maxit']
    @E_hhblits = params["EvalHHblits"]
    @E_psiblast = params["Epsiblastval"]
    @cov_min = params["cov_min"].nil? ? '' : '-cov '+params["cov_min"]
    @ali_mode = params["alignmode"]
    @ss_scoring = "-ssm #{params['ss_scoring']}"
    @realign = params["realign"] ? "-realign" : "-norealign"
    @filter = params["nofilter"] ? "-nofilter" : ""
    if @realign == '-norealign' 
      @mact = ''
    else
      if @ali_mode == 'global' 
        @mact = '-mact 0.0'
      else
        @mact = params["mact"].nil? ? '' : '-mact '+params["mact"]
      end
    end
    @Pmin = params["Pmin"]
    @max_lines = params["maxlines"]
    @max_seqs = params["maxseq"]
    @aliwidth = params["width"]
    @v = 2
    @diff = '-diff 100'
    @local_dir = "/tmp"

    # Input alignment?
    @inputmode = "sequence"
    seqs = 0
    lines = IO.readlines(@infile)
    lines.each do |line|
      if line =~ /^>/
        seqs += 1
      end
    end
    if seqs > 1
      @inputmode = "alignment"
      @commands << "#{HH}/reformat.pl fas a3m #{@infile} #{@a3mfile} -M first -r"
    end
    
  end

  # Prepare FASTA files for 'Show Query Alignemt', HHviz bar graph, and HMM histograms 
  def prepare_fasta_hhviz_histograms_etc
    # Reformat query into fasta format ('full' alignment, i.e. 100 maximally diverse sequences, to limit amount of data to transfer)
    @commands << "#{HH}/hhfilter -i #{@a3m_outfile} -o #{@local_dir}/#{job.jobid}.reduced.a3m -diff 100"
    @commands << "#{HH}/reformat.pl a3m fas #{@local_dir}/#{job.jobid}.reduced.a3m #{@basename}.fas -d 160"  # max. 160 chars in description 
    
    # Reformat query into fasta format (reduced alignment)  (Careful: would need 32-bit version to execute on web server!!)
    @commands << "#{HH}/hhfilter -i #{@a3m_outfile} -o #{@local_dir}/#{job.jobid}.reduced.a3m -diff 50"
    @commands << "#{HH}/reformat.pl -r a3m fas #{@local_dir}/#{job.jobid}.reduced.a3m #{@basename}.reduced.fas"
    @commands << "rm #{@local_dir}/#{job.jobid}.reduced.a3m"
    
    # Generate graphical display of hits
    @commands << "#{HH}/hhviz.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} &> /dev/null"
    
    # Generate profile histograms
    @commands << "#{HH}/profile_logos.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} #{@dbhhm} > /dev/null"
  end  
  
  def perform
    params_dump
    
    if (@inputmode == "alignment")
      @commands << "#{HHBLITS}/hhblits -cpu 4 -v #{@v} -a3m #{@a3mfile} -hh #{HHBLITS} -db #{@dbs} -dbhhm #{@dbhhm} -blast #{BLAST}/bin -csblast #{CSBLAST} -csblast_db #{CSBLASTDB} -psipred #{PSIPRED}/bin -psipred_data #{PSIPRED}/data -o #{@outfile} -qhhm #{@hhmfile} -oa3m #{@a3m_outfile} -ohhm #{@hhm_outfile} -e_hh #{@E_hhblits} -e_psi #{@E_psiblast} -n #{@maxit} -p #{@Pmin} -Z #{@max_lines} -B #{@max_lines} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@realign} #{@mact} #{@filter} #{@cov_min} 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}; echo 'Finished search'";
    else
      @commands << "#{HHBLITS}/hhblits -cpu 4 -v #{@v} -i #{@infile} -hh #{HHBLITS} -db #{@dbs} -dbhhm #{@dbhhm} -blast #{BLAST}/bin -csblast #{CSBLAST} -csblast_db #{CSBLASTDB} -psipred #{PSIPRED}/bin -psipred_data #{PSIPRED}/data -o #{@outfile} -qhhm #{@hhmfile} -oa3m #{@a3m_outfile} -ohhm #{@hhm_outfile} -e_hh #{@E_hhblits} -e_psi #{@E_psiblast} -n #{@maxit} -p #{@Pmin} -Z #{@max_lines} -B #{@max_lines} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@realign} #{@mact} #{@filter} #{@cov_min} 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}; echo 'Finished search'";
    end

    prepare_fasta_hhviz_histograms_etc    
    
    @commands << "#{HH}/reformat.pl fas fas #{@basename}.reduced.fas #{@basename}.uc.fas -uc -r"
    @commands << "#{RUBY_UTILS}/parse_jalview.rb -i #{@basename}.uc.fas -o #{@basename}.j.fas"


    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'cpus' => '4'})
    
  end
  
end



