class BlastclustJob < Job

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
  attr_reader :num_seqs, :aln_blocks, :header
  
  # Overwrite before_results to fill you job object with result data before result display
  def before_results(controller_params)
    @num_seqs = 0
    @header = []
    @aln_blocks = []
    
    resfile = File.join(job_dir, jobid+".out")
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
    res = IO.readlines(resfile).map {|line| line.chomp}
    
    sequencefile = File.join(job_dir, jobid+".fasta")
    seqs = IO.readlines(sequencefile).map {|line| line.chomp}
    
    hits = []
    res.each do |line|
    	hits << line.split(/ /)[0]
    end
    logger.debug "Hits: #{hits.inspect}"

    seqfile = File.join(job_dir, jobid+".seq")
    
    # write one sequencs of each cluster in seqfile
    check = false
    File.open(seqfile, 'w') do |file|
      seqs.each do |line|
        if (line =~ /^>(.*)$/)
          header = ($1.split(/ /))[0]
          check = false
          if (hits.include?(header) || (header =~ /gi\|(\d+)\|/ && hits.include?($1)))
            file.write(line + "\n")
            check = true
          end
        else
          if check
            file.write(line + "\n")
          end
        end
      end
    end


    # read in sequences for output
    res = IO.readlines(seqfile).map {|line| line.chomp}

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
    
    # write sequences in lines with 80 characters
    @aln_blocks.map! do |seq|
    	i = 0
    	new_seq = ""
    	while (i+80 < seq.length)
    		new_seq += seq.slice(i...i+80) + "\n"
    		i += 80
    	end
    	new_seq += seq.slice(i...i+80) + "\n"
    end
  end
end
