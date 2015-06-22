#! /usr/bin/perl -w
# Create a randomized data base of hhm files 
# Read one HMM after the other from indb and randomly draw L columns from the L columns of the HMM L (mit Zuruecklegen).
# The generated data base in outdb has the same length distribution but random order of columns.
# Usage:   hhrandomize.pl indb outdb
# Example: hhrandomize.pl scop20.1.hhm rand20.1.hhm

use strict;

if (scalar(@ARGV)<2) {
    print("
 Create a randomized data base of hhm files 
 Read one HMM after the other from infile and randomly draw L columns from the L columns of the HMM L (mit Zuruecklegen).
 The generated data base in outfile has the same length distribution but random order of columns.
 Usage:   hhrandomize.pl infile outfile
 Example: hhrandomize.pl scop20.1.hhm rand20.1.hhm
\n"); 
    exit;
}


my $infile=$ARGV[0];
my $outfile=$ARGV[1];
my $line;
my $header="";          # Everything in hhm preceding the lines descripbing the HMM states
my $footer="";          # Everything in hhm following the lines descripbing the HMM states
my @state;              # $state[$i] = two lines describing state $i of the HMM
my $l=0;
my $i;                  # column index
my $j;                  # random column index
my $L;                  # number of columns in HMM
my $n=0;                # number of HMMs read/written

open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");
open(OUTFILE,">$outfile") or die("Error: cannot open $outfile: $!\n");

while(1) {
    
    # Initialize
    $header="";
    $footer="";
    @state=();

    # Search beginning of part describing the HMM states
    while ($line=<INFILE>) { 
#    print("Header: $line");
	$header.=$line; 
	if($line=~/^\s+M->M\s/){last;} 
    }
    if (!defined $line) {last;} # Reached end of file
    if ($line!~/^\s+M->M\s/) {die("Error: incorrect format in .hmm file: $!\n");}
    $line=<INFILE>;
    $header.=$line;
    
    # Read HMM states
    $i=0;
    while ($line=<INFILE>) {
	if ($line!~/^\w \d[ 0-9]{3}/) {last;}
	$i++;
	$state[$i]=$line;
	$state[$i].=<INFILE>;
    }
    if (!defined $line) {last;} # Reached end of file
    $L=$i;
    
    # Read footer
    while(1) {
	$footer.=$line; 
#    print("Footer: $line");
	if ($line=~/^\/\/$/) {last;}
	$line=<INFILE>;
	if (!defined $line) {last;}
    }
    if (!defined $line) {last;} # Reached end of file
    
    # Write header and scrambled columns into outfile
    print(OUTFILE $header);
    for ($i=1; $i<=$L; $i++) {
	$j=int(rand($L)+1);
#    printf("j=%-3i  L=%-3i\n",$j,$L);
	substr($state[$j],2,4,sprintf("%-4i",$i));
	print(OUTFILE $state[$j]);
    }
    print(OUTFILE $footer);
    
    $n++;
    if ($n%100 == 0) {print("$n\n");}
   
} # End while(1)
    
    
close(INFILE);
close(OUTFILE)
