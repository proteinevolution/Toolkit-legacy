class HhpredShowtemplalignAction < Action
  HH = File.join(BIOPROGS, 'hhpred')
  
  def do_fork?
    return false
  end
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    
    @mode = params["alformat"]
    @hit = params["hits"]
    
    @oldhit = nil             
    @seq_name
    
    @commands = []
    @local_dir="/tmp"

    lines = IO.readlines(@basename + ".hhr")
    
    lines.each do |line|
      line.scan(/^\s*(\d+)\s+(\S+)\s+/) do |a,b|
	if (a && b && a == @hit)
	  @seq_name = b.gsub(/(\|)|(\.)/, '_')
	  break
	end
      end
    end
   
    #Search in selected databases for a3m file
    @dir = ""
    action_params = HhpredAction.find(:first, :conditions=>{:job_id=>job_id}).params
    dbs_dir = []
    dbs_dir.concat(action_params['hhpred_dbs']) if !action_params['hhpred_dbs'].nil?
    dbs_dir.concat(action_params['genomes_hhpred_dbs']) if !action_params['genomes_hhpred_dbs'].nil?
    dbs_dir.each do |db_dir|
      if File.exist?(File.join(db_dir, @seq_name + ".a3m"))
	logger.debug "File #{@seq_name}.a3m found in #{db_dir}"
	@dir = db_dir
	break
      end
    end 


    if !File.exist?(File.join(@dir, @seq_name + ".a3m"))
      logger.error "ERROR! File #{@seq_name}.a3m not found in databases!"
      raise "ERROR! File #{@seq_name}.a3m not found in databases!"
    end

    # If oldhit number is the same as requested hit number, set $oldhit to something ne ""
    last_action = job.actions.reverse.find() {|a| a.class == self.class && a.id != self.id} 
    if last_action && last_action.params['hits'] == @hit then @oldhit = true end
    
    logger.debug "Old hit: #{@oldhit}!"
    
  end
  
  def perform
    params_dump
    
    # Generate FASTA formatted file for JALVIEW?
    if (@oldhit.nil? || !File.exist?(@basename + ".template.fas"))
      # Filter out 100 most different sequences
      @commands << "#{HH}/hhfilter -i #{@dir}/#{@seq_name}.a3m -o #{@local_dir}/#{job.jobid}.template.reduced.a3m -diff 100"
      @commands << "#{HH}/reformat.pl a3m fas #{@local_dir}/#{job.jobid}.template.reduced.a3m #{@basename}.template.fas"
    end
    
    # Generate FASTA formatted file for JALVIEW (reduced alignment)		    		
    if (@oldhit.nil? || !File.exist?(@basename + ".template.reduced.fas"))
      # Filter out 50 most different sequences
      @commands << "#{HH}/hhfilter -i #{@dir}/#{@seq_name}.a3m -o #{@local_dir}/#{job.jobid}.template.reduced.a3m -diff 50"
      @commands << "#{HH}/reformat.pl -r a3m fas #{@local_dir}/#{job.jobid}.template.reduced.a3m #{@basename}.template.reduced.fas"
      @commands << "rm #{@local_dir}/#{job.jobid}.template.reduced.a3m"
    end

    case @mode 
    when 'fasta'
      @commands << "cp #{@basename}.template.fas #{@basename}.alnout"
    when 'clustal'
      @commands << "#{HH}/reformat.pl a3m clu #{@dir}/#{@seq_name}.a3m #{@basename}.alnout"
    else
      @commands << "cp #{@dir}/#{@seq_name}.a3m #{@basename}.alnout"
    end
    
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'queue' => QUEUES[:immediate]})
  end
  
end


