#!/usr/bin/perl -w
# Rename *.a3m, *.psi, or *.hhm files after the name (or after the scop familiy) of the query sequence
# Usage:   renamealifiles.pl fileglob [-fam]
# Example: renamealifiles.pl "*.a3m"

use strict;
my $v=2;
my $usage="
Rename *.a3m, *.psi, or *.hhm files after the name (or after the scop familiy) of the query sequence
Usage:   renamealifiles.pl fileglob [-fam]
Example: renamealifiles.pl '*.*.a3m'
";

if (@ARGV<1) {die("$usage\n");}
my @files = glob($ARGV[0]);
my $file;
my $line;
my $ext;
my $name;
my $fam;
my $pdbmode=1;
my $options=join(" ",@ARGV);
my $nlines;
my %nfam;
my $n;
if ($options=~/-fam/) {$pdbmode=0;}

printf ("Reading in %i file names ...\n",scalar(@files));
foreach $file (@files) {
    $name=$fam="";
    open (FILE,"<$file") or die("Error: can not open $file: $!\n");
    if ($file=~/.*\.(\w+)$/) {$ext=$1;} else {$ext="";}

    if ($ext eq "psi") {
	while ($line=<FILE>) {
	    # Look for 'd1dlwa_ a.1.1.1 (A:) Description'
	    if ($line=~/^([a-z]\S{6})\s+/) {$name=$1; last;}
	}
    } elsif ($ext eq "scores") {
	$nlines=0;
	while ($line=<FILE>) {
	    if (($fam ne "" && $name ne "") || $nlines++>10) {last;}
	    # Look for 'd1dlwa_ a.1.1.1 (A:) Description'
	    if ($line=~/^NAME\s+([a-z]\S{6})\s+/) {$name=$1;}
	    elsif ($line=~/^FAM\s+([a-z]\.\d+\.\d+\.\d+)\s+/) {$fam=$1;}
	}
    } else {
	while ($line=<FILE>) {
	    # Look for '>d1dlwa_ a.1.1.1 (A:) Description'
	    if ($line=~/^>([a-z]\S{6})\s+([a-z]\.\d+\.\d+\.\d+)/) {$name=$1; $fam=$2; last;}
	}
    }
    close(FILE);
    if (!$line) {print("WARNING: no scop sequence name found in file $file\n"); next;}
    
    if ($pdbmode && defined $name) {
	&System("mv $file $name.$ext"); 
    } elsif (defined $fam) {
	$n=++$nfam{$fam};
	&System("mv $file $fam.$n.$ext"); 
    }
}
exit;
 
sub System() {
    if ($v>=2) {print("$_[0]\n");} 
    return system($_[0])/256;
}

