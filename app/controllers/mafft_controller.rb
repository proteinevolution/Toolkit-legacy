class MafftController < ToolController

  def index
  end
  
  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('mafft', 'ali2d'), fw_to_tool_url('mafft', 'alnviz'), fw_to_tool_url('mafft', 'blastclust'), 
                  fw_to_tool_url('mafft', 'clans'), fw_to_tool_url('mafft', 'seq2gi'),
                  fw_to_tool_url('mafft', 'fast_hmmer'), fw_to_tool_url('mafft', 'frpred'),
                  fw_to_tool_url('mafft', 'hhpred'),
                  fw_to_tool_url('mafft', 'hhsenser'), fw_to_tool_url('mafft', 'psi_blast'),
                  fw_to_tool_url('mafft', 'quick2_d'), fw_to_tool_url('mafft', 'reformat'), 
                  fw_to_tool_url('mafft', 'repper')]
    @fw_labels = [tool_title('ali2d'), tool_title('alnviz'), tool_title('blastclust'), 
                  tool_title('clans'), tool_title('seq2gi'),
                  tool_title('fast_hmmer'), tool_title('frpred'),
                  tool_title('hhpred'),
                  tool_title('hhsenser'), tool_title('psi_blast'), 
                  tool_title('quick2_d'), tool_title('reformat'), 
                  tool_title('repper')] 
    
  end
  
  def mafft_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def mafft_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
end
