class Seq2giController < ToolController

	def index
	end
	
	def results
		@fw_values = [fw_to_tool_url('seq2gi', 'gi2seq')]
		@fw_labels = [tool_title('gi2seq')]
	end
  
end
