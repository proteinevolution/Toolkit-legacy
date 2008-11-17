class HhpredController < ToolController

  def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @maxpsiblastit = ['0','1','2','3','4','5','6','8','10']
    @epsiblastval = ['1E-3', '1E-4', '1E-6', '1E-8', '1E-10', '1E-15', '1E-20', '1E-30', '1E-40', '1E-50']
    @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
    @qid_minval = ['0', '20', '25', '30', '35', '40', '45', '50']
    @maptval = ['0.0', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '0.95']
    @ss_scoring_values = ['2', '0', '4']
    @ss_scoring_labels = ['yes', 'no', 'predicted vs predicted only']
    @compbiascorr_values = ['1', '0']
    @compbiascorr_labels = ['yes', 'no']
    @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']    
    searchpat = File.join(DATABASES, @tool['name'], 'new_dbs', '*')
    dbvalues_pre = Dir.glob(searchpat)
    
    @dbvalues = Array.new
    
    # Sort list of directories according to order given in sortlist 
    sortlist = Array["\/pdb70", "\/pdb_on_hold", "\/scop", "\/cdd", "\/interpro_", "\/pfamA_", "\/smart", "\/panther_", "\/tigrfam", "\/pirsf", "\/COG", "\/KOG", "\/CATH", "\/supfam", "\/pfam_", "\/pfamB_", "\/cd_", "\/test56", "\/test18", "\/Pfalciparum" ]
    # Allow non-standard libraries only on internal server:
    if (ENV['RAILS_ENV'] == 'development') then sortlist.push("\w+") end
    sortlist.each do |el|
      dbvalues_pre.each do |val|
        if (!val.index(/#{el}/).nil?)
          @dbvalues.push(val)
          dbvalues_pre.delete(val)
          next;
        end
      end
    end

    @dblabels = @dbvalues.collect{|e| File.basename(e)}
    @default_db = @dbvalues[0]

    @genome_dbvalues = Array.new

    ['eucarya', 'archaea', 'bacteria'].each do |org|
      genomes_searchpat = File.join(DATABASES, @tool['name'], 'genomes', org, '*')
      genomes_dbvalues_pre = (Dir.glob(genomes_searchpat)).sort!
      @genome_dbvalues.concat(genomes_dbvalues_pre)
    end

    @genome_dblabels = @genome_dbvalues.collect{|e| File.basename(e)}

    # do we need to show output options part of the form?
    @show_more_options = (@error_params['more_options_on'] == "true")
  end
  
  def results
    @widescreen = true
    @mode = params[:mode] ? params[:mode] : 'onlySS'
    @hhcluster = false
    if (!@job.actions.first.flash.nil? && !@job.actions.first.flash['hhcluster'].nil?)
      @hhcluster = true
    end
  end
  
  def histograms
    @job.before_results(params)
    @widescreen = true
    @mode = 'profile_logos'
    @hhcluster = false
    if (!@job.actions.first.flash.nil? && !@job.actions.first.flash['hhcluster'].nil?)
      @hhcluster = true
    end
  end
  
  def results_makemodel
    @widescreen = true
    @mode = params[:mode] ? params[:mode] : 'onlySS'
    @js_onload = "select_first(1);"
  end
  
  def histograms_makemodel
    @widescreen = true
  end  
  
  def createmodel
    @widescreen = true
  end
  
  def mergeali
    @widescreen = true
  end
  
  def showalign
    @widescreen = true
  end
  
  def results_showtemplalign
    @job.actions.last.active = false
    @job.actions.last.save!
    @widescreen = true
  end
  
  def results_hhmergeali
    @widescreen = true
  end
  
  def results_hh3d_templ
    render(:layout => 'plain')
  end
  
  def results_hh3d_querytempl
    @method_values = ['sup3d', 'tmalign', 'fast']
    @method_labels = ['HHpred', 'TMalign', 'FAST']
    render(:layout => 'plain')
  end
  
  def results_export
    super
    @widescreen = true
  end
  
  def export_queryalign_to_browser
    @job.set_export_ext(".fas")
    export_to_browser
  end
  
  def export_queryalign_to_file
    @job.set_export_ext(".fas")
    export_to_file
  end
  
  def export_templalign_to_browser
    @job.set_export_ext(".template.fas")
    export_to_browser
  end
  
  def export_templalign_to_file
    @job.set_export_ext(".template.fas")
    export_to_file
  end
  
  def help_histograms
    render(:layout => "help")
  end

end
