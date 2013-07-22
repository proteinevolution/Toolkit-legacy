class Hmmer3Action < Action
	HMMER3 = File.join(BIOPROGS, 'hmmer3')
  if LOCATION == "Munich" && LINUX == 'SL6'
    PERL   = "perl "+File.join(BIOPROGS, 'perl')
  else
    PERL   = File.join(BIOPROGS, 'perl')
  end


	include GenomesModule
	
	attr_accessor :informat, :sequence_input, :sequence_file, :jobid, :mail, :std_dbs, :user_dbs, :taxids,
	              :hmmbuildopt, :hmmalignopt, :hmmcalibrateopt, :hmmsearchopt, :toupper, :consensus, :extracteval
                 

	validates_input(:sequence_input, :sequence_file, {:informat_field => :informat, 
                                                     :informat => 'fas', 
                                                     :inputmode => 'alignment',
						     :on => :create,
                                                     :min_seqs => 2,
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
                @infile_sto = @basename+".sto"
                @infile_hmm = @basename+".hmm"
                @outfile_tbl = @basename+".tbl"
		@outfile_domtbl = @basename+".dom"
                @outfile    = @basename+".out"
		@outfile_sto    = @basename+".sto"
                @outfile_fas    = @basename+".fas"
                @outfile_multi_sto = @basename+".mal.sto"
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
                # Generate hmm from a given input Alignment
                
                @commands << "#{PERL}/reformat.pl -i=fas -o=sto -f=#{@infile} -a=#{@infile_sto}"
                @commands << "#{HMMER3}/binaries/hmmbuild #{@infile_hmm} #{@infile_sto}"
		            @commands << "#{HMMER3}/binaries/hmmsearch #{@hmmsearchopt} --tblout #{@outfile_tbl} --domtblout #{@outfile_domtbl}  -o #{@outfile} -A #{@outfile_multi_sto}   #{@infile_hmm} #{@db_path}  "
                #@commands << "#{PERL}/reformat.pl -i=sto -o=fas -f=#{@outfile_multi_sto} -a=#{@outfile_fas}"
                @commands << "if [[ -s #{@outfile_multi_sto} ]] ; then #{PERL}/reformat.pl -i=sto -o=fas -f=#{@outfile_multi_sto} -a=#{@outfile_fas}; else echo \"Empty File\" >> #{@outfile_fas} ; fi"
                

                #@commands << "#{HMMER3}/binaries/hmmalign #{@infile_hmm} #{@db_path}  >>  #{@outfile_sto}  "
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	end

end
