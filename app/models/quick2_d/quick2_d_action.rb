class Quick2DAction < Action
  #constants
  REFORMAT    = File.join(BIOPROGS, 'perl', 'reformat.pl')
  BUILDALI    = File.join(BIOPROGS, 'hhpred', 'buildali.pl')
  BLASTPGP    = File.join(BIOPROGS, 'blast', 'blastpgp')
  DIFFSEQS    = File.join(BIOPROGS, 'ruby', 'getDiffSequences.rb')
  PSIPRED     = File.join(BIOPROGS, 'ruby', 'psipred.rb')
  JNET        = File.join(BIOPROGS, 'ruby', 'jnet.rb')
  MEMSAT      = File.join(BIOPROGS, 'ruby', 'memsat.rb')
  DISOPRED    = File.join(BIOPROGS, 'ruby', 'disopred.rb')
  HMMTOP      = File.join(BIOPROGS, 'hmmtop2.1', 'hmmtop')
  HMMTOPARCH  = File.join(BIOPROGS, 'hmmtop2.1', 'hmmtop.arch')
  HMMTOPPSV   = File.join(BIOPROGS, 'hmmtop2.1', 'hmmtop.psv')
  PROFOUALIDIR = File.join(BIOPROGS, 'ProfOuali', 'src')
  PROFOUALI    = File.join(PROFOUALIDIR, 'Prof')
  NCOILSDIR   = File.join(BIOPROGS, 'coils')
  NCOILS      = File.join(NCOILSDIR, 'ncoils-linux')
  PROFROST    = File.join(BIOPROGS, 'ruby', 'profRost.rb')
  VSL2        = JAVA_1_5_EXEC+" -jar "+File.join(BIOPROGS, 'VSL2', 'VSL2.jar')
  DUMMYDB     = File.join(DATABASES, 'do_not_delete', 'do_not_delete')

  #Validation
  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat,
                                                     :informat => 'fas',
                                                     :inputmode => 'alignment',
                                                     :max_seqs => 5000,
                                                     :max_length => 1000,
                                                     :on => :create })

  validates_jobid(:jobid)

  validates_email(:mail)


  # Put action initialisation code in here
  def before_perform
  end

  def init_vars
    @psiblast    = params['psiblast_chk']  ? true : false
    @psipred     = params['psipred_chk']   ? true : false
    @jnet        = params['jnet_chk']      ? true : false
    @coils       = params['coils_chk']     ? true : false
    @profouali   = params['profouali_chk'] ? true : false
    @profrost    = params['profrost_chk']  ? true : false
    @memsat      = params['memsat2_chk']   ? true : false
    @hmmtop      = params['hmmtop_chk']    ? true : false
    @disopred    = params['disopred2_chk'] ? true : false
    @vsl2        = params['vsl2_chk']      ? true : false
    @informat    = params['informat']
    logger.debug("Format: "+@informat+"\n")
  end

  # Optional:
  # Put action initialization code that should be executed on forward here
  # def before_perform_on_forward
  # end


  # Put action code in here
  def perform
    mem = {}
    basename            = File.join(job.job_dir, job.jobid)
    mem['basename']     = basename
    mem['logfile']      = File.join(job.job_dir, "status.log")
    mem['infile']       = basename+".in"
    mem['fasfile']      = basename+".fas"
    mem['psifile']      = basename+".psi"
    mem['queryfile']    = basename+".query"
    mem['seqfile']      = basename+".seq"
    mem['clufile']      = basename+".clu"
    mem['a3mfile']      = basename+".a3m"
    mem['chkfile']      = basename+".chk"
    mem['matrixfile']   = basename+".matrx"
    mem['alnfasfile']   = basename+".afas"
    mem['buildalilog']  = basename+".balilog"
    mem['psiblog']      = basename+".pblog"
    mem['psipredfile']  = basename+".psipred"
    mem['ss2file']      = basename+".ss2"
    mem['jnetfile']     = basename+".jnet"
    mem['memsatfile']   = basename+".memsat2"
    mem['hmmtopfile']   = basename+".hmmtop"
    mem['profoualifile']= basename+".profouali"
    mem['coilsfile']    = basename+".coils"
    mem['accfile']      = basename+".acc"
    mem['htmfile']      = basename+".htm"
    mem['secfile']      = basename+".sec"
    mem['vsl2file']     = basename+".vsl2"
    mem['disopredfile'] = basename+".horiz_d"
    mem['headerfile']   = basename+".header"
    self.flash = mem
    self.save!
    params_to_file( flash['infile'], 'sequence_input', 'sequence_file' )

    init_vars
    reformat(@informat,"fas", flash['infile'], flash['fasfile'])
    if @informat == "a3m"
      system("cp #{flash['infile']} #{flash['a3mfile']}")
    end
    logger.debug("Vor prepareFiles!")
    prepareFiles
  end

  # creates files that are used by the prediction programs
  # psifile - only created if the user provides an alignment and the 'Do PSI-BLAST Search' checkbox is enabled
  # queryfile - the sequence in this file is displayed on the results-page
  def prepareFiles
    flash['seqCount'] = countFastaSeqs(flash['fasfile'])

    createQueryAndHeaderFile(flash['fasfile'], flash['queryfile'],flash['headerfile'])
    createSeqFile(flash['fasfile'], flash['seqfile'])

    commands = []
    if @psiblast
      commands << "echo 'Running PSI-BLAST [buildali] ' >> #{flash['logfile']}"
      commands << "#{BUILDALI} -v5 -diff 200 -noss -n 2 -fas #{flash['fasfile']} &> #{flash['buildalilog']}"

      commands << "echo 'Reducing alignment...' >> #{flash['logfile']}"
      commands << "#{DIFFSEQS} #{flash['a3mfile']} #{flash['a3mfile']} 200 &> #{flash['buildalilog']}"

      commands << "echo 'Reformat a3m to aln fasta' >> #{flash['logfile']}"
      commands << "#{REFORMAT} -i=a3m -o=fas -f=#{flash['a3mfile']} -a=#{flash['alnfasfile']}"
    elsif flash['seqCount']==1
      system "echo 'Cloning input sequence' >> #{flash['logfile']}"
      replicateSeq(flash['queryfile'], flash['alnfasfile'])
    else
      # input file is an alignment
      system "echo 'Inputfile is an alignment.' >> #{flash['logfile']}"
      if( flash['seqCount']>200 )
        commands << "echo 'There are more than 200 sequences!' >> #{flash['logfile']}"
        commands << "echo 'Reducing alignment...' >> #{flash['logfile']}"
        if !File.exist?(flash['a3mfile'])
          commands << "#{REFORMAT} -i=fas -o=a3m -f=#{flash['fasfile']} -a=#{flash['a3mfile']} -M first"
	end
	commands << "#{DIFFSEQS} #{flash['a3mfile']} #{flash['a3mfile']} 200 &> #{flash['buildalilog']}"
	commands << "#{REFORMAT} -i=a3m -o=fas -f=#{flash['a3mfile']} -a=#{flash['fasfile']}"
      end
      flash['alnfasfile'] = flash['fasfile']
    end

    commands << "echo 'Reformat aln to clu' >> #{flash['logfile']}"
    commands << "#{REFORMAT} -i=fas -o=clu -f=#{flash['alnfasfile']} -a=#{flash['clufile']}"
    commands << "echo 'Reformat aln to psi' >> #{flash['logfile']}"
    commands << "#{REFORMAT} -i=fas -o=psi -f=#{flash['alnfasfile']} -a=#{flash['psifile']}"
    commands << "echo 'Create checkpoint-file and ASCII-matrix-file' >> #{flash['logfile']}"
    commands << "#{BLASTPGP} -b 0 -j 1 -h 0.001 -d #{DUMMYDB} -i #{flash['queryfile']} -B #{flash['psifile']} -C #{flash['chkfile']} -Q #{flash['matrixfile']} &> #{flash['psiblog']}"

    q = queue
    q.on_done = 'doPredictions'
    q.save!
    q.submit(commands, false)
    self.save!
  end

  def doPredictions
    init_vars
    commands = []
    if( @psipred )  then commands << "echo 'Running PSIPRED' >> #{flash['logfile']}; #{PSIPRED} #{flash['queryfile']} #{flash['chkfile']} #{flash['psipredfile']}" end
    if( @jnet )     then commands << "echo 'Running JNET' >> #{flash['logfile']}; #{JNET} #{flash['clufile']} #{flash['matrixfile']} #{flash['jnetfile']}" end
    if( @memsat )   then commands << "echo 'Running MEMSAT' >> #{flash['logfile']}; #{MEMSAT} #{flash['queryfile']} #{flash['memsatfile']}" end
    if( @disopred ) then commands << "echo 'Running DISOPRED2' >> #{flash['logfile']}; #{DISOPRED} #{flash['queryfile']}" end
    if( @hmmtop )   then commands << "echo 'Running HMMTOP2.1' >> #{flash['logfile']}; export HMMTOP_ARCH=#{HMMTOPARCH}; export HMMTOP_PSV=#{HMMTOPPSV}; #{HMMTOP} -pi=mpred -pl -sf=FAS -if=#{flash['alnfasfile']} > #{flash['hmmtopfile']}" end
    if( @profouali )then commands << "echo 'Running PROFOUALI' >> #{flash['logfile']}; export PROF_DIR=#{PROFOUALIDIR}; #{PROFOUALI} -d -c -v -m 1 -a #{flash['clufile']} -p #{flash['matrixfile']} -o #{flash['profoualifile']}; echo 'Hide exitstate !=0 by this echo cmd'" end
    if( @coils )    then commands <<	"echo 'Running NCOILS' >> #{flash['logfile']}; export COILSDIR=#{NCOILSDIR}; #{NCOILS} -f < #{flash['queryfile']} > #{flash['coilsfile']}" end
    if( @profrost ) then commands <<	"echo 'Running PROFROST' >> #{flash['logfile']}; #{PROFROST} #{flash['queryfile']} #{flash['accfile']} #{flash['htmfile']} #{flash['secfile']}" end

    # vsl2 does better prediction with psipred results therefore execute vsl2 in a subsequent task if psipredresults are available
    if( !@psipred )
      if( @vsl2 )  then commands <<	"echo 'Running VSL2' >> #{flash['logfile']}; #{VSL2} -s:#{flash['seqfile']} -p:#{flash['matrixfile']} > #{flash['vsl2file']}" end
	queue.submit_parallel(commands)
      else
        logger.debug( "doPredictions:\n"+commands.join("\n"))
	q = queue
	q.on_done = 'doFinal'
	q.save!
	q.submit_parallel(commands, false)
	self.save!
      end

  end

  def doFinal
    init_vars
    commands = []
    logger.debug( "doFinal:\n"+commands.join("\n"))
    if( @vsl2 )  then commands <<	"echo 'Running VSL2' >> #{flash['logfile']}; #{VSL2} -s:#{flash['seqfile']} -i:#{flash['ss2file']} -p:#{flash['matrixfile']} > #{flash['vsl2file']}" end
    queue.submit(commands)
  end

  # returns the number of sequences in a fasta file
  def countFastaSeqs(fasfile)
    ar    = IO.readlines(fasfile)
    count = 0
    ar.each do |line|
      if line =~ /^>/ then count+=1 end
    end
    count
  end


  # creates a new fasta file with the first sequence of the input file with gaps removed
  def createQueryAndHeaderFile(fasfile, queryfile, headerfile)
    ar    = IO.readlines(fasfile)
    head = nil
    seq  = ""
    ar.each do |line|
      if line =~ /^>/
        logger.debug(line)
        (head.nil?) ? head=line : break
      else
        seq += line
      end
    end
    seq.gsub!(/-/, "")
    seq.gsub!(/\*/, "")
    seq.gsub!(/\s+/, "")
    logger.debug("Query: "+head+seq)
    head_blanc = head.gsub(/[^A-Za-z0-9_>]/," ")
    logger.debug("HEADER (only 'word' chars)): "+head_blanc)

    File.open(queryfile,"w") do |file|
      file.write(head_blanc+"\n")
      file.write(seq+"\n")
    end
    File.open(headerfile,"w") do |file|
      file.write(head)
    end
  end

  # creates a new file with the first sequence of the input file
  def createSeqFile(fasfile, seqfile)
    ar    = IO.readlines(fasfile)
    head = nil
    seq  = ""
    ar.each do |line|
      if line =~ /^>/
        logger.debug(line)
	(head.nil?) ? head=line : break
      else
        seq += line
      end
    end
    seq.gsub!(/-/, "")
    seq.gsub!(/\*/, "")
    seq.gsub!(/\s+/, "")
    logger.debug("Query: "+head+seq)
    File.open(seqfile,"w") do |file|
      file.write(seq)
    end
  end

  # used for input files with one sequence and if the user did not check the Do-PSIBLAST box
  # clone input sequence 3 times, used for the generation of profiles from an alignment
  # - in this case a pseudo alignment to exclude database influence
  def replicateSeq(file, repfile)
    ar = IO.readlines(file)
    logger.error("No data in #{ar}\n") if ar.size==0
    ar[ar.size-1] = ar[ar.size-1]+"\n" if !ar.last.ends_with?("\n")
    ar = ar.join
    File.open(repfile,"w") do |file|
      file.write(ar)
      file.write(ar)
      file.write(ar)
      file.write(ar)
      file.write(ar)
    end
  end

end


