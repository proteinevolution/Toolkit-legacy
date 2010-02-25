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

        def results_color
        	@widescreen = true
        	getsubitems
		@coloring = params['coloring'] ? params['coloring'] : "cc"
	end

	def colorconfidence
		@widescreen = true
		getsubitems
		@coloring = params['coloring'] ? params['coloring'] : "cc"
	end

        def color
		@widescreen = true
                getsubitems
		@coloring = params['coloring'] ? params['coloring'] : "ca"
        end

	def black
		@widescreen = true
                getsubitems
		@coloring = params['coloring'] ? params['coloring'] : "ba"
        end

  	def getsubitems
    		@colresults = ["cc", "ca", "ba"]
    		@colitems = ["colorconfidence", "color", "black"]
    		@col_names = ["Colored Alignment with Confidence", "Colored Alignment", "Black/White Alignment"]
    		@col_text = ["Display the colored alignment with confidence", "Display the colored alignment", "Display the black/white alignment"]
  	end


end
