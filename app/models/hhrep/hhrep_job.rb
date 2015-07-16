class HhrepJob < Job
  
  set_export_file_ext 'hhr'
  
  @@export_ext = ".hhr"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  def export
    lines = IO.readlines(File.join(job_dir, jobid + @@export_ext))
    if @@export_ext == ".hhr"
      ([lines[0]] << lines[6..-1]).join
    else
      lines.join
    end
  end
  
  # add your own data accessors for the result templates here! For example:
  attr_reader :mode, :dthr, :dwin, :qid, :map, :res, :num_hits, :rep_results, :hits, :best5, :best10, :best15
  
  # Overwrite before_results to fill you job object with result data before result display
  def before_results(controller_params)
    action = actions.reverse.find() {|a| a.active } || actions.last
    
    logger.debug "Before results!"
    
    resfile = File.join(job_dir, jobid+".hhr")
    return false if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
    @res = IO.readlines(resfile).map {|line| line.chomp}
    
    # count hits
    @num_hits = 0
    @res.each do |line|
      if (line =~ /^Done!/) then break end
      if (line =~ /^\s*No \d+/) then break end
      line.scan(/^\s*(\d+)\s+\S+\s+/) {|num| @num_hits = num.to_s.to_i}
    end
    
    @best5 = ""
    @best10 = ""
    @best15 = ""
    1.upto([5,@num_hits].min.to_i) {|i| @best5 += i.to_s + " "}
    1.upto([10,@num_hits].min.to_i) {|i| @best10 += i.to_s + " "}	   
    1.upto([15,@num_hits].min.to_i) {|i| @best15 += i.to_s + " "}	   
    
    ###############
    # set parameter
    if (actions.first.flash["mode"].nil?)
      @mode = "onlySS"
      @dthr = "0.4"
      @dwin = "10"
      @qid = "0"
      @hits = Array.new(@num_hits) {|i| "#{(i+1)}"}
    else
      @mode = actions.first.flash["mode"].nil? ? "onlySS" : actions.first.flash["mode"]
      @dthr = actions.first.flash["dthr"].nil? ? "0.4" : actions.first.flash["dthr"]
      @dwin = actions.first.flash["dwin"].nil? ? "10" : actions.first.flash["dwin"]
      @qid = actions.first.flash["qid"].nil? ? "0" : actions.first.flash["qid"]
      @hits = actions.first.flash["hits"].nil? ? Array.new() : actions.first.flash["hits"]
      if (@hits == "all")
        @hits = Array.new(@num_hits) {|i| "#{(i+1)}"}
      else
        @hits = @hits.split(' ')
      end
    end
    @hits.uniq!
    
    if (controller_params['action'] == "results_histogram") then @mode = "histogram" end
    
    logger.debug "Hits: #{@hits.inspect}"		
    logger.debug "Mode: #{@mode}"
    
    ########################
    #open histogram tar file
    if (@mode == "histogram") 
      command = "tar -xzf " + File.join(job_dir, jobid+".tar.gz") + " -C #{job_dir} > /dev/null 2>&1"
      logger.debug "Command: #{command}"
      system(command);
    end
    
    
    #################
    # Parse DMAP-file
    dmapfile = File.join(job_dir, jobid+".dmap")
    return false if !File.readable?(dmapfile) || !File.exists?(dmapfile) || File.zero?(dmapfile)
    dmap = IO.readlines(dmapfile).map {|line| line.chomp}
    @map = Array.new
    dmap.each do |line|
      line.scan(/^\s*(\d+)\s+(\S+)/) do |m, coord|
        hits = @hits.clone
        if (hits.index(m).nil?)
          hits.insert(-1, m)
        else
          hits.delete(m)
        end
        hits = hits.join(' ')
        @map.push("<AREA SHAPE=POLY #{coord} HREF=\"/hhrep/hhrep_reload/#{jobid}?mode=#{@mode}&qid=#{@qid}&dwin=#{@dwin}&dthr=#{@dthr}&hits=#{hits}\" onClick=\"\" TITLE='Self hit #{m}' />")
      end
    end
    
    ###################
    # parse result-file
    space_for_checkbox = "   "
    i = 0
    length = 0
    n_seqs = 0
    @res.each do |line|
      line.scan(/Match.columns\s+(\d+)/) {|x| length = x}
      line.scan(/No.of.seqs\s+(\d+)/) {|x| n_seqs = x}
      if (line =~ /^Command\s+/) 
        i = @res.index(line) 
        break
      end
    end
    i.times {@res.delete_at(1)}
    
    # Format query name line
    @res[0] += " (Length=#{length}, Nseqs=#{n_seqs})"
    @res[0].sub!(/Query\s+/, 'Query:  ')
    @res[0].gsub!(/(^.{95,113}\S) +(\S)/, '\1<br>        \2')
    
    for i in 1...@res.size
      if (@res[i] =~ /^Done!/) 
        break
      elsif (@res[i] =~ /^\s*$/ || @res[i].nil?)
        next
      elsif (@res[i] =~ /^\s*No\s+Hit/)
        # Format title line from summary hit list
        @res[i] = space_for_checkbox + @res[i] + " Shift"
      elsif (@res[i] =~ /^\s*(\d+)\s+\S+/)
        # Format summary hit list
        num = $1.to_i
        @res[i].sub!(/#{num}/, "<a href=##{num}>#{num}</a>")
        @res[i].scan(/(\d+)\s*-\d+\s+(\d+)-\d+\s*\(\d+\)\s*$/) do |q,t|
          @res[i] += " " + sprintf("%4i", (t.to_i - q.to_i))
        end
        checked = @hits.index(num.to_s).nil? ? "" : "checked = \"checked\""
        
        hits = @hits.clone
        if (hits.index(num.to_s).nil?)
          hits.insert(-1, num.to_s)
        else
          hits.delete(num.to_s)
        end
        hits = hits.join(' ')				
        @res[i] = "<input type=\"checkbox\" #{checked} name=\"hits[]\" value=\"#{num}\" onclick=\"document.location.href='/hhrep/hhrep_reload/#{jobid}?mode=#{@mode}&qid=#{@qid}&dwin=#{@dwin}&dthr=#{@dthr}&hits=#{hits}';\" />" + @res[i]
      elsif (@res[i] =~ /^No\s*(\d+)/) 
        # 'No X' line before each query-target alignment			
        @num = $1.to_i
        @res[i].sub!(/(No\s*#{@num})/, "<a name = #{@num}>"+'\1'+"<\/a>")
        @res[i] = space_for_checkbox + @res[i]
        if (@mode == "histogram")
          @res[i] += "<a href=\"#{DOC_ROOTURL}/hhrep/results/#{jobid}##{@num}\" style=\"margin: 5px 10px 10px 10px;\"><img src=\"/images/hhpred/logo_alignments.jpg\" alt=\"Alignments\" title=\"show query-template alignments\" border=\"0\" align=\"middle\" height=\"30\" /></a>"
          insert_histogram(i, @num)
        else
          @res[i] += "<a href=\"#{DOC_ROOTURL}/hhrep/results_histogram/#{jobid}##{@num}\" style=\"margin: 5px 10px 10px 10px;\"><img src=\"/images/hhpred/logo_histogram_single.png\" alt=\"Histograms\" title=\"Show histograms\" border=\"0\" align=\"middle\" height=\"30\" /></a>"
        end
      elsif (@res[i] =~ /^>(\S+)\s+(\S+)\s*([^.;,\[\(\{]*)/)
        # '>name and description' line before each query-target alignment
        @res[i].gsub!(/(^.{95}\S)\s+(\S)/, '\1<br>'+space_for_checkbox+'\2')
        checked = @hits.index(@num.to_s).nil? ? "" : "checked = \"checked\""
        hits = @hits.clone
        if (hits.index(num.to_s).nil?)
          hits.insert(-1, num.to_s)
        else
          hits.delete(num.to_s)
        end
        hits = hits.join(' ')
        @res[i] = "<input type=\"checkbox\" #{checked} name=\"hits[]\" value=\"#{@num}\" onclick=\"document.location.href='/hhrep/hhrep_reload/#{jobid}?mode=#{@mode}&qid=#{@qid}&dwin=#{@dwin}&dthr=#{@dthr}&hits=#{hits}';\" />" + @res[i]
      else
        @res[i] = space_for_checkbox + @res[i]
      end
    end
    
    ##########
    # Coloring
    for i in 1...@res.size
      if (@res[i] =~ /\s*(Q|T) ss_(dssp|pred)\s+(\S+)/)
        # Found a ss_dssp or ss_pred line
        seq = $3
        old_seq = seq.clone
        if (@mode == "onlySS" || @mode == "letters")
          seq.gsub!(/(H+)/, '<span style="color: #D00000;">\1</span>')
          seq.gsub!(/(E+)/, '<span style="color: #0000D0;">\1</span>')
        elsif (@mode == "background")
          seq.gsub!(/(H+)/, '<span style="background-color: #ffb0b0;">\1</span>')
          seq.gsub!(/(E+)/, '<span style="background-color: #b0b0ff;">\1</span>')
        end
        @res[i].sub!(/#{old_seq}/, "#{seq}")
      elsif (@res[i] =~ /\s*(Q|T) Cons(-\S+|ensus)\s+\d+\s+(\S+)/)
        # Found a consensus line
        seq = $3
        old_seq = seq.clone
        if (@mode == "letters" || @mode == "background")
          seq.gsub!(/([~.-]+)/, '<span style="color: #808080;">\1</span>')
        end 
        @res[i].sub!(/#{old_seq}/, "#{seq}")
      elsif (@res[i] =~ /\s*(Q|T) (\S+)\s+\d+\s+(\S+)/)
        # Found a sequence line
        seq = $3
        old_seq = seq.clone
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
    @hits = @hits.join(" ")
  end
  
  def insert_histogram(i, num)
    mapfile = File.join(job_dir, jobid + "_#{num}.map")
    imgfile = jobid + "_#{num}.png"
    j = i + 1
    
    # Advance to first line of alignment
    while (j < @res.size && @res[j] !~ /^\s*$/) 
      j += 1
    end
    # Insert Image
    if !File.readable?(mapfile) || !File.exists?(mapfile) || File.zero?(mapfile) 
      @res.delete_at(j)
    else
      map = IO.readlines(mapfile).map {|line| line.chomp}
      @res.insert(j, map).flatten!
      j += map.size + 1
    end
    # Delete all lines of alignment up to beginning of next alignment
    while (j < @res.size && @res[j] !~ /^No\s*\d+/ && @res[j] !~ /^Done!/)
      @res.delete_at(j)
    end
  end
  
  def before_view_repeats_results()
    
    @rep_results = []
    
    resfile = File.join(job_dir, jobid+".qt.clu")
    return false if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
    @res = IO.readlines(resfile).map {|line| line.chomp}
    
    @res.each do |line|
      if (line =~ /^\S+\s+(\S+)/)
        seq = $1
        old_seq = $1
        seq.gsub!(/([WYF]+)/, '<span style="background-color: #00c000;">\1</span>')
        seq.gsub!(/(C+)/, '<span style="background-color: #ffff00;">\1</span>')
        seq.gsub!(/([DE]+)/, '<span style="background-color: #6080ff;">\1</span>')
        seq.gsub!(/([LIVM]+)/, '<span style="background-color: #02ff02;">\1</span>')
        seq.gsub!(/([KR]+)/, '<span style="background-color: #ff0000;">\1</span>')
        seq.gsub!(/([QN]+)/, '<span style="background-color: #e080ff;">\1</span>')
        seq.gsub!(/(H+)/, '<span style="background-color: #ff8000;">\1</span>')
        seq.gsub!(/(P+)/, '<span style="background-color: #a0a0a0;">\1</span>')
        
        line.sub!(/#{old_seq}/, "#{seq}")
        @rep_results << line
      end
    end
    
  end

end
