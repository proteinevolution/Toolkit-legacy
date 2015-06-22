#! /usr/bin/perl -w
# Read in all globbed *.scores files and write several files with hits sorted by E-value
# Usage:   hhallposneg.pl fileglob name  
use strict;

if (scalar(@ARGV)<2) {
    print("
Read in all globbed *.scores files and write several files with hits sorted by E-value:
1. name.22 all hits with MS score >1.0 and from same fold but different superfamily 
2. name.21 all hits with MS score >1.0 and from same class but different fold (interesting true positives)     
3. name.20 all hits with MS score >1.0 and from different classes (interesting true positives)
4. name.01 all hits with MS score =0.0 and from same class but different fold 
5. name.00 all hits with MS score =0.0 and from different class (interesting false positives)
6. name.1  all hits which are neither positives nor negatives (interesting neutrals)

Usage:   hhallposneg.pl fileglob name  
Example: hhallposneg.pl '*.scores' scop20   
\n"); 
    exit;
}

# Constants/Parameters
my $LOG2TO10=log(2)/log(10);
my $MAXEVAL=1E-3; # Evalue >1 are not included in list name.01 and name.00
my $NDB=3691;     # Number of HMMs in data base (for calculating E-value)

# Variables
my @files = glob($ARGV[0]); 
my $base = $ARGV[1];
my $outfile;
my $infile;
my $line;
my $query;                   # name of query 
my $fam;                     # family of query
my $evalue;                  # evalue of hit
my %fam;                     # hash with all scop family ids      
my $MS;                      # Maxsub score
my @l22;                     # lines of hits to be written to name.22
my @l21;                     # lines of hits to be written to name.21
my @l20;                     # lines of hits to be written to name.20
my @l02;                     # lines of hits to be written to name.02
my @l01;                     # lines of hits to be written to name.01
my @l00;                     # lines of hits to be written to name.00
my @l1;                      # lines of hits to be written to name.1
my $n; 

# Read each score file and bin scores
print (scalar(@files)." files read in ...\n");
$n=0;
foreach $infile (@files) {   
    $n++;
    print("Reading $infile ($n)\n");
    open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");
    $line=<INFILE>;
    $line=~/^NAME\s*(\S+)\s*(\S*)/;
    $query=$1;
    $fam=$2;
    $fam{$query}=$fam;
    while($line=<INFILE>) {
#	#           TARGET   REL     LEN     COL  RAW-SCORE SCORE  MS-SCORE
#	if ($line=~/(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s*(\S*)/) {
#                    TARGET   FAMILY REL     LEN     COL       LOG-PVA        S-AASS       PROBAB     MS      NALI
	if ($line=~/^(\S+\s+\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(-?\d+\.?\d*)\s+(-?\d+\.?\d*)\s+\S+\s+(-?\d+\.?\d*)\s+(\d+)/) {
	    $evalue=2.0**(-$5)*$NDB;
	    $MS=$7;
	    if ($MS eq "") {$MS=0;}
	    $line=sprintf("%9.2G %5.2f %3i(%3i)  %7s %-10.10s  %-s\n",$evalue,$MS,$8,$4,,$query,$fam,$1);
	    if ($MS>=1.0) {      # MS-score>=1.0
		    push(@l22,$line);
		if ($2==2) {
		} elsif ($2==1) {
		    push(@l21,$line);
		} elsif ($2==0) {
		    push(@l20,$line);
		}
	    } elsif ($MS<=0) { # MS-score==0.0 
		if ($2==2 && $evalue<$MAXEVAL) {
		    push(@l02,$line);
		} elsif ($2==1 && $evalue<$MAXEVAL) {
		    push(@l01,$line);
		} elsif ($2==0 && $evalue<$MAXEVAL) {
		    push(@l00,$line);
		}
	    } else {
		if ($evalue<$MAXEVAL) {
		    push(@l1,$line);
		}
	    }
	}
    }
    close(INFILE);
}


sub ByEvalue() {
    return substr($a,0,9) <=> substr($b,0,9);
}

# Sort lists
@l22=sort ByEvalue @l22;
@l21=sort ByEvalue @l21;
@l20=sort ByEvalue @l20;
@l02=sort ByEvalue @l02;
@l01=sort ByEvalue @l01;
@l00=sort ByEvalue @l00;
@l1 =sort ByEvalue @l1;


# Write outfiles
open(OUTFILE22,">$base.22") or die("Error: cannot open $base.22: $!\n");
foreach $line (@l22) {
    printf(OUTFILE22 $line);
}
close(OUTFILE22);

open(OUTFILE21,">$base.21") or die("Error: cannot open $base.21: $!\n");
foreach $line (@l21) {
   printf(OUTFILE21 $line);
}
close(OUTFILE21);

open(OUTFILE20,">$base.20") or die("Error: cannot open $base.20: $!\n");
foreach $line (@l20) {
    printf(OUTFILE20 $line);
}
close(OUTFILE20);

open(OUTFILE02,">$base.02") or die("Error: cannot open $base.02: $!\n");
foreach $line (@l02) {
    printf(OUTFILE02 $line);
}
close(OUTFILE02);

open(OUTFILE01,">$base.01") or die("Error: cannot open $base.01: $!\n");
foreach $line (@l01) {
    printf(OUTFILE01 $line);
}
close(OUTFILE01);

open(OUTFILE00,">$base.00") or die("Error: cannot open $base.00: $!\n");
foreach $line (@l00) {
    printf(OUTFILE00 $line);
}
close(OUTFILE00);

open(OUTFILE1,">$base.1") or die("Error: cannot open $base.1: $!\n");
foreach $line (@l1) {
    printf(OUTFILE1 $line);
}
close(OUTFILE1);

exit;


