class Ali2dAction < Action
  ALI2D = File.join(BIOPROGS, 'ali2d')
  MEMSAT2 = File.join(BIOPROGS, 'memsat2')
  

  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail, :seqident

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat,
                                                    :informat => 'fas',
                                                    :inputmode => 'alignment',
                                                    :max_seqs => 1000,
                                                    :min_seqs => 2,
                                                    :on => :create })

  validates_jobid(:jobid)

  validates_email(:mail)

  validates_shell_params(:jobid, :mail, :seqident, {:on => :create})

  validates_float_into_list(:seqident, {:in => 0..100, :message => "should be between 0 and 100",
  									:on => :create})

  def before_perform

    init

    params_to_file(@infile, 'sequence_input', 'sequence_file')

    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @infile)
    @informat = "fas"

    @seqident = params["seqident"]

  end
  
  def init
    @basename = File.join(job.job_dir, job.jobid)
    @infile = @basename+".aln"
    @outfile = @basename+".results"
    @mainlog = @basename+".mainlog"

    @commands = []
  end

  def perform
    params_dump

    @commands << "#{JAVA_EXEC} -Xmx500m -jar #{ALI2D}/prepareAli2d.jar #{@infile} #{@basename} #{@seqident} #{@mainlog} &> #{job.statuslog_path}"

    #logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'memsat_runs'
    q.save!
    
    q.submit(@commands, false)
    


  end

  def memsat_runs

    init

    res = IO.readlines(@mainlog).map {|line| line.chomp}
    res.each do |line|
      if (line =~ /^\s*$/) then next end
      if (line =~ /^(.+)\.\.\.\.\.\.\.\.\.\.(.+)\.\.\.\.\.\.\.\.\.\.(\d+\.*\d*)$/)
        filename = $1
        percent = $3
        other = $2
        File.open(filename + ".log", "w") do |file|
          file.write("..........#{other}")
        end
        system("echo 'Sequence #{filename} is #{percent}% identical to #{other}!\n' >> #{job.statuslog_path}")
        @commands << "#{MEMSAT2}/memsat2.pl #{filename}.fas #{filename} &> #{filename}.memsat2.log"
        system("echo 'Memsat2 run for #{filename}!\n' >> #{job.statuslog_path}")
      else
        command = ". #{SETENV} ;runpsipred.pl #{line}.fas &> #{line}.log; "
        system("echo 'PSIPRED run for #{line}!\n' >> #{job.statuslog_path}")
        command += "#{MEMSAT2}/memsat2.pl #{line}.fas #{line} ; . #{UNSETENV} &> #{line}.memsat2.log;"
        system("echo 'Memsat2 run for #{line}!\n' >> #{job.statuslog_path}")
        @commands << command
      end
    end

    #logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'build_params'
    q.save!

    # each command contains  a call of memsat2.pl, which calls blastpgp -a 2 ...
    q.submit_parallel(@commands, false, { 'cpus' => '2' })
    

  end

  def build_params

    init

    @commands << "#{JAVA_EXEC} -Xmx8000m -jar #{ALI2D}/buildParams.jar #{@infile} #{@mainlog} &> #{@outfile} "

    #logger.debug "Commands:\n"+@commands.join("\n")
    #queue.submit(@commands)
    q = queue
    q.on_done = 'run_viewer'
    q.save!
    
    q.submit(@commands, false)
  end

  def run_viewer
    init
    #viewer colored with confidence
    @commands << "python #{ALI2D}/viewer.py #{@outfile} #{@outfile}_colorC color true"
    #viewer colored without confidence
    @commands << "python #{ALI2D}/viewer.py #{@outfile} #{@outfile}_color color false"
    #viewer not colored without confidence
    @commands << "python #{ALI2D}/viewer.py #{@outfile} #{@outfile}_bw bw false"
    #
    #logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end

end




