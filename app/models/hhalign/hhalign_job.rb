class HhalignJob < Job
  
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
  
  
	attr_reader :header, :lines
  
  
	def before_results(controller_params)
	
		resfile = File.join(job_dir, jobid+".hhr")
		raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
		res = IO.readlines(resfile).map {|line| line.chomp}
	
		@lines = []
		@header = res[0]
		@mode = controller_params['mode'] ? controller_params['mode'] : "onlySS"
		
		for i in 6..res.size
			if (res[i] =~ /^Done!/) then next end
			if (res[i] =~ /^Command /) then next end
			if (res[i] =~ /^\s*No\s+(\S+)\s+(\S+)\s+/) 
				res[i] = "<strong>"+res[i]+"</strong>"
			elsif (res[i] =~ /^\s*(\d+)\s+(\S+)\s+(\S+)\s+/ )
				m = $1
				target = $2
				family = $3
				res[i].sub!(m, "<a href=##{m}>#{m}</a>")
				
				# PFAM identifier? (PF01234)
				if ( target =~ /^PF\d{5}/ || target =~ /^pfam\d{5}/) 
					pfamid = target
					pfamid.sub!(/^pfam/, 'PF')
					# link to PFAM domain
					res[i].sub!(target, "<a href=\"http://www.sanger.ac.uk/cgi-bin/Pfam/getacc?#{pfamid}\" target=\"_blank\">#{target}</a>")
	    
				# SMART identifier? (smart00382)
				elsif ( target =~ /^SM\d{5}/ || target =~ /^smart\d{5}/)
					smartid = target
					smartid.sub!(/^smart/, 'SM')
					res[i] =~ /(\S+)+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s*-(\d+)\s+\d+-\d+\s*\(\d+\)\s*$/
					evalue = $1
					first = $2
					last = $3
					# Link to SMART domain description
					res[i].sub!(target, "<a href=\"http://dylan.embl-heidelberg.de/smart/do_annotation.pl?DOMAIN=#{smartid}&START=#{first}&END=#{last}&E_VALUE=#{evalue}&TYPE=SMART\" target=\"_blank\">#{target} </a>")
					
				# Other CDD identifier? (COG0001, KOG0001, cd00001)
				elsif ( target =~ /^COG\d{4}/ || target =~ /^KOG\d{4}/ || target =~ /^cd\d{5}/)
					# Link to CDD at NCBI
	    			res[i].sub!(target, "<a href=\"http://www.ncbi.nlm.nih.gov/Structure/cdd/cddsrv.cgi?uid=#{target}\" target=\"_blank\">#{target}</a>")
				
				# SCOP identifier? (d3lkfa_,d3pmga1,d3pga1_,d3grs_3,g1m26.1,d1n7daa)
				elsif ( target =~ /^[defgh](\d[a-z0-9]{3})[a-z0-9_.][a-z0-9_]$/ )
					pdbcode = $1
					ucpdbcode = pdbcode.upcase
					# Link to NCBI MMDB
					res[i].sub!(target, "<a href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{ucpdbcode}\" target=\"_blank\">#{target}</a>")
					# Link to SCOP at family level
					res[i].sub!(family, "<a href=\"http://scop.mrc-lmb.cam.ac.uk/scop/search.cgi?sid=#{target}&lev=fa\" target=\"_blank\">#{family}</a>")
										
				# DALI/PDB identifier?  (8fabA_0,1a0i_2)
				elsif ( target =~ /^(\d[a-z0-9]{3})([A-Za-z0-9])?_\d+$/ )
					pdbcode = $1
					ucpdbcode = pdbcode.upcase
					# Link to PDB Beta
					res[i].sub!(target, "<a href=\"http://pdbbeta.rcsb.org/pdb/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\">#{target}</a>")
					# Link to DALI
					res[i].sub!(family, "<a href=\"http://www.bioinfo.biocenter.helsinki.fi:8080/cgi-bin/daliquery.cgi?find=#{target}\" target=\"_blank\">#{family}</a>")
	    
				# PDB identifier?  (8fab_A,1a0i  )
				elsif ( target =~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/ )
					pdbcode = $1
					ucpdbcode = pdbcode.upcase
					# Link to PDB Beta
					res[i].sub!(target, "<a href=\"http://pdbbeta.rcsb.org/pdb/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\">#{target}</a>")
				end
			
			########################################################################################################
			# 'No X' line before each query-target alignment
			elsif ( res[i] =~ /^No\s*(\d+)/ )
				m = $1
				res[i].sub!(/(No\s*\d+)/, "<a name = #{m}>"+'\1'+"</a>")
			
			########################################################################################################
			# '>name and description' line before each query-target alignment
			elsif ( res[i] =~ /^>(\S+\.*\S*)\s+(\S+)\s+/ )
				target = $1
				family = $2
				res[i].gsub!(/(.{0,100}\S)\s+/, '\1\n')
				res[i].sub!(/\n$/, '')
				
				# PFAM identifier? (PF01234)
				if ( target =~ /^PF\d{5}/ || target =~ /^pfam\d{5}/) 
					pfamid = target
					pfamid.sub!(/^pfam/, 'PF')
					# link to PFAM domain
					res[i].sub!(target, "<a href=\"http://www.sanger.ac.uk/cgi-bin/Pfam/getacc?#{pfamid}\" target=\"_blank\">#{target}</a>")
	    
				# SMART identifier? (smart00382)
				elsif ( target =~ /^SM\d{5}/ || target =~ /^smart\d{5}/)
					smartid = target
					smartid.sub!(/^smart/, 'SM')
					res[i] =~ /(\S+)+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s*-(\d+)\s+\d+-\d+\s*\(\d+\)\s*$/
					evalue = $1
					first = $2
					last = $3
					# Link to SMART domain description
					res[i].sub!(target, "<a href=\"http://dylan.embl-heidelberg.de/smart/do_annotation.pl?DOMAIN=#{smartid}&START=#{first}&END=#{last}&E_VALUE=#{evalue}&TYPE=SMART\" target=\"_blank\">#{target} </a>")
					
				# Other CDD identifier? (COG0001, KOG0001, cd00001)
				elsif ( target =~ /^COG\d{4}/ || target =~ /^KOG\d{4}/ || target =~ /^cd\d{5}/)
					# Link to CDD at NCBI
	    			res[i].sub!(target, "<a href=\"http://www.ncbi.nlm.nih.gov/Structure/cdd/cddsrv.cgi?uid=#{target}\" target=\"_blank\">#{target}</a>")
				
				# SCOP identifier? (d3lkfa_,d3pmga1,d3pga1_,d3grs_3,g1m26.1,d1n7daa)
				elsif ( target =~ /^[defgh](\d[a-z0-9]{3})[a-z0-9_.][a-z0-9_]$/ )
					pdbcode = $1
					ucpdbcode = pdbcode.upcase
					# Link to NCBI MMDB
					res[i].sub!(target, "<a href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{ucpdbcode}\" target=\"_blank\">#{target}</a>")
					# Link to SCOP at family level
					res[i].sub!(family, "<a href=\"http://scop.mrc-lmb.cam.ac.uk/scop/search.cgi?sid=#{target}&lev=fa\" target=\"_blank\">#{family}</a>")
										
				# DALI/PDB identifier?  (8fabA_0,1a0i_2)
				elsif ( target =~ /^(\d[a-z0-9]{3})([A-Za-z0-9])?_\d+$/ )
					pdbcode = $1
					ucpdbcode = pdbcode.upcase
					# Link to PDB Beta
					res[i].sub!(target, "<a href=\"http://pdbbeta.rcsb.org/pdb/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\">#{target}</a>")
					# Link to DALI
					res[i].sub!(family, "<a href=\"http://www.bioinfo.biocenter.helsinki.fi:8080/cgi-bin/daliquery.cgi?find=#{target}\" target=\"_blank\">#{family}</a>")
	    
				# PDB identifier?  (8fab_A,1a0i  )
				elsif ( target =~ /^(\d[a-z0-9]{3})_?([A-Za-z0-9]?)$/ )
					pdbcode = $1
					ucpdbcode = pdbcode.upcase
					# Link to PDB Beta
					res[i].sub!(target, "<a href=\"http://pdbbeta.rcsb.org/pdb/explore.do?structureId=#{ucpdbcode}\" target=\"_blank\">#{target}</a>")
				end
			end
		
			##################################################################################################
			# Color alignments
			
			# Found a ss_dssp or ss_pred line?			
			if ( res[i] =~ /\s*(Q|T) ss_(dssp|pred)\s+(\S+)/ )
				seq = $3
				old_seq = $3
				if (@mode == "onlySS" || @mode == "letters")
					seq.gsub!(/(H+)/, '<span style="color: #D00000;">\1</span>')
					seq.gsub!(/(E+)/, '<span style="color: #0000D0;">\1</span>')
				elsif (@mode == "background")
					seq.gsub!(/(H+)/, '<span style="background-color: #ffb0b0;">\1</span>')
					seq.gsub!(/(E+)/, '<span style="background-color: #b0b0ff;">\1</span>')
				end
				res[i].sub!(old_seq, seq)

			# Found a consensus line?
			elsif ( res[i] =~ /\s*(Q|T) Cons(-\S+|ensus)\s+\d+\s+(\S+)/ )
				seq = $3
				old_seq = $3
				if (@mode == "letters" || @mode == "background")
					seq.gsub!(/([~.-]+)/, '<span style="color: #808080;">\1</span>')
				end
				res[i].sub!(old_seq, seq)
    
			# Found a sequence line?
			elsif ( res[i] =~ /\s*(Q|T) (\S+)\s+\d+\s+(\S+)/ )
				seq = $3
				old_seq = $3
				if (@mode == "letters")
					seq.gsub!(/([a-z.-]+)/, '<span style="color: #808080;">\1</span>')
					seq.gsub!(/([WYF]+)/, '<span style="color: #00a000;">\1</span>')
					seq.gsub!(/([LIVM]+)/, '<span style="color: #00ff00;">\1</span>')
					seq.gsub!(/([AST]+)/, '<span style="color: #404040;">\1</span>')
					seq.gsub!(/([KR]+)/, '<span style="color: red;">\1</span>')
					seq.gsub!(/([DE]+)/, '<span style="color: blue;">\1</span>')
					seq.gsub!(/([QN]+)/, '<span style="color: #d000a0;">\1</span>')
					seq.gsub!(/(H+)/, '<span style="color: #E06000;">\1</span>')
					seq.gsub!(/(C+)/, '<span style="color: #A08000;">\1</span>')
					seq.gsub!(/(P+)/, '<span style="color: #000000;">\1</span>')
					seq.gsub!(/(G+)/, '<span style="color: #404040;">\1</span>')
				elsif (@mode == "background")
					seq.gsub!(/([WYF]+)/, '<span style="background-color: #00c000;">\1</span>')
					seq.gsub!(/(C+)/, '<span style="background-color: #ffff00;">\1</span>')
					seq.gsub!(/([DE]+)/, '<span style="background-color: #6080ff;">\1</span>')
					seq.gsub!(/([LIVM]+)/, '<span style="background-color: #02ff02;">\1</span>')
					seq.gsub!(/([KR]+)/, '<span style="background-color: #ff0000;">\1</span>')
					seq.gsub!(/([QN]+)/, '<span style="background-color: #e080ff;">\1</span>')
					seq.gsub!(/(H+)/, '<span style="background-color: #ff8000;">\1</span>')
					seq.gsub!(/(P+)/, '<span style="background-color: #a0a0a0;">\1</span>')
				end
				res[i].sub!(old_seq, seq)
			end				
						
			@lines << res[i]
		end # Each-loop
	end
  
end
