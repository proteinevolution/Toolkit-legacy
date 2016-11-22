class HhmakemodelForwardAction < Action
	
	def run
		@basename = File.join(job.job_dir, job.jobid)
		
		@seq = params['hits']
		
		@commands = []
		@commands << "source #{SETENV}"

		#hhmakemodel aufrufen	
		#old: @commands << "#{HH}/hhmakemodel.pl #{@basename}.hhr -m #{@seq} -q #{@basename}.a3m -v 2 -pir #{@basename}.forward 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
		@commands << "checkTemplates.pl -i #{@basename}.hhr -q #{@basename}.a3m -pir #{@basename}.forward -m #{@seq}  1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"    
	
        @commands << "source #{UNSETENV}"    
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	end
	
	def forward_params
		res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
		{'sequence_input' => res.join, 'informat' => 'pir'}
	end
	
end


