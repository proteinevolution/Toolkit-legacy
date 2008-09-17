class FastHmmerController < ToolController

	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@std_dbs_paths = []
		Dir.glob(File.join(DATABASES, 'standard', '*.pal')).each do |p|
   			p.gsub!(/\.pal/ ,'') 
   			@std_dbs_paths << p
   	end    
    	@std_dbs_paths.uniq!
    	@std_dbs_paths.sort!
    	@std_dbs_labels = @std_dbs_paths.map() {|p| File.basename(p)}
	end
	
	def results
		@widescreen = true
	end
  
	def results_stockholm
		@widescreen = true
	end

	def results_fasta
		@widescreen = true
		@fw_values = [fw_to_tool_url('fast_hmmer', 'alnviz'), fw_to_tool_url('fast_hmmer', 'blastclust'),
		              fw_to_tool_url('fast_hmmer', 'clans'), fw_to_tool_url('fast_hmmer', 'seq2gi'),
		              fw_to_tool_url('fast_hmmer', 'fast_hmmer'), fw_to_tool_url('fast_hmmer', 'frpred'),
		              fw_to_tool_url('fast_hmmer', 'hhpred'),
		              fw_to_tool_url('fast_hmmer', 'hhsenser'), fw_to_tool_url('fast_hmmer', 'quick2_d'),
		              fw_to_tool_url('fast_hmmer', 'reformat'), fw_to_tool_url('fast_hmmer', 'repper')]
		@fw_labels = [tool_title('alnviz'), tool_title('blastclust'),
		              tool_title('clans'), tool_title('seq2gi'),
		              tool_title('fast_hmmer'), tool_title('frpred'),
		              tool_title('hhpred'),
		              tool_title('hhsenser'), tool_title('quick2_d'),
		              tool_title('reformat'), tool_title('repper')]
	end
	
	def export_results_to_browser
		@job.set_export_ext(".hms")
		export_to_browser
	end
  
	def export_results_to_file
		@job.set_export_ext(".hms")
		export_to_file
	end
	
	def export_stockholm_to_browser
		@job.set_export_ext(".hln")
		export_to_browser
	end
  
	def export_stockholm_to_file
		@job.set_export_ext(".hln")
		export_to_file
	end
  
	def fast_hmmer_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def fast_hmmer_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end

end
