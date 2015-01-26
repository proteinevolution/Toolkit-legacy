class Dataa2Action < Action

    BAD2 = File.join(BIOPROGS, 'dataa2')

	attr_accessor :jobid, :sequence_input, :sequence_file, :mail,
                      :hmmfile
	
	validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
                                                     :inputmode => 'sequence',
                                                     :max_seqs => 1,
                                                     :on => :create })

	validates_jobid(:jobid)
  
	validates_email(:mail)

        validates_file(:hmmfile, { :message => "Please select an hmm file!" })
  
  # Put action initialisation code in here
	def before_perform
		@basename = File.join(job.job_dir, job.jobid)
		@infile = @basename    
		@outfile = @basename + ".out"
		params_to_file(@infile, 'sequence_input', 'sequence_file')
                @hmmfile = params['hmmfile']
		@commands = []
	end
  
  
	# Put action code in here
	def perform
		params_dump
		
          @commands << "python #{BAD2}/dataa2.py #{@infile} #{@hmmfile} #{@outfile} > #{job.statuslog_path} 2>&1"
    
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	end

end
