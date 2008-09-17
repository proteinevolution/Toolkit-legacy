class FastHmmerAction < Action
	FASTHMMER = File.join(BIOPROGS, 'fasthmmer')

	include GenomesModule
	
	attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail, :std_dbs, :user_dbs, :taxids,
	              :hmmbuildopt, :hmmalignopt, :hmmcalibrateopt, :hmmsearchopt, :toupper, :consensus, :extracteval
                 

	validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                     :informat => 'fas', 
                                                     :inputmode => 'alignment',
                                                     :max_seqs => 10000,
                                                     :on => :create })

	validates_jobid(:jobid)
  
	validates_email(:mail)
  
	validates_db(:std_dbs, {:personal_dbs => :user_dbs, :genomes_dbs => :taxids, :on => :create})
  
	validates_shell_params(:jobid, :mail, :hmmbuildopt, :hmmalignopt, :hmmcalibrateopt, :hmmsearchopt, 
	                       :extracteval, {:on => :create})
  
	def before_perform
		@basename = File.join(job.job_dir, job.jobid)
		@infile = @basename + ".in"
		params_to_file(@infile, 'sequence_input', 'sequence_file')
    
		@informat = params['informat'] ? params['informat'] : 'fas'
		reformat(@informat, "fas", @infile)
		@informat = "fas"
 
		@commands = []

		@toupper = params['toupper'] ? "t" : "f"
		@consensus = params['consensus'] ? "T" : "F"
		@hmmbuildopt = params['hmmbuildopt'] ? params['hmmbuildopt'] : ""
		@hmmalignopt = params['hmmalignopt'] ? params['hmmalignopt'] : ""
		@hmmcalibrateopt = params['hmmcalibrateopt'] ? params['hmmcalibrateopt'] : ""
		@hmmsearchopt = params['hmmsearchopt'] ? params['hmmsearchopt'] : ""
		@extracteval = params['extracteval'] ? params['extracteval'] : "100"
		
		@hmmcalibrate = @hmmcalibrateopt.empty? ? "f" : "t"

		@db_path = params['std_dbs'].nil? ? "" : params['std_dbs'].join(' ')
		@db_path = params['user_dbs'].nil? ? @db_path : @db_path + ' ' + params['user_dbs'].join(' ')
		# getDBs is part of the GenomesModule
		gdbs = getDBs('pep')
		logger.debug gdbs.join('\n')
		@db_path += ' ' + gdbs.join(' ')  
    
	end

	def perform
		params_dump

		@commands << "#{FASTHMMER}/fasthmmer --conf=#{FASTHMMER}/fasthmmer.conf --toupper=#{@toupper} --psiopt=\" -I T -e #{@extracteval} -b 1 -v 100000\" --db=\"#{@db_path}\" --dohmmc=#{@hmmcalibrate} --dohmma=t --hmmbopt=\"#{@hmmbuildopt}\" --hmmcopt=\"#{@hmmcalibrateopt}\" --hmmsopt=\"#{@hmmsearchopt}\" --hmmaopt=\"#{@hmmalignopt}\" --hmmareformat=t --infile=#{@infile} --consensus=#{@consensus} &> #{job.statuslog_path}"

		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	end

end