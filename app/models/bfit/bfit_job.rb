class BfitJob < Job
  
  @@export_ext = ".export"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  @@export_pdb = ".pdb"
  def set_export_pdb(val)
    @@export_pdb = val
  end
  def get_export_pdb
    @@export_pdb
  end

  # export results
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
  def export_pdb1
    ret = IO.readlines(File.join(job_dir, jobid + "_1_fit"+ @@export_pdb)).join
  end

  def export_pdb2
    ret = IO.readlines(File.join(job_dir, jobid + "_2_fit"+ @@export_pdb)).join
  end

  def export_ensemble
    ret = IO.readlines(File.join(job_dir, jobid + "_1_all"+ @@export_pdb)).join
  end

  
  
  # add your own data accessors for the result templates here! For example:
  # attr_reader :some_results_data
  
  
  # Overwrite before_results to fill you job object with result data before result display
  # def before_results(controller_params)
  #    @some_results_data = ">header\nsequence"
  # end
  
  
  
end