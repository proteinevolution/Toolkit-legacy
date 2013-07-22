class MsaprobsExportAction < Action
  
	attr_accessor :hits
	
	validates_checkboxes(:hits, {:on => :create})
	  
	def run
		@basename = File.join(job.job_dir, job.jobid)
    
		hits = params['hits']
		# Remove redundant hits
		hits.uniq!
    
		logger.debug "Hits: #{hits.inspect}"
		
		infile = @basename + ".aln"
		outfile = @basename + ".export"
		num = 0
    
		error if !File.readable?(infile) || !File.exists?(infile) || File.zero?(infile)
		res = IO.readlines(infile)
		out = File.new(outfile, "w+")
		    
		res.each do |line|
      	if (line =~ /^CLUSTAL/ || line =~ /^\s*$/)
      		num = 0
      		out.write(line)
      	elsif (line =~ /^\s+/)
      		next
      	else
      		if hits.include?(num.to_s)
      			out.write(line)
      		end
      		num += 1
      	end
		end
		out.close
		
		self.status = STATUS_DONE
		self.save!
		job.update_status
	end
  
	def error
		self.status = STATUS_ERROR
		self.save!
		job.update_status
	end
    
end
