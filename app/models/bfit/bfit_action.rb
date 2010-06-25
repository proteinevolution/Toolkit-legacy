class BfitAction < Action

  BFIT = File.join(BIOPROGS, 'bfit')
  SAMCC = File.join(BIOPROGS, 'samcc')

  attr_accessor :mail, :jobid, :pdb_file1, :pdb_file2

  validates_input(:pdb_file1, :pdb_file2, {:informat => 'pdb', :on => :create})

  validates_jobid(:jobid)

  validates_email(:mail)


  # Put action initialisation code in here
  def before_perform
    init

    @pdb_file1 = @basename+"_1.pdb"
    @pdb_file2 = @basename+"_2.pdb"

    params_to_file(@pdb_file1, 'pdb_file1')
    #logger.debug "PDB 1: #{pdb_file1}"
    params_to_file(@pdb_file2, 'pdb_file2')
    #logger.debug "PDB 2: #{pdb_file2}"

    @outpath = job.job_dir

    logger.debug "Outpath: #{@outpath}"

    @model = params['model']
    @optimization = params['optimization']

    logger.debug "Model: #{@model}"
    logger.debug "Optimization: #{@optimization}"

    @ensemble = 'F'

    if (!File.exists?(@pdb_file2))
      logger.debug "In Schleife"
      @ensemble = 'T'
    end

    logger.debug "Ensemble: #{@ensemble}"

  end


  # Optional:
  # Put action initialization code that should be executed on forward here
  # def before_perform_on_forward
  # end
  
  
  # Put action code in here
  def perform
    @commands << "export PYTHONPATH=#{SAMCC}"
    if @ensemble == 'T'
      @commands << "#{BFIT}/bFit.py -e #{@pdb_file1} -l #{@model} -g #{@optimization} -w -p -o #{@outpath}"
    else
      @commands << "#{BFIT}/bFit.py -s #{@pdb_file1} #{@pdb_file2} -l #{@model} -g #{@optimization} -w -p -o #{@outpath}"
    end
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end

  #
  def init
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
  end

end




