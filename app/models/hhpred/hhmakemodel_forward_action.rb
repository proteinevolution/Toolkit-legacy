class HhmakemodelForwardAction < Action
	HH = File.join(BIOPROGS, 'hhpred')
	
	def run
		@basename = File.join(job.job_dir, job.jobid)
		
		@seq = params['hits']
		
		@commands = []
		
		# hhmakemodel aufrufen	
		@commands << "#{HH}/hhmakemodel.pl #{@basename}.hhr -m #{@seq} -q #{@basename}.a3m -v 2 -pir #{@basename}.forward 1>> #{job.statuslog_path} 2>> #{job.statuslog_path}"
		
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	end
	
	def forward_params
		res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
		{'sequence_input' => res.join, 'informat' => 'pir'}
	end
	
end


