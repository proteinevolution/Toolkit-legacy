class ClansAction < Action

  CLANS = File.join(BIOPROGS, 'clans')
  BLAST = File.join(BIOPROGS, 'blast')

  include GenomesModule
   
  # top down: protblast/index.rhtml
  attr_accessor :sequence_input, :sequence_file, :std_dbs, :user_dbs, :taxids, 
                :evalue, :numiterations, :evaluefirst
  # shared/joboptions.rhtml
  attr_accessor :jobid, :mail 

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
                                                    :inputmode => 'sequences',
                                                    :min_seqs => 2,
                                                    :max_seqs => 2000,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_db(:std_dbs, {:personal_dbs => :user_dbs, :genomes_dbs => :taxids, :on => :create})
  
  validates_format_of(:evalue, :evaluefirst, {:with => /^\d+(e|e-|\.)?\d+$/, :on => :create})
  
  validates_format_of(:numiterations, {:with => /^\d+$/, :on => :create})
  
  validates_shell_params(:jobid, :mail, :evalue, :numiterations, :evaluefirst, {:on=>:create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"
    @outfile = @basename+".nxnblast"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @searchtool         = params['searchtool']
    @evalue             = params['evalue']
    @evaluefirst        = params['evaluefirst']
    @numiterations      = params['numiterations']
    @matrix             = params['matrix']
    @ungappedalignment  = params['ungappedalign'] ? 'F' : 'T'
    @filter             = params['filter'] ? 'T' : 'F'

    @db_path            = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    # getDBs is part of the GenomesModule
    gdbs = getDBs('pep')
    logger.debug("SELECTED GENOME DBS\n")
    logger.debug gdbs.join("\n")
    @db_path += ' ' + gdbs.join(' ')
    
    # set gapopen and gapextend costs depending on given matrix
    @gapopen = 11
    @gapext = 1
    if (@matrix =~ /BLOSUM80/i || @matrix =~ /PAM70/i) then @gapopen = 10 end
    if (@matrix =~ /PAM30/i) then @gapopen = 9 end
    if (@matrix =~ /BLOSUM45/i) 
      @gapopen = 15
      @gapext = 2
    end 
    
  end

  def perform
    params_dump
    
    #get number of sequences in order to calculate -b and -v values
    descriptions = 0
    res = IO.readlines(@infile)
    res.each do |line|
    	if (line =~ /^>/) then descriptions += 1 end
    end
    descriptions *= 2
    
    @blastcommand = ""
    if (@searchtool == "blastp")
      @blastcommand = "#{BLAST}/blastall -p #{@searchtool} -e #{@evalue} -F #{@filter} -M #{@matrix} -G #{@gapopen} -E #{@gapext} -g #{@ungappedalignment} -v #{descriptions} -b #{descriptions} -T T -I T "
    else
      @blastcommand = "#{BLAST}/blastpgp -e #{@evalue} -F #{@filter} -M #{@matrix} -G #{@gapopen} -E #{@gapext} -v #{descriptions} -b #{descriptions} -T T -I T -h #{@evaluefirst} -j #{@numiterations}"
    end
    
    #now create the nxnblast command
    @commands << "#{JAVA_1_5_EXEC} -Xmx8G -jar #{CLANS}/allblast.jar -infile #{@infile} -blastpath \"#{@blastcommand}\" -formatdbpath #{BLAST}/formatdb -referencedb \"#{@db_path}\" -eval #{@evalue} -saveblast #{@outfile} -tmpdir #{job.job_dir}/ > #{job.statuslog_path} 2> /dev/null"
    #now bin the values
    @commands << "#{JAVA_1_5_EXEC} -Xmx8G -jar #{CLANS}/plotblast.jar -i #{@outfile} -o #{@basename} 2>&1 1>> #{job.statuslog_path}"


    logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'createImage'
    q.save!
    q.submit(@commands, false)

  end
  
  def createImage
    @basename = File.join(job.job_dir, job.jobid)
    @pvalfile = @basename + "_pplot"
    res = IO.readlines(@pvalfile)
    
    max_num = 0.0
    res.each do |line|
      if (line =~ /(\S+)\s+\d+/)
      	num = $1.to_f
      	max_num = (max_num < num) ? num : max_num      
      end
    end
    
    @outfile      = @basename + "_gnuplot"
    @coveragefile = @basename + "_cplot"
    @identfile    = @basename + "_iplot"
    @pngfile      = @basename + ".png"

    out = File.new(@outfile, "w+")
    out.write("set term png size 700,400\n")
    out.write("set output '#{@pngfile}'\n")
    out.write("set xlabel \"-log(P-value)\"\n")
    out.write("set ylabel \"Fraction of HSPs below P-value &\\n average HSP coverage & identity at P-value\"\n")
    out.write("set key bottom\n")
    out.write("plot [0:#{max_num}] '#{@pvalfile}' with line title \"HSP fraction\", '#{@coveragefile}' with line title \"Avg. coverage\", '#{@identfile}' with line title \"Avg. identity\"\n")
    out.write("q\n")
    out.close
    
    @commands = ["gnuplot #{@outfile}"]
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'cpus' => '3'})
        
  end
    
end
