class FrpredForwardAction < Action
  def run
    self.status = STATUS_DONE
    self.save!
    job.update_status
  end
  
  def forward_params
    hash = {}
    filename = File.join(job.job_dir, job.jobid + ".fasta")
    res = ""
    if (File.exists?(filename))     
     res = IO.readlines(filename).join
    end
    hash = job.params_main_action
    hash['sequence_input'] = res
    hash['inputmode'] = "alignment"
    hash['informat'] = "fas"
    if (hash['pdb_file'] && File.exists?(hash['pdb_file']) && File.readable?(hash['pdb_file']) && !File.zero?(hash['pdb_file']))
    	pdb = IO.readlines(hash['pdb_file']).join
    	hash['pdb_input'] = pdb
    end
    return hash
  end
end


