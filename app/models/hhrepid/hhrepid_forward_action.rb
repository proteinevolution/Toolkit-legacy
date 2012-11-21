class HhrepidForwardAction < Action
  def run
    self.status = STATUS_DONE
    self.save!
    job.update_status
  end
  
  def forward_params
    filename = File.join(job.job_dir, 'result_textbox_to_file')
    res = ""  
    mode = params['fw_mode']
    informat = 'fas'
    inputmode = "alignment"
    
     if (!mode.nil? && mode == "sequence")
      inputmode = "sequence"
    end
    if (File.exists?(filename))     
    	res = IO.readlines(filename).join
   end
   if (!mode.nil? && mode == "alignment")
      inputmode = "alignment"
    end 
    res.gsub!(/>ss_pred\s*\n(.*\n)*?>/, '>')
    res.gsub!(/>ss_conf\s*\n(.*\n)*?>/, '>')      
    {'sequence_input' => res, 'inputmode' => inputmode }

  end
end


