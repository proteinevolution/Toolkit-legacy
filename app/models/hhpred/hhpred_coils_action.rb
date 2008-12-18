class HhpredCoilsAction < Action
	HH = File.join(BIOPROGS, 'hhpred')
  
  	def do_fork?
    	return false
  	end
  
  	def perform
   	@basename = File.join(job.job_dir, job.jobid)
    	@infile = @basename+".a3m"
    	@prepfile = @basename+"_filtered_for_coils.a3m" 
    	@outfile = @basename+"_filtered_for_coils.fas"
    	@commands = []
		# Filter query alignment		
		@commands << "#{HH}/hhfilter -i #{@infile} -o #{@prepfile} -qsc 0.7 -diff 0 &> /dev/null"
		
		# Reformat
		@commands << "#{HH}/reformat.pl a3m fas #{@prepfile} #{@outfile} -r -noss &> /dev/null"
		
		logger.debug "Commands:\n"+@commands.join("\n")
    	queue.submit(@commands, true, {'queue' => :immediate})	
  	end
  
  	def forward_params
    	hash = {}
    	res = IO.readlines(File.join(job.job_dir, job.jobid + "_filtered_for_coils.fas")).join()
    	hash = { 'sequence_input' => res, 'inputmode' => '1' }
  	end
end


