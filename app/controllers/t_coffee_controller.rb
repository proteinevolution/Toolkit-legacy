class TCoffeeController < ToolController

	def index
	end

	def results
		@widescreen=true
		@fw_values = [fw_to_tool_url('t_coffee', 'ali2d'), fw_to_tool_url('t_coffee', 'alnviz'), fw_to_tool_url('t_coffee', 'ancescon'), fw_to_tool_url('t_coffee', 'blastclust'),
		              fw_to_tool_url('t_coffee', 'clans'), fw_to_tool_url('t_coffee', 'seq2gi'),
		              fw_to_tool_url('t_coffee', 'fast_hmmer'), fw_to_tool_url('t_coffee', 'frpred'),
		              fw_to_tool_url('t_coffee', 'hhpred'),
		              fw_to_tool_url('t_coffee', 'hhsenser'), fw_to_tool_url('t_coffee', 'phylip'), fw_to_tool_url('t_coffee', 'psi_blast'),
		              fw_to_tool_url('t_coffee', 'quick2_d'), fw_to_tool_url('t_coffee', 'reformat'),
		              fw_to_tool_url('t_coffee', 'repper')]
		@fw_labels = [tool_title('ali2d'), tool_title('alnviz'), tool_title('ancescon'), tool_title('blastclust'),
		              tool_title('clans'), tool_title('seq2gi'),
		              tool_title('fast_hmmer'), tool_title('frpred'),
		              tool_title('hhpred'),
		              tool_title('hhsenser'), tool_title('phylip'), tool_title('psi_blast'),
		              tool_title('quick2_d'), tool_title('reformat'),
		              tool_title('repper')]

	end

	def tcoffee_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end

	def tcoffee_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end

  def help_results
    render(:layout => "help")
  end

end
