class HhblitsShowtemplalignAction < Action

  def do_fork?
    return false
  end
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @dba3m = "#{DATABASES}/hhblits/uniprot20_a3m"
    @mode = params["alformat"]
    @hit = params["hits"]
    @oldhit = nil   
    @seq_name
    @commands = []
    @local_dir="/tmp"

    lines = IO.readlines(@basename + ".hhr")

    lines.each do |line|
        if(line =~ /^\s*(\d+)/)
            if($1 == @hit)
                
                # Extract sequence identifier (assuming prefixed by tr)
                line =~ /(tr|sp)\|(.*)\|/
                @seq_name = $2
                break
            end
        end
    end

    # If oldhit number is the same as requested hit number, set $oldhit to something ne ""
    last_action = job.actions.reverse.find() {|a| a.class == self.class && a.id != self.id} 
    if last_action && last_action.params['hits'] == @hit then @oldhit = true end
    
    logger.debug "Old hit: #{@oldhit}!"
  end
  
  def perform
    
   # Such that we can use the new hh-suite
   @commands << ". #{SETENV}"   
   params_dump
    
    # Extract database A3M-file
    if(!File.exist?(@basename + "." + @seq_name + ".a3m"))
      # hhlibUsed = true not required for ffindex_get
      @commands << "ffindex_get #{@dba3m}.ffdata #{@dba3m}.ffindex #{@seq_name} > #{@basename}.#{@seq_name}.a3m"
    end

    # Generate FASTA formatted file for JALVIEW?
    if (@oldhit.nil? || !File.exist?(@basename + ".template.fas"))
      # Filter out 100 most different sequences
      @commands << "hhfilter -i #{@basename}.#{@seq_name}.a3m -o #{@local_dir}/#{job.jobid}.template.reduced.a3m -diff 100"
      @commands << "reformat.pl a3m fas #{@local_dir}/#{job.jobid}.template.reduced.a3m #{@basename}.template.fas"
    end
    
    
    ## Generate FASTA formatted file for JALVIEW (reduced alignment)		    		
    if (@oldhit.nil? || !File.exist?(@basename + ".template.reduced.fas"))
      # Filter out 50 most different sequences
      @commands << "hhfilter -i #{@basename}.#{@seq_name}.a3m -o #{@local_dir}/#{job.jobid}.template.reduced.a3m -diff 50"
      @commands << "reformat.pl -r a3m fas #{@local_dir}/#{job.jobid}.template.reduced.a3m #{@basename}.template.reduced.fas"
      @commands << "rm #{@local_dir}/#{job.jobid}.template.reduced.a3m"
    end

    case @mode 
    when 'fasta'
      @commands << "cp #{@basename}.template.fas #{@basename}.alnout"
    when 'clustal'
      @commands << "reformat.pl a3m clu #{@basename}.#{@seq_name}.a3m #{@basename}.alnout"
    else
      @commands << "cp #{@basename}.#{@seq_name}.a3m #{@basename}.alnout"
    end

    #logger.debug "Commands:\n"+@commands.join("\n")
    @commands << ". #{UNSETENV}"
    queue.submit(@commands)
   # queue.submit(@commands, true, {'queue' => QUEUES[:immediate]})
  end
end


