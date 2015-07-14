require 'fasta_reader.rb'

class HamppredController < ToolController
REFORMAT = File.join(BIOPROGS, 'reformat')

  def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @maxhhblitsit = ['0','1','2','3','4','5','8']
    @ehhblitsval = ['0.1','0.05','0.02','0.01' ,'1E-3', '1E-4', '1E-6', '1E-8', '1E-10', '1E-15', '1E-20', '1E-30', '1E-40', '1E-50']
    @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
    @qid_minval = ['0', '20', '25', '30', '35', '40', '45', '50']
    @mactval = ['0.0', '0.01', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '0.95']
    @ss_scoring_values = ['2', '0', '4']
    @ss_scoring_labels = ['yes', 'no', 'predicted vs predicted only']
    @compbiascorr_values = ['1', '0']
    @compbiascorr_labels = ['yes', 'no']
    @maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']    
    @prefilter_values = ['hhblits','psiblast']
    @prefilter_labels = ['HHblits', 'Psiblast']
    searchpat = File.join(DATABASES, 'hhpred', 'new_dbs', '*')
    dbvalues_pre = Dir.glob(searchpat)
    
    logger.debug "L 24 HamppredController #{params['sequence_input']}"

    @dbvalues = Array.new

    # Sort list of directories according to order given in sortlist 
    sortlist = Array["\/hamppred"]
    # Allow non-standard libraries only on internal server:
    if (LOCATION == "Munich" && !@user.nil? && @user.id == 2) then sortlist.push("\/hydra") end
    if (LOCATION == "Munich" && !@user.nil? && (@user.id == 119 || @user.groups.include?('admin'))) then sortlist.push("\/Proteasome") end
    sortlist.each do |el|
      dbvalues_pre.dup.each do |val|
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
    @mode = params[:mode] ? params[:mode] : 'letters'
    @hhcluster = false
    if (!@job.actions.first.flash.nil? && !@job.actions.first.flash['hhcluster'].nil?)
      @hhcluster = true
    end
    
    # Forwarding Values for other HH Tools
    @fw_values = [fw_to_tool_url('hamppred', 'hhblits')+ "&mode=querymsa",
                  fw_to_tool_url('hamppred', 'hhpred')+ "&mode=querymsa", 
                  fw_to_tool_url('hamppred', 'hhrep')+ "&mode=querymsa",  
                  fw_to_tool_url('hamppred', 'hhrepid')+ "&mode=querymsa"] 
    @fw_labels = [tool_title('hhblits'),
                  tool_title('hhpred'),
                  tool_title('hhrep'),
                  tool_title('hhrepid')]
    
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
    #@js_onload = "select_first(1);"
  end
  
  def histograms_makemodel
    @mode = 'profile_logos'
    @job.before_results(params)
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
    @fw_values = [fw_to_tool_url('hhpred', 'hhrep'), fw_to_tool_url('hhpred', 'hhrepid'),
		  fw_to_tool_url('hhpred', 'hhomp')]
    @fw_labels = [tool_title('hhrep'), tool_title('hhrepid'),
		  tool_title('hhomp')]
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
  
  def help_results
    render(:layout => "help")
  end

  def help_faq
    render(:layout => "help")
  end

  def help_params
    render(:layout => "help")
  end

  def resubmit_domain

    basename = File.join(@job.job_dir, @job.jobid)
    @my_command = "#{BIOPROGS}/perl/alicutter.pl #{basename}.resub_domain.a2m #{basename}.in.cut #{params[:domain_start].to_i} #{params[:domain_end].to_i} "
    logger.debug("Running Alicutter -hamppred- #{@my_command}")
    system(@my_command)   
    job_params = @job.actions.first.params
    job_params.sort
    job_params.each_key do |key|
      # If we stumble over sequence_input, after input has already been set from the in.cut file, it is overwritten by an empty job_params[sequence_input]
      if(key=~ /^(\S+)_input$/)
      else
        if (key =~ /^(\S+)_file$/) 
          if !job_params[key].nil? && File.exists?(job_params[key]) && File.readable?(job_params[key]) && !File.zero?(job_params[key])
            params[$1+'_input'] = File.readlines(basename+'.in.cut')
          end
        else
          params[key] = job_params[key]
        end
      end
    end

	#File.delete(basename+'.in.cut')
    params[:jobid] = ''
    index
    render(:action => 'index')
  end
 
end
