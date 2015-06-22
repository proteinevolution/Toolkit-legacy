#! /usr/bin/perl -w
# Usage: perl multiblast.pl 
# Read sequences from current directory with 'extension' and perform a psipred prediction for each.
# Example:
# nice -19 perl multipsipred.pl seq > log &

use strict;

my $ext="seq";
if (scalar(@ARGV)<2)
{
    print("\nRead sequences in fasta sequence file and perform a psipred prediction for each.\n");
    print("Usage: perl multiblast.pl infile outdir\n");
    print("Example: nice -19 multipsipred.pl pdb30 . > log &\n\n");
    exit;
};

# Variable declarations
my $infile=$ARGV[0];
my $outdir=$ARGV[1];
my $currfile="delme.tmp";
my $name;
my $line;
my $overwrite=0;       # 1: overwrite  -1:skip existing files  0:inquire 


print ("Running mulitpsipred.pl @ARGV:\n");
print ("\n");

open (INFILE, "<$infile") || die ("cannot open $infile: $!");
open (ALIFILE, ">delme.tmp")|| die ("cannot open delme.tmp: $!");

# Take one sequence after the other, write it into its file $name.seq 
# and run iterative PsiPred for each sequence
while (1) #assign next line of file to $inline while there is a next line
{
    $line=<INFILE>;
    if( (!$line) || ($line=~/^>/) )
    {
	close ALIFILE;

	if ($currfile ne "delme.tmp") 
	{
	    &System("/home/soeding/programs/psipred/runpsipred.pl $currfile.seq");
	} 
	if( (!$line)) {last;} # if no more new line => stop reading in

#	print("Reading $line");
	$name=$line;

	# Read nameline and extract SCOP family code
	if ($line=~/>(\S+)/) {$currfile="$outdir/$1";}

	# Open next sequence file (Does it exist already? If yes: overwrite or skip?)
	if (-e "$currfile.ss2")  # does the file already exist?
	{
	    if ($overwrite==0) 
	    {
		print("$currfile.ss2 already exists. Overwrite existing files? (y)  "); 
		$line=<STDIN>;
		if ($line =~/^[Yy]/) {$overwrite=1; print("Overwriting existing files\n");} 
		else {$overwrite=-1; print("Skipping exsting files\n");}
	    }
	    if ($overwrite==-1) {$currfile="delme.tmp"; open(ALIFILE,">delme.tmp");}	
	}
	else {print("$currfile.ss2 does not exist yet\n");}
	if ( (!(-e "$currfile.ss2") || $overwrite==1) && $currfile ne "delme.tmp")
	{
	    # Open new file to hold query sequence. Later used to append aligned hits 
	    open (ALIFILE, ">$currfile.seq")|| die("can't open $currfile.seq: $!");
	    print(ALIFILE "$name"); # Write query name in first line of file
	}
    }
    elsif ($currfile ne "delme.tmp")
    {
#	print("Residues: $line");
	$line=~tr/a-z/A-Z/; # transform into upper case
	print(ALIFILE "$line");
     }
}
close ALIFILE;
close INFILE;

print("\n\nFinished psipred runs!\n");
exit;

sub System()
{
    my $command=$_[0];
    print("\nCalling '$command'\n"); 
    return system($command)/256; # && die("\nERROR: $!\n\n"); 
}

