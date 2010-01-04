class KalignForwardAction < Action

	attr_accessor :hits

	validates_checkboxes(:hits, {:on => :create})

	def run
		@basename = File.join(job.job_dir, job.jobid)

		hits = params['hits']
		# Remove redundant hits
		hits.uniq!

		infile = @basename + ".aln"
		outfile = @basename + ".forward"
		num = 0

		error if !File.readable?(infile) || !File.exists?(infile) || File.zero?(infile)
		res = IO.readlines(infile)
		out = File.new(outfile, "w+")

		checked = false
		@format = ''
		res.each do |line|
			# for the case, that the output is in clustal format
			line.gsub!('Kalign', 'CLUSTAL') # the clustal validator requires to have 'CLUSTAL' as first word in the first line
			if (line =~ /^CLUSTAL/ || line =~ /^\s*$/)
                                @format = 'clu'
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

			# for the case, that the output is in fasta format
			if (line =~ /^>/)
				@format = 'fas'
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
		if (@format=='fas')
			{'sequence_input' => res.join, 'informat' => 'fas', 'inputmode' => 'alignment'}
		elsif (@format=='clu')
			{'sequence_input' => res.join, 'informat' => 'clu', 'inputmode' => 'alignment'}
		else
			{'sequence_input' => res.join, 'informat' => 'clu', 'inputmode' => 'alignment'}
		end
	end

end

