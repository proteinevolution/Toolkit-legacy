# A module to be used by jobs which display
# a list of checkable hits on their result page

module CheckedHits

  HEADER_END_IDENT = 'Searching..................................................done'
  HITLIST_START_IDENT = 'Sequences producing significant alignments:                      (bits) Value'
  HITLIST_END_IDENT = '</PRE>'
  ALIGNMENT_END_IDENT = '</PRE>'
  FOOTER_START_IDENT = '<PRE>'

  # support the before_results method of the jobs
  # resultFile   name of results file (without path), assumed to be in job_dir
  # eThres       threshold to consider hits as good
  # eValueTag    Naming of E-Value tag in alignment section
  # doDatabaseRecording indicates, whether databases are recorded in header
  # returns header, alignments (2 arrays)
  def show_hits(resultsFile, eThresh, eValueTag, doDatabaseRecording)
    resfile = File.join(job_dir, resultsFile)
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
    res = IO.readlines(resfile).map { |line| line.chomp }

    no_hits = false
    res.each do |line|
      if (line =~ /No hits found/i) then no_hits = true end
    end

    # extract query and database information
    header_start = res.first =~ /<PRE>/ ? 1 : 0

    # Sometimes produces an error depending on different counts of '.'
#    header_end = res.index(HEADER_END_IDENT)-2
    header_end = header_start + 1
    res.reverse_each do |line|
      if (line =~ /^\s*Searching\.+done/)
        header_end = res.index(line) - 2
        break
      end
    end
    header = res[header_start..header_end]
    if doDatabaseRecording
      header = databaseRecording(header)
    end

    @hits_better = []
    @hits_worse = []
    alignments = []

    if (!no_hits)
      alignments = extractHitlist(res, eThresh, eValueTag, alignments)
    end

    footer = extractFooter(res)
    return header, alignments, footer
  end

  def databaseRecording(header)
    i = nil
    header.each do |line|
      if (line =~ /Database:/)
        i = header.index(line)
        header[i] = "<b>Database:</b>"
        i += 1
        line.sub!(/(<b>)?Database:(<\/b>)?/, '')
        if (line !~ /^\s*$/)
          header.insert(i, line)
        end
        break
      end
    end
    dbentry = ""
    dbs = []
    genomes = []
    while(i < header.length)
      if (header[i] =~ /total letters/) then break end
      dbentry += header[i]
      header.delete_at(i)
      if (dbentry =~ /^(.*);/)
        entry = $1
        # logger.debug entry
        if (entry =~ /genomes/ && entry =~ %r{^(.*)/.*$})
          path = $1.strip
          if genomes.include?(path)
            dbentry.sub!(/^.*;/, '')
            next
          else
            genomes << path
            entry = path
          end
        end
        dbs << strip_dbentry(entry)
        dbentry.sub(/^.*;/, '')
      end
    end
    if (!dbentry.empty?)
      if ((dbentry =~ /genomes/) && (dbentry =~ %r{^(.*)/.*$}))
        dbentry = $1.strip
      end
      dbentry = strip_dbentry(dbentry)
      dbs << dbentry
      dbentry = ""
    end
    if (dbs.length > 5)
      dbentry = "... (#{dbs.length} databases selected)"
    else
      dbentry = dbs.join("\n")
    end
    header.insert(i, dbentry)
  end

  def extractHitlist(res, eThresh, eValueTag, alignments)
    hits_start = res.index(HITLIST_START_IDENT) + 2
    hits_end = res.size - 2 - res[hits_start..-1].reverse.rindex(HITLIST_END_IDENT)
    hits = res[hits_start..hits_end]

    hits.each do |hit|
      # Sufficient for hhomp: hit =~ /#(\d+)>\s*\S+<\/a>\s+(\S+)\s*$/
      hit =~ /#(\w[\w|\d]+)>\s*\S+<\/a>\s+(\S+)\s*$/
      id = $1
      evalue = $2
      # logger.debug "Hit : #{id} Value #{evalue} Hit  #{hit} "
      if (evalue =~ /^e/ ? '1'+evalue : evalue).to_f <= eThresh
        @hits_better << { :id => id, :content => hit }
      else
        @hits_worse << { :id => id, :content => hit }
      end
    end

    @num_checkboxes = hits.size;

    # extract alignemnt sections, alignments is an array that contains arrays (one for each hit in hitlist)
    aln_start = hits_end + 2
    aln_end = res.rindex(ALIGNMENT_END_IDENT)
    # This is a kind of repeat until loop
    last_section = res[aln_start..aln_end].inject({ :id => nil, :check => false, :content => [] }) do |section, line|
      case line
      #><a name = 4539527>
      when /><a name =\s*(\w[\w|\d]+)>/ # sufficient for hhomp: when /><a name =\s*(\d+)>/
        # New section encountered. Append previous section to alignments (ignore initial section dummy).
        alignments << section if !section[:id].nil?
        { :id => $1, :check => false, :content => [line] } # Start new section
      # Score =  185 bits (470), Expect = 2e-46,   Method: Composition-based stats.
      when /#{eValueTag}\s*=\s*(\S+)/
        evalue = $1
        if  (evalue =~ /^e/ ? '1'+evalue : evalue).to_f <= eThresh
          section[:check] = true
        end
        section[:content] << line
        section
      else
        if line !~ /<.*PRE>/ then
          section[:content] << line
        end
        section
      end
    end
    alignments << last_section
  end

  def extractFooter(res)
    res[res.rindex(FOOTER_START_IDENT) + 1..-1]
  end

  # Check if one of the selected databases is a Uniprot database
  def uniprot?(header)
    uniprot = 0;
    if (header.to_s =~ /SwissProt/)
      uniprot = 1   
    end
    if (header.to_s =~ /TREMBL/)
      uniprot = 1   
    end
    return uniprot
  end

  private

  def strip_dbentry(entry)
    if (entry =~ %r{^(.*)/(.*)$})
      name = $2
      if ($1.include?('not_login'))
        name.sub!(/^.*not_login.*?_(.*)$/, '\1')
        entry = "  #{name}"
      else
        entry = "  #{name}"
      end
    end
    return entry
  end

end
