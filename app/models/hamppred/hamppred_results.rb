class HamppredJob  < Job
   
     attr_reader :resultsa  , :hallo
  
   
 
  def before_results(controller_params = nil )
	  @resultsa = Array.new
	  @resultsa.push("Hello")
	  @hallo ="hallo"
	  options = ""
	  program = "results"
	  coloring = "onlySS"
	  hhcluster ="false"
	  makemodel ="false"
	  ARGV.each do |a|
		  options += a
	  end
	  if options.subs(/program=(\S*)/,'')
		  program = $1
	  end
	  if options.subs(/coloring=(\S*)/, '')
		  program = $1
	  end
	  if options.subs(/hhcluster=(\S*)/,'')
		  program = $1
	  end
	  if  options.subs(/makemodel=(\S*)/, '')
	  end
	  if options !~/^\s*$/
		 logger.debug("ERROR: UNKNOWN OPTIONS!\n#{options}");	
	  end
	  
	  
          jobDir = job_dir #"/cluster/toolkit/production/tmp/production/502"
	  jobDirRel = url_for_job_dir
	  jobid = ARGV[0]
	  basename= jobDir+"/"+jobid
	  m; #checkbox index
	  maxlinelen=115
	  space_for_checkbox="  "
	  # Read hhr file
	  
	  resfile = File.join(job_dir, jobid + ".hhr")
	  raise("ERROR with resultfile!") if !File.readable?(resfile)|| !File.exists?(resfile) || File.zero?(resfile)
	  results = File.open(resfile, "r")
	  line = results.readlines  
	  
	  
	  # Read parameters from hhsearch call and format query line and parameter line
	  i =0;
	  query = ""
	  len = "?"
	  nseqs = "?"
	  neff = "?"
	  command=""
	  commandrealign =""
	  queryline;
	  paramline ="";
	
	line.each do  |a| 
		 chomp a 
		 if       a =~/^Query \s+ (\S+)/   
			 query = $1 
		elsif  a =~/^Match.columns\s+(\d)/ 
			len = $1
		elsif  a=~ /^No.of.seqs\s+(\d+)/  
			nSseqs = $1
		elsif  a=~ /^Neff\s+(\S+)/ 
			neff = $1
                elsif  a=~ /^Command.*hhsearch/  
			command = a
		elsif  a=~ /^Command.*hhrealign/  
			commandrealign = a
		elsif  a=~/^\s*$/ 
			line.last
		end 
	end #end each# If list of PDB codes is given, link them to NCBIs MMDB
	
	
	if    -e(jobDir+"/sequence_file" )	
	      # Read sequence file
	       seqfile = File.join(job_dir, "/sequence_file")
	       raise("ERROR with sequencefile!") if !File.readable?(seqfile) || !File.exists?(seqfile) || File.zero?(seqfile)
	      seq = File.open(seqfile, "r")
	    
	  
	      queryseqs = seq.readlines
	      queryseq = queryseqs.join
		queryseq.gsub(/\W|\d|\s|_/,'')
		i
	     queryseq.sub(/^(\S{10}).*(\S{10})$/ , $1...$2) 
	      
	      # Format query name line
	      queryline = "<b>Query </b> #{query} (seq = #{queryseq} Len = #{len} Neff = #{neff}  Nseqs = #{nseqs})"
	      
	else
		queryline = "<b> Query </b> #{query} (Len = #{len} Neff = #{neff} Nseqs = #{nseqs})";
	end #end if
	 
	 # Format parameter line
	 paramline = "<b>Parameters </b> "
	 command =~ /\s-ssm(\d+)\s/
	 
	 if	$1==0
		paramline+="score SS:no "
	elsif  $1==2
		paramline+="score SS:yes "
	elsif  $1==4 
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
	
	if commandrealign != nil
		command = commandrealign
	end #end if
	
	if command =~ /\s-realign/ || command=~/\s-map/
		paramline+="realign with MAP:yes "
		if command =~/\s-mapt (\S+)/
			paramline+= "MAP threshold =#{$1} "
		end
	elsif command =~/\-norealign/
		paramline +="realign with MAP:no "
	else 
		paramline += "realign with MAP:? "
	end # end  if
	
	# Introduce line breaks when necessary
	http://searc
	break_lines(queryline,maxlinelen+7, "       ")
	break_lines(paramline,maxlinelen+7, "       ")
	
	
	
	###############################################################
	# Reformat HHpred output 
	
	# Make array with description of matches, to be used as  html mouse-over titles
	
	
	descr;
	line.each_index do  |a| 
		if line.fetch(a) =~/^No(\d+)/
			m = $1
			if line.fetch(a+1) =~ /^>\S+\s+(.*)/
				descr[m] = $1
				descr[m].gsub(/\"\"\\<>/, '')
			end
		end
	end  #end each
	
	
	#Go to first empty line
	
	while  line[i]!~/^\s*$/
		i+=1
	end
	
	while  line[i]!~/s*$/
		i+=1
	end
	ifirst = i
	
	#Title line from summary hit list? 
	cutres = 0
	if line[i] =~ /^\s*No\s+(\S+)\s+(\S+)\s+/
			line[i].sub(/(.*)/,space_for_checkbox+$1)
			line[i] =~/^(.*)Prob/
			cutres= $1.length
	end
		
	line[i+1] =~ /.{#{cutres}}(.{5})/
	prob = $1
	
	#Does the query have a structure or structural model?
	querypdb = "" # PDB structure file or query
	if -e(basename+".pdb")
		#Query has a structureal model prepared by user (MODELLER)
		querypdb = basename+".pdb"
	
	elsif  line[dirs.last] =~/^Query:\s+[defgh]\d[a-z0-9]{3}[a-z0-9]_\.][a-z0-9_]\s+[a-z]\.\d+\.\d+\.\d+\s+/
		#Query is SCOP sequence
		dirs= Dir.glob(DATABASES+"/hhcluster/new_dbs/scop70*")
		querypdb = dirs[dirs.length-1]+"/query.pdb" 
		if !-e(querypdb).results
			lo.resultsgger.debug("WARNING in #{$0}: called '#{$BIOPROGS}/hhpred/makepdbfile.pl #{basename}.a3m &> /dev/null' to generate PDB file for SCOP query sequence $query");
			querypdb = basename+".pdb" 
		end
		if !-e(querypdb)
			logger.debug("WARNING in #{$0}: Could not find pdb file for SCOP sequence #{query}"); 
			querypdb=""
		end
	elsif  query =~/^(\d[a-z0-9]{3})(A-Za-z0-9])?_\d+$/ || query =~ /^(\d[A-Za-z0-9]{3})()$/  || query =~/^(\d[A-Za-z0-9]{3})_([A-Za-z0-9])$/
		# Query isDALI or PDB sequence
		pdbid =  $1.downcase
		chain = $2.upcase
		if chain  != ""
			chain = "_"+chain
		end
		dirs=  Dir.glob(DATABASES+"/hhpred/new_dbs/pdb70*")
		querypdb = basename+".pdb"
		if !-e("#{dirs[dirs.last]}/#{pdbid}#{chain}.pdb")
			logger.debug("WARNING in #{$0}: Could not find pdb file for sequence #{query}. Interpreted as pdbcore=#{pdbid}, chain=#{chain}"); 
			querypdb=""
		else
			system("cp"+dirs[dir.last]+"/"+pdbid+chain+".pdb"+" "+querypdb)
		end
	end
	
	# Print some comments and tips
	if querypdb != ""
		@resultsa.push("<br><font color='brown'><b>View 3D structural alignments between your query and template structures by clicking on the <img src=\"#{$DOC_ROOTURL}/images/hhpred/logo_QT_struct.png\" height=\"15\" align=\"middle\" /> buttons above the alignments.</b></font>")
	end
	if(Nseqs<=5&& prob < 60)
#		@resultsa.push("<font color='red'> <b>Note</b>: Your query alignment consists of only #{Nseqs} sequence")
#		if Nseqs !=1
#		@resultsa.push("s")
#		end
#		@resultsa.push("(at 90&#37 maximum pairwise sequence identity). You may be able to improve sensitivity vastly")
#		@resultsa.push("by using our intermediate HMM searching method 'HHsenser' to enlarge the query alignment: ")
#		@resultsa.push("Just press <b>\"Resubmit using HHsenser</b>\" above. ")
#		@resultsa.push("<br>Alternatively, you may try to build a bigger query alignment <i>by hand</i>: ")
#		@resultsa.push("Run PSI-BLAST with your query and decide individually for each database match with E-value ")
#		@resultsa.push("< 1...10 whether to include it in the alignment. If you can't decide whether to include ")
#		@resultsa.push("a candidate sequence, you may use a very powerful technique called ")
#		@resultsa.push("i>backvalidation</i> [Koretke <i>et al.</i> 2001]: ")
#		@resultsa.push("Start PSI-BLAST with the candidate sequence and check whether you can find your original ")
#		@resultsa.push("query sequence or any other already accepted sequence with sufficient E-value (e.g. < 0.01) ")
#		@resultsa.push("Repeat PSI-BLAST iterations until you have at least 10 sequences (if possible). ")
#		@resultsa.push("Use this seed alignment to jump-start HHpred.</font><br><br>")
	elsif  prob>40 && prob < 90 && rand>0.8
		@resultsa.push("<br><font color='blue'>\n<b>Need help to find out how to validate your hits? Click <a href=\"\#\" title=\"HHpred FAQs\" onclick=\"openHelpWindow('help_faq','correct match');\">here.</a></b>\n</font>")
	elsif rand > 0.8
		@resultsa.push("<br><font color='darkgreen'> <b>Note: Corrupted alignments are the most common source of high-scoring false positives. Check the query alignment by clicking </font><font color='black'>Show Query Alignment</font><font color='darkgreen'> above. To check the template alignments use the <img src=\"$DOC_ROOTURL/images/hhpred/logo_template_ali.png\" height=\"15\" align=\"middle\" /> logos.</b></font>")
	elsif  rand > 0.8
		@resultsa.push("<br><font color='green'> <b>Need help on how to interpret your results? Click <a href=\"\#\" title=\"HHpred Results\" onclick=\"openHelpWindow('help_results');\">here.</a></b></font>")
	end
	
	##############################################################################
	# if requested, print hhviz output 
	

	if -e("#{basename}.html" && program != "align" && program != "createmodel")
		raise("Cannot open #{basename}.html!")  if !File.readable?("#{basename}.html")|| !File.exists?("#{basename}.html") || File.zero?("#{basename}.html")
		hhviz =  File.open("#{basename}.html", "r")
		lines = hhviz.readlines
		lines.each {|a| @resultsa.push( a)}
	end
	@resultsa.push("</div>\n")
	
	#################################################################################
	# profile_logos
			
	if program == "profile_logos" && !-e("#{basename}_1.png")
		system("tar -xzf #{basename}.tar.gz -C #{jobDir} &> /dev/null")
		logger.debug("tar -xzf #{basename}.tar.gz -C #{jobDir} &> /dev/null")
	elsif program == "results"
		###################################################################################################
		# Display links for prediction of coiled coils, TM alpha-helical domains, or TM beta barrels?
		coiled_coil = 0 # coiled coil found?
		tmbb = 0 #transmembrane beta barrel daomain found?
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
			raise("Cannot open #{basename}.a3m") if !File.readable("#{basename}.a3m") || !File.exists?("#{basename}.a3m") || File.zero?("#{basename}.a3m")
			a3mfile = File.open("#{basename}.a3m", "r")
			a3m = a3mfile.readlines
			seq =""
			a3m.each do |a|
				if seq =~/^>ss/ || seq =~/^>aa/
					next
				end
				seq = a.chomp
				break
			end
			if coiled_coil != 0
				@resultsa.push("<div clas=\"row\">\n")
				url = url_for(controller => "hhpred", action => "run", jobid => jobid)+"?jobaction=hhpred_coils&forward_controller=pcoils&forward_action=forward"
				@resultsa.push("<input type=\"button\" title=\"Run coiled-coil prediction\" value=\"Run PCOILS\" onclick=\"location.href='#{url}'\">\n")
				@resultsa.push("<font color=\"purple\">&nbsp;&nbsp;&nbsp;HHpred has detected hits to coiled coil-containing proteins. Press button to run PCOILS prediction on your query</font>\n")
				@resultsa.push("</div>\n")
				
			end
		end
	 # Display links for prediction of coiled coils, TM alpha-helical domains, or TM beta barrels?
	###################################################################################################

	end
	
	@resultsa.push("<pre> \n #{queryline} \n\n #{paramline} \n\n\n")
	
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
		elsif line[b]=/^\s*$/
			break
		end
		
		if line[b] =~ /^\s*(\d+)\s+(\S+)\s+(\S+)\s+/
			m = $1
			template = $2
			family = $3
			line[b].sub(/#{m}/,"<a href =\##{m}>#{m}<\/a>")
		
		
			# Pfam-A identifier? (PF01234)
			if template =~/^PF\d{5}/ || template =~/^pfam\d{5}/
				pfamid = template
				pfamid.sub(/^pfam/, "PF")
				#link to PFAM domain family?acc=
				line[b].sub(/#{template}/, "<a href=\"http:\/\/pfam.xfam.org\/family?acc=#{pfamid}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
		
			# PRODOM identifier? (PD012345)
			elsif  template =~ /^PD\d{6}/
				# link to PRODOM domain
				line[b] .sub(/#{template}/, "<a href=\"http:\/\/prodes.toulouse.inra.fr\/prodom\/current\/cgi-bin\/request.pl?question=DBEN&query=#{template}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
		
			# SMART identifier? (smart00382)
			elsif template =~/^SM\d{5}/ || template =~/^smart\d{5}/
				smartid = template
				smartid.sub(/^smart/, "SM")
				line[b] =~ /(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s*-(\d+)\s+\d+-\d+\s*\(\d+\)\s*$/
				evalue = $1
				first = $2
				last = $3
				evalue[smartid] = evalue
				first[smartid] =  first
				last[smartid] =  last
			 
				# Link to  SMART domain description
				line[b] .sub(/#{template}/, "<a href=\"http:\/\/dylan.embl-heidelberg.de\/smart\/do_annotation.pl?DOMAIN=#{smartid}&START=#{first}&END=#{last}&E_VALUE=#{evalue}&TYPE=SMART\" target=\"_blank\" title=\"#{descr[m]}\">#{template} <\/a>")
		
			# Other CDD identifier? (COG0001, KOG0001, cd00001)
			elsif template =~/^COG\d{4}/ || template =~/^KOG\d{4}/ || template =~/^cd\d{5}/
				# Link to CDD at NCBI
				line[b] .sub(/#{template}/, "<a href=\"http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
				
			# PANTHER identifier? (PTHR15545)
			elsif template =~/^PTHR\d{5}/ 
				line[b].sub(/#{template}/, "<a href=\"http:\/\/www.pantherdb.org\/panther\/family.do?clsAccession=#{template}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
			
			# TIGRFAMs identifier? (TIGR01243)
			elsif template =~/^TIGR\d{5}/
				# LINK to TIGRFAMs
				line[b].sub(/#{template}/, "<a href=\"http:\/\/www.tigr.org\/tigr-scripts\/CMR2\/hmm_report.spl?acc=#{template}&user=access&password=access\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
			
			#l PIRSF identifier? (PIRSF015873)
			elsif template =~/^PIR(SF\d{6})/
				# Link to PIRSF
				family = $1
				line[b].sub(/#{template}/, "<a href=\"http:\/\/pir.georgetown.edu\/cgi-bin\/ipcSF?id=#{family}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
				
			# SUPFAM identifier? (SUPFAM0022216)
			elsif  template =~ /^SUPFAM\d+$/ 
				line[b] =~ /SUPFAM(\d+)\s+(\S+)/
				template = $1
				family = $2
				
				# Link to SUPERFAMILY
				
				href = "http:\/\/supfam.mrc-lmb.cam.ac.uk\/SUPERFAMILY\/cgi-bin\/model.cgi?model=#{template}";
				line[b].sub(/SUPFAM#{template}/, "<a href=\"#{href}\" target=\"_blank\">SUPFAM#{template}<\/a>")
				
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
				line[b].sub(/#{family}/, "<a href=\"http:\/\/www.cathdb.info\/cathnode\/#{c}.#{a}.#{t}.#{h}\" target=\"_blank\">#{family}<\/a>")
		
				# Link to CATH at protein level
				template=~/^(\S\S)/ # first two letters, e.g. 1c
				c=$1
				line[b].sub(/#{template}/, "<a href=\"http:\/\/www.cathdb.info\/\/domain\/#{template}\" target=\"_blank\">#{template}<\/a>")
		
			# SCOP identifier? (d3lkfa_,d3pmga1,d3pga1_,d3grs_3,g1m26.1,d1n7daa)
			elsif template =~ /^[defgh](\d[a-z0-9]{3})([a-z0-9_\.])[a-z0-9_]$/ 
				pdbcode   = $1
				ucpdbcode = $1.upcase
				pdbc      = $1
				if $2 != "_" 
					pdbc+="%20#{$2}" 
				end
				
				# Link to SCOP at family level
				if  template =~ /^[eu]/ 
					line[b] .sub(/#{family}/, "<a href=\"http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/search.cgi?sid=#{template}&lev=fa\" target=\"_blank\">#{family}<\/a>")
				else 
					line[b].sub(/#{family}/, "<a href=\"http:\/\/www.mrc-lmb.cam.ac.uk\/agm\/cgi-bin\/find2.cgi?search_text=#{pdbc}&index=pox-SCOP_1_72\" target=\"_blank\">#{family}<\/a>")
				end
			
				# Link to NCBI MMDB
				line[b].sub(/#{template}/,"<a href=\"http:\/\/www.ncbi.nlm.nih.gov\/entrez\/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{ucpdbcode}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
		
			# DALI/PDB identifier?  (8fabA_0,1a0i_2)
			elsif  template =~ /^(\d[a-z0-9]{3})([A-Za-z0-9])?_\d+$/
				pdbcode   = $1
				ucpdbcode = $1.upcase
		
			# Link to PDB
				line[b].sub(/#{template}/, "<a href=\"http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
			
		
			# PDB identifier?  (8fab_A,1a0i  )
			elsif template =~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/ 
				pdbcode   = $1
				ucpdbcode = $1.upcase
		
				# Link to PDB
				line[b].sub(/#{template}/, "<a href=\"http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\" title=\"#{descr[m]}\">#{template}<\/a>")
			end
			
			if template !~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/ &&  template !~ /^[defgh](\d[a-z0-9]{3})[a-z0-9_\.][a-z0-9_]$/ 
				createmodel_diabled_checkboxes += "#{checkbox_counter},"
			end
		
			line[b] = "<input style=\"margin: 0px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox#{checkbox_counter}\" id=\"hit_checkbox#{checkbox_counter}\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 0)\"/>#{line[b]}"
		
			checkbox_counter += 1
		end
		
		
		b +=1
	end


	########################################################################################################
	###########################  Alignments  ############################################################### 
	log_attr ="border=\"0\" align=\"middle\""
	 link_attr = "style=\"margin: 5px 10px 10px 10px;\""
	
	b = 0
	
	while b<line.length
		if line[b] =~ /^Done!/
			break
			
		########################################################################################################
		# 'No X' line before each query-target alignment
    
		elsif  line[b]=~/^No\s*(\d+)/ 
			m = $1;
			line[b].sub(/(No\s*$m)/, "<a name = m>$1<\/a>")
			line[b] = space_for_checkbox+line[b];
			
			# print image for hhcluster -> hhpred
			if  hhcluster == "true"
				line[b+1] =~ /^>(\S+)\s+(\S+)\s*([^.;,\[\(\{]*)/
				hhcluster_id = $1;
				line[b].chomp
				line[b] += "<a href=\" #{url_for(controller => "hhcluster", action => "makeHhpred")}?id=#{hhcluster_id}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_HHpred_results.jpg\" alt=\"HHpred Results\" title=\"Show HHpred results\" #{logo_attr} height=\"30\"></a>\n"
			end
			# print image for profile logos
			if  program == "profile_logos"
				line[b].chomp
				if (makemodel == "false") 
					line[b]+= "<a href=\" #{url_for(action => "results", jobid => jobid, anchor => m)}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_alignments.jpg\" alt=\"Alignments\" title=\"show query-template alignments\" #{logo_attr} height=\"30\"></a>\n"
				else 
					line[b]+= "<a href=\" #{url_for(action => "results_makemodel", jobid => jobid, anchor => m)}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_alignments.jpg\" alt=\"Alignments\" title=\"show query-template alignments\" #{logo_attr} height=\"30\"></a>\n\n"
				end
			
			
				mapname="#{jobid}_#{m}"
				mapfile="#{jobDir}/#{mapname}#{map}"
				imgfile="#{jobid}_#{m}#{png}"
				j=b+1;
			
				# Advance to first line of alignment
				while j<line.length && line[j]!~/^\s*$/
					j+=1
				end
			 
				# Insert Image
			
				if -e(mapfile)
					raise("ERROR with mapfile!") if !File.readable?(mapfile)|| !File.exists?(mapfile) || File.zero?(mapfile)
					map = file.open(mapfile, "r")
					line.push(map[j])
					insert_array(line,j,map)
					j += map.length
				else
					line.delete(line[j])
				end
				
				# Delete all lines of alignment up to beginning of next alignment
				j+=1
				while j<line.length && line[j]!~/^No\s*\d+/ 
					line.delete(line[j])
				end
			else
				line[b].chomp
				if makemodel =="false"
					line[b] += "<a href=\"#{url_for(action => "histograms", jobid => jobid, anchor => m)}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_histogram_single.png\" alt=\"Histograms\" title=\"Show histograms\" #{logo_attr} height=\"30\"></a>\n";
				else
					line[b] += "<a href=\"#{url_for(action => "histograms_makemodel", jobid => jobid, anchor => m)}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_histogram_single.png\" alt=\"Histograms\" title=\"Show histograms\" #{logo_attr} height=\"30\"></a>\n\n";
				end
			end
			
			# Add logo for template alignment
			line[b].chomp
			if  makemodel == "false"	
				line[b]+="<a href=\"#{url_for(controller => "hhpred", action => "run", jobid => jobid)}?jobaction=hhpred_showtemplalign&forward_controller=hhpred&forward_action=results_showtemplalign&alformat=fasta&hits=#{m}\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_template_ali.png\" title=\"Show template alignment\" #{logo_attr} /></a>\n"
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
			
			shortname.sub(/\s+The following Pfam-B.*/, "")
			longname.sub(/\s+The following Pfam-B.*/, "")
			if longname.split(/\s+/).length <= 1
				longname+= "[TI]"
			end
			
				break_lines(line[b],maxlinelen,space_for_checkbox) 
			
			# If list of PDB codes is given, link them to NCBIs MMDB
			if line[b].sub(/^(.* PDB:\s*)((\S+[^:]\s+)+)/s,"") 
				left=$1;
				middle=$2;
				middle.sub(/(\S\S\S\S)(\S*)/, "<a href=\"http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{$1}\" target=\"_blank\" title=\"PDB\">#{$1+$2}<\/a>/g; # link to PDB")
				line[b] = left+middle+line[b]
			end
			# Pfam-A identifier? (PF01234)
			if  template=~/^PF\d{5}/ || template=~/^pfam\d{5}/
				template=~ /^(\S*)\.?\S*/
				pfamid = $1
				pfamid.sub(/^pfam/,"PF")
				cite_pfam=1

				# link to Pfam-A domain
				href="http:\/\/pfam.xfam.org\/family?acc=#{pfamid}"
				line[b].sub(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>/g")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_Pfam.jpg\" alt=\"Pfam\" title=\"Pfam\" #{logo_attr} height=\"20\" ></a>\n"
			
				if  template=~/^pfam\d{5}/
					# Link to CDD at NCBI
					href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}";
					line[b-1].chomp
					line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"20\"></a>\n"
				end

					add_inter_pro_link_logo($i);

				if (longname != nil && shortname != nil)
					add_pub_med_logo($i,$longname)
				end
			# PRODOM identifier? (PD012345)
			elsif  template=~/^PD\d{6}/ 
				template=~ /^(\S*)\.?\S*/
				prodomid = $1
				cite_prodom=1
				href="http:\/\/prodes.toulouse.inra.fr\/prodom\/current\/cgi-bin\/request.pl?question=DBEN&query=#{prodomid}"
				# link to PRODOM domain
				line[b] .sub(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_ProDom.jpg\" alt=\"ProDom\" title=\"ProDom\" #{logo_attr} height=\"20\"></a>\n"
		
			# SMART identifier? (smart00382)
			elsif  template=~/^SM\d{5}/ || template=~/^smart\d{5}/
				smartid = template;
				smartid.sub(/^smart/,"SM")
				line[b] =~/^\s*\d+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+.*(\d+)\s*-\s*(\d+)\s*\(\d+\)\s*\d+\s*-\s*\d+\s*\(\d+\)\s*$/
				evalue = evalue[smartid]
				first  = first[smartid]
				last   = last[smartid]
				cite_smart=1

				# Link to SMART domain description
				href="http:\/\/dylan.embl-heidelberg.de\/smart\/do_annotation.pl?DOMAIN=#{smartid}&START=#{first}&END=#{last}&E_VALUE=#{evalue}&TYPE=SMART"
				line[b].sub(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>/")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_SMART.jpg\" alt=\"SMART\" title=\"SMART\" #{logo_attr} height=\"14\"></a>\n";
	
				if  template=~/^smart\d{5}/
					# Link to CDD at NCBI
					href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}"
					line[b-1].chomp
					line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"20\"></a>\n";
				end
	
				if (longname != nil && shortname != nil) 
					add_pub_med_logo(b,longname)
				end
				
			elsif  template=~/^COG\d{4}/
				cite_cog=1
	
				# Link to COGs
				href="http:\/\/www.ncbi.nlm.nih.gov\/COG\/old\/palox.cgi?#{template}";
				line[b].sub(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_COGs.png\" alt=\"COGs\" title=\"COGs\" #{logo_attr} height=\"25\"></a>\n"

				# Link to CDD at NCBI
				href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}"
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"25\"></a>\n"

				if longname != nil  && shortname != nil 
					add_pub_med_logo(b,"#{shortname} #{longname}", line)
				end
			
			elsif  template=~/^KOG\d{4}/ 
				cite_kog=1;

				# Link to KOGs
				href="http:\/\/www.ncbi.nlm.nih.gov/COG/grace/shokog.cgi?#{template}"
				line[b].sub(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_COGs.png\" alt=\"KOGs\" title=\"KOGs\" #{logo_attr} height=\"25\"></a>\n"

				# Link to CDD at NCBI
				href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}";
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"25\"></a>\n"

				if longname != nil && shortname != nil
					add_pub_med_logo(b,"#{shortname} #{longname}", line)
				end
	
			# Other CDD identifier? (KOG0001, cd00001)
			elsif  template=~/^KOG\d{4}/ || template=~/^cd\d{5}/ || template=~/^LOAD\d{4}/
				cite_cdd=1;

				# Link to CDD at NCBI
				href="http:\/\/www.ncbi.nlm.nih.gov\/Structure\/cdd\/cddsrv.cgi?uid=#{template}"
				line[b].sub(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_CDD.jpg\" alt=\"CDD\" title=\"CDD\" #{logo_attr} height=\"20\"></a>\n"

				if longname != nil && shortname != nil
					add_pub_med_logo(b,"#{shortname} #{longname}")
				end
	
			# PANTHER identifier? (PTHR15545)
			elsif  template=~/^PTHR\d{5}/
				cite_panther=1;
	
				# Link to PANTHER
				href="http:\/\/www.pantherdb.org\/panther\/family.do?clsAccession=#{template}"
				line[b].sub(/#{template}/, "<a href=\"href\" target=\"_blank\">template<\/a>")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_panther.gif\" alt=\"PANTHER\" title=\"PANTHER\" #{logo_attr} height=\"25\"></a>\n"

				add_inter_pro_link_logo(b, line)
	
				if  longname !=  nil && shortname != nil
					add_pub_med_logo(b,"#{shortname} #{longname}",line)
				end
		
			# TIGRFAMs identifier? (TIGR01243)
			elsif  template=~/^TIGR\d{5}/
				cite_tigrfam=1;

				# Link to TIGRFAMs
				href="http:\/\/www.tigr.org\/tigr-scripts\/CMR2\/hmm_report.spl?acc=#{template}&user=access&password=access"
				line[b].sub(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_tigr.gif\" alt=\"TIGRFAM\" title=\"TIGRFAM\" #{logo_attr} height=\"20\"></a>\n"
	
				add_inter_pro_link_logo(b, line)

				if longname !=  nil && shortname != nil
					add_pub_med_logo(b,"#{shortname} #{longname}", line)
				end
		
			# PIRSF identifier? (PIRSF015873)
			elsif  template=~/^PIR(SF\d{6})/
				family=$1;
				cite_pirsf=1;

				# Link to PIRSF
				href="http:\/\/pir.georgetown.edu\/cgi-bin\/ipcSF?id=#{family}";
				line[b].sub(/#{template}/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_pirsf.png\" alt=\"PIRSF\" title=\"PIRSF\" #{logo_attr} height=\"20\"></a>\n"

				add_inter_pro_link_logo(b, line)

				if longname !=  nil  &&  shortname != nil 
					add_pub_med_logo(b,"#{shortname} #{longname}", line)
				end
			
			# SUPFAM identifier? (SUPFAM0022216)
			elsif  template =~ /^SUPFAM\d+$/ 
				# SUPFAM0022216 b.29.1 Concanavalin A-like lectins/glucanases (49899) SCOP seed sequence: d1m4wa_.
				line[b] =~ /SUPFAM(\d+)\s+(\S+).*\((\d+)\) SCOP\s+seed\s+sequence:\s+(\w+)/
				template = $1
				family  = $2
				supfam_famid=$3
				scopid   = $4
				scopid=~/^[a-z](\d\S\S\S)/
				pdbcode   = $1
				ucpdbcode = uc($1)
				cite_supfam=1
	   
				# Link to SUPERFAMILY
				href = "http:\/\/supfam.mrc-lmb.cam.ac.uk\/SUPERFAMILY\/cgi-bin\/model.cgi?model=#{template}"
				line[b].sub(/SUPFAM#{template}/, "<a href=\$href\" target=\"_blank\">SUPFAM template<\/a>")
	
				# Link to SUPERFAMILY at family level
				href = "http:\/\/supfam.mrc-lmb.cam.ac.uk\/SUPERFAMILY\/cgi-bin\/scop.cgi?sunid=#{supfam_famid}"
				line[b].sub(/\(#{supfam_famid}\)/, "(<a href=\"#{href}\" target=\"_blank\">#{supfam_famid}<\/a>)")

				# Logo to SUPERFAMILY at family level
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_supfam.gif\" alt=\"Superfamily\" title=\"Superfamily\" #{logo_attr} height=\"30\"></a>"

				# Link/logo to SCOP 
				href="http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/search.cgi?sid=#{scopid}"
				line[b-1].chomp
				line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_SCOP.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>"

				add_inter_pro_link_logo(b,line)
				add_structure_database_logos(b,template,pdbcode, line)
				add_pub_med_logo(b,ucpdbcode, line)
	
			# CATH identifier? (1cz4A1)
			elsif  template =~ /^(\d[a-z0-9]{3})[A-Za-z0-9][0-9]$/ 
				cite_CATH=1

				pdbcode   = $1
				ucpdbcode = $1.upcase
	    
				# Link to CATH at family level
				family=~/^(\d+)\.(\d+)\.(\d+)\.(\d+)/
				c=$1
				a=$2
				t=$3	
				h=$4;
				href="http:\/\/cathwww.biochem.ucl.ac.uk\/latest\/class #{c}\/#{a}\/#{t}\/#{h}\/index.html"
				line[b].sub(/$template/, "<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
				line[b-1].chomp
				line[b-1] += "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_cath.gif\" alt=\"CATH/Gene3D\" title=\"CATH/Gene3D\" #{logo_attr} height=\"20\"></a>\n";

				# Link to PDB
				href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
				line[b] .sub(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
	    
				add_inter_pro_link_logo(b, line);
				add_structure_database_logos(b,template,pdbcode,line)
				add_pub_med_logo(b,ucpdbcode, line)
			
				###############################Ab hier $ in Strings checken
			
			# SCOP identifier? (d3lkfa_,d3pmga1,d3pga1_,d3grs_3,g1m26.1,d1n7daa)
			elsif  template =~ /^[defgh](\d[a-z0-9]{3})([a-z0-9_\.])[a-z0-9_]$/ 
				pdbcode   = $1
				ucpdbcode = $1.upcase
				templpdb;
				pdbc      = $1
				if $2 != "_"
					pdbc+="%20#{$2}"
				end
				cite_scop=1
	    
				# Is query AND template structure known?
				if  querypdb != ""
					dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/scop*")
					templpdb=dirs[dirs.length-1]+"/#{template}.pdb"
					if !-e( templpdb) 
						dirs=Dir.glob("#{$DATABASES}/hhcluster/scop25*")
						templpdb=dirs[dirs.length-1]+"/#{template}.pdb"
					end
					
					if -e(templpdb) 
						line[b-1].chomp
						line[b-1]+="<a href=\"#\" onclick=\"var win = window.open('#{url_for(controller => "hhpred", action => "run", job => "hh3d_querytempl")}?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&querypdb=#{querypdb}&forward_controller=hhpred&forward_action=results_hh3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"$DOC_ROOTURL/images/hhpred/logo_QT_struct.png\" title=\"Show query-template 3D superposition\" #{logo_attr} /></a>\n"
					
					else 
						logger.debug("WARNING in #{$0}: Could not find pdb file for SCOP sequence #{template}")
					end
				else
			
					dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/scop*")
					templpdb=dirs[dirs.length-1]+"/#{template}.pdb"
					if !-e(templpdb) 
						dirs=Dir.glob("#{DATABASES}/hhcluster/scop25*") 
						templpdb=dirs[dirs.length-1]+"/#{template}.pdb"
					end
					
					if -e(templpdb) 
						line[b-1]
					line[b-1]+="<a href=\"#\" onclick=\"var win = window.open('#{url_for(controller => "hhpred", action => "run", job => "hh3d_templ")}?parent=#{jobid}&hit=$m&templpdb=#{templpdb}&forward_controller=hhpred&forward_action=results_hh3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_T_struct.png\" title=\"Show template 3D structure\" #{logo_attr} /></a>\n"
					
					else 
						logger.debug("WARNING in $0: Could not find pdb file for SCOP sequence $template")
					end
				end
				# Link to SCOP 
				if  template =~ /^[eu]/
					href="http:\/\/www.mrc-lmb.cam.ac.uk/agm\/cgi-bin\/find2.cgi?search_text=#{pdbc}&index=pox-SCOP_1_72"
			
				else
					href="http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/search.cgi?sid=#{template}"
			
					line[b].sub(/#{shortname}/,"<a href=\"#{href}\" target=\"_blank\">#{shortname}<\/a>")
					line[b-1].chomp
					line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_SCOP.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>\n"
	    
					# Link to PDB
					href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
					line[b] .sub(/#{template}/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")

					add_structure_database_logos(i,template,pdbcode, line);
					add_pub_med_logo(i,ucpdbcode, line)
				end
	
				# DALI/PDB identifier?  (8fabA_0,1a0i_2)
			elsif  template =~ /^(\d[a-z0-9]{3})([A-Za-z0-9])?_\d+$/ 
				pdbcode   = $1
				ucpdbcode = $1.upcase
				templpdb;
				cite_pdb=1
	    
				# Is query AND template structure known?
				if querypdb != ""
					dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*");
					templpdb=dirs[dirs.length-1]+"/#{template}.pdb";
					if -e(templpdb) 
						line[b-1].chomp
						line[b-1]+="<a href=\"#\" onclick=\"var win = window.open('#{url_for(controller => "hhpred", action => "run", job => "hh3d_querytempl")}?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&querypdb=#{querypdb}&forward_controller=hhpred&forward_action=results_hh3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png\" title=\"Show query-template 3D superposition\" #{logo_attr} /></a>\n"		    
				
					else logger.debug("WARNING in $0: Could not find pdb file for PDB sequence $template")
			
					end
				else 
					dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*")
					templpdb=dirs[dirs.length-1]+"/#{template}.pdb";
					if -e(templpdb) 
						line[b-1].chomp
						line[b-1]+="<a href=\"#\" onclick=\"var win = window.open('#{url_for(controller => "hhpred", action => "run", job => "hh3d_templ")}?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&forward_controller=hhpred&forward_action=results_hh3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_T_struct.png\" title=\"Show template 3D structure\" #{logo_attr} /></a>\n"
				 
					else 
					logger.debug("WARNING in #{$0}: Could not find pdb file for PDB sequence $template")
					end
				end

				# Link to DALI
				line[b].sub(/$shortname/,"<a href=\"http:\/\/www.bioinfo.biocenter.helsinki.fi:8080\/cgi-bin\/daliquery.cgi?find=#{template}\" target=\"_blank\">#{shortname}<\/a>")
	    
				# Link to SCOP family
				if line[b]=~/SCOP:.*\s+([a-z]\.\d+\.\d+\.\d+)\s+/
					line[b].gsub(/([a-z]\.\d+\.\d+\.\d+)/,"<a href=\"http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/search.cgi?key=#{$1}\" target=\"_blank\">#{$1}<\/a>")
					# Link to SCOP with pdb code  
					href="http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/pdb.cgi?pdb=#{pdbcode}"
					line[b-1].chomp
					line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_SCOP.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>\n"
				end
	    
				# Link to PDB
				href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
				line[b] .sub(/$template/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
	
				add_structure_database_logos(b,template,pdbcode, line)
				add_pub_med_logo(b,ucpdbcode, line)
		
	
	
			# PDB identifier?  (8fab_A,1a0i  )
			elsif template =~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/ 
				pdbcode   = $1
				ucpdbcode = $1.upcase
				templpdb
				cite_pdb=1
	    
				# Is query AND template structure known?
				if querypdb != ""
					dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*")
					templpdb=dirs[dirs.length-1]+"/#{template}.pdb";
					if -e(templpdb) 
						line[b-1].chomp
						line[b-1]+="<a href=\"#\" onclick=\"var win = window.open('#{url_for(controller => "hhpred", action => "run", job => "hh3d_querytempl")}?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&querypdb=#{querypdb}&forward_controller=hhpred&forward_action=results_hh3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png\" title=\"Show query-template 3D superposition\" #{logo_attr} /></a>\n"
					else
						logger.debug("WARNING in #{0}: Could not find pdb file for PDB sequence #{template}")
						logger.debug("Path: #{templpdb}")
					end
				else 
					dirs=Dir.glob("#{DATABASES}/hhpred/new_dbs/pdb*")
					templpdb=dirs[dirs.length-1]+"/#{template}.pdb"
					if -e(templpdb) 
						line[b-1].chomp
						line[b-1]+="<a href=\"#\" onclick=\"var win = window.open('#{url_for(controller => "hhpred", action => "run", job => "hh3d_templ")}?parent=#{jobid}&hit=#{m}&templpdb=#{templpdb}&forward_controller=hhpred&forward_action=results_hh3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" #{link_attr} ><img src=\"$DOC_ROOTURL/images/hhpred/logo_T_struct.png\" title=\"Show template 3D structure\" #{logo_attr} /></a>\n"
	
					else 
						logger.debug("WARNING in #{$0}: Could not find pdb file for PDB sequence #{template}")
					end
				end
	    
				# Link to PDB
				href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}"
				line[b].sub(/$template/,"<a href=\"#{href}\" target=\"_blank\">#{template}<\/a>")
	    
				# Link to SCOP family
				if line[b]=~/SCOP:.*\s+([a-z]\.\d+\.\d+\.\d+)\s+/
					line[b].gsub(/([a-z]\.\d+\.\d+\.\d+)/,"<a href=\"http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/search.cgi?key=#{$1}\" target=\"_blank\">#{$1}<\/a>")
					# Link to SCOP with pdb code  
					href="http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/pdb.cgi?pdb=#{pdbcode}"
					line[b-1].chomp
					line[b-1]+= "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_SCOP.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>\n"
				end
		
				add_structure_database_logos(b,template,pdbcode, line)
				add_pub_med_logo(b,ucpdbcode, line)
			
			end	
			
			line[b] = "<input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox$checkbox_counter\" id=\"hit_checkbox$checkbox_counter\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 1)\"/>#{line[$i]}"

			checkbox_counter+=1
		
		elsif line[b] =~ /^>\S+/

			line[b] = "<input style=\"margin: 0px 5px; padding: 0px;\" type=\"checkbox\" name=\"hit_checkbox$checkbox_counter\" id=\"hit_checkbox$checkbox_counter\" value=\"#{m}\" onclick=\"javascript:change(#{m}, 1)\"/>#{$line[$i]}"

		checkbox_counter+=1
    
		 
    
		########################################################################################################
		# All other lines

		else 
			if  line[b]!~/^\s*$/
				line[b] = space_for_checkbox+line[b]
			end
		end
		
		########################################################################################################
		# Color alignments 


		# Found a ss_dssp or ss_pred line?
		if  line[b] =~ /\s*(Q|T) ss_(dssp|pred)\s+(\S+)/
			seq     = $3
			old_seq = $3
			if  coloring == "onlySS"
				seq.gsub(/(H+)/,"<span style=\"color: #D00000;\">#{$1}<\/span>")
				seq.gsub(/(E+)/,"<span style=\"color: #0000D0;\">#{$1}<\/span>")
				line[b].sub(/#{$old_seq}/,seq)
			 
			elsif  coloring == "letters"
				seq.gsub(/(H+)/,"<span style=\"color: #D00000;\">#{$1}<\/span>")
				seq.gsub(/(E+)/,"<span style=\"color: #0000D0;\">#{$1}<\/span>")
				line[b].sub(/#{$old_seq}/,seq)
			 
			elsif  coloring == "background"
				seq.gsub(/(H+)/,"<span style=\"background-color: #ffb0b0;\">#{$1}<\/span>")
				seq.gsub(/(E+)/,"<span style=\"background-color: #b0b0ff;\">#{$1}<\/span>")
				line[b].sub(/#{$old_seq}/,seq)
			end
		

		# Found a consensus line?
		elsif  line[b] =~ /\s*(Q|T) Cons(-\S+|ensus)\s+\d+\s+(\S+)/ 
			seq     = $3
			old_seq = $3
			if coloring == "onlySS"
				seq.gsub(/([A-Za-z]+)/,$1)
				line[b].sub(/#{old_seq}/,seq)
			
			elsif coloring == "letters"
				seq.gsub(/([A-Za-z]+)/,$1)
				seq.gsub(/([~.-]+)/,"<span style=\"color: #808080;\">#{$1}<\/span>")
				line[b].sub(/#{old_seq}/,seq)
			
			elsif coloring == "background"
				seq.gsub(/([A-Za-z]+)/,$1)
				seq.gsub(/([~.-]+)/,"<span style=\"color: #808080;\">#{$1}<\/span>")
				line[b].sub(/#{old_seq}/,seq)
			end
		

		# Found a sequence line?
		elsif line[b] =~ /\s*(Q|T) (\S+)\s+\d+\s+(\S+)/ 
			seq     = $3
			old_seq = $3
			if coloring == "letters"
				seq.gsub(/([a-z.-]+)/,"<span style=\"color: #808080;\">#{$1}<\/span>")
				seq.gsub(/([WYF]+)/,"<span style=\"color: #00a000;\">#{$1}<\/span>")
				seq.gsub(/([LIVM]+)/,"<span style=\"color: #00ff00;\">#{$1}<\/span>")
				seq .gsub(/([AST]+)/,"<span style=\"color: #404040;\">#{$1}<\/span>")
				seq.gsub(/([KR]+)/,"<span style=\"color: red;\">#{$1}<\/span>")
				seq.gsub(/([DE]+)/,"<span style=\"color: blue;\">#{$1}<\/span>")
				seq.gsub(/([QN]+)/,"<span style=\"color: #d000a0;\">#{$1}<\/span>")
				seq.gsub(/(H+)/,"<span style=\"color: #E06000;\">#{$1}<\/span>")
				seq.gsub(/(C+)/,"<span style=\"color: #A08000;\">#{$1}<\/span>")
				seq.gsub(/(P+)/,"<span style=\"color: #000000;\">#{$1}<\/span>")
				seq.gsub(/(G+)/,"<span style=\"color: #404040;\">#{$1}<\/span>")
				line[b].sub(/#{old_seq}/,seq)
			
			elsif	coloring == "background"
				seq.gsub(/([WYF]+)/,"<span style=\"background-color: #00c000;\">#{$1}<\/span>")
				seq.gsub(/(C+)/,"<span style=\"background-color: #ffff00;\">#{$1}<\/span>")
				seq.gsub(/([DE]+)/,"<span style=\"background-color: #6080ff;\">#{$1}<\/span>")
				seq.gsub(/([LIVM]+)/,"<span style=\"background-color: #02ff02;\">#{$1}<\/span>")
				seq.gsub(/([KR]+)/,"<span style=\"background-color: #ff0000;\">#{$1}<\/span>")
				seq.gsub(/([QN]+)/,"<span style=\"background-color: #e080ff;\">#{$1}<\/span>")
				seq.gsub(/(H+)/,"<span style=\"background-color: #ff8000;\">#{$1}<\/span>")
				seq.gsub(/(P+)/,"<span style=\"background-color: #a0a0a0;\">#{$1}<\/span>")
				line[b].sub(/#{old_seq}/,seq)
			end
		

		# Found a ss_conf line?
		elsif  line[b] =~ /\s*(Q|T) ss_/ 
		end
	
		b +=1
	end #end while
	
	b = ifirst
	while b< line.length
		@resultsa.push(line[b])
		b +=1
	end #end while
		
	
	@resultsa.push("<br></pre>\n")
	@resultsa.push("Please cite as appropriate: \n")
	@resultsa.push("<BR><BR><B><i>HHpred</i>: S&ouml;ding, J. (2005) Protein homology detection by HMM-HMM comparison. Bioinformatics 21: 951-960.</B>")
	@resultsa.push("<BR><BR><i>PSIPRED</i>: Jones, D.T. (1999) Protein secondary structure prediction based on position-specific scoring matrices. JMB 292: 195-202.")
	@resultsa.push("<BR><BR><i>PDB</i>: Bourne, PE. <i>et al.</i> (2004) The distribution and query systems of the RCSB Protein Data Bank. NAR 32: D223.") if (cite_pdb != nil)
	@resultsa.push("<BR><BR><i>SCOP</i>: Andreeva A, Howorth D, Brenner SE, Hubbard TJ, Chothia C, Murzin AG. (2004)	SCOP database in 2004: refinements integrate structure and sequence family data. NAR 32: D226-229.") if (cite_scop != nil)
	@resultsa.push("<BR><BR><i>Interpro</i>: Mulder NJ, Apweiler R, Attwood TK, Bairoch A, Bateman A, Binns D, Bradley P, Bork P, Bucher P, Cerutti L, Copley R, Courcelle E, Das U, Durbin R, Fleischmann W, Gough J, Haft D, Harte N, Hulo N, Kahn D, Kanapin A, Krestyaninova M, Lonsdale D, Lopez R, Letunic I, Madera M, Maslen J, McDowall J, Mitchell A, Nikolskaya AN, Orchard S, Pagni M, Ponting CP, Quevillon E, Selengut J, Sigrist CJ, Silventoinen V, Studholme DJ, Vaughan R, Wu CH. (2005) InterPro, progress and status in 2005. NAR 33: D201-205.") if (cite_ipro != nil )
	@resultsa.push("<BR><BR><i>Pfam</i>: Bateman A, Coin L, Durbin R, Finn RD, Hollich V, Griffiths-Jones S, Khanna A, Marshall M, Moxon S, Sonnhammer EL, Studholme DJ, Yeats C, Eddy SR. (2004) The Pfam protein families database. NAR 32: D138-141.") if (cite_pfam != nil)
	@resultsa.push("<BR><BR><i>SMART</i>: Letunic I, Copley RR, Schmidt S, Ciccarelli FD, Doerks T, Schultz J, Ponting CP, Bork P. (2004) SMART 4.0: towards genomic data integration. NAR 32: D142-144.") if (cite_smart != nil )
	@resultsa.push("<BR><BR><i>CDD</i>: Marchler-Bauer A, Anderson JB, Cherukuri PF, DeWeese-Scott C, Geer LY, Gwadz M, He S, Hurwitz DI, Jackson JD, Ke Z, Lanczycki CJ, Liebert CA, Liu C, Lu F, Marchler GH, Mullokandov M, Shoemaker BA, Simonyan V, Song JS, Thiessen PA, Yamashita RA, Yin JJ, Zhang D, Bryant SH. (2005) CDD: a Conserved Domain Database for protein classification.. NAR 33: D192-196.") if (cite_cdd != nil)
	@resultsa.push("<BR><BR><i>COG</i>: Tatusov RL, Fedorova ND, Jackson JD, Jacobs AR, Kiryutin B, Koonin EV, Krylov DM, Mazumder R, Mekhedov SL, Nikolskaya AN, Rao BS, Smirnov S, Sverdlov AV, Vasudevan S, Wolf YI, Yin JJ, Natale DA. (2003) The COG database: an updated version includes eukaryotes. BMC Bioinformatics 4: 41.") if (cite_cog != nil)
	@resultsa.push("<BR><BR><i>KOG</i>: Koonin EV, Fedorova ND, Jackson JD, Jacobs AR, Krylov DM, Makarova KS, Mazumder R, Mekhedov SL, Nikolskaya AN, Rao BS, Rogozin IB, Smirnov S, Sorokin AV, Sverdlov AV, Vasudevan S, Wolf YI, Yin JJ, Natale DA. (2004) A comprehensive evolutionary classification of proteins encoded in complete eukaryotic genomes. Genome Biol 5: R7.") if (cite_kog != nil )
	@resultsa.push("<BR><BR><i>PANTHER</i>: Mi H, Lazareva-Ulitsky B, Loo R, Kejariwal A, Vandergriff J, Rabkin S, Guo N, Muruganujan A, Doremieux O, Campbell MJ, Kitano H, Thomas PD. (2005) The PANTHER database of protein families, subfamilies, functions and pathways. NAR 33: D284-288.") if (cite_panther !=  nil)
	@resultsa.push("<BR><BR><i>TIGRFAMs</i>: Haft DH, Selengut JD, White O. (2003) The TIGRFAMs database of protein families. NAR 31: 371-373.") if (cite_tigrfam != nil )
	@resultsa.push("<BR><BR><i>PIRSF</i>: Wu CH, Nikolskaya A, Huang H, Yeh LS, Natale DA, Vinayaka CR, Hu ZZ, Mazumder R, Kumar S, Kourtesis P, Ledley RS, Suzek BE, Arminski L, Chen Y, Zhang J, Cardenas JL, Chung S, Castro-Alvear J, Dinkov G, Barker WC. (2004) PIRSF: family classification system at the Protein Information Resource. NAR 32: D112-114.") if (cite_pirsf != nil) 
	@resultsa.push("<BR><BR><i>Superfamily</i>: Madera M, Vogel C, Kummerfeld SK, Chothia C and Gough J. (2004) The SUPERFAMILY database in 2004: additions and improvements. NAR 32: D235-D239.") if (cite_supfam != nil)
	@resultsa.push("<BR><BR><i>CATH/Gene3D</i>: Pearl F, Todd A, Sillitoe I, Dibley M, Redfern O, Lewis T, Bennett C, Marsden R, Grant A, Lee D, Akpor A, Maibaum M, Harrison A, Dallman T, Reeves G, Diboun I, Addou S, Lise S, Johnston C, Sillero A, Thornton J, Orengo C. (2005) The CATH Domain Structure Database and related resources Gene3D and DHS provide comprehensive domain family information for genome analysis. NAR 33: D247-D251") if (cite_CATH != nil )  
	@resultsa.push("<BR><BR><i>PRODOM</i>: Bru, C. <i>et al.</i> (2005) The ProDom database of protein domain families: more emphasis on 3D. NAR 33: D212-215.") if (cite_prodom != nil) 
	@resultsa.push("<input type=\"hidden\" id=\"checkboxes\" name=\"checkboxes\" value=\"#{m}\" \>\n")
	@resultsa.push("<input type=\"hidden\" id=\"createmodel_disabled_Checkboxes\" name=\"createmodel_disabled_Checkboxes\" value=\"#{createmodel_diabled_checkboxes}\" \>\n")
	exit(0)
	
		
	
	
end #end method


def add_structure_database_logos
	i = params[0]
	template = params[1]
	pdbcode = params[2]
	ucpdbcode = pdbcode.upcase
	line = params[3]
	line[i-1].chomp
	
	# Link to PDB
	href="http:\/\/pdb.rcsb.org\/pdb\/explore.do?structureId=#{ucpdbcode}";
	line[i-1] += "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_PDB.jpg\" alt=\"PDB\" title=\"PDB\" #{logo_attr} height=\"20\"></a>"
    
    # Link to NCBI MMDB
	href="http:\/\/www.ncbi.nlm.nih.gov\/entrez\/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{ucpdbcode}";
	line[i-1] += "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_MMDB.jpg\" alt=\"MMDB\" title=\"MMDB/NCBI\" #{logo_attr} height=\"20\"></a>"
    
    # Link to EBI MSD
	href="http:\/\/www.ebi.ac.uk/msd-srv/atlas?id=#{pdbcode}"
	line[i-1] += "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_MSD.jpg\" alt=\"MSD\" title=\"MSD/EBI\" #{logo_attr} height=\"25\"></a>"
    
    line[i-1] += "\n"   
    return
end


def add_inter_pro_link_logo(*params)

	i = params[0]
	href = "http:\/\/www.ebi.ac.uk/interpro/IEntry?ac="
	line = params[1]
	if line[b].sub(/InterPro:(\s+)(\S+)/, "InterPro:#{$1}<a href=\"#{href}#{$2}\" target=\"_blank\">#{$2}<\/a>")
		line[i-1].chomp
		line[i-1]+= "<a href=\"#{href}#{$2}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_InterPro.jpg\" alt=\"InterPro\" title=\"InterPro\" #{logo_attr} height=\"20\" ></a>\n"
		cite_ipro=1
	end
end
		



 def add_pubmed_logo(*params)
	 i = params[0]
	 searchstring = params[1]
	 line = params[3]
	 line[i-b].chomp
	 href="http:\/\/www.ncbi.nlm.nih.gov\/entrez\/query.fcgi?CMD=search&db=pubmed&term=#{searchstring}";
	 line[b-1] += "<a href=\"#{href}\" target=\"_blank\" #{link_attr} ><img src=\"$DOC_ROOTURL/images/hhpred/logo_pubmed.jpg\" alt=\"PubMed\" title=\"PubMed\" $logo_attr height=\"20\"></a>\n";
	 return   
end	 






  def break_lines(*params)
	  lref = params[0]
	  maxlinelen = params[1]
	  space = params[2]
	  chrs = lref.unpack('C*') 
	  lastchr = maxlinelen
	  col = 0
	  chrs.each_index do |a|
		if chrs.fetch(a)==32 || chrs.fetch(a) ==124 || chrs.fetch(a) == 125 || chrs.fetch(a) == 93
			lastchr = a
		end  #end if
		if ++col>maxlinelen
			  chrs[lastchr]=10
			  col = 0
			  lastchr +=maxlinelen
		end # end if
	end #end each
	lref = chrs.pack('C*')
	lref.gsub(/\n\s*(\S)/, "\n#{space}#{$1}")
	return 
	
  end #end method

def insert_array(array, offset,  array2)
	
	array.delete_at(offset)
	array2.reverse!
	array2.each do |x|
		array.insert(offset, x)
	end
end
	
		
	
     
         

	 
end #end class

 
