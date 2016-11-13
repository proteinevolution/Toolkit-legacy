#!/usr/bin/ruby
#require File.join(File.dirname(__FILE__), '../../config/environment')

require 'tempfile'
require 'fileutils'
include FileUtils::Verbose


if(ARGV.size<3)
    puts "Usage: ./jnet.rb [clustal-file] [blastpgp-matrix-file] [result-file]"
    exit(1)
end

clufile      = ARGV[0]
matrixfile   = ARGV[1]
results      = ARGV[2]

jnetpssmfile = Tempfile.new('JNetPSSMFile')
blastfile    = Tempfile.new('JNetBLASTFile')
freqfile     = Tempfile.new('JNetFreqFile')
ungapfile    = Tempfile.new('JNetUnGapFaFile')
ungapclufile = Tempfile.new('JNetUnGapCluFile')
hmmfile      = Tempfile.new('JNetHMMERFile')
profile      = Tempfile.new('JNetProfile')
jnethmmfile  = Tempfile.new('JNetHMMFile')
localresults = Tempfile.new('JNetResults')
### Create a JNet specific PSSM file from the matrix blast file generated with the -Q option ###
cmd = "getpssm #{matrixfile} > #{jnetpssmfile.path}"
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end


### Write a file like BLASTPGP to compute a freqency file
ar = IO.readlines(clufile)	
### remove CLUSTAL header line and subsequent banc lines
while( ar.size>0 )
	line = ar[0]
	if line =~ /^CLUSTAL/i
		ar.shift
	elsif line =~ /^\s*$/
		ar.shift
	else
		break	
	end
end		
### remove trailing banc lines
while( ar.size>0 )
	line = ar.last
	if line =~ /^\s*$/
		ar.pop
	else
		break	
	end
end  

### another detail of a valid blastoutput
ar[0] = "QUERY"+ar[0];

blastfile.open
blastfile.write( "Sequences producing significant alignments\n" )
blastfile.write( ar.join)
blastfile.write( "  Database\n" )
blastfile.close

### Create an aa frequency file using the parse_psi script from the blastoutput ### 
cmd = "parse_psi -freq #{blastfile.path} > #{freqfile.path}"
puts cmd 
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end


### Create an aln file with gaps removed from the first sequence using parse_psi script ### 
cmd = "parse_psi -ungap #{blastfile.path} > #{ungapfile.path}"
puts cmd
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end


### Create a clustal alignment with gaps removed in the first sequence ###
cmd = "${PERLREFORMAT} -i=fas -o=clu -f=#{ungapfile.path} -a=#{ungapclufile.path}"
puts cmd 
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end


### build hmm ###
cmd = "hmmbuild --informat CLUSTAL -F --fast --gapmax 1 --wblosum #{hmmfile.path} #{ungapclufile.path}"
puts cmd 
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end

cmd = "hmmconvert -F -p #{hmmfile.path} #{profile.path}"
puts cmd 
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end


cmd = "hmm2profile  #{profile.path} > #{jnethmmfile.path}"
puts cmd 
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end


### jnet ###
cmd = "jnet -p #{ungapfile.path} #{jnethmmfile.path} #{jnetpssmfile.path} #{freqfile.path} > #{localresults.path}"
puts cmd 
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end

### copy results to tmp_dir ### 
cp( localresults.path, results)
chmod(0666, results)

exit(0)
