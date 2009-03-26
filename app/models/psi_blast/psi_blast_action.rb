class PsiBlastAction < Action
  BLAST = File.join(BIOPROGS, 'blast')
  HH = File.join(BIOPROGS, 'hhpred')
  UTILS = File.join(BIOPROGS, 'perl')

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
    @outfile = @basename+".psiblast"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)
    @commands = []

    @inputmode = params['inputmode']
    @expect = params['evalue']
    @mat_param = params['matrix']
    @ungapped_alignment = params['ungappedalign'] ? 'F' : 'T'
    @other_advanced = params['otheradvanced']
    @descriptions = params['alignments']
    @e_thresh = params['evalfirstit']
    @smith_wat = params['smithwat'] ? 'T' : 'F'
    @rounds = params['rounds']
    @filter = params['filter'] ? 'T' : 'F'
    @fastmode = params['fastmode'] ? 'T' : 'F'
    @alignment = ""
    @db_path = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    # getDBs is part of the GenomesModule
    gdbs = getDBs('pep')
    logger.debug gdbs.join('\n')
    @db_path += ' ' + gdbs.join(' ')    
    
    File.open(@basename + ".psiblast_conf", "w") do |file|
      file.write(@e_thresh)
    end
    system("chmod 777 #{@basename}.psiblast_conf")
    
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
    
    # use nr70f for all but last round?
    if (@rounds.to_i > 1 && @fastmode == 'T')
      # first run with nr70f
      @commands << "#{BLAST}/blastpgp -a 4 -i #{@infile} -F #{@filter} -h #{@e_thresh} -s #{@smith_wat} -e #{@expect} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -j #{@rounds} -m 0 -v #{@descriptions} -b #{@descriptions} -T T -o #{@basename}.psiblast_tmp -d #{DATABASES}/standard/nr70f #{@alignment} -I T -C #{@basename}.ksf #{@other_advanced} &> #{job.statuslog_path}"
      @commands << "#{BLAST}/blastpgp -a 4 -i #{@infile} -F #{@filter} -h #{@e_thresh} -s #{@smith_wat} -e #{@expect} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -j 1 -m 0 -v #{@descriptions} -b #{@descriptions} -T T -o #{@outfile} -d \"#{@db_path}\" -I T -R #{@basename}.ksf #{@other_advanced} &> #{job.statuslog_path}"
    else
      @commands << "#{BLAST}/blastpgp -a 4 -i #{@infile} -F #{@filter} -h #{@e_thresh} -s #{@smith_wat} -e #{@expect} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -j #{@rounds} -m 0 -v #{@descriptions} -b #{@descriptions} -T T -o #{@outfile} -d \"#{@db_path}\" #{@alignment} -I T #{@other_advanced} &> #{job.statuslog_path}"
    end
    
    ### KEEPING FORMER ROUNDS
    @commands << "cp #{@outfile} #{@outfile}.former"

    ### SHORTEN PSIBLAST OUTPUT
    @commands << "#{UTILS}/shorten_psiblast_output.pl #{@outfile} #{@outfile} &> #{job.statuslog_path}_shorten_psiblast"

    @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/fix_blast_errors.pl -i #{@outfile} &>#{@basename}.log_fix_errors"
    @commands << "#{UTILS}/blastviz.pl #{@outfile} #{job.jobid} #{job.job_dir} #{job.url_for_job_dir_abs} &> #{@basename}.blastvizlog";
    @commands << "#{UTILS}/blasthisto.pl  #{@outfile} #{job.jobid} #{job.job_dir} &> #{@basename}.blasthistolog";
    
    #create alignment
    @commands << "#{UTILS}/alignhits_html.pl #{@outfile} #{@basename}.align -Q #{@infile} -e #{@expect} -fas -no_link"

    @commands << "#{HH}/reformat.pl fas fas #{@basename}.align #{@basename}.ralign -M first -r"
    @commands << "if [ -s #{@basename}.ralign ]; then #{HH}/hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50; fi"
    @commands << "#{BLAST}/parse_jalview.rb -i #{@basename}.align -o #{@basename}.j.align"
    @commands << "#{HH}/reformat.pl fas fas #{@basename}.j.align #{@basename}.j.align -r"

    
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'cpus' => '4'})
    
  end
  
end




