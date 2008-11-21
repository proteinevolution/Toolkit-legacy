class GdpredAction < Action
GDPRED = File.join(BIOPROGS, 'gdpred')
BLAST  = File.join(BIOPROGS, 'blast')
PSIPRED = File.join(BIOPROGS, 'psipred')
PSIPRED_BIN = File.join(PSIPRED, 'bin')
PSIPRED_DATA =  File.join(PSIPRED, 'data')
STANDARD_DB = File.join(DATABASES, 'standard')


  attr_accessor :sequence_input, :sequence_file, :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas',
                                                    :on => :create,
				                    :inputmode => 'sequences'})

# validates_input(:sequence_input, :sequence_file, {:informat_field => :informat,
#                                                     :informat => 'fas',
#                                                     :on => :create,
#                                                     :inputmode => 'sequences'})
#

  validates_jobid(:jobid)

  validates_email(:mail)

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"
    @outfile = @basename+".out"
	logger.debug	"Basename: #{@basename}"

    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    #@informat = params['informat'] ? params['informat'] : 'fas'
    #reformat(@informat, "fas", @infile)
    #@informat = "fas"

    mem = {}
    mem['basename']     = @basename
    mem['psipredfile']  = @basename+".horiz"
    mem['queryfile']    = @infile
    mem['outfile']      = @outfile
    self.flash = mem
    self.save!

  end

  def perform
    params_dump

    @commands << "#{BLAST}/blastpgp -b 0 -j 3 -h 0.001 -i #{@infile} -d #{STANDARD_DB}/nr90 -C #{@basename}.chk -Q #{@basename}.pssm -F T -e 1e-3 > #{@basename}.txt"

    @commands << "cd #{job.job_dir}"

    @commands << "echo #{job.jobid}.chk > psitmp.pn"

    @commands << "echo #{job.jobid}.in > psitmp.sn"

    @commands << "#{BLAST}/makemat -P psitmp"

    @commands << "#{PSIPRED_BIN}/psipred #{@basename}.mtx #{PSIPRED_DATA}/weights.dat #{PSIPRED_DATA}/weights.dat2 #{PSIPRED_DATA}/weights.dat3 #{PSIPRED_DATA}/weights.dat4 > #{@basename}.ss"

    @commands << "#{PSIPRED_BIN}/psipass2 #{PSIPRED_DATA}/weights_p2.dat 1 1.0 1.3 #{@basename}.ss2 #{@basename}.ss > #{@basename}.horiz"

    @commands << "python #{GDPRED}/gdpred_test.py #{@basename}.pssm #{@basename}.ss2 #{@infile} #{@outfile}"
   
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end


 #constants
 #PSIBLAST = File.join(BIOPROGS, 'perl', 'reformat.pl') # Wo finde ich PSI_BLAST

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




