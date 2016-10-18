#! /usr/bin/perl -w
use File::Spec::Functions;
use File::Spec;

#***********************main*******************************	
# hirni was here
# KFT Sep 2014: For compatibility with hhblits output,
# the <NR20| match was added.
# Now all GI numbers are extracted, except with option -1
$multipleGIsPerLine=1;

if((scalar @ARGV)==2){
    $infilename=$ARGV[0];
    $outfilename=$ARGV[1];
}elsif((scalar@ARGV)==3) {
    $curarg = 0;
    if ("-1" eq $ARGV[$curarg]) {
	++$curarg;
	$multipleGIsPerLine = 0;
    }
    $infilename=$ARGV[$curarg++];
    if ($multipleGIsPerLine && ("-1" eq $ARGV[$curarg])) {
	++$curarg;
	$multipleGIsPerLine = 0;
    }
    $outfilename=$ARGV[$curarg++];
    if ($curarg < 3) {
	if ($multipleGIsPerLine && ("-1" eq $ARGV[$curarg])) {
	    ++$curarg;
	    $multipleGIsPerLine = 0;
	} else {
	    print "Illegal third argument: $ARGV[$curarg++]\n";
	    usage();
	}
    }
}else{
    usage();
}
%tmparr=();
open (FILEOUT,">$outfilename\n") or die "unable to open output file $outfilename\n";
open (FILEIN, "< $infilename") or die "unable to open input file $infilename";
if ($multipleGIsPerLine) {
    while($inline=<FILEIN>){
	$inline4loop = $inline;
	# first check for numbers (#) in the format gi|#
	while ($inline4loop =~ m/gi\|(\d+)/g){
	    $tmparr{$1}=1;
	}
	# in case of hhblits using nr20, there's only |#
	if ($inline=~/^\>nr20\|/i) {
	    while ($inline =~ m/\|(\d+)/g) {
		$tmparr{$1}=1;
	    }
	}
    }
} else {
    while($inline=<FILEIN>) {
	# the original condition required format gi|#|
	if($inline=~/^\>gi\|(\d+)/){
	    $tmparr{$1}=1;
	} elsif ($inline=~/^\>nr20\|.*\|(\d+)/i) {
	    $tmparr{$1}=1;
	}
    }
}
close FILEIN;
foreach $outline(keys %tmparr){
    print FILEOUT "$outline\n";
}

close FILEOUT;

sub usage {
    print "This script searches the specified file for:\n";
    print "a \">gi|\" and a number after that and writes\n";
    print "these numbers to a specified outputfile\n\n";
    print "With option -1, at most one number per input line is written\n\n";
    die "USAGE: getgis.pl [-1] inputfile outputfile\n";
}
