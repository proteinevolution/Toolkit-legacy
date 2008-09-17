class RepperJob < Job
  
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
  
  
  attr_reader :psipred, :coils, :overview, :repper, :length, :sequence
  
  
  def before_results(controller_params)
  
    @basename = File.join(job_dir, jobid)
    @psipred = nil
    @coils = nil
    @overview = nil
    @repper = nil
    
    if (File.exists?(@basename + "_psipred.png"))
    	@psipred = true
    end
    
    if (File.exists?(@basename + "_ncoils.png"))
    	@coils = true
    end
    
    if (File.exists?(@basename + "_overview.png"))
    	@overview = true
    end
    
    if (File.exists?(@basename + "_repper.png"))
    	@repper = true
    end
    
    @length = 0
    data = ""
    check = false
    res = IO.readlines(@basename + ".in").map {|line| line.chomp}
    res.each do |line|
    	if (line =~ /^>/)
    		if (check) then break end
    		check = true
    	else
    		data += line
    	end
    end
    @length = data.length
    
    ### preparing to draw sequence
    data.gsub!(/(.{70})/, '\1'+"\n")
    array = data.split("\n")
    insert = "         \'         \'         \'         \'         \'         \'          "
    right = (@length / 70.0).ceil * 70
    len1 = right.to_s.length
    space = ""
    space2 = (" " * len1)
    
    @sequence = ""
    
    if @psipred
    
      pred = ""
      #preparing to get pred from *horiz for color-coding
      res = IO.readlines(@basename + ".horiz")
      res.each do |line|
      	if (line =~ /^Pred:\s+(\S+)\s*$/)
      		pred += $1
      	end
      end
      
      pred.gsub!(/(.{70})/, '\1'+"\n")
      col = pred.split("\n")
      
      for i in 0...array.size
        line = ""
        chars = array[i].split(//)
        colors = col[i].split(//)
        # E = strand (green), H = helix (red) C = coil (black)
        for j in 0...chars.size
          if (colors[j] == "E")
            line += "<span style=\"color: #00c000\">" + chars[j] + "</span>"
          elsif (colors[j] == "H")
            line += "<span style=\"color: #ff0000\">" + chars[j] + "</span>"          
          else
            line += chars[j]
          end
        end
        array[i] = line      
      end      

    
    end
    
    for i in 0...array.size        
      
      l = 1 + i * 70
      r = (i * 70) + 70
      len2 = l.to_s.length
      diff = len1 - len2
      space = (" " * diff)
        
      @sequence += space + l.to_s + ": " + insert + " :" + r.to_s + "\n"
      @sequence += space2 + "  " + array[i] + "\n"
    end
    
  end
  
end
