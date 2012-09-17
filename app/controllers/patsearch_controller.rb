class PatsearchController < ToolController

	def index
		@grammar_values = ["pro", "reg"]
		@grammar_labels = ["Prosite grammar", "Regular expression"]
    @std_dbs_paths = Dir.glob(File.join(DATABASES, 'standard', '*.pal')).map() {|p| p.gsub(/\.pal/ ,'')}

		@std_dbs_paths.uniq!
		@std_dbs_paths.sort!
    		## Order up Standard databases that shall be displayed on top
    		@std_dbs_paths = order_std_dbs(@std_dbs_paths)
		@std_dbs_labels = @std_dbs_paths.map() {|p| File.basename(p)}
    
	end
	
	def results
		@fw_values = [fw_to_tool_url('patsearch', 'blastclust'), fw_to_tool_url('patsearch', 'clans'),
		              fw_to_tool_url('patsearch', 'clustalw'), fw_to_tool_url('patsearch', 'seq2gi'), 
		              fw_to_tool_url('patsearch', 'kalign'), fw_to_tool_url('patsearch', 'mafft'), 
		              fw_to_tool_url('patsearch', 'muscle'), fw_to_tool_url('patsearch', 'probcons'), 
		              fw_to_tool_url('patsearch', 'reformat')]
		@fw_labels = [tool_title('blastclust'), tool_title('clans'), tool_title('clustalw'),
		              tool_title('seq2gi'), tool_title('kalign'), tool_title('mafft'),
		              tool_title('muscle'), tool_title('probcons'), tool_title('reformat')]  
	end
	
	def patsearch_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def patsearch_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
end
