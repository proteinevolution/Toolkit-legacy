#! /usr/bin/perl -w
# Read in HMMER hmm file and increase transition probabilities for
# transitions M->D, M->I, D->D, I->I according to parameters f, g, h, and i.
# Usage:   hmmbuild+.pl infile [options]
# Example: hmmbuild+.pl d12asa_.hmm -f 0.5 -g 0.5 -h 0.8 -i 0.8   

use strict;

if (scalar(@ARGV)<2) {
    print("
 Read in HMMER hmm file and increase transition probabilities for
 transitions M->D, M->I, D->D, I->I according to parameters f, g, h, and i.
 Usage:   hmmbuild+.pl infile [outfile] [options]
 Example: hmmbuild+.pl d12asa_.hmm -f 0.5 -g 0.5 -h 0.8 -i 0.8 -v 0
\n"); 
    exit;
}

# Constants/Parameters
my $v=2;                 # verbose mode
my $line;
my $infile;
my $outfile;
my $f=0.5;               # change -log(p(M->D)) -> -$f*log(p(M->D))
my $g=0.5;               # change -log(p(M->I)) -> -$g*log(p(M->I))
my $h=0.5;               # change -log(p(D->D)) -> -$h*log(p(D->D))
my $i=0.5;               # change -log(p(I->I)) -> -$i*log(p(I->I))
my $HMMSCALE=1000;       # scale factor for logarithms of probabilities in hmm file
my $SCALELOG2=$HMMSCALE/log(2);
my $pMM;
my $pDM;
my $pIM;


my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i]";}

# Verbose mode?
if ($options=~s/ -v\s*(\d)//g) {$v=$1;}
if ($options=~s/ -v//g) {$v=2;}

# Transition parameters
if ($options=~s/ -f\s*(\S+)//g) {$f=$1;}
if ($options=~s/ -g\s*(\S+)//g) {$g=$1;}
if ($options=~s/ -h\s*(\S+)//g) {$h=$1;}
if ($options=~s/ -i\s*(\S+)//g) {$i=$1;}

# Input and output file
if ($options=~s/ -i\s+(\S+)//g) {$infile=$1;}
if ($options=~s/ -o\s+(\S+)//g) {$outfile=$1;}
if (!$infile  && $options=~s/^\s*([^-]\S*)\s*//) {$infile=$1;} 
if (!$outfile  && $options=~s/^\s*([^-]\S*)\s*//) {$outfile=$1;} 

# Warn if unknown options found or no infile/outfile
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; die("Error: unknown options '$options'\n");}
if (!$infile) {print("Error: no output file given\n"); exit(1);}
if (!$outfile) {
    $outfile=$infile; 
    if ($outfile!~s/\.hmm$/+.hmm/) {print("Error: no output file given\n"); exit(1);}
    elsif ($v>=2) {print("Writing output to $outfile\n");}
}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}

my $f1=0.001*$f;
my $g1=$g/$HMMSCALE;
my $h1=$h/$HMMSCALE;
my $i1=$i/$HMMSCALE;

open (INFILE, "<$infile") || die ("ERROR: cannot open $infile for reading: $!\n");
open (OUTFILE, ">$outfile") || die ("ERROR: cannot open $outfile for writing: $!\n");

while ($line=<INFILE>) {
    if ($line=~/^\s{5}-\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)(\s+\S+)(\s+\S+)/) {
	$pMM=$SCALELOG2*log(1-2**($f1*$3)-2**($g1*$2));
	$pIM=$SCALELOG2*log(1-2**($i1*$5));
	$pDM=$SCALELOG2*log(1-2**($h1*$7));
	printf(OUTFILE "     - %6i %6i %6i %6i %6i %6i %6i%s%s\n",$pMM,$g*$2,$f*$3,$pIM,$i*$5,$pDM,$h*$7,$8,$9);
    } else {
	print(OUTFILE $line);
    }
}

close (INFILE);
close (OUTFILE);

