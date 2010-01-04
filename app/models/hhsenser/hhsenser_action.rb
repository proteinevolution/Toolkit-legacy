class HhsenserAction < Action
  HH = File.join(BIOPROGS, 'hhpred')

  attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                    :informat => 'fas', 
                    :inputmode => 'alignment',
                    :max_seqs => 1000,
                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_shell_params(:jobid, :mail, {:on => :create})

  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @seqfile = @basename+".in"
    params_to_file(@seqfile, 'sequence_input', 'sequence_file')
    @commands = []
    @informat = params['informat'] ? params['informat'] : 'fas'
    reformat(@informat, "fas", @seqfile)
    @informat = "fas"
    
    @db = params["database"]
    @extnd = params["extnd"]
    @psiblast_eval = params["psiblast_eval"]
    @ymax = params["ymax"]
    @cov_min = params["cov_min"]

    @repr_seq = params["include_repr_seqs"] ? "" : "-nr"
    @screen = params["screen"] ? true : false
    
    @e_max = '0.1'
    @e_hmm = '1e-3'
    @maxpsiblastit = '8'
    
    @v = '2'
    
  end


  # Optional:
  # Put action initialization code that should be executed on forward here
  # def before_perform_on_forward
  # end
  
  
  def perform
    params_dump
    
    if (@screen)
      run_screening
    else
      @commands << "#{HH}/buildali.pl -v #{@v} -cpu 2 -n #{@maxpsiblastit} -e #{@psiblast_eval} -cov #{@cov_min} -maxres 500 -bl 0 -bs 0.5 -p 1E-7 -#{@informat} -db #{@db} #{@seqfile} &> #{job.statuslog_path}"
      run_hhsenser
    end

  end
  
  def run_hhsenser
    # Run the hhsenser program
    @commands << "#{HH}/buildinter.pl -v #{@v} -tmax 24:00 -Emax #{@e_max} -extnd #{@extnd} -Ymax #{@ymax} -E #{@e_hmm} -n #{@maxpsiblastit} -e #{@psiblast_eval} -cov #{@cov_min} #{@repr_seq} -db #{@db} #{@basename}.a3m >> #{job.statuslog_path} 2>&1; echo 'Hide exit state!';"

    # Prepare strict alignments
    @commands << "cp #{@basename}-X.a3m #{@basename}_strict.a3m"
    @commands << "#{HH}/reformat.pl #{@basename}_strict.a3m #{@basename}_strict.fas -v #{@v} -noss &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl #{@basename}_strict.a3m #{@basename}_strict_masterslave.fas -v #{@v} -r -noss &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl #{@basename}_strict.fas #{@basename}_strict.clu -v #{@v} -noss &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl #{@basename}_strict_masterslave.fas #{@basename}_strict_masterslave.clu -v #{@v} -noss -l 10000 -lname 32 &> #{job.statuslog_path}_reform"

    @commands << "#{HH}/hhfilter -i #{@basename}_strict.a3m -o #{@basename}_strict.reduced.a3m -diff 100 -v #{@v}"
    @commands << "#{HH}/reformat.pl a3m fas #{@basename}_strict.reduced.a3m  #{@basename}_strict.reduced.fas -v #{@v} &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl a3m fas #{@basename}_strict.reduced.a3m  #{@basename}_strict_masterslave.reduced.fas -r -v #{@v} &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl fas clu #{@basename}_strict_masterslave.reduced.fas #{@basename}_strict_masterslave.reduced.clu -v #{@v} &> #{job.statuslog_path}_reform"

    # Prepare permissive alignments
    @commands << "cp #{@basename}-Y.a3m #{@basename}_permissive.a3m"
    @commands << "#{HH}/reformat.pl #{@basename}_permissive.a3m #{@basename}_permissive.fas -v #{@v} -noss &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl #{@basename}_permissive.a3m #{@basename}_permissive_masterslave.fas -v #{@v} -r -noss &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl #{@basename}_permissive.fas #{@basename}_permissive.clu -v #{@v} -noss &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl #{@basename}_permissive_masterslave.fas #{@basename}_permissive_masterslave.clu -v #{@v} -l 10000 -lname 32 &> #{job.statuslog_path}_reform"

    @commands << "#{HH}/hhfilter -i #{@basename}_permissive.a3m -o #{@basename}_permissive.reduced.a3m -diff 100 -v #{@v}"
    @commands << "#{HH}/reformat.pl a3m fas #{@basename}_permissive.reduced.a3m #{@basename}_permissive.reduced.fas -v #{@v} &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl a3m fas #{@basename}_permissive.reduced.a3m #{@basename}_permissive_masterslave.reduced.fas -r -v #{@v} &> #{job.statuslog_path}_reform"
    @commands << "#{HH}/reformat.pl fas clu #{@basename}_permissive_masterslave.reduced.fas #{@basename}_permissive_masterslave.reduced.clu -v #{@v} &> #{job.statuslog_path}_reform"

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'queue' => QUEUES[:long]})
  end

  def run_screening
    
    run_hhpred
    
    # Read query sequence and determine its length
    resfile = @basename + ".a3m"
    return false if !File.readable?(resfile) || !File.exists?(resfile)
    @res = IO.readlines(resfile, ">")
    
    seq = ""
    @res.each do |line|
      if (line =~ /\n>$/ || line !~ />$/) 
        if (line =~ /^ss_/ || line =~ /aa_/)
          next
        else
          seq = line
          break
        end
      end
    end
    
    seq.sub!(/^(\S*).*/, '')
    name = $1
    seq.delete!("^[a-zA-Z]")
    length = seq.count("a-zA-Z")
    
    logger.debug "Sequence length: #{length}"
    
    # Make HMM file
    @commands << "echo 'Making profile HMM from alignment ...' >> #{job.statuslog_path}"
    @commands << "#{HH}/hhmake -v #{@v} -diff 100 -i #{@basename}.a3m -o #{@basename}.hhm 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    
    # Find SCOP database
    scop_db = Dir.glob(File.join(DATABASES, 'hhpred/new_dbs/scop*'))[0]
    
    # HHsearch with query HMM against SCOP database
    @commands << "echo 'Searching #{scop_db.sub(/^.*\/(.*)$/, '\1')} database ...' >> #{job.statuslog_path}"
    @commands << "#{HH}/hhsearch -cpu 2 -v #{@v} -i #{@basename}.hhm -d #{scop_db}/db/scop.hhm -o #{@basename}.hhr -global 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
    
    # Submit hhmake/hhsearch as subjob and wait
    @hash = {}
    @hash['informat'] = @informat
    @hash['db'] = @db
    @hash['extnd'] = @extnd
    @hash['psiblast_eval'] = @psiblast_eval
    @hash['ymax'] = @ymax
    @hash['repr_seq'] = @repr_seq
    @hash['e_max'] = @e_max
    @hash['e_hmm'] = @e_hmm
    @hash['maxpsiblastit'] = @maxpsiblastit
    @hash['v'] = @v
    @hash['name'] = name
    @hash['seq'] = seq
    @hash['length'] = length
    @hash['seqfile'] = @seqfile
    @hash['cov_min'] = @cov_min    
    self.flash = @hash
    self.save!
    
    logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'screening_search'
    q.save!
    q.submit(@commands, false)
  end
  
  def screening_search
    logger.debug "screening_search"
    
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    @informat = flash["informat"]
    @db = flash["db"]
    @extnd = flash["extnd"]
    @psiblast_eval = flash["psiblast_eval"]
    @ymax = flash["ymax"]
    @repr_seq = flash["repr_seq"]
    @e_max = flash["e_max"]
    @e_hmm = flash["e_hmm"]
    @maxpsiblastit = flash["maxpsiblastit"]
    @cov_min = flash["cov_min"]
    @v = flash["v"]
    
    name = flash["name"]
    seq = flash["seq"]
    length = flash["length"]
    
    @seqfile = flash["seqfile"]
    
    resfile = File.join(job.job_dir, job.jobid+".hhr")
    return false if !File.readable?(resfile) || !File.exists?(resfile)
    @res = IO.readlines(resfile)

    i = nil
    @res.each do |line|
      if (line =~ /^\s*No Hit /)
        i = @res.index(line) + 1
        break
      end 
    end
    
    #  1 1nsj   PRAI, phosphoribosyl an 100.0       0       0  427.4  25.8  198    7-210     1-204 (205)
    @res[i] =~ /(\S+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\d+)-(\d+)\s*\d+-\d+\s+\((\d+)\)\s*$/
    probab = $1.to_f
    e_value = $2.to_f
    cols = $3.to_f
    i1 = $4.to_i
    i2 = $5.to_i
    l_templ = $6.to_f

    logger.debug "Probab=#{probab}, Evalue=#{e_value}, cols=#{cols}, i1=#{i1}, i2=#{i2}, L_templ=#{l_templ}\n\n"

    # Found a SCOP domain with significance that disects the sequence?
    if (probab >= 80 && e_value <= 0.1 && cols >= (0.5 * l_templ) && (i1 > 51 || (length - i2) > 50) )
      # Show page "Your sequence contains multiple domains" with link to result of HHpred and subsequences 
      logger.debug "Multi domains!"
      # Save subsequences in files
      subseq = nil
      if (i1 > 51)
        outFile = File.new(@basename + ".subseq1", "w+")
        outFile.write(">#{name}:1 (1-#{(i1-1)})\n#{seq[0..(i1 - 2)]}\n")
        subseq = 3
      else
        i1 = 1
        subseq = 2
      end
      
      if ((length - i2) > 50)
        outFile = File.new(@basename + ".subseq#{subseq}", "w+")
        outFile.write(">#{name}:#{subseq} (#{(i2+1)}-#{length})\n#{seq[i2..-1]}\n")
      else
        i2 = length
      end
      
      subseq = subseq - 1
      outFile = File.new(@basename + ".subseq#{subseq}", "w+")
      outFile.write(">#{name}:#{subseq} (#{i1}-#{i2})\n#{seq[(i1-1)..(i2-2)]}\n")

      logger.debug "Subseqs erzeugt!"

      qj = queue_jobs.last
      qj.final = true
      qj.save!
      return
      
    else
      
      logger.debug "run hhsenser!"
      @commands << "#{HH}/buildali.pl -v #{@v} -cpu 2 -n 1 -e #{@psiblast_eval} -cov #{@cov_min} -maxres 500 -bl 0 -bs 0.5 -p 1E-7 -db #{@db} #{@basename}.a3m &> #{job.statuslog_path}"
      run_hhsenser
      
    end
  end
  
  def run_hhpred
    
    system("echo 'Waiting for HHpred to pre-screen for structural domains ...' >> #{job.statuslog_path}")
    
    scop_db = Dir.glob(File.join(DATABASES, 'hhpred/new_dbs/scop*'))[0]
    
    tf = Tempfile.new("hhsenser")
    tf.puts(IO.readlines(@seqfile).join)

    
    hhpred_params = {:controller => 'hhpred', 'jobid' => nil, 'parent' => job.jobid, 
      'increment_id' => 'true', 'reviewing' => 'true',
      'job' => 'hhpred', 'action' => 'run', 
      'sequence_input' => nil,
      'sequence_file' => tf,
      'informat' => 'fas', 'width' => '80', 'maxlines' => '100',
      'cov_min' => '20', 'Pmin' => '20', 'maxseq' => '1', 'qid_min' => '0',
      'ss_scoring' => '2', 'maxpsiblastit' => '8', 'Espiblastbal' => '1E-3',
      'alignmode' => 'global', 'hhpred_dbs' => [scop_db]}
    
    hhpred_job = Object.const_get("HhpredJob").create(hhpred_params, @user)	
    
    hhpred_job.run(nil, hhpred_params)

    while (!hhpred_job.done?) do
      sleep(1)
      hhpred_job.reload
    end

    system("echo '#{hhpred_job.jobid}' > #{@basename}.hhpred_id")
    FileUtils.cp(File.join(hhpred_job.job_dir, hhpred_job.jobid) + ".a3m", @basename + ".a3m")

  end
  
end
