require 'genomes_module.rb' # contains GenomesModule for AJAX interactions

class ProtBlastController < ToolController
  
  # make methods of the genomes_module.rb in all instances of this class available
  include GenomesModule

  def index
	@std_dbs_paths = []
	Dir.glob(File.join(DATABASES, 'standard', '*.pal')).each do |p|
   		p.gsub!(/\.pal/ ,'') 
   		@std_dbs_paths << p
   end
	 @std_dbs_paths.uniq!
    @std_dbs_paths.sort!
    @std_dbs_labels = @std_dbs_paths.map() {|p| File.basename(p)}
    @matrices = Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'BLOSUM*')).map() {|m| File.basename(m)}
    @matrices.concat Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'PAM*')).map() {|m| File.basename(m)}
  end

  def results
    # mode: 
    #   -alignment: use alignment of alignhits.pl
    #   -seqs: use sequence by hsp or complete sequence
    @fw_values = [fw_to_tool_url('prot_blast', 'blammer'), 
                  fw_to_tool_url('prot_blast', 'blastclust') + "&fw_mode=seqs", 
                  fw_to_tool_url('prot_blast', 'clans') + "&fw_mode=seqs", 
                  fw_to_tool_url('prot_blast', 'clustalw') + "&fw_mode=seqs", 
                  fw_to_tool_url('prot_blast', 'seq2gi') + "&fw_mode=alignment",
                  fw_to_tool_url('prot_blast', 'hhpred') + "&fw_mode=alignment",
                  fw_to_tool_url('prot_blast', 'hhsenser') + "&fw_mode=alignment", 
                  fw_to_tool_url('prot_blast', 'kalign') + "&fw_mode=seqs", 
                  fw_to_tool_url('prot_blast', 'mafft') + "&fw_mode=seqs", 
                  fw_to_tool_url('prot_blast', 'muscle') + "&fw_mode=seqs",
    		  fw_to_tool_url('prot_blast', 'patsearch') + "&fw_mode=seqs",
    		  fw_to_tool_url('prot_blast', 'probcons') + "&fw_mode=seqs",
                  fw_to_tool_url('prot_blast', 'psi_blast') + "&fw_mode=alignment", 
                  fw_to_tool_url('prot_blast', 'quick2_d') + "&fw_mode=alignment",                   
                  fw_to_tool_url('prot_blast', 'reformat') + "&fw_mode=alignment",                   
                  fw_to_tool_url('prot_blast', 'repper') + "&fw_mode=alignment"]
                  
    @fw_labels = [tool_title('blammer'), tool_title('blastclust'), tool_title('clans'), 
                  tool_title('clustalw'), tool_title('seq2gi'), tool_title('hhpred'),
                  tool_title('hhsenser'), tool_title('kalign'), tool_title('mafft'), 
                  tool_title('muscle'), tool_title('patsearch'), tool_title('probcons'), 
                  tool_title('psi_blast'), tool_title('quick2_d'), tool_title('reformat'), 
                  tool_title('repper')]

                      					
  end
  
  def results_alignment
    # mode aignment: use alignment of alignhits.pl
    @fw_values = [fw_to_tool_url('prot_blast', 'blastclust'),
                  fw_to_tool_url('prot_blast', 'clans'),
                  fw_to_tool_url('prot_blast', 'seq2gi'),
                  fw_to_tool_url('prot_blast', 'hhpred'),
                  fw_to_tool_url('prot_blast', 'hhsenser'),
                  fw_to_tool_url('prot_blast', 'psi_blast'),
                  fw_to_tool_url('prot_blast', 'reformat'),
                  fw_to_tool_url('prot_blast', 'repper')]
                  
    @fw_labels = [tool_title('blastclust'), tool_title('clans'), tool_title('seq2gi'), 
                  tool_title('hhpred'), tool_title('hhsenser'),  tool_title('psi_blast'), 
                  tool_title('reformat'), tool_title('repper')]
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
  
  def prot_blast_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def prot_blast_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end

  def help_results
    render(:layout => "help")
  end

end
