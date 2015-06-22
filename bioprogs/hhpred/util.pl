#!/usr/bin/perl -w
use strict;


##################################################################################
sub RemovePath() {
    if ($_[0]=~/.*\/(.*)/) {$return=$1;} else { return $_[0];}
}

##################################################################################
sub RemoveExtension() {
    if ($_[0] =~/(.*)\..*/)    {return $1;} else {return $_[0];}
}

##################################################################################
sub PathRootExtension () {
    my $path;
    my $root;
    my $ext;
    if ($_[0]=~/^(.*)\/(.*)?$/)  {$path=$1; $root=$2;} else {$path=""; $root=$_[0];}
    if ($root =~/^(.*)\.(.*)?$/) {$root=$1; $ext=$2;}  else {$ext="";}
    return ($path,$root,$ext);
}

##################################################################################
# Minimum
##################################################################################
sub min {
    my $min = shift @_;
    foreach (@_) {
	if ($_<$min) {$min=$_} 
    }
    return $min;
}

##################################################################################
# Maximum
##################################################################################
sub max {
    my $max = shift @_;
    foreach (@_) {
	if ($_>$max) {$max=$_} 
    }
    return $max;
}

##################################################################################
# Calculate a hash value between 0 and N-1 by the division method
##################################################################################
sub HashVal() {
    # Transform key into a natural number k = sum ( key[i]*128^(L-i) ) and calculate i= k % N. 
    # Since calculating k would lead to an overflow, i is calculated iteratively 
    # and at each iteration the part divisible by N is subtracted
    my @key = split(//,$_[0]);
    my $N = $_[1];
    my $k=0;     # Start of iteration: k is zero
    my $c;
    foreach $c (@key) {$k = ($k*128+$c) % $N;}
    return $k;
}


##################################################################################
# Sort several arrays according to array0:  &Sort(\@array0,...,\@arrayN)
##################################################################################
sub Sort() 
{
    my $p_array0 = $_[0];
    my @index=();
    @index = (0..$#{$p_array0};
    @index = sort { ${$p_array0}[$a] <=> ${$p_array0}[$b] } @index;
    foreach my $p_array (@_) {
	my @dummy = @{$p_array};
	@{$p_array}=();
	foreach my $i (@index) {
	    push(@{$p_array}, $dummy[$i]);
	}
    }
}
# Test Sort():
# my @Zahlen =(9,4,6,8,2,1,7,3,5);
# my @Woerter=("neun","vier","sechs","acht","zwei","eins","sieben","drei","fuenf");
# for (my $i=0; $i<@Zahlen; $i++) {printf("%3i  %s\n",$Zahlen[$i],$Woerter[$i]);}
# print("\n");
# &Sort(\@Zahlen,\@Woerter);
# for (my $i=0; $i<@Zahlen; $i++) {printf("%3i  %s\n",$Zahlen[$i],$Woerter[$i]);}
# exit;

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

    # The HETATM selenomethionine is read by MODELLER like a normal MET in both its HETATM_IO=off and on mode!
    elsif ($res eq "MSE") {return "M";} # SELENOMETHIONINE 

    # These two abreviations are probably ignored by MODELLER (?)
    elsif ($res eq "ASX") {return "D";} # D or N
    elsif ($res eq "GLX") {return "E";} # E or Q

    # The following post-translationally modified residues are ignored by MODELLER in its default SET HETATM_IO=off mode
    elsif ($res eq "SEC") {return "C";} # SELENOCYSTEINE
    elsif ($res eq "SEP") {return "S";} # PHOSPHOSERINE 
    elsif ($res eq "TPO") {return "T";} # PHOSPHOTHREONINE 
    elsif ($res eq "TYS") {return "Y";} # SULFONATED TYROSINE 
    elsif ($res eq "KCX") {return "K";} # LYSINE NZ-CARBOXYLIC ACID
    else                  {return "X";}
}

##################################################################################
# Convert one-letter amino acid code into three-letter code
##################################################################################
sub One2ThreeLetter {
    my $res=uc($_[0]);
    if    ($res eq "G") {return "GLY";}
    elsif ($res eq "A") {return "ALA";}
    elsif ($res eq "V") {return "VAL";}
    elsif ($res eq "L") {return "LEU";}
    elsif ($res eq "I") {return "ILE";}
    elsif ($res eq "M") {return "MET";}
    elsif ($res eq "F") {return "PHE";}
    elsif ($res eq "Y") {return "TYR";}
    elsif ($res eq "W") {return "TRP";}
    elsif ($res eq "N") {return "ASN";}
    elsif ($res eq "D") {return "ASP";}
    elsif ($res eq "Q") {return "GLN";}
    elsif ($res eq "E") {return "GLU";}
    elsif ($res eq "C") {return "CYS";}
    elsif ($res eq "P") {return "PRO";}
    elsif ($res eq "S") {return "SER";}
    elsif ($res eq "T") {return "THR";}
    elsif ($res eq "K") {return "LYS";}
    elsif ($res eq "H") {return "HIS";}
    elsif ($res eq "R") {return "ARG";}
    elsif ($res eq "U") {return "SEC";}
    elsif ($res eq "B") {return "ASX";}
    elsif ($res eq "Z") {return "GLX";}
    else                {return "UNK";}
}
