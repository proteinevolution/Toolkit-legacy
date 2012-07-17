class HhrepidController < ToolController

  def index
    @mode = params["mode"] 
    @informat_values   = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels   = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @maxpsiblastit     = ['0','1','2','4','6','8','10']
    @ss_scoring_values = ['4', '0']
    @ss_scoring_labels = ['yes', 'no']
    @ptot              = ['1e-1', '1e-2', '1e-3', '1e-4', '1e-5', '1e-6', '1e-7', '1e-8', '1e-9', '1e-10']   
    @pself             = ['1e-1', '1e-2', '1e-3', '1e-4', '1e-5', '1e-6', '1e-7', '1e-8', '1e-9', '1e-10']   
    @mergerounds       = ['0','1','2','3','4','5','6','7','8','9','10']
    @mact              = ['0.3','0.4','0.5','0.6']
  end

  def results_showquery
    @fw_values = [fw_to_tool_url('hhrepid', 'hhrepid')]
    @fw_labels = [tool_title('hhrepid')]
    @widescreen = true
  end
  
  def results
    @qsc        = (params["qsc"] || 0.3).to_f
    @mode       = params['mode'] || 'background'
    @widescreen = true
  end
  
  def help_params
    render(:layout => "help")
  end
end
