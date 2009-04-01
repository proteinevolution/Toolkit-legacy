class Quick2DJob < Job
  
  @@majorTicks    = 50
  @@minorTicks    = 10
  @@linewidth     = 80
  #@@helix_color   = "#FFD4D9"
  #@@sheet_color   = "#C4D6FF"
  
  @@helix_color   = "#ff8284"
  @@sheet_color   = "#739cff"
  
  @@loop_color    = "#FFFFFF"
  @@query_color   = "#FFFAE0"
  #@@tm_color      = "#E2FFEA"
  @@tm_color      = "#74e25f"
  #@@do_color      = "#e4f5f7"#"#EDEEEB"
  @@do_color      = "#ddc57c"
  #@@cc_color      = "#F0E0FF" 
  @@cc_color      = "#be80ff"
  
  @@sol_color     = "#ffff69"  
  
  @@metric_bgcolor = "#d9e0e0"  
  
  @@descr_width   = 17
  
  @@export_ext    = "quick2d" 
  
  def set_export_ext(val)
    @@export_ext = val  
  end
  
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export
    query    = readQuery
    psipred  = readPsipred
    jnet     = readJNet
    prof_o   = readProfOuali	
    prof_r   = readProfRost
    memsat   = readMemsat
    hmmtop   = readHMMTOP	
    disopred = readDisopred
    vsl2     = readVSL2
    coils    = readCoils		
    
    data     = ""
    len      = query['sequence'].length
    i        = 0
    while( i<len )
      stop = min(i+@@linewidth, len)
      data += sprintf("%-#{@@descr_width}s", "QUERY")
      data += query['sequence'][i..(stop-1)] + "\n"
      
      data += export_ss("SS PSIPRED", psipred, i, stop-1)
      data += export_ss("SS JNET", psipred, i, stop-1)
      
      data += sprintf("%-#{@@descr_width}s", "SS PROF (Ouali)")
      if( !prof_o.nil? && !prof_o['pred'].nil? ) 
        data += prof_o['pred'][i..(stop-1)] + "\n"
      else
        data += "\n"
      end	
      data += sprintf("%-#{@@descr_width}s", "CONF")
      if( !prof_o.nil? && !prof_o['conf'].nil? ) 
        tmp = prof_o['conf'][i..(stop-1)]
        0.upto(tmp.size-1){|ii|
          tmp[ii] = ((tmp[ii].to_f)*9.0).floor
        }
        data +=  tmp.to_s + "\n"
      else
        data += "\n"
      end	
      
      data += export_ss("SS PROF (Rost)", psipred, i, stop-1)
      
      data += sprintf("%-#{@@descr_width}s", "CC COILS")
      if( !coils.nil? && !coils['ccpred'].nil? ) 
        data += coils['ccpred'][i..(stop-1)] + "\n"
      else
        data += "\n"
      end	
      data += sprintf("%-#{@@descr_width}s", "CONF")
      if( !coils.nil? && !coils['conf'].nil? ) 
        data += coils['conf'][i..(stop-1)] + "\n"
      else
        data += "\n"
      end									
      
      data += export_tm("TM MEMSAT2", memsat, i, stop-1)
      data += export_tm("TM HMMTOP", hmmtop, i, stop-1)
      data += export_tm("TM PROF (Rost)", prof_r, i, stop-1)
      
      data += export_do("DO DISOPRED2", disopred, i, stop-1)
      data += export_do("DO VSL", vsl2, i, stop-1)			
      
      data += export_so("SO PROF (Rost)", prof_r, i, stop-1)			
      data += export_so("SO JNET", jnet, i, stop-1)
      
      data += "\n\n"
      i += @@linewidth
    end
    data
  end
  
  
  def export_ss(name, blub, a, b)
    ret = sprintf("%-#{@@descr_width}s", name)
    if( !blub.nil? && !blub['pred'].nil? )
      ret += blub['pred'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret += sprintf("%-#{@@descr_width}s", "CONF")
    if( !blub.nil? && !blub['conf'].nil? )
      ret += blub['conf'][a..b] + "\n"
    else 
      ret += "\n"
    end
    ret
  end  
  
  def export_tm(name, blub, a, b)
    ret = sprintf("%-#{@@descr_width}s", name)
    if( !blub.nil? && !blub['tmpred'].nil? )
      ret += blub['tmpred'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret += sprintf("%-#{@@descr_width}s", "CONF")
    if( !blub.nil? && !blub['tmconf'].nil? )
      ret += blub['tmconf'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret
  end  
  
  def export_do(name, blub, a, b)
    ret = sprintf("%-#{@@descr_width}s", name)
    if( !blub.nil? && !blub['dopred'].nil? )
      ret += blub['dopred'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret += sprintf("%-#{@@descr_width}s", "CONF")
    if( !blub.nil? && !blub['doconf'].nil? )
      ret += blub['doconf'][a..b] + "\n"
    else
      ret += "\n"
		end
    ret
  end 
  
  def export_so(name, blub, a, b)
    ret = sprintf("%-#{@@descr_width}s", name)
    if( !blub.nil? && !blub['sol'].nil? )
      ret += blub['sol'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret
  end 
  
  # add your own data accessors for the result templates here! For example:
  attr_reader :legend, :data, :header, :sequence
  
  
  # Overwrite before_results to fill you job object with result data before result display
  def before_results(controller_params)
    h = readQuery
    @header   = h['header'] 
    @sequence = h['seq']
    @data     = getData
    @legend   = printLegend
  end
  
  
  def getData
    
    query    = readQuery
    psipred  = readPsipred
    jnet     = readJNet
    prof_o   = readProfOuali	
    prof_r   = readProfRost
    memsat   = readMemsat
    hmmtop   = readHMMTOP	
    disopred = readDisopred
    vsl2     = readVSL2
    coils    = readCoils		
    
    data     = ""
    
    # write javascript
    data += "\n"+'<script type="text/javascript">' +"\n"
    data += 'initInfo(); '+"\n"
    data += 'RESIDUES="' +query['sequence']+'"; '+"\n"
    data += 'PSIPRED_CONF=new Array'+toJSArray( psipred['conf'] )+";\n"
    data += 'JNET_CONF=new Array'+toJSArray( jnet['conf'] )+";\n" 
    data += 'PROFROST_CONF=new Array'+toJSArray( prof_r['conf'] )+";\n" 
    data += 'PROFROST_TMCONF=new Array'+toJSArray( prof_r['tmconf'] )+";\n" 
    data += 'PROFOUALI_CONF=new Array'+toJSArray( prof_o['conf'] )+";\n" 
    data += 'DISOPRED2_CONF=new Array'+toJSArray( disopred['doconf'] )+";\n"
    data += '</script>' +"\n"		
    
    
    len      = query['sequence'].length
    i        = 0
    while( i<len )
      stop = min(i+@@linewidth, len)
      
      data += sprintf("<span>%-#{@@descr_width}s</span>", "")	
      data += "<span style=\"background-color:#{@@metric_bgcolor};\">"+getMetricPos(i, stop)+"</span>\n" 
      
      data += sprintf("<span>%-#{@@descr_width}s</span>", "")		
      data += "<span style=\"background-color:#{@@metric_bgcolor};\">"+getMetricTicks(i, stop)+"</span>\n" 
      
      #data += sprintf("<span>%-#{@@descr_width}s</span>", "")						
      #data += query['sequence'][i..(min(i+@@linewidth, len)-1)]+"\n"
      
      data += printSEQHTML(query['sequence'].split(//),"aa",i,stop)			
      
      data += printSSHTML("SS PSIPRED", "psipred", psipred, i, stop)
      data += printSSHTML("SS JNET", "jnet", jnet, i, stop)
      data += printSSHTML("SS Prof (Ouali)", "prof_o", prof_o, i, stop)
      data += printSSHTML("SS Prof (Rost)", "prof_r", prof_r, i, stop)
      
      data += printCCHTML("CC Coils", "coils", coils, i, stop)				
      
      data += printTMHTML("TM MEMSAT2", "memsat", memsat, i, stop)	
      data += printTMHTML("TM HMMTOP", "hmmtop", hmmtop, i, stop)
      data += printTMHTML("TM PROF (Rost)", "prof_tm", prof_r, i, stop)					
      
      data += printDOHTML("DO DISOPRED2", "disopred", disopred, i, stop)				
      data += printDOHTML("DO VSL2", "vsl2", vsl2, i, stop)
      
      data += printSOLHTML("SO Prof (Rost)", "sol_prof", prof_r, i, stop)
      
      data += printSOLHTML("SO JNET", "sol_jnet", jnet, i, stop)
      
      
      data += "\n"
      i += @@linewidth
		end
    data
  end  
  
  def printLegend
    ret = "";
    ret += "<span>SS = </span><span style=\"background-color: #{@@helix_color};\"> Alpha-Helix </span><span style=\"background-color: #{@@sheet_color};\"> Beta-Sheet </span><span> Secondary Structure</span></br>"
    ret += "<span>CC = </span><span style=\"background-color: #{@@cc_color};\">Coiled Coils</span></br>"
    ret += "<span>TM = </span><span style=\"background-color: #{@@tm_color};\">Transmembrane</span><span> (\'+\'=outside, \'-\'=inside)</span></br>"
    ret += "<span>DO = </span><span style=\"background-color: #{@@do_color};\">Disorder</span></br>"
    ret += "<span>SO = </span><span style=\"background-color: #{@@sol_color};\">Solvent accessibility</span><span> (A <b>b</b>urried residue has at most 25% of its surface exposed to the solvent.)</span></br>"
  end  
  
  def printSEQHTML(seq, id_name, a, b)
    data = sprintf("<span>%-#{@@descr_width}s</span>", "")					
    a.upto(b-1){ |j|
      data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{seq[j]}</span>"
    }
    data +="\n"
    data
  end
  	
  def printSSHTML(name, id_name, hash, a, b)
    if( hash['pred'].nil?|| hash['pred']=="") then return "" end
    data = ""
    data += sprintf("<span>%-#{@@descr_width}s</span>", name)
    a.upto(b-1){ |j|
      if(hash['pred'][j].chr=="H")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@helix_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['pred'][j].chr}</span>"
      elsif(hash['pred'][j].chr=="E")
        data += "<span id=\"#{j}#{id_name}\" style=\"background-color: #{@@sheet_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['pred'][j].chr}</span>"	
      else
        data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['pred'][j].chr}</span>"
      end
    }
    data += "\n"
    data
  end 
  
  
  def printTMHTML(name, id_name, hash, a, b)
    if( hash['tmpred'].nil?|| hash['tmpred']=="") then return "" end
    data = ""
    data += sprintf("<span>%-#{@@descr_width}s</span>", name)
    a.upto(b-1){ |j|
      if(hash['tmpred'][j].chr=="X")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@tm_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['tmpred'][j].chr}</span>"
      else
        data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['tmpred'][j].chr}</span>"
      end
    }
    data += "\n"
    data
  end  
  
  def printDOHTML(name, id_name, hash, a, b)
    if( hash['dopred'].nil?|| hash['dopred']=="") then return "" end
    data = ""
    data += sprintf("<span>%-#{@@descr_width}s</span>", name)
    a.upto(b-1){ |j|
      if(hash['dopred'][j].chr=="D")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@do_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['dopred'][j].chr}</span>"
      else
        data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['dopred'][j].chr}</span>"
      end
    }
    data += "\n"
    data
  end    
  
  def printCCHTML(name, id_name, hash, a, b)
    if( hash['ccpred'].nil?|| hash['ccpred']=="") then return "" end
    data = ""
    data += sprintf("<span>%-#{@@descr_width}s</span>", name)
    a.upto(b-1){ |j|
      if(hash['ccpred'][j].chr=="C")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@cc_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['ccpred'][j].chr}</span>"
      else
        data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['ccpred'][j].chr}</span>"
      end
    }
    data += "\n"
    data
  end  
  
  def printSOLHTML(name, id_name, hash, a, b)
    if( hash['sol'].nil?|| hash['sol']=="") then return "" end
    data = ""
    data += sprintf("<span>%-#{@@descr_width}s</span>", name)
    a.upto(b-1){ |j|
      if(hash['sol'][j].chr!=" ")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@sol_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['sol'][j].chr}</span>"
      else
        data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['sol'][j].chr}</span>"
      end
    }
    data += "\n"
    data
  end  
  
  def readQuery 	
    if( !File.exists?( self.actions[0].flash['queryfile'] ) ) then return {} end
    ret={'header'=>"", 'sequence'=>"" }
    ar = IO.readlines( self.actions[0].flash['queryfile'])
    ar.each do |line|
      line.chomp
      if( line =~ /^>/ )
        ret['header'] = line
      else
        ret['sequence'] += line
      end
    end
    ret['header'] = IO.readlines( self.actions[0].flash['headerfile']).join
    ret['sequence'].gsub!(/\s+/,"")
    ret
  end
  
  def readPsipred
    if( !File.exists?( self.actions[0].flash['psipredfile'] ) ) then return {} end
    ret={'conf'=>"", 'pred'=>"" }
    ar = IO.readlines( self.actions[0].flash['psipredfile'])
    ar.each do |line|
      if( line =~ /Conf:\s+(\S+)\s*$/ )
        ret['conf']+=$1
      elsif( line =~ /Pred:\s+(\S+)\s*$/ )
        ret['pred']+=$1
      end
    end
    ret['pred'].gsub!(/C/, " ")  		
    ret
  end
  
  def readProfOuali
    if( !File.exists?( self.actions[0].flash['profoualifile'] ) ) then return {} end
    ret={'conf'=>[], 'pred'=>"" }
    ar = IO.readlines( self.actions[0].flash['profoualifile'])
    ar.each do |line|
      if( line =~ /^\S\s+(\S)\s+(\S+)\s*/ )
        ret['pred']+=$1
        ret['conf']<<$2
      end
    end
    ret['pred'].gsub!(/C/, " ")  		
    ret
  end
  
  def readJNet
    if( !File.exists?( self.actions[0].flash['jnetfile'] ) ) then return {} end
    ret={'conf'=>"", 'pred'=>"", 'sol'=>""}
    sol25 = ""
    sol5  = ""
    sol0  = ""	
    ar = IO.readlines( self.actions[0].flash['jnetfile'] )
    ar.each do |line|
      if( line =~ /\s*CONF\s+:\s+(\S+)\s*$/ )
        ret['conf']+=$1
      elsif( line =~ /\s*FINAL\s+:\s+(\S+)\s*$/ )
        ret['pred']+=$1
      elsif( line =~ /\s*SOL25\s+:\s+(\S+)\s*$/ )
        sol25 += $1
      elsif( line =~ /\s*SOL5\s+:\s+(\S+)\s*$/ )
        sol5 += $1
      elsif( line =~ /\s*SOL0\s+:\s+(\S+)\s*$/ )
        sol0 += $1
      end
    end
    ret['pred'].gsub!(/-/, " ")  
    #sol25.gsub!(/B/,'1')
    sol25.gsub!(/-/,' ')
    #for i in 0..(sol25.length-1)
    #	if( sol0[i]=='B'[0] )
    #		sol25[i]='3'
    #	elsif( sol5[i]=='B'[0] )
    #		sol25[i]='2'
    #	end
    #end		
    ret['sol']=sol25
    ret
  end
  
  def readProfRost
    ret={'conf'=>"", 'pred'=>"", 'sol'=>"", 'tmpred'=>"", 'tmconf'=>""}
    
    sol = []
    if( !File.exists?( self.actions[0].flash['accfile'] ) ) then return {} end
    ar = IO.readlines( self.actions[0].flash['accfile'] )
    ar.each do |line|
      if( line =~ /^\d+\s+\S+\s+\d+\s+(\d+)\s+\d+\s+(\S)\s+/ )
        sol << $1
      end
    end  	
    0.upto(sol.size-1){ |i|
      if( sol[i].to_i <= 25 )
        sol[i] = "B"
      else
        sol[i] = " "
      end
    }
    ret['sol']= sol.join
    
    if( !File.exists?( self.actions[0].flash['htmfile'] ) ) then return {} end
    ar = IO.readlines( self.actions[0].flash['htmfile'] )
    ar.each do |line|
      if( line =~ /^\d+\s+\S\s+\S\s+\S+\s+\S+\s+(\S)+\s+(\d)/ )
        ret['tmpred'] += $1
        ret['tmconf'] += $2
      end
    end  	
    ret['tmpred'].gsub!(/i/, "-")
    ret['tmpred'].gsub!(/o/, "+")
    ret['tmpred'].gsub!(/T/, "X")
    
    if( !File.exists?( self.actions[0].flash['secfile'] ) ) then return {} end
    ar = IO.readlines( self.actions[0].flash['secfile'] )
    ar.each do |line|
      if( line =~ /^\d+\s+\S+\s+(\S)\s+(\d)\s+/ )
        ret['pred'] += $1
        ret['conf'] += $2
      end
    end  	
    ret['pred'].gsub!(/L/, " ")  		
    ret
  end
  
  def readMemsat
    if( !File.exists?( self.actions[0].flash['memsatfile'] ) ) then return {} end
    ret={'conf'=>"", 'tmpred'=>""}
    ar = IO.readlines( self.actions[0].flash['memsatfile'] )
    bool = false
    ar.each do |line|
      if( line =~ /FINAL PREDICTION/ )
        bool = true
      elsif( bool && line =~ /^\s*([-\+IOSX]+)\s*$/ )
        ret['tmpred']+=$1
      end
    end  	
    ret['tmpred'].gsub!(/O/, "X")
    ret['tmpred'].gsub!(/I/, "X")
    ret
  end
  
  def readDisopred
    if( !File.exists?( self.actions[0].flash['disopredfile'] ) ) then return {} end
    ret={'doconf'=>"", 'dopred'=>""}
		ar = IO.readlines( self.actions[0].flash['disopredfile'] )
    ar.each do |line|
      if( line =~ /conf\s*?:\s*?(\S*)\s*$/ )
        ret['doconf']+=$1
      elsif( line =~ /pred\s*?:\s*?(\S*)\s*$/ )
        ret['dopred']+=$1
      end	
    end
    ret['dopred'].gsub!(/\./, " ")
    ret['dopred'].gsub!(/\*/, "D")
    ret
  end
  
  def readVSL2
    if( !File.exists?( self.actions[0].flash['vsl2file'] ) ) then return {} end
    ret={'dopred'=>""}
    ar = IO.readlines( self.actions[0].flash['vsl2file'] )
    ar.each do |line|
      if( line =~ /^\d+\s+\S+\s+\S+\s+([D.])\s*$/ )
        ret['dopred']+=$1
      end	
    end
    ret['dopred'].gsub!(/\./, " ")
    ret
  end
  
  def readHMMTOP
    if( !File.exists?( self.actions[0].flash['hmmtopfile'] ) ) then return {} end
    ret={'tmpred'=>""}
    ar = IO.readlines( self.actions[0].flash['hmmtopfile'] )
    ar.each do |line|
      if( line =~ /^\s*pred\s*?(.*)$/ )
        ret['tmpred']+=$1
      end	
    end
    ret['tmpred'].gsub!(/\s+/, "")
    ret['tmpred'].gsub!(/[Ii]/, "++")
    ret['tmpred'].gsub!(/[Oo]/, "--")
    ret['tmpred'].gsub!(/H/, "X")
    ret
  end
  
  def readCoils
    if( !File.exists?( self.actions[0].flash['coilsfile'] ) ) then return {} end
    ret={'ccpred'=>""}
    ar = IO.readlines( self.actions[0].flash['coilsfile'] )
    ar.each do |line|
      if( line !~ /^>/ )
        ret['ccpred']+=line
      end	
    end
    ret['ccpred'].gsub!(/\s+/, "")
    ret['ccpred'].gsub!(/[^x]/, " ")
    ret['ccpred'].gsub!(/[x]/, "C")
    ret
  end
  
  def min(a,b)
    if( a<b ) then return a else return b end
  end
  
  def max(a,b)
    if( a<b ) then return b else return a end
  end  
  
  def toJSArray(ar)
    if( ar.nil? || ar.size==0 ) 
      return "()"
    else
      if( !ar.kind_of? Array ) then ar = ar.split(//) end
      ret = "("
      for i in 0..max(0,(ar.size-2)) do 	
        ret += "'"+ar[i].to_s+"',"
      end
      ret += "'"+ar.last.to_s+"')"
    end
    ret
  end  
  
  def getMetricPos(a,b)
    ret = ""
    i=a
    while(i<b)
      k = i+1
      if( (k%@@majorTicks)==0 && i<(b-k.to_s.length) )
        ret += k.to_s		
        i   += k.to_s.length-1
      else
        ret += " "
      end
      i += 1
    end
    #trailing_blancs = b-a-ret.length;
    #ret += " " * trailing_blancs
    ret
  end
	
  def getMetricTicks(a,b)
    ret = ""
    f = ((b-a)/@@minorTicks).to_i
    0.upto(f-1){ |i|
      ret += sprintf("%#{@@minorTicks}s","|")
    }
    trailing_blancs = b-a-ret.length;
    ret += " " * trailing_blancs
    ret
  end
  
  
end
