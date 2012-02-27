class HhblitsShowtemplalignAction < Action
  HH = File.join(BIOPROGS, 'hhblits')
  
  def do_fork?
    return false
  end
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    
    @dba3m = job.params_main_action['hhblits_dbs'] + "_a3m_db"

    @mode = params["alformat"]
    @hit = params["hits"]
    
    @oldhit = nil             
    @seq_name
    
    @commands = []
    @local_dir="/tmp"

    lines = IO.readlines(@basename + ".hhr")

    lines.each do |line|
      line.scan(/^\s*(\d+)\s+\S+?\|(\S+?)\|/) do |a,b|
        if (a && b && a == @hit)
          @seq_name = b
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
    params_dump
    
    # Extract database A3M-file
    if (!File.exist?(@basename + "." + @seq_name + ".a3m"))
      @commands << "#{HH}/ffindex_get #{@dba3m} #{@dba3m}.index #{@seq_name}.a3m > #{@basename}.#{@seq_name}.a3m"
    end

    # Generate FASTA formatted file for JALVIEW?
    if (@oldhit.nil? || !File.exist?(@basename + ".template.fas"))
      # Filter out 100 most different sequences
      @commands << "#{HH}/hhfilter -i #{@basename}.#{@seq_name}.a3m -o #{@local_dir}/#{job.jobid}.template.reduced.a3m -diff 100"
      @commands << "#{HH}/reformat.pl a3m fas #{@local_dir}/#{job.jobid}.template.reduced.a3m #{@basename}.template.fas"
    end
    
    # Generate FASTA formatted file for JALVIEW (reduced alignment)		    		
    if (@oldhit.nil? || !File.exist?(@basename + ".template.reduced.fas"))
      # Filter out 50 most different sequences
      @commands << "#{HH}/hhfilter -i #{@basename}.#{@seq_name}.a3m -o #{@local_dir}/#{job.jobid}.template.reduced.a3m -diff 50"
      @commands << "#{HH}/reformat.pl -r a3m fas #{@local_dir}/#{job.jobid}.template.reduced.a3m #{@basename}.template.reduced.fas"
      @commands << "rm #{@local_dir}/#{job.jobid}.template.reduced.a3m"
    end

    case @mode 
    when 'fasta'
      @commands << "cp #{@basename}.template.fas #{@basename}.alnout"
    when 'clustal'
      @commands << "#{HH}/reformat.pl a3m clu #{@basename}.#{@seq_name}.a3m #{@basename}.alnout"
    else
      @commands << "cp #{@basename}.#{@seq_name}.a3m #{@basename}.alnout"
    end
    
    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands, true, {'queue' => QUEUES[:immediate]})
  end
  
end


