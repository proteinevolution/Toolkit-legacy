class HhompExportAction < Action
  
	attr_accessor :hits
  
	validates_checkboxes(:hits, {:on => :create})
  
	def run
		@basename = File.join(job.job_dir, job.jobid)
    
		hits = params['hits']
		# Remove redundant hits
		hits.uniq!
    
		logger.error "Hits: #{hits.inspect}"    
    
		infile = @basename + ".hhr"
		outfile = @basename + ".export"

		res = IO.readlines(infile)
		out = File.new(outfile, "w+")
    
		i = 0
		# write header
		for i in i..res.length
			out.write(res[i])
			if (res[i] =~ /^\s*No Hit/) then break end
		end
    
		# write hitlist
		for i in i..res.length
			if (res[i] =~ /^\s*$/) then break end
			if (res[i] =~ /^\s*(\d+)\s+(\S+)/)
				num = $1
				if (hits.include?(num))
					out.write(res[i])
				end
			end
		end
		out.write("\n")	
		
		# write alignment
		check = false
		for i in i..res.length
			if (res[i] =~ /^Done!/) then break end
			if (res[i] =~ /^No (\d+)/)
				num = $1
				if (hits.include?(num))
					check = true
				else
					check = false
				end
			end
			if (check)
				out.write(res[i])
			end
		end
		out.write("\nDone!\n")    
		out.close
    
		self.status = STATUS_DONE
		self.save!
		job.update_status
		@job.set_export_ext(".export")
	end
  
	def error
		self.status = STATUS_ERROR
		self.save!
		job.update_status
	end
  
end

