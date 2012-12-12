class Seq2giController < ToolController

	def index
	end
	
	def results
		@fw_values = [fw_to_tool_url('seq2gi', 'gi2seq')]
		@fw_labels = [tool_title('gi2seq')]
    
        # Test of Emission and Acceptance Values of YML DATA  
        calculate_forwardings(@tool)
        @fw_values = get_tool_list
        @fw_labels = get_tool_name_list
	end
  
end
