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
        @commands << "#{UTILS}/alignhits_html.pl #{@outfile}_prepare #{@outfile} -fas -no_link -e 999999 -Q #{@basename}.fasta" + (@seqlen == "slider" ? sprintf(" -qs %d -qe %d", @seqlen_start, @seqlen_end) : "")
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
      if (@res[i] =~ /^\s*><a name =\s*(\w[\w|\d]+)>/)
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
      #if (@res[i] =~ /^\s*><a name = (\d+)>/)
      if (@res[i] =~ /^\s*><a name =\s*(\w[\w|\d]+)>/)
        if @hits.include?($1)
          if (!@seqlen.nil? && @seqlen == "complete")
            if (@res[i] =~ /(\w\w\|\w[\w|\d]+\|)/)
              #if (@res[i] =~ /([gi\|\d+\||tr\|\w[\w|\d]+\|])/)
              logger.debug "Trembl Hit !"
              #if (@res[i] =~ /(gi\|\d+\|)/)
              File.open(@basename + ".fw_gis", "a") do |file|
                file.write($1 + "\n")
              end
            #            if (@res[i] =~ /(gi\|\d+\|)/)
            #              File.open(@basename + ".fw_gis", "a") do |file|
            #                file.write($1 + "\n")
            #              end
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
      @commands << "#{UTILS}/seq_retrieve.pl -i #{@basename}.fw_gis -o #{@outfile} -b #{BLAST} -unique"
    end

  end

  def forward_params
    res = IO.readlines(File.join(job.job_dir, job.jobid + ".forward"))
    mode = params['fw_mode']
    informat = 'fas'
    inputmode = "alignment"
    if (!mode.nil? && mode == "sequence")
      inputmode = "sequence"
    end

    controller = params['forward_controller']
    if (controller == "patsearch")
      logger.debug "patsearch"
      {'db_input' => res.join, 'std_dbs' => ""}
    elsif (controller == "pcoils")
      logger.debug "pcoils"
      {'sequence_input' => res.join, 'inputmode' => '2'}
    else
      logger.debug "forwarding to: #{params['forward_controller']}"
      {'sequence_input' => res.join, 'inputmode' => inputmode, 'informat' => informat}
    end
  end

end