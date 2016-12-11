class HhfragController < ToolController

	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@weighting_labels = ['yes', 'no']
		@weighting_values = ['1', '0']
		@matrix_labels = ['9FAM','MTK matrix', 'MTIDK matrix']
		@matrix_values = ['','-C', '-C -i']
		@marcoil_labels = ['Marcoil','PSSM']
		@marcoil_values = ['','-P']
                @transprob_labels = ['High','Low']
                @transprob_values = ['-H','-L']
	end
	
	def help_results
		render(:layout => "help")
	end

        def results
        end

        def results_numerical
        end
end
