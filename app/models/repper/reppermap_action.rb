class ReppermapAction < Action
  REPPER = File.join(BIOPROGS, 'repper')
  
  def before_perform
  
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    @length = params['length'].to_i
    @coords = params['coords']
    
    # files
    @infile     = @basename+".in"    
    @repperfile = @basename+"_repper.dat"
    @outfile    = @basename + ".r_out"

    @coords =~ /(\d+),(\d+)/
    @valX = $1.to_f
    @valY = $2.to_f
    @endL = 0
    @endR = 0
      
    # translating coordinates into the sequence fragment that will be processed
#    @xOffsetL = 95.0;
    @xOffsetL = 65.0;
#    @xOffsetR = 544.0;    # 640-544 = 96
    @xOffsetR = 515.0;
    @yOffsetT = 55.0;
    @yOffsetB = 251.0;    # 320-251 = 69
      
    # getting begin and end values of the sequence
    # length correction of seq_len for perio4gnuplot.pl
    @len = 0
    if (@length <= 50) 
      @len = (@length / 5).ceil * 5
    elsif (@length <= 100) 
      @len = (@length / 10).ceil * 10
    elsif (@length <= 200) 
      @len = (@length / 20).ceil * 20 
    elsif (@length <= 500) 
      @len = (@length / 50).ceil * 50 
    elsif (@length <= 1000) 
      @len = (@length / 100).ceil * 100
    elsif (@length <= 2000) 
      @len = (@length / 200).ceil * 200
    elsif (@length <= 5000) 
      @len = (@length / 500).ceil * 500
    elsif (@length <= 10000) 
      @len = (@length / 1000).ceil * 1000
    elsif (@length <= 20000) 
      @len = (@length / 2000).ceil * 2000 
    end

  end

  def perform
    params_dump
    
    min = 0
    max = 0
    
    # getting the max. y-value from the plotted graph
    res = IO.readlines(@repperfile)
    res.each do |line|
      if (line =~ /^\s*\d+\s+(\d+)/)
        y = $1.to_f
        if (max < y)
          max = y
        end
      end
    end
        
    # correction for y-Value
    if (max % 5 == 0)
      max = (max / 5 + 1) * 5
    else
      max = (max / 5).ceil * 5
    end
    
    xScale = (@xOffsetR - @xOffsetL) / @len
    yScale = (@yOffsetB - @yOffsetT) / (max - min)
    
    # calculating the position of the click in the sequence
    posInSeq = ((@valX - @xOffsetL ) / xScale).round
    
    # extracting the sequence by y values
    yValue = (max - (@valY - @yOffsetT) / yScale).round

    # getting left end and right end of the sequence with the appropriate periodicity
    xArray = []
	 res.each do |line|
	   line =~ /^(\d+)\s+(\d+)/
	   x = $1.to_i
	   y = $2.to_i
	   # the value "x" (here: 10) is the threshold due to inexact clicking - can be changed!
      if ( (y - 10) < yValue && yValue < (y + 10) )
        xArray << x
      end
	 end
	 
    xArray.sort!.uniq!
	    
    if xArray.empty?
      File.open(@outfile, "w") do |file|
        file.write("No Corresponding Alignment found!")
      end
      self.status = STATUS_DONE
      self.save!
      job.update_status
      return
    end
    
    # where is $PosInSeq?
	   
    # the next 5 lines are needed because of possibly added value at position 0 due to same z-values
    tmp = 0
    @endL = xArray[tmp]
    if (@endL == 0)
      tmp += 1
      @endL = xArray[tmp]
    end
	   
    flag = false
    counter = @endL
    for i in tmp...xArray.size
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
	 
	 #extracting the sequence...
	 @seq = ""
	 res = IO.readlines(@infile).map {|line| line.chomp}
	 res.shift
    res.each do |line|
      if (line =~ /^>/) then break end
      @seq += line
    end
    
    @seq = @seq.slice((@endL - 1), ((@endR - @endL).abs + 1))
    
    # print results
    File.open(@outfile, "w") do |file|
      
      if (@endR == 0)
        file.write("No Corresponding Alignment found!")
      else
        # the number of steps...
        partlen = (@seq.length / yValue).floor
      
        @old_seq = @seq.clone
        color_seq
        file.write(@seq + "\n")
     
        for i in 0...partlen
          @seq = @old_seq.slice(yValue, (@old_seq.length - 1))
          @old_seq = @seq.clone
          color_seq
          file.write(@seq + "\n")
        end
      end
      
    end
    
    self.status = STATUS_DONE
    self.save!
    job.update_status
  end
  
  def color_seq
    @seq.gsub!(/([WYF]+)/, '<span style="background-color: #00a000;">\1</span>')
    @seq.gsub!(/(C+)/, '<span style="background-color: #ffff00;">\1</span>')
    @seq.gsub!(/([DE]+)/, '<span style="background-color: #c080ff;">\1</span>')
    @seq.gsub!(/([LIVM]+)/, '<span style="background-color: #00ff00;">\1</span>')
    @seq.gsub!(/([KR]+)/, '<span style="background-color: #ff0000;">\1</span>')
    @seq.gsub!(/([QN]+)/, '<span style="background-color: #ffc0ff;">\1</span>')
    @seq.gsub!(/(H+)/, '<span style="background-color: #d00000;">\1</span>')
    @seq.gsub!(/(P+)/, '<span style="background-color: #808080;">\1</span>')
    @seq.gsub!(/(G+)/, '<span style="background-color: #ffd070;">\1</span>')
  end
  
end
