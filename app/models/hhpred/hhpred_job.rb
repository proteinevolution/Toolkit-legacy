require 'fasta_reader.rb'

class HhpredJob  < Job
  require 'Biolinks.rb'

  attr_reader :results
  @@export_ext = ".hhr"

  def set_export_ext(val)
    @@export_ext = val
  end

  def get_export_ext
    @@export_ext
  end

  def before_results(controller_params = nil )

    location = "HhpredJob.before_results"
    logger.debug "Before results on job #{jobid}"

    self.viewed_on = Time.now
    self.save!
    @results = []
    @cite_pdb=0
    @cite_scop=0
    @cite_ipro=0
    @cite_cdd=0
    @cite_pfam=0
    @cite_smart=0
    @cite_cog=0
    @cite_kog=0
    @cite_prodom=0
    @cite_panther=0
    @cite_tigrfam=0
    @cite_pirsf=0
    @cite_supfam=0
    @cite_CATH=0
    @resultcounter = 0
    createmodel_diabled_checkboxes=""
    options = ""
    program = ""
    coloring = "onlySS"
    hhcluster = false
    makemodel = false

    evalue_hash = Hash.new
    first_hash = Hash.new
    last_hash = Hash.new

    # No file *.PDBlist exists anywhere. Was it an attempt to speed up displaying the result page? TODO: remove this.
    # get databases of HHpred job
    @pdb_ids = Hash.new
    @dbs = actions.first.params['hhpred_dbs'].nil? ? "" : actions.first.params['hhpred_dbs']
    @dbs.each do |db|
      if db.gsub!(/(cdd|COG|KOG|\/pfam|smart|cd|pfamA|pfamB)(_\S*)/, '\1\2/db/\1.PDBlist')
      elsif db.gsub!(/(scop|pdb)(\S*)/, '\1\2/db/\1.PDBlist')
      elsif db.gsub!(/SCOPe(\S*)/, 'SCOPe\1/db/scop.PDBlist')
      elsif db.gsub!(/(panther|tigrfam|pirsf|supfam|CATH)(_\S*)/, '\1\2/db/\1.PDBlist')
      elsif db.gsub!(/([^\/]+)$/, '\1/db/\1.PDBlist' )
      end
      if File.exists?(db)
        File.open(db, "r").each do |line|
#          logger.debug("DB-PDB: #{line}!")
          @pdb_ids[line] = 1
        end
      end
    end

    coloring = controller_params[:mode] ? controller_params[:mode] : 'letters'
    program = controller_params[:action]
    if (!actions.first.flash.nil? && !actions.first.flash['hhcluster'].nil?)
      hhcluster = true
    end

    logger.debug("PROGRAM: #{program}")

    if program.eql?("results_makemodel") || program.eql?("histograms_makemodel")
      makemodel = true
    end

    @results.push("<div id=\"hitlist_img\">\n")

    jobDir = job_dir

    jobDirRel = url_for_job_dir
    # jobid = ARGV[0]
    basename= "#{jobDir}/#{jobid}"
    m = 0 #checkbox index
    maxlinelen=113
    space_for_checkbox="  "
    # Read hhr file
    resfile = File.join("#{jobDir}/" , "#{jobid}.hhr")
    raise("ERROR file not readable!#{jobDir}/#{jobid}.hhr") if !File.readable?(resfile)
    raise("ERROR file does not exist!#{jobDir}") if !File.exists?(resfile)
    raise("ERROR file is zero!#{jobDir}") if  File.zero?(resfile)
    results = File.open(resfile, "r")
    line = results.readlines


    # Read parameters from hhsearch call and format query line and parameter line
    i =0
    query = ""
    len = "?"
    nseqs = "?"
    neff = "?"
    command=""
    commandrealign =""
    queryline=""
    paramline =""

    line.each do  |a|

      if       a =~/^Query \s+ (\S+)/
        query = $1
      elsif  a =~/^Match.columns\s+(\d+)/
        len = $1
      elsif  a=~ /^No.of.seqs\s+(\d+)/
        nseqs = $1
      elsif  a=~ /^Neff\s+(\S+)/
        neff = $1
      elsif  a=~ /^Command.*hhsearch/
        command = a
      elsif  a=~ /^Command.*hhrealign/
        commandrealign = a
      elsif  a=~/^\s*$/
        break
      end
    end #end each# If list of PDB codes is given, link them to NCBIs MMDB


    if    File.exists?(jobDir+"/sequence_file" )
      # Read sequence file
      seqfile = File.join(job_dir, "/sequence_file")
      raise("ERROR with sequencefile!") if !File.readable?(seqfile) || !File.exists?(seqfile) || File.zero?(seqfile)
      seq = File.open(seqfile, "r")

      queryseqs = seq.readlines[1]
      queryseq = queryseqs
      queryseq.gsub!(/\W|\d|\s|_/,"")

      queryseq=~/^(\S{10}).*(\S{10})$/
      queryseq = "#{$1}...#{$2}"

      # Format query name line
      queryline = "<b>Query </b>#{query} (seq=#{queryseq} Len=#{len} Neff=#{neff}  Nseqs=#{nseqs}) "

    else
      queryline = "<b> Query </b>#{query} (Len=#{len} Neff=#{neff} Nseqs=#{nseqs})";
    end #end if

    # Format parameter line
    paramline = "<b>Parameters </b> "
    command =~ /\s-ssm\s(\d+)\s/

    if  $1.to_i == 0
      paramline = paramline+"score SS:no "
    elsif  $1.to_i ==2
      paramline = paramline+"score SS:yes "
    elsif  $1.to_i ==4
      paramline = paramline+"score SS:pred-pred "
    else
      paramline = paramline+ "score SS:? "
    end  # end  if

    if command =~ /\s-local/
      paramline=paramline+"search:local "
    elsif command =~/\s-global/
      paramline= paramline+"search:global "
    else
      paramline =paramline+ "search:? "
    end

    if  !(commandrealign.eql?(""))
      command = commandrealign
    end #end if

    if command =~ /\s-realign/ || command=~/\s-map/
      paramline=paramline+"realign with MAP:yes "
      if command =~/\s-mapt (\S+)/
        paramline=paramline+ "MAP threshold=#{$1} "
      end
    elsif  command =~ /(-norealign)/
      paramline =paramline+"realign with MAP:no "
    else
      paramline =paramline+ "realign with MAP:? #{$1}"
    end # end  if

    # Introduce line breaks when necessary
    wrap(queryline,maxlinelen+7, "      ")
    wrap(paramline,maxlinelen+7, "      ")
    #break_lines(queryline,maxlinelen+7, "       ")
    #break_lines(paramline,maxlinelen+7, "       ")

    ###############################################################
    # Reformat HHpred output

    # Make array with description of matches, to be used as  html mouse-over titles

    descr    = []
    pdb_searched = false
    line.each_index do  |a|
      if line.fetch(a) =~/^No (\d+)/
        m = $1.to_i
       #if line.fetch(a+1) =~ /^>\S+\s+(.*)/
       if line.fetch(a+1) =~ />(.*)/
          descr[m] = $1 
          #descr[m].gsub!(/\"\"\\<>/, '')
        end
      end
      if line.fetch(a) =~ /^Command.*pdb\.hhm/
        pdb_searched = true;
      end
    end  #end each
    #Go to first empty line
    while  line[i]!~/^\s*$/
      i = i+1
    end

    # Go to next non-empty line
    while line[i]=~/^\s*$/
      i = i+1
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

    #Does the query have a structure or structural model?
    querypdb = "" # PDB structure file or query
    if File.exists?(basename+".pdb")
      #Query has a structureal model prepared by user (MODELLER)
      querypdb = basename+".pdb"

    elsif  line[0] =~/^Query\s+([defgh]\d[a-z0-9]{3}[a-z0-9_\.][a-z0-9_])\s+[a-z]\.\d+\.\d+\.\d+\s+/
      #Query is SCOP sequence
      queryname = $1
      scopedir = Biolinks.scope_db_dir()
      if (scopedir)
        querydbpdb = scopedir+"/#{queryname}.pdb"
        if File.exists?(querydbpdb)
          querypdb = querydbpdb
          # system("cp #{querydbpdb} #{querypdb}")
        end
      end
      if querypdb.empty?
        logger.debug("WARNING in #{location}: Could not find pdb file for SCOP sequence #{query}");
      end
    elsif  query =~/^(\d[a-z0-9]{3})([A-Za-z0-9])?_\d+$/ || query =~ /^(\d[A-Za-z0-9]{3})()$/  || query =~/^(\d[A-Za-z0-9]{3})_([A-Za-z0-9])$/
      # Query isDALI or PDB sequence
      pdbid =  $1.downcase
      chain = $2.upcase
      if chain  != ""
        chain = "_"+chain
      end
      dirs=  Dir.glob(DATABASES+"/hhpred/new_dbs/pdb70*")
      querypdb = basename+".pdb"
      if !File.exists?("#{dirs.first}/#{pdbid}#{chain}.pdb")
        logger.debug("WARNING in #{location}: Could not find pdb file for sequence #{query}. Interpreted as pdbcore=#{pdbid}, chain=#{chain}");
        querypdb=""
      else
        system("cp "+dirs.first+"/"+pdbid+chain+".pdb"+" "+querypdb)
      end
    end

    # Print some comments and tips
    if querypdb != ""
      @results.push("<br><font color='brown'><b>View 3D structural alignments between your query and template structures by clicking on the <img src=\"#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png\" height=\"15\" align=\"middle\" /> buttons above the alignments.</b></font>")
    end
    if(prob < 99 && pdb_searched)
      if(self.user_id.nil?)
        @pdbalert_url = "/pdbalert"
      else
        @pdbalert_url = "/pdbalert/automatic_upload?id=#{self.id}"
      end
      @results.push("<font color='red'> <b>*Note*</b>: click <a href=#{@pdbalert_url}>PDBalert<\/a>  to upload your query sequence and get alerted by email as soon as better PDB templates get available.</font><br /><br />")
    end

    if(nseqs.to_i <=5&& prob  < 60)
      @results.push("<font color='red'> <b>Note</b>: Your query alignment consists of only #{nseqs} sequence")
      if nseqs.to_i !=1
        @results.push("s")
      end
      @results.push("(at 90&#37 maximum pairwise sequence identity). You may be able to improve sensitivity vastly ")
      @results.push("by using our intermediate HMM searching method 'HHsenser' to enlarge the query alignment: ")
      @results.push("Just press <b>\"Resubmit using HHsenser</b>\" above. ")
      @results.push("<br>Alternatively, you may try to build a bigger query alignment <i>by hand</i>: ")
      @results.push("Run PSI-BLAST with your query and decide individually for each database match with E-value ")
      @results.push("< 1...10 whether to include it in the alignment. If you can't decide whether to include ")
      @results.push("a candidate sequence, you may use a very powerful technique called ")
      @results.push("i>backvalidation</i> [Koretke <i>et al.</i> 2001]: ")
      @results.push("Start PSI-BLAST with the candidate sequence and check whether you can find your original ")
      @results.push("query sequence or any other already accepted sequence with sufficient E-value (e.g. < 0.01) ")
      @results.push("Repeat PSI-BLAST iterations until you have at least 10 sequences (if possible). ")
      @results.push("Use this seed alignment to jump-start HHpred.</font><br><br>")
    elsif  prob >40 && prob  < 90 && rand() >0.8
      @results.push("<br><font color='blue'>\n<b>Need help to find out how to validate your hits? Click <a href=\"\#\" title=\"HHpred FAQs\" onclick=\"openHelpWindow('/hhpred/help_faq#correct match');\">here.<\/a></b>\n</font>")
    elsif rand() > 0.8
      @results.push("<br><font color='darkgreen'> <b>Note: Corrupted alignments are the most common source of high-scoring false positives. Check the query alignment by clicking </font><font color='black'>Show Query Alignment</font><font color='darkgreen'> above. To check the template alignments use the <img src=\"#{DOC_ROOTURL}/images/hhpred/logo_template_ali.png\" height=\"15\" align=\"middle\" /> logos.</b></font>")
    elsif  rand() > 0.8
      @results.push("<br><font color='green'> <b>Need help on how to interpret your results? Click <a href=\"\#\" title=\"HHpred Results\" onclick=\"openHelpWindow('/hhpred/help_results');\">here.<\/a></b></font>")
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
      @results.push("<div id=\"slider_bar_span\" class=\"span\"></div>\n")
      @results.push("</div>\n")
      @results.push("</div>\n")
      @results.push("<div class=\"row\" style=\"position:absolute; top:50px; width:785px;\">\n")
      @results.push("<form action=\"/hhpred/resubmit_domain/#{jobid}\" method=\"post\">\n")
      @results.push("<input type=\"hidden\" id=\"domain_start\" name=\"domain_start\"/>\n")
      @results.push("<input type=\"hidden\" id=\"domain_end\" name=\"domain_end\"/>\n")
      @results.push("<input type=\"submit\" class=\"feedbutton\" style=\"border-width:2px;\" value=\"Resubmit section\"/>\n")
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

    if (program.eql?("histograms") || program.eql?("histograms_makemodel")) && !File.exists?("#{basename}_1.png")
      system("tar -xzf #{basename}.tar.gz -C #{jobDir} > /dev/null 2>&1")
      logger.debug("tar -xzf #{basename}.tar.gz -C #{jobDir} > /dev/null 2>&1")
    elsif program.eql?( "results")
      ###################################################################################################
      # Display links for prediction of coiled coils, TM alpha-helical domains, or TM beta barrels?
      coiled_coil = 0 # coiled coil found?
      tmbb = 0  # transmembrane beta barrel domain found?
      tma=0     # transmembrane alpha-helical domain found?
      line.each do |a|
        if a =~ /^>/
          if a =~/ h\.\d+\.\d+|coiled coil|coiled-coil|tropomyosin|apolipoprotein/i
            coiled_coil=1
          end
          if a  =~ / f\.[456]\.\d+| omp|outer membrane|porin/i
            tmbb=1
          elsif a =~ / f\.[1-37-9]\d*\.d+| f\.\d\d+\.d+||cytochrome|photosystem/i
            tma=1
          end
        end
      end #end each
      if coiled_coil != 0 || tmbb != 0 ||tma != 0
        raise("Cannot open #{basename}.a3m") if !File.readable?("#{basename}.a3m") || !File.exists?("#{basename}.a3m") || File.zero?("#{basename}.a3m")
        a3mfile = File.open("#{basename}.a3m", "r")
        a3m = a3mfile.readlines
        seq =""
        a3m.each do |a|
          if seq =~/^>ss/ || seq =~/^>aa/
            next
          end
          seq = a.chomp!
          break
        end
        ## Comment this so no automatic coiled Coils Prediction Button fires up
        if coiled_coil != 0
          #@results.push("<div class=\"row\">\n")
          #@results.push("</div>\n")
          #@results.push("<br>HHpred has detected coiled coil containing regions, you may consider running PCoils\n ")
          #url ="#{DOC_ROOTURL}/hhpred/run/#{jobid}?jobaction=hhpred_coils&forward_controller=pcoils&forward_action=forward"
          #@results.push("<input type=\"button\" title=\"Run coiled-coil prediction\" value=\"Run PCOILS\" onclick=\"location.href='#{url}'\">\n")
          @results.push("<pre><font color=\"purple\">HHpred has detected hits to coiled coil-containing proteins.<br>You may consider running a PCOILS prediction on your query.<br></font>\n")
          #@results.push("</div>\n")

        end
      end
      # Display links for prediction of coiled coils, TM alpha-helical domains, or TM beta barrels?
      ###################################################################################################

    end

    @results.push("<pre>#{queryline} \n#{paramline} \n")


    ########################################################################################################
    ############################### Summary hit list  ######################################################
    #
    # No Hit                             Prob E-value P-value  Score    SS Cols Query HMM  Template HMM
    #  1 pfam03756 AfsA A-factor biosyn  99.9 9.3E-28 4.9E-32  173.4   4.9   80   19-102     1-80  (80)

    checkbox_counter = 0
    b=ifirst
    c=ifirst
    while c<line.length
      if line[c] =~/^Done!/
        break
      elsif line[c]=~/^\s*$/

        break
      end

      if line[c] =~ /^\s*(\d+)\s+(\S+)\s+(\S+)\s+/
        @resultcounter = @resultcounter+1
      end
      c = c+1
    end

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
    

        # Pfam-A identifier? (PF01234)
        if template =~/^PF\d{5}/ || template =~/^pfam\d{5}/
          pfamid = template
          pfamid.sub!(/^pfam/, "PF")
          #link to PFAM domain family?acc=
          descr[m] = descr[m].gsub(/[><=;]/," - ")
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/pfam.xfam.org\/family?acc=#{pfamid}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
          # PRODOM identifier? (PD012345)
        elsif  template =~ /^PD\d{6}/
          # link to PRODOM domain
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/prodes.toulouse.inra.fr\/prodom\/current\/cgi-bin\/request.pl?question=DBEN&query=#{template}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")

          # SMART identifier? (smart00382)
        elsif template =~/^SM\d{5}/ || template =~/^smart\d{5}/
          smartid = template
          smartid.sub!(/^smart/, "SM")
          line[b] =~ /(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s*-(\d+)\s+\d+-\d+\s*\(\d+\)\s*$/
          evalue = $1
          first = $2
          last = $3
          evalue_hash[smartid] = evalue
          first_hash[smartid] =  first
          last_hash[smartid] =  last

          # Link to  SMART domain description
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/dylan.embl-heidelberg.de\/smart\/do_annotation.pl?DOMAIN=#{smartid}&START=#{first}&END=#{last}&E_VALUE=#{evalue}&TYPE=SMART\" target=\"_blank\" title=\"#{descr[m]}\">#{template} <\/a>")

          # Other CDD identifier? (COG0001, KOG0001, cd00001)
        elsif template =~/^COG\d{4}/ || template =~/^KOG\d{4}/ || template =~/^cd\d{5}/
                                # Link to CDD at NCBI
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")

          # PANTHER identifier? (PTHR15545)
        elsif template =~/^PTHR\d{5}/
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/www.pantherdb.org\/panther\/family.do?clsAccession=#{template}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")

          # TIGRFAMs identifier? (TIGR01243)
        elsif template =~/^TIGR\d{5}/
          # LINK to TIGRFAMs
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/www.tigr.org\/tigr-scripts\/CMR2\/hmm_report.spl?acc=#{template}&user=access&password=access\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")

          #l PIRSF identifier? (PIRSF015873)
        elsif template =~/^PIR(SF\d{6})/
          # Link to PIRSF
          family = $1
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/pir.georgetown.edu\/cgi-bin\/ipcSF?id=#{family}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")

          # SUPFAM identifier? (SUPFAM0022216)
        elsif  template =~ /^SUPFAM\d+$/
          line[b] =~ /SUPFAM(\d+)\s+(\S+)/
          template = $1
          family = $2

          # Link to SUPERFAMILY

          href = "http:\/\/supfam.mrc-lmb.cam.ac.uk\/SUPERFAMILY\/cgi-bin\/model.cgi?model=#{template}";
          line[b].sub!(/SUPFAM#{template}/, "<a href=\"#{href}\" target=\"_blank\">SUPFAM#{template}<\/a>")

          # CATH identifier? (1cz4A1)
        elsif template =~ /^(\d[a-z0-9]{3})[A-Za-z0-9][0-9]$/
          pdbcode   = $1;
          ucpdbcode= $1.upcase;

          # Link to CATH at family level
          family=~/^(\d+)\.(\d+)\.(\d+)\.(\d+)/
          c=$1
          a=$2
          t=$3
          h=$4
          line[b].sub!(/#{family}/, "<a href=\"http:\/\/cathwww.biochem.ucl.ac.uk\/latest\/class#{c}\/#{a}\/#{t}\/#{h}\/index.html\" target=\"_blank\">#{family}<\/a>")

          # Link to CATH at protein level
          template=~/^(\S\S)/ # first two letters, e.g. 1c
          c=$1
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/cathwww.biochem.ucl.ac.uk\/latest\/domains\/#{c}\/#{template}.html\" target=\"_blank\">#{template}<\/a>")

          # SCOP identifier? (d3lkfa_,d3pmga1,d3pga1_,d3grs_3,g1m26.1,d1n7daa)
        elsif template =~ /^[defgh](\d[a-z0-9]{3})([a-z0-9_\.])[a-z0-9_]$/
          pdbcode   = $1
          ucpdbcode = $1.upcase
          pdbc      = $1
          if $2 != "_"
            pdbc=pdbc+"%20#{$2}"
          end

          # Link to SCOP at family level
          line[b].sub!(/#{family}/, Biolinks.scop_family_link(family))

          # Link to NCBI MMDB
          line[b].sub!(/#{template}/,"<a href=\"http:\/\/www.ncbi.nlm.nih.gov\/entrez\/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{ucpdbcode}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")

          # DALI/PDB identifier?  (8fabA_0,1a0i_2)
        elsif  template =~ /^(\d[a-z0-9]{3})([A-Za-z0-9])?_\d+$/
          pdbcode   = $1
          ucpdbcode = $1.upcase

          # Link to PDB
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")


          # PDB identifier?  (8fab_A,1a0i  )
        elsif template =~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/
          pdbcode   = $1
          ucpdbcode = $1.upcase

          # Link to PDB
          line[b].sub!(/#{template}/, "<a href=\"http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
        end

        if template !~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/ &&  template !~ /^[defgh](\d[a-z0-9]{3})[a-z0-9_\.][a-z0-9_]$/ && !@pdb_ids.include?(template)
          createmodel_diabled_checkboxes =createmodel_diabled_checkboxes+"#{checkbox_counter},"
        end

        #line[b] = "<input style=\"margin: 0px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox#{checkbox_counter}\" id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 0)\"/>#{line[b]}"
        line[b] = "<input style=\"margin: 0px; padding: 0px;\" type=\"checkbox\"    id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"document.getElementById('hit_checkbox#{@resultcounter+m-1}').checked = this.checked\">#{line[b]}"

        checkbox_counter =checkbox_counter+ 1
      end
      b= b+1

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
        line[b].sub!(/(No\s*#{m})/) {|match| match =  "<a name = #{m}>#{$1}<\/a>"}
        line[b] = space_for_checkbox+line[b];

        # print image for hhcluster -> hhpred
        if  hhcluster
          line[b+1] =~ /^>(\S+)\s+(\S+)\s*([^.;,\[\(\{]*)/
          hhcluster_id = $1
          line[b].chomp!
          line[b] = line[b]+ "<a href=\"#{DOC_ROOTURL}/hhcluster/makeHhpred/?id=#{hhcluster_id}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_HHpred_results.jpg\" alt=\"HHpred Results\" title=\"Show HHpred results\" #{logo_attr} height=\"30\"><\/a>\n"
        end
        # print image for profile logos
        if (program.eql?("histograms") || program.eql?("histograms_makemodel"))
          line[b].chomp!
          if !makemodel
            line[b]=line[b]+ "<a href=\"#{DOC_ROOTURL}/hhpred/results/#{jobid}##{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_alignments.jpg\" alt=\"Alignments\" title=\"show query-template alignments\" #{logo_attr} height=\"30\"><\/a>\n"
          else
            line[b] = line[b]+ "<a href=\"#{DOC_ROOTURL}/hhpred/results_makemodel/#{jobid}##{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_alignments.jpg\" alt=\"Alignments\" title=\"show query-template alignments\" #{logo_attr} height=\"30\"><\/a>\n\n"
          end

          mapname="#{jobid}_#{m}"
          mapfile="#{jobDir}/#{mapname}.map"
          imgfile="#{jobid}_#{m}.png"
          j=b+1;

          # Advance to first line of alignment
          while j<line.length && line[j]!~/^\s*$/
            j=j+1
          end

          # Insert Image

          if File.exists?(mapfile)
            raise("ERROR with mapfile!") if !File.readable?(mapfile)|| !File.exists?(mapfile) || File.zero?(mapfile)
            map = (File.open(mapfile, "r")).readlines
            #~ line.push(map[j])
            insert_array(line,j,map)
            j =j+ map.length

          else
            line.delete_at(j)
          end

          # Delete all lines of alignment up to beginning of next alignment
          j=j+1
          while j<line.length && line[j]!~/^No\s*\d+/
            line.delete_at(j)
          end
        else
          line[b].chomp!
          if !makemodel
            line[b] =line[b]+ "<a href=\"#{DOC_ROOTURL}/hhpred/histograms/#{jobid}##{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_histogram_single.png\" alt=\"Histograms\" title=\"Show histograms\" #{logo_attr} height=\"30\"><\/a>\n";
          else
            line[b] =line[b]+ "<a href=\"#{DOC_ROOTURL}/hhpred/histograms_makemodel/#{jobid}##{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_histogram_single.png\" alt=\"Histograms\" title=\"Show histograms\" #{logo_attr} height=\"30\"><\/a>\n\n";
          end
        end

        # Add logo for template alignment
        line[b].chomp!
        if !makemodel
          line[b]=line[b]+"<a href=\"#{DOC_ROOTURL}/hhpred/run/#{jobid}?jobaction=hhpred_showtemplalign&forward_controller=hhpred&forward_action=results_showtemplalign&alformat=fasta&hits=#{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_template_ali.png\" title=\"Show template alignment\" #{logo_attr} /><\/a>\n"
        end

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
          longname = longname + "[TI]"
        end
        wrap(line[b], maxlinelen, space_for_checkbox)
        #break_lines(line[b],maxlinelen,space_for_checkbox)

        # If list of PDB codes is given, link them to NCBIs MMDB
        if line[b]=~/^([\s\S]*PDB:\s*)((\S+[\^:]{0,1}\s*)+)/
          left = $1
          middle = $2
          line[b].sub!(/^([\s\S]*PDB:\s*)((\S+[\^:]{0,1}\s*)+)/,"")
          middle.gsub!(/(\S\S\S\S)(\S*)/, "<a href=\"http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=\\1 \" target=\"_blank\" title=\"PDB\"> \\1 \\2<\/a>")# link to PDB
          line[b] =left+middle+line[b]
        end
        # Pfam-A identifier? (PF01234)
        if  template=~/^PF\d{5}/ || template=~/^pfam\d{5}/
          template=~ /^(\S*)\.?\S*/
          pfamid = $1
          pfamid.sub!(/^pfam/,"PF")
          @cite_pfam=1

          # link to Pfam-A domain
          href="http:\/\/pfam.xfam.org\/family?acc=#{pfamid}"
          line[b].gsub!(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1]= line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_Pfam.jpg\" alt=\"Pfam\" title=\"Pfam\" #{logo_attr} height=\"20\" ><\/a>\n"

          if  template=~/^pfam\d{5}/
            # Link to CDD at NCBI
            href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}";
            line[b-1].chomp!
            line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"20\"><\/a>\n"
          end

          add_inter_pro_link_logo(b, line, link_attr, logo_attr);

          if (longname != nil && shortname != nil)
            add_pubmed_logo(b,longname, line, link_attr, logo_attr)
          end
          # PRODOM identifier? (PD012345)
        elsif  template=~/^PD\d{6}/
          template=~ /^(\S*)\.?\S*/
          prodomid = $1
          @cite_prodom=1
          href="http:\/\/prodes.toulouse.inra.fr\/prodom\/current\/cgi-bin\/request.pl?question=DBEN&query=#{prodomid}"
          # link to PRODOM domain
          line[b].sub!(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_ProDom.jpg\" alt=\"ProDom\" title=\"ProDom\" #{logo_attr} height=\"20\"><\/a>\n"

          # SMART identifier? (smart00382)
        elsif  template=~/^SM\d{5}/ || template=~/^smart\d{5}/
          smartid = template;
          smartid.sub!(/^smart/,"SM")
          line[b] =~/^\s*\d+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+.*(\d+)\s*-\s*(\d+)\s*\(\d+\)\s*\d+\s*-\s*\d+\s*\(\d+\)\s*$/
          evalue = evalue_hash[smartid]
          first  = first_hash[smartid]
          last   = last_hash[smartid]
          @cite_smart=1

          # Link to SMART domain description
                                href="http:\/\/dylan.embl-heidelberg.de\/smart\/do_annotation.pl?DOMAIN=#{smartid}&START=#{first}&END=#{last}&E_VALUE=#{evalue}&TYPE=SMART"
          line[b].sub!(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>/")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_SMART.jpg\" alt=\"SMART\" title=\"SMART\" #{logo_attr} height=\"14\"><\/a>\n";

          if  template=~/^smart\d{5}/
            # Link to CDD at NCBI
            href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}"
            line[b-1].chomp!
            line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"20\"><\/a>\n";
          end

          if (longname != nil && shortname != nil)
            add_pubmed_logo(b,longname, line, link_attr, logo_attr)
          end

        elsif  template=~/^COG\d{4}/
          @cite_cog=1

          # Link to COGs
          href="http:\/\/www.ncbi.nlm.nih.gov\/COG\/old\/palox.cgi?#{template}";
          line[b].sub!(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_COGs.png\" alt=\"COGs\" title=\"COGs\" #{logo_attr} height=\"25\"><\/a>\n"

          # Link to CDD at NCBI
          href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}"
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"25\"><\/a>\n"

          if longname != nil  && shortname != nil
            add_pubmed_logo(b,"#{shortname} #{longname}", line, link_attr, logo_attr)
          end

        elsif  template=~/^KOG\d{4}/
          @cite_kog=1;

          # Link to KOGs
          href="http:\/\/www.ncbi.nlm.nih.gov/COG/grace/shokog.cgi?#{template}"
          line[b].sub!(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_COGs.png\" alt=\"KOGs\" title=\"KOGs\" #{logo_attr} height=\"25\"><\/a>\n"

          # Link to CDD at NCBI
          href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}";
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"25\"><\/a>\n"

          if longname != nil && shortname != nil
            add_pubmed_logo(b,"#{shortname} #{longname}", line, link_attr, logo_attr)
          end

          # Other CDD identifier? (KOG0001, cd00001)
        elsif  template=~/^KOG\d{4}/ || template=~/^cd\d{5}/ || template=~/^LOAD\d{4}/
          @cite_cdd=1;

          # Link to CDD at NCBI
          href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}"
          line[b].sub!(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"20\"><\/a>\n"

          if longname != nil && shortname != nil
            add_pubmed_logo(b,"#{shortname} #{longname}", line, link_attr, logo_attr)
          end

          # PANTHER identifier? (PTHR15545)
        elsif  template=~/^PTHR\d{5}/
          @cite_panther=1;

          # Link to PANTHER
          href="http:\/\/www.pantherdb.org\/panther\/family.do?clsAccession=#{template}"
          line[b].sub!(/#{template}/, "<a href=\"href\" target=\"_blank\">template<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_panther.gif\" alt=\"PANTHER\" title=\"PANTHER\" #{logo_attr} height=\"25\"><\/a>\n"

          add_inter_pro_link_logo(b, line, link_attr, logo_attr)

          if  longname !=  nil && shortname != nil
            add_pubmed_logo(b,"#{shortname} #{longname}",line, link_attr, logo_attr)
          end

          # TIGRFAMs identifier? (TIGR01243)
        elsif  template=~/^TIGR\d{5}/
          @cite_tigrfam=1;

          # Link to TIGRFAMs
          href="http:\/\/www.tigr.org\/tigr-scripts\/CMR2\/hmm_report.spl?acc=#{template}&user=access&password=access"
          line[b].sub!(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_tigr.gif\" alt=\"TIGRFAM\" title=\"TIGRFAM\" #{logo_attr} height=\"20\"><\/a>\n"

          add_inter_pro_link_logo(b, line, link_attr, logo_attr)

          if longname !=  nil && shortname != nil
            add_pubmed_logo(b,"#{shortname} #{longname}", line, link_attr, logo_attr)
          end

          # PIRSF identifier? (PIRSF015873)
        elsif  template=~/^PIR(SF\d{6})/
          family=$1;
          @cite_pirsf=1;

          # Link to PIRSF
          href="http:\/\/pir.georgetown.edu\/cgi-bin\/ipcSF?id=#{family}";
          line[b].sub!(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_pirsf.png\" alt=\"PIRSF\" title=\"PIRSF\" #{logo_attr} height=\"20\"><\/a>\n"

          add_inter_pro_link_logo(b, line, link_attr, logo_attr)

          if longname !=  nil  &&  shortname != nil
            add_pubmed_logo(b,"#{shortname} #{longname}", line, link_attr, logo_attr)
          end

          # SUPFAM identifier? (SUPFAM0022216)
        elsif  template =~ /^SUPFAM\d+$/
          # SUPFAM0022216 b.29.1 Concanavalin A-like lectins/glucanases (49899) SCOP seed sequence: d1m4wa_.
          line[b] =~ /SUPFAM(\d+)\s+(\S+)(\n|.)*\((\d+)\) SCOP\s+seed\s+sequence:\s+(\w+)/
          template = $1
          family  = $2
          supfam_famid=$4
          scopid   = $5
          scopid=~/^[a-z](\d\S\S\S)/
          pdbcode   = $1
          ucpdbcode = $1.upcase
          @cite_supfam=1

          # Link to SUPERFAMILY
          href = "http:\/\/supfam.mrc-lmb.cam.ac.uk\/SUPERFAMILY\/cgi-bin\/model.cgi?model=#{template}"
          line[b].sub!(/SUPFAM#{template}/, "<a href=\"#{href}\" target=\"_blank\">SUPFAM template<\/a>")

          # Link to SUPERFAMILY at family level
          href = "http:\/\/supfam.mrc-lmb.cam.ac.uk\/SUPERFAMILY\/cgi-bin\/scop.cgi?sunid=#{supfam_famid}"
                                line[b].sub!(/\(#{supfam_famid}\)/, "(<a href=\"#{href}\" target=\"_blank\">#{supfam_famid}<\/a>)")

          # Logo to SUPERFAMILY at family level
          line[b-1].chomp!
          line[b-1]= line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_supfam.gif\" alt=\"Superfamily\" title=\"Superfamily\" #{logo_attr} height=\"30\"><\/a>"

          # Link/logo to SCOP
          href=Biolinks.scop_sid_href(scopid)
          line[b-1].chomp!
          line[b-1]=line[b-1] + Biolinks.scope_picture_link(href, link_attr, logo_attr)
          add_inter_pro_link_logo(b,line, link_attr, logo_attr)
          add_structure_database_logos(b,template,pdbcode, line, link_attr, logo_attr)
          add_pubmed_logo(b,ucpdbcode, line, link_attr, logo_attr)

          # CATH identifier? (1cz4A1)
        elsif  template =~ /^(\d[a-z0-9]{3})[A-Za-z0-9][0-9]$/
          @cite_CATH=1

          pdbcode   = $1
          ucpdbcode = $1.upcase

          # Link to CATH at family level
          family=~/^(\d+)\.(\d+)\.(\d+)\.(\d+)/
          c=$1
          a=$2
          t=$3
          h=$4;
          href="http:\/\/cathwww.biochem.ucl.ac.uk\/latest\/class #{c}\/#{a}\/#{t}\/#{h}\/index.html"
          line[b].sub!(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
          line[b-1].chomp!
          line[b-1] =line[b-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_cath.gif\" alt=\"CATH/Gene3D\" title=\"CATH/Gene3D\" #{logo_attr} height=\"20\"><\/a>\n";

          # Link to PDB
          href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
          line[b].sub!(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")

          add_inter_pro_link_logo(b, line, link_attr, logo_attr);
          add_structure_database_logos(b,template,pdbcode,line, link_attr, logo_attr)
          add_pubmed_logo(b,ucpdbcode, line, link_attr, logo_attr)

          # SCOP identifier? (d3lkfa_,d3pmga1,d3pga1_,d3grs_3,g1m26.1,d1n7daa)
        elsif  template =~ /^[defgh](\d[a-z0-9]{3})([a-z0-9_\.])[a-z0-9_]$/
          pdbcode   = $1
          ucpdbcode = $1.upcase
          templpdb = nil # Initialize templpdb, in case the code is in a loop...
          pdbc      = $1
          if $2 != "_"
            pdbc=pdbc+"%20#{$2}"
          end
          @cite_scop=1

          # Is query AND template structure known?
          if  querypdb != ""
            scopedir = Biolinks.scope_db_dir()
            if (scopedir)
              templpdb=scopedir+"/#{template}.pdb"
            end
            unless templpdb && File.exists?(templpdb)
              dirs=Dir.glob("#{DATABASES}/hhcluster/scop25*")
              if (0 < dirs.length)
                templpdb=dirs[dirs.length-1]+"/#{template}.pdb"
              else
                templpdb=nil
              end
            end

            if  templpdb && File.exists?(templpdb)
              line[b-1].chomp!
              line[b-1]=line[b-1]+"<a href=\"#\" onclick=\"var win = window.open('#{DOC_ROOTURL}/hhpred/run/hh3d_querytempl?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&querypdb=#{querypdb}&forward_controller=hhpred&forward_action=results_hh3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png\" title=\"Show query-template 3D superposition\" #{logo_attr} /><\/a>\n"

            else
              logger.debug("WARNING in #{location}: Could not find pdb file for SCOP sequence #{template}")
            end
          else
            scopedir = Biolinks.scope_db_dir()
            if (scopedir)
              templpdb=scopedir+"/#{template}.pdb"
            end
            unless templpdb && File.exists?(templpdb)
              dirs=Dir.glob("#{DATABASES}/hhcluster/scop25*")
              if (0 < dirs.length)
                templpdb=dirs[dirs.length-1]+"/#{template}.pdb"
              else
                templpdb=nil
              end
            end

            if  File.exists?(templpdb)
              line[b-1].chomp!
              line[b-1]=line[b-1]+"<a href=\"#\" onclick=\"var win = window.open('#{DOC_ROOTURL}/hhpred/run/hh3d_templ?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&forward_controller=hhpred&forward_action=results_hh3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_T_struct.png\" title=\"Show template 3D structure\" #{logo_attr} /><\/a>\n"

            else
              logger.debug("WARNING in #{0}: Could not find pdb file for SCOP sequence #{template}")
            end
          end
          # Link to SCOP
          href=Biolinks.scop_sid_href(template)

          line[b].sub!(/#{shortname}/,"<a href=\"#{href}\" target=\"_blank\">#{shortname}<\/a>")
          line[b-1].chomp!
          line[b-1]=line[b-1] + Biolinks.scope_picture_link(href, link_attr, logo_attr) + "\n"

          # Link to PDB
          href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
          line[b].sub!(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")

          add_structure_database_logos(i,template,pdbcode, line, link_attr, logo_attr);
          add_pubmed_logo(i,ucpdbcode, line, link_attr, logo_attr)

          # DALI/PDB identifier?  (8fabA_0,1a0i_2)
        elsif  template =~ /^(\d[a-z0-9]{3})([A-Za-z0-9])?_\d+$/
          pdbcode   = $1
          ucpdbcode = $1.upcase
          templpdb = nil
          @cite_pdb=1

          # Is query AND template structure known?
          if querypdb != ""
            dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*");
            dirs.each do |dir|
              templpdb=dir+"/#{template}.pdb";
              if  File.exists?(templpdb)
                line[b-1].chomp!
                line[b-1]=line[b-1]+"<a href=\"#\" onclick=\"var win = window.open('#{DOC_ROOTURL}/hhpred/run/hh3d_querytempl?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&querypdb=#{querypdb}&forward_controller=hhpred&forward_action=results_hh3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png\" title=\"Show query-template 3D superposition\" #{logo_attr} /><\/a>\n"
                break
              end
            end
            #else logger.debug("WARNING in #{location}: Could not find pdb file for PDB sequence #{template}")

          else
            dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*")
            dirs.each do |dir|
              templpdb=dir+"/#{template}.pdb";
              if  File.exists?(templpdb)
                line[b-1].chomp!
                line[b-1]=line[b-1]+"<a href=\"#\" onclick=\"var win = window.open('#{DOC_ROOTURL}/hhpred/run/hh3d_templ?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&forward_controller=hhpred&forward_action=results_hh3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_T_struct.png\" title=\"Show template 3D structure\" #{logo_attr} /><\/a>\n"
                break
              end
            end
          end

          # Link to DALI
          line[b].sub!(/#{shortname}/,"<a href=\"http:\/\/www.bioinfo.biocenter.helsinki.fi:8080\/cgi-bin\/daliquery.cgi?find=#{template}\" target=\"_blank\">#{shortname}<\/a>")

          # Link to SCOP family
          if line[b]=~/SCOP:.*\s+([a-z]\.\d+\.\d+\.\d+)\s+/
            line[b].gsub!(/([a-z]\.\d+\.\d+\.\d+)/, Biolinks.scop_family_link($1))
            # Link to SCOP with pdb code
            href = Biolinks.scop_pdb_href(pdbcode)
            line[b-1].chomp!
            line[b-1]= line[b-1] + Biolinks.scope_picture_link(href, link_attr, logo_attr) + "\n"
          end

          # Link to PDB
          href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
          line[b].sub!(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")

          add_structure_database_logos(b,template,pdbcode, line, link_attr, logo_attr)
          add_pubmed_logo(b,ucpdbcode, line, link_attr, logo_attr)



          # PDB identifier?  (8fab_A,1a0i  )
        elsif template =~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/
          pdbcode   = $1
          ucpdbcode = $1.upcase
          templpdb
          @cite_pdb=1
          # Is query AND template structure known?
          if querypdb != ""
            dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*")
            dirs.each do |dir|
              templpdb=dir+"/#{template}.pdb";
              if  File.exists?(templpdb)
                line[b-1].chomp!
                line[b-1]=line[b-1]+"<a href=\"#\" onclick=\"var win = window.open('#{DOC_ROOTURL}/hhpred/run/hh3d_querytempl?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&querypdb=#{querypdb}&forward_controller=hhpred&forward_action=results_hh3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png\" title=\"Show query-template 3D superposition\" #{logo_attr} /><\/a>\n"
#            else
#              logger.debug("WARNING in #{0}: Could not find pdb file for PDB sequence #{template}")
#              logger.debug("Path: #{templpdb}")
                break
              end
            end
          else
            dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*")
            dirs.each do |dir|
              templpdb=dir+"/#{template}.pdb"
              if  File.exists?(templpdb)
                line[b-1].chomp!
                line[b-1]=line[b-1]+"<a href=\"#\" onclick=\"var win = window.open('#{DOC_ROOTURL}/hhpred/run/hh3d_templ?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&forward_controller=hhpred&forward_action=results_hh3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_T_struct.png\" title=\"Show template 3D structure\" #{logo_attr} /><\/a>\n"

#            else
#              logger.debug("WARNING in #{location}: Could not find pdb file for PDB sequence #{template}")
                break
              end
            end
          end

          # Link to PDB
          href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
          line[b].sub!(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")

          # Link to SCOP family
          if line[b]=~/SCOP:.*\s+([a-z]\.\d+\.\d+\.\d+)\s+/
            line[b].gsub!(/[a-z]\.\d+\.\d+\.\d+/){|match| match = Biolinks.scop_family_link(match)}
            # Link to SCOP with pdb code
            href=Biolinks.scop_pdb_href(pdbcode)
            line[b-1].chomp!
            line[b-1]=line[b-1] + Biolinks.scope_picture_link(href, link_attr, logo_attr) + "\n"
          end

          add_structure_database_logos(b,template,pdbcode, line,link_attr, logo_attr)
          add_pubmed_logo(b,ucpdbcode, line, link_attr, logo_attr)

        end

        #line[b] = "#{m}<input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox#{checkbox_counter}\" id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 1)\"/>#{line[b]}"
        line[b] = "<input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\"  id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"document.getElementById('hit_checkbox#{checkbox_counter-@resultcounter}').checked = this.checked\">"+line[b]

        checkbox_counter=checkbox_counter+1

      elsif line[b] =~ /^>\S+/

        #line[b] = "<input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox#{checkbox_counter}\" id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 1)\"/>#{line[b]}"
        line[b] = " <input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\"   id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"document.getElementById('hit_checkbox#{checkbox_counter-@resultcounter}').checked = this.checked\">"+line[b]

        checkbox_counter=checkbox_counter+1


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
      if  line[b] =~ /^\s*(Q|T) ss_(dssp|pred)\s+(\S+)/
        seq     = $3
        old_seq = $3
        if  coloring.eql?( "onlySS")
          seq.gsub!(/([eE]+)/) {|match|  match ="<span style=\"color: #0000D0;\">#{$1}<\/span>"}
          seq.gsub!(/([hH]+)/) {|match| match = "<span style=\"color: #D00000;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,"#{seq}")

        elsif  coloring.eql?( "letters")
          seq.gsub!(/([eE]+)/) {|match| match ="<span style=\"color: #0000D0;\">#{$1}<\/span>"}
          seq.gsub!(/([hH]+)/) {|match|  match = "<span style=\"color: #D00000;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,"#{seq}")

        elsif  coloring.eql?( "background")
          seq.gsub!(/([eE]+)/) {|match|  match = "<span style=\"background-color: #b0b0ff;\">#{$1}<\/span>"}
          seq.gsub!(/([hH]+)/) {|match|  match ="<span style=\"background-color: #ffb0b0;\">#{$1}<\/span>"}
          line[b].sub!(/#{old_seq}/,"#{seq}")
        end
        # Found a consensus line?
      elsif  line[b] =~ /^\s*(Q|T) Cons(-\S+|ensus)\s+\d+\s+(\S+)/
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
      elsif line[b] =~ /^\s*(Q|T) (\S+)\s+\d+\s+(\S+)/
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

        elsif   coloring.eql?( "background")
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
      elsif  line[b] =~ /^\s*(Q|T) ss_/
      end
      b = b+1

    end #end while
    #~ @results.push("<font size = 16><b> Hier!</b></font><br><br><br><br>")

    @results.push("<input type=\"hidden\" id=\"checkboxes\" name=\"checkboxes\" value=\"#{m}\" \>\n")
    @results.push("<input type=\"hidden\" id=\"createmodel_disabled_Checkboxes\" name=\"createmodel_disabled_Checkboxes\" value=\"#{createmodel_diabled_checkboxes}\" \>\n")

    b = ifirst
    while b< line.length
      @results.push(line[b])
      b = b+1
    end #end while


    @results.push("<br></pre>\n")
    @results.push("Please cite as appropriate: \n")
    @results.push("<BR><BR><B><i>HHpred</i>: S&ouml;ding, J. (2005) Protein homology detection by HMM-HMM comparison. Bioinformatics 21: 951-960.</B>")
    @results.push("<BR><BR><i>PSIPRED</i>: Jones, D.T. (1999) Protein secondary structure prediction based on position-specific scoring matrices. JMB 292: 195-202.")
    @results.push("<BR><BR><i>PDB</i>: Bourne, PE. <i>et al.</i> (2004) The distribution and query systems of the RCSB Protein Data Bank. NAR 32: D223.") if (@cite_pdb >0)
    @results.push("<BR><BR><i>SCOP</i>: Andreeva A, Howorth D, Brenner SE, Hubbard TJ, Chothia C, Murzin AG. (2004)     SCOP database in 2004: refinements integrate structure and sequence family data. NAR 32: D226-229.") if (@cite_scop  >0)
    @results.push("<BR><BR><i>Interpro</i>: Mulder NJ, Apweiler R, Attwood TK, Bairoch A, Bateman A, Binns D, Bradley P, Bork P, Bucher P, Cerutti L, Copley R, Courcelle E, Das U, Durbin R, Fleischmann W, Gough J, Haft D, Harte N, Hulo N, Kahn D, Kanapin A, Krestyaninova M, Lonsdale D, Lopez R, Letunic I, Madera M, Maslen J, McDowall J, Mitchell A, Nikolskaya AN, Orchard S, Pagni M, Ponting CP, Quevillon E, Selengut J, Sigrist CJ, Silventoinen V, Studholme DJ, Vaughan R, Wu CH. (2005) InterPro, progress and status in 2005. NAR 33: D201-205.") if (@cite_ipro  >0 )
    @results.push("<BR><BR><i>Pfam</i>: Bateman A, Coin L, Durbin R, Finn RD, Hollich V, Griffiths-Jones S, Khanna A, Marshall M, Moxon S, Sonnhammer EL, Studholme DJ, Yeats C, Eddy SR. (2004) The Pfam protein families database. NAR 32: D138-141.") if (@cite_pfam  >0)
    @results.push("<BR><BR><i>SMART</i>: Letunic I, Copley RR, Schmidt S, Ciccarelli FD, Doerks T, Schultz J, Ponting CP, Bork P. (2004) SMART 4.0: towards genomic data integration. NAR 32: D142-144.") if (@cite_smart  >0 )
    @results.push("<BR><BR><i>CDD</i>: Marchler-Bauer A, Anderson JB, Cherukuri PF, DeWeese-Scott C, Geer LY, Gwadz M, He S, Hurwitz DI, Jackson JD, Ke Z, Lanczycki CJ, Liebert CA, Liu C, Lu F, Marchler GH, Mullokandov M, Shoemaker BA, Simonyan V, Song JS, Thiessen PA, Yamashita RA, Yin JJ, Zhang D, Bryant SH. (2005) CDD: a Conserved Domain Database for protein classification.. NAR 33: D192-196.") if (@cite_cdd >0)
    @results.push("<BR><BR><i>COG</i>: Tatusov RL, Fedorova ND, Jackson JD, Jacobs AR, Kiryutin B, Koonin EV, Krylov DM, Mazumder R, Mekhedov SL, Nikolskaya AN, Rao BS, Smirnov S, Sverdlov AV, Vasudevan S, Wolf YI, Yin JJ, Natale DA. (2003) The COG database: an updated version includes eukaryotes. BMC Bioinformatics 4: 41.") if (@cite_cog  >0)
    @results.push("<BR><BR><i>KOG</i>: Koonin EV, Fedorova ND, Jackson JD, Jacobs AR, Krylov DM, Makarova KS, Mazumder R, Mekhedov SL, Nikolskaya AN, Rao BS, Rogozin IB, Smirnov S, Sorokin AV, Sverdlov AV, Vasudevan S, Wolf YI, Yin JJ, Natale DA. (2004) A comprehensive evolutionary classification of proteins encoded in complete eukaryotic genomes. Genome Biol 5: R7.") if (@cite_kog >0 )
    @results.push("<BR><BR><i>PANTHER</i>: Mi H, Lazareva-Ulitsky B, Loo R, Kejariwal A, Vandergriff J, Rabkin S, Guo N, Muruganujan A, Doremieux O, Campbell MJ, Kitano H, Thomas PD. (2005) The PANTHER database of protein families, subfamilies, functions and pathways. NAR 33: D284-288.") if (@cite_panther  >0)
    @results.push("<BR><BR><i>TIGRFAMs</i>: Haft DH, Selengut JD, White O. (2003) The TIGRFAMs database of protein families. NAR 31: 371-373.") if (@cite_tigrfam  >0 )
    @results.push("<BR><BR><i>PIRSF</i>: Wu CH, Nikolskaya A, Huang H, Yeh LS, Natale DA, Vinayaka CR, Hu ZZ, Mazumder R, Kumar S, Kourtesis P, Ledley RS, Suzek BE, Arminski L, Chen Y, Zhang J, Cardenas JL, Chung S, Castro-Alvear J, Dinkov G, Barker WC. (2004) PIRSF: family classification system at the Protein Information Resource. NAR 32: D112-114.") if (@cite_pirsf  >0)
    @results.push("<BR><BR><i>Superfamily</i>: Madera M, Vogel C, Kummerfeld SK, Chothia C and Gough J. (2004) The SUPERFAMILY database in 2004: additions and improvements. NAR 32: D235-D239.") if (@cite_supfam  >0)
    @results.push("<BR><BR><i>CATH/Gene3D</i>: Pearl F, Todd A, Sillitoe I, Dibley M, Redfern O, Lewis T, Bennett C, Marsden R, Grant A, Lee D, Akpor A, Maibaum M, Harrison A, Dallman T, Reeves G, Diboun I, Addou S, Lise S, Johnston C, Sillero A, Thornton J, Orengo C. (2005) The CATH Domain Structure Database and related resources Gene3D and DHS provide comprehensive domain family information for genome analysis. NAR 33: D247-D251") if (@cite_CATH  >0 )
    @results.push("<BR><BR><i>PRODOM</i>: Bru, C. <i>et al.</i> (2005) The ProDom database of protein domain families: more emphasis on 3D. NAR 33: D212-215.") if (@cite_prodom  >0)
    #exit(0)

end #end method


def add_structure_database_logos(*params)
  i = params[0]
  template = params[1]
  pdbcode = params[2]
  ucpdbcode = pdbcode.upcase
  line = params[3]
  link_attr = params[4]
  logo_attr = params[5]
  line[i-1].chomp!

  # Link to PDB
  href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}";
  line[i-1] =line[i-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_PDB.jpg\" alt=\"PDB\" title=\"PDB\" #{logo_attr} height=\"20\"><\/a>"

  # Link to NCBI MMDB
  href="http:\/\/www.ncbi.nlm.nih.gov\/entrez\/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{ucpdbcode}";
  line[i-1] =line[i-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_MMDB.jpg\" alt=\"MMDB\" title=\"MMDB/NCBI\" #{logo_attr} height=\"20\"><\/a>"

  # Link to EBI MSD
  href="http:\/\/www.ebi.ac.uk/pdbe-srv/view/entry/#{pdbcode}"
  line[i-1] =line[i-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_MSD.jpg\" alt=\"MSD\" title=\"MSD/EBI\" #{logo_attr} height=\"25\"><\/a>"

  line[i-1] =line[i-1]+ "\n"

  return
end


def add_inter_pro_link_logo(*params)

  i = params[0]
  href = "http:\/\/www.ebi.ac.uk/interpro/entry/"
  line = params[1]
  link_attr = params[2]
  logo_attr = params[3]
  if line[i].sub!(/InterPro:(\s+)(\S+)/, "InterPro:#{$1}<a href=\"#{href}#{$2}\" target=\"_blank\">#{$2}<\/a>")
    line[i-1].chomp!
    line[i-1]=line[i-1]+ "<a href=\"#{href}#{$2}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_InterPro.jpg\" alt=\"InterPro\" title=\"InterPro\" #{logo_attr} height=\"20\" ><\/a>\n"
    @cite_ipro=1
  end
end

def add_pubmed_logo(*params)
  i = params[0]
  searchstring = params[1]
  line = params[2]
  link_attr = params[3]
  logo_attr = params[4]
  line[i-1].chomp!
  href="http:\/\/www.ncbi.nlm.nih.gov\/entrez\/query.fcgi?CMD=search&db=pubmed&term=#{searchstring}";
  line[i-1] =line[i-1]+ "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_pubmed.jpg\" alt=\"PubMed\" title=\"PubMed\" #{logo_attr} height=\"20\"><\/a>\n";
  return
end

def break_lines(s, width, space)
  chrs = s.unpack('C*')
  lastchr = width
  col = 0
  chrs.each_index do |a|
    if chrs.fetch(a)==32 || chrs.fetch(a) ==124 || chrs.fetch(a) == 125 || chrs.fetch(a) == 93
      lastchr = a
    end  #end if
    col=col +1
    if col>width
      chrs[lastchr]=10
      col = 0
      lastchr =lastchr+width
    end # end if
  end #end each
  s = chrs.pack('C*')
  s.gsub!(/\n\s*(\S)/, "\n#{space}#{$1}")
  return  s

end #end method

def insert_array(array, offset,  array2)
  array2.reverse!
  array2.each do |x|
    array.insert(offset, x)
  end
end

def wrap(s, width,space)
  width = width
  w = width
  i = 0
  
  while width  <=  s.size
    if s[width,1] =~ /\s/
      s[width,1]= "\n"
      s.insert(width+1,space)
      width = width+w
    else
      i = width
      while i > (width-w)
        if s[i,1] =~ /\s/
          s[i,1] = "\n"
          s.insert(i+1,space) 
          width = width+w
          break
        end
        i= i-1
      end
    end
   end
  return s
 end

 def export
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end






end #end class


