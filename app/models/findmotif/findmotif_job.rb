class FindMotifJob < Job

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
  attr_reader :


  # Overwrite before_results to fill you job object with result data before result display
  def before_results(controller_params)
    resfile = File.join(job_dir, jobid+".aln")
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
    res = IO.readlines(resfile).map {|line| line.chomp}
    
  end
end
