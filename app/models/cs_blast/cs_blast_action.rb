require 'ftools'

###
# Tool Description: CS-Blast
# CS-BLAST is an extension to standard NCBI BLAST that allows to increase its sensitivity by a factor of more than 
# two on remote homologs at the same speed. CS-BLAST first adds context-specific pseudocounts to the input sequence   
# and then jumpstarts PSI-BLAST with the resulting profile. The output is identical to BLAST and contains a list of  
# closest homologs with alignments.  
###
class CsBlastAction < Action
  # Generate application paths
  BLAST = File.join(BIOPROGS, 'blast')
  RUBY_UTILS = File.join(BIOPROGS, 'ruby')
  CSBLAST = File.join(BIOPROGS, 'csblast')
  CSDB = File.join(DATABASES, 'csblast')
  HHSUITE = File.join(BIOPROGS, 'hhsuite/bin')
  HHSUITELIB = File.join(BIOPROGS, 'hhsuite/lib/hh/scripts')
  
  if LOCATION == "Munich" && LINUX == 'SL6'
    UTILS = "perl " +File.join(BIOPROGS, 'perl')
    HH = "perl " +File.join(BIOPROGS, 'hhpred')
  else
     UTILS = File.join(BIOPROGS, 'perl')
     HH = File.join(BIOPROGS, 'hhpred')
  end
  
  include GenomesModule
    
  # set in: csblast/index.rhtml 
  attr_accessor :sequence_input, :sequence_file, :std_dbs, :user_dbs, :taxids, :evalue, :descr, :alignments, :otheradvanced,:rounds,:inputmode,:evalfirstit,
			:informat
  # set in: shared/joboptions.rhtml
  attr_accessor :jobid, :mail 

  # Self defined validator in app/models/validators/input_validator.rb
  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat,
						    :informat => 'fas',
                                                    :inputmode => :inputmode,
                                                    :max_seqs => 9999,
                                                    :on => :create })
  # Self defined Validator in app/models/validators/id_validator.rb
  validates_jobid(:jobid,:message => 'Job Id must be given')
  # Self defined Validator in app/models/validators/email_validator.rb
  validates_email(:mail)
  # Self defined Validator in app/models/validators/db_validator.rb
  validates_db(:std_dbs, {:personal_dbs => :user_dbs, :genomes_dbs => 'taxids', :on => :create})
  # Native RoR Validator  
  validates_format_of(:evalue, :evalfirstit, {:with => /(^\d+\.?\d*(e|e-|E|E-|\.)?\d+$)|(^\d+$)/, :on => :create, :message => 'Invalid value!'})
  # Native RoR Validator  
  validates_format_of(:alignments, :rounds, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 
  # Native RoR Validator  
  validates_format_of(:descr, :alignments, {:with => /^\d+$/, :on => :create})
  # Self defined validator in app/models/validators/shell_params_validator.rb
  validates_shell_params(:jobid, :mail, :evalue, :evalfirstit, :descr, :alignments, :rounds, :otheradvanced,
                         {:on=>:create})


  ###
  # Set up / build parameters needed for running CS-Blast
  #
  ###
  def before_perform  
    # Init file vars 
	  @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"
    @outfile = @basename+".csblast"
    
    # Save either the pasted Sequence from frontend or uploaded Sequence File to in file
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    # Reformat the input sequence to match fasta format (perl script call)
    reformat(@informat, "fas", @infile)
    # necessary for resubmitting domains via slider
	  File.copy(@infile, @basename+".in")	
    
    # init cmd container
    @commands = []

    # init frontend params
    @inputmode          = params['inputmode']
    @expect             = params['evalue']
    @filter             = params['filter'] ? 'T' : 'F'
    @mat_param          = params['matrix']
    @other_advanced     = params['otheradvanced']
    @descriptions       = params['descr']
    @alignments         = params['alignments']
    @db_path            = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path            = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    
    @ungapped_alignment = params['ungappedalign'] ? 'F' : 'T'
    @e_thresh           = params['evalfirstit']
    @smith_wat          = params['smithwat'] ? 'T' : 'F'
    @rounds             = params['rounds']
    @fastmode           = params['fastmode'] ? 'T' : 'F'
    @alignment          = ""
    
    # init genome db parameter
    # getDBs is part of the GenomesModule
    gdbs = getDBs('pep')
    logger.debug("SELECTED GENOME DBS\n")
    logger.debug gdbs.join("\n")
    @db_path += ' ' + gdbs.join(' ')


    # Write confidence parameter to file in temp directory
    File.open(@basename + ".csiblast_conf", "w") do |file|
    file.write(@e_thresh)
  end
    # set file rights ugo+rxw
    system("chmod 777 #{@basename}.csiblast_conf")
    # if input is alignment call method process_alignment
    if (@inputmode == "alignment") then process_alignment end

    # set gapopen and gapextend costs depending on given matrix
    # default values
    @gapopen = 11
    @gapext = 1
    if (@mat_param =~ /BLOSUM80/i || @mat_param =~ /PAM70/i) then @gapopen = 10 end
    if (@mat_param =~ /PAM30/i) then @gapopen = 9 end
    if (@mat_param =~ /BLOSUM45/i) 
      @gapopen = 15
      @gapext = 2
    end    
    
  end
  
   ###
   # 
   # imports alignment file, removes all gap-only rows. Write output to file 
   ###
   def process_alignment
    # init vars
    @names = []
    @seqs = []
     
    @alignment = "-B #{@basename}.aln"

    # import alignment file
    @content = IO.readlines(@infile).map {|line| line.chomp}
    
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
  
  ###
  # Checks alignment for gap-only columns and removes them
  #
  ### 
  def remove_inserts

    currseq = ""
    currname = ""
    # TODO: extract this from all methods to a helper class  
    @content.each do |line|
      # if name anchor is found start a new bin
      if (line =~ /^>(.*)/)
        # check if we found next bin
        if (currseq.length > 0)
          # push name and sequence to containers
          @names << currname
          @seqs << currseq
        end
        # name is found next to anchor
        currname = $1
        # no sequence data yet
        currseq = ""
      else
        # append sequence data
        currseq += line
      end 
    end  
    # collect the data from the last bin
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
      # Unpack C : 8-bit unsigned integer , push -> Array
      residues = @seqs[i].unpack("C*")
      seq = ""
      # traverse over Integer Representation
      residues.each_index do |num|
        # If the base Sequence has no gap then check current sequence 
        if (match_cols[num])
          if (residues[num] == 45 || residues[num] == 46)
            # Add gap to Sequence
            seq += "-"
          else
            # Add the Residue to Sequence
            seq += residues[num].chr
          end  
        end   
      end
      # Remove anchoring String Characters
      seq.tr!('^a-zA-Z-','')
      # Push an Upper Case representation to the @seqs array
      @seqs[i] = seq.upcase
      # Check whether all sequences have same length as parent
      if (@seqs[i].length != @seqs[0].length)
        logger.debug "ERROR! Sequences in alignment do not all have equal length!"
      end
    end
  end

  ###
  # Constructs cmd parameters and submits to queue
  #
  ### 
  def perform
    params_dump
    
    ### KEEPING FORMER ROUNDS
    #@commands << "cp #{@outfile} #{@outfile}.former"  
    # Export variable needed for HHSuite
    @commands << "export  HHLIB=#{HHLIB} "
    @commands << "export  PATH=$PATH:#{HHSUITE}" 
    
    # cmd for blast run 
    @commands << "echo 'Starting BLAST search' &> #{job.statuslog_path}"
    @commands << "#{CSBLAST}/bin/csblast -i #{@infile} -j #{@rounds} -h #{@e_thresh} -D #{CSBLAST}/data/K4000.lib #{@alignment} --blast-path #{BLAST}/bin -e #{@expect} -F #{@filter} -G #{@gapopen} -E #{@gapext} -v #{@descriptions} -b #{@alignments} -T T -o #{@outfile} -d \"#{@db_path}\" -I T -a 1 #{@other_advanced} >>#{job.statuslog_path}"
     
    @commands << "echo 'Finished BLAST search' >> #{job.statuslog_path}"
    # run perl script to fix blast errors. TODO: Find out what script does 
    @commands << "echo 'Fixing BLAST errors' >> #{job.statuslog_path}"  
    @commands << "#{UTILS}/fix_blast_errors.pl -i #{@outfile} &>#{@basename}.log_fix_errors"
    # run perl script to visualize blast results. TODO: Find out what script does
    @commands << "echo 'Visualizing BLAST Output' >> #{job.statuslog_path}" 
    @commands << "#{UTILS}/blastviz.pl #{@outfile} #{job.jobid} #{job.job_dir} #{job.url_for_job_dir_abs} &> #{@basename}.blastvizlog";
    # run perl script to process blast history. TODO: Find out what script does
    @commands << "echo 'Generating Blast Histograms... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/blasthisto.pl  #{@outfile} #{job.jobid} #{job.job_dir} &> #{@basename}.blasthistolog";
    
    # run perl script to create alignment
    @commands << "echo 'Processing Alignments... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/alignhits_html.pl #{@outfile} #{@basename}.align -fas -no_link -e #{@expect}"
    # run perl script to reformat alignment TODO: Find out what script does
    @commands << "#{HH}/reformat.pl fas fas #{@basename}.align #{@basename}.ralign -M first -r"
    # TODO: Find out what script does
    @commands << "if [ -s #{@basename}.ralign ]; then #{HHSUITE}/hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50; fi"
    # TODO: Find out what script does
    @commands << "#{RUBY_UTILS}/parse_csiblast.rb -i #{@basename}.csblast -o #{@basename}.csblast"
    # Generate Jalview Output from alignment data
    @commands << "echo 'Creating Jalview Input... ' >> #{job.statuslog_path}"
    @commands << "#{RUBY_UTILS}/parse_jalview.rb -i #{@basename}.ralign -o #{@basename}.j.align" 
    # TODO: Find out what script does
    @commands << "#{HH}/reformat.pl fas fas #{@basename}.j.align #{@basename}.j.align -r"



    logger.debug "Commands:\n"+@commands.join("\n")
    # Submit generated cmd list to queue
    queue.submit(@commands)

  end  
end


