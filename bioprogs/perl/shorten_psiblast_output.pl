#! /usr/bin/perl -w
# Shorten PSIBLAST output by throwing out 
# result sections of all rounds but last one 
# Usage:   shorten_psiblast_output.pl psiblast-resultfile outfile

use strict;

my $line;
my @file;
my $i;
my $infile;
my $outfile;
my $lr;
my $lines;
use constant ROUND_START_PATTERN => qr/Results from round\s+\d+/;

# check arguments
if ( scalar(@ARGV) != 2) {
    usage();
} elsif (!(-r $ARGV[0])) {
    print STDERR "\nERROR: Cannot read from input-file " . $ARGV[0] . "!";
    exit(1);
}
# everything went file!
$infile = $ARGV[0];
$outfile = $ARGV[1];

$lr = &find_last_round($infile);
if ($lr == 0) {
    # nothing to do, there is only one round
    if ($infile ne $outfile) {	
        system("cp $infile $outfile");
    }
    system("chmod 777 $outfile");
    exit(0);
}

open(IN, "<$infile") or die("Cannot open: $!");
@file = <IN>;
close IN;
$lines = scalar(@file);

open(OUT, ">$outfile") or die("Cannot open: $!");
$i = 0;
while($i < $lines) {
    if ($file[$i] =~ ROUND_START_PATTERN) {
	$i = $lr;
    }
    print OUT $file[$i];
    $i++;
}
close(OUT);
system("chmod 777 $outfile");

exit(0);

#####################################################
# functions

sub usage 
{
	print("Usage: shorten_psiblast_output.pl infile outfile\n");
	exit(1);
}

sub find_last_round 
{
    my $infile = $_[0];
    my $ret = 0;
    my $i = 0;
    my $line;
    
    # first find line number with results section of last run
    open(IN, "<$infile") or die("Cannot open: $!");
    while ($line = <IN>) {
	if ($line =~ ROUND_START_PATTERN) {
	    $ret = $i;
	}
	$i++;
    }
    close IN; 

    return $ret;
}
