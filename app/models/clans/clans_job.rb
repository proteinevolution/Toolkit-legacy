class ClansJob < Job
  
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
  
  
  
  attr_reader :max_num
  
  
  def before_results(controller_params)
    @basename = File.join(job_dir, jobid)
    @pvalfile = @basename + "_pplot"
    res = IO.readlines(@pvalfile)
    
    @max_num = 0.0
    res.each do |line|
      if (line =~ /(\S+)\s+\d+/)
      	num = $1.to_f
      	@max_num = (@max_num < num) ? num : @max_num      
      end
    end
    
  end
  
  
  
end
