#!/usr/bin/perl -w
use strict;   

$|=1;  # force flush after each print

# Default parameters
my $v=2;

my $usage = "
Read infile with fasta sequences and distribute sequences into N files (named infile_1 to infile_N) 
according to the hash value for its id (using the multiplication method). The id is the gi number, 
or, if no gi number is found, the characters between '>' and the first non-whitespace character.
Usage: hashdb.pl infile outdir [N]
\n";

if (@ARGV<1) {die $usage;}

# Variable declarations 
our $v=2;
my $infile=$ARGV[0];
my $outdir=".";
my $N=37;
if (@ARGV>=2) {$outdir=$ARGV[1];}
if (@ARGV>=3) {$N=$ARGV[2];}
my $line;

# Extract full-length sequences from database and store in dbm
open (INFILE, "<$infile") || die "ERROR: Couldn't open $infile: $!\n";

my $id="";     # gi number of nr sequence
my $nameline;  # full name line of nr sequence
my $seq;       # nr sequence (without whitespace)
my $nseq=0;
my $hval=-1;    # hash value of string $id
my @buffer;    # array with $N string buffers for the $N output files
my @nseq;      # nubmer of sequences in each outfile

for (my $n=0; $n<$N; $n++) {$buffer[$n]=""; $nseq[$n]=0; }

# Read one sequence after the other and store in appropriate outfile buffer
for (;;) {
    $line=<INFILE>;
    if (!$line || $line=~/^>/) {
	if ($hval>=0) {
	    if ($v>=3) {printf("%6i %15.15s -> %-2i\n",$nseq,$id,$hval);}
	    $buffer[$hval].="$nameline$seq"; # store nameline in dbm-hash
	    ($nseq[$hval])++;
	}
	if(!$line) {last;}
	if ($line=~/^>\s*gi\|(\d+)/ || $line=~/^>\s*(\S+)/) {
	    $id=$1; 
	    $nameline=$line;
	    $hval=&HashVal($id,$N);
	}
	$seq="";
	$nseq++;
    } elsif ($id) {
	$seq.=$line;
    }
}
close INFILE;
if ($v>=2) {print(STDERR "found $nseq sequences in input file\n")};

# Write out $N buffers into outfiles
#if ($infile=~/^(.*)\.\w*$/) {$infile=$1;} ; # remove extension
if ($infile=~/^.*\/(.*?)$/) {$infile=$1;} ; # remove path
for (my $n=0; $n<$N; $n++) {
    $outdir=~s/\/$//;          # remove last slash
    my $outfile="$outdir/".$infile."_$n";
    open (OUTFILE,">$outfile") || die ("ERROR: couldn't open $outfile: $!\n");
    print(OUTFILE $buffer[$n]);
    close (OUTFILE);
    if ($v>=2) {print(STDERR "Written $nseq[$n] sequences into $outfile\n")};
}

###################################################################################################
# Calculate a hash value by the division method: 
###################################################################################################
sub HashVal() {
    # Transform key into a natural number k = sum ( key[i]*128^(L-i) ) and calculate i= k % N. 
    # Since calculating k would lead to an overflow, i is calculated iteratively 
    # and at each iteration the part divisible by num_slots is subtracted, i.e. (% num_slots is taken).
    my @key = split(//,$_[0]);
    my $N = $_[1];
    my $k=0;     # Start of iteration: k is zero
    my $c;
    foreach $c (@key) {$k = ($k*128+$c) % $N;}
    return $k;
}
