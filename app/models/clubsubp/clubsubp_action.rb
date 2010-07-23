class ClubsubpAction < Action

  BLAST  = File.join(BIOPROGS, 'blast')
  DBPATH = File.join(DATABASES, 'clubsubp', 'clst_m_scl')
  CLUB   = File.join(BIOPROGS, 'clubsubp')


  attr_accessor :mail, :jobid, :sequence_input, :sequence_file

  # Put action initialisation code in here
  def before_perform
    init

    @text_search = params['text_search'] ? params['text_search'] : ""

    @infile = @basename+".in"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @outfile = @basename+".out"
    logger.debug "Outfile: #{@outfile}"

    if(!@text_search.empty?)
      @infile=""
    end 
  end


  # Optional:
  # Put action initialization code that should be executed on forward here
  # def before_perform_on_forward
  # end
  
  
  # Put action code in here
  def perform

    # Text search starts here
    if(!@text_search.empty?)
      @commands << "echo #{@basename} &> #{job.statuslog_path}"
      @commands << "/usr/bin/perl #{CLUB}/search_clubsub.pl #{@basename} #{@text_search} >> #{job.statuslog_path}" 
      @commands << "echo #{@text_search} >> #{job.statuslog_path}"
#     ./qupdate.rb 2316 d      
#     @temp_id   = QueueJob.find(:first, :conditions => ["action_id=?", @action_id])
#     logger.debug @temp_id

#      @commands << "echo #{@temp_id} >> #{job.statuslog_path}"
    end

    # Blast search if we have sequence input 
    if(!@infile.empty?)
      @commands << "#{BLAST}/blastall -p blastp -i #{@infile} -d #{DBPATH} -o #{@outfile} -I t &> #{job.statuslog_path}"
      @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
      @commands << "/usr/bin/perl #{CLUB}/blast_parser.pl #{@outfile} #{@basename} >> #{job.statuslog_path}"
      @commands << "echo 'Blast output parsed !' >> #{job.statuslog_path}"

    end
   
    if(@infile.empty? && @text_search.empty?)
      @commands << "echo 'no input data' &> #{job.statuslog_path}"
    end 
 
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

  
  def init
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    olt
  end

  def olt
    @action_id = job.id
#    @temp_id   = QueueJob.find(:first, :conditions => ["action_id=?", @action_id])
#    logger.debug @temp_id
  end

end
