class ClubsubpAction < Action

  BLAST  = File.join(BIOPROGS, 'blast')
  DBPATH = File.join(DATABASES, 'clubsubp', 'clst_m_scl')
  PARSER = File.join(BIOPROGS, 'clubsubp')


  attr_accessor :mail, :jobid, :sequence_input, :sequence_file

  # Put action initialisation code in here
  def before_perform
    init

    @infile = @basename+".in"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @outfile = @basename+".out"
    logger.debug "Outfile: #{@outfile}"

  end


  # Optional:
  # Put action initialization code that should be executed on forward here
  # def before_perform_on_forward
  # end
  
  
  # Put action code in here
  def perform
    @commands << "#{BLAST}/blastall -p blastp -i #{@infile} -d #{DBPATH} -o #{@outfile} -I t &>#{job.statuslog_path}"
    @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
    @commands << "/usr/bin/perl #{PARSER}/blast_parser.pl #{@outfile} #{@basename} >> #{job.statuslog_path}"
    @commands << "echo 'Blast ouput parsed !' >> #{job.statuslog_path}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end

  
  def init
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
  end

end
