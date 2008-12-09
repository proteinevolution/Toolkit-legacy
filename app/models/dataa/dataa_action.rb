class DataaAction < Action

	BAD = File.join(BIOPROGS, 'dataa')

	attr_accessor :jobid, :sequence_input, :sequence_file, :mail
	
	validates_input(:sequence_input, :sequence_file, {:informat => 'fas', 
                                                     :inputmode => 'sequence',
                                                     :max_seqs => 1,
                                                     :on => :create })

	validates_jobid(:jobid)
  
	validates_email(:mail)
  
  # Put action initialisation code in here
	def before_perform
		@basename = File.join(job.job_dir, job.jobid)
		@infile = @basename    
		@outfile = @basename + ".out"
		params_to_file(@infile, 'sequence_input', 'sequence_file')
		@commands = []
		@fragcheck = params['disc'] ? "T" : "F"
	end
  
  
	# Put action code in here
	def perform
		params_dump
		
		@commands << "#{BAD}/do_search.pl -i #{@infile} -td #{job.job_dir} -id #{job.jobid} -lp '#{job.url_for_job_dir}' BIOPROGS_DIR = #{BIOPROGS} -fg #{@fragcheck} 1> #{@outfile} 2> #{job.statuslog_path}"
    
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	end

end




