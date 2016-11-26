class GcviewController < ToolController

  def index
    @informat_values = ['fas', 'gi']
    @informat_labels = ['FASTA Sequences', 'NCBI Accession']
    @numvalues = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    @numlabels = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    @typevalues = ['genes', 'kb']
    @typelabels = ['genes', 'kilobase']
    @gi = params['gi'] ? params['gi'] : ""
    @oldjob = params['parentjob'] ? params['parentjob'] : ""
  end

  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('gcview', 'gcview'), fw_to_tool_url('gcview', 'seq2gi')]
    @fw_labels = [tool_title('gcview'), tool_title('seq2gi')]
  end

  def results_taxonomy
   @fullscreen = true
    @fw_values = [fw_to_tool_url('gcview', 'gcview'), fw_to_tool_url('gcview', 'seq2gi')]
    @fw_labels = [tool_title('gcview'), tool_title('seq2gi')]
  end

# this is needed to output the third page

#  def results_tab3
#   @fullscreen = true
#  end

  def help_results
    render(:layout => "help")
  end

end
