class NucBlastController < ToolController

	def index
		@std_dbs_paths = Dir.glob(File.join(DATABASES, 'standard', '*.nal')).map() {|p| p.gsub(/\.nal/ ,'')}
		@std_dbs_paths.uniq!
		@std_dbs_paths.sort!
		@std_dbs_labels = @std_dbs_paths.map() {|p| File.basename(p)}
		@matrices = Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'BLOSUM*')).map() {|m| File.basename(m)}
		@matrices.concat Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'PAM*')).map() {|m| File.basename(m)}
		@program_labels = ["blastn", "tblastn", "tblastx"]
		@program_values = ["blastn", "tblastn", "tblastx"]
	end
	
	def results
		@fw_values = [fw_to_tool_url('nuc_blast', 'sixframe'), fw_to_tool_url('nuc_blast', 'gi2seq')]
		@fw_labels = [tool_title('sixframe'), tool_title('gi2seq')]  
	end
  
	def results_alignment
	end
	
	def results_hitlist
		@widescreen = true  
	end

	def export_alignment_to_browser
		@job.set_export_ext(".align")
		export_to_browser
	end
  
	def export_alignment_to_file
		@job.set_export_ext(".align")
		export_to_file
	end
  
	def nuc_blast_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def nuc_blast_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
end
