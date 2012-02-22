class SimshiftAction < Action
  SIMSHIFT = File.join(BIOPROGS,'simshift')

  attr_accessor  :jobid , :mail ,  :sequence_file,:sequence_input , :minblocklen, :localevaluecut, :evaluecut, :database , :fullA

  no_input = []

 #validates_input_fields ( :sequence_file, {:allow_nil => false}) 
 
  validates_input( :sequence_input  , :sequence_file, {:informat => 'shx'})

  validates_jobid(:jobid)
  
  validates_email(:mail)

  validates_db(:database)

  validates_shell_params(:mail, :jobid, :minblocklen , :localevaluecut, :evaluecut)
 
  validates_format_of(:localevaluecut, :evaluecut, {:with => /(^\d+\.?\d*(e|e-|E|E-|\.)?\d+$)|(^\d+$)/,
                                                    :on => :create,
                                                    :message => 'Invalid value!' })
  
   validates_format_of(:minblocklen, {:with => /(^\d+$)/,
                                    :on => :create,
                                   :message => 'Invalid value'})

  def before_perform
   @basename =  File.join(job.job_dir,job.jobid)
   @infile = @basename+".shiftx"
   @outfileA = @basename+".align"
   @outfileB = @basename+".align2"
   params_to_file(@infile,'sequence_file')
   @commands = []
   
   @blocklen = params['minblocklen']
   @localecut = params['localevaluecut']
   @ecut = params['evaluecut']
   @db_path =  params['database']
   @fullA = params['fullA'] ? 'T' : 'F'
   
    
  end

  def perform
     params_dump
    if @fullA == 'T' 
      @commands << "cd #{SIMSHIFT}; #{SIMSHIFT}/load_remove_matrix_shm -load"
      @commands << "cd #{SIMSHIFT};  #{SIMSHIFT}/SimShiftDB_Server -M #{@blocklen} -e #{@localecut} -E #{@ecut} -O #{@outfileA} #{@infile} #{@db_path}"
      @commands << "cd #{SIMSHIFT}; #{SIMSHIFT}/simviz.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} #{@db_path}.fas &> /dev/null"
      @commands << "cd #{SIMSHIFT};  #{SIMSHIFT}/SimShiftDB_Server -M #{@blocklen} -e #{@localecut} -E #{@ecut} -F  -O #{@outfileB}  #{@infile} #{@db_path}"
      @commands << "cd #{SIMSHIFT}; #{SIMSHIFT}/load_remove_matrix_shm"

    else
      @commands << "cd #{SIMSHIFT}; #{SIMSHIFT}/load_remove_matrix_shm -load"
      @commands << "cd #{SIMSHIFT};  #{SIMSHIFT}/SimShiftDB_Server -M #{@blocklen} -e #{@localecut} -E #{@ecut} -O #{@outfileA} #{@infile} #{@db_path}"
      @commands << "cd #{SIMSHIFT}; #{SIMSHIFT}/simviz.pl #{job.jobid} #{job.job_dir} #{job.url_for_job_dir} #{@db_path}.fas &> /dev/null"
      @commands << "cd #{SIMSHIFT}; #{SIMSHIFT}/load_remove_matrix_shm"

    end
       
    logger.debug("Commands:\n"+@commands.join("\n"))
    queue.submit(@commands)

  end





  
  # Put action initialisation code in here
  # def before_perform
  # end


  # Optional:
  # Put action initialization code that should be executed on forward here
  # def before_perform_on_forward
  # end
  
  
  # Put action code in here
  # def perform
  # end

end




