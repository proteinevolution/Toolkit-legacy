#! /usr/bin/perl -w
# Determine functional dependence between score/column and MS-score*L_Q/cols
# Read in all globbed *.scores files, bin results by score/column and write out a list
# with Score/Column MS-score L_Q cols
# Usage:   hhallvarms.pl fileglob outfile  
# Example: hhallvarms.pl '*.scores' scop20_varms.dat   

use strict;

if (scalar(@ARGV)<2) {
    print("
 Determine functional dependence between score/column and MS-score*L_Q/cols
 Read in all globbed *.scores files, bin results by score/column and write out a list
 with Score/Column MS-score L_Q cols
 Usage:   hhallvarms.pl fileglob outfile  
 Example: hhallvarms.pl '*.scores' scop20_varms.dat   
\n"); 
    exit;
}

# Constants/Parameters
my $NBINS=42;                # bins: 0,1,2,..,$NBINS ($NBINS+1 in all)
my $MIN=-1;                   # left margin of smallest bin for -log10(P-value)
my $MAX=41;                   # left margin of largest bin for -log10(P-value)
my $DBIN=($MAX-$MIN)/$NBINS; # width of bins
my $MINSCORE=5.5;            # minimum score up to which to bin results (speed-up)
my $MINLEN=0;                # minimum number of residues for query
my $LOG2TO10=log(2)/log(10);
my $LOGNDB=log(3791)/log(10);
my $scopfile="/home/soeding/nr/scop20.1.63";

# Variables
my @files = glob($ARGV[0]); 
my $outfile = $ARGV[1];
my $infile;
my $line;
my $bin;                     # counts bins 
my $n; 
my $len;                     # length of query
my @bin;                     # @{$bin[$bin]} is an array containg all the data points for this bin

# Create array of arrays with two predefined extreme data elements (MS*L_Q/cols)
for ($bin=$NBINS; $bin>=0; $bin--) {$bin[$bin][0]=0; $bin[$bin][1]=1;}


# Read each score file and bin scores
print (scalar(@files)." files read in ...\n");
$n=0;
foreach $infile (@files) {   
    $n++;
    print("Reading $infile ($n)\n");
    open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");
    # Read query name
#    while($line=<INFILE>) {if ($line=~/^LENG\s+(\S+)/) {$len=$1; last;} }
#    if ($len<=$MINLEN) {next;} # Query too short?
    # Advance to title line
    while($line=<INFILE>) {if ($line=~/^TARGET\s(\S+)/) {last;} }
    # Read data
    while($line=<INFILE>) {
	#           TARGET   REL     LEN     COL  RAW-SCORE SCORE  MS-SCORE
	if ($line=~/(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+\S+\s+(\S+)\s+(\S+)/) {
	    
	    if ($5<$MINSCORE) {last;} # Minimum score reached?
	    if ($6==0) {next;} # maxsub =0
	    if ($2==5) {next;} # Skip identical HMMs
	    $bin= int(($5*$LOG2TO10-$LOGNDB-$MIN)/$DBIN);
	    if ($bin<0) {$bin=0;} elsif ($bin>$NBINS) {$bin=$NBINS;}
	    push(@{$bin[$bin]},$6);
	}
    }
    close(INFILE);
}

# Sort vectors and determine medians
my $size;
my $i;
my ($lower, $median, $upper);
# Print out binned score distribution
open(OUTFILE,">$outfile") or die("Error: cannot open $outfile: $!\n");
print(OUTFILE "SCORE  LOWER MEDIAN  UPPER COUNTS\n");
for ($bin=0; $bin<=$NBINS; $bin++) {
    @{$bin[$bin]} = sort {$a<=>$b} @{$bin[$bin]};
    $size=$#{$bin[$bin]}+1;
    $lower=int(0.25*$size);
    $median=int(0.5*$size-0.5);
    $upper=$size-$lower-1;
#    printf("bin =%i size=%i low=%i  median=%i  upper=%i\n",$bin,$size,$lower,$median,$upper);
    printf(OUTFILE "%5.2f %6.3f %6.3f %6.3f %6i\n",$MIN+$bin*$DBIN,$bin[$bin][$lower],$bin[$bin][$median],$bin[$bin][$upper],$size);
}
close(OUTFILE);

exit(0);

