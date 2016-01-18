class GlprobsController < ToolController

	def index

	end

	def results 
                  
    # Test of Emission and Acceptance Values of YML DATA  
    calculate_forwardings(@tool)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list              
                  
                  

	end

	def msaprobs_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end

	def msaprobs_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end

end
