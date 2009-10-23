class SamccController < ToolController

  def index
    informat = "pdb"
    @periodicity_values = ['7', '11', '18']
    @periodicity_labels = ['7', '11', '18']
  end

  def results
  end

  def results_plot
    #read_dir_entries
  end

  def results_numerical
  end

  def results_pdbs
  end

  def export_pdb_to_file
    function_name = @job.stripped_class_name.to_us + '_export_pdb'
    logger.debug "#{function_name}"
    if self.respond_to?(function_name) then send(function_name) end
    ret = render_to_string(:action => function_name, :layout => false)
    logger.debug "#{ret}"
    #changed the following line to be able to set own extension /Chris
    #filename = @job.class.export_basename + "." + @job.class.export_file_ext
    filename = "out.pdb"
    logger.debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{filename}"
    send_data(ret, :filename => filename, :type => @job.class.export_type)
  end

  def export_axis_to_file
    function_name = @job.stripped_class_name.to_us + '_export_axis'
    logger.debug "#{function_name}"
    if self.respond_to?(function_name) then send(function_name) end
    ret = render_to_string(:action => function_name, :layout => false)
    logger.debug "#{ret}"
    #changed the following line to be able to set own extension /Chris
    #filename = @job.class.export_basename + "." + @job.class.export_file_ext
    filename = "out_axes.pdb"
    logger.debug ">>>>>>>>>>>>>>>>>>>>>>>>#{filename}"
    send_data(ret, :filename => filename, :type => @job.class.export_type)
  end

end
