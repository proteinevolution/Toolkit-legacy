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
  @@tm_color      = "#74e25f"
  @@do_color      = "#ddc57c"
  @@sp_color      = "#FF99FF"
  @@cleavage_color= "#33FFCC"
  @@cc_color      = "#be80ff"



  @@sol_color     = "#ffff69"

  @@metric_bgcolor = "#d9e0e0"

  @@descr_width   = 17

  @@export_ext    = ".quick2d"

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
   # memsat   = readMemsat
    memsat_svm = readMemsatSvm
    phobius = readPhobius
    phobius_sp =readPhobius_sp
    hmmtop   = readHMMTOP
    disopred = readDisopred
    iupred = readIUPred
  #  vsl2     = readVSL2
    coils    = readCoils
    predisi  = readPREDISI
    
    # Alignment Conservation, alco instead of al2co, don't now if numbers allowed in variable name
    #alco = readAlco

    data     = ""
    len      = query['sequence'].length
    i        = 0
    while( i<len )
      stop = min(i+@@linewidth, len)
      data += sprintf("%-#{@@descr_width}s", "QUERY")
      data += query['sequence'][i..(stop-1)] + "\n"

      if (exist_ss_params(psipred))
        data += export_ss("SS PSIPRED", psipred, i, stop-1)
      end
      if(exist_ss_params(jnet))
        data += export_ss("SS JNET", jnet, i, stop-1)
      end

      if(!prof_o.nil? and !prof_o.empty? and !(prof_o['pred'].nil? or prof_o['pred'] !~ /\w/))
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
      end
      
      if(exist_ss_params(prof_r))
        data += export_ss("SS PROF (Rost)", prof_r, i, stop-1)
      end

      if(!coils.nil? and !coils.empty? and !coils['ccpred'] == "")
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
      end

      #data += export_tm("TM MEMSAT2", memsat, i, stop-1)
      if(!hmmtop.nil? and !hmmtop.empty?)
        data += export_tm("TM HMMTOP", hmmtop, i, stop-1)
      end
      if(!predisi.nil? and !predisi.empty?)
        data += export_sp("SP PREDISI", predisi, i, stop-1)
      end
      if(!hmmtop.nil? and !hmmtop.empty?)
        data += export_sp("SP HMMTOP", hmmtop, i, stop-1)
      end
      
      if(exist_tm_params?(memsat_svm))
        data += export_tm("TM MEMSATSVM",memsat_svm, i, stop-1)
      end
      if(exist_tm_params?(phobius))
        data += export_tm("TM PHOBIUS", phobius, i, stop-1)
      end
      #'conf'=>"", 'pred'=>"", 'sol'=>"", 'tmpred'=>"", 'tmconf'=>""
      if(exist_tm_params?(prof_r))
        data += export_tm("TM PROF (Rost)", prof_r, i, stop-1)
      end

      if(exist_do_params?(disopred))
        data += export_do("DO DISOPRED2", disopred, i, stop-1)
      end
      if(exist_do_params?(iupred))
        data += export_do("DO IUPRED", iupred, i, stop-1)
      end
      #data += export_do("DO VSL", vsl2, i, stop-1)

#      if(!prof_r.nil? and !prof_r.empty?)
#        data += export_so("SO PROF (Rost)", prof_r, i, stop-1)
#      end
#      if(!jnet.nil? and !jnet.empty?)
#        data += export_so("SO JNET", jnet, i, stop-1)
#      end
      
      data += "\n\n"
      i += @@linewidth
    end
    data
  end
  
  def exist_ss_params(dic)
    !dic.nil? and !dic.empty? and !((dic['pred'].nil? or dic['pred'] !~ /\w/) and (dic['conf'].nil? or dic['conf'] !~ /\w/))
  end
  
  def exist_tm_params?(dic)
    !dic.nil? and !dic.empty? and !((dic['tmpred'].nil? or dic['tmpred'] !~ /\w/) and (dic['tmconf'].nil? or dic['tmconf'] !~ /\w/))
  end
  
  def exist_do_params?(dic)
    !dic.nil? and !dic.empty? and !((dic['dopred'].nil? or dic['dopred'] !~ /\w/) and (dic['doconf'].nil? or dic['doconf'].empty? or dic['doconf'] !~ /\w/))
  end
  
  def exist_so_params?(dic)
    !dic.nil? and !dic.empty? and !((dic['sol'].nil? or dic['sol'] !~ /\w/))
  end


  def export_ss(name, blub, a, b)
    ret = sprintf("%-#{@@descr_width}s", name)
    if( !blub.nil? && !blub['pred'].nil?)
      ret += blub['pred'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret += sprintf("%-#{@@descr_width}s", "CONF")
    if( !blub.nil? && !blub['conf'].nil?)
      ret += blub['conf'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret
  end


  def export_tm(name, blub, a, b)
    ret = sprintf("%-#{@@descr_width}s", name)
    if( !blub.nil? && !blub['tmpred'].nil?)
      ret += blub['tmpred'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret += sprintf("%-#{@@descr_width}s", "CONF")
    if( !blub.nil? && !blub['tmconf'].nil? && !blub['tmconf'].is_a?(Array))
      ret += blub['tmconf'][a..b] + "\n"
    else
      ret += "\n"
    end
    ret
  end


  def export_sp(name, blub, a, b)
    ret = sprintf("%-#{@@descr_width}s", name)
    if( !blub.nil? && !blub['sppred'].nil?)
      ret += blub['sppred'] + "\n"
      blub['sppred']=""
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
    if( !blub.nil? && !blub['doconf'].nil? && !blub['doconf'].is_a?(Array))
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
 #   memsat   = readMemsat
    memsat_svm = readMemsatSvm
    phobius = readPhobius
    hmmtop    = readHMMTOP
    phobius_sp = readPhobius_sp
    predisi  = readPREDISI
    
    # Alignment Conservation
    
    alcoent = readAlcomap('al2comapent')
    alcovar = readAlcomap('al2comapvar')
    alcossp = readAlcomap('al2comapssp')

    #logger.debug "L248 GetData HMMTOP  ->  #{hmmtop}"
    logger.debug "L248 GetData PREDISI ->  #{predisi}"
    
    disopred = readDisopred
    iupred = readIUPred
# vsl2     = readVSL2
    coils    = readCoils

    data     = ""

    # write javascript
    data += "\n"+'<script type="text/javascript">' +"\n"
    data += 'initInfo(); '+"\n"
    data += 'RESIDUES="' +query['sequence']+'"; '+"\n"
    #data += 'ALCO="'     +alco['cons']+'";      '+"\n"
    data += 'PSIPRED_CONF=new Array'+toJSArray( psipred['conf'] )+";\n"
    data += 'JNET_CONF=new Array'+toJSArray( jnet['conf'] )+";\n"
    data += 'PROFROST_CONF=new Array'+toJSArray( prof_r['conf'] )+";\n"
    data += 'PROFROST_TMCONF=new Array'+toJSArray( prof_r['tmconf'] )+";\n"
    data += 'MEMSATSVM_TMCONF=new Array'+toJSArray(memsat_svm['tmconf'])+"; \n"
    data += 'PROFOUALI_CONF=new Array'+toJSArray( prof_o['conf'] )+";\n"
    data += 'DISOPRED2_CONF=new Array'+toJSArray( disopred['doconf'] )+";\n"
    data += 'IUPRED_CONF=new Array'+toJSArray( iupred['doconf'] )+";\n"
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
      data += printCONSHTML("CO AL2CO_ENT", "alcoent", alcoent['cons'].split(//), i, stop  ) 
      data += printCONSHTML("CO AL2CO_VAR", "alcovar", alcovar['cons'].split(//), i, stop  ) 
      data += printCONSHTML("CO AL2CO_SSP", "alcossp", alcossp['cons'].split(//), i, stop  ) 
      data += printSSHTML("SS PSIPRED", "psipred", psipred, i, stop)
      data += printSSHTML("SS JNET", "jnet", jnet, i, stop)
      data += printSSHTML("SS Prof (Ouali)", "prof_o", prof_o, i, stop)
      data += printSSHTML("SS Prof (Rost)", "prof_r", prof_r, i, stop)
      data += printCCHTML("CC Coils", "coils", coils, i, stop)

   #   data += printTMHTML("TM MEMSAT2", "memsat", memsat, i, stop)
      data += printTMHTML("TM HMMTOP", "hmmtop", hmmtop, i, stop)
      data += printTMHTML("TM PROF (Rost)", "prof_tm", prof_r, i, stop)
      data += printTMHTML("TM MEMSAT-SVM","memsat_svm", memsat_svm, i, stop)
      data += printTMHTML("TM PHOBIUS","phobius", phobius, i, stop)
      
      data += printSPHTML("SP PREDISI", "predisi", predisi, i, stop)
      data += printSPHTML("SP PHOBIUS", "phobius_sp", phobius_sp, i, stop)
      data += printDOHTML("DO DISOPRED2", "disopred", disopred, i, stop)
      data += printDOHTML("DO IUPRED","iupred",iupred,i,stop)
#      data += printDOHTML("DO VSL2", "vsl2", vsl2, i, stop)

      #data += printSOLHTML("SO Prof (Rost)", "sol_prof", prof_r, i, stop)

      #data += printSOLHTML("SO JNET", "sol_jnet", jnet, i, stop)


      data += "\n"
      i += @@linewidth
		end
    data
  end


  def printLegend
    ret = "";
    ret += "<span>SS = </span><span style=\"background-color: #{@@helix_color};\"> Alpha-Helix </span><span style=\"background-color: #{@@sheet_color};\"> Beta-Sheet </span><span> Secondary Structure</span></br>"
    ret += "<span>CO = </span><span style=\"background-color: rgb(255,0,0);\">High</span><span style=\"background-color: rgb(0,0,255); \">Low</span><span>Conservation</span></span></br>"
    ret += "<span>CC = </span><span style=\"background-color: #{@@cc_color};\">Coiled Coils</span></br>"
    ret += "<span>TM = </span><span style=\"background-color: #{@@tm_color};\">Transmembrane</span><span> (\'+\'=outside, \'-\'=inside)</span></br>"
    ret += "<span>DO = </span><span style=\"background-color: #{@@do_color};\">Disorder</span></br>"
    ret += "<span>SP = </span><span style=\"background-color: #{@@sp_color};\">Signal Peptide</span><span style=\"background-color: #{@@cleavage_color};\"> Cleavage Site </span></br>"
    #ret += "<span>SO = </span><span style=\"background-color: #{@@sol_color};\">Solvent accessibility</span><span> (A <b>b</b>urried residue has at most 25% of its surface exposed to the solvent.)</span></br>"
  end


  def printSEQHTML(seq, id_name, a, b)
    data = sprintf("<span>%-#{@@descr_width}s</span>", "")
    a.upto(b-1){ |j|
      data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{seq[j]}</span>"
    }
    data +="\n"
    data
  end

  # Prints the necessary HTML code to display Aligment conservation computed by AL2CO
  def printCONSHTML(name, id_name, cons, a, b)
    data = sprintf("<span>%-#{@@descr_width}s</span>", name)
    a.upto(b-1){ |j|
      
      # Determine the color 
      rgb =  convert_to_rgb(0, 10, cons[j].to_i, [[0, 0, 255], [0, 255, 0], [255, 0, 0]])
      data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\" style=\"background-color: #{rgb_to_css(rgb)};\" >#{cons[j]}</span>"
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
    if(hash['tmpred'][j].nil?)
      data+=" "
    else
      if(hash['tmpred'][j].chr=="X")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@tm_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['tmpred'][j].chr}</span>"
      else
        data += "<span id=\"#{j}#{id_name}\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['tmpred'][j].chr}</span>"
      end
      end
    }
    data += "\n"
    data
  end

  def printSPHTML(name, id_name, hash, a, b)
    if( hash['sppred'].nil?) then return "" end
    data = ""
    data += sprintf("<span>%-#{@@descr_width}s</span>", name)
    a.upto(b-1){ |j|
    if(hash['sppred'][j].nil?)
      data+=" "
    else
      if(hash['sppred'][j].chr=="S")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@sp_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['sppred'][j].chr}</span>"
      elsif (hash['sppred'][j].chr=="C")
        data += "<span id=\"#{j}#{id_name}\"style=\"background-color: #{@@cleavage_color};\" onmouseover=\"showInfo('#{j}aa');\" onmouseout=\"hideInfo();\">#{hash['sppred'][j].chr}</span>"
        
      end
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
    
    @query_sequence_length = ret['sequence'].length
    
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


  # This function is currently not used. See readAlcomap
  #

  #def readAlco
  #    if (!File.exists?(self.actions[0].flash['al2cofile'])) then return {} end
  #    ret={'cons'=>[]}
  #    ar = IO.readlines(self.actions[0].flash['al2cofile'])
  #    ar.each do |line|

  #        # Line matches conservation line
  #        if(line =~ /^[0-9]+\s+[A-Za-z\-]+\s+(\S+)/)

  #            ret['cons'] << $1
  #        end
  #    end
  #    return ret
  #end
  #


  def readAlcomap(filename)
      if (!File.exists?(self.actions[0].flash[filename])) then return {} end
      ret={'cons'=>""}
      ar = IO.readlines(self.actions[0].flash[filename])
      ar.each do |line|

          # Line matches conservation line
          if(line =~ /^Conservation:\s+(\S+)$/)

              ret['cons'] += $1
          end
      end
      return ret
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
      elsif( line =~ /\s*ALIGN\s+:\s+(\S+)\s*$/ )
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

    if (ret['tmpred']=="") then ret['tmpred'] = nil end
    if (ret['tmconf']=="") then ret['tmconf'] = nil end

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


  #~ def readMemsat
    #~ if( !File.exists?( self.actions[0].flash['memsatfile'] ) ) then return {} end
    #~ ret={'conf'=>"", 'tmpred'=>""}
    #~ ar = IO.readlines( self.actions[0].flash['memsatfile'] )
    #~ bool = false
    #~ ar.each do |line|
      #~ if( line =~ /FINAL PREDICTION/ )
        #~ bool = true
      #~ elsif( bool && line =~ /^\s*([-\+IOSX]+)\s*$/ )
        #~ ret['tmpred']+=$1
      #~ end
    #~ end
    #~ ret['tmpred'].gsub!(/O/, "X")
    #~ ret['tmpred'].gsub!(/I/, "X")
    #~ ret
  #~ end

#########################################################################################
# Extract all Disordered Information from Disopred .horiz_d file
#
#DISOPRED predictions for a false positive rate threshold of: 5%
#
#conf: 960000000000000000000000000000000000000000000000000000000000
#pred: **..........................................................
#  AA: MMLALVCVLFGFAWLIDRLGLRRFSRVLGLTSVLLVFAVGCGPLPSWMLHHLQHTGVNDF
#              10        20        30        40        50        60
#########################################################################################
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

  def readIUPred
    if( !File.exists?( self.actions[0].flash['iupredfile'] ) ) then return {} end
    ret={'doconf'=>[], 'dopred'=>"" }
    ar = IO.readlines( self.actions[0].flash['iupredfile'])
    ar.each do |line|
      if( line =~ /\s*\d+\s\w\s*(\d.\d*)/ )
        if($1.to_f>=0.5)
		ret['dopred']+="D"
	else
		ret['dopred']+=" "
	end
        ret['doconf']<<$1
      end
    end
    ret
  end
#########################################################################################
# Extract the Data from Phobius for SP Prediction
#
# ID   gi
#FT   SIGNAL        1     18
#FT   DOMAIN        1      2       N-REGION.
#FT   DOMAIN        3     13       H-REGION.
#FT   DOMAIN       14     18       C-REGION.
#FT   DOMAIN       19     27       NON CYTOPLASMIC.
#FT   TRANSMEM     28     49
#FT   DOMAIN       50    253       CYTOPLASMIC.
#
#########################################################################################
  def readPhobius_sp
    # Initialize all Variables 
    query    = readQuery
    if( !File.exists?( self.actions[0].flash['phobiusfile'] ) ) then return {} end
    ret={'sppred' =>""}
    ar = IO.readlines( self.actions[0].flash['phobiusfile'])
    
    # Signal Peptide
    sp_start_array = Array.new
    sp_end_array = Array.new
    
    # Cleavage Site
    cs_start_array = Array.new
    cs_end_array = Array.new
    
    
    result=""
    
    
   # Calculate Output from data 
   ar.each do |line|
   
   # Check for Signal Peptide
    line =~ /SIGNAL/
      if $& then
        line =~ /(\d+)\s+(\d+)/
        sp_start_array.push($1)
        sp_end_array.push($2)
        logger.debug "L80 SIGNAL PEPTIDE Start#{$1} End #{$2} "
      end
   
    
    # Check for Cleavage Site in Signal
    line =~ /C-REGION/
      if $& then
        line =~ /(\d+)\s+(\d+)/
        cs_start_array.push($1)
        cs_end_array.push($2)
        logger.debug "L80 Cleavage Site Start#{$1} End #{$2} "
      end
    
     end
    
    result=""
    for  i in 0..@query_sequence_length
      result = result+ "--"  
    end
    
    # Signal Peptide
    sp_start_array.length.times { |i|
    result[sp_start_array[i].to_i-1..sp_end_array[i].to_i] ='S'*( sp_end_array[i].to_i+1 - sp_start_array[i].to_i )
    }
    
    # Cleavage Site
    cs_start_array.length.times { |i|
    result[cs_start_array[i].to_i-1..cs_end_array[i].to_i] ='C'*( cs_end_array[i].to_i+1 - cs_start_array[i].to_i )
    }
    
    ret['sppred'] += result
    
    ret
  end



#########################################################################################
# Extract the Data from Phobius for TM Prediction
#
# ID   gi
#FT   SIGNAL        1     18
#FT   DOMAIN        1      2       N-REGION.
#FT   DOMAIN        3     13       H-REGION.
#FT   DOMAIN       14     18       C-REGION.
#FT   DOMAIN       19     27       NON CYTOPLASMIC.
#FT   TRANSMEM     28     49
#FT   DOMAIN       50    253       CYTOPLASMIC.
#
#########################################################################################
  def readPhobius
    
    query    = readQuery
    
    if( !File.exists?( self.actions[0].flash['phobiusfile'] ) ) then return {} end
    ret={'tmconf'=>[], 'tmpred'=>"" , 'sppred' =>""}
    ar = IO.readlines( self.actions[0].flash['phobiusfile'])
    start_array = Array.new
    end_array = Array.new
    
    # Outside + Domains
    outside_start_array = Array.new
    outside_end_array   = Array.new
    
    # Signal Peptide
    sp_start_array = Array.new
    sp_end_array = Array.new
    
    result=""
    
    
    ar.each do |line|
      
      # Check for Signal Peptide
      line =~ /SIGNAL/
      if $& then
        line =~ /(\d+)\s+(\d+)/
        sp_start_array.push($1)
        sp_end_array.push($2)
      end
      
      # Check for Outside Domains 
      line =~ /NON CYTOPLASMIC/
      if $& then
        line =~ /(\d+)\s+(\d+)/
        outside_start_array.push($1)
        outside_end_array.push($2)
      end
      
      
      # Check for Transmembrane Fragment
      line=~ /TRANSMEM/
      if $& then
        line =~ /(\d+)\s+(\d+)/
        start_array.push($1)
        end_array.push($2)
      end
      
    end

  result=""
  for  i in 0..@query_sequence_length
    result = result+ "--"  
   end

    # Set Transmembrane Regions
    start_array.length.times { |i|
    result[start_array[i].to_i-1..end_array[i].to_i] ='X'*( end_array[i].to_i+1 - start_array[i].to_i )
    }
    # Set Outside Regions
    outside_start_array.length.times { |i|
    result[outside_start_array[i].to_i-1..outside_end_array[i].to_i] ='+'*( outside_end_array[i].to_i+1 - outside_start_array[i].to_i )
    }

    # Set Signal Peptide Regions, we need to check wether the next Element is in / outside find the next element to the Sp 
    # Test for  outside Regions, Sp can only exist once
    start_after_sp = sp_end_array[i].to_i+1
    outside_start_array.length.times { |i|
    if outside_start_array[i].to_i == start_after_sp
      start_after_sp = '+'
    else
      start_after_sp = '-'
    end
    }
    sp_start_array.length.times { |i|
    result[sp_start_array[i].to_i-1..sp_end_array[i].to_i] =start_after_sp*( sp_end_array[i].to_i+1 - sp_start_array[i].to_i )
    }

    sp_result = ""
    # Signal Peptide Identification
    sp_start_array.length.times { |i|
    sp_result[sp_start_array[i].to_i-1..sp_end_array[i].to_i] =start_after_sp*( sp_end_array[i].to_i+1 - sp_start_array[i].to_i )
    }
    ret['sppred'] += sp_result


#  outside_start_array.length.times { |i|
#    (outside_start_array[i].to_i-1-result.length).times { result +=" " }
#    (outside_end_array[i].to_i-result.length).times { result += "+" }
#  }

#	start_array.length.times { |i|
#		(start_array[i].to_i-1-result.length).times { result +=" " }
#		(end_array[i].to_i-result.length).times { result += "X" }
#	}
	(readQuery['sequence'].length-result.length+1).times{ result += " " }
	ret['tmpred'] += result

	ret
  end

#########################################################################################
# Extract the information from the hmmtop output, see example output below
#
#
#>HP: 297 gi 312803 emb CAA43985 1  cdk2  Homo sapiens   OUT   0
#The best model:
#
#     seq  MENFQKVEKI GEGTYGVVYK ARNKLTGEVV ALKKIRDTET EGVPSTAIRE    50
#     pred OOOOOOOOOO OOOOOOOOOO OOOOOOOOOO OOOOOOOOOO OOOOOOOOOO
#
#     seq  ISLLKELNHP NIVKLLDVIH TENKLYLVFE FLHQDLKKFM DASALTGIPL   100
#     pred OOOOOOOOOO OOOOOOOOOO OOOOOOOOOO OOOOOOOOOO OOOOOOOOOO
#########################################################################################
  def readHMMTOP
    if( !File.exists?( self.actions[0].flash['hmmtopfile'] ) ) then return {} end
    ret={'tmpred'=>""}
    ar = IO.readlines( self.actions[0].flash['hmmtopfile'] )
    ar.each do |line|
      if( line =~ /^\s*pred\s*?(.*)$/ )
        ret['tmpred']+=$1
      end
    end
    logger.debug "#{ret['tmpred']}"
    ret['tmpred'].gsub!(/\s+/, "")
    ret['tmpred'].gsub!(/[Ii]/, "-")
    ret['tmpred'].gsub!(/[Oo]/, "+")
    ret['tmpred'].gsub!(/H/, "X")
    logger.debug "#{ret['tmpred']}"
    ret
  end

  def readPREDISI

    if( !File.exists?( self.actions[0].flash['predisifile'] ) ) then return {} end
    ret={'sppred'=>""}
    ar = IO.readlines( self.actions[0].flash['predisifile'] )
    # Predisi should output only one line and then 
    ar.each do |line|
     
      logger.debug "L673 PREDISI : #{line}"
      if( line =~ /(\d+)\s+(Y|N)\s+(.+)/ )
        cleavage_count = $1
        if($2 =~ /Y/)
          ret['sppred']+= "S" * (cleavage_count.to_i-1)
          ret['sppred']+= "C"
        end
        logger.debug "L676  #{$1} #{$2} #{$3} "
      end
    end
    ret
  end




  def readMemsatSvm
    if( !File.exists?(self.actions[0].flash['memsatsvmfile'])) then return { } end
    ret={'tmpred'=>"", 'tmconf'=>[]}
    ar = IO.readlines(self.actions[0].flash['memsatsvmfile'])
    pos = "", score="", result = ""

    #read positions and score
    ar.each do |line|
      line =~ /Topology:/
      if $& then
        pos = line
      end

      line =~ /Score:/
      if $& then
        line =~ /\-*\d+\.\d+/
        score = $&
      end
    end

    if(score.to_f>=0) then
      pos.gsub!(/Topology:\s*/,"")
      i = 0
      #Arrays for start-positions and end-positions and save them
      start_array = Array.new
      end_array = Array.new
      while true do
        pos=~/(\d+)-(\d+)/
        if $1==nil then break end
        start_array[i]=$1
        end_array[i] = $2
        i+=1
        pos.gsub!(/\A(\d+)-(\d+)\,*/,"")
      end

      #X for transmembrane and gap for none and putting the score to the javascript
      start_array.length.times { |i|
        (start_array[i].to_i-1-result.length).times { result +=" "; ret['tmconf']<<"-" }
        (end_array[i].to_i-result.length).times { result += "X"; ret['tmconf'] << score }
      }
      (readQuery['sequence'].length-result.length+1).times{ result += " "; ret['tmconf']<<"-" }
      ret['tmpred'] += result
    else
      (readQuery['sequence'].length).times{ result += " "}
      ret['tmpred'] += result
    end
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

  def convert_to_rgb(minval, maxval, val, colors)

    max_index = colors.length - 1
    v = (val - minval).to_f / (maxval - minval).to_f * max_index
    i1 = v.to_i
    i2 = [v.to_i + 1, max_index].min
    color1 = colors[i1]
    color2 = colors[i2]
    f = v - i1
    return [color1[0] + f*(color2[0]-color1[0]), color1[1] + f*(color2[1]-color1[1]), color1[2] + f*(color2[2]-color1[2])]
  end
  def rgb_to_css(color)

    return "rgb(#{color[0].round},#{color[1].round},#{color[2].round})"
  end

end
