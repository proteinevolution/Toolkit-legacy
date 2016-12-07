class GcviewForwardAction < Action

	def run
          logger.debug "In run!"
	  self.status = STATUS_DONE
	  self.save!
	  job.update_status
	end

        def forward_params
	  hash = {}
	  logger.debug "In Forward Params!!!!"
	  res = IO.readlines(File.join(job.job_dir, job.jobid + "_gcvout.html"))
	  if (params['forward_controller'] == "gcview")
	    jobid = job.jobid
            hash = {'jobid_input' => jobid, 'show_number' => job.params_main_action['show_number'], 'show_type' => job.params_main_action['show_type']}
          end
	  if (params['forward_controller'] == "seq2gi")
	    logger.debug "#{params['forward_controller']}"
	    res.join
	    hash = {'sequence_input' => res.join}
          end
	  return hash
        end
end

