class HhsenserForwardAction < Action
  def run
    basename = File.join(job.job_dir, job.jobid)
    
    logger.debug "Forward action, mode: #{params['alignment_mode']}"
    
    if (params['alignment_mode'] == "strict") 
      FileUtils.cp(basename + "_strict_masterslave.fas", basename + ".forward")
    elsif (params['alignment_mode'] == "permissive") 
      FileUtils.cp(basename + "_permissive_masterslave.fas", basename + ".forward")    
    elsif (params['alignment_mode'] == "1") 
      FileUtils.cp(basename + ".subseq1", basename + ".forward")    
    elsif (params['alignment_mode'] == "2") 
      FileUtils.cp(basename + ".subseq2", basename + ".forward")    
    elsif (params['alignment_mode'] == "3") 
      FileUtils.cp(basename + ".subseq3", basename + ".forward")    
    end
    self.status = STATUS_DONE
    self.save!
    job.update_status
  end
  
  def forward_params
    prescreen = true
    if (params['alignment_mode'] == "1" || params['alignment_mode'] == "2" || params['alignment_mode'] == "3")
      prescreen = false
    end
    logger.debug "Screen: #{prescreen}"
    mode = params['fw_mode']
    inputmode = "alignment"
    if (!mode.nil? && mode == "sequence")
     logger.debug "mode == sequence"
     inputmode = "sequence"
    end
    logger.debug "Input mode: #{inputmode}"
    {'sequence_input' => IO.readlines(File.join(job.job_dir, job.jobid) + ".forward").join, 'screen' => prescreen, 'inputmode' => inputmode }
  end
end


