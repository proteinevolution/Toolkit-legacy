class RepperController < ToolController

	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@inputmode_labels = ['Use input as given', 'Run PSI-BLAST']
		@inputmode_values = ['1', '0']
		@criteria_labels = ['Kyte-Doolittle hydrophobicity', 'Standard Binary', 'own Scale']
		@criteria_values = ['1', '0', '2']
		@weighting_labels = ['unweighted', 'weighted']
		@weighting_values = ['0', '1']
		@matrix_labels = ['MTIDK matrix', 'PDB matrix']
		@matrix_values = ['0', '1']
	end
	
	def results_createmap
		@job.actions.last.active = false
		@job.actions.last.save!
	end
  
	def results_reppermap
		@job.actions.last.active = false
		@job.actions.last.save!
	end

        def template
		render(:layout => 'template')
	end

	def help_results
          render(:layout => "help")
        end


end
