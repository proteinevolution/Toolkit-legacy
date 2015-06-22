#! /usr/bin/perl -w
# Usage: perl addscopfam.pl aligment-dir
# For each HMMer alignment file (*.hln) in current directory 
# insert the SCOP familiy sequences (extracted from the astral file) 
# as first sequences of the .hln file and redo hmmalign
# 

use strict;
use File::Copy;

my $hmmdir="/raid/users/soeding/hmmer/hmmer-2.2g/binaries/";
my $ext="seq";

if (scalar(@ARGV)<1) 
{
    print("\nFor each HMMer alignment file (*.hln) in current directory insert the SCOP familiy sequence (*.$ext-file) as first sequences of the .hln file and redo hmmalign\n"); 
    print("Usage:   perl addscopfam.pl alignment-dir\n\n"); 
    exit;
}
my $alidir = $ARGV[0];


my @files = glob("*.hln"); #read all such files into @files 
my $file;
my $basename;
my $alifile;
my $catfile;
my $tmpfile;
my $hmmfile;
my $a2mfile;
my $msffile;

print (scalar(@files)." files read in. Starting loop ...\n");


foreach $file (@files)
{   
    $file =~ /(.*\.)/;
    $basename = $1;
    $alifile = $alidir.$basename.$ext;
    $catfile = $basename."cat"; 
    $tmpfile = $basename."tmp"; 
    $hmmfile = $basename."hmm";
    $a2mfile = $basename."a2m";
    $msffile = $basename."msf";

    my $err;

    print("cat $alifile $file > $catfile \n");
    $err=system("cat $alifile $file > $catfile\n");
    if ($err!=0) {print("\'cat $alifile $file > $catfile\' failed: $!\n");}
  
    print("hmmalign -o $tmpfile $hmmfile $catfile \n");
    $err=system("hmmalign -o $tmpfile $hmmfile $catfile\n");
    if ($err!=0) {print("hmmalign -o $tmpfile $hmmfile $catfile failed: $!\n")}; 
 
    print("sreformat a2m $tmpfile > $a2mfile \n");
    $err=system("sreformat a2m $tmpfile > $a2mfile\n");
    if ($err!=0) {print("sreformat a2m $tmpfile > $a2mfile failed: $!\n")}; 

    print("sreformat msf $tmpfile > $msffile \n");
    $err=system("sreformat msf $tmpfile > $msffile\n");
    if ($err!=0) {print("sreformat msf $tmpfile > $msffile failed: $!\n")}; 
}
