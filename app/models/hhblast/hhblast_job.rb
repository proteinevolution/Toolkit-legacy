class HhblastJob < Job
  
  @@export_ext = ".hhr"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
  attr_reader :results 
 
  def before_results(controller_params = nil )
    self.viewed_on = Time.now
    self.save!
    @results = []
    options = ""
    program = "results"
    coloring = "onlySS"
    makemodel = false
	  
    coloring = controller_params[:mode] ? controller_params[:mode] : 'letters'
    program = controller_params[:action]
    
    basename= File.join(job_dir, jobid)
    m = 0 #checkbox index
    maxlinelen=105
    space_for_checkbox="  "
    # Read hhr file
	  
    resfile = basename + ".hhr"
    raise("ERROR file not readable!#{resfile}") if !File.readable?(resfile)
    raise("ERROR file does not exist!#{resfile}") if !File.exists?(resfile)
    raise("ERROR file is zero!#{resfile}") if  File.zero?(resfile)
    results = File.open(resfile, "r")
    line = results.readlines  
	  
    # Read parameters from hhsearch call and format query line and parameter line
    i =0
    query = ""
    len = "?"
    nseqs = "?"
    neff = "?"
    command = ""
    queryline = ""
    paramline = ""
    pdb_searched = false
    
    line.each do  |a| 
      if a =~/^Query \s+ (\S+)/   
        query = $1 
      elsif a =~/^Match.columns\s+(\d+)/ 
        len = $1
      elsif a=~ /^No.of.seqs\s+(\d+)/  
        nseqs = $1
      elsif a=~ /^Neff\s+(\S+)/ 
        neff = $1
      elsif a=~ /^Command.*/  
        command = a
      elsif a=~/^\s*$/ 
        break
      end 
    end #end each# If list of PDB codes is given, link them to NCBIs MMDB
	  
    if  File.exists?(job_dir+"/sequence_file" )	
      # Read sequence file
      seqfile = File.join(job_dir, "sequence_file")
      raise("ERROR with sequencefile!") if !File.readable?(seqfile) || !File.exists?(seqfile) || File.zero?(seqfile)
      seq = File.open(seqfile, "r")
      
      queryseqs = seq.readlines[1]
      queryseq = queryseqs
      queryseq.gsub!(/\W|\d|\s|_/,"")
		
      queryseq=~/^(\S{10}).*(\S{10})$/ 
      queryseq = "#{$1}...#{$2}" 
	 
      # Format query name line
      queryline = "<b>Query </b>#{query} (seq=#{queryseq} Len=#{len} Neff=#{neff} Nseqs=#{nseqs})"
    else
      queryline = "<b>Query </b>#{query} (Len=#{len} Neff=#{neff} Nseqs=#{nseqs})";
    end #end if
	 
    # Format parameter line
    paramline = "<b>Parameters </b> "
    command =~ /\s-ssm\s(\d+)\s/
	
    if $1 == '0'
      paramline+="score SS:no "
    elsif $1 == '2'
      paramline+="score SS:yes "
    elsif $1 == '4' 
      paramline +="score SS:pred-pred "
    else
      paramline += "score SS:? "
    end  # end  if
	
    if command =~ /\s-local/
      paramline+="search:local "
    elsif command =~/\s-global/
      paramline+="search:global "
    else 
      paramline +="search:? "
    end
	
    if command =~ /\s-realign/ || command=~/\s-mact/
      paramline+="realign with MAP:yes "
      if command =~/\s-mact (\S+)/
        paramline+= "MAP threshold=#{$1} "
      end
    elsif  command =~ /(-norealign)/
      paramline +="realign with MAP:no "
    else 
      paramline += "realign with MAP:? #{$1}"
    end # end  if

    if command =~ /^pdb\.hhm/
      pdb_searched = true;
    end
    
    # Introduce line breaks when necessary
    
    queryline = break_lines(queryline,maxlinelen+7, "       ")
    paramline = break_lines(paramline,maxlinelen+7, "       ")
    
    ###############################################################
    # Reformat HHblast output

    @results.push("<div id=\"hitlist_img\">\n")

    # Make array with description of matches, to be used as  html mouse-over titles
    
    descr    = []
    line.each_index do |a| 
      if line.fetch(a) =~/^No(\d+)/
        m = $1
        if line.fetch(a+1) =~ /^>\S+\s+(.*)/
          descr[m] = $1
          descr[m].gsub!(/\"\"\\<>/, '')
        end
      end
    end  #end each
    
    #Go to first empty line
    while  line[i]!~/^\s*$/
      i+=1
    end
    
    # Go to next non-empty line
    while line[i]=~/^\s*$/
      i+=1
    end
    ifirst = i
    
    #Title line from summary hit list? 
    cutres = 0
    if line[i] =~ /^\s*No\s+(\S+)\s+(\S+)\s+/
      line[i].sub!(/(.*)/,space_for_checkbox+'\1')
      line[i] =~/^(.*)Prob/
      cutres= $1.length-3
    end
    
    line[i+1] =~ /.{#{cutres}}(.{5})/
      prob = $1.to_i
    
    # Print some comments and tips
    if  prob >40 && prob  < 90 && rand() >0.8
      @results.push("<br><font color='blue'>\n<b>Need help to find out how to validate your hits? Click <a href=\"\#\" title=\"HHpred FAQs\" onclick=\"openHelpWindow('hhpred_help_faq','correct match');\">here.</a></b>\n</font>")
    elsif rand() > 0.8
      @results.push("<br><font color='darkgreen'> <b>Note: Corrupted alignments are the most common source of high-scoring false positives. Check the query alignment by clicking </font><font color='black'>Show Query Alignment</font><font color='darkgreen'> above. To check the template alignments use the <img src=\"#{DOC_ROOTURL}/images/hhpred/logo_template_ali.png\" height=\"15\" align=\"middle\" /> logos.</b></font>")
    elsif rand() > 0.6
      @results.push("<br><font color='green'> <b>To create a structural model for your query, submit your results to HHpred and search the PDB database.</a></b></font>")
    end

    ##############################################################################
    # if requested, print hhviz output and the domain slider

    if  File.exists?("#{basename}.html") && !(program.eql?("align")) && !(program.eql?( "createmodel"))
      @results.push("\n<style type=\"text/css\">\n")
      @results.push("div.slider {position: absolute; height:40px;}\n")
      @results.push("div.slider div.label {position:absolute; top: 0px; height:12px; width:30px; cursor:default;}\n")
      @results.push("div.slider div.bar {position:absolute; top:14px; height:16px;}\n")
      @results.push("div.slider div.bar div.handle {position:absolute; width:16px; height:16px; cursor:move;}\n")
      @results.push("div.slider div.bar div.span {position:absolute; top:6px; height:6px; background-color:#000000;}\n")
      @results.push("</style>\n")

      #The slider is placed above the image generated by hhviz (see bioprogs/hhpred/hhviz.pl).
      match_states = len.to_i
      xscale = 780 / match_states	#In the *.png file generated by hhviz, the distance of the bar to the left margin depends on the number of match states
      slider_width = 812 - xscale
      @results.push("<div class=\"row\" style=\"position:relative; height:10px\">\n")
      @results.push("<div id=\"slider\" class=\"slider\" style=\"top:5px; left: #{xscale - 7}px; width: #{slider_width}px;\">\n")
      @results.push("<div id=\"slider_label_left\" class=\"label\" style=\"text-align:right;\"></div>\n")
      @results.push("<div id=\"slider_label_right\" class=\"label\" style=\"text-align:left;\"></div>\n")
      @results.push("<div id=\"slider_bar\" class=\"bar\" style=\"width: #{slider_width}px;\">\n")
      @results.push("<div id=\"slider_bar_handle_left\" class=\"handle\"><img src=\"/images/arrow_right.png\" alt=\"\"/></div>\n")
      @results.push("<div id=\"slider_bar_handle_right\" class=\"handle\"><img src=\"/images/arrow_left.png\" alt=\"\"/></div>\n")
      @results.push("<div id=\"slider_bar_span\" class=\"span\"</div>\n")
      @results.push("</div>\n")
      @results.push("</div>\n")
      @results.push("<div class=\"row\" style=\"position:absolute; top:50px; width:785px;\">\n")
      @results.push("<form action=\"/hhblast/resubmit_domain/#{jobid}\" method=\"post\">\n")
      @results.push("<input type=\"hidden\" id=\"domain_start\" name=\"domain_start\"/>\n")
      @results.push("<input type=\"hidden\" id=\"domain_end\" name=\"domain_end\"/>\n")
      @results.push("<input type=\"submit\" class=\"feedbutton\" style=\"border-width:2px;\" value=\"Resubmit\"/>\n")
      @results.push("</form>\n")
      @results.push("</div>\n")
      @results.push("</div>\n")
      #Get start and end position of the best hit
      domain_start = 1
      domain_end = match_states
      line.each do |l|
	if l =~ /^\s*1\s.+\s(\d+)-(\d+)\s+\d+-\d+/
	  domain_start = $1
	  domain_end = $2
	  break
	end
      end
      @results.push("<script type=\"text/javascript\">domain_slider_show(#{match_states},#{domain_start},#{domain_end});</script>\n")
    
      raise("Cannot open #{basename}.html!")  if !File.readable?("#{basename}.html")|| !File.exists?("#{basename}.html") || File.zero?("#{basename}.html")
      hhfile =  File.open("#{basename}.html", "r")
      hhviz = hhfile.readlines
      hhviz.each {|a| @results.push( a)}
    end
    @results.push("</div>\n")

    #################################################################################
 
   # profile_logos
    
    if program.eql?("histograms") && !File.exists?("#{basename}_1.png")
      system("tar -xzf #{basename}.tar.gz -C #{job_dir} &> /dev/null")
      logger.debug("tar -xzf #{basename}.tar.gz -C #{job_dir} &> /dev/null")
    end
    
    @results.push("<pre>#{queryline} \n#{paramline} \n\n")
	
    ########################################################################################################
    ############################### Summary hit list  ######################################################
    #
    # No Hit                             Prob E-value P-value  Score    SS Cols Query HMM  Template HMM
    #  1 pfam03756 AfsA A-factor biosyn  99.9 9.3E-28 4.9E-32  173.4   4.9   80   19-102     1-80  (80)
    
    checkbox_counter = 0
    b=ifirst  
    
    while b<line.length
      if line[b] =~/^Done!/
        break
      elsif line[b]=~/^\s*$/
        break
      end
      
      if line[b] =~ /^\s*(\d+)\s+(\S+)\s+(\S+)\s+/
        m = $1.to_i
        template = $2
        family = $3
        line[b].sub!(/#{m}/,"<a href =\##{m}>#{m}<\/a>")
        
        line[b] = "<input style=\"margin: 0px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox#{checkbox_counter}\" id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 0)\"/>#{line[b]}"
        checkbox_counter += 1
      end
      b+=1
      
    end
    

    ########################################################################################################
    ###########################  Alignments  ############################################################### 
    logo_attr ="border=\"0\" align=\"middle\""
    link_attr = "style=\"margin: 5px 10px 10px 10px;\""
    href =""
    #b= 0
    
    while b<line.length
      if   line[b] =~  /^Done!/
        break
        
      ########################################################################################################
      # 'No X' line before each query-target alignment
        
      elsif  line[b]=~/^No\s*(\d+)/ 
        
        m = $1
        line[b].sub!(/(No\s*#{m})/) {|match| match = "<a name = #{m}>#{$1}<\/a>"}
        line[b] = space_for_checkbox+line[b];
        
        # profile logos
        if  program.eql?("histograms")
          line[b].chomp!
          line[b]+= "<a href=\"#{DOC_ROOTURL}/hhblast/results/#{jobid}##{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_alignments.jpg\" alt=\"Alignments\" title=\"show query-template alignments\" #{logo_attr} height=\"30\"></a>\n"
          
          mapname="#{jobid}_#{m}"
          mapfile="#{job_dir}/#{mapname}.map"
          imgfile="#{jobid}_#{m}.png"
          j=b+1;
          
          # Advance to first line of alignment
          while j<line.length && line[j]!~/^\s*$/
            j+=1
          end
          
          # Insert Image
          if File.exists?(mapfile)
            raise("ERROR with mapfile!") if !File.readable?(mapfile)|| !File.exists?(mapfile) || File.zero?(mapfile)
            map = (File.open(mapfile, "r")).readlines
            insert_array(line,j,map)
            j += map.length
          else
            line.delete_at(j)
          end
          
          # Delete all lines of alignment up to beginning of next alignment
          j+=1
          while j<line.length && line[j]!~/^No\s*\d+/ 
            line.delete_at(j)
          end
        else
          line[b].chomp!
          line[b] += "<a href=\"#{DOC_ROOTURL}/hhblast/histograms/#{jobid}##{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_histogram_single.png\" alt=\"Histograms\" title=\"Show histograms\" #{logo_attr} height=\"30\"></a>\n";
        end
        
        # Add logo for template alignment
        line[b].chomp!
        line[b]+="<a href=\"#{DOC_ROOTURL}/hhblast/run/#{jobid}?jobaction=hhblast_showtemplalign&forward_controller=hhblast&forward_action=results_showtemplalign&alformat=fasta&hits=#{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_template_ali.png\" title=\"Show template alignment\" #{logo_attr} /></a>\n"
        
        ########################################################################################################
        # '>name and description' line before each query-target alignment
        
      elsif   line[b] =~  /^>(\S+)\s+(\S+)\s*([^.;,\[\(\{]*)/
        
        template = $1
        shortname = $2
        family = $2
        longname = $3
        if shortname =~ /^unknown|^DUF\d|^uncharacterized/
          shortname=""
        end
        if longname =~ /^unknown|^DUF\d|^uncharacterized/
          longname=""
        end
        
        shortname.sub!(/\s+The following Pfam-B.*/, "")
        longname.sub!(/\s+The following Pfam-B.*/, "")
        if longname.split(/\s+/).length <= 1
          longname+= "[TI]"
        end
        
        line[b] = break_lines(line[b],maxlinelen,space_for_checkbox) 

        line[b] = "<input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox#{checkbox_counter}\" id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 1)\"/>#{line[b]}"
        checkbox_counter+=1
		
      elsif line[b] =~ /^>\S+/
        
        line[b] = "<input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox#{checkbox_counter}\" id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 1)\"/>#{line[b]}"
        
        checkbox_counter+=1
        
        
        
        ########################################################################################################
        # All other lines
        
      else 
        if  line[b]!~/^\s*$/
          line[b] = space_for_checkbox + line[b]
        end
      end
      
      ########################################################################################################
      # Color alignments 
      
      # Found a ss_dssp or ss_pred line?
      if  line[b] =~ /\s*(Q|T) ss_(dssp|pred)\s+(\S+)/
        seq     = $3
        old_seq = $3
        if  coloring.eql?( "onlySS")
          seq.gsub!(/([eE]+)/) {|match| match = "<span style=\"color: #0000D0;\">#{$1}<\/span>"}
          seq.gsub!(/([hH]+)/) {|match| match = "<span style=\"color: #D00000;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,"#{seq}")
          
        elsif  coloring.eql?( "letters")
          seq.gsub!(/([eE]+)/) {|match| match = "<span style=\"color: #0000D0;\">#{$1}<\/span>"}
          seq.gsub!(/([hH]+)/) {|match| match = "<span style=\"color: #D00000;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,"#{seq}")
          
        elsif  coloring.eql?( "background")
          seq.gsub!(/([eE]+)/) {|match| match = "<span style=\"background-color: #b0b0ff;\">#{$1}<\/span>"}
          seq.gsub!(/([hH]+)/) {|match| match = "<span style=\"background-color: #ffb0b0;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,"#{seq}")
        end
        
        
        # Found a consensus line?
      elsif  line[b] =~ /\s*(Q|T) Cons(-\S+|ensus)\s+\d+\s+(\S+)/ 
        seq     = $3
        old_seq = $3
        if coloring.eql?( "onlySS")
          seq.gsub!(/([A-Za-z]+)/) {|match|  match =$1}
          line[b].sub!(/#{old_seq}/) {|match|  match =seq}
          
        elsif coloring.eql?( "letters")
          seq.gsub!(/([A-Za-z]+)/) {|match|  match =$1}
          seq.gsub!(/([~\.-]+)/) {|match|  match ="<span style=\"color: #808080;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,seq)
          
        elsif coloring.eql?("background")
          seq.gsub!(/([A-Za-z]+)/) {|match|  match =$1}
          seq.gsub!(/([~\.-]+)/) {|match|  match ="<span style=\"color: #808080;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,seq)
        end
        
        
        # Found a sequence line?
      elsif line[b] =~ /\s*(Q|T) (\S+)\s+\d+\s+(\S+)/ 
        seq     = $3
        old_seq = $3
        if coloring.eql?( "letters")
          seq.gsub!(/([a-z\.-]+)/) {|match| match = "<span style=\"color: #808080;\">#{$1}<\/span>"}
          seq.gsub!(/([WYF]+)/){|match| match ="<span style=\"color: #00a000;\">#{$1}<\/span>"}
          seq.gsub!(/([LIVM]+)/){|match| match ="<span style=\"color: #00ff00;\">#{$1}<\/span>"}
          seq .gsub!(/([AST]+)/){|match| match ="<span style=\"color: #404040;\">#{$1}<\/span>"}
          seq.gsub!(/([KR]+)/){|match| match ="<span style=\"color: red;\">#{$1}<\/span>"}
          seq.gsub!(/([DE]+)/){|match| match ="<span style=\"color: blue;\">#{$1}<\/span>"}
          seq.gsub!(/([QN]+)/){|match| match ="<span style=\"color: #d000a0;\">#{$1}<\/span>"}
          seq.gsub!(/(H+)/){|match| match ="<span style=\"color: #E06000;\">#{$1}<\/span>"}
          seq.gsub!(/(C+)/){|match| match ="<span style=\"color: #A08000;\">#{$1}<\/span>"}
          seq.gsub!(/(P+)/){|match| match ="<span style=\"color: #000000;\">#{$1}<\/span>"}
          seq.gsub!(/(G+)/){|match| match ="<span style=\"color: #404040;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,seq)
          
        elsif	coloring.eql?( "background")
          seq.gsub!(/([WYF]+)/) {|match|  match ="<span style=\"background-color: #00c000;\">#{$1}<\/span>"}
          seq.gsub!(/(C+)/) {|match|  match ="<span style=\"background-color: #ffff00;\">#{$1}<\/span>"}
          seq.gsub!(/([DE]+)/) {|match|  match ="<span style=\"background-color: #6080ff;\">#{$1}<\/span>"}
          seq.gsub!(/([LIVM]+)/) {|match|  match ="<span style=\"background-color: #02ff02;\">#{$1}<\/span>"}
          seq.gsub!(/([KR]+)/) {|match|  match ="<span style=\"background-color: #ff0000;\">#{$1}<\/span>"}			
          seq.gsub!(/([QN]+)/) {|match|  match ="<span style=\"background-color: #e080ff;\">#{$1}<\/span>"}				
          seq.gsub!(/(H+)/) {|match|  match ="<span style=\"background-color: #ff8000;\">#{$1}<\/span>"}
          seq.gsub!(/(P+)/) {|match|  match ="<span style=\"background-color: #a0a0a0;\">#{$1}<\/span>"}				
          line[b].sub!(/#{old_seq}/,seq)
        end
                
        # Found a ss_conf line?
      elsif  line[b] =~ /\s*(Q|T) ss_/ 
      end
      
      b +=1
      
    end #end while

    b = ifirst
    while b< line.length
      @results.push(line[b])
      b +=1
    end #end while
		
	
    @results.push("<br></pre>\n")
    @results.push("Please cite as appropriate: \n")
    @results.push("<BR><BR><B><i>HHblast</i>: Remmert, M. [unpublished]</B>")
    @results.push("<BR><BR><i>PSIPRED</i>: Jones, D.T. (1999) Protein secondary structure prediction based on position-specific scoring matrices. JMB 292: 195-202.")
    @results.push("<input type=\"hidden\" id=\"checkboxes\" name=\"checkboxes\" value=\"#{m}\" \>\n")
	
  end #end method

  
  def break_lines(*params)
    lref = params[0]
    maxlinelen = params[1]
    space = params[2]
    chrs = lref.unpack('C*') 
    lastchr = maxlinelen
    col = 0
    chrs.each_index do |a|
      if chrs[a] == 32 || chrs[a] ==124 || chrs[a] == 125 || chrs[a] == 93
        lastchr = a
      end  #end if
      col = col + 1
      if col>maxlinelen
        chrs[lastchr]=10
        col = 0
        lastchr += maxlinelen
      end # end if
    end #end each
    lref = chrs.pack('C*')
    lref.gsub!(/\n\s*/, "\n#{space}")
    return lref
    
  end #end method
  
  def insert_array(array, offset,  array2)
    
    array2.reverse!
    array2.each do |x|
      array.insert(offset, x)
    end
  end
  
end #end class

 
