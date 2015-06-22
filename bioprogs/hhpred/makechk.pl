#! /usr/bin/perl -w
# Usage: makechk.pl "file-glob.psi"  
# Generate checkpoint file for all globbed files (must be in *.psi-format)

use strict;

# Default values:
# Filter thresholds for sequences before aligning with clustal and building an HMM 
my $id=90;                        #maximum sequence identity
my $qid=15;                       #minimum sequence identity with query
my $cov=0;                        #minimum coverage before clustal
my $weighting="-wps";             #weighting scheme: "wps" or "wg" (position specific or global)
my $lga="-la";                    #input alignments are local or global: "-la" or "-ga"
my $M="-M a2m";                   #match/insert assignment

# directory path
my $hh="/home/soeding/hh";    #perl directory: querydb.pl, alignhits.pl


if (scalar(@ARGV)<1) 
{
    print("
Generate checkpoint file for all globbed files (must be in *.psi-format)
For each *.psi file a file *.sq with the query sequence in fasta format is required
Usage: makechk.pl 'file-glob.psi'
\n"); 
    exit;
}

my $glob = $ARGV[0];
my @files = glob("$glob"); #read all such files into @files 
my $file;
my $basename;
my $line;

print (scalar(@files)." files read in. Starting selection loop ...\n");

foreach $file (@files)
{   
    if ($file =~/(.*)\..*/)    {$basename=$1;} else {$basename=$file;}
    if (!-e "$basename.sq") {print("Error: $basename.sq does not exist. Skipping $file\n"); next;}
    &System("blastpgp -b 0 -j 1 -h 1E-4 -i $basename.sq -d ~/nr/dummy -B $file -C $basename.chk -o tmp.bla");
}
exit(0);

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

