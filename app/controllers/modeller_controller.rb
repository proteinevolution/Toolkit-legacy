class ModellerController < ToolController

	include UserGroupModule
	
	def index
		@informat_values = ['fas', 'clu', 'sto', 'a2m', 'a3m', 'emb', 'meg', 'msf', 'pir', 'tre']
		@informat_labels = ['FASTA', 'CLUSTAL', 'Stockholm', 'A2M', 'A3M', 'EMBL', 'MEGA', 'GCG/MSF', 'PIR/NBRF', 'TREECON']
		@internal = is_internal?(request.remote_ip) 
	end
  
	def verify3d
		@widescreen = true
	end
	
	def anolea
		@widescreen = true
	end
	
	def solvx
		@widescreen = true
	end
	
	def modeller2hhpred
		hhpred_job = @job.parent.parent
		hhpred_basename = File.join(hhpred_job.job_dir, hhpred_job.jobid)
		command = "#{BIOPROGS}/modeller_scripts/changeIndices.pl -pdb #{File.join(@job.job_dir, @job.jobid + '.pdb')} -q #{hhpred_basename}.a3m -o #{hhpred_basename}.pdb"
		logger.debug "### modeller2hhpred command: #{command}"
		system(command)
		redirect_to(:host => DOC_ROOTHOST, :controller => 'hhpred', :action => 'results', :jobid => hhpred_job)		
	end
	
	def modeller2hhomp
		hhomp_job = @job.parent.parent
		hhomp_basename = File.join(hhomp_job.job_dir, hhomp_job.jobid)
		command = "#{BIOPROGS}/modeller_scripts/changeIndices.pl -pdb #{File.join(@job.job_dir, @job.jobid + '.pdb')} -q #{hhomp_basename}.a3m -o #{hhomp_basename}.pdb"
		logger.debug "### modeller2hhomp command: #{command}"
		system(command)
		redirect_to(:host => DOC_ROOTHOST, :controller => 'hhomp', :action => 'results', :jobid => hhomp_job)		
	end
  
end
