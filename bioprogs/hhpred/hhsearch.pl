#! /usr/bin/perl -w
# Usage:  hhsearch.pl <file.fasta> <database.hhm> [<hhsearch options>]
use lib ".";         
use strict;

my $hh="/home/soeding/hh";    # Set to directory containing buildali.pl, hhsearch, hhmake, cal.hhm !

if (@ARGV<2) {
    print("\nRun hhsearch from a single sequence or preliminary multiple FASTA alignment\n");
    print("This script will first launch PSI-BLAST (up to 8 rounds), \n");
    print("extract the alignment, call hhmake and then run hhsearch.\n\n");
    print("Usage:  hhsearch.pl <file.fasta> <hhsearch options>\n");
    print("Example: hhsearch.pl test.seq scop70_1.69.hhm -global\n\n"); 
    exit;
}

my $options=join(" ",@ARGV[2..$#ARGV]);
#for ($i=2; $i<$ARGC; $i++) {$options.="$ARGV[$i] ";}
my $base = $ARGV[0];
$base=~s/\.?[^.]*$//; # remove extension
&System("$hh/buildali.pl -v 1 $ARGV[0]");
&System("$hh/hhmake -i $base.a3m -o $base.hhm");
&System("$hh/hhsearch -v 1 -cal -i $base.hhm -d $hh/cal.hhm $options");
&System("$hh/hhsearch -i $base.hhm -d $ARGV[1] $options");
exit;

sub System() {
    print("\$ $_[0]\n");
    return system($_[0]);
}
