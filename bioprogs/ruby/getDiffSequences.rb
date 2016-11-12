#!/usr/bin/ruby
#require File.join(File.dirname(__FILE__), '../../config/environment')

require 'tempfile'
require 'fileutils'
include FileUtils::Verbose


#=================================FUNCTIONS/METHODS===================================================#
# returns the number of sequences in a fasta file
def countFastaSeqs(fasfile)
	ar    = IO.readlines(fasfile)
	count = 0
	ar.each do |line|
		if line =~ /^>/ then count+=1 end
	end		
	count
end

def takeFirstSeqs(sourcefile, targetfile, limit)
	ar  = IO.readlines(sourcefile)
	c   = 0
	out = File.open(targetfile,"w")
	ar.each do |line|
		if line =~ /^>/
			c += 1
			if(c>limit) then break end
			out.write(line)
		else
			out.write(line)
		end
	end
	out.close	
end


#==========================MAIN=====================================================================#

if(ARGV.size<3)
    puts "Usage: ./jnet.rb [a3m-infile] [a3m-outfile] [max-number-of-most-different-sequences]"
    exit(1)
end

infile      = ARGV[0]
outfile     = ARGV[1]
maxseqs     = ARGV[2].to_i

tmpfile = Tempfile.new('QUICK2D_HHFILTER')

n = countFastaSeqs(infile)
diff = maxseqs;
while( n>maxseqs && diff!=1 )
	cmd = "hhfilter -diff #{diff} -i #{infile} -o #{tmpfile.path}"
	if( !system(cmd) ) 
		raise "Error executing #{cmd}\n"
		exit(1);
	end
	n = countFastaSeqs(tmpfile.path)
	diff -= 20;
	if( diff <= 0 ) then diff=1 end
end

if( n>maxseqs && diff==1 )
	takeFirstSeqs(infile, tmpfile.path, maxseqs)
end

if (File.size?(tmpfile.path).nil?)
	if (infile != outfile)	
		cp( infile, outfile)
	end
else
	cp( tmpfile.path, outfile)
end

chmod(0666, outfile)
exit(0);
#============================END MAIN=================================================================#






