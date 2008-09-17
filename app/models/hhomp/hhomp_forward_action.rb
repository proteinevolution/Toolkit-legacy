class HhompForwardAction < Action
  def run
    self.status = STATUS_DONE
    self.save!
    job.update_status
  end
  
  def forward_params
    hash = {}

    filename = File.join(job.job_dir, 'result_textbox_to_file')
    res = ""    
    if (File.exists?(filename))     
  	  res = IO.readlines(filename).join
    end
    res.gsub!(/>ss_pred\s*\n(.*\n)*?>/, '>')
    res.gsub!(/>ss_conf\s*\n(.*\n)*?>/, '>')      
    res.gsub!(/>bb_pred\s*\n(.*\n)*?>/, '>')
    res.gsub!(/>bb_conf\s*\n(.*\n)*?>/, '>')
    hash = { 'sequence_input' => res }

    return hash
  end
end


