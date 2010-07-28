class Gi2seqController < ToolController
  
  def index
    
    @std_dbs_paths = []
    Dir.glob(File.join(DATABASES, 'standard', '*.pal')).each do |p|
      p.gsub!(/\.pal/ ,'')
      @std_dbs_paths << p
    end
    @std_dbs_paths.uniq!
    @std_dbs_paths.sort!
    @std_dbs_labels = @std_dbs_paths.map() {|p| (File.basename(p))}
    
  end
  
  def results
    @fw_values = [fw_to_tool_url('gi2seq', 'blastclust'), fw_to_tool_url('gi2seq', 'clans'), 
                  fw_to_tool_url('gi2seq', 'clustalw'), fw_to_tool_url('gi2seq', 'kalign'),
                  fw_to_tool_url('gi2seq', 'mafft'), fw_to_tool_url('gi2seq', 'muscle'),		              
                  fw_to_tool_url('gi2seq', 'patsearch'), fw_to_tool_url('gi2seq', 'probcons'),		              		              
                  fw_to_tool_url('gi2seq', 'reformat'), fw_to_tool_url('gi2seq', 'clubsubp')]
    @fw_labels = [tool_title('blastclust'), tool_title('clans'), 
                  tool_title('clustalw'), tool_title('kalign'),
                  tool_title('mafft'), tool_title('muscle'),
                  tool_title('patsearch'), tool_title('probcons'),		              		              
                  tool_title('reformat'), tool_title('clubsubp')] 
    @fullscreen = true
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
