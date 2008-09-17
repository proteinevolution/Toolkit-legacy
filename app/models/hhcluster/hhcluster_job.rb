class HhclusterJob < Job
  
  @@export_ext = ".export"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
  
  
	attr_reader :results, :marked, :gis, :evalue
  
  
	def before_results(controller_params)

		@results = []
		@marked = []
		@gis = []
		@evalue = []

		resfile = File.join(job_dir, jobid+".out")
		raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile)
		if File.zero?(resfile)
			return
		end
		res = IO.readlines(resfile)
		
		res.each do |line|
			if (line =~ /^>(.*)$/)
				@results << $1
			elsif (line =~ /^\s*(\S+)\s+(\S+)\s+(\S+)/)
				@marked << $1
				@gis << $2
				@evalue << $3
			end
		end
		
	end
  
  
end
