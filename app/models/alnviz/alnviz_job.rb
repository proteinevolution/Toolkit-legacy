class AlnvizJob < Job
  
  @@export_ext = ".out"
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
  
  
  
  attr_reader :results
  
  def before_results(controller_params)
    
    @basename = File.join(job_dir, jobid)
    
    @results = []
    
    resfile = @basename + ".out"
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile)
    res = IO.readlines(resfile).map {|line| line.chomp}
    
    res.each do |line|
	   if (line =~ /^\s*$/) then @results << line end
	   if (line =~ /^\S+\s+(\S+)/)
	     seq = $1
	     old_seq = $1
        seq.gsub!(/([WYF]+)/, '<span style="background-color: #00c000;">\1</span>')
        seq.gsub!(/(C+)/, '<span style="background-color: #ffff00;">\1</span>')
        seq.gsub!(/([DE]+)/, '<span style="background-color: #6080ff;">\1</span>')
        seq.gsub!(/([LIVM]+)/, '<span style="background-color: #02ff02;">\1</span>')
        seq.gsub!(/([KR]+)/, '<span style="background-color: #ff0000;">\1</span>')
        seq.gsub!(/([QN]+)/, '<span style="background-color: #e080ff;">\1</span>')
        seq.gsub!(/(H+)/, '<span style="background-color: #ff8000;">\1</span>')
        seq.gsub!(/(P+)/, '<span style="background-color: #a0a0a0;">\1</span>')
        
        line.sub!(/#{old_seq}/, "#{seq}")
        @results << line
      end
    end
  end
end
