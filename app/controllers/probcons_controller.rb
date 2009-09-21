class ProbconsController < ToolController

  def index
  end

  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('probcons', 'ali2d'), fw_to_tool_url('probcons', 'alnviz'), fw_to_tool_url('probcons', 'blastclust'),
                  fw_to_tool_url('probcons', 'clans'), fw_to_tool_url('probcons', 'seq2gi'),
                  fw_to_tool_url('probcons', 'fast_hmmer'), fw_to_tool_url('probcons', 'hhpred'),
                  fw_to_tool_url('probcons', 'hhsenser'), fw_to_tool_url('probcons', 'psi_blast'),
                  fw_to_tool_url('probcons', 'quick2_d'), fw_to_tool_url('probcons', 'reformat'),
                  fw_to_tool_url('probcons', 'repper')]
    @fw_labels = [tool_title('ali2d'), tool_title('alnviz'), tool_title('blastclust'),
                  tool_title('clans'), tool_title('seq2gi'),
                  tool_title('fast_hmmer'), tool_title('hhpred'),
                  tool_title('hhsenser'), tool_title('psi_blast'),
                  tool_title('quick2_d'), tool_title('reformat'),
                  tool_title('repper')]
  end
  
  def probcons_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def probcons_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
end
