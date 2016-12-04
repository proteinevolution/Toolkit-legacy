class BlammerController < ToolController
  def index
    @outformat_labels = ["FASTA format","ClustalW format"]
    @outformat_values = ["fasta","clustal"]
  end

  def results
    @fullscreen = true
    @fw_values = [fw_to_tool_url('blammer', 'ali2d'),
                  fw_to_tool_url('blammer', 'alnviz'),
                  fw_to_tool_url('blammer', 'aln2plot'),
                  fw_to_tool_url('blammer', 'ancescon'),
                  fw_to_tool_url('blammer', 'blastclust'),
		              fw_to_tool_url('blammer', 'clans'),
		              fw_to_tool_url('blammer','cs_blast'),
		              fw_to_tool_url('blammer', 'seq2gi'),
		              fw_to_tool_url('blammer', 'frpred'),
                  fw_to_tool_url('blammer', 'hhblits'),
                  fw_to_tool_url('blammer', 'hhomp'),
		              fw_to_tool_url('blammer', 'hhpred'),
                  fw_to_tool_url('blammer', 'hhrep'),
                  fw_to_tool_url('blammer', 'hhrepid'),
		              fw_to_tool_url('blammer', 'hhsenser'),
                  fw_to_tool_url('blammer', 'patsearch'),
                  fw_to_tool_url('blammer', 'pcoils'),
		              fw_to_tool_url('blammer', 'phylip'),
		              fw_to_tool_url('blammer', 'psi_blast'),
		              fw_to_tool_url('blammer', 'quick2_d'),
		              fw_to_tool_url('blammer', 'reformat'),
		              fw_to_tool_url('blammer', 'repper')]
		              
    @fw_labels = [tool_title('ali2d'),
                  tool_title('alnviz'),
                  tool_title('aln2plot'),
                  tool_title('ancescon'),
                  tool_title('blastclust'),
		              tool_title('clans'),
		              tool_title('cs_blast'),
		              tool_title('seq2gi'),
		              tool_title('frpred'),
                  tool_title('hhblits'),
                  tool_title('hhomp'),
		              tool_title('hhpred'),
                  tool_title('hhrep'),
                  tool_title('hhrepid'),
		              tool_title('hhsenser'),
                  tool_title('patsearch'),
                  tool_title('pcoils'),
		              tool_title('phylip'),
		              tool_title('psi_blast'),
		              tool_title('quick2_d'),
		              tool_title('reformat'),
		              tool_title('repper')]
                  
    # Test of Emission and Acceptance Values of YML DATA  

    # Don't sent clustal format to tools expecting one or multiple sequences
    # only: They won't handle it correctly!
    # Therefore, job properties are different with clustal format.
    job_params = @job.params_main_action
    if "clustal" == job_params["outformat"] then
      jobtype = "_clustal_job"
    else
      jobtype = "_job"
    end
    jobname = @tool['name'] + jobtype
    calculate_forwardings(@tool, jobname)
    @fw_values = get_tool_list
    @fw_labels = get_tool_name_list                  
  end

  def blammer_export_browser
    if @job.actions.last.type.to_s.include?("Export")
    @job.actions.last.active = false
    @job.actions.last.save!
    end
  end

  def blammer_export_file
    if @job.actions.last.type.to_s.include?("Export")
    @job.actions.last.active = false
    @job.actions.last.save!
    end
  end
end
