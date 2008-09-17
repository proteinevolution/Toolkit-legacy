class Createmap2Action < Action
  REPPER = File.join(BIOPROGS, 'repper')
  
  attr_accessor :threshold

  validates_shell_params(:threshold, {:on => :create})
  
  validates_format_of(:threshold, {:with => /^\d+\.?\d*$/, :on => :create, :message => 'Invalid value!'}) 
  
  def before_perform
  
    @basename = File.join(job.job_dir, job.jobid)
    @commands = []
    
    @cutoff = params['threshold'].to_f
    
    @yMax_array = []
    @xMax_array = []
    
    # files
    @outfile    = @basename + ".out"
    @perfile    = @basename + ".ftwin_per2"
    @parfile    = @basename + ".ftwin_par"
    
    res = IO.readlines(@parfile)
    perioL = res[1].chomp.to_f
    perioH = res[2].chomp.to_f
    # applying special formula: 2001-4000/value
    @min = 2001 - (4000 / perioL)
    @max = 2001 - (4000 / perioH)
    
  end

  def perform
    params_dump
    
    calculate_peaks_over_cutoff
    print_cutoff_results
    
    self.status = STATUS_DONE
    self.save!
    job.update_status	
  end
  
  def calculate_peaks_over_cutoff

    if (!File.exists?(@perfile) || File.zero?(@perfile)) then return end

    # Make preparations and call "run_third"
    yMax = 0.0
    xMax = 0.0
    up = false
            
    res = IO.readlines(@perfile).map {|line| line.chomp}
    res.each do |line|
      if (line =~ /^\s*(\S+)\s+(\S+)/)
        x = $1.to_f
        y = $2.to_f
        if (y > @cutoff && y >= yMax)
          yMax = y
          xMax = x
          up = true
        elsif (y <= @cutoff && up)
          @yMax_array << yMax
          @xMax_array << ((((4000 / (2001 - xMax)) * 1000).round).to_f / 1000)
          up = false
          yMax = 0
        end
      end
    end
    
    if (yMax >= @cutoff)
      @yMax_array << yMax
      @xMax_array << ((((4000 / (2001 - xMax)) * 1000).round).to_f / 1000)
    end
    
    @xMax_array.reverse!
    @yMax_array.reverse!    

  end
  
  def print_cutoff_results
  
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
      
      for i in 0...@yMax_array.size
      
        if (@xMax_array[i] >= 3.3 && @xMax_array[i] < 3.63)
          file.write("<tr><td>#{@xMax_array[i]}</td><td>#{@yMax_array[i]}</td><td><a target=\"_blank\" href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=14659700\">left-handed coiled coil?</a></td></tr>")
        elsif (@xMax_array[i] >= 3.63 && @xMax_array[i] <= 3.8)
          file.write("<tr><td>#{@xMax_array[i]}</td><td>#{@yMax_array[i]}</td><td><a target=\"_blank\" href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=14659700\">right-handed coiled coil?</a></td></tr>")
        else
          file.write("<tr><td>#{@xMax_array[i]}</td><td>#{@yMax_array[i]}</td></tr>")
        end
        
      end
      
      file.write("</table><br><br><br>\n</div>\n") 
    end
  
  end
  
end

