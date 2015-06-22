#! /usr/bin/perl -w
#
# Show sequences for chains in a pdb file

use strict;


my $usage="Usage: pdbshowseq.pl file.pdb\n\n";
if (!$ARGV[0]) {die($usage);}

my $pdbfile=$ARGV[0];

# Read sequence from pdb file
if (!open (PDBFILE, "<$pdbfile")) {
    die ("Error: Couldn't open $pdbfile: $!\n");
}
$pdbfile=~s/\.\S+?$//;
$pdbfile=~s/^.*\///;
$pdbfile=~s/^pdb//;
my $line;
my $aapdb="";
my $l=0;
my $chain="nothing";
my $res;
my $prevchain="nothing";
my @nres;        # $nres[$l] = pdb residue index for residue $aapdb[$l]
my $resolution=-1.00;
my $rvalue=-1.00;
while ($line=<PDBFILE>) {
    if ($line=~/^REMARK.*RESOLUTION\.\s+(\d+\.?\d*)/) {$resolution=$1;}
    if ($line=~/^REMARK.*R VALUE\s+\(WORKING SET\)\s+:\s+(\d+\.?\d*)/) {$rvalue=$1;}
    if ($line=~/^ENDMDL/) {last;} # if file contains NMR models read only first one
    if ($line=~/^ATOM\s+\d+  CA [ A](\w{3}) (.)\s*(-?\d+.)/) {
#			    if ($line=~/^ATOM\s+\d+  CA [ A](\w{3}) $chain\s*(-?\d+.)/ ||  # we have to skip HETATM records because they are 
#				($line=~/^HETATM\s+\d+  CA [ A](\w{3}) $chain\s*(-?\d+.)/  # ignored by MODELLER and thus would cause an error
#				 && &Three2OneLetter($1) ne "X") ) { 
	$prevchain=$chain;
	$res=$1;
	$chain=$2;
	$nres[$l]=$3;
	if ($chain ne $prevchain && length($aapdb)>0 && $prevchain ne "nothing") {
	    if ($prevchain eq "") {$prevchain="_";}
	    printf("%s_%s  %s\n",$pdbfile,$prevchain,$aapdb);
	    $aapdb="";
	}
	$res=&Three2OneLetter($res);
	$aapdb.=$res;
    }
}
if (length($aapdb)>0) {
    if ($prevchain eq "") {$prevchain="_";}
    printf("%s_%s  %s\n",$pdbfile,$prevchain,$aapdb);
    
}
close (PDBFILE);
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
#    elsif ($res eq "SEC") {return "C";}
#    elsif ($res eq "ASX") {return "D";}
#    elsif ($res eq "GLX") {return "E";}
#    elsif ($res eq "KCX") {return "K";}
#    elsif ($res eq "MSE") {return "M";} # SELENOMETHIONINE 
#    elsif ($res eq "SEP") {return "S";} # PHOSPHOSERINE 
#    elsif ($res eq "TPO") {return "T";} # PHOSPHOTHREONINE 
    else                  {return "X";}
}
