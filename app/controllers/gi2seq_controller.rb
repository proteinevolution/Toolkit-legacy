class Gi2seqController < ToolController
  
  def index
    
    @std_dbs_paths = []
    Dir.glob(File.join(DATABASES, 'standard', '*.pal')).each do |p|
      p.gsub!(/\.pal/ ,'')
      @std_dbs_paths << p
    end
    @std_dbs_paths.uniq!
    @std_dbs_paths.sort!
    ## Order up Standard databases that shall be displayed on top
    #@std_dbs_paths = order_std_dbs(@std_dbs_paths)
    @std_dbs_paths = order_std_dbs(@std_dbs_paths, ["uniprot", "nr50", "nr70", "nr90", "nr"])
    @std_dbs_labels = @std_dbs_paths.map() {|p| (File.basename(p))}

    @gi = params['gi'] ? params['gi'] : ""
    @oldjob = params['parentjob'] ? params['parentjob'] : ""

  end
  
  def results
    @fullscreen = true
    calculate_forwardings(@tool)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list
  end
  
  def gi2seq_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def gi2seq_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
end
