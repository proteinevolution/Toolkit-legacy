#! /usr/bin/perl -w
# Create scatter plot for MaxSub scores from two directories
# 1. Read globbed *.score files from first directory and 
# when MS1>0 write MS1 into hash $MS1{$query.$template}. 
# 2. Read globbed *.scores files from second directory and 
# when MS1>0 AND MS2>0 write MS2 into hash $MS2{$query.$template}. 
# 3. Write  QUERY TARGET MS1 MS2  into outfile when MS1>0 and MS2>0.
# Usage:   hhallmsms.pl fileglob1 fileglob2 outfile  
# Example: hhallbin.pl 'hhrcs/*.scores' 'hmmer/*.scores' scop20_msms.dat   

use strict;

if (scalar(@ARGV)<3) {
    print("
 Create scatter plot for MaxSub scores from two directories
 1. Read globbed *.scores files from 1st directory and when MS1>0 write MS1 into hash MS1{'query template'}
 2. Read globbed *.scores files from 2nd directory and when MS1>0, MS2>0 write MS2 into hash MS2{'query template'}
 3. Write  QUERY TARGET MS1 MS2  into outfile when MS1>0 and MS2>0.
 Usage:   hhallmsms.pl fileglob1 fileglob2 outfile  
 Example: hhallmsms.pl 'hhrcs/*.scores' 'hmmer/*.scores' scop20_msms.dat   
\n"); 
    exit;
}

# Constants/Parameters
my $MINSCORE=8;         # minimum score up to which to read scores list (speed-up)
my $MAXREL=4;           # maximum relationship to be included

# Variables
my @files;              # array for globbd files
my $outfile = $ARGV[2];
my $infile;             # current file being read in
my $line;
my $n; 
my $query;              # scop-id of query sequence
my $template;             # scop-id of template sequence
my $MS1;                # Maxsub score
my $MS2;                # Maxsub score
my %MS1=();             # $MS1{$query.$template} = MS score of query with template in 1st dir if MS1>0
my %MS2=();             # $MS2{$query.$template} = MS score of query with template in 2nd dir if MS1>0 & MS2>0
my $key;                # $key="$query $template"

$n=0;
@files = glob($ARGV[0]);
print ("\n".scalar(@files)." file names read with glob $ARGV[0] ...\n");

# Read each score file from 1st directory and record MaxSub1 score if >0
foreach $infile (@files) {   

    $n++;
#    print("Reading $infile ($n)\n");
    open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");

    # Read query name
    while($line=<INFILE>) {if ($line=~/^NAME\s+(\S+)/) {$query=$1; last;} }

    # Advance to title line
    while($line=<INFILE>) {if ($line=~/^TARGET\s(\S+)/) {last;} }

    # Read data
    while($line=<INFILE>) {

	#           TARGET   REL     LEN     COL    SCORE  MS-SCORE
	if ($line=~/(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)/) {
	    if ($5<$MINSCORE) {last;} # Minimum score reached?
	    $MS1=$6;
	    if ($MS1>0 && $2<=$MAXREL) { $MS1{$query." ".$1}=$MS1; }
	}
    }
    close(INFILE);
}

$n=0;
@files = glob($ARGV[1]);
print ("\n".scalar(@files)." file names read with glob $ARGV[1] ...\n");

# Read each score file from 2nd directory and record MaxSub2 score if MS1>0 and MS2>0
foreach $infile (@files) {   

    $n++;
#   print("Reading $infile ($n)\n");
    open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");

    # Read query name
    while($line=<INFILE>) {if ($line=~/^NAME\s+(\S+)/) {$query=$1; last;} }

    # Advance to title line
    while($line=<INFILE>) {if ($line=~/^TARGET\s(\S+)/) {last;} }

    # Read data
    while($line=<INFILE>) {

	#           TARGET   REL     LEN     COL    SCORE  MS-SCORE
	if ($line=~/(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)/) {
	    if ($5<$MINSCORE) {last;} # Minimum score reached?
	    $MS2=$6;
	    if ($MS2>0 && $2<=$MAXREL) { 
		$MS1=$MS1{$query." ".$1}; 
		if (defined $MS1) { 
		    $MS2{$query." ".$1}=$MS2;
		} else {
		    $MS2{$query." ".$1}=$MS2;
		    $MS1{$query." ".$1}=0;
		}
	    }
	}
    }
    close(INFILE);
}


# Print out binned score distribution
my $greater1=0;
my $smaller1=0;
my $total1;
my $greater0=0;
my $smaller0=0;
my $total0;
my $greater=0;
my $smaller=0;
my $total;

print ("Printing MaxSub1 MaxSub2 pairs into $outfile ...\n");
open(OUTFILE,">$outfile") or die("Error: cannot open $outfile: $!\n");
foreach $key (keys(%MS1)) {
    if ($MS1{$key}>0 && defined $MS2{$key} ) {
	if ($MS1{$key}>$MS2{$key}) {$greater1++;}
	elsif ($MS1{$key}<$MS2{$key}) {$smaller1++;}
	printf(OUTFILE "%s %5.2f %5.2f\n",$key,$MS1{$key},$MS2{$key});
    } else {
	if (! defined $MS2{$key}) {$greater0++;}
	elsif ($MS1{$key}<$MS2{$key}) {$smaller0++;}
    }
}
close(OUTFILE);

$total1=$smaller1+$greater1+.1;
$total0=$smaller0+$greater0+.1;
$total=$total0+$total1;
$greater=$greater1+$greater0;
$smaller=$smaller1+$smaller0;
printf("MS1>MS2>0: %5.1f%%  MS2>MS1>0: %5.1f%%\n",100*$greater1/$total1,100*$smaller1/$total1);
printf("MS1>MS2=0: %5.1f%%  MS2>MS1=0: %5.1f%%\n",100*$greater0/$total0,100*$smaller0/$total0);
printf("MS1>MS2:   %5.1f%%  MS2>MS1:   %5.1f%%\n",100*$greater/$total,100*$smaller/$total);

exit(0);

