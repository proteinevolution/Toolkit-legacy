class SixframeJob < Job
  
  @@export_ext = ".export"
  @@linewidth = 80
  
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
	def export
		if( self.actions[0].params['showseqs'] &&  self.actions[0].params['relative'] )
			ret = print_results
		else
			ret = IO.readlines(File.join(job_dir, jobid + ".aa")).join 
		end
		ret
	end
  
    
	def print_results
		ret = ""		
		heads=Array.new; seqs=Array.new	
		lines = IO.readlines(File.join(job_dir, jobid + ".aa"))
		lines.each do |line|
			line.chomp!
			if ( line=~/^>/ ) 
				heads << line
			else 
				seqs << line
			end
		end
		
		len = seqs[0].length
		# print forward strand translations with newlines
		0.upto(3){ |h|
			if( h==0 )
				ret += ">Nuc := " + heads[h] + "\n"
			else 	
				ret += ">+#{h}  := " + heads[h] + "\n"		
			end	
		}
		ret += "\n"	
		i = 0
		while( i<len )
			stop = min(i+@@linewidth, len)-1
			0.upto(3){ |s|
				if( s==0 )
					ret += ">Nuc " + seqs[s][i..stop] + "\n"
				else
					ret += ">+#{s}  " + seqs[s][i..stop] + "\n" 
				end
			}
			i += @@linewidth		
		end

	ret += "\n"	
	ret += "-------------------------------------------------------------------------------------\n\n"	
		# reverse strand
		4.upto(7){ |h|
			if( h==4 )
				ret += ">Nuc := " + heads[h] + "\n"
			else 	
				ret += ">-#{h}  := " + heads[h] + "\n"		
			end	
		}
		ret += "\n"	
		i = 0
		while( i<len )
			stop = min(i+@@linewidth, len)-1
			4.upto(7){ |s|
				if( s==4 )
					ret += ">Nuc " + seqs[s][i..stop] + "\n"
				else
					ret += ">-#{s}  " + seqs[s][i..stop] + "\n" 
				end
			}
			i += @@linewidth		
		end

		return ret
	end
  
  
  def min(a,b)
  		if( a<b ) then return a else return b end
  	end
  
	def max(a,b)
  		if( a<b ) then return b else return a end
  	end 
  # add your own data accessors for the result templates here! For example:
  # attr_reader :some_results_data
  
  
  # Overwrite before_results to fill you job object with result data before result display
  # def before_results(controller_params)
  #    @some_results_data = ">header\nsequence"
  # end
  
  
  
end
