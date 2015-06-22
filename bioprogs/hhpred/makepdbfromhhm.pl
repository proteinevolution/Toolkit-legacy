#! /usr/bin/perl -w
# Build a *.pdb file for each globbed hhm file 
# Usage: makepdbfiles.pl fileglob  

BEGIN {
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/home/soeding/hh"); 
    push (@INC,"/cluster/soeding/perl"); 
    push (@INC,"/cluster/soeding/hh"); 
}
use strict;
use Align;
$|=1; # autoflush on

# Default parameters for Align.pm
our $d=3;    # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penatlty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
our $v=2;    # verbose mode
our $matrix="identity";

# Default values:
my $hostname=`hostname`;
my $pdbdir="/raid/db/pdb";    # path to pdb (for MakePdbFile() )
my $maxsub="/home/soeding/programs/maxsub/maxsub";    # maxsub executable
my $tmpfile="/home/soeding/hh/maxsub.out";            # write maxsub output to this file
my $hh="/home/soeding/hh";    # path to hh directory (hhmakemodel.pl,...)

if ($hostname=~/compute|seth|enkil|mpi-/) {
    # Directory paths for cluster
    $pdbdir="/cluster/database/pdb";
    $hh="/cluster/soeding/hh";
    $maxsub="/cluster/soeding/programs/maxsub/maxsub";
    $tmpfile="/cluster/soeding/submit/maxsub.out"; 
}

if (scalar(@ARGV)<1) {
    print("
 Build a *.pdb file for each globbed hhm file 
 Usage: makepdbfiles.pl fileglob  
 Example: makepdbfiles.pl *.hhm
\n"); 
    exit;
}

my $glob = $ARGV[0];
my @files = glob("$glob"); #read all such files into @files 
my $base;          # basename of *.scores file (name without extension)
my $root;          # rootname of *.scores file (base name without path)
my $line;

print (scalar(@files)." files read in. Starting selection loop ...\n");

for (my $n=0; $n<@files; $n++) {  
 
    if ($files[$n] =~/^(.*)\..*?$/) {$base=$1;} else {$base=$files[$n];} # get basename for file
    if ($base =~/.*\/(.*?)$/) {$root=$1;} else {$root=$base;} # rootname = basename without path
    print("\n>>> Building pdb file $base.pdb ($n) <<<\n");

    # Make pdb file to compare model to
    &MakePdbFile($base,$files[$n]);
}
exit(0);


##################################################################################
# Make a pdb file $base.pdb with correct resdiue numbers from query sequence in $base.hhm 
##################################################################################
sub MakePdbFile() 
{
    my $base=$_[0];
    my $hhmfile=$_[1];
    my $aaq;        # query amino acids
    my $scopid;     # scopid of query sequence in hmmfile
    my $chain;      # chain id of query sequence for hmmfile 
    my $pdbfile;    # pdbfile corresponding to query sequence
    my $i;          # index for column in HMM
    my $line;       # currently read input line
    
    # Open hhm file and read name and chain id of query
    if ($v>=2) {printf("Reading %s ... \n",$hhmfile);}
    if (!open (HHMFILE,"<$hhmfile")) {
	$hhmfile="$root".".hhm";
	if (!open (HHMFILE,"<$hhmfile")) {
	    warn("Error: can't open $hhmfile: $!\n"); 
	    return 1;
	}
    }
    while ($line=<HHMFILE>) {if ($line=~/^NAME/) {last;} }
    if ($line!~/NAME\s+(\S+)/) {warn ("Error: can't fine NAME line in $hhmfile: $!\n"); return 1;}
    $scopid=$1;
    $scopid=~/^[a-z](\w{4})(\S)./;
    $pdbfile="$pdbdir/pdb$1.ent";
    if ($2 eq "_") {$chain="[A ]";} # sequence has no chain id in name, e.g. d1hz4__
    elsif ($2 eq ".") {          # sequence is composed of more than one pdb chain, e.g. d1hz4.1
	$line=~/NAME\s+\S+\s+\S+\s+\((\S+)\)/;
	$chain=$1;               # e.g. (A:,B:). (B:,A:) will cause an incomplete alignment!!
	$chain=~tr/A-Z//cd;      # remove everything but the chain identifiers 
	$chain="[".$chain."]";   # extract all lines from pdb file belonging to one of these chains
    } else {$chain=uc($2);}      # sequence has just one chain, e.g. d1hz4a_
    
    # Read query sequence $aaq
    $aaq="";
    while ($line=<HHMFILE>) {if ($line=~/^>$scopid/) {last;} }
    if ($line!~/^>$scopid/) {warn("Error: can't fine query sequence $scopid in $hhmfile: $!\n"); return 1;}
    while ($line=<HHMFILE>) {
	if ($line=~/^>/) {last;} 
	if ($line=~/^\#/) {last;} 
	else {chomp($line); $aaq.=$line;}
    }
    $aaq=~tr/x.//d;  # $aaq=~tr/a-z.//d;  # remove all inserts
    close (HHMFILE);
    
    my $l;          # index for lines in pdb file 
    my @pdbline;    # $pdbline[$l][$natom] = line in pdb file for l'th residue in $aapdb and atom N, CB, or O 
    my $natom;      # runs from 0 up to 2 (N, CB, O)
    my $res;        # residue in pdb line
    my $atom;       # atom code in pdb file (N, CA, CB, O, ...)
    my $aapdb="";   # template amino acids from pdb file
    my $col;        # column of alignment query (from hhm file) versus pdb-residues
    my $nres;       # residue number in pdb file

    # Read pdb file corresponding to 
    if (!open (PDBFILE,"<$pdbfile")) {warn("Error: can't open $pdbfile: $!\n"); return 2;}
    $l=0;
    $nres=-10;
    while ($line=<PDBFILE>) {
# ATOM      1  N   GLY A   1     -19.559   8.872   4.925  1.00 16.44           N
# ATOM      2  CA  GLY A   1     -19.004   8.179   6.112  1.00 14.30           C
	if ($line=~/^ENDMDL/) {last;} # if file contains NMR models read only first
	if ($line=~/^ATOM\s+\d+  (..) .(\w{3}) $chain\s*(-?\d+).*/ ) {
	    $atom=$1;
	    $res=$2;
	    # New residue?
	    if ($3!=$nres) {  # $3<$nres if new chain (A:,B:)
 		$nres=$3;
		$l++;
		$res=&Three2OneLetter($res);
		$aapdb.=$res;
		$natom=0;
	    }
	    $pdbline[$l][$natom++]=$line;
	}
    }
    close (PDBFILE);
    
    # Align scop query sequence ($aaq) with query sequence in pdb ($aapdb)	
    my $xseq=$aaq;
    my $yseq=$aapdb;
    my ($imin,$imax,$lmin,$lmax);
    my $Sstr;
    my $score;  
    my (@i,@l);    # The aligned characters are returend in $j[$col] and $l[$col]
    $score=&AlignNW(\$xseq,\$yseq,\@i,\@l,\$imin,\$imax,\$lmin,\$lmax,\$Sstr);  
    
    # DEBUG
    if ($v>=3) {
    }	
    
    # Print pdb file where residue index i corresponds exactly to the i'th scop sequence residue
    if (!open (SHORTFILE,">$base.pdb")) {warn("Error: can't open $base.pdb: $!\n"); return 3;}
    my $match=0; 
    my $len=length($aaq); 
    for ($col=0; $col<@i; $col++) {
	if ($i[$col] && $l[$col]) {
	    $match++;
	    for ($natom=0; $natom<scalar(@{$pdbline[$l[$col]]}); $natom++) {
		$pdbline[$l[$col]][$natom]=~/(^ATOM\s+\d+  .. .\w{3} $chain).{4}(.*)/;
		if ($v>=3) {printf("%s%4i%s\n",$1,$i[$col],$2);}
		printf(SHORTFILE "%s%4i%s\n",$1,$i[$col],$2);
	    }
	}
    }
    close (SHORTFILE);
    
    if ($v>=3 || ($v>=1 && $len-$match>5)) {
	if ($v>=1 && $len-$match>1) {
	    printf("\nWARNING: could not find coordinates for %i query residues:\n",$len-$match);
	} else { printf("\n"); }
	printf("hhm: $xseq\n");
	printf("id:  $Sstr\n");
	printf("pdb: $yseq\n");
	printf("\n");
	if ($v>=4) {
	    for ($col=0; $col<@l && $col<200; $col++) {
		printf("%3i  %3i  %3i\n",$col,$i[$col],$l[$col]);
	    }
	}
    }

    return 0;
}
# End MakePdbFile()


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
    elsif ($res eq "SEC") {return "U";}
    elsif ($res eq "ASX") {return "B";}
    elsif ($res eq "GLX") {return "Z";}
    elsif ($res eq "KCX") {return "K";}
    elsif ($res eq "MSE") {return "M";} # SELENOMETHIONINE 
    elsif ($res eq "SEP") {return "S";} # PHOSPHOSERINE 
    else                  {return "X";}
}

sub System {
    if ($v>=2) {print($_[0]."\n");} 
    return system($_[0]); 
}

