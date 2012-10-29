class Gi2seqController < ToolController
  
  def index
    
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

    @gi = params['gi'] ? params['gi'] : ""
    @oldjob = params['parentjob'] ? params['parentjob'] : ""

  end
  
  def results
    # tools to forward to
    # put into different lists, depending on number of necessary input sequences
    @tools_with_more_than_one_inseq_values = [fw_to_tool_url('gi2seq', 'blastclust'), 
                                              fw_to_tool_url('gi2seq', 'clans'), 
                                              fw_to_tool_url('gi2seq', 'clubsubp'),
                                              fw_to_tool_url('gi2seq', 'clustalw'), 
                                              fw_to_tool_url('gi2seq', 'kalign'),
                                              fw_to_tool_url('gi2seq', 'mafft'), 
                                              fw_to_tool_url('gi2seq', 'muscle'),		              
                                              fw_to_tool_url('gi2seq', 'patsearch'), 
                                              fw_to_tool_url('gi2seq', 'probcons'),		              		              
                                              fw_to_tool_url('gi2seq', 'reformat')]
    @tools_with_more_than_one_inseq_labels = [tool_title('blastclust'), 
                                              tool_title('clans'), 
                                              tool_title('clubsubp'), 
                                              tool_title('clustalw'), 
                                              tool_title('kalign'),
                                              tool_title('mafft'), 
                                              tool_title('muscle'),
                                              tool_title('patsearch'), 
                                              tool_title('probcons'),		              		              
                                              tool_title('reformat')] 
                  
    # one or more sequences necessary - require alignment
    @tools_with_one_or_more_inseq_values = [fw_to_tool_url('gi2seq', 'frpred'),
                                            fw_to_tool_url('gi2seq', 'hhblits'),
                                            fw_to_tool_url('gi2seq', 'hhpred'),
                                            fw_to_tool_url('gi2seq', 'hhrep'),
                                            fw_to_tool_url('gi2seq', 'hhrepid'),
                                            fw_to_tool_url('gi2seq', 'hhsenser'),
                                            fw_to_tool_url('gi2seq', 'psi_blast'),
                                            fw_to_tool_url('gi2seq', 'prot_blast'),
                                            fw_to_tool_url('gi2seq', 'repper')]
    @tools_with_one_or_more_inseq_labels = [tool_title('frpred'),
                                            tool_title('hhblits'),
                                            tool_title('hhpred'),
                                            tool_title('hhrep'),
                                            tool_title('hhrepid'),
                                            tool_title('hhsenser'),
                                            tool_title('psi_blast'),
                                            tool_title('prot_blast'),
                                            tool_title('repper')]
                           
    # exactly one sequence necessary
    @tools_with_exactly_one_inseq_values = [fw_to_tool_url('gi2seq', 'cs_blast'),
                                            fw_to_tool_url('gi2seq', 'tprpred'),
                                            fw_to_tool_url('gi2seq', 'marcoil'),
                                            fw_to_tool_url('gi2seq', 'hhfrag')]
    @tools_with_exactly_one_inseq_labels = [tool_title('cs_blast'),
                                            tool_title('tprpred'),
                                            tool_title('marcoil'),
                                            tool_title('hhfrag')]
    #@fullscreen = true
  end
  
  def gi2seq_export_browser
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
  def gi2seq_export_file
    if @job.actions.last.type.to_s.include?("Export")
      @job.actions.last.active = false
      @job.actions.last.save!
    end
  end
  
end
