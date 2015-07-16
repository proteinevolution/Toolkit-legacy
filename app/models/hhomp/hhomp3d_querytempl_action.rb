class Hhomp3dQuerytemplAction < Action
	HH = File.join(BIOPROGS, 'hhpred')
	TMALIGN = File.join(BIOPROGS, 'TMalign')
	FAST = File.join(BIOPROGS, 'fast')
	
	def do_fork?
		return false
	end
	
	def before_perform
		@basename = File.join(job.job_dir, job.jobid)
		
		@commands = []
		
		@hit = params["hit"]    # number of hit in hitlist of job
		@templpdb = params["templpdb"] # database file that contains the template pdb structure (probably in $database_dir/pdb/all/)
		@querypdb = params["querypdb"] # database file that contains the query pdb structure (probably in $basename.pdb)
		@method = params["method"].nil? ? @method = 'sup3d' : @method = params["method"]
		@rms = params["rms"].nil? ? @rms = '4' : @rms = params["rms"]		

		@aaq = ""              # query residues
		@aat = ""              # template residues
		@qfirst = nil          # index of first query residue in alignment
		@tfirst = nil          # index of first template residue in alignment

	end
	
	def before_perform_on_forward
	
		pjob = job.parent
		parent_basename = File.join(pjob.job_dir, pjob.jobid)
		FileUtils.cp(parent_basename + ".hhr", @basename + ".hhr")
		
	end
  
	def perform
		params_dump
		
		logger.debug "Methode: #{@method}"
		
		case @method
		when 'sup3d'
			sup3d
		when 'tmalign'
			tmalign
		when 'fast'
			fast
		end
		
		if (@method != "fast")
			
			# Make arrays with indices of pairs of aligned residues
			i = @tfirst.to_i
			j = @qfirst.to_i
			indexFile = File.new(@basename + ".index", "w+")
			aaq = @aaq.split(//)
			aat = @aat.split(//)
			aaq.each_index do |c|
				if (aaq[c] != "-" && aaq[c] != "." && aat[c] != "-" && aat[c] != ".") 
					indexFile.write("#{i} #{j}\n")
					i += 1
					j += 1
				elsif (aat[c] != "-" && aat[c] != ".") 
					i += 1
				elsif (aaq[c] != "-" && aaq[c] != ".") 
					j += 1 
				end
								
			end
			indexFile.close
		end
		
		# Superpose the template with the query structure and write the result into basename.templ.pdb
		command = "#{HH}/superpose3d -v 2 -col -rms #{@rms} #{@basename}.index #{@templpdb} #{@querypdb} #{@basename}.templ.pdb > #{@basename}.sup3d_out 2>&1"
		logger.debug "Command: #{command} "
		system(command)
		
		self.status = STATUS_DONE
		self.save!
		job.update_status		
	end
	
	def sup3d
	
		###############################################################
		# Open infile and parse out set of aligned residues
		lines = IO.readlines(@basename + ".hhr")		
		
		pos = 0
		lines.each do |line|
			if (line =~ /^No #{@hit}\s/)
				pos = lines.index(line) + 2
				break
			end
		end
		
		# Search for first line beginning with Q ot T and not followed by aa_, ss_pred, ss_conf, or Consensus
		while (1) do
		
			# Scan up to first line starting with Q; stop when line 'No\s+\d+' or 'Done' is found
			while (pos < lines.length && lines[pos] !~ /^Q\s\S+/) do
				if (lines[pos] =~ /^No\s+\d/ || lines[pos] =~ /^Done/) then break end
				pos += 1
				next
			end
			
			if (pos >= lines.length || lines[pos] =~ /^No\s+\d/ || lines[pos] =~ /^Done/) then break end
			
			logger.debug "first Q line"
			logger.debug "line-num: #{pos} "
			logger.debug "line: #{lines[pos]} "

			# Scan up to first line that is not secondary structure line or consensus line
			while (pos < lines.length && lines[pos] =~ /^Q\s+(ss_dssp|ss_pred|bb_pred|bb_conf|ss_conf|aa_pred|Consensus|Cons-)/ ) do
				pos += 1
			end

			logger.debug "first Q line (not ss)"
			logger.debug "line-num: #{pos} "
			logger.debug "line: #{lines[pos]} "
			
			lines[pos].scan(/^Q\s*\S+\s+(\d+)\s+(\S+)\s+\d+\s+\(\d+\)/) do |num,seq|
				if (num && seq) 
					if @qfirst.nil? then @qfirst = num end
					@aaq += seq
					pos += 1
				else
					raise "ERROR! Bad format in #{@basename}.hhr"
				end	
			end
			
			logger.debug "after Q line"
			logger.debug "line-num: #{pos} "
			logger.debug "line: #{lines[pos]} "
			
			# Scan up to first line starting with T, that is not secondary structure line or consensus line
			while (pos < lines.length && (lines[pos] !~ /^T\s+\S+/ || lines[pos] =~ /^T\s+(ss_|bb_|aa_|Consensus|Cons-)/)) do
				pos += 1
			end
			
			logger.debug "first T line"
			logger.debug "line-num: #{pos} "
			logger.debug "line: #{lines[pos]} "

			# Read next block of template sequences
			lines[pos].scan(/^T\s*\S+\s+(\d+)\s+(\S+)/) do |num,seq|
			if (num && seq) 
					if @tfirst.nil? then @tfirst = num end
					@aat += seq
					pos += 1
				else
					raise "ERROR! Bad format in #{@basename}.hhr"
				end	
			end

		end
		logger.debug "sup3d!!!"
		logger.debug "aaq: #{@aaq}"
		logger.debug "aat: #{@aat}"
	
	end
	
	def tmalign
	
		system("#{TMALIGN}/TMalign #{@querypdb} #{@templpdb} > #{@basename}.tmalign.prepare")
		lines = IO.readlines(@basename + ".tmalign.prepare")
		i = nil
		lines.each do |line|
			if (line =~ /denotes the residue pairs of distance/)  
				i = lines.index(line)
				break
			end
		end
		if i.nil? then raise "ERROR! Wrong output format!"	end
		
		@aaq = lines[i+1].chomp
		@aat = lines[i+3].chomp
		@qfirst = 1
		@tfirst = 1
		
		logger.debug "tmalign!!!"
		logger.debug "aaq: #{@aaq}"
		logger.debug "aat: #{@aat}"
	
	end
	
	def fast
	
		command = "cd #{job.job_dir}; #{FAST}/fast #{@querypdb} #{@templpdb} > #{@basename}.fastout"
		logger.debug "Command: #{command}"
		
		system(command)
		
		lines = IO.readlines(@basename + ".fastout")
		indexFile = File.new(@basename + ".index", "w+")

		lines.each do |line|
			line.scan(/^\s*(\d+)\s+\w+\s+\w\s+\w\s+\w+\s+(\d+)\s*$/) do |a,b|
				if (a && b) then indexFile.write("#{b} #{a}\n") end
			end
		end
		indexFile.close
		
		logger.debug "fast!!!"

	end	
	
end


