#! /usr/bin/perl -w
# Usage: hhmakeall.pl fileglob [options]
# Run hhmake for all globbed files in current directory

BEGIN { 
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/cluster/soeding/perl");     # for cluster
    push (@INC,"/cluster/bioprogs/hhpred");  # for chimaera  webserver: MyPaths.pm
    push (@INC,"/cluster/lib");              # for chimaera webserver: ConfigServer.pm
}
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with paht variables for nr, blast, psipred, pdb, dssp etc.

if (scalar(@ARGV)<1) {
   print("
Generate an HMM with hhmake for all globbed files
Usage:   hhmakeall.pl fileglob [hhmake options] [options] 
Options:
 -u          : update: skip if *.hhr already exists
 -rev        : reverse file list, i.e. start from the end
 -first int  : skip files with index 0 to first-1
Example: hhmakeall.pl '*.a3m' -M first -u > hhmakeall.log 2>&1 &
\n"); 
    exit;
}

# Default values:
# Filter thresholds for sequences before aligning with clustal and building an HMM 
my $id=100;               # maximum sequence identity
my $qid=0;                # minimum sequence identity with query
my $cov=0;                # minimum coverage before clustal
my $weighting="-wps";     # weighting scheme: "wps" or "wg" (position specific or global)
my $lga="-la";            # input alignments are local or global: "-la" or "-ga"
my $M="-M a3m";           # match/insert assignment
my $v=2;                  # verbose mode

# Variables
my @files = glob("$ARGV[0]"); #read all such files into @files 
my $update=0;      # default: calculate every hhr file anew
my $first=0;       # index of query file to start with 
my $rev=0;         # reverse mode (def=off)
my $options=" ";   # command line options
my $file;          # current file
my $ifile;
my $i;
my $basename;      # no extension
my $rootname;      # no path, no extension
my $line;

if ($v>=2) {
    print ("Running hhmake.pl @ARGV:\n");
    print ("id        = $id\n");
    print ("qid       = $qid\n");
    print ("cov       = $cov\n");
    print ("weighting = $weighting\n");
    print ("loc/glob  = $lga\n");
    print ("Match/Ins = $M\n");
}

if (@ARGV>1) {
    $options.=join(" ",@ARGV[1..$#ARGV]);
}

# Set number of cpus to use
if ($options=~s/ -u\s*//g)          {$update=1;}
if ($options=~s/ -rev\s*//g)        {$rev=1;}
if ($options=~s/ -first\s+(\d+)//g) {$first=$1;}

print (scalar(@files)." files read in ...\n");


for ($i=$first; $i<@files; $i++) {   
    if ($rev) {$ifile=($#files-$i);} else {$ifile=$i;}
    $file=$files[$ifile];
#    if ($file =~/(.*)\..*?$/)     {$basename=$1;} else {$basename=$file;} # basename = name without extension
#    if ($basename =~/.*\/(.*?)$/) {$rootname=$1;} else {$rootname=$basename;} # rootname = basename without path

    if ($update==1 && -e "$rootname.hhm") {next;}
    print(">>>>>>>> $ifile: $file <<<<<<<<\n");
    &System("$hh/hhmake -i $file $options");
    print("\n");
}
print("Finished hhmakeall\n");
exit(0);

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

