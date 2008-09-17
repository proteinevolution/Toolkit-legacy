class Gi2seqJob < Job
  
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
  
  
  attr_reader :summary, :num_seqs, :header, :aln_blocks
  
  
  def before_results(controller_params)
  
    @basename = File.join(job_dir, jobid)

    @summary = "<table>\n"
    
    res = IO.readlines(@basename + ".mainlog").map {|line| line.chomp}
    
    num = res.index("Summary:") + 1
    
    for i in num...res.size
      res[i].sub!(/(\d+)/, '')
      num = $1.to_i
      @summary += "<tr><td>" + res[i] + "</td><td align=\"right\">"
      if (res[i] =~ /unretrievable/ && num > 0)
        @summary += "<font style=\"color: red; font-weight: bold;\">" + num.to_s + "</font>\n"
      else
        @summary += num.to_s + "\n"
      end
      @summary += "</td></tr>\n"
    end
    
    @summary += "</table>\n"
    
    
    @num_seqs = 0
    @header = []
    @aln_blocks = []
    
    res = IO.readlines(@basename + ".out").map {|line| line.chomp}
    
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

