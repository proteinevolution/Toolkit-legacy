# -*- coding: utf-8 -*-
class PatsearchJob < Job
  
  @@export_ext = ".html"
  def set_export_ext(val)
    @@export_ext = val  
  end
  def get_export_ext
    @@export_ext
  end
  
  # export results
  def export

  	resfile = File.join(job_dir, jobid+".out")
		raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
		ret = IO.readlines(resfile).map {|line| line.chomp}
        
		@num_seqs = 0
		@seqs = []
		@headers = []
		@pattern = ""
		@orig_pattern = ""
		
		ret.each do |line|
			if (line =~ /^Input Pattern:/) 
				@orig_pattern = line
			elsif (line =~ /^Pattern regular expression: (.+)$/)
				@pattern = $1.strip
			elsif (line =~ /^>/)
				line.gsub!(/\001.*$/, '')
				line.gsub!('>', "\n\n>")
				line.gsub!(']', "]\n\n")
				line.gsub!(';', ";\n")		
				@num_seqs += 1
				@headers << line
			else
					
				line.gsub!(/(#{@pattern})/) {|s| s.downcase}
				line.gsub!(/(.{70})/, '\1'+"\n")
				#line.gsub!(';', "\n")
				line.gsub!(/([A-Z]*)([a-z]+)/) {|s| $1 + "<span style=\"color: red; background-color: yellow; font-weight: bold;\">" + $2.upcase! + "</span>"}
				
				@seqs << line			
				

			end
		end

  end
  
  
  
	attr_reader :headers, :seqs, :num_seqs, :orig_pattern
  
  
	def before_results(controller_params)
       
		resfile = File.join(job_dir, jobid+".out")
		raise("ERROR with resultfile!") if !File.readable?(resfile) || !File.exists?(resfile) || File.zero?(resfile)
		res = IO.readlines(resfile).map {|line| line.chomp}
        
		@num_seqs = 0
		@seqs = []
		@headers = []
		@pattern = ""
		@orig_pattern = ""
		
		res.each do |line|
			if (line =~ /^Input Pattern:/) 
				@orig_pattern = line
			elsif (line =~ /^Pattern regular expression: (.+)$/)
				@pattern = $1.strip
			elsif (line =~ /^>/)
				line.gsub!(/\001.*$/, '')
				@num_seqs += 1
				@headers << line
			else
					
				line.gsub!(/(#{@pattern})/) {|s| s.downcase}
				line.gsub!(/(.{70})/, '\1'+"\n")
				line.gsub!(/([A-Z]*)([a-z]+)/) {|s| $1 + "<span style=\"color: red; background-color: yellow; font-weight: bold;\">" + $2.upcase! + "</span>"}				
				@seqs << line			
				
#			elsif (line =~ /^(.*)(#{@pattern})(.*)$/)
				# Pattern färben und Ausgabe von jeweils 80 Zeichen
#				first = $1
#				second = $2
#				third = $3
#				i = 0
#				seq = ""
#				while (i < (first.size - 80))
#					seq += first.slice(i, 80) + "\n"
#					i += 80
#				end
#				temp = 80 - (first.size - i)
#				line = first.slice(i, 80) + 
#				       "<span style=\"color: red; background-color: yellow; font-weight: bold;\">" +
#				       second.slice(0, temp)
#				i = temp
#				if (temp < second.size)
#					seq += line + "\n"
#					while (i < (second.size - 80))
#						seq += second.slice(i, 80) + "\n"
#						i += 80
#					end
#					temp = 80 - (second.size - i)
#					seq += second.slice(i,80) + "</span>" + third.slice(0,temp) + "\n"
#				else
#					temp = temp - second.size
#					seq += line + "</span>" + third.slice(0,temp) + "\n"	
#				end
#				i = temp
#				while (i < third.size)
#					seq += third.slice(i, 80) + "\n"
#					i += 80
#				end
#				@seqs << seq
                 

				#@basename = File.join(job.job_dir, job.jobid)



			end
		end


		
	end
  
  
  
end
