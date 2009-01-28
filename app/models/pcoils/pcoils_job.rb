class PcoilsJob < Job
  
  @@export_ext = ".out"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export
    set_export_ext(".numerical" )
    ret = IO.readlines(File.join(job_dir, jobid + @@export_ext)).join
  end
  
  
  
  
  attr_reader :psipred, :coils, :alignment
  
  
  def before_results(controller_params)
  
    @basename = File.join(job_dir, jobid)
    @psipred = nil
    @coils = nil
    @alignment = nil
    @coils14 = @basename + ".coils_n14"
    @coils21 = @basename + ".coils_n21"
    @coils28 = @basename + ".coils_n28"
    @nums=[]
    @aas=[]
    @pos14 = []
    @val14=[]
    @pos21 = []
    @val21=[]
    @pos28 = []
    @val28=[]

    if (File.exists?(@basename + "_psipred.png"))
    	@psipred = true
    end
    
    if (File.exists?(@basename + "_ncoils.png"))
    	@coils = true
    end
  
    if (File.exists?(@basename + ".alignment.psi") && !File.zero?(@basename + ".alignment.psi"))
      @alignment = ""
      res = IO.readlines(@basename + ".alignment.psi")
      res.each do |line|
        if (line =~ /\S+\s+(\S+)/)
          @alignment += $1 + "\n"
        end
      end
      
      @alignment.gsub!(/([WYF]+)/, '<span style="background-color: #00a000;">\1</span>')
      @alignment.gsub!(/(C+)/, '<span style="background-color: #ffff00;">\1</span>')
      @alignment.gsub!(/([DE]+)/, '<span style="background-color: #c080ff;">\1</span>')
      @alignment.gsub!(/([LIVM]+)/, '<span style="background-color: #00ff00;">\1</span>')
      @alignment.gsub!(/([KR]+)/, '<span style="background-color: #ff0000;">\1</span>')
      @alignment.gsub!(/([QN]+)/, '<span style="background-color: #ffc0ff;">\1</span>')
      @alignment.gsub!(/(H+)/, '<span style="background-color: #d00000;">\1</span>')
      @alignment.gsub!(/(P+)/, '<span style="background-color: #808080;">\1</span>')
      @alignment.gsub!(/(G+)/, '<span style="background-color: #ffd070;">\1</span>') 
    end

    #numerical output

    #input file
    #file *.coils_n14
    if (!File.exists?(@coils14)) then return {} end
    file14 = File.open(@coils14)
    file14.each do |line|
      nl = line.gsub(/^\s+/, '')
      ln = nl.gsub(/^\D+/, '')
      if (!ln.empty?)
        spl = ln.split(/\s+/)
        @nums << spl[0]
        @aas << spl[1]
        @pos14 << spl[2]
        @val14 << spl[4]
      end
    end
    file14.closed?
    file14.close

    #file *.coils_n21
    if (!File.exists?(@coils21)) then return {} end
    file21 = File.open(@coils21)
    file21.each do |line|
      nl = line.gsub(/^\s+/, '')
      ln = nl.gsub(/^\D+/, '')
      if (!ln.empty?)
        spl = ln.split(/\s+/)
        @pos21 << spl[2]
        @val21 << spl[4]
      end
    end
    file21.closed?
    file21.close

    #file *.coils_n28
    if (!File.exists?(@coils28)) then return {} end
    file28 = File.open(@coils28)
    file28.each do |line|
      nl = line.gsub(/^\s+/, '')
      ln = nl.gsub(/^\D+/, '')
      if (!ln.empty?)
        spl = ln.split(/\s+/)
        @pos28 << spl[2]
        @val28 << spl[4]
      end
    end
    file28.closed?
    file28.close

    file = File.new(@basename + ".numerical", "w")
    if (@nums.length > 999)
      for index in (0...9)
        file.write("   #{@nums[index]} #{@aas[index]}     #{@pos14[index]} #{@val14[index]}     #{@pos21[index]} #{@val21[index]}     #{@pos28[index]} #{@val28[index]} \n")
      end
      for index in (9...99)
        file.write("  #{@nums[index]} #{@aas[index]}     #{@pos14[index]} #{@val14[index]}     #{@pos21[index]} #{@val21[index]}     #{@pos28[index]} #{@val28[index]} \n")
      end
      for index in (99...999)
        file.write(" #{@nums[index]} #{@aas[index]}     #{@pos14[index]} #{@val14[index]}     #{@pos21[index]} #{@val21[index]}     #{@pos28[index]} #{@val28[index]} \n")
      end
      for index in (999...@nums.length)
        file.write("#{@nums[index]} #{@aas[index]}     #{@pos14[index]} #{@val14[index]}     #{@pos21[index]} #{@val21[index]}     #{@pos28[index]} #{@val28[index]} \n")
      end
    else
      for index in (0...9)
        file.write("  #{@nums[index]} #{@aas[index]}     #{@pos14[index]} #{@val14[index]}     #{@pos21[index]} #{@val21[index]}     #{@pos28[index]} #{@val28[index]} \n")
      end
      for index in (9...99)
        file.write(" #{@nums[index]} #{@aas[index]}     #{@pos14[index]} #{@val14[index]}     #{@pos21[index]} #{@val21[index]}     #{@pos28[index]} #{@val28[index]} \n")
      end
      for index in (99...@nums.length)
        file.write("#{@nums[index]} #{@aas[index]}     #{@pos14[index]} #{@val14[index]}     #{@pos21[index]} #{@val21[index]}     #{@pos28[index]} #{@val28[index]} \n")
      end
    end
    file.close

  end

end
