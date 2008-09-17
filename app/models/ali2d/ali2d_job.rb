class Ali2dJob < Job
  
  @@export_ext = ".results"
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
  
  
  attr_reader :param_keys, :param_values
  
  
  def before_results(controller_params)
    @param_keys = []
    @param_values = []
    @basename = File.join(job_dir, jobid)
    
    res = IO.readlines(@basename + ".results")
    
    res.each do |line|
      if (line =~ /^\s*(\S+): (.+)$/)
        @param_keys << $1
        @param_values << $2
      end
    end
    
  end
  
  
  
end
