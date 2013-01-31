class AncesconAction < Action
  ANCESCON = File.join(BIOPROGS, 'ancescon')
  if LOCATION == "Munich" && LINUX == 'SL6'
    PERL   = "perl "+File.join(BIOPROGS, 'perl')
  else
    PERL   = File.join(BIOPROGS, 'perl')
  end

  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail, :otheradvanced

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => 'alignment',
                                                    :min_seqs => 2,
                                                    :max_seqs => 10000,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, :otheradvanced, {:on => :create})
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @seqfile = @basename+".in"
    @alnfile = @basename+".aln"
    @namesfile = @basename+".names"
    @outfile = @basename+".out"            
    params_to_file(@seqfile, 'sequence_input', 'sequence_file')
    @commands = []
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @seqfile)
    @informat = "fas"
    
    @otheradvanced = params["otheradvanced"] ? params["otheradvanced"] : ""
     
    #check other advanced options
    @options = ""
    if (@otheradvanced =~ /-o|-O/) then @options += " -O" end
    if (@otheradvanced =~ /-c|-C/) then @options += " -C" end
    if (@otheradvanced =~ /-d|-D/) then @options += " -D" end
    if (@otheradvanced =~ /-r|-R/) then @options += " -R" end
    if (@otheradvanced =~ /-ro|-RO|-R0/) then @options += " -RO" end
    if (@otheradvanced =~ /-pp|-PP/) then @options += " -PP" end
    if (@otheradvanced =~ /-pd|-PD/) then @options += " -PD" end
    if (@otheradvanced =~ /-g (\d+)/ || @otheradvanced =~ /-G (\d+)/) then @options += " -G $1" end

  end
  
  def perform
    params_dump
    
    # Ersetze Sequence Namen
    seq_num = 0
    res = IO.readlines(@seqfile)
    names = File.new(@namesfile, "w+")
    out = File.new(@seqfile, "w+")
    
    res.each do |line|
      if (line =~ /^>\s*(\S+?)\s+/)
      	name = $1
      	line = "Sequence#{seq_num}".ljust(20)
      	names.write(line + name + "\n")
      	line = ">" + line + "\n"
      	seq_num += 1
      end
      out.write(line)
    end

    names.close
    out.close
    
    reformat("fas", "clu", @seqfile)

    # CLUSTAL am Anfang des Alignments entfernen
    res = IO.readlines(@seqfile)
    res.delete_at(0)
    out = File.new(@alnfile, "w+")
    out.write(res)
    out.close
    
    #here you run the ancescon program
    @commands << "echo 'Starting Tree Generation... ' >> #{job.statuslog_path}"
    @commands << "#{ANCESCON}/ancestral -i #{@alnfile} -o #{@outfile} #{@options} &> #{job.statuslog_path}"
    @commands << "echo 'Finished Tree Generation... ' >> #{job.statuslog_path}"
    @commands << "#{PERL}/ancescontreemerger.pl -n #{@namesfile} -t #{@alnfile}.tre &> #{job.statuslog_path}"
    @commands << "echo 'Finished Tree Labeling... ' >> #{job.statuslog_path}"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
    
  end

end
