class HhrepController < ToolController

	def index
    @mode = params["mode"] 
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@maxpsiblastit = ['0','1','2','4','6','8','10']
    @maxhhblitsit = ['0','1','2','3','4','5','8']
		@ss_scoring_values = ['4', '0']
		@ss_scoring_labels = ['yes', 'no']
		@maxseqval = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']   
    @prefilter_values = ['hhblits','psiblast']
    @prefilter_labels = ['HHblits', 'Psiblast']
	end
  
	def results
		@widescreen = true
		
		#added by Hippolyt
		@fw_values_msa = [
                       fw_msa_to_tool_url('hhrep', 'hhblits')+ "&mode=querymsa",
                       fw_msa_to_tool_url('hhrep', 'hhpred')+ "&mode=querymsa",
                       fw_msa_to_tool_url('hhrep', 'hhrep')+ "&mode=querymsa",
                       fw_msa_to_tool_url('hhrep', 'hhrepid')+ "&mode=querymsa"]
                       
          @fw_labels_msa = [tool_title('hhblits'), tool_title('hhpred'), tool_title('hhrep'), tool_title('hhrepid')]
	end
  
	def results_histogram
		@widescreen = true
	end
  
	def results_showquery
		@fw_values = [fw_to_tool_url('hhrep', 'ancescon')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'alnviz')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'ali2d')+ "&fw_mode=alignment",
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
                  fw_to_tool_url('hhrep', 'hmmer3')+ "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhsenser') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'modeller') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'pcoils') + "&fw_mode=alignment",                  
                  fw_to_tool_url('hhrep', 'phylip') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'psi_blast') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'quick2_d') + "&fw_mode=alignment",                   
                  fw_to_tool_url('hhrep', 'reformat') + "&fw_mode=alignment",                   
                  fw_to_tool_url('hhrep', 'repper') + "&fw_mode=alignment",
                  fw_to_tool_url('hhrep', 'hhfilter') + "&fw_mode=alignment",
                  ]
                  
		@fw_labels = [tool_title('ancescon'),
                  tool_title('alnviz'),
                  tool_title('ali2d'),
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
                  tool_title('hmmer3'),
                  tool_title('hhsenser'),
                  tool_title('modeller'),
                  tool_title('pcoils'),
                  tool_title('phylip'),
                  tool_title('psi_blast'),
                  tool_title('quick2_d'),
                  tool_title('reformat'),
                  tool_title('repper'),
                  tool_title('hhfilter'),
                  ]
    # Test of Emission and Acceptance Values of YML DATA  
    calculate_forwardings(@tool)
    add_parameters_to_selected_forwardings("&fw_mode=alignment", [4,5,6])
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list               
                  
                  
		@widescreen = true
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
	
	def view_repeats_results
		@job.actions.last.active = false
		@job.actions.last.save!
		@widescreen = true
	end 
	
	def help_tutorial
		render(:layout => "help")
	end
	
	def hhrep_reload
	
		hh = File.join(BIOPROGS, 'hhpred')
		@basename = File.join(@job.job_dir, @job.jobid)

		@ss_scoring = "-ssm " + @job.params_main_action["ss_scoring"]
		@aliwidth = @job.params_main_action["width"].to_i < 20 ? "20" : @job.params_main_action['width']
		
		@mode = params["mode"]
		@dwin = params["dwin"]
		@dthr = params["dthr"]
		@qid = params["qid"]
		@hits = params["hits"].nil? ? "" : params["hits"]
		
		hash = {}
		hash['mode'] = @mode
		hash['dwin'] = @dwin
		hash['dthr'] = @dthr
		hash['qid'] = @qid
		hash['hits'] = @hits
		
		@job.actions.first.flash = hash
		@job.actions.first.save!
		
		# Links to file
		system("rm -f #{@basename}.a3m; ln -s #{@basename}.#{@qid}.a3m #{@basename}.a3m")
		system("rm -f #{@basename}.hhm; ln -s #{@basename}.#{@qid}.hhm #{@basename}.hhm")
		system("rm -f #{@basename}.tar.gz; ln -s #{@basename}.#{@qid}.tar.gz #{@basename}.tar.gz")
		system("rm -f #{@basename}.fas; ln -s #{@basename}.#{@qid}.fas #{@basename}.fas")
		system("rm -f #{@basename}.reduced.fas; ln -s #{@basename}.#{@qid}.reduced.fas #{@basename}.reduced.fas")
		
		# hhalign HMM with itself
		logger.debug "#{hh}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 600 -v 1 -i #{@basename}.hhm -o #{@basename}.hhr -dmap #{@basename}.dmap -png #{@basename}.png -dwin #{@dwin} -dali #{@hits} -dthr #{@dthr} 1>>#{@job.statuslog_path} 2>&1"
		system("#{hh}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 600 -v 1 -i #{@basename}.hhm -o #{@basename}.hhr -dmap #{@basename}.dmap -png #{@basename}.png -dwin #{@dwin} -dali #{@hits} -dthr #{@dthr} 1>>#{@job.statuslog_path} 2>&1")
		# create png-file with factor 3
		logger.debug "#{hh}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 3 -i #{@basename}.hhm -png #{@basename}_factor3.png -dwin #{@dwin} -dali #{@hits} -dthr #{@dthr} 1>>#{@job.statuslog_path} 2>&1"
		system("#{hh}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 3 -i #{@basename}.hhm -png #{@basename}_factor3.png -dwin #{@dwin} -dali #{@hits} -dthr #{@dthr} 1>>#{@job.statuslog_path} 2>&1")

		redirect_to(:host => DOC_ROOTHOST, :controller => 'hhrep', :action => 'results', :jobid => @job)
	
	end	

	def help_results
		render(:layout => "help")
	end
  
  
end
