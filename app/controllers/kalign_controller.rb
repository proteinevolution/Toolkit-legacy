class KalignController < ToolController

  def index
    @outorder_labels = ["Input", "Tree", "Gaps"]
    @outorder_values = ["input","tree","gaps"]
  end
  
  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('kalign', 'alnviz'), fw_to_tool_url('kalign', 'blastclust'), 
                  fw_to_tool_url('kalign', 'clans'), fw_to_tool_url('kalign', 'seq2gi'),
                  fw_to_tool_url('kalign', 'fast_hmmer'), fw_to_tool_url('kalign', 'frpred'),
                  fw_to_tool_url('kalign', 'hhpred'),
                  fw_to_tool_url('kalign', 'hhsenser'), fw_to_tool_url('kalign', 'psi_blast'),
                  fw_to_tool_url('kalign', 'quick2_d'), fw_to_tool_url('kalign', 'reformat'),
                  fw_to_tool_url('kalign', 'repper')]
    @fw_labels = [tool_title('alnviz'), tool_title('blastclust'), 
                  tool_title('clans'), tool_title('seq2gi'),
                  tool_title('fast_hmmer'), tool_title('frpred'),
                  tool_title('hhpred'),
                  tool_title('hhsenser'), tool_title('psi_blast'), 
                  tool_title('quick2_d'), tool_title('reformat'), 
                  tool_title('repper')] 
    
  end
  
  def kalign_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def kalign_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
end
