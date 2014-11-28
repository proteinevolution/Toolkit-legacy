require 'genomes_module.rb' # contains GenomesModule for AJAX interactions

class PsiBlastController < ToolController

  # make the methods of the genomes_module.rb in all instances of this class available
  include GenomesModule

  def index
    @inputmode_values = ["sequence", "alignment"]
    @inputmode_labels = ["single FASTA sequence", "alignment"]
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @std_dbs_paths = []
    Dir.glob(File.join(DATABASES, 'standard', '*.pal')).each do |p|
   		p.gsub!(/\.pal/ ,'') 
   		@std_dbs_paths << p
    end    
    @std_dbs_paths.uniq!
    @std_dbs_paths.sort!
    ## Order up Standard databases that shall be displayed on top
    @std_dbs_paths = order_std_dbs(@std_dbs_paths)
    @std_dbs_labels = @std_dbs_paths.map() {|p| (File.basename(p))}
    @matrices = Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'BLOSUM*')).map() {|m| File.basename(m)}
    @matrices.concat Dir.glob(File.join(BIOPROGS, 'blast', 'data', 'PAM*')).map() {|m| File.basename(m)}
  end

  def results
    # mode:
    #   -alignment: use alignment of alignhits.pl
    #   -seqs: use sequence by hsp or complete sequence 
    # 29 Forwardings implemented by hand
    @fw_values = [fw_to_tool_url('psi_blast', 'ancescon')+ "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'alnviz')+ "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'aln2plot')+ "&fw_mode=alignment", 
                  fw_to_tool_url('psi_blast', 'blammer'), 
                  fw_to_tool_url('psi_blast', 'blastclust') + "&fw_mode=seqs", 
                  fw_to_tool_url('psi_blast', 'clans') + "&fw_mode=seqs", 
                  fw_to_tool_url('psi_blast', 'clustalw') + "&fw_mode=seqs", 
                  fw_to_tool_url('psi_blast', 'cs_blast') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'seq2gi') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'frpred') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'hhalign') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'hhblits') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'hhomp') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'hhpred') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'hhrep') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'hhrepid') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'hhsenser') + "&fw_mode=alignment", 
                  fw_to_tool_url('psi_blast', 'kalign') + "&fw_mode=seqs", 
                  fw_to_tool_url('psi_blast', 'mafft') + "&fw_mode=seqs", 
                  fw_to_tool_url('psi_blast', 'muscle') + "&fw_mode=seqs",
                  fw_to_tool_url('psi_blast', 'patsearch') + "&fw_mode=seqs",
                  fw_to_tool_url('psi_blast', 'pcoils') + "&fw_mode=alignment",                  
                  fw_to_tool_url('psi_blast', 'phylip') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'probcons') + "&fw_mode=seqs",
                  fw_to_tool_url('psi_blast', 'psi_blast') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 'quick2_d') + "&fw_mode=alignment",                   
                  fw_to_tool_url('psi_blast', 'reformat') + "&fw_mode=alignment",                   
                  fw_to_tool_url('psi_blast', 'repper') + "&fw_mode=alignment",
                  fw_to_tool_url('psi_blast', 't_coffee') + "&fw_mode=seqs"]
    # labels are added to the tools               
    @fw_labels = [tool_title('ancescon'),
                  tool_title('alnviz'),
                  tool_title('aln2plot'),
                  tool_title('blammer'),  
                  tool_title('blastclust'), 
                  tool_title('clans'), 
                  tool_title('clustalw'), 
                  tool_title('cs_blast'), 
                  tool_title('seq2gi'),   
                  tool_title('frpred'),
                  tool_title('hhalign'),
                  tool_title('hhblits'), 
                  tool_title('hhomp'),
                  tool_title('hhpred'),
                  tool_title('hhrep'),
                  tool_title('hhrepid'),
                  tool_title('hhsenser'),
                  tool_title('kalign'),
                  tool_title('mafft'),
                  tool_title('muscle'),
                  tool_title('patsearch'),
                  tool_title('pcoils'),
                  tool_title('phylip'),
                  tool_title('probcons'),
                  tool_title('psi_blast'),
                  tool_title('quick2_d'),
                  tool_title('reformat'),
                  tool_title('repper'),
                  tool_title('t_coffee')]
                  
                  
    # Test of Emission and Acceptance Values of YML DATA  
    calculate_forwardings(@tool)
    add_parameters_to_selected_forwardings("&fw_mode=alignment", [4,5,6,7])
    add_parameters_to_selected_forwardings("&fw_mode=seqs", [1,2,3,11])
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list 
                  
                  
                  

# Test if current Psiblast Job is a uniprot Job and remove Blammer tool from @fw_values and @fw_label
   if(@job.is_uniprot == 1)
     tool_index = @fw_labels.index(tool_title('blammer'))
     @fw_values.delete_at(tool_index)
     @fw_labels.delete_at(tool_index)
     get_tool_mode_list.delete_at(tool_index)
   end
   
    @widescreen = true
    @show_graphic_hitlist = true
    @show_references = false
  end

  def results_alignment
    # mode aignment: use alignment of alignhits.pl
    @fw_values = [fw_to_tool_url('psi_blast', 'blastclust'),
                  fw_to_tool_url('psi_blast', 'clans'),
                  fw_to_tool_url('psi_blast', 'cs_blast'),
                  fw_to_tool_url('psi_blast', 'seq2gi'),
                  fw_to_tool_url('psi_blast', 'hhpred'),
                  fw_to_tool_url('psi_blast', 'hhsenser'),
                  fw_to_tool_url('psi_blast', 'psi_blast'),
                  fw_to_tool_url('psi_blast', 'reformat'),
                  fw_to_tool_url('psi_blast', 'repper')]

    @fw_labels = [tool_title('blastclust'), tool_title('clans'), tool_title('cs_blast'),
		  tool_title('seq2gi'), tool_title('hhpred'), tool_title('hhsenser'),
		  tool_title('psi_blast'), tool_title('reformat'), tool_title('repper')]
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
  
  def psi_blast_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def psi_blast_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def help_results
    render(:layout => "help")
  end

  def resubmit_domain
    basename = File.join(@job.job_dir, @job.jobid)
    system(sprintf('%s/perl/alicutter.pl %s.in %s.in.cut %d %d', BIOPROGS, basename, basename, params[:domain_start].to_i, params[:domain_end].to_i));

    job_params = @job.actions.first.params
    job_params.each_key do |key|
      # If we stumble over sequence_input, after input has already been set from the in.cut file, it is overwritten by an empty job_params[sequence_input]
      if(key=~ /^(\S+)_input$/)
      else  
          if (key =~ /^(\S+)_file$/) 
            if !job_params[key].nil? && File.exists?(job_params[key]) && File.readable?(job_params[key]) && !File.zero?(job_params[key])
              params[$1+'_input'] = File.readlines(basename+'.in.cut')
            end
          else
            params[key] = job_params[key]
        end
     end   
    end

	File.delete(basename+'.in.cut')
    params[:jobid] = ''
    index
    render(:action => 'index')
  end

  
end
