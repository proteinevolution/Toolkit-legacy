class BfitController < ToolController

  def index
    @model_values = ["k", "student"]
    @model_labels = ["K distribution", "Student t distribution"]

    @optimization_values = ["em", "gibbs"]
    @optimization_labels = ["EM algorithm", "Gibbs sampling"]
  end

  def export_pdb1_to_file
    function_name = @job.stripped_class_name.to_us + '_export_pdb1'
    logger.debug "Hihihihihi #{function_name}"
    if self.respond_to?(function_name) then send(function_name) end
    ret = render_to_string(:action => function_name, :layout => false)
    logger.debug " Hallo"
    filename = "#{@job.jobid}_1.pdb"
#    if (!File.exists?(File.join(@job.job_dir, @job.jobid + "_2.pdb")))
#      filename = "#{@job.jobid}_1_all.pdb"
#    end
    logger.debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{filename}"
    send_data(ret, :filename => filename, :type => @job.class.export_type)
  end

  def export_pdb2_to_file
    function_name = @job.stripped_class_name.to_us + '_export_pdb2'
    logger.debug "Hihihihi #{function_name}"
    if self.respond_to?(function_name) then send(function_name) end
    ret = render_to_string(:action => function_name, :layout => false)
    @job.class.export_file_ext
    filename = "#{@job.jobid}_2.pdb"
    logger.debug ">>>>>>>>>>>>>>>>>>>>>>>>#{filename}"
    send_data(ret, :filename => filename, :type => @job.class.export_type)
  end

  def export_ensemble_to_file
    function_name = @job.stripped_class_name.to_us + '_export_ensemble'
    logger.debug "Hihihihi #{function_name}"
    if self.respond_to?(function_name) then send(function_name) end
    ret = render_to_string(:action => function_name, :layout => false)
    @job.class.export_file_ext
    filename = "#{@job.jobid}_1_all.pdb"
    logger.debug ">>>>>>>>>>>>>>>>>>>>>>>>#{filename}"
    send_data(ret, :filename => filename, :type => @job.class.export_type)
  end


end
