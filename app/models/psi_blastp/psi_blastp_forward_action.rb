class PsiBlastpForwardAction < Action
  require 'ForwardActions.rb'
  include ForwardActions
  HITLIST_LINE_PATTERN = /<a href\s*=\s*\#\d+>\s*\d+<\/a>/

  UTILS = File.join(BIOPROGS, 'perl')
  BLAST = File.join(BIOPROGS, 'blast')

  include GenomesModule

  def do_fork?
    return false
  end

  attr_accessor :hits, :includehits, :alignment

  validates_checkboxes(:hits, {:on => :create, :include => :includehits, :alternative => :alignment})

  def run
    logger.debug "Forward Action!"
    @basename = File.join(job.job_dir, job.jobid)
    @outfile = @basename + ".forward"
    @commands = []
    File.delete(@basename + ".fw_gis") if File.exist?(@basename + ".fw_gis")
    File.delete(@outfile) if File.exist?(@outfile)

    mode = params['fw_mode']
    @seqlen = params['seqlen']
    @seqlen = "slider" if (@seqlen.nil?)
    @seqlen_start = params['domain_start'].to_i
    @seqlen_end = params['domain_end'].to_i
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
      infile = @basename + ".psiblastp"
      @res = IO.readlines(infile).map {|line| line.chomp}
      @hits_start = 1
      @hits_end = 0
      @res.each_index { |index|
        if (@res[index]=~HITLIST_LINE_PATTERN)
          if (0 == @hits_end)
            @hits_start = index
          end
          @hits_end = index
        elsif @res[index]=~/^>/
          break
        elsif (@hits_end > 0)
          break
        end
      }
      hit_lines = @res[@hits_start..@hits_end]

      # get hits to be forwarded
      if (includehits == "byevalue")
	logger.debug "byevalue!"
	if (hitsevalue =~ /^e.*$/)
	  hitsevalue = "1" + hitsevalue
	end
	@hits = []
	hit_lines.each do |hit_line|
	  hit_line.scan(/<a href\s*=\s*\#(\d+)>\s*\d+<\/a>\s+(\S+.*)$/) do |name, eval|
	    if (eval =~ /^e.*$/)
	      eval = "1" + eval
	    end
	    if (eval.to_f < hitsevalue.to_f)
	      @hits << name
	    end
	  end
	end
      else
	# remove redundant hits
	  @hits.uniq!
      end

      if (mode.nil? || mode == "alignment")
        make_blast_output
      else
        make_seqs_output
      end

      if (!mode.nil? && mode == "alignment")
        FileUtils.mv(@outfile, @outfile + "_prepare")
        @commands << "#{UTILS}/alignhits_html.pl #{@outfile}_prepare #{@outfile} -fas -no_link -e 999999 -Q #{@basename}.fasta" + (@seqlen == "slider" ? sprintf(" -qs %d -qe %d", @seqlen_start, @seqlen_end) : "")
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
      queue.submit(@commands, true, {'queue' => QUEUES[:immediate]})
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
      #if (@res[i] =~ /^\s*><a name = (\S+?)>/)
      if (@res[i] =~ /^\s*><a name =\s*(\w[\w|\d]+)>/)
        if @hits.include?($1)
          if (!@seqlen.nil? && @seqlen == "complete")
            logger.debug "LINE 150 "+$1
           if (@res[i] =~ /(\w\w\|\w[\w|\d]+\|)/)
              logger.debug "LINE 152 "+$1
              ret = $1
              ret.gsub!(/<.*?>/, '')
              File.open(@basename + ".fw_gis", "a") do |file|
                file.write(ret + "\n")
              end
            end
          else
            name = @res[i]
           #name.sub!(/<a name = \d+><\/a>/, '')
            name.sub!(/<a name = \w[\w|\d]+><\/a>/, '')
            if name=~ /<a href="http:\/\/www.uniprot.org\/uniprot\/(.*)"/
              name.sub!(/<a href=.*>/, "#{$1}")
            else
              name.sub!(/<a href=\S+" >/, '')
            end
             # this removes the complete HREF Tag from the ProtBlast run
            name.sub!(/<a href=.*>/, '')
            name.sub!(/<\/a>/, '')

            seq_data = ""
	    first_res = nil;
	    last_res = nil;
	    while (i < @res.size)
	      if (@res[i] =~ /^<\/PRE>$/) then break end
	      if (@res[i] =~ /^(\w+):\s*(\d+)\s+(\S+)\s+(\d+)\s*$/) 
		if ($1 == "Query")
	   	  if (first_res.nil?) then first_res = $2.to_i end
		  last_res = $4.to_i
	        elsif ($1 == "Sbjct")
		  seq_data += $3
	        end
	      end
	      i += 1
	    end
	    if (!first_res.nil? && (last_res - first_res + 1 <= seq_data.length))
	      if (@seqlen == "slider")
		if (first_res < @seqlen_start) 
		  seq_data = seq_data[@seqlen_start - first_res, seq_data.length]
		  first_res = @seqlen_start
		end
		if (!seq_data.nil? && last_res > @seqlen_end)
		  seq_data = seq_data[0, @seqlen_end - first_res + 1]
		  last_res = @seqlen_end
		end
	      end
	      if (!seq_data.nil? && seq_data.length > 0) 
		File.open(@outfile, "a") do |file|
		  file.write(name + "\n" + seq_data + "\n")
		end
	      end
	    end
          end
        end
      end
      File.open(@outfile, "a") do |file| file.write("") end
      i = i + 1
    end
    
    if (!@seqlen.nil? && @seqlen == "complete")

      # Get path of databases
      @db_path = job.params_main_action['std_dbs'].nil? ? "" : job.params_main_action['std_dbs'].join(' ')
      @db_path = job.params_main_action['user_dbs'].nil? ? @db_path : @db_path + ' ' + job.params_main_action['user_dbs'].join(' ')
      # get Genomes Databases
      if( job.params_main_action['taxids'] )
        ret = []
        genomesjar = File.join(BIOPROGS, "genomes", "genomes.jar")
        cmd = "#{JAVA_1_5_EXEC} -Xmx1G -jar #{genomesjar} -pep -nolog -dbs #{job.params_main_action['taxids']} 2>&1"
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
    forward_alignment_tools()
  end
    
end

