class HhrepReloadAction < Action
  HH = File.join(BIOPROGS, 'hhpred')
  
  def do_fork?
    return false
  end
  
  # Put action initialisation code in here
  def before_perform
    
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    @ss_scoring = "-ssm " + job.params_main_action["ss_scoring"]
    @aliwidth = job.params_main_action["width"].to_i < 20 ? "20" : job.params_main_action['width']
    
    @dwin = params["dwin"]
    @dthr = params["dthr"]
    @qid = params["qid"]
    @hits = params["hits"].nil? ? "" : params["hits"]
    
    if (!@hits.empty?)
      @hits = @hits.uniq!.join(" ")
    end
		
    logger.debug "Hits: " + @hits		
    
  end
  
  
  # Put action code in here
  def perform
    
    # Links to file
    #		@commands << "rm -f #{@basename}.a3m; ln -s #{@basename}.#{@qid}.a3m #{@basename}.a3m"
    #		@commands << "rm -f #{@basename}.hhm; ln -s #{@basename}.#{@qid}.hhm #{@basename}.hhm"
    #		@commands << "rm -f #{@basename}.tar.gz; ln -s #{@basename}.#{@qid}.tar.gz #{@basename}.tar.gz"
    #		@commands << "rm -f #{@basename}.fas; ln -s #{@basename}.#{@qid}.fas #{@basename}.fas"
    #		@commands << "rm -f #{@basename}.reduced.fas; ln -s #{@basename}.#{@qid}.reduced.fas #{@basename}.reduced.fas"
    
    # hhalign HMM with itself
    #		@commands << "#{HH}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 600 -v 1 -i #{@basename}.hhm -o #{@basename}.hhr -dmap #{@basename}.dmap -png #{@basename}.png -dwin #{@dwin} -dthr #{@dthr} -dali #{@hits} 1>>#{job.statuslog_path} 2>&1"
    # create png-file with factor 3
    #		@commands << "#{HH}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 3 -i #{@basename}.hhm -png #{@basename}_factor3.png -dwin #{@dwin} -dthr #{@dthr} -dali #{@hits} 1>>#{job.statuslog_path} 2>&1"
    
    #		logger.debug "Commands2:\n"+@commands.join("\n")
    #		queue.submit(@commands)
    
    # Links to file
    system("rm -f #{@basename}.a3m; ln -s #{@basename}.#{@qid}.a3m #{@basename}.a3m")
    system("rm -f #{@basename}.hhm; ln -s #{@basename}.#{@qid}.hhm #{@basename}.hhm")
    system("rm -f #{@basename}.tar.gz; ln -s #{@basename}.#{@qid}.tar.gz #{@basename}.tar.gz")
    system("rm -f #{@basename}.fas; ln -s #{@basename}.#{@qid}.fas #{@basename}.fas")
    system("rm -f #{@basename}.reduced.fas; ln -s #{@basename}.#{@qid}.reduced.fas #{@basename}.reduced.fas")
    
    # hhalign HMM with itself
    system("#{HH}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 600 -v 1 -i #{@basename}.hhm -o #{@basename}.hhr -dmap #{@basename}.dmap -png #{@basename}.png -dwin #{@dwin} -dthr #{@dthr} -dali #{@hits} 1>>#{job.statuslog_path} 2>&1")
    # create png-file with factor 3
    system("#{HH}/hhalign -aliw #{@aliwidth} -local #{@ss_scoring} -alt 20 -dsca 3 -i #{@basename}.hhm -png #{@basename}_factor3.png -dwin #{@dwin} -dthr #{@dthr} -dali #{@hits} 1>>#{job.statuslog_path} 2>&1")
    
    self.status = STATUS_DONE
    self.save!
    job.update_status
    
  end

end



