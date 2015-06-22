#!/usr/bin/perl -w
# Read through astral file and create a file per SCOP sequence

#
# Usage: astralextractseq.pl sourcefile templatedir 
# Example: astralextractseq.pl astral.scopdom.sequences.pdb95.v1.59.txt /data/seq/pdb95/
#

use strict;
use File::Basename;

if (scalar(@ARGV)<2) 
{
    print("\nExtract sequences from astral-file and write into files, one per sequence, with names a.1.1.1.n.seq \n"); 
    print("Usage: astralextractseq.pl sourcefile templatedir\n"); 
    print("Example: astralextractseq.pl astral.scopdom.sequences.pdb95.v1.59.txt /data/seq95/\n\n"); 
    exit;
}

my $infile = $ARGV[0];
my $templatedir = $ARGV[1];
my $extension = ".seq";
my $family="undefined";
my $line;
my $members=0;
#if (scalar(@ARGV)>=3) {$extension=$ARGV[2]};
#if (scalar(@ARGV)>=4) {$Catoms=$ARGV[3]};

print ("Reading in astral-file $infile ...\n");
open (INFILE, $infile) or die "Couldn't open $infile:$!"; 
while (defined($line=<INFILE>))
{
#    print("$line");
    if ($line=~/^>/) 
    {
	if( $line=~/\s([abcdefghijklmn]\.\d+\.\d+\.\d+)\s/)
	{
#	    print("New sequence found from family $1\n");
	    if ($1 ne $family)
	    {
  		print("$family contains $members sequences\n");
		$family=$1;
		$members=0;
	    }
	    $members++;
	    close (OUTFILE);
	    open (OUTFILE, ">$templatedir$family\.$members$extension") or die "Couldn't open $templatedir$family\.$members$extension: $!"; ;
	}
	else
	{
	    print("Warning: no SCOP-family code found in line\n$line\nof astral file\n");
	}
    }
    print(OUTFILE "$line");
}
print("$family contains $members sequences\n");


