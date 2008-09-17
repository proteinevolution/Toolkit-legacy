class ReformatController < ToolController

	def index
		@informat_labels = ["A2M (FASTA with '.' and '-')","A3M (FASTA with '.' removed)","CLUSTAL","EMBL","FASTA","GENBANK","MEGA","GCG MSF","PAUP NEXUS","PHYLIP","PIR/NBRF","STOCKHOLM","TREECON"]
		@informat_values = ["a2m","a3m","clu","emb","fas","gbk","meg","msf","nex","phy","pir","sto","tre"]
		@outformat_labels = ["A2M (FASTA with '.' and '-')","A3M (FASTA \with '.' removed)","CLUSTAL","FASTA","MEGA","GCG MSF","PHYLIP","PIR/NBRF","PIR2","STOCKHOLM","TREECON","UFASTA"]
		@outformat_values = ["a2m","a3m","clu","fas","meg","msf","phy","pir","pir2","sto","tre","ufas"]
		@character_labels = ["No change","To lower case","To upper case"]
		@character_values = [" ","-tolower","-toupper"]
	end
  
end
