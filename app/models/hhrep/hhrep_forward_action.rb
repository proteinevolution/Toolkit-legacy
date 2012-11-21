class HhrepForwardAction < Action
  def run
        logger.debug "L3 :Running  "
    self.status = STATUS_DONE
    self.save!
    job.update_status
  end
  
  def forward_params
    logger.debug "In forward params"
    logger.debug "#{job.job_dir}"
    filename = File.join(job.job_dir, 'result_textbox_to_file')
     mode = params['fw_mode']
    informat = 'fas'
    inputmode = "alignment"
     if (!mode.nil? && mode == "sequence")
      inputmode = "sequence"
    end
    
    logger.debug "L19 :#{mode}  "
    res = ""    
    if (File.exists?(filename))     
    	res = IO.readlines(filename).join
    end
    res.gsub!(/>ss_pred\s*\n(.*\n)*?>/, '>')
    res.gsub!(/>ss_conf\s*\n(.*\n)*?>/, '>')      
    {'sequence_input' => res, 'inputmode' => inputmode }
  end
end


