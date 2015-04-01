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
    # Prefilter Selector
    @prefilter_values = ['hhblits','psiblast']
    @prefilter_labels = ['HHblits', 'Psiblast']
    @maxhhblitsit = ['0','1','2','3','4','5','8']
    
  end

  def results_showquery
    @fw_values = [fw_to_tool_url('hhrep', 'ancescon')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'alnviz')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'aln2plot')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'cs_blast') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'seq2gi') + "&fw_mode=alignment",
                  
                  fw_to_tool_url('hhrep', 'frpred') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhalign') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhblits') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhomp') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhpred')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhrepid')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhrep')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhsenser') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'pcoils') + "&fw_mode=alignment",                  
                  fw_to_tool_url('hhrep', 'phylip') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'psi_blast') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'quick2_d') + "&fw_mode=alignment",                   
                  fw_to_tool_url('hhrep', 'reformat') + "&fw_mode=alignment",                   
                  fw_to_tool_url('hhrep', 'repper') + "&fw_mode=alignment",]
                  
    @fw_labels = [tool_title('ancescon'),
                  tool_title('alnviz'),
                  tool_title('aln2plot'),
                  tool_title('cs_blast'),
                  tool_title('seq2gi'),
                  tool_title('frpred'),
                  tool_title('hhalign'),
                  tool_title('hhblits'),
                  tool_title('hhomp'),
                  tool_title('hhpred'), 
                  tool_title('hhrepid'),
                  tool_title('hhrep'),
                  tool_title('hhsenser'),
                  tool_title('pcoils'),
                  tool_title('phylip'),
                  tool_title('psi_blast'),
                  tool_title('quick2_d'),
                  tool_title('reformat'),
                  tool_title('repper'),
                  ]
    @widescreen = true
  end
  
  def results
    @qsc        = (params["qsc"] || 0.3).to_f
    @mode       = params['mode'] || 'background'
    @widescreen = true
    
    @fw_values_msa = [fw_msa_to_tool_url('hhrepid', 'hhblits')+ "&mode=querymsa",
                      fw_msa_to_tool_url('hhrepid', 'hhpred')+ "&mode=querymsa",
                      fw_msa_to_tool_url('hhrepid', 'hhrep')+ "&mode=querymsa",
                      fw_msa_to_tool_url('hhrepid', 'hhrepid')+ "&mode=querymsa"]
                       
    @fw_labels_msa = [tool_title('hhblits'), tool_title('hhpred'), tool_title('hhrep'), tool_title('hhrepid')]
  end
  
  def help_params
    render(:layout => "help")
  end
end
