class HhompdbAction < Action
  HHOMP = File.join(BIOPROGS, 'hhomp')
  
  attr_accessor :keywords

  validates_shell_params(:keywords, {:on => :create})
  
  def before_perform
    @basename = File.join(job.job_dir, job.jobid)
    @outfile = @basename + ".cluster"

    @keywords = params['keywords'] ? params['keywords'] : ""
    @comb = params['comb'] ? params['comb'] : "and" 

    @commands = []

    searchpat = File.join(DATABASES, 'hhomp', '*.keys')
    key_files = Dir.glob(searchpat)
    
    @cluster = key_files.collect { |e| (File.basename(e)).gsub!(/\.keys/, '') }
    @keys = []
    key_files.each do |file|
    	@keys << IO.readlines(file).join
    end

  end

  def perform
    params_dump
    
    @keywords.gsub!(/\./, "\\.")
    @keywords.gsub!(/(\d+)\s*strands/i, '\1strands')
    logger.debug "Keywords: #{@keywords}"    
    
    if (@keywords != "")
    	@key_array = @keywords.split(/ /)	 
	   File.open(@outfile, "w") do |file|
	 	   
        for i in 0...@keys.length
          
          #logger.debug "Cluster[i]: #{@cluster[i]}"
          #logger.debug "Keys[i]: #{@keys[i]}"
          check = nil
          @key_array.each do |word|
          	if (@keys[i] =~ /^#{word}/i || @keys[i] =~ / #{word}/i)
              if (@comb == "or" || (@comb == "and" && check.nil?))
                #logger.debug "Treffer!   Check: #{check}   comb: #{@comb}"
                check = true
              end
            else
              if (@comb == "and" || (@comb == "or" && check.nil?))
                #logger.debug "Kein Treffer!   Check: #{check}   comb: #{@comb}"
                check = false
              end
            end
            #logger.debug "Keyword: #{word}       check: #{check}"
          end
          
          if (check)
            file.write(@cluster[i] + "\n")
          end
        	 	   
        end	 	   
	 	   
	   end
	   
	   @commands << "#{HHOMP}/hhomp_imgprocessor.pl -c #{IMAGES}/hhomp/all_small.coords #{IMAGES}/hhomp/all.png #{@basename}.gif #{@outfile}"
	   @commands << "#{HHOMP}/hhomp_imgprocessor.pl -c #{IMAGES}/hhomp/wza_small.coords #{IMAGES}/hhomp/wza.png #{@basename}_wza.gif #{@outfile}"
	   @commands << "#{HHOMP}/hhomp_imgprocessor.pl -c #{IMAGES}/hhomp/tolc_small.coords #{IMAGES}/hhomp/tolc.png #{@basename}_tolc.gif #{@outfile}"
	   
	   logger.debug "Commands:\n"+@commands.join("\n")
      queue.submit(@commands)
      
    else
    
      self.status = STATUS_DONE
		self.save!
		job.update_status		    
    
	 end
  end

end






