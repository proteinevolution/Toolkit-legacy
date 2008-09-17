class BlammerController < ToolController

	def index
		@outformat_labels = ["FASTA format","ClustalW format"]
		@outformat_values = ["fasta","clustal"]
	end
	
	def results
		@fullscreen = true
		@fw_values = [fw_to_tool_url('blammer', 'alnviz'), fw_to_tool_url('blammer', 'blastclust'), 
		              fw_to_tool_url('blammer', 'clans'), fw_to_tool_url('blammer', 'seq2gi'),
		              fw_to_tool_url('blammer', 'fast_hmmer'), fw_to_tool_url('blammer', 'frpred'),
		              fw_to_tool_url('blammer', 'hhpred'),
		              fw_to_tool_url('blammer', 'hhsenser'), fw_to_tool_url('blammer', 'psi_blast'),
		              fw_to_tool_url('blammer', 'quick2_d'), fw_to_tool_url('blammer', 'reformat'), 
		              fw_to_tool_url('blammer', 'repper')]
		@fw_labels = [tool_title('alnviz'), tool_title('blastclust'), 
		              tool_title('clans'), tool_title('seq2gi'),
		              tool_title('fast_hmmer'), tool_title('frpred'),
		              tool_title('hhpred'),
		              tool_title('hhsenser'), tool_title('psi_blast'), 
		              tool_title('quick2_d'), tool_title('reformat'), 
		              tool_title('repper')] 
 
	end
	
	def blammer_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def blammer_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
end
