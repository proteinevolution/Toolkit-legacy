class HhompJob < Job
  require 'Biolinks.rb'
  require 'checked_hits'
  include CheckedHits
  
  @@export_ext = ".export"
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
  
  
  	attr_reader :header, :hitlist, :hitlist_header, :alignment, :no_pdb, :pdb_file
  
	def before_results(controller_params)
	
		@mode = controller_params[:mode] ? controller_params[:mode] : 'onlySS'
		@program = controller_params[:action]		
		
		@basename = File.join(job_dir, jobid)		
		
		if (@program == "results_histograms" && !File.exists?(@basename + "_1.png"))
			command = "tar -xzf #{@basename}.tar.gz -C #{job_dir} &> /dev/null"
			logger.debug("Command: #{command}")
			system(command)
		end		
		
		@header = []
		@hitlist_header = ""
		@hitlist = []
		@alignment = []
		@no_pdb = ""
		@pdb_file = nil
		if File.exists?(@basename + ".pdb") && File.readable?(@basename + ".pdb") && !File.zero?(@basename + ".pdb")
			@pdb_file = true
		end
		
		logger.debug("Controller Params: #{controller_params.inspect}")	
	
		resfile = @basename + ".hhr"
		raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
		@res = IO.readlines(resfile).map {|line| line.chomp}	

		@longnames = {}
	
		for i in 0..@res.length
			if (@res[i] =~ /^No (\d+)/)
				num = $1
				if (@res[i+1] =~ /^>(.*)$/)
					@longnames[num] = $1
				end
			end
		end	
	
		# correct header		
		length = nil;
		n_seqs = nil;
		if (@res[1] =~ /Match.columns\s+(\d+)/)
			length = $1
		end
		if (@res[2] =~ /No_of_seqs\s+(\d+)/)
			n_seqs = $1
		end
		@res[0] += " (Length=#{length}, Nseqs=#{n_seqs})   Alignment: #{params_main_action['alignmode']}"
		@res[0].sub!(/Query\s+/, 'Query:  ')
		@res[0].gsub!(/(.{90,110})\s+(\S)/, '\1***        \2')
		
		@header << @res[0].split('***')
						
		# extract hitlist
		i = 0
		for i in i..@res.length
			if (@res[i] =~ /^Overall probability for query/) 
				@res[i] =~ /^(.*\:)\s+(\S+)/
				@res[i] = "\&nbsp;" + $1 + " <span style='color: red;'>" + $2 + "%</span>"
				box = "<div style='border: 1px solid; background-color: #D0D0D0; font-weight: bold; width: 370px;'>#{@res[i]}</div>"				
				@header << "\n" + box 
			end			
			if (@res[i] =~ /No Hit/) then break end
		end	
		
		@hitlist_header = "<strong>#{@res[i]}</strong>"		
		
		for i in (i+1)..@res.length
			if (@res[i] =~ /^\s*$/) then break end
			if (@res[i] =~ /^\s*(\d+)\s+(\S+)\s+(\S+)/)
				num = $1
				name = $2
				fam = $3
				if (name =~ /^[defgh](\d[a-z0-9]{3})[a-z0-9_.][a-z0-9_]$/)	# SCOP hit 
					pdb_code = $1.upcase!					
					@res[i].sub!(/#{num}/, "<a href=\##{num}>#{num}<\/a>")
					@res[i].sub!(/#{fam}/, Biolinks.scop_family_link(fam))
					@res[i].sub!(/#{name}/, "<a href='http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{pdb_code}' onmouseover=\"return overlib('#{@longnames[num]}');\" onmouseout=\"return nd();\" target='_blank'>#{name}<\/a>")
				else 	                  # HHomp hit
					@res[i].sub!(/#{num}/, "<a href=\##{num}>#{num}<\/a>")
					@res[i].sub!(/#{name}/, "<a href='#{DOC_ROOTURL}/hhomp/browse/#{jobid}?page=#{name}' onmouseover=\"return overlib('#{@longnames[num]}');\" onmouseout=\"return nd();\">#{name}<\/a>")
				end
			end
			@hitlist << @res[i]
		end	
		
		# extract alignments
		for i in i..@res.length
			if (@res[i] =~ /^\s*$/) then next end
			if (@res[i] =~ /^Done!/) then break end
			if (@res[i] =~ /^No (\d+)/)
				i = extract_ali(i, $1)
			end
		end
	
	end
	
	def extract_ali(i, num)
		ali = @res[i]
		i += 1
		ali.sub!(/No \d+/, "<a name = #{num}>No #{num}</a>")
		if (@program == "results")
			url = "#{DOC_ROOTURL}/hhomp/results_histograms/#{jobid}\##{num}" 			
			ali += "<a href='#{url}' style='margin: 5px 10px 10px 10px;' ><img src='#{DOC_ROOTURL}/images/hhpred/logo_histogram_single.png' alt='Histograms' title='Show histograms' border='0' align='middle' height='30'></a>"		
		else # histogram
			url = "#{DOC_ROOTURL}/hhomp/results/#{jobid}\##{num}" 			
			ali += "<a href='#{url}' style='margin: 5px 10px 10px 10px;' ><img src='#{DOC_ROOTURL}/images/hhpred/logo_alignments.jpg' alt='Alignments' title='Show query-template alignments' border='0' align='middle' height='30'></a>"
		end
		
		if (@res[i] =~ /^>(\S+)\s*/)
			name = $1
			if (name =~ /^[defgh](\d[a-z0-9]{3})[a-z0-9_.][a-z0-9_]$/)	# SCOP hit 
				pdb_code = $1.upcase!				
				@res[i] =~ /^>(\S+)\s+(\S+)\s+/
				fam = $2
				@res[i].sub!(/#{fam}/, Biolinks.scop_family_link(fam))
				@res[i].sub!(/#{name}/, "<a href='http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?SUBMIT=y&db=structure&orig_db=structure&term=#{pdb_code}' onmouseover=\"return overlib('#{@longnames[num]}');\" onmouseout=\"return nd();\" target='_blank'>#{name}<\/a>")
				pdbfile = File.join(DATABASES, 'hhomp', 'scop_db', name + ".pdb")
				if (@pdb_file)
					ali += "<a href='#' onclick=\"var win = window.open('#{DOC_ROOTURL}/hhomp/run/hhomp3d_querytempl?parent=#{jobid}&templpdb=#{pdbfile}&hit=#{num}&querypdb=#{@basename}.pdb&forward_controller=hhomp&forward_action=results_hhomp3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" style='margin: 5px 10px 10px 10px;' ><img src='#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png' title='Show query-template 3D superposition'  border='0' align='middle' height='30'/></a>"
				else
					ali += "<a href='#' onclick=\"var win = window.open('#{DOC_ROOTURL}/hhomp/run/hhomp3d_templ?parent=#{jobid}&templpdb=#{pdbfile}&forward_controller=hhomp&forward_action=results_hhomp3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" style='margin: 5px 10px 10px 10px;' ><img src='#{DOC_ROOTURL}/images/hhpred/logo_T_struct.png' alt='Alignments' title='Show template 3D structure' border='0' align='middle' height='30'></a>"
				end								
			else
				@res[i].sub!(/#{name}/, "<a href='#{DOC_ROOTURL}/hhomp/browse/#{jobid}?page=#{name}' onmouseover=\"return overlib('#{@longnames[num]}');\" onmouseout=\"return nd();\">#{name}<\/a>")
				#check for pdb-file
				pdbfile = File.join(DATABASES, 'hhomp', 'pdb', name + ".pdb")
				if File.exists?(pdbfile) && File.readable?(pdbfile) && !File.zero?(pdbfile)
					if (@pdb_file)
						ali += "<a href='#' onclick=\"var win = window.open('#{DOC_ROOTURL}/hhomp/run/hhomp3d_querytempl?parent=#{jobid}&templpdb=#{pdbfile}&hit=#{num}&querypdb=#{@basename}.pdb&forward_controller=hhomp&forward_action=results_hhomp3d_querytempl','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" style='margin: 5px 10px 10px 10px;' ><img src='#{DOC_ROOTURL}/images/hhpred/logo_QT_struct.png' title='Show query-template 3D superposition'  border='0' align='middle' height='30'/></a>"
					else
						ali += "<a href='#' onclick=\"var win = window.open('#{DOC_ROOTURL}/hhomp/run/hhomp3d_templ?parent=#{jobid}&templpdb=#{pdbfile}&forward_controller=hhomp&forward_action=results_hhomp3d_templ','_blank','width=850,height=850,left=0,top=0,scrollbars=yes,resizable=no'); win.focus();\" style='margin: 5px 10px 10px 10px;' ><img src='#{DOC_ROOTURL}/images/hhpred/logo_T_struct.png' alt='Alignments' title='Show template 3D structure' border='0' align='middle' height='30'></a>" 
					end								
				else
					@no_pdb += num + ","				
				end
			end
		end 
		ali += "\n" + @res[i] + "\n" + @res[i+1] + "\n"
		i += 2
		
		#read alignment
		if (@program == "results")
			for i in i..@res.length
				if (@res[i] =~ /^No (\d+)/ || @res[i] =~ /^Done!/) then break end
				color_line(i)
				ali += @res[i] + "\n"
			end
		else # histogram
			mapfile = @basename + "_" + num.to_s + ".map"
			if File.exists?(mapfile) && File.readable?(mapfile) && !File.zero?(mapfile)
				ali += IO.readlines(mapfile).join
			end
	    	for i in i..@res.length
				if (@res[i] =~ /^No (\d+)/ || @res[i] =~ /^Done!/) then break end
			end
		end

		@alignment << ali
		
		return (i-1)		
	end	
	
	def get_Name(cluster)
		tempfile = File.join(DATABASES, 'hhomp', cluster + ".hhm")
		return "" if !File.readable?(tempfile) || !File.exists?(tempfile) || File.zero?(tempfile)
		lines = IO.readlines(tempfile)
		lines.each do |line|
			if (line =~ /^NAME\s+(\S.*?)\s*$/)
				return $1
			end
		end
		return ""
	end	
	
	# Coloring	
	def color_line(i)
		
		# Found ss_pred line?
		if (@res[i] =~ /\s*(Q|T) ss_pred\s+(\S+)/ )
			seq = $2
			old_seq = $2
			if (@mode == "onlySS" || @mode == "letters")
				seq.gsub!(/(H+)/, '<span style="color: #D00000;">\1</span>')
				seq.gsub!(/(E+)/, '<span style="color: #0000D0;">\1</span>')
			else
				seq.gsub!(/(H+)/, '<span style="background-color: #ffb0b0;">\1</span>')
				seq.gsub!(/(E+)/, '<span style="background-color: #b0b0ff;">\1</span>')
			end
			@res[i].sub!(/#{old_seq}/, "#{seq}")
		# Found bb_pred line?
		elsif (@res[i] =~ /\s*(Q|T) bb_pred\s+(\S+)/)		
			seq = $2
			old_seq = $2
			if (@mode == "onlySS" || @mode == "letters")
				seq.gsub!(/(D+)/, '<span style="color: #14bc03;">\1</span>')
				seq.gsub!(/(U+)/, '<span style="color: #fa9904;">\1</span>')
			else
				seq.gsub!(/(D+)/, '<span style="background-color: #74e25f;">\1</span>')
				seq.gsub!(/(U+)/, '<span style="background-color: #f5c34a;">\1</span>')
			end
			@res[i].sub!(/#{old_seq}/, "#{seq}")
		# Found a consensus line?		
		elsif (@res[i] =~ /\s*(Q|T) Cons(-\S+|ensus)\s+\d+\s+(\S+)/)
			seq = $3
			old_seq = $3
			if (@mode == "background" || @mode == "letters")
				seq.gsub!(/([~.-]+)/, '<span style="color: #808080;">\1</span>')
			end
			@res[i].sub!(/#{old_seq}/, "#{seq}")
		# Found a sequence line?
		elsif (@res[i] =~ /\s*(Q|T) (\S+)\s+\d+\s+(\S+)/)
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
				seq.gsub!(/(H+)/, '<span style="color: #e06000;">\1</span>')
				seq.gsub!(/(C+)/, '<span style="color: #a08000;">\1</span>')
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
			@res[i].sub!(/#{old_seq}/, "#{seq}")
		end
		
	end
	
	
	# for BLAST output	
	
  	E_THRESH = 0.01
  	
	attr_reader :blast_header, :hits_better, :hits_worse, :blast_alignments, :footer, :num_checkboxes	
	
	def before_blast_results()
          @blast_header, @blast_alignments, @footer = show_hits(jobid + ".blast", E_THRESH, "E-value", false)
    	  return true
	end	

	
end
