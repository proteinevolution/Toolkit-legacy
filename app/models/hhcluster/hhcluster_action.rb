require 'open3'

class HhclusterAction < Action

  BLAST32 = File.join(BIOPROGS, "blast32")

  attr_accessor :blast_input, :text_search

  def before_perform

    @basename = File.join(job.job_dir, job.jobid)

    @outfile = @basename + ".out"

    @commands = []

    @text_search = params['text_search'] ? params['text_search'] : ""
    @blast_input = params["blast_input"] ? params['blast_input'] : ""
    @crossbars = params["crossbars"] ? "-c" : ""

    @scop_names = {}

    if (!@text_search.empty?)
      @blast_input = ""
    end

    @results = []
    @marked = []
    @gis = []
    @evalue = []

  end


  def perform

    logger.debug "Search name: #{@text_search}"

    # Text search in names of scop25 file
    indexfile = HHCLUSTER_DB_PATH + "/" + HHCLUSTER_DB
    lines = IO.readlines(indexfile)
    lines.each do |line|
      if (line =~ /^>(.*)$/)
        name = $1
        id = name[0,7]
        @scop_names[id] = name
        if (!@text_search.empty? && name =~ /#{@text_search}/i)
          @results << name
          @marked << true
          @gis << id
          @evalue << "-"
        end
      end
                end

    # Was search string @text_search given but no match found in scop25?
    if (!@text_search.empty? && @gis.empty?)
      index100file = HHCLUSTER_DB_PATH + "/" + HHCLUSTER_DB.sub(/scop\d+/, 'scop100')
      logger.debug "Search SCOP 100 (#{index100file}) with #{@text_search}"
      lines = IO.readlines(index100file)
      name = ""
      seq = ""
      lines.each do |line|
        if (line =~ /^>/ || line =~ /^\s*$/)
          if (!name.empty? && name =~ /#{@text_search}/i)
            break
          end
          name = line[1..-1]
          seq = ""
        else
          seq += line
        end
      end
      if (!name.empty? && name =~ /#{@text_search}/i)
        @blast_input = seq
      end
    end

    # Do BLAST search with @blast_input sequence?
    if (!@blast_input.empty?)
      stdin, stdout, stderr = Open3.popen3("#{BLAST32}/blastpgp -b 1 -d #{indexfile}")
      stdin.puts @blast_input
      stdin.close
      lines = stdout.readlines
      stdout.close
      stderr.close

      mark = true
      i = 0
      while (i < lines.size)
        if (lines[i] =~ /Sequences producing/) then break end
        i += 1
                        end
      if (i != lines.size)
        i += 2
        while (i < lines.size)
          if (lines[i] =~ /^(\S+).*?\s+(\S+)\s*$/)
            @results << @scop_names[$1]
            @marked << mark
            @gis << $1
            @evalue << $2
            mark = false
          else
            break
          end
          i += 1
        end
      end
    end

    File.open(@outfile, "w") do |file|
      for i in 0...@results.size
        file.write ">#{@results[i]}\n"
        file.write "#{@marked[i]} #{@gis[i]} #{@evalue[i]}\n"
      end
    end

    self.forward_action = "update"
    self.status = STATUS_DONE
    self.save!
    job.update_status

  end

end




