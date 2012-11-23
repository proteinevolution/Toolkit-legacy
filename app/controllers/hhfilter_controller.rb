class HhfilterController < ToolController

	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
	end

	def results
		@fw_values = [fw_to_tool_url('hhfilter', 'alnviz'), 
                  fw_to_tool_url('hhfilter', 'blastclust'),
		              fw_to_tool_url('hhfilter', 'clans'), 
                  fw_to_tool_url('hhfilter', 'cs_blast') + "&fw_mode=alignment" + "&alignment_mode=strict", 
                  fw_to_tool_url('hhfilter', 'seq2gi'),
                  fw_to_tool_url('hhfilter', 'hhblits') + "&fw_mode=alignment",
		              fw_to_tool_url('hhfilter', 'hhpred'),
		              fw_to_tool_url('hhfilter', 'hhsenser'),
                  fw_to_tool_url('hhfilter', 'hmmer3') + "&fw_mode=alignment",
                  fw_to_tool_url('hhfilter', 'psi_blast') + "&fw_mode=alignment",
		              fw_to_tool_url('hhfilter', 'quick2_d'), 
                  fw_to_tool_url('hhfilter', 'reformat'),
		              fw_to_tool_url('hhfilter', 'repper'),
                  fw_to_tool_url('hhfilter', 'hhalign') + "&fw_mode=alignment",
                  
                  fw_to_tool_url('hhfilter', 'aln2plot') + "&fw_mode=alignment",
                  fw_to_tool_url('hhfilter', 'pcoils') + "&fw_mode=alignment",
                  fw_to_tool_url('hhfilter', 'frpred') + "&fw_mode=alignment",
                  fw_to_tool_url('hhfilter', 'hhrep') + "&fw_mode=alignment",
                  fw_to_tool_url('hhfilter', 'hhrepid') + "&fw_mode=alignment",
                  
                  
                  
                  ]
		@fw_labels = [tool_title('alnviz'), 
                  tool_title('blastclust'),
		              tool_title('clans'), 
                  tool_title('cs_blast'), 
                  tool_title('seq2gi'),
                  tool_title('hhblits'),
		              tool_title('hhpred'),
		              tool_title('hhsenser'), 
                  tool_title('hmmer3'),
                  tool_title('psi_blast'),
		              tool_title('quick2_d'), 
                  tool_title('reformat'),
		              tool_title('repper'),
                  tool_title('hhalign'),
                  
                  tool_title('aln2plot'),
                  tool_title('pcoils'),
                  tool_title('frpred'),
                  tool_title('hhrep'),
                  tool_title('hhrepid'),
                  
                  ]

	end
	
	def hhfilter_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def hhfilter_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
end
