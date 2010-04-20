class GcviewAction < Action

  GCVIEW = File.join(BIOPROGS, 'gcview')
  BLAST = File.join(BIOPROGS, 'blast')
  UTILS = File.join(BIOPROGS, 'perl')

  attr_accessor :mail, :jobid, :sequence_input, :sequence_file, :informat

  #validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, :on => :create})

  #validates_input(:jobid_input, {:informat => 'fas', :on => :create})

  validates_jobid(:jobid)

  validates_email(:mail)


  # Put action initialisation code in here
  def before_perform
    logger.debug "Beginn von before_perform"
    init

    @inputformat = params['informat'] ? params['informat'] : ""
    logger.debug "Inputformat: #{@inputformat}"

    @colors = ['red', 'orange', 'yellow', 'darkgreen', 'green', 'lightblue', 'blue', 'violet', 'pink']

    @inputSequences = Array.new

    @db_path = File.join(GCVIEW, 'tool.db')
    @show_number = params['show_number'] ? params['show_number'] : "10"
    @show_type = params['show_type'] ? params['show_type'] : "genes"

    @input = @basename+".in"
    params_to_file(@input, 'sequence_input', 'sequence_file', 'jobid_input')

    #logger.debug "Params seq inp: #{params.inspect}"

    if (params['sequence_input']!=nil || params['sequence_file']!=nil)
      @input_sequence = true
    else
      @input_sequence = false
    end

    if (params['jobid_input']!=nil)
      @input_jobid = true
    else
      @input_jobid = false
    end


    logger.debug "Inputsequence: #{@input_sequence}"
    logger.debug "JobID: #{@input_jobid}"

    @outfile = @basename

    @configfile = @basename+".conf"

    @mainlog = @basename+".mainlog"

    #if (@inputformat=='jid')
    if (@input_sequence == false && @input_jobid == true)
      parse_sequencefile

      for i in 0..@inputSequences.length-1
        @inputSequences[i]=@inputSequences[i].gsub(/\s+$/, '')
        logger.debug "#{@inputSequences[i]}"
      end
    end

    if (@input_sequence && !@input_jobid)
      if (@inputformat=='fas')
        #get number of sequences in order to calculate -b and -v values
        @sequence_array = Array.new
        descriptions = 0
        res = IO.readlines(@input)
        res.each do |line|
          if (line =~ /^>/)
            if (descriptions != 0)
              parameter = job.jobid.to_s+"_"+descriptions.to_s
              @inputSequences.push(parameter)
	      @sequence_array.push(@seq)
              logger.debug "Array-Input: #{@sequence_array[@sequence_array.length-1]}"
	    end
            descriptions += 1
            @seq = ''
          else
            line = line.chomp
            @seq += line
          end
        end
        parameter = job.jobid.to_s+"_"+descriptions.to_s
        @inputSequences.push(parameter)
        @sequence_array.push(@seq)
        logger.debug "Sequenzanzahl: #{descriptions}"
        logger.debug "inputSequenz: #{@inputSequences[0]}"
        logger.debug "Array-Laenge: #{@sequence_array.length}"
        for i in 0..@inputSequences.length-1
          input_file = File.join(@basename+"_#{i+1}.in")
          res = []
          res << "#{@sequence_array[i]}"
          inputf = File.open(input_file, "w")
          inputf.write(res)
          inputf.close
        end
      end

      if (@inputformat=='gi')
        descriptions = 1
        res = IO.readlines(@input)
        res.each do |line|
          inputfile = File.join(@basename+"_GI_#{descriptions}.in")
          writefile = File.open(inputfile, "w")
          writefile.write(line)
          writefile.close
          gi2seq_out = File.join(@basename+"_#{descriptions}.in")
          @commands << "#{UTILS}/seq_retrieve.pl -i #{inputfile} -o #{gi2seq_out} -d \"#{@database}\" -unique> #{@mainlog} 2> #{@mainlog}"
          parameter = job.jobid.to_s+"_"+descriptions.to_s
          @inputSequences.push(parameter)
          descriptions += 1
        end
      end
    end

    # Angabe, wie viele Inputsequences bzw. JobIDs gegeben sind
    @inputSequences_length = @inputSequences.length

    logger.debug "Length: #{@inputSequences.length}"

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
    logger.debug "In 'perform'"
    if (@input_jobid && !@input_sequence)
    #if (@inputformat=='jid')
      logger.debug "Directory: #{job.job_dir}"
      for i in 0..@inputSequences_length-1
        tmp_id=Job.find(:first, :conditions => [ "jobid = ?", @inputSequences[i]]).id
        old_tmp_dir=File.join(job.job_dir, "../#{tmp_id}")
        old_tmp_file = File.join(old_tmp_dir, "#{@inputSequences[i]}.psiblast")
        psiblast_file = File.join(@tmpdir, "#{@inputSequences[i]}.psiblast")
        output_file = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
        @commands << "cp #{old_tmp_file} #{@tmpdir}"
        @commands << "python #{GCVIEW}/psiblast_parser.py #{psiblast_file} #{output_file}"
      end
    end

    if (!@input_jobid && @input_sequence)
      if (@inputformat=='gi')
        @input = @infile
      end

      for i in 0..@inputSequences_length-1
        psiblast_file = File.join(@tmpdir, job.jobid+"_#{i+1}.psiblast")
        output_file = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
        @commands << "#{BLAST}/blastpgp -a 4 -i #{@basename}_#{i+1}.in -F F -h 0.001 -s F -e 10 -M BLOSUM62 -G 11 -E 1 -j 1 -m 0 -v 100 -b 100 -T T -o #{psiblast_file} -d \"#{@database}\" -I T &> #{job.statuslog_path}"
        @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
        @commands << "python #{GCVIEW}/psiblast_parser.py #{psiblast_file} #{output_file}"
      end
    end
    @commands << "python #{GCVIEW}/tool.py #{@configfile}"
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end

  def init
    @basename = File.join(job.job_dir, job.jobid)
    @tmpdir = job.job_dir
    @outurl = job.url_for_job_dir_abs
    @database = File.join(DATABASES, "standard/nr")
    @commands = []
  end

  def parse_sequencefile
    @tmparray = Array.new
    logger.debug "Inputfile: #{@input}"
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
      colornum = i % 9
      res << "infile_#{i} = #{@inputSequences[i]}.txt\n"
      res << "infile_#{i}_color = #{@colors[colornum]}\n"
    end

    param = File.open(@configfile, "w")
    param.write(res)
    param.close
  end
end




