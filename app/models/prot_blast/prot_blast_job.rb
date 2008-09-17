class ProtBlastJob < Job
  HEADER_END_IDENT = 'Searching..................................................done'
  HITLIST_START_IDENT = 'Sequences producing significant alignments:                      (bits) Value'
  HITLIST_END_IDENT = '</PRE>'
  ALIGNMENT_END_IDENT = '</PRE>'
  FOOTER_START_IDENT = '<PRE>'
  E_THRESH = 0.01
  
  attr_reader :header, :hits_better, :hits_worse, :alignments, :footer, :num_checkboxes

  @@export_ext = ".export"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end

  # Parse out the main components of the BLAST output file in preparation for result display
  def before_results(controller_params)
    resfile = File.join(job_dir, jobid+".protblast")
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
    res = IO.readlines(resfile).map {|line| line.chomp}

    no_hits = false
    res.each do |line|
    	if (line =~ /No hits found/i) then no_hits = true end
    end
    
    # extract query and database information
    header_start = res.first =~ /<PRE>/ ? 1 : 0

    # Gibt teilweise einen Fehler da unterschiedliche Anzahl an '.'
#    header_end = res.rindex(HEADER_END_IDENT)-2
    header_end = header_start + 1
    res.reverse_each do |line|
      if (line =~ /^\s*Searching\.+done/)
        header_end = res.rindex(line)-2
        break
      end
    end

    @header = res[header_start..header_end]
    
    # database recording
    i = nil
    @header.each do |line|
    	if (line =~ /Database:/)
    		i = @header.index(line)
    		@header[i] = "<b>Database:</b>"
    		i += 1
    		line.sub!(/(<b>)?Database:(<\/b>)?/, '')
    		if (line !~ /^\s*$/)
	    	  @header.insert(i,line)
	    	end
    		break
    	end
    end
    dbentry = ""
    dbs = []
    genomes = []
    while (i < @header.length)
    	if (@header[i] =~ /total letters/) then break end
    	dbentry += @header[i]
    	@header.delete_at(i)
    	if (dbentry =~ /^(.*);/)
    		entry = $1
    		logger.debug entry
    		if (entry =~ /genomes/ && entry =~ /^(.*)\/.*$/)
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
    		dbentry.sub!(/^.*;/, '')	
    	end
    end
    if (!dbentry.empty?)
    	if( (dbentry=~/genomes/) && (dbentry=~/^(.*)\/.*$/) )
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
    @header.insert(i, dbentry)
    
    @hits_better = []
    @hits_worse = []
    @alignments = []
    
    if (!no_hits)    
    	# extract hitlist
    	hits_start = res.rindex(HITLIST_START_IDENT)+2
    	hits_end = res.size-2 - res[hits_start..-1].reverse.rindex(HITLIST_END_IDENT)
    	hits = res[hits_start..hits_end]
    	
    	hits.each do |hit|
    	  hit =~ /#(\d+)>\s*\S+<\/a>\s+(\S+)\s*$/
    	  id = $1
    	  evalue = $2
    	  if  (evalue =~ /^e/ ? '1'+evalue : evalue).to_f <= E_THRESH
    	    @hits_better << { :id => id, :content => hit }
    	  else
    	    @hits_worse << { :id => id, :content => hit }
    	  end  
    	end
    	
    	@num_checkboxes = hits.size;
    	
    	# extract alignment sections, @alignments is an array that contains arrays (one for each hit in hitlist)
    	aln_start = hits_end+2
    	aln_end = res.rindex(ALIGNMENT_END_IDENT)
    	last_section = res[aln_start..aln_end].inject({ :id => nil, :check => true, :content => [] }) do |section, line|
    	  case line
    	    #><a name = 4539527>
    	    when /><a name =\s*(\d+)>/
    	      @alignments << section if !section[:id].nil?
    	      { :id => $1, :check => true, :content => [line] }
    	    # Score =  185 bits (470), Expect = 2e-46,   Method: Composition-based stats.
    	    when /Expect = (\S+)/
    	      evalue = $1
    	      if  (evalue =~ /^e/ ? '1'+evalue : evalue).to_f > E_THRESH
    	      	section[:check] = false
    	      end
    	      section[:content] << line
    	      section
    	    else
    	      if line !~ /<.*PRE>/ then section[:content] << line end 
    	      section
    	  end
    	end
    	@alignments << last_section
    
    end
    	    
    # extract footer
    @footer = res[res.rindex(FOOTER_START_IDENT)+1..-1]
    return true
  end
  
  def strip_dbentry(entry)
    if (entry =~ /^(.*)\/(.*)$/)
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
  
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
end 





