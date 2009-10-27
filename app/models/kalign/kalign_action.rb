class KalignAction < Action

  KALIGN = File.join(BIOPROGS, 'kalign')

  attr_accessor :sequence_input, :sequence_file, :gapopen, :gapextension, :termgap, :bonusscore

  attr_accessor :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat => 'fas',
  																	 :on => :create,
																	 :max_seqs => 5000,
  																	 :min_seqs => 2,
  																	 :inputmode => 'sequences'})


  validates_shell_params(:jobid, :mail, :gapopen, :gapextension, :termgap, :bonusscore, {:on => :create})

  validates_format_of(:gapopen, :gapextension, :termgap, :bonusscore, {:with => /^\d+\.*\d*$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 

  validates_jobid(:jobid)

  validates_email(:mail)

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".in"
    @outfile = @basename+".aln"

    params_to_file(@infile, 'sequence_input', 'sequence_file')
    @commands = []

    @gapopen = params['gapopen'] ? params['gapopen'].to_f : 11.0
    @gapextension = params['gapextension'] ? params['gapextension'].to_f : 0.85
    @termgap = params['termgap'] ? params['termgap'].to_f : 0.45
    @bonusscore = params['bonusscore'] ? params['bonusscore'].to_f : 0.0

    @outorder = params['outorder']

    if (@gapopen < 0) then @gapopen = 11.0 end
    if (@gapextension < 0) then @gapextension = 0.85 end
    if (@termgap < 0) then @termgap = 0.45 end
  end

  def perform
    params_dump

    @commands << "#{KALIGN}/kalign -i #{@infile} -o #{@outfile} -s #{@gapopen} -e #{@gapextension} -t #{@termgap} -m #{@bonusscore} -c #{@outorder} &> #{job.statuslog_path}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)

  end

end
