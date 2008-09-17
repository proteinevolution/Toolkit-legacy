class TCoffeeCombineController < ToolController

	def index
	end
	
	def results
	  @widescreen = true
	end
	
  	def tCoffeeCombine_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def tCoffeeCombine_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
end
