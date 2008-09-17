class BlastclustController < ToolController

	def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
	end  

	def results
		@fw_values = [fw_to_tool_url('blastclust', 'clans'), 
		              fw_to_tool_url('blastclust', 'clustalw'), fw_to_tool_url('blastclust', 'kalign'),
		              fw_to_tool_url('blastclust', 'mafft'), fw_to_tool_url('blastclust', 'muscle'),		              
		              fw_to_tool_url('blastclust', 'probcons'),		              		              
		              fw_to_tool_url('blastclust', 'reformat')]
	
		@fw_labels = [tool_title('clans'), 
		              tool_title('clustalw'), tool_title('kalign'),
		              tool_title('mafft'), tool_title('muscle'),
		              tool_title('probcons'),		              		              
		              tool_title('reformat')] 
		@fullscreen = true
	end
	

	def blastclust_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def blastclust_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
end
