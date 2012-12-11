class MuscleController < ToolController

  def index
    @outorder_labels = ["Group sequences by similarity","Output sequences in input order"]
    @outorder_values = ["group","stable"]
    @outformat_labels = ["FASTA format","ClustalW format"]
    @outformat_values = ["fasta","clustal"]
  end

  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('muscle', 'ali2d'),
                  fw_to_tool_url('muscle', 'alnviz'),
                  fw_to_tool_url('muscle', 'aln2plot'),
                  fw_to_tool_url('muscle', 'ancescon'),
                  fw_to_tool_url('muscle', 'blastclust'),
                  fw_to_tool_url('muscle', 'clans'),
                  fw_to_tool_url('muscle', 'cs_blast'),
                  fw_to_tool_url('muscle', 'seq2gi'),
                  fw_to_tool_url('muscle', 'frpred'),
                  fw_to_tool_url('muscle', 'hhblits'),
                  fw_to_tool_url('muscle', 'hhomp'),
                  fw_to_tool_url('muscle', 'hhpred'),
                  fw_to_tool_url('muscle', 'hhrep'),
                  fw_to_tool_url('muscle', 'hhrepid'),
                  fw_to_tool_url('muscle', 'hhsenser'),
                  fw_to_tool_url('muscle', 'patsearch'),
                  fw_to_tool_url('muscle', 'pcoils'),
                  fw_to_tool_url('muscle', 'phylip'),
                  fw_to_tool_url('muscle', 'psi_blast'),
                  fw_to_tool_url('muscle', 'quick2_d'),
                  fw_to_tool_url('muscle', 'reformat'),
                  fw_to_tool_url('muscle', 'repper')]
                  
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
    # Test of Emission and Acceptance Values of YML DATA  
    calculate_forwardings(@tool)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list 

  end

  def muscle_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end

  def muscle_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end

end
