class Hmmer3Controller < ToolController

	def index
          @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
          @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
          @std_dbs_paths = []
          Dir.glob(File.join(DATABASES, 'standard', '*.pal')).each do |p|
            p.gsub!(/\.pal/ ,'') 
            @std_dbs_paths << p if File.exist? p
          end    
          @std_dbs_paths.uniq!
          @std_dbs_paths.sort!
          ## Order up Standard databases that shall be displayed on top
          @std_dbs_paths = order_std_dbs(@std_dbs_paths)
          @std_dbs_labels = @std_dbs_paths.map() {|p| File.basename(p)}
	end
	
	def results
	       	@widescreen = true
	end
  
	def results_stockholm
		@widescreen = true
	end
        
        def results_domain
	      @widescreen = true
        end

	def results_fasta
		@widescreen = true
                @fw_values = [fw_to_tool_url('hmmer3', 'alnviz'), fw_to_tool_url('hmmer3', 'blastclust'),
                              fw_to_tool_url('hmmer3', 'clans'), fw_to_tool_url('hmmer3', 'seq2gi'),
                              fw_to_tool_url('hmmer3', 'hmmer3'),fw_to_tool_url('hmmer3', 'frpred'),
                              fw_to_tool_url('hmmer3', 'hhpred'),
                              fw_to_tool_url('hmmer3', 'hhsenser'), fw_to_tool_url('hmmer3', 'quick2_d'),
                              fw_to_tool_url('hmmer3', 'reformat'), fw_to_tool_url('hmmer3', 'repper')]
                @fw_labels = [tool_title('alnviz'), tool_title('blastclust'),
                              tool_title('clans'), tool_title('seq2gi'),
                              tool_title('hmmer3'), tool_title('frpred'),
                              tool_title('hhpred'),
                              tool_title('hhsenser'), tool_title('quick2_d'),
                              tool_title('reformat'), tool_title('repper')]
                              
    # Test of Emission and Acceptance Values of YML DATA  
    calculate_forwardings(@tool)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list
	end
	
	def export_results_to_browser
		@job.set_export_ext(".out")
		export_to_browser
	end
  
	def export_results_to_file
		@job.set_export_ext(".out")
		export_to_file
	end
	
	def export_stockholm_to_browser
		@job.set_export_ext(".out")
		export_to_browser
	end
  
	def export_stockholm_to_file
		@job.set_export_ext(".out")
		export_to_file
	end


	def export_logo_to_browser
		@job.set_export_ext(".logo")
		export_to_browser
	end
  
	def export_logo_to_file
		@job.set_export_ext(".logo")
		export_to_file
	end
        
        def export_domain_to_browser
                @job.set_export_ext(".dom")
		export_to_browser
        end 
       
        def export_domain_to_file
               @job.set_export_ext(".dom")
	       export_to_file
        end

 
	def hmmer3_export_browser
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end
  
	def hmmer3_export_file
		if @job.actions.last.type.to_s.include?("Export")
			@job.actions.last.active = false
			@job.actions.last.save!
		end
	end

end
