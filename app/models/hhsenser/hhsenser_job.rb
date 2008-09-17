class HhsenserJob < Job
  set_export_file_ext 'clu'
  
  @@export_ext = "_strict_masterslave.clu"
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
  

  attr_reader :strict_res, :permissive_res, :rejected_res, :intermediate_res, :multi_dom, :hhpred_id, 
              :alignment, :alignment_values, :alignment_labels
  
  def before_results(controller_params)
    
    @basename = File.join(job_dir, jobid)
    
    @strict_res = []
    @permissive_res = []
    @rejected_res = []
    @intermediate_res = []
    @multi_dom = {}
    @hhpred_id = nil
    @alignment = nil
    @alignment_values = ["0"]
    @alignment_labels = ["Alignment 0"]
    
    if (File.exists?(@basename + ".subseq1")) 
      for i in 1..3 do
        if (File.exists?(@basename + ".subseq#{i}"))
          res = IO.readlines(@basename + ".subseq#{i}").join
          res =~ /^>\S+:(\d \(.*?\))/
          @multi_dom[i] = $1 	
        end 
      end
      @hhpred_id = (IO.readlines(@basename + ".hhpred_id").map {|line| line.chomp})[0]
      
      return
    end
    
    if (controller_params['action'] == "results") 
    
      resfile = @basename + "_strict_masterslave.reduced.clu"
    	raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile)
	   @res = IO.readlines(resfile).map {|line| line.chomp}
    
		coloring_array(@res, @strict_res)

    elsif (controller_params['action'] == "results_permissive")

      resfile = @basename + "_permissive_masterslave.reduced.clu"
    	raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile)
	   @res = IO.readlines(resfile).map {|line| line.chomp}
    
		coloring_array(@res, @permissive_res)

    
    elsif (controller_params['action'] == "results_rejected")
    
      resfile = @basename + "-Z.a3m"
    	raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile)
	   @rejected_res = IO.readlines(resfile).map {|line| line.chomp}
	   
    elsif (controller_params['action'] == "results_intermediate")

      @alignment = controller_params['alignment'] ? controller_params['alignment'] : "0"

      resfile = @basename + "-#{@alignment}.fas"
      if (@alignment == '0')
        resfile = @basename + ".a3m"
      end
    	raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile)
	   @intermediate_res = IO.readlines(resfile).map {|line| line.chomp}
    
      Dir.foreach(job_dir) do |file| 
        if (file =~ /^#{jobid}-(\d+).fas$/)
          @alignment_values << $1
          @alignment_labels << "Alignment #{$1}"
        end
      end
      
    end
    
  end
  
  def coloring_array(res, array)
    res.each do |line|
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
      end
      array << line
    end
  end
  
  
  
end
