# A module to be used by actions forwarding blast results

module ForwardHits

  UTILS = File.join(BIOPROGS, 'perl')
  BLAST = File.join(BIOPROGS, 'blast')
  BLASTP = File.join(BIOPROGS, 'blastplus/bin')
  SEQRET = File.join(BIOPROGS, 'seq_retrieve')

  HITLIST_LINE_PATTERN = /<a href\s*=\s*\#[^>]+>\s*[\deE\.+-]+<\/a>/

  # support the run method of forwarding actions
  # Parameters:
  # resultFileType   ending of results file (including dot)
  # handleGenomes    handle genomes
  # use_legacy_blast true if legacy blast commands should be used for forwarding
  # logger, job, params, queue
  # Instance variables created here (please don't rely on them)
  # @basename, @outfile, @commands, @seqlen, @seqlen_start, @seqlen_end, @hits, @res, @hits_start, @hits_end
  def forward_hits(resultsFileType, handleGenomes, use_legacy_blast, logger, job, params, queue)
    logger.debug "L20 ForwardAction!"
    @basename = File.join(job.job_dir, job.jobid)
    @outfile = @basename + ".forward"
    @commands = []
    File.delete(@basename + ".fw_gis") if File.exists?(@basename + ".fw_gis")
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
      logger.debug "L40 result_alignment page!"
      File.open(@outfile, "w") do |file|
        file.write(alignment)
      end
    else
      logger.debug "L45 result page!"
      infile = @basename + resultsFileType
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
        logger.debug "L66 byevalue!"
        if (hitsevalue =~ /^e.*$/)
          hitsevalue = "1" + hitsevalue
        end
        @hits = []
        hit_lines.each do |hit_line|
          hit_line.scan(/<a href\s*=\s*\#([^>]+)>\s*[\deE\.+-]+<\/a>\s+(\S+.*)$/) do |name, eval|
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
        make_blast_output(job)
      else
        make_seqs_output(job, handleGenomes, use_legacy_blast, resultsFileType)
      end

      if (!mode.nil? && mode == "alignment")
        FileUtils.mv(@outfile, @outfile + "_prepare")
        @commands << "#{UTILS}/alignhits_html.pl #{@outfile}_prepare #{@outfile} -fas -no_link -e 999999 -Q #{@basename}.fasta" + (@seqlen == "slider" ? sprintf(" -qs %d -qe %d", @seqlen_start, @seqlen_end) : "")
      end
    end

    if (@commands.empty?)
      logger.debug "L99 commands empty!"
      self.status = STATUS_DONE
      self.save!
      # reload
      job.update_status
    else
      logger.debug "L105 Commands:\n" + @commands.join("\n")
      queue.submit(@commands, true, {'queue' => QUEUES[:immediate]})
    end

  end

  private

  def make_blast_output(job)
    job.before_results nil

    res = job.header
    res << job.searching if job.searching
    job.hits_better.each do |h|
      if ( hits.include?(h[:id]) )
        res << h[:content]
      end
    end
    if ( job.hits_prev && job.hits_prev.length > 0 )
      res << "Sequences not found previously or not previously below threshold:\n"

      job.hits_prev.each do |h|
        if ( hits.include?(h[:id]) )
          res << h[:content]
        end
      end
    end
    job.hits_worse.each do |h|
      if ( hits.include?(h[:id]) )
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
  
  def make_seqs_output(job, handleGenomes, use_legacy_blast, resultsFileType)
    i = @hits_end + 1
    # loop over alignments section
    while (i < @res.size)
      line = @res[i]
      if ((line=~/^\s*Database:/) || (line=~/^Lambda/)) then break end
      #><a name = 82736116><
      if (line =~ /^><a name =\s*([^>\s]+)>/ || line=~/^>.*<a name=([^>]+)>/)
        if @hits.include?($1)
          # @hits.delete($1) # this was in cs_blast_forward_action.rb only
          if (!@seqlen.nil? && @seqlen == "complete")
            logger.debug "L168 "+$1
            if (line =~ /(\w\w\|\w+\|)/)
              logger.debug "L170 Trembl Hit "+$1
              ret = $1
              File.open(@basename + ".fw_gis", "a") do |file|
                file.write(ret + "\n")
              end
            end
          else
            name = line.sub(/<a name\s*=\s*[^>]+><\/a>/, '')
            name.sub!(/<a.*href=[^>]*>/, '')
            name.sub!(/<\/a>/, '')
            name.sub!(/Length\s*=\s*\d+\s*$/, '')
            name.strip!

            seq_data = ""
	    first_res = nil;
	    last_res = nil;
            i = i + 1
	    while (i < @res.size)
              line = @res[i]
              if (line =~ /^>/)
                i = i - 1
                break
              end
              if ((line=~/^\s*Database:/) || (line=~/^Lambda/)) then break end
	      if (line =~ /^(\w+):?\s*(\d+)\s+(\S+)\s+(\d+)\s*$/) 
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
      db_path = job.params_main_action['std_dbs'].nil? ? "" : job.params_main_action['std_dbs'].join(' ')
      db_path = job.params_main_action['user_dbs'].nil? ? db_path : db_path + ' ' + job.params_main_action['user_dbs'].join(' ')
      # get Genomes Databases
      if( handleGenomes && job.params_main_action['taxids'] )
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
        db_path += ' ' + ret.join(' ')
      end

      logger.debug "L248 Database path: #{db_path}\n"

      db_path.strip!
      if db_path.empty?
        db_option = ""
      else
        db_option = " -d '#{db_path}'"
      end

      if (use_legacy_blast)
        @commands << "#{SEQRET}/seq_retrieve.pl -i #{@basename}.fw_gis -o #{@outfile} -b #{BLAST} -unique#{db_option}"
      else
        
         # Rewrite the forwarding file    
        File.delete(@basename + ".fw_gis") if File.exists?(@basename + ".fw_gis")
        
        #  Write hits to file
        File.open(@basename + ".fw_gis", "w+") do |f|
              f.puts(remove_redundancy(hits))
        end
        @commands << "#{SEQRET}/seq_retrieve.pl -use_blastplus -i #{@basename}.fw_gis -o #{@outfile} -b #{BLASTP} -unique#{db_option}"
      end
    end
  
  end

    # Removes an accession acc from the array if an equivalent accession acc.v with version annotation v is also in the array
   def remove_redundancy(accs)

        res = []
        accs.each do |x|

            res << x unless(accs.grep(/#{x}\.[0-9]/).any?)
        end
        return res
   end

end
