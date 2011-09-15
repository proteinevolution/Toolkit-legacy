class Hmmer3ForwardAction < Action
  
	attr_accessor :hits
	
	validates_checkboxes(:hits, {:on => :create})
	  
	def run
		@basename = File.join(job.job_dir, job.jobid)
    
		hits = params['hits']
		# Remove redundant hits
		hits.uniq!
    
		infile = @basename + ".fas"
		outfile = @basename + ".forward"
		num = 0
    
		error if !File.readable?(infile) || !File.exists?(infile) || File.zero?(infile)
		res = IO.readlines(infile)
		out = File.new(outfile, "w+")
		    
		checked = false
		res.each do |line|
			if (line =~ /^>/)
				if (hits.include?(num.to_s))
					checked = true	
				else
					checked = false
				end
				num += 1
			end
			if (checked)
				out.write(line)
			end
		end
			
		out.close
		
		self.status = STATUS_DONE
		self.save!
		job.update_status
	end
  
	def forward_params
		res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
		informat = "fas"
		{'sequence_input' => res.join, 'informat' => informat, 'inputmode' => 'alignment'}
	end
    
end
