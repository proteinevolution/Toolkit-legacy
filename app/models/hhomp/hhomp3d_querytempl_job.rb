class Hhomp3dQuerytemplJob < Job

	attr_reader :hit, :templpdb, :querypdb, :method, :rms, :sup_out

	def before_results(controller_params)
	
		@basename = File.join(job_dir, jobid)

		@hit = params["hit"]    # number of hit in hitlist of job
		@templpdb = params["templpdb"] # database file that contains the template pdb structure (probably in $database_dir/pdb/all/)
		@querypdb = params["querypdb"] # database file that contains the query pdb structure (probably in $basename.pdb)
		@method = params["method"].nil? ? @method = 'sup3d' : @method = params["method"]
		@rms = params["rms"].nil? ? @rms = '4' : @rms = params["rms"]	
	
		@sup_out = ""
		lines = IO.readlines(@basename + ".sup3d_out")
		for i in 1..(lines.length-1) do
			@sup_out += lines[i]
			if (lines[i] =~ /^RMSD/) then break end
		end
	
	end
  
end
