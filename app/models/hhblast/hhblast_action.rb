class HhblastAction < Action
  HHBLAST = File.join(BIOPROGS, 'hhblast')
  HH = File.join(BIOPROGS, 'hhpred')
  BLAST = File.join(BIOPROGS, 'blast')
  
  attr_accessor :jobid, :hhblast_dbs, :informat, :inputmode, :maxit, :ss_scoring,
  					 :alignmode, :realign, :Epsiblastval, :mact, :maxseq, :width, :Pmin, :maxlines,
                :sequence_input, :sequence_file, :mail, :otheradvanced

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => :inputmode,
                                                    :max_seqs => 9999,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_db(:hhblast_dbs, {:on => :create})
  
  validates_shell_params(:jobid, :mail, :width, :Pmin, :maxlines, {:on => :create})
  
  validates_format_of(:width, :Pmin, :maxlines, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"    
    @outfile = @basename+".hhr"
    @a3m_outfile = @basename+"_out.a3m"
    @hhm_outfile = @basename+"_out.hhm"
    @hhm_infile = @basename+".hhm"
    @psi_infile = @basename+".psi"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)
    @commands = []

    @dbs = params['hhblast_dbs'].join(" ")
    @dbhhm = params['dbhhm']
        
    @maxit = params['maxit']
    @E_psiblast = params["Epsiblastval"]
    @ali_mode = params["alignmode"]
    @ss_scoring = "-ssm #{params['ss_scoring']}"
    @realign = params["realign"] ? "-realign" : "-norealign"
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
    @v = 9
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
      process_alignment
    end
    
  end

  def process_alignment
    @commands << "#{HH}/reformat.pl fas psi #{@infile} #{@psi_infile} -M first -r"
    @commands << "#{HH}/hhmake -i #{@infile} -o #{@hhm_infile} -M first" 
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
    @commands << "#{HH}/profile_logos.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} > /dev/null"
  end  
  
  def perform
    params_dump
    
    if (@inputmode == "alignment")
      @commands << "#{HHBLAST}/HHblast -cpu 4 -v #{@v} -psi #{@psi_infile} -hhm #{@hhm_infile} -write_query_hhm #{@hhm_infile} -db #{@dbs} -dbhhm #{@dbhhm} -o #{@outfile} -Oa3m #{@a3m_outfile} -Ohhm #{@hhm_outfile} -e_psi #{@E_psiblast} -n #{@maxit} -p #{@Pmin} -Z #{@max_lines} -B #{@max_lines} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@ss_scoring} #{@realign} #{@mact} 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}; echo 'Finished search'";
    else
      @commands << "#{HHBLAST}/HHblast -cpu 4 -v #{@v} -i #{@infile} -write_query_hhm #{@hhm_infile} -db #{@dbs} -dbhhm #{@dbhhm} -o #{@outfile} -Oa3m #{@a3m_outfile} -Ohhm #{@hhm_outfile} -e_psi #{@E_psiblast} -n #{@maxit} -p #{@Pmin} -Z #{@max_lines} -B #{@max_lines} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@ss_scoring} #{@realign} #{@mact} 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}; echo 'Finished search'";
    end
  
    prepare_fasta_hhviz_histograms_etc    
    
    @commands << "#{HH}/reformat.pl -i #{@basename}.fas -o #{@basename}.uc.fas -uc"
    @commands << "#{BLAST}/parse_jalview.rb -i #{@basename}.uc.fas -o #{@basename}.j.fas"


    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'cpus' => '4'})
    
  end
  
end



