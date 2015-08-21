# A module to be used by jobs which display
# a list of checkable hits on their result page

module CheckedHits

  # support the before_results method of the jobs
  # resultFile   name of results file (without path), assumed to be in job_dir
  # eThres       threshold to consider hits as good
  # eValueTag    Naming of E-Value tag in alignment section
  # doDatabaseRecording indicates, whether databases are recorded in header
  # returns header, alignments, footer, searching
  # side effects: sets @hits_better, @hits_worse, @hits_prev, @num_checkboxes
  def show_hits(resultsFile, eThresh, eValueTag, doDatabaseRecording, maxDBs)
      process_blast_output(resultsFile, eThresh, eValueTag, doDatabaseRecording, maxDBs)
  end

private

  def process_blast_output(resultsFile, evalueThreshold, eValueTag, doDatabaseRecording, maxDBs)
    resfile = File.join(job_dir, resultsFile)
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)

    @hits_better = []
    @hits_prev   = [] # contains all hits after Sequences not found previously or not previously below threshold:
    @hits_worse = []
    alignments = []
    header = []
    footer = []
    searching = []
    
    no_hits = false
    ids = Hash.new
    file = File.open(resfile,"r")
    found_databases = false	
    databases = ""
    extract = 0
    section = nil
    in_footer = false
    in_first_line = true
    in_get_header = true
    in_get_header2 = false
    in_get_hits = false
    in_get_hits_prev = false
    in_get_algn = false
    while line = file.gets

       line = line.chomp

       # sanity check
       if (in_first_line)
          in_first_line = false
	  if  (line=~/<PRE>/) then next end
       end

      if (in_get_header)
        if( line =~ /^\s*Searching\.+done\s*$/ )
          next
        end
        if( line =~ /total letters/ )
          if (doDatabaseRecording)
            header << strip_dbs(databases, maxDBs)
          end
          header << line
          found_databases=false
          next
        elsif( line =~ /(<b>)?Database:(<\/b>)?/ || found_databases )
          found_databases=true
          databases += line
          next
        elsif ( line =~ /No hits found/ )
          no_hits = true
	  in_get_header = false
          in_get_algn = true # only for switching to in_footer
	  next          
        elsif ( line =~ /Score/ )
          in_get_header = false
          in_get_hits = true
        else
          header << line
          next
        end
      end

      if (in_get_hits)
       # extract hitlist
        if( line=~/Sequences not found previously or not previously below threshold:/ )
          extract = 0
          in_get_hits = false
          in_get_hits_prev = true
          in_get_algn = true
          next
        elsif( ( (line=~/^\s*<\/PRE>\s*$/) || (line=~/^\s*<PRE>\s*$/) ) )
          next
        elsif( line =~/\s*Sequences producing significant alignments:\s*/ )
          searching << line << ""
          extract = 1
          next
        elsif( (extract==1) &&  line=~/^\s*$/)
          extract = 2
          next
        elsif(extract==2 && (line =~ /#([^>]+)>\s*[\deE\.+-]+<\/a>\s+(\S+)\s*$/))
          id = $1
          evalue = $2
          if(evalue =~ /^e/ ? '1'+evalue : evalue).to_f <= evalueThreshold
            @hits_better << { :id => id, :content => line }
            ids[id]=1
          else
            @hits_worse << { :id => id, :content => line }
          end
          next
        elsif (line =~ /^>/)
          in_get_hits = false
          in_get_algn = true
        else
          searching << line
          next
        end	
      end
  
     if (in_get_hits_prev)
        # extract hitlist of "previous" sequences
        if( (line=~/^\s*<\/PRE>\s*$/) || (line=~/^\s*<PRE>\s*$/) )
	  next
        elsif (line =~ /#([^>]+)>\s*[\deE\.+-]+<\/a>\s+(\S+)\s*$/)
          id = $1
          evalue = $2
          if  (evalue =~ /^e/ ? '1'+evalue : evalue).to_f <= evalueThreshold
            @hits_prev << { :id => id, :content => line }
            ids[id]=1
          else
            @hits_worse << { :id => id, :content => line }
          end
          next
        elsif (line =~ /^>/)
          in_get_hits_prev = false
        end
     end

     if (in_get_algn)
      # extract alignments
      if( (line=~/^\s*<PRE>\s*$/) || (line=~/^\s*<\/PRE>\s*$/) )
        next 
      elsif( (line=~/^\s*Database:/) || (line=~/^Lambda/) )
        alignments << section if !section.nil?
	in_get_algn = false
        in_footer = true
      elsif( line=~/^><a name =\s*([^>\s]+)>/ || line=~/^>.*?<a name=([^>]+)>/ )
        id = $1
        alignments << section if !section.nil?
        section = { :id => id, :check => false, :content => [line] }
      elsif( line=~/#{eValueTag}\s*=\s*(\S+)/ )
        evalue = $1
        if( ids.has_key?(section[:id]) )
          section[:check] = true
        end
        section[:content] << line
      elsif( !section.nil? )
        section[:content] << line
      end
     end

      # save footer lines
      if (in_footer) then
        if ( !((line=~/^\s*<\/PRE>\s*$/) || (line=~/^\s*<PRE>\s*$/)) )
          footer << line
        end
      end
   end  # ... while
   @num_checkboxes = alignments.length
   return header, alignments, footer, searching
  end

  # reduce path-names of databases or print the counter if it exceeds maxDBs
  def strip_dbs(dbs, maxDBs)
    dbs.gsub!(/(<b>)?Database:(<\/b>)?/,"")
    dbs.gsub!(/\s+/, " ")
    ar = dbs.split(/;/)
    dbs = []
    genomes = Hash.new
    ar.each do |db|
      if( db =~ /^\s*(.+)\s*$/ )
        db = $1;
      end			
      if( db=~/not_login/ )
        db.sub!(/^.*not_login.*?_(.*)$/, '\1')
        dbs << db 
      elsif( db =~ %r{/genomes/\S+?/data/.+?/(.+?)/.+} )
        if( !genomes.has_key?($1) ) 
          genomes[$1]=1
          dbs << $1 
        end
      else
        dbs << File.basename(db)
      end
    end
    if( dbs.length>maxDBs )
      dbs = ["	... (#{dbs.length} databases selected)"]
    end			
    dbs.insert(0, "<b>Database:</b>")
    dbs.join("\n   ")	
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

end
