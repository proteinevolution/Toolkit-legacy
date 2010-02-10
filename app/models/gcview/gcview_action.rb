class GcviewAction < Action

  GCVIEW = File.join(BIOPROGS, 'gcview')
  BLAST = File.join(BIOPROGS, 'blast')

  attr_accessor :mail, :jobid, :sequence_input, :sequence_file

  #validates_input(:sequence_input, :sequence_file, {:informat => 'fas', :on => :create})

  validates_jobid(:jobid)

  validates_email(:mail)


  # Put action initialisation code in here
  def before_perform
    init

    @inputformat = params['informat'] ? params['informat'] : "jid"

    @colors = ['red', 'orange', 'yellow', 'darkgreen', 'green', 'lightblue', 'blue', 'violet', 'pink']

    @inputSequences = Array.new

    @db_path = File.join(GCVIEW, 'tool.db')
    @show_number = params['show_number'] ? params['show_number'] : "10"
    @show_type = params['show_type'] ? params['show_type'] : "genes"

    #logger.debug "DB path: #{@db_path}; number: #{@show_number}; type: #{@show_type}"
    logger.debug "Inputformat: #{@inputformat}"

    @input = @basename+".in"
    params_to_file(@input, 'sequence_input', 'sequence_file')

    logger.debug "Infile: #{@input}"

    @outfile = @basename

    logger.debug "Outfile: #{@outfile}"

    @configfile = @basename+".conf"


    if (@inputformat=='jid')

      parse_sequencefile

      logger.debug "\n\nArray:\n"
      for i in 0..@inputSequences.length-1
        @inputSequences[i]=@inputSequences[i].gsub(/\s+$/, '')
        logger.debug "#{@inputSequences[i]}"
      end
    end

    if (@inputformat=='fas')
      @inputSequences.push(job.jobid)
      logger.debug "#{@inputSequences[0]}"
    end

    @inputSequences_length = @inputSequences.length

    logger.debug "#{@inputSequences.length}"

    write_configfile

    #Check input format

    ### -> muss noch erledigt werden: jetzt allerdings Annahme, dass nur IDs eingegeben werden

    #if JobID: JobIDS getrennt ins Array @inputIDs speichern; Array-Laenge bestimmen

    #if (@inputformat=='jid')
    # 1) Testen, ob Jobs existieren und ob es sich um einen PsiblastJob handelt, dann in Array
    # einfuegen
         #-> erledigt: parse_sequencefile

    # 2) Arraylaenge bestimmen
    #  @inputSequences_length = @inputSequences.length  -> erledigt: in before_perform
    #if FASTA: bei Input einer Fasta-Sequenz gibt es nur ein Inputfile -> Array hat nur die Länge 1
    #else
      #Wird noch hinzugefuegt, allerdings erst nachdem der jid-Teil fertig ist ... .
    #end



    # Inputfiles aus den Psiblast-Tmp-Verzeichnissen holen + ins neue tmp-Verzeichnis speichern
    #  -> für Anzahl der Psiblast-Jobs, die verwendet werden ... .
    #for (i=0; i<@inputSequences_length; i++)



    # 1) Input Format checken:
    #   a) JobIDs: - IDs trennen
    #              - Anzahl (nicht mehr als 10)
    #              - IDs in ein Array schreiben und schauen, ob es diese ID überhaupt noch gibt
    #                (Mysql Table zu JobID die MysqlID suchen, dann mit MysqlID im tmp-Verz.
    #                schauen -> aehnlich Jobscard am li Rand)
    #                -> Anzahl der Inputfiles richtet sich nach der Anzahl der JobIDs
    #   b) FASTA: - Psiblast laufen lassen (ein Inputfile ...)
    #   c) in Array abspeichern
    # 2) Arraylaenge der Inputfiles abspeichern


  end

  def perform
    if (@inputformat=='jid')
      logger.debug "Directory: #{job.job_dir}"
      for i in 0..@inputSequences_length-1
        tmp_id=Job.find(:first, :conditions => [ "jobid = ?", @inputSequences[i]]).id
        logger.debug "JobID: #{@inputSequences[i]}; tmpID: #{tmp_id}"
        old_tmp_dir=File.join(job.job_dir, "../#{tmp_id}")
        logger.debug "Old TmpDirectory: #{old_tmp_dir}"
        old_tmp_file = File.join(old_tmp_dir, "#{@inputSequences[i]}.psiblast")
        logger.debug "File: #{old_tmp_file}"
        psiblast_file = File.join(@tmpdir, "#{@inputSequences[i]}.psiblast")
        output_file = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
        @commands << "cp #{old_tmp_file} #{@tmpdir}"
        @commands << "python #{GCVIEW}/psiblast_parser.py #{psiblast_file} #{output_file}"
      end
      #@commands << "cp "
    end

    if (@inputformat=='fas')
      psiblast_file = File.join(@tmpdir, job.jobid+".psiblast")
      database = File.join(DATABASES, "standard/nr")
      output_file = File.join(job.job_dir, "#{@inputSequences[0]}.txt")
      @commands << "#{BLAST}/blastpgp -a 4 -i #{@input} -F F -h 0.001 -s F -e 10 -M BLOSUM62 -G 11 -E 1 -j 1 -m 0 -v 100 -b 100 -T T -o #{psiblast_file} -d \"#{database}\" -I T &> #{job.statuslog_path}"
      #@commands << "#{UTILS}/shorten_psiblast_output.pl #{@outfile} #{@outfile} &> #{job.statuslog_path}_shorten_psiblast"
      @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
      
      @commands << "python #{GCVIEW}/psiblast_parser.py #{psiblast_file} #{output_file}"
    end
    @commands << "python #{GCVIEW}/tool.py #{@configfile}"
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end

  def init
    @basename = File.join(job.job_dir, job.jobid)
    @tmpdir = job.job_dir
    @outurl = job.url_for_job_dir_abs
    @commands = []
  end

  def parse_sequencefile
    @tmparray = Array.new
    idfile = File.open("#{@input}")
    idfile.each { |line| @tmparray.push(line) }
    for i in 0..@tmparray.length-1
      logger.debug "---------------------------------"
      @tmparray[i]=@tmparray[i].gsub(/\s+$/, '')
      existingjob = Job.find(:first, :conditions => [ "jobid = ?", @tmparray[i]])
      logger.debug "Existing Job: #{existingjob}, #{@tmparray[i]}"
      if existingjob
        psiblastjob = Job.find(:first, :conditions => [ "jobid = ?", @tmparray[i]]).tool
        logger.debug "Job with valid JobID: #{psiblastjob}"
        if (psiblastjob=="psi_blast")
          @inputSequences.push(@tmparray[i])
          logger.debug "Valid PsiblastJob: #{@tmparray[i]}"
          logger.debug "Arraylength: #{@inputSequences.length}"
        end
      end
      logger.debug "\n"
    end
    idfile.closed?
    idfile.close
  end

  def checkIDs
    logger.debug "Check if ID exists and is a PsiBlast-Job"
  end

  def write_configfile
    res = []
    res << "db_path=#{@db_path}\n"
    res << "show_number=#{@show_number}\n"
    res << "show_type=#{@show_type}\n"
    res << "outfile_url=#{@outurl}/\n"
    res << "outfile=#{job.jobid}\n"
    for i in 0..@inputSequences_length-1
      infile = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
      res << "infile_#{i} = #{infile}\n"#{@inputSequences[i]}.txt\n"
      res << "infile_#{i}_color = #{@colors[i]}\n"
    end

    param = File.open(@configfile, "w")
    param.write(res)
    param.close
  end
end




