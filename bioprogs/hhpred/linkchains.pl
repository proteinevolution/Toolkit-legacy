#! /usr/bin/perl -w

use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/bioprogs/hhpred";  # forchimaera  webserver: MyPaths.pm
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with paht variables for nr, blast, psipred, pdb, dssp etc.
use Align;

$|=1;  # force flush after each print

# Default parameters
our $d=1;    # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penalty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
my $v=2;     # 3: DEBUG
my $help="
 Link all chains from a pdb file specified by a regular expression into a single chain 
 with correct numbering of residues. Leaves a gap of 20 in the residue count between chains 
 as imaginary linker. Make sure that the chain regex matches only a single character.
 Usage: linkchains.pl infile outfile chain-regex
 Options:
 -het      include HETATM records
 -v <int>  verbose mode (default=2)
 Example: linkchains.pl /raid/db/pdb/pdb1mka.ent 1mka.pdb [AB]
\n";

# Processing command line options
if (@ARGV<1) {die $help;}

# Variable declarations
my $infile="";
my $outfile="";
my $chain_regex="";
my $gapwidth=20;          # leave gap of 20 in residue count between chains
my $line;
my $left;
my $right;
my $resnumber=0;
my $offset=0;
my $chain=undef;
my $options="";
my $atom=0;               # number of ATOM lines written
my $hetatm=0;             # number of HETATM lines written
my $het=0;                # default: do not include HETATM records
 

# Set options
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}
if ($options=~s/ -i\s+(\S+) //g) {$infile=$1;}
if ($options=~s/ -o\s+(\S+) //g) {$outfile=$1;}
if ($options=~s/ -r\s+(\S+) //g) {$chain_regex=$1;}
if ($options=~s/ -het //g) {$het=1;}
if ($options=~s/ -v\s+(\d+) //g) {$v=$1;}
elsif ($options=~s/ -v //g)      {$v=1;}

# Read infile and outfile 
if (!$infile  && $options=~s/^\s*([^-]\S+)\s*//) {$infile=$1;} 
if (!$outfile && $options=~s/^\s*([^-]\S+)\s*//) {$outfile=$1;} 
if (!$chain_regex && $options=~s/^\s*([^-]\S+)\s*//) {$chain_regex=$1;} 

# Warn if unknown options found or no infile/outfile
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; die("Error: unknown options '$options'\n");}
if ($infile eq "")  {die("$help\nError: input file missing: $!\n");}
if ($outfile eq "") {die("$help\nError: output file missing: $!\n");}
if ($chain_regex eq "") {die("$help\nError: chain-regex missing: $!\n");}

# Read infile ATOM records and write ATOM records to outfile, line by line
open (OUTFILE,">$outfile") || die ("Error: could not open $outfile for writing: $!\n");

open (INFILE,"<$infile") || die ("Error: could not open $infile for reading: $!\n");
while ($line=<INFILE>) {
    if ($line=~/^ATOM/o || ($line=~/^HETATM/ && $line=~/^.{17}MSE/o)) {
	if ($line=~/^(.{21})($chain_regex)\s*(\d+)(.{54})/o) {
	    if ($chain && $2 ne $chain) {
		$offset+=$resnumber+$gapwidth;
	    }
	    $left=$1;
	    $chain=$2;
	    $resnumber=$3;
	    $right=$4;
	    printf(OUTFILE "%s %4i%s\n" ,$left,$resnumber+$offset,$right);
	    if ($v>=3) {
#		printf("old: %s" ,$line);
		printf("new: %s %4i%s\n" ,$left,$resnumber+$offset,$right);
	    }
	    $atom++;
	}
    } elsif ($line=~/^HEADER/) {
	printf(OUTFILE "%s",$line);
	printf(OUTFILE "%-80.80s\n", "REMARK    Chains $chain_regex linked together with perl linkchains.pl");
    } elsif ($line=~/^TITLE|REMARK|KEYWDS|EXPDTA|KEYWDS|COMPND|SOURCE/) {
	printf(OUTFILE "%s",$line);
    } 
}
printf(OUTFILE "%-80.80s\n","TER");
close(INFILE);

if ($het) {
    # Read infile HETATM records and write HETATM records to outfile, line by line
    open (INFILE,"<$infile") || die ("Error: could not open $infile for reading: $!\n");
    while ($line=<INFILE>) {
	if ($line=~/^HETATM/o && $line!~/^.{17}(HOH|MSE)/o) {
	    if ($line=~/^(.{21})($chain_regex)\s*(\d+)(.{54})/o) {
		if ($chain && $2 ne $chain) {
		    $offset+=$resnumber+1-$3;
		}
		$left=$1;
		$chain=$2;
		$resnumber=$3;
		$right=$4;
		printf(OUTFILE "%s %4i%s\n" ,$left,$resnumber+$offset,$right);
		if ($v>=3) {
#		printf("old: %s" ,$line);
		    printf("new: %s %4i%s\n" ,$left,$resnumber+$offset,$right);
		}
		$hetatm++;
	    }
	} 
    }
    close(INFILE);
}
if ($v>=2) {print("Written $atom ATOM lines and $hetatm HETATM lines to $outfile\n");}

close(OUTFILE);

