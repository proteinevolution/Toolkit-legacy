#! /usr/bin/perl -w
use strict;

# Default parameters
my $v=2;
my $usage="
Reads the DALI domain sequences, selects one domain for each fold index (e.g. 1.2.3.4.5.6) 
and writes the selected domain sequences to the FASTA output file. 
Selection criteria are length and resolution.

Usage: dalifilter.pl dali90.fas dali.fas
\n";

if (@ARGV<2) {die("$usage");}

my $infile=$ARGV[0];        
my $outfile=$ARGV[1];
my $line;
my $n;           # number of domains (read in from domain_definitions.txt)
my $k;           # index for domain in @domainids, @foldids, @ranges
my $i;           # index for domain in @domainids, @foldids, @ranges

my %index;       # $index{$dali_id} gives the index of domain $domainid in @domainids, @foldids, @ranges
my $foldindex;
my $resolution;
my $rvalue;
my $length;
my $residues="";
my $nameline;
my @resolutions;
my @rvalues;
my @lengths;
my @residues;
my @names;

;
# Read FoldIndex.html
print("Reading $infile ... ");
open (INFILE,"<$infile") || die ("ERROR: cannot open $infile: $!\n");
$n=0;
$k=0;
#>1qsdA_1  1.1.3.1.1.1 (1-106) BETA-TUBULIN BINDING POST-CHAPERONIN COFACTOR (2.2A, R=0.208)
#maptqldikvkalkrltkeegyyqqelkdqeahvaklkedksvdpydlkkqeevlddtkrllptlyekirefkedleqflktyqgtedvsdarsaitsaq
#elldsk
while($line=<INFILE>) {
    if ($line=~/^>\S+\s+(\d+\.\d+\.\d+\.\d+\.\d+\.\d+)\s+(\(\S+\))?\s*.*\((\S+)A, R=(\S+)\)/) {
	if ($residues) {
	    if (exists $index{$foldindex}) {
		$i=$index{$foldindex};
		if($resolutions[$i]>$resolution) {
		    $resolutions[$i]=$resolution;
		    $rvalues[$i]=$rvalue;
		    $lengths[$i]=$length;
		    $residues[$i]=$residues;
		    $names[$i]=$nameline;
		}		
	    } else {
		$resolutions[$k]=$resolution;
		$rvalues[$k]=$rvalue;
		$lengths[$k]=$length;
		$residues[$k]=$residues;
		$names[$k]=$nameline;
		$index{$foldindex}=$k++;
	    }
	}
	$foldindex=$1;
	if ($3==-1) {$resolution=100;} else {$resolution=$3;}
	$rvalue=$4;
	$length=length($residues);
	$residues="";
	$nameline=$line;
	$n++;
    } else {
	$residues.=$line;
    }
}
if ($residues) {
    if (exists $index{$foldindex}) {
	$i=$index{$foldindex};
	if($resolutions[$i]>$resolution) {
	    $resolutions[$i]=$resolution;
	    $rvalues[$i]=$rvalue;
	    $lengths[$i]=$length;
	    $residues[$i]=$residues;
	    $names[$i]=$nameline;
	    $n++;
	}		
    }
} else {
    $resolutions[$k]=$resolution;
    $rvalues[$k]=$rvalue;
    $lengths[$k]=$length;
    $residues[$k]=$residues;
    $names[$k]=$nameline;
    $index{$1}=$k++;
    $n++;
}
close(INFILE);
print(" found $n domains and $k representative domains\n");


# Write domain sequences to $outfile
print("Writing $outfile with $k domains...\n");
open (OUTFILE,">$outfile") || die ("ERROR: cannot open $outfile for writing: $!\n");
for ($i=0; $i<$k; $i++) {
    print(OUTFILE $names[$i]);
    print(OUTFILE $residues[$i]);
}
close(OUTFILE);
exit;


##################################################################################
# Convert three-letter amino acid code into one-letter code
##################################################################################
sub Three2OneLetter {
    my $res=uc($_[0]);
    if    ($res eq "GLY") {return "G";}
    elsif ($res eq "ALA") {return "A";}
    elsif ($res eq "VAL") {return "V";}
    elsif ($res eq "LEU") {return "L";}
    elsif ($res eq "ILE") {return "I";}
    elsif ($res eq "MET") {return "M";}
    elsif ($res eq "PHE") {return "F";}
    elsif ($res eq "TYR") {return "Y";}
    elsif ($res eq "TRP") {return "W";}
    elsif ($res eq "ASN") {return "N";}
    elsif ($res eq "ASP") {return "D";}
    elsif ($res eq "GLN") {return "Q";}
    elsif ($res eq "GLU") {return "E";}
    elsif ($res eq "CYS") {return "C";}
    elsif ($res eq "PRO") {return "P";}
    elsif ($res eq "SER") {return "S";}
    elsif ($res eq "THR") {return "T";}
    elsif ($res eq "LYS") {return "K";}
    elsif ($res eq "HIS") {return "H";}
    elsif ($res eq "ARG") {return "R";}
    elsif ($res eq "SEC") {return "X";}
    elsif ($res eq "ASX") {return "D";}
    elsif ($res eq "GLX") {return "E";}
    elsif ($res eq "KCX") {return "K";}
    elsif ($res eq "MSE") {return "M";} # SELENOMETHIONINE 
    elsif ($res eq "SEP") {return "S";} # PHOSPHOSERINE 
    elsif ($res =~ /\s*/) {return "";}  
    else                  {return "X";}
}
