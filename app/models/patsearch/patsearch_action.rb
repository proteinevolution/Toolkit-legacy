class PatsearchAction < Action

  if LOCATION == "Munich" && LINUX == 'SL6'
    PATSEARCH = "perl "+ File.join(BIOPROGS, 'pattern_search')
  else
     PATSEARCH = File.join(BIOPROGS, 'pattern_search')
  end


  include GenomesModule
   
  # top down: protblast/index.rhtml
  attr_accessor :sequence_input, :sequence_file, :std_dbs, :user_dbs, :taxids,:sc ,:db_input, :db_file
  # shared/joboptions.rhtml
  attr_accessor :jobid, :mail 

  validates_input(:sequence_input, :sequence_file, {:informat => 'grammar', 
                                                    :inputmode => 'sequence',
                                                    :max_seqs => 1,
                                                    :on => :create })

  validates_input(:db_input, :db_file, {:informat => 'fas', 
                                        :inputmode => 'sequences',
                                        :max_seqs => 100000,
                                        :allow_nil => true,
                                        :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, {:on=>:create})
  validates_format_of(:sc, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".grammar"
    @dbfile = @basename+".db"    
    @outfile = @basename+".out"
    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @pattern = IO.readlines(@infile).join
    @pattern.gsub!(/\n/, '')
    @pattern.gsub!(/\s+/, '')
    
    @commands = []

    @grammar = params['grammar'] == "reg" ? "-reg" : ""
    @db_type = params['db_type']
    @sc = params["sc"]
    
    @db_path = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
    @db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
    # getDBs is part of the GenomesModule
    gdbs = getDBs('pep')
    logger.debug("SELECTED GENOME DBS\n")
    logger.debug gdbs.join("\n")
    @db_path += ' ' + gdbs.join(' ')
    
    @db_input = params_to_file(@dbfile, 'db_input', 'db_file')
    if @db_input
    	@db_path += ' ' + @dbfile
    end
    
  end

  def perform
    params_dump
    
    @commands << " #{PATSEARCH}/search.pl -i \"#{@pattern}\" -d \"#{@db_path}\" -o #{@outfile} -sc #{@sc} #{@grammar} &> #{job.statuslog_path}"
    
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end  
end

