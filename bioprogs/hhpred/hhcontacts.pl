#! /usr/bin/perl -w
# Usage:   hhcontacts.pl file-glob
use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/bioprogs/hhpred";  # forchimaera  webserver: MyPaths.pm
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with path variables for nr, blast, psipred, pdb, dssp etc.
 
# Default parameters for Align.pm
our $d=3;  # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penatlty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
our $v=3;    # verbose mode
our $matrix="identity";

my $ARGC=scalar(@ARGV);
if ($ARGC<1) {
    print("\nRead in all globbed *.hhm files and add the contact map information \n");
    print("to the end of the hhm files. Contacts are calculated from a pdb file <name>.pdb\n");
    print("found in a specified directory. from the original pdb file of the parent structure.\n");
    print("The script calls contacts.C which outputs a list of atom-atom contacts\n");
    print("(i j pair R) into a file *.contacts.\n");
    print("(i,j=residue numbers, pair=atom pair code, R=spatial distance in A)\n\n");
    print("Usage:   hhcontacts.pl file-glob [pdb-dir]\n");
    print("Example: hhcontacts.pl '*.hhm'\n");
    exit;
}

my @files = glob($ARGV[0]);
my $dir=".";    # default dir =  working directory
my $infile;
my $base;       # basename of hmmfile (no extension)
my @line;       # all lines from hhm file
my $name;       # name of scop query sequence for hmmfile
my $chain;      # chain id of scop query sequence for hmmfile 
my $pdbfile;    # pdbfile corresponding to query sequence
my $aaq;        # query amino acids
my $structure;  # pdb-formatted file used for calculating contacts (either original PDB file of file generated for SCOP domain)
my $i;          # index for column in HMM
my $l;          # index for line in hhm file

if ($ARGC>=2) { $dir=$ARGV[1]; }

if ($v>=2) {printf("Found %i files of type %s ...\n\n",scalar(@files),$ARGV[0]);}

# Read in one hhm-file after the other
foreach $infile (@files) {
    
    if ($infile=~/(.*)\..*$/) {$base=$1;} else {$base=$infile;}

    # Open hhm file and read name and chain id of query
    if ($v>=2) {printf("Reading %s ... \n",$infile);}
    if (!open (INFILE,"<$infile")) {warn("Error: can't open $infile: $!\n"); next;}
    @line=<INFILE>;
    close (INFILE);

    for($l=0; $l<@line; $l++) {if ($line[$l]=~/NAME/) {last;} }
    if ($line[$l]!~/NAME\s+(\S+)/) {warn ("Error: can't fine NAME line in $infile: $!\n"); next;}
    $name=$1;
    if (!-e "$dir/$name.pdb") {warn("WARNING: $dir/$name.pdb not found; skipping $infile...\n"); next;}
    
    # Scan up to end of file (//)
    for($l++; $l<@line; $l++) {if ($line[$l]=~/^\#/) {last;}} 
    for($l++; $l<@line; $l++) {if ($line[$l]=~/^\/\/|^\#/) {last;}} 

    $line[$l++]="#CONTACTS\n"; # $line[$l] is next line to be written
    
    # Call contacts.C to get list of contacts: i j pi R(i,j,pi)
    if ($v>=3) { print("$hh/contacts $dir/$name.pdb stdout |\n" );}
    if (!open(CONTACTS,"$hh/contacts $dir/$name.pdb stdout |")) {
	warn("Error: can't open '$hh/contacts $infile stdout |': $!\n");
	next;
    }

    # Read list of contacts and add counts
    my $line;
    my $Nc=0;
    while ($line=<CONTACTS>) {
	if ($line=~/^(\d+\s+\d+\s+\d+\s+\d+)/) {
	    $line[$l++]=$1."\n";
	    $Nc++;
	}
    }
    close (CONTACTS);
    $line[$l]="//\n";
    splice(@line,$l+1);
    if ($v>=2) {printf("Counted %i contacts\n",$Nc);}

    # Write hhm file
    my $hhmfile =  $infile;
    if ($v>=3) {print("Writing contacts to $infile ...\n");}
    if (!open (HHMFILE,">$hhmfile")) {warn("Error: can't open $hhmfile: $!\n"); next;}
    foreach $line (@line) {print(HHMFILE $line);}
    close(HHMFILE)

}

exit(0);

