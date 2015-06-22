#!/usr/bin/perl -w
use strict;   

$|=1;  # force flush after each print

# Default parameters
my $v=2;

my $usage = "
Extract seed sequences from a3m or hhm files write into single sequence file.
Usage: extractseqs.pl <fileglob> outfile
\n";

if (@ARGV<1) {die $usage;}

# Variable declarations 
my $infile;
my @infiles=glob($ARGV[0]);
my $outfile=$ARGV[1];
my $line;
my $seq;

open (OUTFILE, ">$outfile") || die "ERROR: Couldn't open $outfile: $!\n";

foreach $infile (@infiles) {
    # Read query sequence in infile
    open(INFILE,"<$infile") or die("Error: can't open $infile: $!\n");
    while ($line=<INFILE>) {  # find query sequence
	if ( $line=~/^>/ && $line!~/^>(aa|ss|sa)_/){last;}
    }
    $seq=$line;
    # Read query sequence
    while ($line=<INFILE>) {
	if($line=~/^>/) {last;}
	$seq.=$line;
    }
    print(OUTFILE $seq);
#    print($seq);
    close INFILE;
}
close OUTFILE;
