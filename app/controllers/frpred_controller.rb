class FrpredController < ToolController

	def index
		@inputmode_values = ["sequence", "alignment"]
		@inputmode_labels = ["single FASTA sequence", "alignment"]
		@informat_values = ['fas', 'gfas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'grouped FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
#		@matrix_values = ['B50', 'B62', 'B80', 'Gonnet']
#		@matrix_labels = ['BLOSUM50', 'BLOSUM62', 'BLOSUM80', 'Gonnet']
		@maxpsiblastit = ['0','1','2','3','4','5','6','8','10']
		@epsiblastval = ['1E-3', '1E-4', '1E-6', '1E-8', '1E-10', '1E-15', '1E-20', '1E-30', '1E-40', '1E-50']
	end
	
	def results
		@fullscreen = true
	end
  
        def results_mpicons_cat
                @fullscreen = true
        end

	def results_mpicons_lig
		@fullscreen = true
	end

	def results_mpiet
		@fullscreen = true
	end

	def results_mpisubtype
		@fullscreen = true
	end

	def results_hrsubtype
		@fullscreen = true
	end

	def results_jmol
		@fullscreen = true
	end
	
	def applet
		@fullscreen = true
		@tree = params['tree'] ? params['tree'] : ""
		render(:layout => 'plain')
	end

end
