#!/usr/bin/perl -w
#
# @author Michael Remmert
# @time 2005-07-18
#
use warnings;

my $resfile;
my $imgfile;
my $plotdatafile;
my $plotfile;
my $id;
my $basedir;
my $progtype;
my @res = ();
my $num = 0;

# check arguments
if((scalar @ARGV)!=3){
    print "Usage: blasthisto.pl BLASTRESFILE ID BASEDIR\n";
    exit(1);
}else{
    $resfile = $ARGV[0];
    $resfile=~/^\S+\.(\S+)$/;
    $progtype=$1;
    $id = $ARGV[1];
    $basedir = $ARGV[2];
    $imgfile = "$basedir/$id"."_histo.png";
    $plotdatafile = "$basedir/$id.plotdata";
    $plotfile = "$basedir/$id.gnuplot";
}

# Read hit list
open (RESFILE,"<$resfile") or die "unable to open blastresultfile $resfile for reading\n";
while($line=<RESFILE>) {
    if ($line =~ /Sequences producing significant alignments:/) {
	last;
    }
}
while($line=<RESFILE>) {
    if ($line =~ /^>/) {
	last;
    }
    if ($line =~ /<\/a>\s+(\S+)\s*$/) {
	if ( substr( $1, 0, 1 ) eq "e" ) {
	    $tmp = "1$1";
	}
	else {
	    $tmp = $1;
	}
	$num++;
	push(@res, $tmp);
    }
}

close RESFILE;

if ($num == 0) {
    print "No Sequences!";
    exit(0);
}

open (DATA, ">$plotdatafile") or die ("Cannot open");
my $max = 0;
my $tmp;
my $tmp_old = 100000;
for (my $i = 0; $i < scalar(@res); $i++) {
    if ($res[$i] == 0 || $res[$i] == 0.0) {
	$tmp = 300;
    } else {
	$tmp = (-1)*(log($res[$i])/log(10));
    }
    if ($tmp > $max) {
	$max = $tmp;
    }
    if ($tmp != $tmp_old) {
	$tmp_old = $tmp;
	print DATA $tmp . "\t" . ($num-$i). "\n";
    }
}
close DATA;

open (OUTFILE, ">$plotfile") or die ("Cannot open");

print OUTFILE "set term png size 700,400\n";
print OUTFILE "set output '$imgfile'\n";
print OUTFILE "set xlabel \"-log(E-value)\"\n";
print OUTFILE "set ylabel \"Number of HSP's below E-value\n";
print OUTFILE "set key bottom\n";
print OUTFILE "plot [0:$max] [0:$num] '$plotdatafile' with line title \"number of HSPs\"\n";
print OUTFILE "q\n";

close OUTFILE;

system("gnuplot $plotfile");

exit(0);

