class TprpredController < ToolController

	def index
		@pssm_paths = Dir.glob(File.join(BIOPROGS, 'tprpred', '*.pp'))
		@pssm_paths.uniq!
		@pssm_paths.sort!
		@pssm_labels = @pssm_paths.map() {|p| File.basename(p).gsub!(/\.pp/, '')}
		@pssm_default = File.join(BIOPROGS, 'tprpred', 'tpr2.8.pp')
	end
  
end
