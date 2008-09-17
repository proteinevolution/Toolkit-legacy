class ViewRepeatsAction < Action
	HH = File.join(BIOPROGS, 'hhpred')

	attr_accessor :hits
	
	validates_checkboxes(:hits, {:on => :create})
	
	# Put action initialisation code in here
	def before_perform
	
		@basename = File.join(job.job_dir, job.jobid)
		@commands = []
		
		@hits = params["hits"].nil? ? Array.new() : params["hits"]
		@hits.uniq!
		@hits = @hits.join(" ")
		
		logger.debug "Hits: " + @hits		
			
	end


	# Put action code in here
	def perform

		@commands << "#{HH}/hhmakemodel.pl -v 2 -m #{@hits} -i #{@basename}.hhr -fas #{@basename}.qt.fas -q #{@basename}.a3m -conjs"

		@commands << "#{HH}/reformat.pl -l 10000 fas clu #{@basename}.qt.fas #{@basename}.qt.clu"

		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)

	end

end



