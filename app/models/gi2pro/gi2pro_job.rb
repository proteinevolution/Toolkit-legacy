class Gi2proJob < Job
  
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
    @results = ""
    
    res = IO.readlines(@basename + ".out").map {|line| line.chomp}
    res.each do |line|
    
      if (line =~ /^>/)
        @results += line + "\n"
      else
        i = 0
        while ((i+80) < line.length)
          @results += line.slice(i, 80) + "\n"
          i += 80
        end
        if (i < line.length)
          @results += line.slice(i..-1) + "\n"
        end
      end
    
    end
    
  
  end
  
  
  
end
