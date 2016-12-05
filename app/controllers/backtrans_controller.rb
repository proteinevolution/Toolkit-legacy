class BacktransController < ToolController

	def index
		
		@gencode_values = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
		@gencode_labels = ['Standard',
								 'Vertebrate Mitochondrial',
								 'Yeast Mitochondrial',
								 'Mold, Protozoan, and Coelenterate Mitochondrial and Mycoplasma/Spiroplasma',
								 'Invertebrate Mitochondrial',
								 'Ciliate, Dasycladacean and Hexamita Nuclear',
								 'Echinoderm and Flatworm Mitochondrial',
								 'Euplotid Nuclear','Bacterial and Plant Plastid',
								 'Alternative Yeast Nuclear',
								 'Ascidian Mitochondrial',
								 'Alternative Flatworm Mitochondrial',
								 'Blepharisma Nuclear',
								 'Chlorophycean Mitochondrial',
								 'Trematode Mitochondrial',
								 'Scenedesmus Obliquus Mitochondrial',
								 'Thraustochytrium Mitochondrial']
	end
	
	def results
		@fullscreen = true
	end
	
	def upload_cut
	
		require 'open3'
		
		@cutname = params['cutname'].empty? ? "." : params['cutname']
		@organism = []
	  
		command = "#{File.join(BIOPROGS, 'backtranslate')}/findOrganism.pl -i '#{@cutname}'"
	  
		logger.debug "Command: #{command}"
	  
		Open3.popen3(command) do |stdin, stdout, stderr|
			@organism = stdout.readlines.map {|line| line.chomp}
			logger.debug "orgs: #{@organism}"
		end
	  
		@organism = @organism.join(',')
		filename = "/tmp/CUT_orgs_" + rand(99999999).to_s
		File.open(filename, "w") do |file|
			file.write(@organism)
		end
	  	  
		redirect_to(:host => DOC_ROOTHOST, :controller => 'backtrans', :action => 'index', :organism => filename, :cut => true)
	end
end
