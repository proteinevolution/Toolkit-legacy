class HhblastController < ToolController

  def index
    @inputmode_values = ["sequence", "alignment"]
    @inputmode_labels = ["single FASTA sequence", "alignment"]
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @maxit = ['1','2','3','4','5','6','8','10']
    @epsiblastval = ['10', '100', '1000']
    @mactval = ['0.0', '0.01', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '0.95']
    @ss_scoring_values = ['2', '0', '4']
    @ss_scoring_labels = ['yes', 'no', 'predicted vs predicted only']
    @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']    
    
    @dbvalues = [File.join(DATABASES, 'standard', 'nr30cons')]
    @dbhhm = [File.join(DATABASES, 'nr30')]
    @dblabels = ['NR30']
    @default_db = @dbvalues[0]
    @default_dbhhm = @dbhhm[0]
    
    # do we need to show output options part of the form?
    @show_more_options = (@error_params['more_options_on'] == "true")
  end
  
  def results
    @widescreen = true
    @mode = params[:mode] ? params[:mode] : 'onlySS'
  end
  
  def histograms
    @widescreen = true
    @job.before_results(params)
  end
  
  def showalign
    @widescreen = true
  end
  
  def export_align_to_browser
    @job.set_export_ext(".fas")
    export_to_browser
  end
  
  def export_align_to_file
    @job.set_export_ext(".fas")
    export_to_file
  end
  
  def help_histograms
    render(:layout => "help")
  end
  
end
