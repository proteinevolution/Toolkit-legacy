class MafftJob < Job
  
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
  attr_reader :num_seqs, :aln_blocks, :header, :mode
  
  # Overwrite before_results to fill you job object with result data before result display
  def before_results(controller_params)
    @num_seqs = 0
    @header = []
    @aln_blocks = []
    @mode = ""
    
    resfile = File.join(job_dir, jobid+".aln")
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
    res = IO.readlines(resfile).map {|line| line.chomp}
    
    if (res[0] =~ /CLUSTAL/)
    	# CLUSTALW format
    	@mode = "clu"
    	
    	# get the header
      @header << res.shift
    
      #get the alignment blocks
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
    
    else
      # FASTA format
      @mode = "fas"
      
      seq = ""
      res.each do |line|
        if (line =~ /^>/)
          if (!seq.empty?) then @aln_blocks.push(seq) end
          @header.push(line)
          @num_seqs += 1
          seq = ""
        else
          seq += line + "\n"
        end
      end
      if (!seq.empty?) then @aln_blocks.push(seq) end
    end
  end
end
