class ModellerJob < Job
	@@export_ext = ".pdb"
	def set_export_ext(val)
		@@export_ext = val  
	end
	def get_export_ext
		@@export_ext
	end
	
	# add your own data accessors for the result templates here! For example:
	attr_reader :hhpred_child, :hhomp_child, :verify3d_out, :imoltalk_id
  
	# Overwrite before_results to fill you job object with result data before result display
	def before_results(controller_params)
		@hhpred_child = nil
		if self.parent && self.parent.parent && self.parent.parent.class.to_s == 'HhpredJob'
			@hhpred_child = true	
		end
		@hhomp_child = nil
		if self.parent && self.parent.parent && self.parent.parent.class.to_s == 'HhompJob'
			@hhomp_child = true	
		end  
		@imoltalk_id = nil
		filename = File.join(job_dir, jobid + ".imoltalk")
		if (File.exists?(filename))
			lines = IO.readlines(filename)
			@imoltalk_id = lines[0]
		end

	end
	
	def export
		lines = IO.readlines(File.join(job_dir, jobid + ".pdb"))
		return lines
	end
  
	def before_verify3d
          @verify3d_out = nil
          if (File.exists?(File.join(job_dir, jobid + ".plotdat")))
            lines = IO.readlines(File.join(job_dir, jobid + ".plotdat"))
            @verify3d_out = ([lines[0]] << lines[5..lines.length]).join
          end            
	end
	  
end
