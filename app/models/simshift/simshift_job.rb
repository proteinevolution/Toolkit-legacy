# -*- coding: iso-8859-1 -*-
class SimshiftJob < Job
  
  #attr_accessor :outformat 
  
  attr_reader :results , :outformat
  @@export_ext = ".align"
  
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
  
  def before_results(controller_params = nil)
    
    logger.debug "Before results on job #{jobid}"
    
    self.viewed_on = Time.now
    self.save!
    @results = []
    @alignments = []
    @alignment = []
    @fullA = params['fullA'] ? 'T' : 'F'
    linecounter = 1
    basename= "#{job_dir}/#{jobid}"
    
    if @fullA == 'T'
      resultfile = File.join("#{job_dir}","#{jobid}.align2")
      raise("ERROR file not readable!#{job_dir}#{jobid}")if !File.readable?(resultfile)
      raise("ERROR file does not exist!#{job_dir}#{jobid}")if !File.exists?(resultfile)
      raise("ERROR file is zero!#{job_dir}#{jobid}") if File.zero?(resultfile)
      results = File.open(resultfile, "r")
      lines2 = results.readlines
      
      #fasta outputformat                                                                                                                                                                            
      i = 0  
      headlinecounter = 1
      while i<lines2.length
        lines2[i].chomp!
        lines2[i]=~/^([\w\.]+)\s+\((\d\.\d+e-\d+)\)/
        template = $1
        evalue = $2
        #scop identifier?                                                                                                                                                                            
        if template =~ /^[defgh](\d[a-z0-9]{3})([a-z0-9_\.])[a-z0-9_]/
          i = i+1
        else
          @alignment.push("<pre>")
          s = 0
          while s<lines2[i].length
            lines2[i].chomp!
            lines2[i+1].chomp!
            if lines2[i].length > s+80-1
              align1 = lines2[i].slice(s..(s+80) )
              align2 = lines2[i+1].slice(s..(s+80))
              @alignment.push("Query   : "+align1+"<br>")
              @alignment.push("Template: #{align2}<br><br>")
              
            else
              align1 = lines2[i].slice(s..lines2[i].length)
              align2 = lines2[i+1].slice(s..(lines2[i+1].length))
              @alignment.push("Query   : "+align1+"<br>")
              @alignment.push("Template: #{align2}<br><br><br><br><br>")
              break
            end
            s = s+80
          end
          i = i+2
          @alignment.push("</\pre>")
          @alignments.push(@alignment.join)
          @alignment.clear
        end
      end #end while                                                                                                                                                                                 
    end
    
    
    if  File.exists?("#{basename}.html")
      raise("Cannot open #{basename}.html!")  if !File.readable?("#{basename}.html")|| !File.exists?("#{basename}.html") || File.zero?("#{basename}.html")
      hhfile =  File.open("#{basename}.html", "r")
      hhviz = hhfile.readlines
      hhviz.each {|a| @results.push( a)}
    end
    @results.push("<br>")
    
    resultfile = File.join("#{job_dir}","#{jobid}.align")
    raise("ERROR file not readable!#{job_dir}#{jobid}")if !File.readable?(resultfile)
    raise("ERROR file does not exist!#{job_dir}#{jobid}")if !File.exists?(resultfile)
    raise("ERROR file is zero!#{job_dir}#{jobid}") if File.zero?(resultfile)
    results = File.open(resultfile, "r")
    line = results.readlines
    
    
    
    i = 1
    #residue outputformat
    
    while i<line.length
      logo_attr ="border=\"0\" align=\"middle\""
      link_attr = "style=\"margin: 5px 10px 10px 10px;\""
      
      
      line[i]=~/^([\w\.]+)\s+(\d\.\d+e-\d+)/
      template = $1
      evalue = $2
      #scop identifier?
      if template =~ /^[defgh](\d[a-z0-9]{3})([a-z0-9_\.])[a-z0-9_]/
        pdbcode   = $1
        scophref="http:\/\/scop.mrc-lmb.cam.ac.uk\/scop\/search.cgi?sid=#{template}"
        pubmedhref="http:\/\/www.ncbi.nlm.nih.gov\/entrez\/query.fcgi?CMD=search&db=pubmed&term=#{pdbcode}"
        pdbhref ="http://pdb.rcsb.org/pdb/explore.do?structureId=#{pdbcode}"
        tstructhref =""
        imoltalkhref =""
        mmdbhref ="http://www.ncbi.nlm.nih.gov/sites/entrez?SUBMIT=y&db=structure&orig_db=structure&term=#{pdbcode}"
        msdhref ="http://www.ebi.ac.uk/pdbe-srv/view/entry/#{pdbcode}"
        

        pdblink = "<a href=\http://www.rcsb.org/pdb/explore/explore.do?structureId=#{pdbcode}>#{template}<\/a>"
        line[i] ="<p><font size ='2'><b>No #{i}<\/b>  "+line[i]     
        line[i].sub!(/#{template}/,"#{pdblink}<br>")
        line[i].sub!(/#{evalue}/,"<b>E-value: <\/b>#{evalue}")  
        line[i].sub!(/No\s+#{i}<\/b> /, "<a name = #{i}>No #{i}<\/a><\/b>&nbsp;&nbsp; &nbsp; &nbsp;
   
<a href=\"#{scophref}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_SCOP.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>\n
<a href=\"#{pdbhref}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_PDB.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>\n   
<a href=\"#{mmdbhref}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_MMDB.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>\n   
<a href=\"#{msdhref}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_MSD.jpg\" alt=\"SCOP\" title=\"SCOP\" #{logo_attr} height=\"25\"></a>\n   
<a href=\"#{pubmedhref}\" target=\"_blank\" #{link_attr} ><img src=\"#{DOC_ROOTURL}/images/hhpred/logo_pubmed.jpg\" alt=\"PubMed\" title=\"PubMed\" #{logo_attr} height=\"20\"></a>\n<br>")
        line[i].sub!(/\(/,"<\/font><br><table>") 
        line[i].sub!(/\)\)/,")")
        line[i].gsub!(/(\(-{0,1}\d+-\w:-{0,1}\d+-\w\))/,"<td><pre>"+'\1'+"<\/pre><\/td>")
        line[i].gsub!(/((<td><pre>\(-{0,1}\d+-\w:-{0,1}\d+-\w\)<\/pre><\/td>){7})/,'<tr width ="40">\1</tr>') 
        line[i].sub!(/(\(\d+-\w:\d+-\w\))<br>\s*\)/,'\1') 
      end
      @results.push(line[i] +"<\/table><br></p>")
      @results.push(@alignments[i])
      i = i+1
    end
    
    @results.push("<br>\n")
    @results.push("Please cite as appropriate: \n")
    @results.push("<BR><BR><B><i>SimShift</i>: Simon W. Ginzinger, Thomas Gräupl, Volker Heun (2007) SimShiftDB: <BR>\n ")
    @results.push("Chemical-Shift-Based Homology Modeling. <\/B>")
  end      
  
end
