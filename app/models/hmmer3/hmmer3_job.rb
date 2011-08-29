class Hmmer3Job < Job
  
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
  
  
  attr_reader :headers, :seqs, :num_seqs
  
  def before_results(controller_params)
    @num_seqs = 0
    @headers = []
    @seqs = []
    
    resfile = File.join(job_dir, jobid+".fas")
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile)
    return if File.zero?(resfile)
    res = IO.readlines(resfile).map {|line| line.chomp}
    
    seq = ""
    res.each do |line|
      if (line =~ /^>/)
        if (!seq.empty?) then @seqs << seq end
        @headers << line
        @num_seqs += 1
        seq = ""
      else
        i = 0
        while (i < line.size)
          seq += line.slice(i, 100) + "\n"
          i += 100
        end
      end
    end
    if (!seq.empty?) then @seqs << seq end
  end
  
end
