#! /usr/bin/perl -w
# Read in all globbed *.scores files, bin results and write out a table with columns
#    MS   FAM  SFAM  FOLD
# which lists how many pairs where found at the family, superfamily and fold level 
# within what Maxsub score range
# Each bin goes up to the MS given in the table, the first bin starts with MS score >0
# Usage:   hhallbinMS.pl fileglob outfile  
# Example: hhallbinMS.pl '*.scores' scop20_ms.dat   

#   MS   FAM  SFAM  FOLD   CLASS     DIFF
#  0.0  3280 20072 62793 2639918 10730224
#  1.0    42   199   190     430       53
#  2.0   503  2891  1583    6576      361
#  3.0  1131  3354  1131    3216      192
#  4.0  1613  2324   480     924       82
#  5.0  1484  1247   210     290       47
#  6.0  1071   539    87      65        7
#  7.0   629   181    14      17        3
#  8.0   251    53     1       2        2
#  9.0    54     7     0       0        0
# 10.0     3     0     0       0        0

use strict;

if (scalar(@ARGV)<2) {
    print("
 Read in all globbed *.scores files, bin results and write out a table with columns
    MS   FAM  SFAM  FOLD
 which lists how many pairs where found at the family, superfamily and fold level 
 within what Maxsub score range
 Each bin goes up to the MS given in the table, the first bin starts with MS score >0
 Usage:   hhallbinMS.pl fileglob outfile  
 Example: hhallbinMS.pl '*.scores' scop20_ms.dat   
\n"); 
    exit;
}

# Constants/Parameters
my $NBINS=10;                # bins: 0,1,2,..,$NBINS ($NBINS+1 in all)
my $MIN=0;                   # left margin of smallest bin for -log10(P-value)
my $MAX=10;                  # left margin of largest bin for -log10(P-value)
my $DBIN=($MAX-$MIN)/$NBINS; # width of bins

# Variables
my @files = glob($ARGV[0]); 
my $outfile = $ARGV[1];
my $infile;
my $line;
my $bin;                     # counts bins 
my @fam =(0)x($NBINS+1);     # number of homologs with score in bin
my @sfam=(0)x($NBINS+1);     # number of non-homologs with score in bin
my @fold=(0)x($NBINS+1);     # number of sequences with unknown relationship and with score in bin
my @class=(0)x($NBINS+1);    # number of sequences with unknown relationship and with score in bin
my @diff=(0)x($NBINS+1);     # number of sequences with unknown relationship and with score in bin
my $nfiles; 



# Read each score file and bin scores
print (scalar(@files)." files read in ...\n");
$nfiles=0;
foreach $infile (@files) {   
    $nfiles++;
    print("Reading $infile ($nfiles)\n");
    open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");
    # Advance to title line
    while($line=<INFILE>) {if ($line=~/^TARGET\s(\S+)/) {last;} }
    # Read data
    while($line=<INFILE>) {
	#           TARGET   REL     LEN     COL    SCORE  MS-SCORE
#@	if ($line=~/(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)/) {
	#           TARGET   REL     LEN     COL  RAW-SCORE SCORE  MS-SCORE
	if ($line=~/(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
	    $bin= int(($7-$MIN)/$DBIN+0.999);
	    if ($bin<0) {$bin=0;} elsif ($bin>$NBINS) {$bin=$NBINS;}
	    if ($2==0) { 
		$diff[$bin]++;     # different class
	    } elsif ($2==1) {
		$class[$bin]++;    # same class
	    } elsif ($2==2) {
		$fold[$bin]++;     # same fold
	    } elsif ($2==3) {
		$sfam[$bin]++;     # same superfamily
	    } elsif ($2==4) {	
		$fam[$bin]++;      # same family
	    }
	}
    }
    close(INFILE);
}

# Print out binned score distribution
open(OUTFILE,">$outfile") or die("Error: cannot open $outfile: $!\n");
print(OUTFILE "   MS   FAM  SFAM  FOLD   CLASS     DIFF\n");
for ($bin=0; $bin<=$NBINS; $bin++) {
    printf(OUTFILE "%5.1f %5i %5i %5i %7i %8i\n",$bin*$DBIN+$MIN,$fam[$bin],$sfam[$bin],$fold[$bin],$class[$bin],$diff[$bin]);
}
close(OUTFILE);
