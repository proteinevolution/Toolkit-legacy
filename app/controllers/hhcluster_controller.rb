class HhclusterController < ToolController

	HH = File.join(BIOPROGS, "hhpred")
	HHCLUSTER = File.join(BIOPROGS, "hhcluster")

	def index
		@widescreen = true
		@color_scheme = ["fa", "sf", "fd", "cl"]
		@color_scheme_names = ["families", "superfamilies", "fold", "class"]
		@coloring = params['coloring'] ? params['coloring'] : "cl"
		@img_path = "/images/hhcluster/" + HHCLUSTER_DB + "/" + HHCLUSTER_DB
		@images = {'cl' => @img_path + "_cl.gif", 'fd' => @img_path + "_fd.gif",
					  'fa' => @img_path + "_fa.gif", 'sf' => @img_path + "_sf.gif", 
					  'default' => @img_path + "_" + @coloring + ".gif"}
					
		@mapfile = HHCLUSTER_DB_PATH + "/config/" + HHCLUSTER_DB + "_" + @coloring + ".map"
		@map = ""
		if File.exist?(@mapfile) && File.size?(@mapfile)
			@map = IO.readlines(@mapfile).join
		end
	end
	
	def search
		@id = params['jobid'] ? params['jobid'] : ""	
	end
	
	def results
		@id = params['jobid'] ? params['jobid'] : ""
		@color_scheme = ["fa", "sf", "fd", "cl"]
		@color_scheme_names = ["families", "superfamilies", "fold", "class"]
		@coloring = params['coloring'] ? params['coloring'] : "cl"
		@img_path = File.join(@job.url_for_job_dir, @job.jobid)
		@images = {'cl' => @img_path + "_cl.gif", 'fd' => @img_path + "_fd.gif",
					  'fa' => @img_path + "_fa.gif", 'sf' => @img_path + "_sf.gif", 
					  'default' => @img_path + "_" + @coloring + ".gif"}
					
		@mapfile = HHCLUSTER_DB_PATH + "/config/" + HHCLUSTER_DB + "_" + @coloring + ".map"
		@map = ""
		if File.exist?(@mapfile) && File.size?(@mapfile)
			@map = IO.readlines(@mapfile).join		
		end
	end
	
	def update
		hits = params['hits'] ? params['hits'] : []
		
		@basename = File.join(@job.job_dir, @job.jobid)
		gifile = @basename + ".gis"
		
		res = IO.readlines(@basename + ".out")
		
		File.open(gifile, "w") do |file|
			if params['userUpdateCluster']
				file.write hits.join("\n")
				File.open(@basename + ".out", "w") do |out|
					res.each do |line|
						if (line !~ /^>/ && line =~ /^\s*(\S+)\s+(\S+)\s+(\S+)/)
							if (hits.include?($2))
								line = "true #{$2} #{$3}\n"
							else
								line = "false #{$2} #{$3}\n"
							end							
						end
						out.write(line)
					end
				end
			else
				# find marked gis in result file
				res.each do |line|
					if (line !~ /^>/ && line =~ /^\s*(\S+)\s+(\S+)\s+(\S+)/)
						gi = $2
						mark = $1
						if (mark == "true")
							file.write gi + "\n"
						end
					end
				end
			end
		end
		
		@cb = ""
		if (@job.actions.last.params['crossbars'])
			@cb = "-c"
		end
		
		['cl', 'fd', 'sf', 'fa'].each do |cs|
			hhcluster_file = File.join(HHCLUSTER_DB_PATH, 'config', HHCLUSTER_DB + "_" + cs + ".hhcluster")
			img_in_file = File.join(TOOLKIT_ROOT, 'public', 'images', 'hhcluster', HHCLUSTER_DB, HHCLUSTER_DB + "_" + cs + ".png")
			img_out_file = @basename + "_" + cs + ".gif"
			
			command = "#{HHCLUSTER}/hhcluster_imgprocessor.pl #{@cb} #{hhcluster_file} #{img_in_file} #{img_out_file} #{gifile}"
			logger.debug "###### Command: #{command}"
			system(command)
			
		end

		redirect_to(:host => DOC_ROOTHOST, :controller => 'hhcluster', :action => 'results', :jobid => @job)
	end
		
	def makeHhpred 
		@id = params['id']
			
		hhpred_job = Object.const_get("HhpredJob").create({:controller => 'hhpred', 'jobid' => nil}, @user)
      
      @basename = File.join(HHCLUSTER_DB_PATH, @id)
      @hhpred_basename = File.join(hhpred_job.job_dir, hhpred_job.jobid)
      
      FileUtils.cp(@basename + ".a3m", @hhpred_basename + ".a3m")
      FileUtils.cp(@basename + ".hhr", @hhpred_basename + ".hhr")
      FileUtils.cp(@basename + ".hhm", @hhpred_basename + ".hhm")
      FileUtils.cp(@basename + ".fas", @hhpred_basename + ".fas")
      FileUtils.cp(@basename + ".reduced.fas", @hhpred_basename + ".reduced.fas")
      FileUtils.cp(@basename + ".pdb", @hhpred_basename + ".pdb")
      
      res = IO.readlines(@hhpred_basename + ".fas")
      File.open(@hhpred_basename + ".in", "w") do |file|
      	check = false
      	res.each do |line|
      		if (line =~ /^>[^ss]/) then check = true end
      		if (check)
      			file.write(line)
      		end
      	end
      end
      
      scop_db = Dir.glob(File.join(DATABASES, 'hhpred/new_dbs/scop*'))[0]
      
      hhpred_params = {:controller => 'hhpred', 'jobid' => nil, 'reviewing' => 'true',
                       'job' => 'hhpred', 'action' => 'run', 
                       'sequence_input' => nil,
                       'sequence_file' => @hhpred_basename + ".in",
                       'informat' => 'fas', 'width' => '80', 'maxlines' => '100',
                       'cov_min' => '20', 'Pmin' => '20', 'maxseq' => '1', 'qid_min' => '0',
                       'ss_scoring' => '2', 'maxpsiblastit' => '8', 'Espiblastbal' => '1E-3',
                       'alignmode' => 'global', 'hhpred_dbs' => [scop_db]}
      
      hhpred_action = Object.const_get("HhpredAction").new(:params => hhpred_params,
                                                          :job => hhpred_job,
                                                          :status => STATUS_DONE,
                                                          :forward_controller => 'hhpred',
                                                          :forward_action => 'results'
                                                          )
                                                          
		hhpred_params.each do |key,value|                                                 
        if (key != "controller" && key != "action" && key != "job" && key != "parent" && key != "method" &&
            key != "forward_controller" && key != "forward_action" && hhpred_action.respond_to?(key))
          eval "hhpred_action."+key+" = value"
        end
      end
      
      
      hhpred_action.flash = {'hhcluster' => true}
      
      hhpred_action.save!

		# Generate graphical display of hits
		command = "#{HH}/hhviz.pl #{hhpred_job.jobid} #{hhpred_job.job_dir} #{hhpred_job.url_for_job_dir} &> #{hhpred_job.statuslog_path}"
		logger.debug "###### Command: #{command}"
		system(command)
    
		###############################
		# Get profile histogram images
		FileUtils.cp(@basename + ".tar.gz", "/tmp/" + hhpred_job.jobid + ".tar.gz")
		system("tar -xzf /tmp/" + hhpred_job.jobid + ".tar.gz -C /tmp/")
		
		# Rename all .png files
		Dir.glob("/tmp/#{@id}_*.png").each do |file|
			newfile = file.sub(/#{@id}/, hhpred_job.jobid)
			File.rename(file, newfile)
		end
		
		# Replace $scopid by $id in all map files and rename files
		Dir.glob("/tmp/#{@id}_*.map").each do |file|
			newfile = file.sub(/#{@id}/, hhpred_job.jobid)
			lines = IO.readlines(file)
			File.open(newfile, "w") do |out|
				lines.each do |line|
					line.gsub!(/#{@id}/, hhpred_job.jobid)
					line.gsub!(/IMAGEDIR/, hhpred_job.url_for_job_dir)
					out.write(line)
				end
			end
		end
		
		system("cd /tmp/; tar -czf #{@hhpred_basename}.tar.gz #{hhpred_job.jobid}_*.*")
		system("rm /tmp/#{@id}*")
		system("rm /tmp/#{hhpred_job.jobid}*")
		##################################
		
		hhpred_job.status = STATUS_DONE
		hhpred_job.save!
		
		@jobs_cart.push(hhpred_job.jobid)

		redirect_to(:host => DOC_ROOTHOST, :controller => 'hhpred', :action => 'results', :jobid => hhpred_job)
		
	end
  
end
