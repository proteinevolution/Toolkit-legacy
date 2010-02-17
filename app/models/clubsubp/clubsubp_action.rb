class ClubsubpAction < Action

  CLUB = File.join(BIOPROGS, 'clubsubp')

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
    @commands << "/usr/bin/perl #{CLUB}/blast_search.pl #{@infile} #{@outfile} &> #{job.statuslog_path}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end

  
  def init
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
  end


end




