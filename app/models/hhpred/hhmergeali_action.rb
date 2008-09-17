class HhmergealiAction < Action
	HH = File.join(BIOPROGS, 'hhpred')
	
	attr_accessor :hits
	
	validates_checkboxes(:hits, {:on => :create})
	
	def before_perform
		@basename = File.join(job.job_dir, job.jobid)
		
		seqs   = params["hits"]
		
		@commands = []
		
		# Remove redundant hits
		@seqs = seqs.split(' ')		
		@seqs = @seqs.uniq.join(' ')
		
		@dirs = Dir.glob(File.join(DATABASES, 'hhpred/new_dbs/*')).join(' ');
		logger.debug "Dirs: #{@dirs}"
					
	end
	
	def before_perform_on_forward
	
		pjob = job.parent
		@parent_basename = File.join(pjob.job_dir, pjob.jobid)
		@parent_jobdir = pjob.job_dir
	
	end
  
	def perform
		params_dump
		
		# Make FASTA alignment from query and selected templates (from hhr file). -N: use $parentId as query name 
		@commands << "#{HH}/hhmakemodel.pl -v 2 -N -m #{@seqs} -i #{@parent_basename}.hhr -fas #{@basename}.qt.fas -q #{@parent_basename}.a3m";

		# Merge all alignments whose sequences are given in $basename.qt.fas
		@commands << "#{HH}/mergeali.pl #{@basename}.qt.fas #{@basename}.qt.a3m -d #{@parent_jobdir} #{@dirs} -diff 100 -mark";

		@commands << "#{HH}/hhfilter -diff 100 -i #{@basename}.qt.a3m -o #{@basename}.qt.reduced.a3m";

		@commands << "#{HH}/reformat.pl a3m fas -r -noss #{@basename}.qt.reduced.a3m #{@basename}.qt.reduced.fas";
		@commands << "#{HH}/reformat.pl a3m fas -noss #{@basename}.qt.a3m #{@basename}.qt.fas";
		
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
		
	end
	
end


