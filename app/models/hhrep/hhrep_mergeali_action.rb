class HhrepMergealiAction < Action
	HH = File.join(BIOPROGS, 'hhpred')
  if LOCATION == "Munich" && LINUX == 'SL6'
    HHPERL   = "perl "+File.join(BIOPROGS, 'hhpred')
  else
     HHPERL = File.join(BIOPROGS, 'hhpred')
  end
	CAL_HHM = File.join(DATABASES,'hhpred','cal.hhm')
	
	attr_accessor :hits
	
	validates_checkboxes(:hits, {:on => :create})
	
	# Put action initialisation code in here
	def before_perform
	
		@basename = File.join(job.job_dir, job.jobid)
		@commands = []

		@maxlines = "20"
		@v = 1

		@hits = params["hits"].nil? ? Array.new() : params["hits"]
		@hits.uniq!
		@hits = @hits.join(" ")
		
		logger.debug "Before perform!"
		logger.debug "Hits: #{@hits}"
	
	end


	# Optional:
	# Put action initialization code that should be executed on forward here
	def before_perform_on_forward
	
		logger.debug "Before perform on forward!"
	
		pjob = job.parent
		@parent_job_dir = pjob.job_dir
		@parent_basename = File.join(pjob.job_dir, pjob.jobid)
		@maxpsiblastit = pjob.params_main_action['maxpsiblastit']
		@ss_scoring = "-ssm " + pjob.params_main_action["ss_scoring"]
		@max_seqs = pjob.params_main_action["maxseq"]
		@aliwidth = pjob.params_main_action["width"].to_i < 20 ? "20" : pjob.params_main_action['width']

		logger.debug "Width: #{@aliwidth}"

		self.params['maxpsiblastit'] = pjob.params_main_action['maxpsiblastit']
		self.params['ss_scoring'] = pjob.params_main_action["ss_scoring"]
		self.params['maxseq'] = pjob.params_main_action["maxseq"]
		self.params['width'] = @aliwidth
		
		self.save!

	end
  
  
	# Put action code in here
	def perform

		logger.debug "perform"

		# Make FASTA alignment from query and selected templates (from hhr file).
		@commands << "echo 'Extracting alignment of repeats from previous HMM-HMM comparison' >> #{job.statuslog_path}"
		@commands << "#{HHPERL}/hhmakemodel.pl -v #{@v} -N -m #{@hits} -i #{@parent_basename}.hhr -fas #{@basename}.qt.fas -q #{@parent_basename}.a3m -conj"

		# Merge all alignments whose sequences are given in $basename.qt.fas
		@commands << "echo 'Merging sequence alignments of repeats into super-alignment' 1>>#{job.statuslog_path} 2>&1"
		@commands << "#{HHPERL}/mergeali.pl #{@basename}.qt.fas #{@basename}.a3m -d #{@parent_job_dir} -diff 100 -mark -first -v #{@v}"
		
		# Do PSIPRED prediction?
		if (@ss_scoring != "-ssm 0")
			@commands << "#{HHPERL}/buildali.pl -v 0 -b 0 -maxres 800 -n 0 #{@basename}.a3m 1>>#{job.statuslog_path} 2>&1"
		end
		
		@hash = {}
		@hash['maxlines'] = @maxlines
		@hash['width'] = @aliwidth
		@hash['ss_scoring'] = @ss_scoring
		@hash['hits'] = @hits

		self.flash = @hash
		self.save!
		
		logger.debug "Commands:\n"+@commands.join("\n")
		q = queue
		q.on_done = 'makemodel'
		q.save!
		q.submit(@commands, false)

	end
	
	def makemodel
	
		@basename = File.join(job.job_dir, job.jobid)
		@ss_scoring = flash["ss_scoring"]
		@maxlines = flash["maxlines"]
		@aliwidth = flash["width"]
		
		['30', '40', '50', '0'].each do |qid|
			@commands = []
			# Filter alignment
			@commands << "#{HH}/hhfilter -diff 500 -qid #{qid} -i #{@basename}.a3m -o #{@basename}.#{qid}.a3m 1>>#{job.statuslog_path} 2>&1"
			# Make HMM from alignment
			@commands << "#{HH}/hhmake -i #{@basename}.#{qid}.a3m -o #{@basename}.#{qid}.hhm 1>>#{job.statuslog_path} 2>&1"
			# Calibrate hhm file
			@commands << "#{HH}/hhsearch -cpu 2 -v 1 -i #{@basename}.#{qid}.hhm -d #{CAL_HHM} #{@ss_scoring} -cal 1>>#{job.statuslog_path} 2>&1"
			# hhalign HMM with itself
			@commands << "#{HH}/hhalign -aliw #{@aliwidth} -local -p 10 -alt #{@maxlines} -v 1 -i #{@basename}.#{qid}.hhm -o #{@basename}.#{qid}.hhr #{@ss_scoring} 1>>#{job.statuslog_path} 2>&1"
			# Prepare FASTA files for 'Show Query Alignemt', and HMM histograms
			prepare_fasta_hhviz_histograms_etc("#{@basename}.#{qid}", "#{job.jobid}.#{qid}")
			
			logger.debug "Commands:\n"+@commands.join("\n")
			q = queue
			if qid == '0'
				q.on_done = 'create_links'
				q.save!
			end
                        q.submit(@commands, false, { 'cpus' => '2' })
			
		end
		
	end
	
	def create_links
	
		@basename = File.join(job.job_dir, job.jobid)
		@ss_scoring = flash["ss_scoring"]
		@maxlines = flash["maxlines"]
		@aliwidth = flash["width"]
		@hits = flash['hits']
		@commands = []
		
		# Links to file
		@commands << "rm -f #{@basename}.a3m; ln -s #{@basename}.0.a3m #{@basename}.a3m"
		@commands << "rm -f #{@basename}.hhm; ln -s #{@basename}.0.hhm #{@basename}.hhm"
		@commands << "rm -f #{@basename}.tar.gz; ln -s #{@basename}.0.tar.gz #{@basename}.tar.gz"
		@commands << "rm -f #{@basename}.fas; ln -s #{@basename}.0.fas #{@basename}.fas"
		@commands << "rm -f #{@basename}.reduced.fas; ln -s #{@basename}.0.reduced.fas #{@basename}.reduced.fas"
		# hhalign HMM with itself
		@commands << "#{HH}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt #{@maxlines} -dsca 600 -v 1 -i #{@basename}.0.hhm -o #{@basename}.hhr -dmap #{@basename}.dmap -png #{@basename}.png -dwin 10 -dthr 0.4 -dali all 1>>#{job.statuslog_path} 2>&1"
		# create png-file with factor 3
		@commands << "#{HH}/hhalign -aliw #{@aliwidth} -local -alt 1 -dsca 3 -i #{@basename}.0.hhm -png #{@basename}_factor3.png -dwin 10 -dthr 0.4 -dali all 1>>#{job.statuslog_path} 2>&1"
		
		logger.debug "Commands:\n"+@commands.join("\n")
		queue.submit(@commands)
	
	end
	
	# Prepare FASTA files for 'Show Query Alignemt', HHviz bar graph, and HMM histograms 
  def prepare_fasta_hhviz_histograms_etc(basename, id)
    @local_dir = '/tmp'
  
    # Reformat query into fasta format ('full' alignment, i.e. 100 maximally diverse sequences, to limit amount of data to transfer)
    @commands << "#{HH}/hhfilter -i #{basename}.a3m -o #{@local_dir}/#{id}.reduced.a3m -diff 100"
    @commands << "#{HHPERL}/reformat.pl a3m fas #{@local_dir}/#{id}.reduced.a3m #{basename}.fas -d 160"  # max. 160 chars in description 
    
    # Reformat query into fasta format (reduced alignment)  (Careful: would need 32-bit version to execute on web server!!)
    @commands << "#{HH}/hhfilter -i #{basename}.a3m -o #{@local_dir}/#{id}.reduced.a3m -diff 50"
    @commands << "#{HHPERL}/reformat.pl a3m fas #{@local_dir}/#{id}.reduced.a3m #{basename}.reduced.fas -r"
    @commands << "rm #{@local_dir}/#{id}.reduced.a3m"
    
    # Generate graphical display of hits
    @commands << "#{HHPERL}/hhviz.pl #{id} #{job.job_dir} #{job.url_for_job_dir} &> /dev/null"
    
    # Generate profile histograms
    @commands << "#{HHPERL}/profile_logos.pl #{id} #{job.job_dir} #{job.url_for_job_dir} > /dev/null"
  end

end



