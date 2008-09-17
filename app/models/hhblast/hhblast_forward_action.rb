class HhblastForwardAction < Action
  def run
    self.status = STATUS_DONE
    self.save!
    job.update_status
  end
  
  def forward_params
    hash = {}
    if params['mode'].nil? 
      filename = File.join(job.job_dir, 'result_textbox_to_file')
      res = ""    
      if (File.exists?(filename))     
    	  res = IO.readlines(filename).join
      end
      res.gsub!(/>ss_pred\s*\n(.*\n)*?>/, '>')
      res.gsub!(/>ss_conf\s*\n(.*\n)*?>/, '>')      
      hash = { 'sequence_input' => res }
    else
      res = IO.readlines(job.params_main_action['sequence_file']).join("\n")
      hash = { 'sequence_input' => res, 'informat' => job.params_main_action['informat'] }
    end
    return hash
  end
end


