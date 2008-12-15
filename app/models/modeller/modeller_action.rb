class ModellerAction < Action
  MODELLER = File.join(BIOPROGS, 'modeller_scripts')
  MODEL_QUALITY = File.join(BIOPROGS, 'model-quality')
  MOD_BIN = File.join(BIOPROGS, 'modeller', 'bin', 'modeller')

  attr_accessor :informat, :sequence_input, :sequence_file, :modeller_key, :jobid, :mail , :own_pdb_name , :own_pdb_file

  validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                    :informat => 'fas', 
                                                    :inputmode => 'alignment',
                                                    :min_seqs => 2,
                                                    :max_seqs => 1000,
                                                    :on => :create })

  validates_jobid(:jobid)
  
  validates_email(:mail)
  
  validates_presence_of(:modeller_key, {:on => :create})
  
  validates_shell_params(:jobid, :mail, {:on => :create})
  
  # Put action initialisation code in here
  def before_perform
    
    @basename = File.join(job.job_dir, job.jobid)
    @seqfile = @basename + ".prepare"
    @infile = @basename + ".in"
    @ownpdbfile = File.join(job.job_dir, "#{params['own_pdb_name']}.pdb")
    params_to_file(@seqfile, 'sequence_input', 'sequence_file')
    params_to_file(@ownpdbfile, 'own_pdb_file')
    @commands = []
    
    @format = params["informat"].nil? ? 'fas' : params["informat"]
    
    @seq_name = "#{job.jobid}_temp";
    @local_dir = "/tmp"
    
    @modeller_key = params['modeller_key']
    @need_key = params['need_key']
    
    if (@need_key == "false")
      @modeller_key = "MODELIRANJE"
    end
    
  end
  

  # Optional:
  # Put action initialization code that should be executed on forward here
  def before_perform_on_forward
    pjob = job.parent
  end
  
  
  # Put action code in here
  def perform
    
    if job.parent.nil? 
      
      if (@format != "pir")
        reformat(@format, "fas", @seqfile)			
      
        # convert alignment in fasta-format
        command = "#{MODELLER}/pir_converter.pl -i #{@seqfile} -o #{@infile} -fas -tmp #{job.job_dir}"
        logger.debug "Command: #{command}"
        system(command)
        
      else

        command = "cp #{@seqfile} #{@infile}"
        system(command)
        
      end

      # change sequence name	
      i = nil
      lines = IO.readlines(@infile)
      lines.each do |line|
        if line =~ /^sequence:/
          i = lines.index(line)
        end
        line.sub!(/>P1;(\S\S\S\S)_\S/, '>P1;\1')
        line.sub!(/structureX:\s*(\S\S\S\S)_\S/, 'structureX:\1')		
      end
      if i.nil? then raise "ERROR! Wrong format!" end
      
      lines[i-1] = ">P1;#{@seq_name}\n"
      lines[i].gsub!(/^sequence:.*?:(.*)$/, "sequence:#{@seq_name}:"+'\1')
      
      File.open(@infile, 'w') do |file|
        file.write(lines.join(''))
      end
    else
      
      input = IO.read(@seqfile)
      
      # special character (Ascii Code 13) rauszufiltern
      input.gsub!(/\13/, '')
      
      # remove chain identifiers
      input.gsub!(/>P1;(\S\S\S\S)_\S/, '>P1;\1')
      input.gsub!(/structureX:\s*(\S\S\S\S)_\S/, 'structureX:\1')
      # change sequence name
      input.sub!(/^[^\n]*/, ">P1;#{@seq_name}")
      
      File.open(@infile, 'w') do |file|
        file.write(input)
      end
      
    end
    
    # get knowns
    knowns = ""
    knowns_h = Hash.new
    lines = IO.readlines(@infile)
    lines.each do |line|
      line.scan(/^structureX:(.*?):/) do |name|
        if (!knowns_h.has_key?(name))     
          if (knowns == "")
            knowns = "'#{name}'"
          else
            knowns += ", '#{name}'"
          end
	  knowns_h[name] = 1
        end
      end
    end
    
    # write the top-file		
    modeller_script = @basename + ".py"
    File.open(modeller_script, 'w') do |file|
      file.write("# Homology modeling by the automodel class\n")
      file.write("from modeller import *               # Load standard Modeller classes\n")
      file.write("from modeller.automodel import *     # Load the automodel class\n")
      file.write("log.verbose()\n")
      file.write("env = environ()                      # create a new MODELLER environment to build this model\n")
      file.write("# directories for input atom files\n")
      file.write("env.io.atom_files_directory = '#{DATABASES}/pdb/all:#{DATABASES}/hhomp/pdb:#{job.job_dir}'\n")
      file.write("a = automodel(env,\n")
      file.write("              alnfile  = '#{@infile}',    # alignment filename\n")
      file.write("              knowns   = (#{knowns}),       # codes of the templates\n")
      file.write("              sequence = '#{@seq_name}')  # code of the target\n")
      file.write("a.starting_model= 1                       # index of the first model\n")
      file.write("a.ending_model = 1                        # index of the last model\n")
      file.write("\n")
      file.write("a.make()                                  # do the actual homology modeling\n")
    end
    File.chmod(0777, modeller_script)		
    File.chmod(0777, @infile)		
    
		
    #here you run the modeller program
    @commands << "#{MOD_BIN} #{modeller_script} >> #{job.statuslog_path}"
    @commands << "mv #{@basename}_temp.*.pdb #{@basename}.pdb; rm -f #{@basename}_temp.*"
    @commands << "#{MODELLER}/repair_pdb.pl #{@basename}.pdb > #{@basename}.log_repair"

    # put into iMolTalk server
    ## @commands << "cd #{job.job_dir}; wget -O #{@basename}.imoltalk --post-file=#{@basename}.pdb http://protevo.eb.tuebingen.mpg.de/iMolTalk/batchupload.cgi ;\n"
 
    logger.debug "Commands:\n"+@commands.join("\n")
    q = queue
    q.on_done = 'quality_check'
    q.save!
    q.submit(@commands, false)
    
  end
  
  def quality_check

    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    # model quality
    @commands << "cd #{job.job_dir}; #{MODEL_QUALITY}/verify3d/environments > #{job.jobid}.log_verify3d << EOIN \n#{job.jobid}.pdb\n \n#{job.jobid}.env \nA \nEOIN\n"
    @commands << "ln -s #{MODEL_QUALITY}/verify3d/3d_1d.tab #{job.job_dir}/verify3d_1d.tab"
    @commands << "cd #{job.job_dir}; #{MODEL_QUALITY}/verify3d/verify_3d >> #{job.jobid}.log_verify3d << EOIN \n#{job.jobid}.env\nverify3d_1d.tab\n#{job.jobid}.plotdat\n21\n0\nEOIN\n"
    @commands << "#{MODEL_QUALITY}/verify3d/verify3d_graphics.pl #{job.jobid} #{job.job_dir} > #{@basename}.log_verify3d_graphic"
    
    @commands << "cd #{job.job_dir}; #{MODEL_QUALITY}/anolea_bin/anolea #{MODEL_QUALITY}/anolea_bin/surf.de #{MODEL_QUALITY}/anolea_bin/pair.de #{@basename}.pdb"
    @commands << "#{MODEL_QUALITY}/anolea_bin/anolea_graphics.pl #{job.jobid} #{job.job_dir} > #{@basename}.log_anolea"
    
    @commands << "ln -s #{MODEL_QUALITY}/Solvx/solvx #{job.job_dir}/solvx"
    @commands << "ln -s #{MODEL_QUALITY}/Solvx/torso.reslib #{job.job_dir}/torso.reslib"
    @commands << "echo #{@basename}.pdb | ./solvx"
    @commands << "mv #{job.job_dir}/fort.29 #{@basename}.solvx"
    @commands << "#{MODEL_QUALITY}/Solvx/solvx_graphics.pl #{job.jobid} #{job.job_dir} > #{@basename}.log_solvx"
    
    # work-around (TODO: Run commands without setting job status to error, if a command fails)
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'additional' => 'true'})

  end

end




