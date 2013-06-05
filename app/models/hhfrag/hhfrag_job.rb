class HhfragJob < Job


  @@export_ext = ".hhfrags.09"
  def set_export_ext(val)
    @@export_ext = val
  end
  def get_export_ext
    @@export_ext
  end

  # export results
  def export
    ret = IO.readlines(File.join(job_dir, "query" + @@export_ext)).join
  end




  attr_reader :ta

  def before_results(controller_params)

    @problistname = File.join(job_dir,jobid+".ProbList")
    @basename = File.join(job_dir, jobid)
    @psipred = nil
    @coils = nil
    @alignment = nil
    @pssm = false

    if (File.exists?(@problistname +"PSSM"))
 	@pssm = true
    end
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
    
  end
  
end
