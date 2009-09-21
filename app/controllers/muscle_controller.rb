class MuscleController < ToolController

  def index
    @outorder_labels = ["Group sequences by similarity","Output sequences in input order"]
    @outorder_values = ["group","stable"]
    @outformat_labels = ["FASTA format","ClustalW format"]
    @outformat_values = ["fasta","clustal"]
  end

  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('muscle', 'ali2d'), fw_to_tool_url('muscle', 'alnviz'), fw_to_tool_url('muscle', 'blastclust'),
                  fw_to_tool_url('muscle', 'clans'), fw_to_tool_url('muscle', 'seq2gi'),
                  fw_to_tool_url('muscle', 'fast_hmmer'), fw_to_tool_url('muscle', 'frpred'),
                  fw_to_tool_url('muscle', 'hhpred'),
                  fw_to_tool_url('muscle', 'hhsenser'), fw_to_tool_url('muscle', 'psi_blast'),
                  fw_to_tool_url('muscle', 'qick2_d'), fw_to_tool_url('muscle', 'reformat'),
                  fw_to_tool_url('muscle', 'repper')]
    @fw_labels = [tool_title('ali2d'), tool_title('alnviz'), tool_title('blastclust'),
                  tool_title('clans'), tool_title('seq2gi'),
                  tool_title('fast_hmmer'), tool_title('frpred'),
                  tool_title('hhpred'),
                  tool_title('hhsenser'), tool_title('psi_blast'),
                  tool_title('quick2_d'), tool_title('reformat'),
                  tool_title('repper')]

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
