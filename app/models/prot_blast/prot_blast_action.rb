require 'ftools'

class ProtBlastAction < Action

  BLAST = File.join(BIOPROGS, 'blast')
  HH = File.join(BIOPROGS, 'hhpred')
  RUBY_UTILS = File.join(BIOPROGS, 'ruby')
  
  if LOCATION == "Munich" && LINUX == 'SL6'
    UTILS = "perl " +File.join(BIOPROGS, 'perl')
    HHPERL = "perl " +File.join(BIOPROGS, 'hhpred')
  else
     UTILS = File.join(BIOPROGS, 'perl')
     HHPERL = File.join(BIOPROGS, 'hhpred')
  end


  include GenomesModule
   
  # top down: protblast/index.rhtml
  attr_accessor :sequence_input, :sequence_file, :std_dbs, :user_dbs, :taxids, :evalue, :descr, :alignments, :otheradvanced, :informat
  # shared/joboptions.rhtml
  attr_accessor :jobid, :mail 

#  validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
#                                                    :inputmode => 'sequence',
#                                                    :min_seqs =>0,
#                                                    :max_seqs => 1,
#                                                    :on => :create })
  validates_input(:sequence_input, :sequence_file, {:informat=> :informat, 
                                                    :inputmode => 'sequences',
                                                    :max_seqs => 1,
                                                    :min_seqs => 0,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_db(:std_dbs, {:personal_dbs => :user_dbs, :genomes_dbs => 'taxids', :on => :create})
  
  validates_format_of(:evalue, {:with => /^\d+(e|e-|\.)?\d+$/, :on => :create})
  
  validates_format_of(:descr, :alignments, {:with => /^\d+$/, :on => :create})
  
  validates_shell_params(:jobid, :mail, :evalue, :descr, :alignments, :otheradvanced, 
                         {:on=>:create})

  def before_perform  
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".fasta"
    @outfile = @basename+".protblast"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    #reformat("fas", "fas", @infile)
	  File.copy(@infile, @basename+".in")	# necessary for resubmitting domains via slider
    @commands = []
    
    @program            = params['program'] == 'blastpgp' ? 'blastpgp' : "blastall -p #{params['program']}"
    @expect             = params['evalue']
    @filter             = params['filter'] ? 'T' : 'F'
    @mat_param          = params['matrix']
    @ungapped_alignment = if @program!='blastpgp' then params['ungappedalign'] ? '-g F' : '-g T' else '' end
    @other_advanced     = params['otheradvanced']
    @descriptions       = params['descr']
    @alignments         = params['alignments']
    @db_path            = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    # getDBs is part of the GenomesModule
    gdbs = getDBs('pep')
    logger.debug("SELECTED GENOME DBS\n")
    logger.debug gdbs.join("\n")
    @db_path += ' ' + gdbs.join(' ')
    
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

def check_GI
  
    #  Try to bundle all needed Parameters for GI Check 
    #  Dbs needed for GI extraction
    @mainlog = job.statuslog_path+"_gi2seq"
    @database_nr = File.join(DATABASES, "standard/nr")
    @database_uniprot_sprot = File.join(DATABASES, "standard/uniprot_sprot.fasta")
    @database_uniprot_trembl = File.join(DATABASES, "standard/uniprot_trembl.fasta")
    @commands << "echo 'We find that it is a  GI search!' >> #{job.statuslog_path}"
    @inputSequences = Array.new
    @inputTags = Array.new
    @tmparray = Array.new
    @jobtype = Array.new
    @formerjob = ''
  
    descriptions = 1
    ## Open Filereader on 
    res = IO.readlines(@infile)
    res.each do |line|
      logger.debug(line)
      inputfile = File.join(@basename+"_GI_#{descriptions}.in")
      writefile = File.open(inputfile, "w")
      writefile.write(line)
      writefile.close
      if line.strip =~ /^[gi\|]?[0-9]+\|?$/
        @database=@database_nr
      else
        @database="#{@database_uniprot_sprot} #{@database_uniprot_trembl}"
      end
      gi2seq_out = File.join(@basename+"_#{descriptions}.in")
      logger.debug("#{UTILS}/seq_retrieve.pl -i #{inputfile} -o #{@infile} -b #{BLAST} -d \"#{@database}\" -unique >> #{@mainlog} 2>> #{@mainlog}")
      @commands << "#{UTILS}/seq_retrieve.pl -i #{inputfile} -o #{@infile} -b #{BLAST} -d \"#{@database}\" -unique >> #{@mainlog} 2>> #{@mainlog}"
      parameter = job.jobid.to_s+"_"+descriptions.to_s
      @inputSequences.push(parameter)
      @inputTags.push(line)
      @jobtype.push('sequence')
      descriptions += 1
    end
  end

  def perform
    params_dump
     #if (params['informat'] == 'gi')
        #check_GI
    #end
    # TEST if this reformats our wrecked input 
    @commands << "#{UTILS}/reformat_protblast.pl -f=#{@infile} -a=#{@infile} -i=fas -o=fas &> #{@infile}.reform_log " 
    @commands << "echo 'Starting BLAST search!' &> #{job.statuslog_path}"
    @commands << "#{BLAST}/#{@program} -i #{@infile} -e #{@expect} -F #{@filter} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} #{@ungapped_alignment} -v #{@descriptions} -b #{@alignments} -T T -o #{@outfile} -d \"#{@db_path}\" -I T -a 1 #{@other_advanced} >>#{job.statuslog_path}"
    @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/fix_blast_errors.pl -i #{@outfile} &>#{@basename}.log_fix_errors"
    @commands << "echo 'Visualizing Blast Output... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/blastviz.pl #{@outfile} #{job.jobid} #{job.job_dir} #{job.url_for_job_dir_abs} &> #{@basename}.blastvizlog";
    @commands << "echo 'Generating Blast Histograms... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/blasthisto.pl  #{@outfile} #{job.jobid} #{job.job_dir} &> #{@basename}.blasthistolog";
    
    #create alignment
    @commands << "echo 'Processing Alignments... ' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/alignhits_html.pl #{@outfile} #{@basename}.align -fas -no_link -e #{@expect}"
    
    @commands << "#{HHPERL}/reformat.pl fas fas #{@basename}.align #{@basename}.ralign -M first -r"
    @commands << "if [ -s #{@basename}.ralign ]; then #{HH}/hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50; fi"
    @commands << "echo 'Creating Jalview Input... ' >> #{job.statuslog_path}"
    @commands << "#{RUBY_UTILS}/parse_jalview.rb -i #{@basename}.ralign -o #{@basename}.j.align"
    @commands << "#{HHPERL}/reformat.pl fas fas #{@basename}.j.align #{@basename}.j.align -r"


    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end  
end

