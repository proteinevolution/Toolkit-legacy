class AncientDictJob < Job

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
  # attr_reader :some_results_data


  # Overwrite before_results to fill you job object with result data before result display
  def before_results(controller_params)
    f = File.join(job_dir, jobid+'.sql')
    logger.debug "path: #{f}"
    file = IO.readlines(File.join(job_dir, jobid + '.sql')).join
    logger.debug "das ist file: #{file}"
    for i in file
      logger.debug "das ist i: #{i}"
      #system(i)
    end
    system("mysql toolkit_development #{f}")
  end

end
