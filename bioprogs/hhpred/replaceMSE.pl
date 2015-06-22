#! /usr/bin/perl -w
#

use strict;
$|=1; # autoflush on


if (@ARGV<1) {
    print("Replace all Selenomethionines by regular Methionines in pdb files\n");
    print("\n");
    print("Usage:   replaceMSE.pl '<fileglob>'\n");
    print("Example: replaceMSE.pl '*.pdb'\n");
    exit;
}

my @files = glob($ARGV[0]);
my $i=0;
printf("Found %i files ... \n",scalar(@files));

foreach my $file (@files) {
    open(IN,"<$file") || die("Error: could not open $file for reading: $!\n");
    my @lines=<IN>;
    close(IN);
    open(OUT,">$file.tmp") || die("Error: could not open $file.tmp for writing: $!\n");
    foreach my $line (@lines) {
	if ($line=~/HETATM/o) {
	    $line=~s/^(HETATM\s*\d+ )SE(...MSE)/$1 S$2/ && $line=~s/SE(\s*)$/ S$1/;
	    $line=~s/^HETATM(\s*\d+ .....)MSE/ATOM  $1MET/;
	}
	print(OUT $line);
    }
    close(OUT);
    rename("$file.tmp",$file); # in case that script receives an interrupt
    print(".");
    if ((++$i % 100) == 0) {print (" $i\n");}
}     
print (" $i\n");

