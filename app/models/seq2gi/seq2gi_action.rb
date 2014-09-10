class Seq2giAction < Action

	PERL = File.join(BIOPROGS, 'perl')

	attr_accessor :sequence_input, :sequence_file, :jobid, :mail

	validates_jobid(:jobid)

	validates_email(:mail)

 
	def before_perform
	
		@basename = File.join(job.job_dir, job.jobid)
		@infile = @basename+".in"
		@outfile = @basename+".out"

		params_to_file(@infile,'sequence_input','sequence_file')
		@commands = []

                @oneperline = params['oneperline'] ? true : false

	end

	def perform
		params_dump

                option = @oneperline ? "-1 " : ""

          @commands << "#{PERL}/getgis.pl #{option}#{@infile} #{@outfile} &> #{job.statuslog_path}"
	  
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)

	end

end




