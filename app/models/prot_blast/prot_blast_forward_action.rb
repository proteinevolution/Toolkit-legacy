class ProtBlastForwardAction < Action
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
      infile = @basename + ".protblast"
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
	   hit_line.scan(/<a href = \#(\d+)>\s*\d+<\/a>\s+(\S+.*)$/) do |name, eval|
            if (eval =~ /^e.*$/)
              eval = "1" + eval
            end

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
      job.update_status
    else
      logger.debug "Commands:\n"+@commands.join("\n")
      queue.submit(@commands)
    end

  end

  def make_blast_output
    i = @hits_start
    while (i < @res.size)
      if (@res[i] =~ /<\/PRE>/i) then break end
      if (@res[i] =~ /#(\d+)>\s*\S+<\/a>\s+\S+\s*$/)
        if @hits.include?($1)
          i += 1
        else
          @res.delete_at(i)
        end
      else
        i += 1
      end
    end

    check = true
    while (i < @res.size)
      if (@res[i] =~ /^\s*Database:/) then break end
      #><a name = 82736116><
      if (@res[i] =~ /^\s*><a name = (\d+)>/)
        if @hits.include?($1)
          check = true
          i += 1
        else
          check = false
          @res.delete_at(i)
        end
      else
        if check
          i += 1
        else
          @res.delete_at(i)
        end
      end
    end

    File.open(@outfile, "w") do |file|
      file.write(@res.join("\n"))
    end
  end

  def make_seqs_output
    i = @hits_end
    while (i < @res.size)
      if (@res[i] =~ /^\s*Database:/) then break end
      #><a name = 82736116><
      if (@res[i] =~ /^\s*><a name = (\d+)>/)
        if @hits.include?($1)
          if (!@seqlen.nil? && @seqlen == "complete")
            if (@res[i] =~ /(gi\|\d+\|)/)
              File.open(@basename + ".fw_gis", "a") do |file|
                file.write($1 + "\n")
              end
            else
              if (@res[i] =~ /<\/a>(\S+)\s/)
                File.open(@basename + ".fw_gis", "a") do |file|
                  file.write($1 + "\n")
                end
              else
                logger.error "Missing template name!"
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
      @commands << "#{UTILS}/seq_retrieve.pl -i #{@basename}.fw_gis -o #{@outfile} -b #{BLAST} -unique"
    end


  end

  def forward_params
    res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
    mode = params['fw_mode']
    inputmode = "sequence"
    if (!mode.nil? && mode == "alignment")
      inputmode = "alignment"
    end
    {'sequence_input' => res.join, 'inputmode' => inputmode}
  end

end

