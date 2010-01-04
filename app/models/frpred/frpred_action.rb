class FrpredAction < Action
  FRPRED = File.join(BIOPROGS, 'frpred')
  HH = File.join(BIOPROGS, 'hhpred')
  REFORMAT = File.join(BIOPROGS, 'hhpred', 'reformat.pl')
  
  attr_accessor :sequence_input, :sequence_file, :informat, :inputmode, :mail, :jobid, :minCoverage, :minIdentity
  attr_accessor :pdb_chain

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => :inputmode,
                                                    :max_seqs => 1000,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_format_of(:pdb_chain, {:on => :create, :with => /^\s*[A-Z123]?\s*$/, :message => 'Identifier must be a character in upper case.'})
  
  validates_shell_params(:jobid, :mail, :minCoverage, :minIdentity, :pdb_chain, {:on => :create})
  
  validates_int_into_list(:minCoverage, :minIdentity, {:on => :create, :in => 0..100,
  																		 :message => 'should be between 0 and 100'})
  
  
  def before_perform
    
    if (params['pdb_check']) 
      filename = File.join(job.job_dir, 'pdb_file')
      File.open(filename, "w") do |f|
        f.write(params['parent_pdb'])
      end
      params['pdb_file'] = filename
      params['pdb_chain'] = params['parent_chain']
      params['parent_pdb'] = ""
    end    
    
    init
    
    @infile = @basename+".fasta"    
    @outfile = @basename+".out"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    
    # has manual subgroups?
    @manual_subgroups = false
    if (@informat == "gfas")
      res = IO.readlines(@infile)
      res.each do |line|
        if (line =~ /^#/)
          @manual_subgroups = true
          break
        end
      end
      # create group fasta file without # ????    
    else
      reformat(@informat, "fas", @infile)
    end

  end
  
  def init
    
    @basename = File.join(job.job_dir, job.jobid)
    @workdir  = job.job_dir
    @jobID    = job.jobid
    @commands = []
    
    @inputmode = params['inputmode']
    @pdb_file = params['pdb_file']
#    @solv_acc = params['solv_acc'] ? true : false
    @moreHomologs = params['moreHomologs'] == "true" ? 'T' : 'F'
    @maxpsiblastit = params['maxpsiblastit']
    @E_psiblast = params['epsiblastval']
    @cov_min = params['minCoverage'] ? params['minCoverage'] : '85'
    @qid_min = params['minIdentity'] ? params['minIdentity'] : '15'                
    @seqcentered = params['seqCentered'] ? '1' : '2' 
    @pdb_chain = params['pdb_chain'] ? 'chain=' + params['pdb_chain'] : ''
#    @matrix = params['matrix']
#    @sopcons = "y"
    @catRes = 'n'
    
    @pdb = false
    if (@pdb_file && File.exists?(@pdb_file) && File.readable?(@pdb_file) && !File.zero?(@pdb_file))
      @pdb = true
    end
    logger.debug "PDB: #{@pdb}"
    
  end
  
  def perform
    params_dump
    
    if (@pdb)
      @commands << "#{FRPRED}/DSSP/dsspcmbi #{@pdb_file} #{@pdb_file}.dssp"
    end

    tmp = "echo 'Running sable on query sequnece with 3 PSI-BLAST iterations' >> #{job.statuslog_path}"
    tmp += "; #{FRPRED}/perl/FRpred_sable.pl -f #{@infile} -o #{@basename} -b #{BIOPROGS} "
    @commands << tmp
    
    # exec buildali if input is only one sequence
    if (@inputmode == 'sequence')
      tmp = "echo 'Get more homologs kickstarting PSI-BLAST' >> #{job.statuslog_path}"
      tmp += "; #{FRPRED}/perl/myBuildali.pl #{@infile} -noss -N 500 -cpu 2 -n #{@maxpsiblastit} -e #{@E_psiblast} -cov #{@cov_min} -qid #{@qid_min} -fas &> #{job.statuslog_path}.buildali"
      
      tmp += "; #{REFORMAT} a3m fas #{@basename}.a3m #{@infile} -r &> #{job.statuslog_path}.reformat"
      tmp += "; #{FRPRED}/perl/runPsipred.pl #{@basename} #{BIOPROGS}"
		@commands << tmp
    else 
    	@commands << "#{FRPRED}/perl/runPsipred.pl #{@basename} #{BIOPROGS}"
    end

    @hash = {}
    @hash['infile'] = @infile
    @hash['manual_subgroups'] = @manual_subgroups
		
    self.flash = @hash
    self.save!
    
    logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'run_methods'
    q.save!
    q.submit_parallel(@commands, false)
    
  end
  
  def run_methods
  
    logger.debug "################# Run methods! ##########################"
    
    init
    @infile = flash['infile']
    @manual_subgroups = flash['manual_subgroups']

    # check for only one sequence
    num_seqs = 0
    res = IO.readlines(@infile).map {|line| line.chomp}
    res.each do |line|
      if (line =~ /^>/)
        num_seqs += 1
      end
    end
    if (num_seqs < 2)
      system("echo \"\nERROR! No homologs found!\" >> #{job.statuslog_path}")
      self.status = STATUS_ERROR
      self.save
      job.update_status
      exit
    end

    @in_f = @infile.gsub(/^\S+\/(\S+.\S+)$/,'\1')
    @pdb_f = nil
    if @pdb
      @pdb_f = @pdb_file.gsub(/^\S+\/(pdb_file)$/,'\1')
    end
    @sab=" sable=#{@jobID}.sable psi=#{@jobID}.ss2"

    # method 1 (lig = 1 / cat = 7)

     if (!@pdb)
       @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} score=1#{@sab} catRes=#{@catRes} toolkit=y win=y seqCentered=0 cons=new scoreOutFile=#{@jobID}.1_scores fastaOutFile=#{@jobID}.fastaOut1 bench=lig 1>> #{job.statuslog_path} 2>&1"
       @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} score=1#{@sab} catRes=#{@catRes} toolkit=y win=y seqCentered=0 cons=new scoreOutFile=#{@jobID}.7_scores fastaOutFile=#{@jobID}.fastaOut7 bench=cat 1>> #{job.statuslog_path} 2>&1"
     else
       @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} pdbFile=#{@pdb_f} #{@pdb_chain} score=1#{@sab}  win=y catRes=#{@catRes} toolkit=y seqCentered=0 cons=new pdbScriptFile=#{@jobID}.1_rasmol scoreOutFile=#{@jobID}.1_scores fastaOutFile=#{@jobID}.fastaOut1 bench=lig 2>> #{job.statuslog_path}"
       @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} pdbFile=#{@pdb_f} #{@pdb_chain} score=1#{@sab}  win=y catRes=#{@catRes} toolkit=y seqCentered=0 cons=new pdbScriptFile=#{@jobID}.7_rasmol scoreOutFile=#{@jobID}.7_scores fastaOutFile=#{@jobID}.fastaOut7 bench=cat 2>> #{job.statuslog_path}"

     end
    
    
    #method 2
    
    if (!@pdb)
      @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} score=2#{@sab} catRes=#{@catRes} toolkit=y win=y seqCentered=0 cons=new scoreOutFile=#{@jobID}.2_scores fastaOutFile=#{@jobID}.fastaOut2 1>> #{job.statuslog_path} 2>&1"
     else
      @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} pdbFile=#{@pdb_f} #{@pdb_chain} score=2#{@sab}  win=y catRes=#{@catRes} toolkit=y seqCentered=0 cons=new pdbScriptFile=#{@jobID}.2_rasmol scoreOutFile=#{@jobID}.2_scores fastaOutFile=#{@jobID}.fastaOut2 2>> #{job.statuslog_path}"
     end


    #method 5,7 / 6,8

    if @manual_subgroups
      
      if(!@pdb)
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f}  score=5#{@sab} catRes=#{@catRes} toolkit=y seqCentered=#{@seqcentered} cons=new scoreOutFile=#{@jobID}.5_scores fastaOutFile=#{@jobID}.fastaOut5 1>> #{job.statuslog_path} 2>&1"
      else
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} pdbFile=#{@pdb_f} #{@pdb_chain}  score=5#{@sab} catRes=#{@catRes} toolkit=y seqCentered=#{@seqcentered} cons=new pdbScriptFile=#{@jobID}.5_rasmol scoreOutFile=#{@jobID}.5_scores fastaOutFile=#{@jobID}.fastaOut5 1>> #{job.statuslog_path} 2>&1"
      end
      
      if(!@pdb)
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f}  score=7#{@sab} catRes=n toolkit=y seqCentered=0 cons=new scoreOutFile=#{@jobID}.6_scores fastaOutFile=#{@jobID}.fastaOut6 1>> #{job.statuslog_path} 2>&1"
      else
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} pdbFile=#{@pdb_f} #{@pdb_chain}  score=7#{@sab} catRes=n toolkit=y seqCentered=0 cons=new pdbScriptFile=#{@jobID}.6_rasmol scoreOutFile=#{@jobID}.6_scores fastaOutFile=#{@jobID}.fastaOut6 1>> #{job.statuslog_path} 2>&1"
      end
      
    else
    
      if(!@pdb)
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f}  score=6#{@sab} catRes=#{@catRes} toolkit=y seqCentered=#{@seqcentered} cons=new scoreOutFile=#{@jobID}.5_scores fastaOutFile=#{@jobID}.fastaOut5 1>> #{job.statuslog_path} 2>&1"
      else
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} pdbFile=#{@pdb_f} #{@pdb_chain} score=6#{@sab} catRes=#{@catRes} toolkit=y seqCentered=#{@seqcentered} cons=new pdbScriptFile=#{@jobID}.5_rasmol scoreOutFile=#{@jobID}.5_scores fastaOutFile=#{@jobID}.fastaOut5 1>> #{job.statuslog_path} 2>&1"
      end
      
      if(!@pdb)
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} score=8#{@sab} catRes=n toolkit=y seqCentered=0 cons=new scoreOutFile=#{@jobID}.6_scores fastaOutFile=#{@jobID}.fastaOut6 1>> #{job.statuslog_path} 2>&1"
      else
        @commands << "#{JAVA_1_5_EXEC} -Xms16M -Xmx2G -server -cp #{FRPRED} formatIO.Main workDir=#{@workdir} fastaFile=#{@in_f} pdbFile=#{@pdb_f} #{@pdb_chain} score=8#{@sab} catRes=n toolkit=y seqCentered=0 cons=new pdbScriptFile=#{@jobID}.6_rasmol scoreOutFile=#{@jobID}.6_scores fastaOutFile=#{@jobID}.fastaOut6 1>> #{job.statuslog_path} 2>&1"
      end
      
    end    
    
        
    logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'compute_html_pages'
    q.save!
    q.submit_parallel(@commands, false)
  
  end
  
  
  def compute_html_pages
    
    logger.debug "################# Compute html pages! ##########################"

    init
    @manual_subgroups = flash['manual_subgroups']

    grouped = "N"
	 if @manual_subgroups
	   grouped = "T"
	 end
	 	      
    ['1', '2', '5', '6', '7'].each do |i|
      @commands << "#{FRPRED}/perl/FRpredCreateResultPages.pl #{@basename} #{i} #{grouped} #{File.join(@job.url_for_job_dir, @job.jobid)}"
    end
      
    
    @commands << "#{FRPRED}/perl/FRpredResultsOV.pl #{@basename}"
    if (@pdb)
		@commands << "echo 'PDB=true' >> #{job.statuslog_path}; #{FRPRED}/perl/FRpredResultsJmol.pl #{job.url_for_job_dir_abs}/pdb_file #{@basename}"
    else
		@commands << "echo 'PDB=false' >> #{job.statuslog_path}"	
    end
        
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit_parallel(@commands)
  
  end
  
end
