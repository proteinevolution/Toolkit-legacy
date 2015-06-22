#!/usr/bin/perl -w

use strict;
my $ext="*";
my $v=2;
my $usage="
Copy all files seqname.* whose seqname is found in the FASTA sequence file from dir to present directory
Usage:   copysubdb.pl seqfile dir [extension]
Example: copysubdb.pl scop50.1.67 ~/scop50.1.65 a3m
";

if (@ARGV<2) {die("$usage\n");}
my $seqfile = $ARGV[0];
my $dbdir = $ARGV[1];
my $line;
my $fileglob;
my @files;
my $notfound=0;

open (SEQFILE,"<$seqfile") or die("Error: can not open $seqfile: $!\n");
while($line=<SEQFILE>) {
    if ($line=~/^>/) {
	if ($line=~/^>([a-z]\S{6})\s+[a-z]\.\d+\.\d+\.\d+/) {
	    $fileglob="$dbdir/$1.$ext";
	    @files=glob($fileglob);
	    if (scalar(@files)==0) {
		$notfound++;
		print("WARNING: no file $fileglob found ($notfound)\n");
	    } else {
		&System("cp @files ./");
	    }
	} else {
	    print("WARNING: wrong name format in nameline:\n$line");
	}
    }
}

printf("Could not find %i files\n",$notfound);
exit;

sub System() {
    if ($v>=2) {print("$_[0]\n");} 
    return system($_[0])/256;
}

