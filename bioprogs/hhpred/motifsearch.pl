#!/usr/bin/perl 
# Search for regular expressions in DNA sequences
use strict;

if (@ARGV<2) {
    print("Search for a regular expression in a FASTA file of DNA sequences\n");
    print("Usage:   searchmotif.pl <file> <structured motif>\n");
    print("Example: searchmotif.pl test.fasta 'TNGA[12,14]TWNYTNNA[19,21]TNTMYRT[4,6]WNCCNNNNRG'\n");
    print("\n");
    exit;
}

$/=">";  # input record seperator
my $line;
my $name;
my $regex=$ARGV[1];
print("Original regular expression:    $regex\n");
$regex=~s/\[([0-9,]+)\]/.{$1}/g; # replace [12,14] with .{12,14}
$regex=~s/N/./g;
$regex=~s/R/[AG]/g;
$regex=~s/Y/[CT]/g;
$regex=~s/K/[GT]/g;
$regex=~s/M/[AC]/g;
$regex=~s/S/[GC]/g;
$regex=~s/W/[AT]/g;
$regex=~s/B/[CGT]/g;
$regex=~s/D/[AGT]/g;
$regex=~s/H/[ACT]/g;
$regex=~s/V/[ACG]/g;
$regex=~s/\s//g;
print("Transformed regular expression: $regex\n\n");

if (0) {
    
    open (INFILE,"<$ARGV[0]") || die("Error: can't open $ARGV[0]: $!\n");
    while ($line=<INFILE>) {
	if ($line eq ">") {next;}
	while ($line=~/>$/ && $line!~/\n>$/) {$line.=<INFILE>;}
	$line=~s/^(\S*).*//;
	$name=$1;
	$line=~tr/\n>//d;
	while ($line=~/($regex)/go) {
	    printf("%-30.30s  %s\n",$name,$1);
	}
    }
    close(INFILE);

} else {
    
    my $pos=1;
    open (INFILE,"<$ARGV[0]") || die("Error: can't open $ARGV[0]: $!\n");
    while ($line=<INFILE>) {
	if ($line eq ">") {next;}
	while ($line=~/>$/ && $line!~/\n>$/) {$line.=<INFILE>;}
	$line=~s/^(\S*).*//;
	$name=$1;
	$line=~tr/\n>//d;
	while ($line=~s/^(.*?)($regex)//o) {
	    $pos+=length($1);
	    printf("%-30.30s  %4i  %s\n",$name,$pos,$2);
	}
    }
    close(INFILE);
}
