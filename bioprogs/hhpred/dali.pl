#! /usr/bin/perl -w
my $rootdir;
BEGIN {
    if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} else {$rootdir="/cluster";}
};
use lib "$rootdir/bioprogs/hhpred";
use lib "/cluster/lib";

use strict;
use MyPaths;
use Align;

# Default parameters
my $v=2;
our $d=3;    # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penalty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
my $usage="
Generate FASTA sequence file with domain sequences from DALI database and pdb files
Write residues that are missing in ATOM records but appear in SEQRES records in lower case

Steps to generate DALI database:
* Download files pdb90.fasta, domain_definitions.txt, and FoldIndex.html from
  http://www.bioinfo.biocenter.helsinki.fi:8080/dali/index.html
* Generate file dali.fas with domain sequences including descriptions
  > dali.pl pdb90.fasta domain_definitions.txt FoldIndex.html dali90.fas
* Filter dali.fas sequences
  > dalifilter.pl dali90.fas dali.fas
* Build alignments (*.a3m) 
  > builddb.pl dali.fas
* Make HMMs from alignments (*.hhm)
  > hhmake.pl '*.a3m' > hhmake.log 2>&1 &
* copy *.a3m files and *.hhm files to webservers
  chimaera> cd /cluster/databases/hhpred/new_dbs/
  chimaera> mkdir dali_Oct2004
  > scp *.a3m soeding\@chimaera:/cluster/databases/hhpred/new_dbs/dali_Oct2004
  > scp *.hhm soeding\@chimaera:/cluster/databases/hhpred/new_dbs/dali_Oct2004
  soeding\@chimaera> cat *.hhm > dali50.hhm

Usage: dali.pl pdb90.fasta domain_definitions.txt FoldIndex.html dali90.fas
\n";

if (@ARGV<4) {die("$usage");}

my $infile=$ARGV[0];        
my $domainfile=$ARGV[1];
my $foldindexfile=$ARGV[2];
my $outfile=$ARGV[3];
my $line;
my $n;           # number of domains (read in from domain_definitions.txt)
my $k;           # index for domain in @domainids, @foldids, @ranges
my %index;       # $index{$dali_id} gives the index of domain $domainid in @domainids, @foldids, @ranges
my @domainids;   # e.g. 1cunA_2
my @pdbids;      # e.g. 1cun
my @foldids;     # e.g. 1.1.1.2.1.1
my @ranges;      # $ranges[$k] = 1-137,256-403
my @descr;       # $descr[$k] = description field of pdb structure containing domain with index $k
my @chainids;    # $chainids[$k] = "A:" for chain A and "" if no chain specified
my %residues;    # $residues{$pdbid} = residues of 4-letter pdb-id read in from pdb90.fasta

# Read FoldIndex.html
print("Reading $foldindexfile ... ");
open (FOLDINDEXFILE,"<$foldindexfile") || die ("ERROR: cannot open $foldindexfile: $!\n");
# 1.1.1.1.1.1     1cunA_2 ...
# 1.1.1.2.1.1     ___1lvfA_1 ...
my $domainid;
$k=0;
while($line=<FOLDINDEXFILE>) {
    if ($line=~/(\d+\.\d+\.\d+\.\d+\.\d+\.\d+)\s+_*(\S+)(_\d+).*>\s+(.*)/) {
	$index{$2.$3}=$k;
	$foldids[$k]=$1;
	$pdbids[$k]=$2;
	$domainids[$k]=$2.$3;
	$descr[$k]=$4;
	$pdbids[$k]=~/\S{4}(\S*)/;
	if ($1 eq "") {$chainids[$k]="";} else {$chainids[$k]=$1.":";}
	$k++;
    }
}
$n=$k;
close(FOLDINDEXFILE);
print(" found $n domains\n");

# Read domain_definitions.txt
print("Reading $domainfile ... ");
open (DOMAINFILE,"<$domainfile") || die ("ERROR: cannot open $domainfile: $!\n");
# 1cunA/1-106	1cunA_1	1	ALPHA SPECTRIN
my $j=0;
while($line=<DOMAINFILE>) {
    if ($line=~/(\S+)\/\S+\s+(\S+)_/ && $1 eq $2) { # does this domain belong to pdb90 chain?
	$line=~/(\S+)\/(\d+)-(\d+)\s+(\S+)\s+\d*\s*(.*)/;
	chomp($line);
#	print("line='$line' pdbid=$1  first=$2  last=$3  domainid=$4\n");
	if (!defined $index{$4} ) {
	    warn("WARNING: index $4 in $domainfile (line $.) was never defined in $foldindexfile\n");
	    $k=$n++;
	    $foldids[$k]="0.0.0.0.0.0";
	    $domainids[$k]=$4;
	    $index{$4}=$k;
	} else {
	    $k=$index{$4};
	}
	if (defined $ranges[$k]) {
	    # Insert new range interval at right position into intervals already defined
	    my $left=$2;
	    my $right=$3;
	    my @range=split(/,/,$ranges[$k]);
	    my $pos;
	    for ($pos=0; $pos<@range;) {
		$range[$pos]=~/(\d+)-/;
		if ($left<$1) {last;}    
		$pos++;
	    }
	    splice(@range,$pos,0,$left."-".$right);
	    $ranges[$k]=join(",",@range);
	} else {
	    $pdbids[$k]=$1;
	    $descr[$k]=$5;
	    $ranges[$k]="$2-$3";
	    $pdbids[$k]=~/\S{4}(\S*)/;
	    if ($1 eq "") {$chainids[$k]="";} else {$chainids[$k]=$1.":";}
	    $j++;
	}
    }
}
close(DOMAINFILE);
print(" found $j domains from pdb90 set\n");

# Read pdb90.fasta sequence file
print("Reading $infile ... ");
open (INFILE,"<$infile") || die ("ERROR: cannot open $infile: $!\n");
my $residues="";
my $pdbid="";
$j=0;
while ($line = <INFILE>) #scan through PsiBlast-output line by line
{
    if ($line=~/^>(.*)/) # nameline detected
    {
	if ($residues) {
	    $residues=~tr/A-Za-z.-/A-Za-z.-/d;
	    $residues{$pdbid}=$residues;
	    $j++;
	}
	$pdbid=$1;
	$residues="";
    }
    else
    {
	chomp($line);
	$residues.=$line;
    }
}
if ($residues) {
    $residues=~tr/A-Za-z.-/A-Za-z.-/d;
    $residues{$pdbid}=$residues;
    $j++;
}
close(INFILE);
print(" found $j chains\n");


# Write domain sequences to $outfile
print("Writing $outfile with $n domains...\n");
my $nameline;
my $atomres;
my $seqres;
my $nres;
my $chainid;     # Either A for chain A or "" if no chain id 

open (OUTFILE,">$outfile") || die ("ERROR: cannot open $outfile for writing: $!\n");
for ($k=0; $k<$n; $k++) {

#    if ($domainids[$k] ne "1c9wA_2") {next;} # DEBUG

    if ($v>=2) {printf("%4i %s\n",$k+1,$domainids[$k]);}

    $atomres=$residues{$pdbids[$k]};
    if (($atomres=~tr/abcdefghiklmnpqstuvwyzABCDEFGHIKLMNPQRSTUVWYZ/abcdefghiklmnpqstuvwyzABCDEFGHIKLMNPQRSTUVWYZ/)<20) {
	print("WARNING: domain $domainids[$k] has less than 20 residues; skipping domain\n");
	print("$atomres\n");
	next;
    }    

    # Read SEQRES residues from pdb file
    if ($pdbids[$k]!~/(\S{4})(\S*)/) {die("Error: wrong pdb id $pdbids[$k]\n")}
    $pdbid=lc($1);
    $chainid=uc($2);
    my $pdbfile="$pdbdir/pdb".$pdbid.".ent";
#    print("file=$pdbfile  pdbid=$pdbid chain=$chainid\n");
    open (PDBFILE, "<$pdbfile") || die ("Error: couldn't open $pdbfile: $!\n");
    $seqres="";
    my $match=0;
    my $resolution=-1.00;
    my $rvalue=-1.00;
    #SEQRES   1 A  366  SER ARG MET PRO SER PRO PRO MET PRO VAL PRO PRO ALA          
    #SEQRES   2 A  366  ALA LEU PHE ASN ARG LEU LEU ASP ASP LEU GLY PHE SER          
    while ($line=<PDBFILE>) {
	if ($line=~/^REMARK.*RESOLUTION\.\s+(\d+\.?\d*)/) {$resolution=$1;}
	if ($line=~/^REMARK.*R VALUE\s+\(WORKING SET\)\s+:\s+(\d+\.?\d*)/) {$rvalue=$1;}
	if ($line=~/^SEQRES\s+\d+\s+$chainid\s+\d+(.*?)\s*$/ ) {
	    $seqres.=$1;
	    $match=1;
	} elsif ($match) {last;}
    }
    close (PDBFILE);
    
    # Transform 3-letter code into 1-letter code
    my @seqres=split(/\s+/,$seqres);
    $seqres="";
    foreach my $aa (@seqres) {$seqres.=&Three2OneLetter($aa);}
    
    # Align $atomres with $seqres
    my $xseq=$atomres;
    my $yseq=$seqres;
    my @i;
    my @j;
    my ($imin,$imax,$jmin,$jmax);
    my $Sstr;
    my $score;  
    # The aligned characters are returend in $j2[$col2] and $l2[$col2]
    $score=&AlignNW(\$xseq,\$yseq,\@i,\@j,\$imin,\$imax,\$jmin,\$jmax,\$Sstr);  
    
    # DEBUG
    if ($v>=3) {
	printf("ATOM   $xseq\n");
	printf("Ident  $Sstr\n");
	printf("SEQRES $yseq\n");
	printf("\n");
	if ($v>=4) {
	    for (my $l=0; $l<@j && $l<1000; $l++) {
		printf("%3i  %3i %s %3i %s\n",$l,$i[$l],substr($atomres,$i[$l]-1,1),$j[$l],substr($seqres,$j[$l]-1,1));
	    }
	}
    }	
    
    # Calculate which residue index in $seqres corresponds to which index in $atomres?
    my @jl;   # $jl[$i] gives residue number of $seqres aligned to residue $i-1 of $atomres, plus one
    my @jr;   # $jr[$i] gives residue number of $seqres aligned to residue $i+1 of $atomres, minus one
    my $i=0;
    for (my $l=0; $l<@j; $l++) {
	if ($i[$l]) {$i=$i[$l];}
	if ($j[$l]) {$j=$j[$l];}
	$jr[$i]=$j;
    }
    $i=length($atomres);
    for (my $l=$#j; $l>=0; $l--) {
	if ($i[$l]) {$i=$i[$l];}
	if ($j[$l]) {$j=$j[$l];}
	$jl[$i]=$j;
    }

    # Set nameline and residues
    if (defined $ranges[$k]) {
	# Add residues contained in residue range with one or more intervals, e.g. 1-137,256-403
	$residues="";
	my $range="";
	while($ranges[$k]=~s/,?(\d+)-(\d+)//) {
	    my $j1=$jl[$1];
	    my $j2=$jr[$2];
	    if (!defined $j2) {$j2=$jmax;}
	    if (!defined $j1) {$j1=$jmin;}
	    $range.=$chainids[$k]."$j1"."-$j2,";
	    if ($v>=4) {print("i1=$1  i2=$2, j1=$j1  j2=$j2\n");}
	    $residues.=lc(sprintf("%s",substr($seqres,$j1-1,$j2-$j1+1)))."X";
	}
	$residues=~s/X$//;
	$range=~s/,$//;
	$nameline=sprintf(">%s  %s (%s) %s (%sA, R=%s)\n",$domainids[$k],$foldids[$k],$range,$descr[$k],$resolution,$rvalue);
    } else {
	if ($chainid eq "") {$chainid="-";} else {$chainid.=":";}
	$nameline=sprintf(">%s  %s (%s) %s (%sA, R=%s)\n",$domainids[$k],$foldids[$k],$chainid,$descr[$k],$resolution,$rvalue);
	$residues=lc(sprintf("%s",$seqres));
    }

    $nres=($residues=~tr/a-zA-Z/a-zA-Z/);
    if ($nres<=25) {$residues .= 'X' x (26-$nres);} # if <=25 residues add Xs to make lenght =26 (for PSI-BLAST)
    $residues=~s/(\S{1,100})/$1\n/g; # insert newlines after each 100 characters
    print(OUTFILE $nameline);
    print(OUTFILE $residues);
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
