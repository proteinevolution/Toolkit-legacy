class PhylipController < ToolController

	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@type_values = ['prot', 'dna']
		@type_labels = ['Protein', 'DNA']
		@protMat_values = ['1', '2', '3', '4', '5', '6']
		@protMat_labels = ['Jones-Taylor-Thornton matrix', 'Henikoff/Tillier PMB matrix', 'Dayhoff PAM matrix', 'Kimura formula', 'Similarity table', 'Categories model']
		@dnaMat_values = ['1', '2', '3', '4']
		@dnaMat_labels = ['F84','Kimura 2-parameter','Jukes-Cantor','LogDet']
	end
	
	def export_nj_to_browser
		@job.set_export_ext('.nj')
		export_to_browser
	end
  
	def export_nj_to_file
		@job.set_export_ext('.nj')
		export_to_file
	end
	
	def export_upgma_to_browser
		@job.set_export_ext('.upgma')
		export_to_browser
	end
  
	def export_upgma_to_file
		@job.set_export_ext('.upgma')
		export_to_file
	end
  
end
