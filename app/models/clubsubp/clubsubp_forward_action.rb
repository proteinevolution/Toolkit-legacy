class ClubsubpForwardAction < Action
  
	def run
		self.status = STATUS_DONE
		self.save!
		job.update_status
	end
  
	def forward_params
		res = IO.readlines(File.join(job.job_dir, job.jobid + ".gis"))
		{'sequence_input' => res.join}
	end
    
end

