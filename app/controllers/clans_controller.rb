class ClansController < ToolController

  def index
    @searchtool_values = ["blastp", "blastpgp"]
    @searchtool_labels = ["BLASTP", "PSI-BLAST"]		
    @std_dbs_paths = Dir.glob(File.join(DATABASES, 'standard', '*.pal')).map() {|p| p.gsub(/\.pal/ ,'')}
    @std_dbs_paths.uniq!
    @std_dbs_paths.sort!
    @std_dbs_labels = @std_dbs_paths.map() {|p| File.basename(p)}
    @matrices = Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'BLOSUM*')).map() {|m| File.basename(m)}
    @matrices.concat Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'PAM*')).map() {|m| File.basename(m)}
  end
  
  def results
    @js_onload = "init();"
  end
  
end
