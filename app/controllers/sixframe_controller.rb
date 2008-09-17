class SixframeController < ToolController

	def index
		@codon_labels = ["Universal Code","Vertebrate Mitochondrial Code","Yeast Mitochondrial Code","Mold, Protozoa, Coelenterate Mitochondrial & Mycoplasma/Spiroplasma Code","Invertebrate Mitochondrial Code","The Ciliate, Dasycladacean and Hexamita Neclear Code","The Echinoderm and Flatworm Mitochondrial Code","The Euplotid Nuclear Code","The Bacterial and Plant Plastid Code","The Alternative Yeast Nuclear Code","The Ascidian Mitochondrial Code","The Alternative Flatworm Mitochondrial Code","Blepharisma Nuclear Code","Chlorophycean Mitochondrial Code","Trematode Mitochondrial Code","Scenedesmus obliquus mitochondrial code","Thraustochytrium Mitochondrial Code"]
		@codon_values = ["1","2","3","4","5","6","9","10","11","12","13","14","15","16","21","22","23"]
	end
  
end
