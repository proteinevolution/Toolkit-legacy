class CreatemapAction < Action
  
  if LOCATION == "Munich" && LINUX == 'SL6'
     REPPER = File.join(BIOPROGS, 'repper')
  else
     REPPER = File.join(BIOPROGS, 'repper')
  end
  
  attr_accessor :leftend, :rightend

  validates_shell_params(:leftend, :rightend, {:on => :create})
  
  validates_format_of(:rightend, :leftend, {:with => /^\d+$/, :on => :create, :message => 'Invalid value! Only integer values are allowed!'}) 
  
  def before_perform
  
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    @length = params['length'].to_i
    @endL = params['leftend'].to_i 
    @endR = params['rightend'].to_i
    @coords = params['coords']
    
    # files
    @infile     = @basename+".in"    
    @infile2    = @basename+".in2"
    @outfile    = @basename + ".out"
    @parfile    = @basename + ".ftwin_par"
    @perfile    = @basename + ".ftwin_per2"
    @hydro_data = @basename + ".hydro_data"
    @overview   = @basename + ".ftwin_ov"
    @newseqfile = @basename + ".newseq"

    res = IO.readlines(@parfile)
    perioL = res[1].chomp.to_f
    perioH = res[2].chomp.to_f
    # applying special formula: 2001-4000/value
    @min = 2001 - (4000 / perioL)
    @max = 2001 - (4000 / perioH)
    
  end

  def perform
    params_dump
    
    general_stuff
    
    if (@endL == 0 && @endR == 0)
      if (File.exists?(@outfile) && !File.zero?(@outfile))
          File.delete(@outfile)
      end
      system("touch #{@outfile}")      
      self.status = STATUS_DONE
      self.save!
      job.update_status
      return
    end

    run_third
    print_results

    logger.debug "Commands:\n"+@commands.join("\n")
    queue.submit(@commands)
  end
  
  def general_stuff
  
    if @coords
    
      @coords =~ /(\d+),(\d+)/
      valX = $1.to_i
      valY = $2.to_i
      
      # translating coordinates into the sequence fragment that will be processed
#      @xOffsetL = 95.0;
      xOffsetL = 65.0;
#      @xOffsetR = 544.0;    # 640-544 = 96
      xOffsetR = 515.0;
      yOffsetT = 55;
      yOffsetB = 251;    # 320-251 = 69
      
      # getting begin and end values of the sequence
      # length correction of seq_len for perio4gnuplot.pl
      len = 0
      if (@length <= 50) 
        len = (@length / 5).ceil * 5
      elsif (@length <= 100) 
        len = (@length / 10).ceil * 10
      elsif (@length <= 200) 
        len = (@length / 20).ceil * 20 
      elsif (@length <= 500) 
        len = (@length / 50).ceil * 50 
      elsif (@length <= 1000) 
        len = (@length / 100).ceil * 100
      elsif (@length <= 2000) 
        len = (@length / 200).ceil * 200
      elsif (@length <= 5000) 
        len = (@length / 500).ceil * 500
      elsif (@length <= 10000) 
        len = (@length / 1000).ceil * 1000
      elsif (@length <= 20000) 
        len = (@length / 2000).ceil * 2000 
      end
      
      xScale = (xOffsetR - xOffsetL).to_f / len
      yScale = (yOffsetB - yOffsetT).to_f / (@max - @min)
      
      posInSeq = ((valX - xOffsetL) / xScale).round.to_i
      yValue = (@max - ((valY - yOffsetT) / yScale)).round.to_i
      
	   # getting left end and right end of the sequence with the appropriate periodicity
      xArray = []
	   res = IO.readlines(@overview)
	   res.each do |line|
	     line =~ /^(\d+)\s+(\d+)/
	     x = $1.to_i
	     y = $2.to_i
	     # the value "x" (here: 15) is the threshold due to inexact clicking - can be changed!
        if ( (y - 15) < yValue && yValue < (y + 15) )
          xArray << x.to_i
        end
	   end
	   
	   if xArray.empty? then return end
	   
	   xArray.sort!.uniq!
	   # in which bar is PosInSeq?
	   flag = false
	   @endL = xArray[0]
	   counter = @endL
	   for i in 0...xArray.size
	     if (counter == xArray[i])
	       if (counter == posInSeq || flag)
	         flag = true
	         @endR = counter
	       end
	     else
	       if (!flag)
	         @endL = xArray[i]
	         counter = @endL
	       else
	         break
	       end	     	     
	     end
	     counter += 1
	   end
	   
    else # @coords = nil

      # using input values from textfields: "leftend", "rightend"
      @length = (@endR - @endL).abs + 1
   
    end
  
  end
  

  def run_third
  
    seq = ""
    first = true
    firstseq = ""
    out = File.open(@infile2, "w")
    res = IO.readlines(@infile).map {|line| line.chomp}
    res.shift
    res.each do |line|
      if (line =~ /^>/)
        # extracing substring of specified sequence with edges left, right
        tmp = seq.slice((@endL -1), ((@endR - @endL).abs + 1))
        if (first)
          firstseq = tmp
          first = false
        end
        out.write(">partial input sequence\n" + tmp + "\n")
      else
        seq += line
      end
    end
    # extracing substring of specified sequence with edges left, right
    tmp = seq.slice((@endL -1), ((@endR - @endL).abs + 1))
    if (first)
      firstseq = tmp
      first = false
    end
    out.write(">partial input sequence\n" + tmp + "\n")
    out.close
    
    command = "#{REPPER}/third_profile #{@infile2} #{@parfile} #{@perfile} #{@hydro_data}"
    ## Test if Repper works
    #@commands <<   "#{REPPER}/third_profile #{@infile2} #{@parfile} #{@perfile} #{@hydro_data}"    

    logger.debug "Command: #{command}"
    system(command)
    
    ### preparing to draw sequence
    sequence = ""
    length = firstseq.length
    firstseq.gsub!(/(.{70})/, '\1'+"\n")
    array = firstseq.split("\n")
    insert = "         \'         \'         \'         \'         \'         \'          "
    left = @endL
    right = (@endR / 70).ceil * 70
    len1 = right.to_s.length
    space = ""
    space2 = (" " * len1)
    
    for i in 0...array.size        
      l = left + (i * 70)
      r = left + (i * 70) + 69
      len2 = l.to_s.length
      diff = len1 - len2
      if diff < 0 then diff = 0 end
      space = (" " * diff)
        
      sequence += space + l.to_s + ": " + insert + " :" + r.to_s + "\n"
      sequence += space2 + "  " + array[i] + "\n"
    end
    
    File.open(@newseqfile, "w") do |file|
      file.write("Sequence fragment from #{@endL} to #{@endR}:\n\n")
      file.write(sequence)
    end
    
    # calling gnuplot
    @yMax = 0.0 # maximal periodicity
    @xMax = 0.0 # maximal intensity
    res = IO.readlines(@perfile).map {|line| line.chomp}
    res.each do |line|
      if (line =~ /^\s*(\S+)\s+(\S+)/)
        if (@yMax < $2.to_f)
          @yMax = $2.to_f
          @xMax = $1.to_f
        end
      end
    end
    
    @xMax = (4000 / (2001 - @xMax))
    @commands << "#{REPPER}/perio4gnuplot.pl #{@basename} #{@perfile} #{@yMax.ceil}"
  
  end
  
  
  def print_results
    
    File.open(@outfile, "w") do |file|
      
      file.write("<map name=\"m_perio\">\n")  
      
      width = (@max - @min) / (564 - 79)
      newVal = 0
      for i in 78...564
        tmp = @min + (i - 78) * width
        newVal = 4000 / (2001 - tmp)
        file.write("<area shape=\"rect\" coords=\"#{i},52,#{i+1},256\" href=\"#\" title=\"Periodicity = #{newVal}\">\n")
      end
      
      file.write("</map>\n")
      file.write("<img border=\"0\" src=\"#{job.url_for_job_dir}/#{job.jobid}_perio.png\" name=\"perio\" usemap=\"#m_perio\" style=\"background-color: #FFF;\">\n")
      file.write("<div class=\"row\"><table width=50%><tr><th align=\"left\">Periodicity</th><th align=\"left\">Peak</th><th align=\"left\">Comments</th></tr><tr></tr>")
      
      if (@xMax >= 3.3 && @xMax < 3.63)
        file.write("<tr><td>#{@xMax}</td><td>#{@yMax}</td><td><a target=\"_blank\" href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=14659700\">left-handed coiled coil?</a></td></tr>")
      elsif (@xMax >= 3.63 && @xMax <= 3.8)
        file.write("<tr><td>#{@xMax}</td><td>#{@yMax}</td><td><a target=\"_blank\" href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=14659700\">right-handed coiled coil?</a></td></tr>")
      else
        file.write("<tr><td>#{@xMax}</td><td>#{@yMax}</td></tr>")
      end
      
      file.write("</table><br><br><br>\n</div>\n")
          
    end
    
  end
  
end
