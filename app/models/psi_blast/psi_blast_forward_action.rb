class PsiBlastForwardAction < Action
  HITLIST_START_IDENT = 'Sequences producing significant alignments:                      (bits) Value'
  HITLIST_END_IDENT = '</PRE>'
  
  UTILS = File.join(BIOPROGS, 'perl')
  BLAST = File.join(BIOPROGS, 'blast')

  include GenomesModule
  
  def do_fork?
    return false
  end
  
  attr_accessor :hits, :includehits, :alignment
	
  validates_checkboxes(:hits, {:on => :create, :include => :includehits, :alternative => :alignment})
    
  def perform
    logger.debug "Forward Action!"
    @basename = File.join(job.job_dir, job.jobid)
    @outfile = @basename + ".forward"
    @commands = []
    File.delete(@basename + ".fw_gis") if File.exist?(@basename + ".fw_gis")
    File.delete(@outfile) if File.exist?(@outfile)
    
    mode = params['fw_mode']
    @seqlen = params['seqlen']
    includehits = params['includehits']
    hitsevalue = params['hitsevalue']
    alignment = params['alignment']
        
    @hits = params['hits']
        
    # from result_alignment?
    if (@hits.nil? && !alignment.nil?)
      logger.debug "result_alignment page!"
      File.open(@outfile, "w") do |file|
        file.write(alignment)
      end
    else
      logger.debug "result page!"
      infile = @basename + ".psiblast"
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
          hit_line.scan(/<a href = \#(\S+)>\s*\d+<\/a>\s+(\d+.*)$/) do |name, eval|
            if (eval.to_f < hitsevalue.to_f)
              @hits << name
            end
          end
        end
      else
      	# Remove redundant hits
	      @hits.uniq!
     	end
      
      if (mode.nil? || mode == "alignment")
        make_blast_output
      else
        make_seqs_output
      end
      
      if (!mode.nil? && mode == "alignment")
        FileUtils.mv(@outfile, @outfile + "_prepare")
        @commands << "#{UTILS}/alignhits_html.pl #{@outfile}_prepare #{@outfile} -fas -no_link -e 100 -Q #{@basename}.fasta"
      end
    end
    
    if (@commands.empty?)
      logger.debug "commands empty!"
      self.status = STATUS_DONE
      self.save!
      reload
      job.update_status
    else
      logger.debug "Commands:\n"+@commands.join("\n")
      queue.submit(@commands, true, {'queue' => 'toolkit_immediate'})
    end

  end
  
  def make_blast_output
    	job.before_results
    
  		res = job.header
  		res << job.searching
		job.hits_better.each do |h|
			if( hits.include?(h[:id]) )
				res << h[:content]
			end
		end
		if( job.hits_prev.length>0 )
			res << "Sequences not found previously or not previously below threshold:\n"
		end
		job.hits_prev.each do |h|
			if( hits.include?(h[:id]) )
				res << h[:content]
			end
		end
		job.hits_worse.each do |h|
			if( hits.include?(h[:id]) )
				res << h[:content]
			end
		end
		res << "</PRE>" 
		res << ""
   	job.alignments.each do |h|
			if( hits.include?(h[:id]) )
				res << "<PRE>"
				res << h[:content]
				res << "</PRE>"
			end
		end
		res << "<PRE>" 
		res << job.footer
		res << "</PRE>"

		out = File.new(@outfile, "w+")
		out.write("<PRE>\n")
		out.write(res.join("\n"))
		out.write("</PRE>\n")
		out.close
  end
  
  def make_seqs_output
    i = @hits_end
    while (i < @res.size)
      if (@res[i] =~ /^\s*Database:/) then break end
      #><a name = 82736116><
      if (@res[i] =~ /^\s*><a name = (\S+?)>/)
        if @hits.include?($1)
          if (!@seqlen.nil? && @seqlen == "complete")
            if (@res[i] =~ /(gi\|\d+\|)/ || @res[i] =~ /^>(.*)<\/a>.*?$/)
              ret = $1
              ret.gsub!(/<.*?>/, '')
              File.open(@basename + ".fw_gis", "a") do |file|
                file.write(ret + "\n")
              end
            end
          else
            name = @res[i]
            name.sub!(/<a name = \d+><\/a>/, '')
            name.sub!(/<a href=\S+ >/, '')
            name.sub!(/<\/a>/, '')

            seq_data = ""
				while (i < @res.size)
				  if (@res[i] =~ /^<\/PRE>$/) then break end
				  if (@res[i] =~ /^Sbjct:\s*\d+\s*(\S+)\s*\d+\s*$/)
				    seq_data += $1
				  end
				  i += 1
				end
				File.open(@outfile, "a") do |file|
              file.write(name + "\n" + seq_data + "\n")
            end
          end
        end
      end
      i += 1
    end
    
    if (!@seqlen.nil? && @seqlen == "complete")

      # Get path of databases
      @db_path = job.params_main_action['std_dbs'].nil? ? "" : job.params_main_action['std_dbs'].join(' ')
      @db_path = job.params_main_action['user_dbs'].nil? ? @db_path : @db_path + ' ' + job.params_main_action['user_dbs'].join(' ')
      # get Genomes Databases
      if( job.params_main_action['taxids'] )
        ret = []
        genomesjar = File.join(BIOPROGS, "genomes", "genomes.jar")
        cmd = "#{JAVA_1_5_EXEC} -jar #{genomesjar} -pep -nolog -dbs #{job.params_main_action['taxids']} 2>&1"
        proc = IO.popen(cmd)
        ret = proc.readlines.map{|line| line.chomp};
        proc.close
        exit_status = $?.exitstatus
        if( exit_status!=0 ) then
          raise("ERROR in execution of #{cmd}\nERROR_EXIT_CODE: #{exit_status}\nERROR_MESSAGE: #{ret}\nPARAMS: #{data_type}");    
        end   
        @db_path += ' ' + ret.join(' ')
      end

      logger.debug "Database path: #{@db_path}\n"

      @commands << "#{UTILS}/seq_retrieve.pl -i #{@basename}.fw_gis -o #{@outfile} -b #{BLAST} -unique -d '#{@db_path}'"
    end
  
  
  end
  
  def forward_params
    logger.debug "Forward params!"
    res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
    mode = params['fw_mode']
    inputmode = "alignment"
    if (!mode.nil? && mode == "sequence")
      inputmode = "sequence"
    end
    if (params['forward_controller'] == "patsearch")
      {'db_input' => res.join, 'std_dbs' => ""}
    else
      {'sequence_input' => res.join, 'inputmode' => inputmode}
    end
  end
    
end

