class BlammerForwardAction < Action
  
	attr_accessor :hits
	
	validates_checkboxes(:hits, {:on => :create})
	  
	def run
		@basename = File.join(job.job_dir, job.jobid)
    
		hits = params['hits']
		# Remove redundant hits
		hits.uniq!
    
		infile = @basename + ".cln"
		outfile = @basename + ".forward"
		num = 0
    
		error if !File.readable?(infile) || !File.exists?(infile) || File.zero?(infile)
		res = IO.readlines(infile)
		out = File.new(outfile, "w+")
		    
		if (res[0] =~ /CLUSTAL/)
			#CLUSTALW format
			    
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
		else
			#FASTA format
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
			
		end
		out.close
		
		self.status = STATUS_DONE
		self.save!
		job.update_status
	end
  
	def forward_params
		res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
		informat = params['outformat']
		if (res[0] =~ /CLUSTAL/) then informat = "clu" end
		
		controller = params['forward_controller']
    if (controller == "patsearch")
      logger.debug "patsearch"
      {'db_input' => res.join, 'std_dbs' => ""}
    elsif (controller == "pcoils")
      logger.debug "pcoils"
      {'sequence_input' => res.join, 'informat' => informat, 'inputmode' => '2'}
    else
      {'sequence_input' => res.join, 'informat' => informat, 'inputmode' => 'alignment'}
    end
	end
end

