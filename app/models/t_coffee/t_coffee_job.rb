class TCoffeeJob < Job
  
  @@export_ext = ".export"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
  
  
  # add your own data accessors for the result templates here! For example:
  attr_reader :html_data, :num_seqs, :aln_blocks, :header, :fasta_seqs, :fasta_headers, :pdf_file
  
  
  
  # Overwrite before_results to fill you job object with result data before result display
	def before_results(controller_params)
      read_score_html(File.join(job_dir, "#{jobid}.score_html"))
		read_clustal(File.join(job_dir, jobid+".clustalw_aln"))
		@pdf_file = File.join(url_for_job_dir_abs, "#{jobid}.score_pdf")
	end
  
	def read_score_html(file)
		@html_data = IO.readlines(file)
      0.upto(@html_data.size){ |i|
      	if( @html_data[i] =~ /SPAN\s*\{\s*font-family:\s*courier\s*new,\s*courier-new,\s*courier;\s*font-weight:\s*bold;\s*font-size:\s*11pt;\}/ ) 
      		@html_data[i] = ""
      		break
      	end  	 
      }
		@html_data = @html_data.join
	end  
  
	def read_clustal(file)
    res = IO.readlines(file).map {|line| line.chomp}
    
    # get the header
    @header = res.shift
    @num_seqs = 0
    #get the alignment blocks
    @aln_blocks = []
    block = []
    num = 0
    res.each do |line|
      if (line =~ /^\s*$/)
        if (!block.empty?)
          @aln_blocks.push(block)
          block = []
          if (@num_seqs == 0) then @num_seqs = num end
          num = 0
        end
        next
      end
      # get the number of sequences
		if (line !~ /^\s+/) then num += 1 end
      block.push(line)
    end   
    if (!block.empty?)
      @aln_blocks.push(block)
    end

	end
  
	def read_fasta(file)
		@fasta_headers = []
		@fasta_seqs = []
		res = IO.readlines(file).map {|line| line.chomp}
    	seq = ""
    	res.each do |line|
    		if (line =~ /^>/)
				if (!seq.empty?) then @fasta_seqs.push(seq) end
				@fasta_headers.push(line)
				seq = ""
			else
				seq += line + "\n"
			end
		end
		if (!seq.empty?) then @fasta_seqs.push(seq) end
	end  
  
end