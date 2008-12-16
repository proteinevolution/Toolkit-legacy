class CsBlastAction < Action
  BLAST = File.join(BIOPROGS, 'blast')
  HH = File.join(BIOPROGS, 'hhpred')
  UTILS = File.join(BIOPROGS, 'perl')
  CSBLAST = File.join(BIOPROGS, 'csblast')

  include GenomesModule

  # top down: csblast/index.rhtml
  attr_accessor :sequence_input, :sequence_file, :std_dbs, :user_dbs, :taxids, :evalue, :descr, :alignments, :otheradvanced
  # shared/joboptions.rhtml
  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas',
                                                    :inputmode => 'sequence',
                                                    :max_seqs => 1,
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
    @outfile = @basename+".csblast"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @expect             = params['evalue']
    @filter             = params['filter'] ? 'T' : 'F'
    @mat_param          = params['matrix']
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

  def perform
    params_dump

    @commands << "#{CSBLAST}/bin/csblast -i #{@infile} -D #{CSBLAST}/data/clusters.prf --blast-path #{BLAST}/bin -e #{@expect} -F #{@filter} -M #{@mat_param} -G #{@gapopen} -E #{@gapext} -v #{@descriptions} -b #{@alignments} -T T -o #{@outfile} -d \"#{@db_path}\" -I T -a 1 #{@other_advanced} &>#{job.statuslog_path}"
    @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
    @commands << "#{UTILS}/fix_blast_errors.pl -i #{@outfile} &>#{@basename}.log_fix_errors"
    @commands << "#{UTILS}/blastviz.pl #{@outfile} #{job.jobid} #{job.job_dir} #{job.url_for_job_dir_abs} &> #{@basename}.blastvizlog";
    @commands << "#{UTILS}/blasthisto.pl  #{@outfile} #{job.jobid} #{job.job_dir} &> #{@basename}.blasthistolog";

    #create alignment
    @commands << "#{UTILS}/alignhits_html.pl #{@outfile} #{@basename}.align -fas -no_link -e #{@expect}"

    @commands << "#{HH}/reformat.pl fas fas #{@basename}.align #{@basename}.ralign -M first -r"
    @commands << "if [ -s #{@basename}.ralign ]; then #{HH}/hhfilter -i #{@basename}.ralign -o #{@basename}.ralign -diff 50; fi"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end
end


