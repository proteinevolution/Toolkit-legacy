class HhpredAction < Action
  HH = File.join(BIOPROGS, 'hhpred')
  HHBLITS = File.join(BIOPROGS, 'hhblits')
  CAL_HHM = File.join(DATABASES,'hhpred','cal.hhm')
  RUBY_UTILS = File.join(BIOPROGS, 'ruby')
  CSBLAST = File.join(BIOPROGS, 'csblast')
  HHBLITS_DB = File.join(DATABASES, 'hhblits','uniprot20.cs219')
  HHBLITS_DBHHM = File.join(DATABASES, 'hhblits','uniprot20_hhm_db')
  HHBLITS_DBA3M = File.join(DATABASES, 'hhblits','uniprot20_a3m_db')

  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail,
                :width, :Pmin, :maxlines, :hhpred_dbs, :genomes_hhpred_dbs

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat,
                                                    :informat => 'fas',
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 10000,
                                                    :on => :create,
						    :ss_allow => true })

  validates_jobid(:jobid)

  validates_email(:mail)

  validates_db(:hhpred_dbs, {:genomes_dbs => 'genomes_hhpred_dbs', :on => :create})

  validates_shell_params(:jobid, :mail, :width, :Pmin, :maxlines, {:on => :create})

  validates_format_of(:width, :Pmin, :maxlines, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @seqfile = @basename+".in"
    params_to_file(@seqfile, 'sequence_input', 'sequence_file')
    @commands = []
    @informat = params['informat'] ? params['informat'] : 'fas'
    if (@informat != "a3m")
      reformat(@informat, "fas", @seqfile)
      @informat = "fas"
    end

    @dbs = params['hhpred_dbs'].nil? ? "" : params['hhpred_dbs']
    if @dbs.kind_of?(Array) then @dbs = @dbs.join(' ') end
    @genomes_dbs = params['genomes_hhpred_dbs'].nil? ? "" : params['genomes_hhpred_dbs']
    if @genomes_dbs.kind_of?(Array) then @genomes_dbs = @genomes_dbs.join(' ') end

    @dbs = @dbs + " " + @genomes_dbs

    @maxhhblitsit = params['maxhhblitsit']
    @E_hhblits = params["Ehhblitsval"].nil? ? '' : "-e "+params["Ehhblitsval"]
    @cov_min = params["cov_min"].nil? ? '' : '-cov '+params["cov_min"]
    @qid_min = params["qid_min"].nil? ? '' : '-qid '+params["qid_min"]
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
    @compbiascorr = params["compbiascorr"].nil? ? '' : (params["compbiascorr"]=='1'? '-sc 1' : '-sc 0 -shift -0.1')
    @Pmin = params["Pmin"].nil? ? 20 : params["Pmin"]
    @max_lines = params["maxlines"].nil? ? 100 : params["maxlines"]
    @max_seqs = params["maxseq"].nil? ? 1 : params["maxseq"]
    @aliwidth = params["width"].nil? ? 80 : params["width"]
    @relaunch = params["relaunch"]
    @hhviz = params["hhviz"]
    @inputmode = params["inputmode"]
    @sequences = []
    @seqnames  = []
    @v = 1
    @diff = '-diff 100'
    @local_dir = '/tmp'

    process_databases
  end

  def process_databases

    # Expand cdd and interpro as list of member databases
    if (@dbs =~ /cdd_/)
      ['pfam_*', 'smart_*', 'KOG_*', 'COG_*', 'cd_*'].each do |db|
        db_path = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', db))[0]
        if (!db_path.nil?)
          @dbs += " " + db_path
        end
      end
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pfam_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'smart_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'KOG_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'COG_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'cd_*'))[0]

      @dbs.gsub!(/\s*\S+\/cdd_\S+\s+/, ' ')
    end
    if (@dbs =~ /interpro_/)
      ['pfamA_*', 'smart_*', 'panther_*', 'tigrfam_*', 'pirsf_*', 'supfam_*', 'CATH_*'].each do |db|
        db_path = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', db))[0]
        if (!db_path.nil?)
          @dbs += " " + db_path
        end
      end

#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pfamA_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'smart_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'panther_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'tigrfam_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pirsf_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'supfam_*'))[0]
#      @dbs += " " + Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'CATH_*'))[0]

      @dbs.gsub!(/\s*\S+\/interpro_\S+\s+/, ' ')
    end

    # Replace pdb70_* with new version of pdb
    newpdb = Dir.glob(File.join(DATABASES, 'hhpred', 'new_dbs', 'pdb70_*'))[0]
    @dbs.gsub!(/\S*pdb70_\S+/, newpdb)

    @dbs = @dbs.split(' ')
    @dbs = @dbs.uniq.join(' ')

    # Save databases for realign
    @dbs_realign = @dbs.clone

    # Append /db/scop.hhm or /db/pdb.hhm or /db/cdd.hhm etc. to every database directory
    dbs=""
    @dbs.split(/\s+/).each do |db|
      if db.gsub!(/(cdd|COG|KOG|\/pfam|smart|cd|pfamA|pfamB)(_\S*)/, '\1\2/db/\1.hhm')
#      elsif db.gsub!(/(scop|pdb)([^_]\S*)/, '\1\2/db/\1.hhm')
      elsif db.gsub!(/(scop|pdb)(\S*)/, '\1\2/db/\1.hhm')
      elsif db.gsub!(/(panther|tigrfam|pirsf|supfam|CATH)(_\S*)/, '\1\2/db/\1.hmm')
      elsif db.gsub!(/([^\/]+)$/, '\1/db/\1.hhm' )
      end
      dbs += db+' '
    end
    dbs.strip!

    # Extract names from database directories for echo in log file
    @dbnames = dbs.dup
    @dbnames.gsub!(/\S*\/([^\/]*)\/db\/\S*/, '\1,')
    @dbnames.gsub!(/,\s*$/, '')
    @dbnames.gsub!(/,\s*(\S+)$/, ' and \1 databases')

    @dbs = dbs
  end

  # Prepare FASTA files for 'Show Query Alignemt', HHviz bar graph, and HMM histograms
  def prepare_fasta_hhviz_histograms_etc
    # Reformat query into fasta format ('full' alignment, i.e. 100 maximally diverse sequences, to limit amount of data to transfer)
    @commands << "#{HH}/hhfilter -i #{@basename}.a3m -o #{@local_dir}/#{job.jobid}.reduced.a3m -diff 100"
    @commands << "#{HH}/reformat.pl a3m fas #{@local_dir}/#{job.jobid}.reduced.a3m #{@basename}.fas -d 160 -uc"  # max. 160 chars in description

    # Reformat query into fasta format (reduced alignment)  (Careful: would need 32-bit version to execute on web server!!)
    @commands << "#{HH}/hhfilter -i #{@basename}.a3m -o #{@local_dir}/#{job.jobid}.reduced.a3m -diff 50"
    @commands << "#{HH}/reformat.pl -r a3m fas #{@local_dir}/#{job.jobid}.reduced.a3m #{@basename}.reduced.fas -uc"
    @commands << "rm #{@local_dir}/#{job.jobid}.reduced.a3m"

    # Generate graphical display of hits
    @commands << "#{HH}/hhviz.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} &> /dev/null"

    # Generate profile histograms
    @commands << "#{HH}/profile_logos.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} > /dev/null"
  end

  # Tool can forward to HHpred in different modes, the following modes are possible:
  # 1. :queryhmm  :
  # 2. :hhsenser  :
  # 3. :realign   :
  # 4. nil        :
  def before_perform_on_forward
    pjob = job.parent
    @mode = pjob.params['mode']
    case @mode
    when 'queryhmm'
      @informat = 'fas'
      FileUtils.copy_file("#{pjob.job_dir}/#{pjob.jobid}.a3m", "#{@basename}.a3m")
      FileUtils.copy_file("#{pjob.job_dir}/#{pjob.jobid}.hhm", "#{@basename}.hhm")
    when 'hhsenser'
      @informat = 'a3m'
      FileUtils.copy_file("#{pjob.job_dir}/#{pjob.jobid}.a3m", "#{@basename}.a3m")
    when 'realign'
      FileUtils.copy_file("#{pjob.job_dir}/#{pjob.jobid}.a3m", "#{@basename}.a3m")
      FileUtils.copy_file("#{pjob.job_dir}/#{pjob.jobid}.hhr", "#{@basename}_parent.hhr")
      dbs = pjob.actions.first.params['hhpred_dbs']
      # TODO: update database paths
      params['hhpred_dbs'] = dbs
      self.save!
      @dbs = dbs.join(' ')
      process_databases
    end
  end

  def perform
    params_dump

    if job.parent.nil? || @mode.nil?
      # Create alignment
      # @commands << "#{HH}/buildali.pl -nodssp -cpu 4 -v #{@v} -n #{@maxpsiblastit} -diff 1000 #{@E_psiblast} #{@cov_min} -#{@informat} #{@seqfile} &> #{job.statuslog_path}"
      if @maxhhblitsit == '0'
          @commands << "#{HH}/reformat.pl #{@informat} a3m #{@seqfile} #{@basename}.a3m"
      else
          @commands << "#{HHBLITS}/hhblits -cpu 8 -v 2 -i #{@seqfile} #{@E_hhblits} -db #{HHBLITS_DB} -dbhhm #{HHBLITS_DBHHM} -dba3m #{HHBLITS_DBA3M} -o /dev/null -oa3m #{@basename}.a3m -n #{@maxhhblitsit} -mact 0.5 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
      end

      @commands << "#{HHBLITS}/addss.pl #{@basename}.a3m"

      # Make HMM file
      @commands << "echo 'Making profile HMM from alignment ...' >> #{job.statuslog_path}"
      @commands << "#{HH}/hhmake -v #{@v} #{@cov_min} #{@qid_min} #{@diff} -i #{@basename}.a3m -o #{@basename}.hhm 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    end

    if @mode == 'hhsenser'
      # Trim alignment
      @commands << "#{HH}/buildali.pl -nodssp -cpu 4 -v #{@v} -n 0 -maxres 300 -diff 1000 -#{@informat} #{@basename}.a3m &> #{job.statuslog_path}"
      # Start HHsenser
      @commands << "#{HH}/buildinter.pl -v #{@v} -cpu 4 -Emax 0.1 -e 0.001 -Ey 0.01 -E 0.001 -Ymax 100 -accmax 10 -rejmax 10 -idmax 0 -extnd 20  #{@basename}.a3m &> #{job.statuslog_path}"
      # new command?
      # $command = "$hh/buildinter.pl -v $v -cpu 2 -quick -Emax 0.1 -e 0.001 -Ey 0.01 -E 0.001 -Ymax 100 -idmax 0 -extnd 20  $seqfile &> $basename.log";

      # Copy -Y.a3m file to .a3m file
      @commands << "cp #{@basename}-Y.a3m #{@basename}.a3m"
      # Make HMM file
      @commands << "echo 'Making profile HMM from alignment ...' >> #{job.statuslog_path}"
      @commands << "#{HH}/hhmake -v #{@v} #{@cov_min} #{@qid_min} #{@diff} -i #{@basename}.a3m -o #{@basename}.hhm 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    end

    if @mode == 'realign'

      # Make HMM file
      @commands << "echo 'Making profile HMM from alignment ...' >> #{job.statuslog_path}"
      @commands << "#{HH}/hhmake -v #{@v} #{@cov_min} #{@qid_min} #{@diff} -i #{@basename}.a3m -o #{@basename}.hhm 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"

      # If cov_min is 20 and qid_min is 0, we can realign with hhm files instead of a3m files ($hhrealign_options="-hhm").
      # This speeds up realignment a lot because we don't have to filter all template alignments.
      realign_options = "-hhm"
      if @cov_min != 20 || @qid_min != 0 then realign_options="#{@cov_min} #{@qid_min} #{@diff}" end

      @commands << "#{HH}/hhrealign.pl -v 2 -resort -i #{@basename}_parent.hhr -o #{@basename}.hhr -q #{@basename}.hhm -d #{@dbs_realign} #{realign_options} #{@ss_scoring} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@realign} #{@mact} #{@compbiascorr} 1>> #{job.statuslog_path} 2>&1";
    else

      ####################################################
      ### NO CALIBRATION WITH NEW HHSEARCH VERSION
      #
      #   # Do we need to calibrate query HMM before search?
      #   cal = '-cal'
      #   if @dbs !~ /scop/
      #     cal = ''
      #     @commands << "echo 'Calibrating query HMM ...' >> #{job.statuslog_path}"
      #     @commands << "#{HH}/hhsearch -cpu 4 -v #{@v} -i #{@basename}.hhm -d #{CAL_HHM} -cal -#{@ali_mode} #{@ss_scoring} #{@compbiascorr} -norealign 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
      #   end
      #
      #   # HHsearch with query HMM against HMM database
      #   @commands << "echo 'Searching #{@dbnames} ...' >> #{job.statuslog_path}"
      #   @commands << "#{HH}/hhsearch #{cal} -cpu 4 -v #{@v} -i #{@basename}.hhm -d '#{@dbs}' -o #{@basename}.hhr -p #{@Pmin} -P #{@Pmin} -Z #{@max_lines} -B #{@max_lines} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@ss_scoring} #{@realign} #{@mact} #{@compbiascorr} -dbstrlen 10000 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}; echo 'Finished search'";
      #
      ####################################################

      # HHsearch with query HMM against HMM database
      @commands << "echo 'Searching #{@dbnames} ...' >> #{job.statuslog_path}"
      @commands << "#{HH}/hhsearch -cpu 4 -v #{@v} -i #{@basename}.hhm -d '#{@dbs}' -o #{@basename}.hhr -p #{@Pmin} -P #{@Pmin} -Z #{@max_lines} -B #{@max_lines} -seq #{@max_seqs} -aliw #{@aliwidth} -#{@ali_mode} #{@ss_scoring} #{@realign} #{@mact} #{@compbiascorr} -dbstrlen 10000 -cs #{CSBLAST}/data/clusters.prf 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}; echo 'Finished search'";
    end

    prepare_fasta_hhviz_histograms_etc

    @commands << "#{HH}/hhfilter -i #{@basename}.reduced.fas -o #{@basename}.top.a3m -id 90 -qid 0 -qsc 0 -cov 0 -diff 10 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    @commands << "#{HH}/reformat.pl a3m fas #{@basename}.top.a3m #{@basename}.repseq.fas -uc 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    @commands << "#{HH}/tenrep.rb -i #{@basename}.repseq.fas -h #{@basename}.hhr -p 40 -o #{@basename}.tenrep_file"
    @commands << "#{RUBY_UTILS}/parse_jalview.rb -i #{@basename}.tenrep_file -o #{@basename}.tenrep_file"


    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'cpus' => '3'})
  end

end




