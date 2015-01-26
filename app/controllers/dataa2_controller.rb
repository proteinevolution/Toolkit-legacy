class Dataa2Controller < ToolController

	BAD2 = File.join(BIOPROGS, 'dataa2')

	def browse
          @id = params['jobid'] ? params['jobid'] : ""
          @widescreen = true
	end

	def index
          searchpat = File.join(BAD2, 'hmm', '*')
          @dbvalues = Dir.glob(searchpat)
          @dblabels = @dbvalues.collect{|e| File.basename(e)}
          @default_db = @dbvalues[0]

          # because the browse tab "is" on the index page and on the results
          # page, @widescreen should have the same value on all these pages.
          @widescreen = true
	end
	
	def results
		@widescreen = true
	end

        def help_results
          render(:layout => "help")
        end

        def help_compare
          render(:layout => "help")
        end
  
end
