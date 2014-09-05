class HhsenserController < ToolController

  def index
    @informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
    @informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
    @extnd = ['0', '20', '50']
    @psiblast_eval = ['1e-3', '1e-4', '1e-6', '1e-7', '1e-8', '1e-10']
    @cov_minval = ['0', '10', '20', '30', '40', '50', '60', '70', '80', '90']
    @ymax = ['10', '100', '500', '1000', '5000']
    @match_mode_values = ['first', '0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100']
    @match_mode_labels = ['residues of first sequence',
                          'no gaps',
                          'fraction of gaps <10%',
                          'fraction of gaps <20%',
                          'fraction of gaps <30%',
                          'fraction of gaps <40%',
                          'fraction of gaps <50%',
                          'fraction of gaps <60%',
                          'fraction of gaps <70%',
                          'fraction of gaps <80%',
                          'fraction of gaps <90%',
                          'assigning all columns to match states']
    @dblabels = ['nr', 'nr + environmental', 'nr_eukaryotes', 'nr_prokaryotes', 'nr_bacteria', 'nr_archaea', 'nr_viruses']
    @dbvalues = [File.join(DATABASES,'standard','nr'), File.join(DATABASES,'standard','nre'), File.join(DATABASES,'standard','nr_euk'), File.join(DATABASES,'standard','nr_pro'), File.join(DATABASES,'standard','nr_bac'), File.join(DATABASES,'standard','nr_arc'), File.join(DATABASES, 'standard', 'nr_vir')]
    @default_db = @dbvalues[0]
  end
  
  def results
    @widescreen = true
    @fw_values = [fw_to_tool_url('hhsenser', 'cs_blast') + "&fw_mode=alignment" + "&alignment_mode=strict", fw_to_tool_url('hhsenser', 'hhpred') + "&alignment_mode=strict", fw_to_tool_url('hhsenser', 'psi_blast') + "&fw_mode=alignment" + "&alignment_mode=strict"]
    @fw_labels = [tool_title('cs_blast'), tool_title('hhpred'), tool_title('psi_blast')]  
  end
	
  def results_permissive
    @widescreen = true
    @fw_values = [fw_to_tool_url('hhsenser', 'hhpred') + "&alignment_mode=permissive", fw_to_tool_url('hhsenser', 'psi_blast') + "&fw_mode=alignment" + "&alignment_mode=permissive"]
    @fw_labels = [tool_title('hhpred'), tool_title('psi_blast')]  
  end

  def results_rejected
    @widescreen = true
  end

  def results_intermediate
    @widescreen = true
  end
	
  def export_permissive_to_browser
    @job.set_export_ext("_permissive_masterslave.clu")
    export_to_browser
  end
  
  def export_permissive_to_file
    @job.set_export_ext("_permissive_masterslave.clu")
    export_to_file
  end
	
  def export_permissive_to_browser
    @job.set_export_ext("-Z.a3m")
    export_to_browser
  end
  
  def export_permissive_to_file
    @job.set_export_ext("-Z.a3m")
    export_to_file
  end
  
  def stop_hhsenser

    job = Job.find(:first, :conditions => [ "jobid = ?", params[:jobid]])

    worker_id = job.actions.first.queue_jobs.first.workers.first.id
		
    script = File.join(BIOPROGS, 'perl/stop_hhsenser.pl')
    logger.debug "Command: #{script} #{job.job_dir}/#{worker_id}.exec_host"
    system("#{script} #{job.job_dir}/#{worker_id}.exec_host")
		
    sleep(2)
    job.reload
		
    if job.done?
      redirect_to(:host => DOC_ROOTHOST, :controller => job.forward_controller, :action => job.forward_action, :jobid => job)
    else
      redirect_to(:host => DOC_ROOTHOST, :action => "waiting", :jobid => job)
    end
  end
	
  def help_results
    render(:layout => "help")
  end

  	
end
