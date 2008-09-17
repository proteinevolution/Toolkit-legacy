class ReformatJob < Job
  
  @export_ext = ".out"
  
  def set_export_ext(val)
    @export_ext = val  
  end
  
  def get_export_ext
    @export_ext
  end
  
  # export results
  def export
  	set_export_ext( self.actions[0].params['outformat'] )
	ret = IO.readlines(File.join(job_dir, jobid + "." + @export_ext )).join
  end
	
	def getResultsFile
		set_export_ext( self.actions[0].params['outformat'] )
		jobid+"."+@export_ext
	end   
   
end
