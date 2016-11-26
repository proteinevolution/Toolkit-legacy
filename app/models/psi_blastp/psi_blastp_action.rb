require 'ftools'

class PsiBlastpAction < Action
  BLAST = File.join(BIOPROGS, 'blast')
  BLASTP = File.join(BIOPROGS, 'blastplus/bin')
  RUBY_UTILS = File.join(BIOPROGS, 'ruby')
  REFORMAT = File.join(BIOPROGS,'reformat')
  HELPER = File.join(BIOPROGS, "helper")

  if LOCATION == "Munich" && LINUX == 'SL6'
    UTILS = "perl "+File.join(BIOPROGS, 'perl')
  else
     UTILS = File.join(BIOPROGS, 'perl')
  end

  include GenomesModule

  attr_accessor :jobid, :rounds, :evalue, :evalfirstit, :alignments, :informat, :inputmode,
                :sequence_input, :sequence_file, :mail, :otheradvanced, :std_dbs, :user_dbs, :taxids

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => :inputmode,
                                                    :max_seqs => 9999,
                                                    :on => :create })

  validates_jobid(:jobid)

  validates_email(:mail)

  validates_db(:std_dbs, {:personal_dbs => :user_dbs, :genomes_dbs => 'taxids', :on => :create})

  validates_shell_params(:jobid, :mail, :evalue, :evalfirstit, :alignments, :rounds, :otheradvanced,
                         {:on => :create})

  validates_format_of(:evalue, :evalfirstit, {:with => /(^\d+\.?\d*(e|e-|E|E-|\.)?\d+$)|(^\d+$)/, 
                                              :on => :create,
                                              :message => 'Invalid value!' })

  validates_format_of(:alignments, :rounds, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"    
    @outfile = @basename+".psiblastp"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)
	File.copy(@infile, @basename+".in")	# necessary for resubmitting domains via slider
    @commands = []
    
    @inputmode = params['inputmode']
    @expect = params['evalue']
    @mat_param = params['matrix']
    @ungapped_alignment = params['ungappedalign'] ? 'F' : 'T'
    @other_advanced = params['otheradvanced']
    @descriptions = params['alignments']
    @e_thresh = params['evalfirstit']
    @smith_wat = params['smithwat'] ? ' -use_sw_tback' : ''
    @rounds = params['rounds']
    @filter = params['filter'] ? 'yes' : 'no'
    @fastmode = params['fastmode'] ? 'T' : 'F'
    @query = " -query " + @infile
    @alignment = ""
    @db_path = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    # getDBs is part of the GenomesModule
    gdbs = getDBs('pep')
    logger.debug gdbs.join('\n')
    @db_path += ' ' + gdbs.join(' ')    
    
    File.open(@basename + ".psiblastp_conf", "w") do |file|
      file.write(@e_thresh)
    end
    system("chmod 777 #{@basename}.psiblastp_conf")
    
    # write db-list in pal file
    if (!gdbs.empty?)
      File.open(@basename + "_dblist.pal", "w") do |file|
        file.write("#\nTITLE Genome databases\n#\nDBLIST ")
        file.write(@db_path);
        file.write("\n")
      end
      system("chmod 777 #{@basename}_dblist.pal")
      @db_path = "#{@basename}_dblist"
    end

    if (@inputmode == "alignment") then process_alignment end
    
    # set gapopen and gapextend costs depending on given matrix
    @gapopen = 11
    @gapext = 1
    if (@mat_param =~ /BLOSUM80/i || @mat_param =~ /PAM70/i) then @gapopen = 10 end
    if (@mat_param =~ /PAM30/i) then @gapopen = 9 end
    if (@mat_param =~ /BLOSUM45/i) 
      @gapopen = 15
      @gapext = 2
    end
 
  end

  def process_alignment
    @query = "" # parameters -query and -in_msa are incompatible
    @alignment = " -in_msa #{@basename}.aln"
    
    @content = IO.readlines(@infile).map {|line| line.chomp}
    
    @names = []
    @seqs = []
    
    #check alignment for gap-only columns
    remove_inserts
    
    #write query-file
    File.open(@infile, "w") do |file|
      file.write(">#{@names[0]}\n")
      file.write("#{@seqs[0]}\n")
    end
    
    #write aln-file
    File.open(@basename + ".aln", "w") do |file|
      @names.each_index do |num|
        file.write("Sequence#{num}         ")
        file.write(" ") if (num < 10)
        file.write(" ") if (num < 100)
        file.write("#{@seqs[num]}\n")
      end
    end
  end
  
  def remove_inserts

    currseq = ""
    currname = ""
      
    @content.each do |line|
      if (line =~ /^>(.*)/)
        if (currseq.length > 0)
          @names << currname
          @seqs << currseq
        end
        currname = $1
        currseq = ""
      else
        currseq += line
      end 
    end  
    if (currseq.length > 0)
      @names << currname
      @seqs << currseq
    end
    
    match_cols = []
    
    # Determine which columns have a gap in first sequence (match_cols = false)
    residues = @seqs[0].unpack("C*")
    residues.each_index do |num|
      if (residues[num] == 45 || residues[num] == 46)
        match_cols[num] = false
      else
        match_cols[num] = true
      end
    end
  
    # Delete insert columns
    @names.each_index do |i|
      residues = @seqs[i].unpack("C*")
      seq = ""
      residues.each_index do |num|
        if (match_cols[num])
          if (residues[num] == 45 || residues[num] == 46)
            seq += "-"
          else
            seq += residues[num].chr
          end  
        end   
      end
      seq.tr!('^a-zA-Z-','')
      @seqs[i] = seq.upcase
      if (@seqs[i].length != @seqs[0].length)
        logger.debug "ERROR! Sequences in alignment do not all have equal length!"
      end
    end
  end

  def perform
    params_dump
    @commands << "source #{SETENV}"
    # use nr70f for all but last round?
    # replaced nr70f by nr70 in Tuebingen
    if (@rounds.to_i > 1 && @fastmode == 'T')
      # first run with nr70
      @commands << "echo 'Starting  BLAST+ search, Round 1 with nr70' &> #{job.statuslog_path}"
      #@commands << "#{BLAST}/blastpgp -a 4 -i #{@infile} -F #{@filter} -h #{@e_thresh} -s #{@smith_wat} -e #{@expect} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -j #{@rounds} -m 0 -v #{@descriptions} -b #{@descriptions} -T T -o #{@basename}.psiblastp_tmp -d #{DATABASES}/standard/nr70 #{@alignment} -I T -C #{@basename}.ksf #{@other_advanced}  >> #{job.statuslog_path}"
      # The following command gives the following warning:
      #  Warning: Composition-based score adjustment conditioned on sequence properties and unconditional composition-based score adjustment is not supported with PSSMs, resetting to default value of standard composition-based statistics
      @commands << "#{BLASTP}/psiblast -db #{DATABASES}/standard/nr70@{@query} -matrix #{@mat_param} -num_iterations #{@rounds} -evalue #{@expect} -gapopen #{@gapopen} -gapextend #{@gapext} -num_threads 4 -inclusion_ethresh #{@e_thresh} -num_descriptions #{@descriptions} -num_alignments #{@descriptions} -out #{@basename}.psiblastp_tmp#{@alignment} -outfmt 0 -html -show_gis#{@smith_wat} -seg #{@filter} -out_pssm #{@basename}.ksf #{@other_advanced} >> #{job.statuslog_path}"
      #@commands << "#{BLAST}/blastpgp -a 4 -i #{@infile} -F #{@filter} -h #{@e_thresh} -s #{@smith_wat} -e #{@expect} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -j 1 -m 0          -v #{@descriptions} -b #{@descriptions} -T T -o #{@outfile} -d \"#{@db_path}\" -R #{@basename}.ksf #{@other_advanced} >> #{job.statuslog_path}"
      ## direct "translation" did not work:
      ## Error: Argument "query". Incompatible with argument:  `in_pssm'
      ## legacy_blast gives the following error instead:
      ## ERROR: recovery from C toolkit checkpoint file format not supported
      # Trying without -query parameter
      @commands << "#{BLASTP}/psiblast -db \"#{@db_path}\" -matrix #{@mat_param} -num_iterations 1 -evalue #{@expect} -gapopen #{@gapopen} -gapextend #{@gapext} -num_threads 4 -inclusion_ethresh #{@e_thresh} -num_descriptions #{@descriptions} -num_alignments #{@descriptions} -out #{@outfile} -outfmt 0 -html -show_gis#{@smith_wat} -seg #{@filter} -in_pssm #{@basename}.ksf #{@other_advanced} >> #{job.statuslog_path}"
    else
      @commands << "echo 'Starting BLAST+ search' &> #{job.statuslog_path}"
#      @commands << "#{BLAST}/blastpgp -a 4 -i #{@infile} -F #{@filter} -h #{@e_thresh} -s #{@smith_wat} -e #{@expect} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -j #{@rounds} -m 0 -v #{@descriptions} -b #{@descriptions} -T T -o #{@outfile} -d \"#{@db_path}\" #{@alignment} -I T #{@other_advanced} >> #{job.statuslog_path}"
      @commands << "#{BLASTP}/psiblast -db \"#{@db_path}\"#{@query} -matrix #{@mat_param} -num_iterations #{@rounds} -evalue #{@expect} -gapopen #{@gapopen} -gapextend #{@gapext} -num_threads 4 -inclusion_ethresh #{@e_thresh} -num_descriptions #{@descriptions} -num_alignments #{@descriptions} -out #{@outfile}#{@alignment} -outfmt 0 -html -show_gis#{@smith_wat} -seg #{@filter} #{@other_advanced} >> #{job.statuslog_path}"
      # for testing a blastp call instead. Does not work with alignment (no -in_msa parameter)!
      #@commands << "#{BLASTP}/blastp -db \"#{@db_path}\"#{@query} -matrix #{@mat_param} -evalue #{@expect} -gapopen #{@gapopen} -gapextend #{@gapext} -num_threads 4 -num_descriptions #{@descriptions} -num_alignments #{@descriptions} -out #{@outfile}#{@alignment} -outfmt 0 -html -show_gis#{@smith_wat} -seg #{@filter} #{@other_advanced} >> #{job.statuslog_path}"
    end
    
    ### KEEPING FORMER ROUNDS
    @commands << "echo 'Copying former BLAST results...' >> #{job.statuslog_path}"
    @commands << "cp #{@outfile} #{@outfile}.former  >> #{job.statuslog_path}"

    ### SHORTEN PSIBLAST OUTPUT
    @commands << "echo 'Shortening Blast Output... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/shorten_psiblast_output.pl #{@outfile} #{@outfile} &> #{job.statuslog_path}_shorten_psiblastp"
    @commands << "echo 'Finished BLAST+ search!' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/fix_blast_errors.pl -i #{@outfile} 1>> #{@basename}.log_fix_errors   1>> #{job.statuslog_path}" 
    @commands << "echo 'Visualizing Blast Output... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/blastviz.pl #{@outfile} #{job.jobid} #{job.job_dir} #{job.url_for_job_dir_abs} 1>> #{@basename}.blastvizlog ";
    @commands << "echo 'Generating Blast Histograms... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/blasthisto.pl  #{@outfile} #{job.jobid} #{job.job_dir} &> #{@basename}.blasthistolog";
    
    #create alignment
    if File.exist?("#{@basename}.aln") then
	   @commands << "echo 'Processing Alignments... ' >> #{job.statuslog_path}"
     @commands << "#{REFORMAT}/reformat.pl -i=phy -o=fas -f=#{@basename}.aln -a=#{@basename}.fas"
	   @commands << "#{UTILS}/alignhits_html.pl #{@outfile} #{@basename}.align -Q #{@basename}.fas -e #{@expect} -fas -no_link -blastplus"
    else
	   @commands << "#{UTILS}/alignhits_html.pl #{@outfile} #{@basename}.align -Q #{@basename}.fasta -e #{@expect} -fas -no_link -blastplus"   
    end

    @commands << "reformat.pl fas fas #{@basename}.align #{@basename}.ralign -M first -r"
    @commands << "if [ -s #{@basename}.ralign ]; then hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50 1>  #{File.join(job.job_dir, "psiblast.out")} 2>  #{File.join(job.job_dir, "psiblast.err")}       ; fi"
    @commands << "echo 'Creating Jalview Input... ' >> #{job.statuslog_path}"
    # the result of parse_jalview here seems to be overwritten immediatedly
    # and, additionally, relating to the wrong input file.
    # @commands << "#{RUBY_UTILS}/parse_jalview.rb -i #{@basename}.ralign -o #{@basename}.j.align"
    @commands << "reformat.pl fas fas #{@basename}.align #{@basename}.j.align -M first -r"

    # Use blast parser to modify the output of CS-BLAST
    @commands << "#{HELPER}/blast-parser.pl -i #{@outfile} --add-links > #{@outfile}_out"
    @commands << "mv  #{@outfile}_out #{@outfile}"

    @commands << "source #{UNSETENV}"
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'cpus' => '4'})
    
  end
  
end
