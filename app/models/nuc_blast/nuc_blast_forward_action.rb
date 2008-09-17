class NucBlastForwardAction < Action
  HITLIST_START_IDENT = 'Sequences producing significant alignments:                      (bits) Value'
  HITLIST_END_IDENT = '</PRE>'
  
  UTILS = File.join(BIOPROGS, 'perl')
  BLAST = File.join(BIOPROGS, 'blast')
    
  attr_accessor :hits, :includehits, :alignment
	
  validates_checkboxes(:hits, {:on => :create, :include => :includehits, :alternative => :alignment})
    
  def run
    logger.debug "Forward Action!"
    @basename = File.join(job.job_dir, job.jobid)
    @outfile = @basename + ".forward"
    @commands = []
    
    File.delete(@outfile) if File.exist?(@outfile)
    
    includehits = params['includehits']
    hitsevalue = params['hitsevalue']
        
    @hits = params['hits']
        
    infile = @basename + ".nucblast"
    @res = IO.readlines(infile).map {|line| line.chomp}    
      
    @hits_start = @res.rindex(HITLIST_START_IDENT)+2
    @hits_end = @res.size-2 - @res[@hits_start..-1].reverse.rindex(HITLIST_END_IDENT)
    hit_lines = @res[@hits_start..@hits_end]
      
    if (includehits == "byevalue")
      logger.debug "byevalue!"
      if (hitsevalue =~ /^e.*$/) 
        hitsevalue = "1" + hitsevalue 
      end
      @hits = []
      hit_lines.each do |hit_line|
        hit_line.scan(/<a href = \#(\d+)>\s*\d+<\/a>\s+(\d+.*)$/) do |name, eval|
          if (eval.to_f < hitsevalue.to_f)
            @hits << name
          end
        end
      end
    else
      # Remove redundant hits
 	   @hits.uniq!
    end
    
    seq = ""
    names = []
    seqs = []
      
    i = @hits_end
    while (i < @res.size)
    	if (@res[i] =~ /<a name = (\d+)><\/a>(.*)$/)
      	name = ">" + $2
      	seq = ""
      	if (@hits.include?($1))
      		i += 1
      		while (@res[i] !~ /Length/)
      			name += @res[i]
      			i += 1
      		end
      		
      		while (@res[i] !~ /<\/PRE>/)
      			if (@res[i] =~ /^Sbjct: \d+\s+(\S*)\s+\d+/)
      				seq += $1
      			end
      			i += 1
      		end
      		
      		name.gsub!(/\s+/, ' ')
      		name.gsub!(/<a href.*?>/, '')
      		name.gsub!(/<\/a>/, '')
				seq.gsub!(/-/, '')
		
				names << name
				seqs << seq
      	end
      end
      i += 1
    end
    
    File.open(@outfile, "w") do |file|
      for i in 0...names.size
      	file.write(names[i] + "\n")
      	file.write(seqs[i] + "\n")	
      end
    end
    
    self.status = STATUS_DONE
    self.save!
    job.update_status

  end
  
  def forward_params
    res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
    {'sequence_input' => res.join}
  end
    
end

