#!/usr/bin/perl -w
use strict;

if (@ARGV<1) {
    print("Calculate the amino acid frequency distribution for a FASTA alignment\n");
    print("Usage: aacomposition.pl <FASTA-file> [-res <first>-<last>]\n");
    print("\n");
    exit();
}


my $infile=$ARGV[0];
my $first=0;
my $last=100000;
my $counts=0;
my @aacounts=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
my @fbg=(7.68,5.14,4.02,5.41,1.89,3.27,5.99,7.56,3.69,5.06,10.01,5.97,2.20,3.50,4.54,4.67,7.12,1.25,3.95,7.28,5.0);
# Amino acids Sorted by alphabet     -> internal numbers a 
#          0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#          A  b  C  D  E  F  G  H  I  j  K  L  M  N  o  P  Q  R  S  T  u  V  W  x  Y  z
my @s2a =( 0,21, 4, 3, 6,13, 7, 8, 9,21,11,10,12, 2,21,14, 5, 1,15,16,21,19,17,20,18,21);
# Internal numbers a for amino acids -> amino acids Sorted by alphabet: 
#          0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
#          A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V  X
my @a2s =( 0,17,13, 3, 2,16, 4, 6, 7, 8,11,10,12, 5,15,18,19,22,24,21,23);

my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# General options
if ($options=~s/ -r\s+(\d+)-(\d+) / /g) {$first=$1-1; $last=$2-1;}

# Read FASTA file
$/=">"; # set input field seperator
my @seqs=();  # sequences read in from $tmp.in.a3m
my $seq;      # sequence read in
my $i=0;
open (INFILE, "<$infile") or die ("ERROR: cannot open $infile: $!\n");
while ($seq=<INFILE>) {
    if ($seq eq ">") {next;}
    while ($seq=~s/(.)>$/$1/) {$seq.=<INFILE>;} # in the case that nameline contains a '>'
    $seq=~s/^(.*)//;        # divide into nameline and residues; '.' matches anything except '\n'
#    $nameline=">$1";        # don't move this line away from previous line $seq=~s/([^\n]*)//;
    $seq=~tr/\n> .//d;      # remove all newlines, '.'
    $seq=~tr/acdefghiklmnpqrstvwyACDEFGHIKLMNPQRSTVWY//cd;   # remove all newlines and non-residue non-gap characters
    $seq=~tr/a-z/A-Z/;      # transform to upper case
    my @seq=unpack("C*",$seq);
    for (my $j=$first; $j<=&min($last,@seq-1); $j++) {
#	printf("%3i  %3i  %3i\n",$j,$seq[$j],$s2a[$seq[$j]-65]);
	$aacounts[ $s2a[$seq[$j]-65] ]++;
	$counts++;
    }
}
close (INFILE);
$/="\n"; # set input field seperator

# Print amino acids
print("Amino acids          ");
for (my $a=0; $a<20; $a++) {printf("     %s ",chr(65+$a2s[$a]));}
print("\n");

# Print aa counts
print("Amino acid counts    ");
for (my $a=0; $a<20; $a++) {printf("%6i ",100.0*$aacounts[$a]);}
print("\n");

# Print background frequencies
print("Amino acid bg freqs  ");
for (my $a=0; $a<20; $a++) {printf("%6.2f ",$fbg[$a]);}
print("\n");

# Print aa frequencies
print("Amino acid freqs     ");
for (my $a=0; $a<20; $a++) {printf("%6.2f ",100.0*$aacounts[$a]/$counts);}
print("\n");

# Print difference of frequencies
print("Amino acid freq diff ");
for (my $a=0; $a<20; $a++) {printf("%6.2f ",100.0*$aacounts[$a]/$counts-$fbg[$a]);}
print("\n");

# Print log odds 
print("Amino acid log odds  ");
for (my $a=0; $a<20; $a++) {printf("%6.2f ",log(100.0*$aacounts[$a]/$counts/$fbg[$a])/log(2));}
print("\n");

exit;

##################################################################################
# Minimum
##################################################################################
sub min {
    my $min = shift @_;
    foreach (@_) {
	if ($_<$min) {$min=$_} 
    }
    return $min;
}
