class HhompMakemodelAction < Action
	HH = File.join(BIOPROGS, 'hhomp')
	
	attr_accessor :hits
	
	validates_checkboxes(:hits, {:on => :create})
	
	
	def before_perform
		@basename = File.join(job.job_dir, job.jobid)

		hits = params['hits']		
		
		@hits = hits.uniq
		@hits = @hits.join(" ")
		
		@commands = []
	end
	 	
  	def before_perform_on_forward
		pjob = job.parent
		@parent_basename = File.join(pjob.job_dir, pjob.jobid)
		@parent_jobdir = pjob.job_dir
		
		FileUtils.copy_file("#{@parent_basename}.a3m", "#{@basename}.a3m")		
		FileUtils.copy_file("#{@parent_basename}.hhm", "#{@basename}.hhm")
		
	end
  
	def perform
		params_dump
		
		# hhomp_makemodel aufrufen
		@commands << "#{HH}/hhomp_makemodel.pl -v 2 -m #{@hits} -d '#{File.join(DATABASES, 'pdb', 'all')} #{File.join(DATABASES, 'hhomp', 'pdb')}' -i #{@parent_basename}.hhr -pir #{@basename}.prepare_out"

		# update PIR-file by deleting columns at the begin and the end, if there are no Templates
		@commands << "#{HH}/update_pir.pl -i #{@basename}.prepare_out -o #{@basename}.out -n #{@basename}.note"

		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	end
	
	def forward_params
		@basename = File.join(job.job_dir, job.jobid)
		@hash = { 'sequence_input' => IO.readlines(@basename + ".out").join, 'informat' => 'pir' } 
		if (File.exists?(@basename + ".note") && !File.zero?(@basename + ".note"))
			@hash['note'] = IO.readlines(@basename + ".note").join
		end
		return @hash
	end
	
end


