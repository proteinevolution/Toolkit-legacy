class GdpredJob < Job
  
  @@linewidth = 80
  @@descr_width = 17
  @@metric_bgcolor = "#d9e0e0"
  @@helix_color = "#ff8284"
  @@sheet_color = "#739cff"

  @@export_ext = "export"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export
    query    = readQuery
#    gdpred  = readGdpred
 #   psipred = readPsipred    

    data     = ""
    len      = query['sequence'].length
    i        = 0
    
    while( i<len )
      stop = min(i+@@linewidth, len)
      logger.debug("Stop: "+stop+"\n")
      data += sprintf("%-#{@@descr_width}s", "QUERY")
      data += query['sequence'][i..(stop-1)] + "\n"
  #    data += export_ss("SS PSIPRED", psipred, i, stop-1)
   #   data += export_ss("GDPRED", gdpred, i, stop-1)
    end
    logger.debug("DATA: "+data+"\n")                     
    data
    #ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end 

  # add your own data accessors for the result templates here! For example:
  attr_reader :legend, :data, :header, :sequence

  #Overwrite before_results to fill your job object with result data before result display
  def before_results(controller_params)
    logger.debug("Ich bin jetzt in before_result!\n")
    h = readQuery
    @header = h['header']
    @sequence = h['sequence']
    logger.debug("Header: "+@header+"\n")
    logger.debug("Sequence: "+@sequence+"\n")
    @data = getData
    #@legend = printLegend
  end
  

  def getData
    query = readQuery
    #psipred = readPsipred
   # gdpred = readGdpred

    data = ""

    #write javascript
    data += "\n"+'<script type="text/javascript">' +"\n"
    data += 'initInfo(); '+"\n"
    data += 'RESIDUES="' +query['sequence']+'"; '+"\n"
  #  data += 'PSIPRED_CONF=new Array'+toJSArray( psipred['conf'] )+";\n"
   # data += 'JNET_CONF=new Array'+toJSArray( jnet['conf'] )+";\n"
    data += '</script>' +"\n"


    len = query['sequence'].length
    i = 0
    while(i<len)
      stop = min(i+@@linewidth, len)
      data += sprintf("<span>%-#{@@descr_width}s</span>", "")
      data += "<span style=\"background-color:#{@@metric_bgcolor};\">"+getMetricPos(i, stop)+"</span>\n"

      data += sprintf("<span>%-#{@@descr_width}s</span>", "")
      data += "<span style=\"background-color:#{@@metric_bgcolor};\">"+getMetricTicks(i, stop)+"</span>\n"
      data += printSEQHTML(query['sequence'].split(//),"aa",i,stop)

   #   data += printSSHTML("SS PSIPRED", "psipred", psipred, i, stop)
    #  data += printGDHTML("GDPRED", "gdpred", gdpred, i, stop)

      data += "\n"
      i += @@linewidth
    end
    data
  end

  def printLegend
    ret += "<span>SS = </span><span style=\"background-color: #{@@helix_color};\"> Alpha-Helix </span><span style=\"background-color: #{@@sheet_color};\"> Beta-Sheet </span><span> Secondary Structure</span></br>"

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

  def getMetricPos(a,b)
    ret = ""
    i=a
    while(i<b)
      k = i+1
      if( (k%@@majorTicks)==0 && i<(b-k.to_s.length) )
        ret += k.to_s
        i += k.to_s.length-1
      else
        ret += " "
      end
      i += 1
    end
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

          

  #your own data accessors for the result templates here! For example:
  # attr_reader :some_results_data
  
  
  # Overwrite before_results to fill you job object with result data before result display
  # def before_results(controller_params)
  #    @some_results_data = ">header\nsequence"
  # end
  
  
  
end
