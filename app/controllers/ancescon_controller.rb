class AncesconController < ToolController

	def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
	end
	
	def results
		@fullscreen = true
	end
	
	def results_tree
		@fullscreen = true
	end
        
        def results_data
                @fullscreen = true
        end
	
	def export_results_to_browser
		@job.export_results
		export_to_browser
	end
  
	def export_results_to_file
		@job.export_results
		export_to_file
	end
	
	def export_tree_to_browser
		@job.export_tree
		export_to_browser
	end
  
	def export_tree_to_file
		@job.export_tree
		export_to_file
	end
  
end
