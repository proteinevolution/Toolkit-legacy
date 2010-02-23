class GcviewController < ToolController

  def index
    @informat_values = ['fas', 'jid']
    @informat_labels = ['FASTA', 'Job IDs']
    @numvalues = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    @numlabels = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    @typevalues = ['genes', 'kb']
    @typelabels = ['genes', 'kilobase']
  end

  def results
    @widescreen = true
  end

  def results_taxonomy
   @fullscreen = true 
  end

  def help_results
    render(:layout => "help")
  end

end
