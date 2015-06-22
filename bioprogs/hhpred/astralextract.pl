#!/usr/bin/perl -w
# Read through astral file and create a file per SCOP family containing all
# sequences in the astral file
#
# Usage: astralextract.pl sourcefile templatedir 
# Example: astralextract.pl astral.scopdom.sequences.pdb95.v1.59.txt /data/fam/pdb95/
#

use strict;
use File::Basename;

if (scalar(@ARGV)<2) 
{
    print("\nExtract sequences from astral-file and write all sequences belonging to same family into files, with names a.1.1.1.seq etc.\n"); 
    print("Usage: astralextract.pl sourcefile templatedir\n"); 
    print("Example: astralextract.pl astral.scopdom.sequences.pdb95.v1.59.txt /data/fam95/\n\n"); 
    exit;
}

my $infile = $ARGV[0];
my $templatedir = $ARGV[1];
my $extension = ".ali";
my $family="undefined";
my $line;
my $ members=0;
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
  		print("$family$extension contains $members sequences\n");
		$family=$1;
		$members=0;
	    close (OUTFILE);
	    open (OUTFILE, ">$templatedir$family$extension") or die "Couldn't open $templatedir$family.$extension: $!"; ;
	    }
	    $members++;
	}
	else
	{
	    print("Warning: no SCOP-family code found in line\n$line\nof astral file\n");
	}
    }
    print(OUTFILE "$line");
}
print("$family$extension contains $members sequences\n");


