#!/usr/bin/ruby

# christian mayer christian.mayer@tuebingen.mpg.de

#require File.join(File.dirname(__FILE__), '../../config/environment')

require 'tempfile'
require 'fileutils'
include FileUtils::Verbose


if(ARGV.size<1)
    puts "Usage: ./disopred.rb [fasta-file] [threshold(1..10%) default=5]"
    exit(1)
end

infile       = ARGV[0]
resultfile   = ARGV[1]
threshold    = ARGV[2]

# the following files are needed by makemat and disopred which critically depend on certain files/filenames

rootname        = File.basename(infile, ".*")
dirname         = File.dirname(infile)
ext             = File.extname(infile)
basename        = File.join(dirname, rootname)
fasfile         = File.join(dirname, rootname+'_disopred.fasta')
chkfile         = File.join(dirname, rootname+'_disopred.chk')
mtxfile         = File.join(dirname, rootname+'_disopred.mtx')

psitmp_pn_file  = File.new( File.join(dirname, rootname+'_disopred.pn'), 'w' )
psitmp_pn_file.write( rootname+"_disopred.chk\n" )
psitmp_pn_file.close

psitmp_sn_file  = File.new( File.join( dirname, rootname+'_disopred.sn' ), 'w' )
psitmp_sn_file.write( rootname+ext+"\n" )
psitmp_sn_file.close

psitmp_file     = File.join( dirname, rootname + '_disopred' )

cp(infile,fasfile)


cmd = "formatdb -p T -i #{fasfile}"
puts cmd
if( !system(cmd) ) 
    raise "Error executing #{cmd}\n"
end

### exec BALSTPGP and kill as soon as round 3 searching is started,
### because the results of the last round have no influence on the checkpointfile
### saves one third of computation time
cmd = "blastpgp -b 0 -j 3 -h 0.001 -a 1 -d \"${NR} #{fasfile}\" -i #{fasfile} -C #{chkfile}"
puts cmd
IO.popen(cmd){|io|
	while( !io.eof && line = io.readline)
		puts line
		if( line =~/^Results from round 2/i )
			buf = Array.new(14)
			while( !io.eof && char = io.readchar)
				buf.shift
				buf.push( char.chr )
				#puts( buf.join )
				if( buf.join =~/\n\nSearching\.\.\./i ) 
					puts "Killing BLASTPGP (checkpoint file of round 2 should have been written)"
					Process.kill( 9, io.pid )
				end
			end
		end
	end
}

cmd = "makemat -P #{psitmp_file}"
puts cmd
if( !system(cmd) )
	raise "Error executing #{cmd}\n"
end

cmd = "disopred #{basename} #{mtxfile} ${DISOPREDDATA} #{threshold}"
if( !system(cmd) )
	raise "Error executing #{cmd}\n"
end

rm psitmp_pn_file.path
rm psitmp_sn_file.path
rm File.join(dirname, rootname+'_disopred.mn')
rm File.join(dirname, rootname+'_disopred.aux')
rm File.join(dirname, rootname+'.diso')
rm chkfile
rm mtxfile
rm fasfile

exit(0)
	
