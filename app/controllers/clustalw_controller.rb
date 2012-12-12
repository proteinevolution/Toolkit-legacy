class ClustalwController < ToolController

	def index
		@clustal_version_labels = ['ClustalW','Clustal-Omega']
		@clustal_version_values = ['-w', '-o']
	end

	def results
    
    @fw_values = [fw_to_tool_url('clustalw', 'ali2d'), 
                  fw_to_tool_url('clustalw', 'alnviz'),
                  fw_to_tool_url('clustalw', 'aln2plot'),
                  fw_to_tool_url('clustalw', 'ancescon'), 
                  fw_to_tool_url('clustalw', 'blastclust'),
		              fw_to_tool_url('clustalw', 'clans'), 
                  fw_to_tool_url('clustalw', 'cs_blast'), 
                  fw_to_tool_url('clustalw', 'seq2gi'),
                  fw_to_tool_url('clustalw', 'frpred'),
                  fw_to_tool_url('clustalw', 'hhblits'),
                  fw_to_tool_url('clustalw', 'hhomp'),
		              fw_to_tool_url('clustalw', 'hhpred'),
                  fw_to_tool_url('clustalw', 'hhrep'),
                  fw_to_tool_url('clustalw', 'hhrepid'),
                  fw_to_tool_url('clustalw', 'hhsenser'),
                  fw_to_tool_url('clustalw', 'pcoils'),
                  fw_to_tool_url('clustalw', 'phylip'), 
                  fw_to_tool_url('clustalw', 'psi_blast'),
		              fw_to_tool_url('clustalw', 'quick2_d'), 
                  fw_to_tool_url('clustalw', 'reformat'),
		              fw_to_tool_url('clustalw', 'repper')]
                  
    @fw_labels = [tool_title('ali2d'),
                  tool_title('alnviz'),
                  tool_title('aln2plot'),
                  tool_title('ancescon'), 
                  tool_title('blastclust'),
		              tool_title('clans'), 
                  tool_title('cs_blast'), 
                  tool_title('seq2gi'),
		              tool_title('frpred'),
                  tool_title('hhblits'),
                  tool_title('hhomp'),
		              tool_title('hhpred'), 
                  tool_title('hhrep'), 
                  tool_title('hhrepid'), 
                  tool_title('hhsenser'),
                  tool_title('pcoils'), 
                  tool_title('phylip'), 
                  tool_title('psi_blast'),
		              tool_title('quick2_d'), 
                  tool_title('reformat'),
		              tool_title('repper')]
                  
    # Test of Emission and Acceptance Values of YML DATA  
    calculate_forwardings(@tool)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list              
                  
                  

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
