class ClustalwController < ToolController

	def index
	end
	
	def results
		@fw_values = [fw_to_tool_url('clustalw', 'alnviz'), fw_to_tool_url('clustalw', 'ancescon'), fw_to_tool_url('clustalw', 'blastclust'), 
		              fw_to_tool_url('clustalw', 'clans'), fw_to_tool_url('clustalw', 'seq2gi'),
		              fw_to_tool_url('clustalw', 'fast_hmmer'), fw_to_tool_url('clustalw', 'frpred'),
		              fw_to_tool_url('clustalw', 'hhpred'),
		              fw_to_tool_url('clustalw', 'hhsenser'), fw_to_tool_url('clustalw', 'phylip'), fw_to_tool_url('clustalw', 'psi_blast'),
		              fw_to_tool_url('clustalw', 'quick2_d'), fw_to_tool_url('clustalw', 'reformat'), 
		              fw_to_tool_url('clustalw', 'repper')]
		@fw_labels = [tool_title('alnviz'), tool_title('ancescon'), tool_title('blastclust'), 
		              tool_title('clans'), tool_title('seq2gi'),
		              tool_title('fast_hmmer'), tool_title('frpred'),
		              tool_title('hhpred'),
		              tool_title('hhsenser'), tool_title('phylip'), tool_title('psi_blast'), 
		              tool_title('quick2_d'), tool_title('reformat'), 
		              tool_title('repper')] 

	end
	
	def clustalw_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def clustalw_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
end
