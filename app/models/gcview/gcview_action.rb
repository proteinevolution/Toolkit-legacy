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
    init

    @inputformat = params['informat'] ? params['informat'] : ""

    @colors = ['red', 'orange', 'yellow', 'darkgreen', 'green', 'lightblue', 'blue', 'violet', 'pink']
    #@colors = ['red', 'blue', 'yellow', 'darkgreen', 'pink', 'lightblue', 'orange', 'green', 'pink']

    @inputSequences = Array.new

    #@db_path = File.join(GCVIEW, 'tool.db')

    @db_path = File.join(DATABASES, 'gcview', 'tool.db')
    @show_number = params['show_number'] ? params['show_number'] : "10"
    @show_type = params['show_type'] ? params['show_type'] : "genes"
    @cut_off = params['evalue_cutoff'] ? params['evalue_cutoff'] : "1e-3"
    @one_line = params['one_line'] ? "1" : "0"

    @input = @basename+".in"
    params_to_file(@input, 'sequence_input', 'sequence_file', 'jobid_input')

    #logger.debug "Params seq inp: #{params.inspect}"

    @input_sequence = false
    if (params['sequence_input']!=nil || params['sequence_file']!=nil)
      @input_sequence = true
    end

    @input_jobid = false
    if (params['jobid_input']!=nil)
      @input_jobid = true
    end

    if (@cut_off =~ /^e.*$/)
      @cut_off = "1" + @cut_off
    end


    @outfile = @basename

    @configfile = @basename+".conf"

    @mainlog = @basename+".mainlog"

    @tmparray = Array.new
    @jobtype = Array.new
    @formerjob = ''

    #if (@inputformat=='jid')
    if (@input_sequence == false && @input_jobid == true)
      logger.debug "Einmal Input JobID"
      parse_sequencefile(@input)

      for i in 0..@inputSequences.length-1
        @inputSequences[i]=@inputSequences[i].gsub(/\s+$/, '')
      end
    end

    if (@input_sequence && !@input_jobid)
      logger.debug "Einmal Input Sequence oder GI"
      if (@inputformat=='fas')
	check_fasta
      end

      if (@inputformat=='gi')
        check_GI
      end
    end

    if (@input_sequence == true && @input_jobid == true)
      logger.debug "Einmal Input gemischt!"
      @input_ID = @basename + ".in2"
      params_to_file(@input_ID, 'jobid_input')

      parse_sequencefile(@input_ID)

      for i in 0..@inputSequences.length-1
        @inputSequences[i]=@inputSequences[i].gsub(/\s+$/, '')
      end

      if (@inputformat=='fas')
        check_fasta
      end

      if (@inputformat=='gi')
        check_GI
      end
    end

    

    # Angabe, wie viele Inputsequences bzw. JobIDs gegeben sind
    @inputSequences_length = @inputSequences.length
    logger.debug "InputSequences Length: #{@inputSequences_length}"

    logger.debug "Input_Sequences (before_perform): #{@inputSequences.length} "
    logger.debug "tmparray (before_perform): #{@tmparray.length}"
    logger.debug "jobtype (before_perform): #{@jobtype.length}"

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
    if (@input_jobid && !@input_sequence)
    #if (@inputformat=='jid')
      for i in 0..@inputSequences_length-1

        #tmp_id=Job.find(:first, :conditions => [ "jobid = ?", @inputSequences[i]]).id
        jobending = ''
        if (@jobtype[i] == 'psi_blast')
          jobending = 'psiblast'
        end
        if (@jobtype[i] == 'cs_blast')
          jobending = 'csblast'
        end
        if (@jobtype[i] == 'prot_blast')
          jobending = 'protblast'
	end
        if (@jobtype[i] == 'gcview')
	  tmp_id = @inputSequences[i].split('/')
	  for f in 0..tmp_id.length-1
            logger.debug "tmp_id: #{tmp_id[f]}"
	  end
          old_tmp_dir = File.join(job.job_dir, "../#{tmp_id[0]}")
	  old_tmp_file = File.join(old_tmp_dir, "#{tmp_id[1]}")
          #blast_file = File.join(@tmpdir, "#{tmp_id[1]}")
	  out_id = tmp_id[1].split('.')
          for f in 0..out_id.length-1
            logger.debug "out_id: #{out_id[f]}"
          end
	  output_file = File.join(job.job_dir, "#{out_id[0]}.txt")
	  @commands << "cp #{old_tmp_file} #{@tmpdir}"
          #@commands << "python #{GCVIEW}/psiblast_parser.py #{blast_file} #{output_file}"
        elsif (@jobtype[i] == 'psi_blast' || @jobtype[i] == 'cs_blast' || @jobtype[i] == 'prot_blast')
          tmp_id=Job.find(:first, :conditions => [ "jobid = ?", @inputSequences[i]]).id
          old_tmp_dir=File.join(job.job_dir, "../#{tmp_id}")
          old_tmp_file = File.join(old_tmp_dir, "#{@inputSequences[i]}.#{jobending}")
          blast_file = File.join(@tmpdir, "#{@inputSequences[i]}.#{jobending}")
          output_file = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
          @commands << "cp #{old_tmp_file} #{@tmpdir}"
          @commands << "python #{GCVIEW}/psiblast_parser.py #{blast_file} #{output_file}" 
        end
      end
    end

    if (!@input_jobid && @input_sequence)
      #if (@inputformat=='gi')
      #  @input = @infile
      #end

      for i in 0..@inputSequences_length-1
        psiblast_file = File.join(@tmpdir, job.jobid+"_#{i+1}.psiblast")
        output_file = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
        @commands << "#{BLAST}/blastpgp -a 4 -i #{@basename}_#{i+1}.in -F F -h 0.001 -s F -e 10 -M BLOSUM62 -G 11 -E 1 -j 1 -m 0 -v 100 -b 100 -T T -o #{psiblast_file} -d \"#{@database}\" -I T &> #{job.statuslog_path}"
        @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
        @commands << "python #{GCVIEW}/psiblast_parser.py #{psiblast_file} #{output_file} &> #{job.statuslog_path}"
      end
    end

    if (@input_jobid && @input_sequence)
      j=1
      for i in 0..@inputSequences_length-1
        if (@jobtype[i] == 'gcview')
          logger.debug @inputSequences[i]
          tmp_id = @inputSequences[i].split('/')
          for f in 0..tmp_id.length-1
            logger.debug "tmp_id: #{tmp_id[f]}"
          end
          old_tmp_dir = File.join(job.job_dir, "../#{tmp_id[0]}")
          old_tmp_file = File.join(old_tmp_dir, "#{tmp_id[1]}")
          out_id = tmp_id[1].split('.')
          for f in 0..out_id.length-1
            logger.debug "out_id: #{out_id[f]}"
          end
          output_file = File.join(job.job_dir, "#{out_id[0]}.txt")
          @commands << "cp #{old_tmp_file} #{@tmpdir}"
        elsif (@jobtype[i] == 'psi_blast' || @jobtype[i] == 'cs_blast' || @jobtype[i] == 'prot_blast')
          jobending = ''
          if (@jobtype[i] == 'psi_blast')
            jobending = 'psiblast'
          end
          if (@jobtype[i] == 'cs_blast')
            jobending = 'csblast'
          end
          if (@jobtype[i] == 'prot_blast')
            jobending = 'protblast'
            logger.debug "Jobending: #{jobending}"
          end
          tmp_id=Job.find(:first, :conditions => [ "jobid = ?", @inputSequences[i]]).id
          old_tmp_dir=File.join(job.job_dir, "../#{tmp_id}")
          old_tmp_file = File.join(old_tmp_dir, "#{@inputSequences[i]}.#{jobending}")
          blast_file = File.join(@tmpdir, "#{@inputSequences[i]}.#{jobending}")
          output_file = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
          @commands << "cp #{old_tmp_file} #{@tmpdir}"
          @commands << "python #{GCVIEW}/psiblast_parser.py #{blast_file} #{output_file}"
        else
          psiblast_file = File.join(@tmpdir, job.jobid+"_#{j}.psiblast")
          output_file = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
          @commands << "#{BLAST}/blastpgp -a 4 -i #{@basename}_#{j}.in -F F -h 0.001 -s F -e 10 -M BLOSUM62 -G 11 -E 1 -j 1 -m 0 -v 100 -b 100 -T T -o #{psiblast_file} -d \"#{@database}\" -I T &> #{job.statuslog_path}"
          @commands << "echo 'Finished BLAST search!' >> #{job.statuslog_path}"
          @commands << "python #{GCVIEW}/psiblast_parser.py #{psiblast_file} #{output_file}"
          j+=1
        end
      end
    end

    @commands << "python #{GCVIEW}/tool.py #{@configfile} &> #{job.statuslog_path}"
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

  def parse_sequencefile(inputfile)
    #@tmparray = Array.new
    #@jobtype = Array.new
    logger.debug "Inputfile (parse_sequencefile): #{inputfile}"
    idfile = File.open("#{inputfile}")
    idfile.each { |line| @tmparray.push(line) }
    for i in 0..@tmparray.length-1
      logger.debug "---------------------------------"
      @tmparray[i]=@tmparray[i].gsub(/\s+$/, '')
      existingjob = Job.find(:first, :conditions => [ "jobid = ?", @tmparray[i]])
      logger.debug "Existing Job: #{existingjob}, #{@tmparray[i]}"
      if existingjob
        @formerjob = Job.find(:first, :conditions => [ "jobid = ?", @tmparray[i]]).tool
        if (@formerjob=="psi_blast" || @formerjob=="cs_blast" || @formerjob=="prot_blast")
          @inputSequences.push(@tmparray[i])
	  @jobtype.push(@formerjob)
        elsif (@formerjob=="gcview")
          tmp_gcviewjob=Job.find(:first, :conditions => [ "jobid = ?", @tmparray[i]]).id
          tmp_id=Job.find(:first, :conditions => [ "jobid = ?", @tmparray[i]]).id
          old_tmp_dir=File.join(job.job_dir, "../#{tmp_id}")
          file = File.join(old_tmp_dir, "*.txt")
          files = Dir.glob(file)
          for j in 0..files.length-1
            files[j].gsub!(old_tmp_dir, '')
	    files[j].gsub!('/', '')
            #files[j].gsub!(".csblast", '')
	    #logger.debug "~~~ #{files[j]} ~~~"
            testfile = File.join(tmp_id.to_s, files[j])
	    @inputSequences.push(testfile)
	    @jobtype.push(@formerjob)
          end
        end
      end
      #@jobtype.push(@formerjob)
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
    res << "evalue_cutoff=#{@cut_off}\n"
    res << "one_line=#{@one_line}\n"
    res << "outfile_url=#{@outurl}/\n"
    res << "outfile=#{job.jobid}\n"
    for i in 0..@inputSequences_length-1
      if (@jobtype[i]=="gcview")
	filename = @inputSequences[i].split('/')
        for k in 0..filename.length-1
#	  logger.debug "Filename: #{filename[k]}"
	end
        jobname = filename[1].split('.')
        #infile = File.join(job.job_dir, "#{jobname[0]}.txt")
        #colornum = i % 9
        res << "infile_#{i} = #{jobname[0]}.txt\n"
      else
        #infile = File.join(job.job_dir, "#{@inputSequences[i]}.txt")
        #colornum = i % 9
        res << "infile_#{i} = #{@inputSequences[i]}.txt\n"
      end
      colornum = i % 9
      res << "infile_#{i}_color = #{@colors[colornum]}\n"
    end

    param = File.open(@configfile, "w")
    param.write(res)
    param.close
  end

  def check_fasta
    @sequence_array = Array.new
    descriptions = 0
    res = IO.readlines(@input)
    res.each do |line|
      if (line =~ /^>/)
        if (descriptions != 0)
          parameter = job.jobid.to_s+"_"+descriptions.to_s
          @inputSequences.push(parameter)
          @sequence_array.push(@seq)
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
    @jobtype.push('sequence')
    @sequence_array.push(@seq)
    for i in 0..@sequence_array.length-1#@inputSequences.length-1
      input_file = File.join(@basename+"_#{i+1}.in")
      res = []
      res << "#{@sequence_array[i]}"
      inputf = File.open(input_file, "w")
      inputf.write(res)
      inputf.close
    end
  end

  def check_GI
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
      @jobtype.push('GInumber')
      descriptions += 1
    end
  end


end




