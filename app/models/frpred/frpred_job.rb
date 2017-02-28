class FrpredJob < Job
  
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
  
  
  
  attr_reader :pdb
  
  def before_results(controller_params)
    @pdb = false
    @res = []
    
    @basename = File.join(job_dir, jobid)
    
    if (File.exists?(@basename + "_pdb.html"))
      @pdb = true
    end
    
  end
end
