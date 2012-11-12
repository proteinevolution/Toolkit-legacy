class ProbconsController < ToolController

  def index
  end

  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('probcons', 'ali2d'),
                  fw_to_tool_url('probcons', 'alnviz'),
                  fw_to_tool_url('probcons', 'aln2plot'),
                  fw_to_tool_url('probcons', 'ancescon'),
                  fw_to_tool_url('probcons', 'blastclust'),
                  fw_to_tool_url('probcons', 'clans'),
                  fw_to_tool_url('probcons', 'cs_blast'),
		              fw_to_tool_url('probcons', 'seq2gi'),
                  fw_to_tool_url('probcons', 'frpred'),
                  fw_to_tool_url('probcons', 'hhblits'),
                  fw_to_tool_url('probcons', 'hhomp'),
		              fw_to_tool_url('probcons', 'hhpred'),
                  fw_to_tool_url('probcons', 'hhrep'),
                  fw_to_tool_url('probcons', 'hhrepid'),
		              fw_to_tool_url('probcons', 'hhsenser'),
                  fw_to_tool_url('probcons', 'patsearch'),
                  fw_to_tool_url('probcons', 'pcoils'),
                  fw_to_tool_url('probcons', 'phylip'),
                  fw_to_tool_url('probcons', 'psi_blast'),
                  fw_to_tool_url('probcons', 'quick2_d'),
                  fw_to_tool_url('probcons', 'reformat'),
                  fw_to_tool_url('probcons', 'repper')]
                  
    @fw_labels = [tool_title('ali2d'),
                  tool_title('alnviz'),
                  tool_title('aln2plot'),
                  tool_title('ancescon'),
                  tool_title('blastclust'),
                  tool_title('clans'),
                  tool_title('cs_blast'),
		              tool_title('seq2gi'),
                  tool_title('frpred'),
                  tool_title('hhblits'),
                  tool_title('hhomp'),
                  tool_title('hhpred'),
                  tool_title('hhrep'),
                  tool_title('hhrepid'),
                  tool_title('hhsenser'),
                  tool_title('patsearch'),
                  tool_title('pcoils'),
                  tool_title('phylip'),
                  tool_title('psi_blast'),
                  tool_title('quick2_d'),
                  tool_title('reformat'),
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
