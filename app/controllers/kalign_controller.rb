class KalignController < ToolController

  def index
    @outorder_labels = ["Input", "Tree", "Gaps"]
    @outorder_values = ["input","tree","gaps"]
  end

  def results
    @fullscreen = false
    @fw_values = [fw_to_tool_url('kalign', 'ali2d'),
                  fw_to_tool_url('kalign', 'alnviz'),
                  fw_to_tool_url('kalign', 'aln2plot'),
                  fw_to_tool_url('kalign', 'ancescon'),
                  fw_to_tool_url('kalign', 'blastclust'),
                  fw_to_tool_url('kalign', 'clans'),
                  fw_to_tool_url('kalign', 'cs_blast'),
                  fw_to_tool_url('kalign', 'seq2gi'),
                  fw_to_tool_url('kalign', 'frpred'),
                  fw_to_tool_url('kalign', 'hhblits'),
                  fw_to_tool_url('kalign', 'hhomp'),
                  fw_to_tool_url('kalign', 'hhpred'),
                  fw_to_tool_url('kalign', 'hhrep'),
                  fw_to_tool_url('kalign', 'hhrepid'),
                  fw_to_tool_url('kalign', 'hhsenser'),
                  fw_to_tool_url('kalign', 'pcoils'),
                  fw_to_tool_url('kalign', 'phylip'),
                  fw_to_tool_url('kalign', 'psi_blast'),
                  fw_to_tool_url('kalign', 'quick2_d'),
                  fw_to_tool_url('kalign', 'reformat'),
                  fw_to_tool_url('kalign', 'repper')]
                  
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
                  tool_title('pcoils'),
                  tool_title('phylip'),
                  tool_title('psi_blast'),
                  tool_title('quick2_d'),
                  tool_title('reformat'),
                  tool_title('repper')]
                  
    # Test of Emission and Acceptance Values of YML DATA  
    calculate_forwardings(@tool)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list              
                  

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
