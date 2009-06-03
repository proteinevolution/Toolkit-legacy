class CsBlastAction < Action
  BLAST = File.join(BIOPROGS, 'blast')
  HH = File.join(BIOPROGS, 'hhpred')
  UTILS = File.join(BIOPROGS, 'perl')
  RUBY_UTILS = File.join(BIOPROGS, 'ruby')
  CSBLAST = File.join(BIOPROGS, 'csblast')

  include GenomesModule

  # top down: csblast/index.rhtml
  attr_accessor :sequence_input, :sequence_file, :std_dbs, :user_dbs, :taxids, :evalue, :descr, :alignments, :otheradvanced,:rounds,:inputmode,:evalfirstit,
			:informat
  # shared/joboptions.rhtml
  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat,
						    :informat => 'fas',
                                                    :inputmode => :inputmode,
                                                    :max_seqs => 9999,
                                                    :on => :create })

  validates_jobid(:jobid)

  validates_email(:mail)

  validates_db(:std_dbs, {:personal_dbs => :user_dbs, :genomes_dbs => 'taxids', :on => :create})

  validates_format_of(:evalue, :evalfirstit, {:with => /(^\d+\.?\d*(e|e-|E|E-|\.)?\d+$)|(^\d+$)/, :on => :create, :message => 'Invalid value!'})

  validates_format_of(:alignments, :rounds, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  validates_format_of(:descr, :alignments, {:with => /^\d+$/, :on => :create})

  validates_shell_params(:jobid, :mail, :evalue, :evalfirstit, :descr, :alignments, :rounds, :otheradvanced,
                         {:on=>:create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"
    @outfile = @basename+".csblast"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    @commands = []

    @inputmode = params['inputmode']
    @expect             = params['evalue']
    @filter             = params['filter'] ? 'T' : 'F'
    @mat_param          = params['matrix']
    @other_advanced     = params['otheradvanced']
    @descriptions       = params['descr']
    @alignments         = params['alignments']
    @db_path            = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    
    @ungapped_alignment = params['ungappedalign'] ? 'F' : 'T'
    @e_thresh = params['evalfirstit']
    @smith_wat = params['smithwat'] ? 'T' : 'F'
    @rounds = params['rounds']
    @fastmode = params['fastmode'] ? 'T' : 'F'
    @alignment = ""
    
    
    # getDBs is part of the GenomesModule
    gdbs = getDBs('pep')
    logger.debug("SELECTED GENOME DBS\n")
    logger.debug gdbs.join("\n")
    @db_path += ' ' + gdbs.join(' ')

    File.open(@basename + ".csiblast_conf", "w") do |file|
    file.write(@e_thresh)
    end
    system("chmod 777 #{@basename}.csiblast_conf")
    
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
    @alignment = "-B #{@basename}.aln"
    
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

    
    ### KEEPING FORMER ROUNDS
    #@commands << "cp #{@outfile} #{@outfile}.former"
    @commands << "#{CSBLAST}/bin/csblast -i #{@infile} -j #{@rounds} -h #{@e_thresh} -D #{CSBLAST}/data/K4000.lib --blast-path #{BLAST}/bin -e #{@expect} -F #{@filter} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -v #{@descriptions} -b #{@alignments} -T T -o #{@outfile} -d \"#{@db_path}\" -I T -a 1 #{@other_advanced} &>#{job.statuslog_path}"
    
    @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/fix_blast_errors.pl -i #{@outfile} &>#{@basename}.log_fix_errors"
    @commands << "#{UTILS}/blastviz.pl #{@outfile} #{job.jobid} #{job.job_dir} #{job.url_for_job_dir_abs} &> #{@basename}.blastvizlog";
    @commands << "#{UTILS}/blasthisto.pl  #{@outfile} #{job.jobid} #{job.job_dir} &> #{@basename}.blasthistolog";

    #create alignment
    @commands << "#{UTILS}/alignhits_html.pl #{@outfile} #{@basename}.align -fas -no_link -e #{@expect}"

    @commands << "#{HH}/reformat.pl fas fas #{@basename}.align #{@basename}.ralign -M first -r"
    @commands << "if [ -s #{@basename}.ralign ]; then #{HH}/hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50; fi"
    
    @commands << "#{RUBY_UTILS}/parse_jalview.rb -i #{@basename}.ralign -o #{@basename}.j.align"
    @commands << "#{HH}/reformat.pl fas fas #{@basename}.j.align #{@basename}.j.align -r"



    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end
end


