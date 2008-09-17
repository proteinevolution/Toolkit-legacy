class Ali2dController < ToolController

	def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
	end
	
	def results
		@widescreen = true
	end
	
	def results_applet
		@widescreen = true	
	end
	
	def results_show_applet
		render(:layout => 'plain')
	end
  
end