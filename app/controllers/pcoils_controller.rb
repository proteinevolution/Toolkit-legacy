class PcoilsController < ToolController

	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@inputmode_labels = ['No alignment (only single sequence)', 'Run PSI-BLAST', 'Use input alignment']
		@inputmode_values = ['0', '1', '2']
		@weighting_labels = ['yes', 'no']
		@weighting_values = ['1', '0']
		@matrix_labels = ['MTIDK matrix', 'PDB matrix', 'Iterated matrix', 'MTK matrix']
		@matrix_values = ['2', '1', '0', '3']
	end
	
	def help_results
		render(:layout => "help")
	end

        def results
        end

        def results_numerical
        end
  
  
end
