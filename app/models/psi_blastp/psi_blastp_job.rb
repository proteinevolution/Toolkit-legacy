require 'checked_hits'

class PsiBlastpJob < Job
  include CheckedHits
  
  @@export_ext = ".export"
  # no longer used, take user evalue for next iterations  
  #E_THRESH   = 0.01
  @@MAX_DBS    = 5
  
  attr_reader :header, :hits_better, :hits_prev, :hits_worse, :alignments, :footer, :searching, :num_checkboxes, :evalue_threshold

  def set_export_ext(val)
    @@export_ext = val  
  end
  
  def get_export_ext
    @@export_ext
  end

  # Check if one of the selected databases is a Uniprot database
  def is_uniprot
    uniprot?(@header)
  end
  
  # Parse out the main components of the BLAST output file in preparation for result display
  def before_results(controller_params=nil)
    @hits_better = []
    @hits_prev   = [] # contains all hits after Sequences not found previously or not previously below threshold:
    @hits_worse  = []
    @alignments  = []	
    @header      = []
    @footer      = []
    @searching   = []
    ids         = Hash.new
    @evalue_threshold  = params_main_action['evalfirstit'].to_f
    @no_hits        = false
    i               = 0
    
    resfile         = File.join(job_dir, jobid+".psiblastp")
    raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
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

       # hack: remove erroneous duplicate authors line in output
       # kft 12 Feb 2015: not present any more
       if (line =~ /L\. Aravaind/) then next end
       if (line =~ /Schaffer/) then next end
       
      if (in_get_header)
        if( line =~ /^\s*Searching\.+done\s*$/ )
          next
        end
        if( line =~ /total letters/ )
          @header << strip_dbs(databases)
          @header << line
          found_databases=false
          next
        elsif( line =~ /(<b>)?Database:(<\/b>)?/ || found_databases )
          found_databases=true
          databases += line
          next
        elsif ( line =~ /No hits found/ )
          @no_hits = true
	  in_get_header = false
	  next          
        elsif ( line =~ /Score/ )
          in_get_header = false
          in_get_hits = true
        else
          @header << line
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
          @searching << line << ""
          extract = 1
          next
        elsif( (extract==1) &&  line=~/^\s*$/)
          extract = 2
          next
        elsif(extract==2 && (line =~ /#(\S+)>\s*\S+<\/a>\s+(\S+)\s*$/))
          id = $1
          evalue = $2
          if(evalue =~ /^e/ ? '1'+evalue : evalue).to_f <= evalue_threshold
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
          @searching << line
          next
        end	
      end
  
     if (in_get_hits_prev)
        # extract hitlist of "previous" sequences
        if( (line=~/^\s*<\/PRE>\s*$/) || (line=~/^\s*<PRE>\s*$/) )
	  next
        elsif (line =~ /#(\S+)>\s*\S+<\/a>\s+(\S+)\s*$/)
          id = $1
          evalue = $2
          if  (evalue =~ /^e/ ? '1'+evalue : evalue).to_f <= evalue_threshold
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
        @alignments << section if !section.nil?
	in_get_algn = false
        in_footer = true
      elsif( line=~/^><a name =\s*(\S+?)>/ || line=~/^>.*?<a name=(\S+?)>/ )
        id = $1
        @alignments << section if !section.nil?
        section = { :id => id, :check => false, :content => [line] }
      elsif( line=~/Expect\s*=\s*(\S+)/ )
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
          @footer << line
        end
      end
   end  # ... while
   @num_checkboxes = @alignments.length		
  end

  # reduce path-names of databases or print the counter if it exceeds @@MAX_DBS 
  def strip_dbs(dbs)
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
    if( dbs.length>@@MAX_DBS )
      dbs = ["	... (#{dbs.length} databases selected)"]
    end			
    dbs.insert(0, "<b>Database:</b>")
    dbs.join("\n   ")	
  end
  
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
end 

