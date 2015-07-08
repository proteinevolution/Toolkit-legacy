#! /usr/bin/perl -w
#
# Generate a model from an output alignment of hmmer. 
# The model output format can be either AL (alignment) or TS (pdb-format).

# Usage: hmmermakemodel.pl -i file.out (-ts file.pdb|-al file.al) [-m int] [-pdb pdbdir] 
BEGIN {
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/home/soeding/hh"); 
    push (@INC,"/cluster/usr/soeding/perl");  # for cluster
    push (@INC,"/cluster/bioprogs/hhpred");   # forchimaera  webserver: MyPaths.pm
    push (@INC,"/cluster/lib");               # for chimaera webserver: ConfigServer.pm
}
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;
use Align;
$|=1;  # force flush after each print

# Default parameters
our $d=3;  # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penatlty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
my $v=3;     # 3: DEBUG

my $program="hmmermakemodel.pl";
my $infile="";
my $outfile="";
my $format="AL";
my $pickhit=1;     # default: build model from best hit 
my $shift=0;       # ATTENTION: set to 0 as default!  
my $usage="
 Generate a 3D model from an output alignment of hmmer. 
 The model output format can be either AL (alignment) or TS (pdb-format).
 Usage: $program [-i] file.hhr [options]
 Options:
  -i  file.hmr      results file from hmmer with hit list and alignments
  -al file.al       write the AL-formatted model into file.al
  -ts file.ts       write the pdb-formatted model into file.ts
  -m  hit-index     pick hits with specified index as models (default=1)
  -s  shift         shift the residue indices up/down by an integer (default=$shift);           
  -v                verbose mode (default=$v)
\n"; 

# Processing command line options
if (@ARGV<1) {die $usage;}

my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.="$ARGV[$i] ";}

# Set verbose mode?

# Set options
if ($options=~s/-i\s+(\S+)//g)  {$infile=$1;}
if ($options=~s/-ts\s+(\S+)//g) {$outfile=$1; $format="TS";}
if ($options=~s/-al\s+(\S+)//g) {$outfile=$1; $format="AL";}
if ($options=~s/-s\s+(\S+)//g)  {$shift=$1;}

if ($options=~s/-m\s+(\d+)//g) {$pickhit=$1;}

if ($options=~s/-v\s+(\d+)//g)  {$v=$1;}
elsif ($options=~s/-v\s+//g)    {$v=1;}

# Read infile and outfile 
if (!$infile  && $options=~s/^\s*([^-]\S+)\s*//) {$infile=$1;} 
if (!$outfile && $options=~s/^\s*([^-]\S+)\s*//) {$outfile=$1;} 

# Warn if unknown options found or no infile/outfile
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; die("Error: unknown options '$options'\n");}
if ($infile eq "")  {die("$usage\nError in $program: input file missing: $!\n");}
if ($outfile eq "") {die("$usage\nError in $program: output file missing: $!\n");}

# Variable declarations
my $line;        # input line
my @line;        # input line is split into words in @line
my $query;       # name of query from hmmer output file (infile)
my $template="";   # name of template (hit) from hmmer output file (infile)
my $pdbfile;     # name of pdbfile to read
my $pdbcode;     # four-letter pdb code in lower case and _A if chain A (e.g. 1h7w_A)
my $aaq;         # query amino acids from hmmer output
my @aaq;         # query amino acids from hmmer output
my $aat;         # template amino acids from hmmer output
my @aat;         # template amino acids from hmmer output
my $aapdb;       # template amino acids from pdb file
my @aapdb;       # template amino acids from pdb file
my @nres;        # $nres[$l] = pdb residue index for residue $aapdb[$l]
my @coord;       # $coord[$l] = coordinates of CA atom of residue $aapdb[$l]
my $i=0;         # counts query  residues from hmmer output
my $j=0;         # counts template residues from hmmer output
my $l=1;         # counts template residues from pdb file (first=1, like for i[col2] and j[col2]
my $col1=0;      # counts columns from hmmer alignment
my $col2=0;      # counts columns from alignment (by function &AlignNW) of $aat versus $aapdb 
my @i1;          # $i1[$col1] = index of query  residue in column $col1 of hmmer-alignment
my @j1;          # $j1[$col1] = index of template residue in column $col1 of hmmer-alignment
my @j2;          # $j2[$col2] = index of hmmer template seq in $col2 of alignment against pdb template sequence
my @l2;          # $l2[$col2] = index of pdb template seq in $col2 of alignment against hmmer template sequence
my @l1;          # $l1[$col1] = $l2[$col2]
my $res;         # residue name
my $chain;       # pdb chain from template name
my $Eval;        # E-value of hit
my $length;      # query length
my $nali;        # number of residue-residue columns in blast alignment

my $hit;         # index of hit in hit list
my $buffer;      # Model to be printed

# Read query sequence
#open (INFILE, "<$queryfile") || die "Error in $program: Couldn't open $infile: $!\n";
#while($line=<INFILE>) {if ($line=~/^>(\S+)/) {$query=$1; last;} }
#$aaq="";
#while($line=<INFILE>) {    
#    if($line=~/^>(\S+)/) {
#	if ($aaq ne "") {last;}
#    } else {
#	chomp($line);
#	$aaq.=$line;
#    }
#}
#close(INFILE);

# Find hit list
open (INFILE, "<$infile") || die "Error in $program: Couldn't open $infile: $!\n";
while ($line=<INFILE>) {if ($line=~/^Sequence Description/) {last;} }
$line=<INFILE>;
$line=<INFILE>;
$line=~/^(\S+)/;
$query=$1; 

# Record name of pickhit'th hit
$hit=1; 
while ($hit<$pickhit) {
    $line=<INFILE>; 
    if ($line=~/^\s*$/) {last;}
    $hit++; 
} 
if ($hit==0) {die("Error: no hit found\n");}
if ($hit!=$pickhit) {die("Error: only $hit alignments found! No model constructed. \n");}
$line=~/(\S+)/;
$template=$1;
#print("template: $template\n");

# Advance to alignments
while ($line=<INFILE>) {if ($line=~/^Alignments of top-scoring domains:/) {last;} }

# Find pickhit'th hit in hmmer file
while ($line=<INFILE>) {if ($line=~/^$template: domain/) {last;} }


# Write model file header

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8

# Print header
my $date = scalar(localtime);
$buffer="PFRMAT $format\nTARGET $query\n";
$buffer.="REMARK $date\n";
$buffer.="AUTHOR J. Soeding\n";

# Add method description
$buffer.="METHOD HMMER\n";
$buffer.="REMARK \n";
$buffer.="MODEL  1\n";
$buffer.="PARENT $template\n";


# Scan through query-vs-template-alignments from infile and create model
&ReadAlignment();

# Write alignment into $buffer
&WriteAlignment();

close (INFILE);



# Print $buffer into outfile

open (OUTFILE, ">$outfile") || die "Error in $program: Couldn't open $outfile: $!\n";
my @printarr=split(/\n/,$buffer);
my $printstr;
if ($format eq "TS") {
    foreach $printstr (@printarr) {
	printf(OUTFILE "%-80.80s\n",$printstr);
    }
} else {
    foreach $printstr (@printarr) {
	printf(OUTFILE "%s\n",$printstr);
    }
}
close (OUTFILE);

printf("Written model to $outfile with %i coordinate lines from $nali match columns\n",scalar(@l2));
exit;


##################################################################################
# Read Alignment from infile
##################################################################################
sub ReadAlignment() {

    $aaq="";
    $aat="";
    $i=0;     # no query line read so far
    $j=0;     # no template line read so far
    
    # Extract pdbcode and construct name of pdbfile
    $template=~/[a-z](\S{4})(.)./;
    $pdbcode=$1;
    $pdbcode=lc($pdbcode);
    $pdbfile="$pdbdir/pdb".$pdbcode.".ent";
    $chain=uc($2);
    if ($chain eq "_") {$chain="[A ]";} else {$pdbcode.="_$chain";}
 
    # Search for all lines with 'Query:' and 'Sbjct:'
    $i=1;
    while ($line=<INFILE>) {
	if ($line=~/^\s*CS\s/) {$line=<INFILE>}
	if ($line=~/^\s*RF\s([\w\.\- ]*[\w\.\-])/) {
	    $aaq.=$1;
	    $line=<INFILE>;
	    $line=<INFILE>;
	    $line=<INFILE>;
	} else {last;}
	if ($line=~/^\s*$template\s+([-\d]+)\s(\s*\S+)/) {
	    if (!$j) {$j=$1;} # if $=j==0 then this is the first template line read -> set $j to >0
	    if (!$j) {$j=1;}  # if still $j==0 then set $j to 1
	    $aat.=$2;
	    $line=<INFILE>;
	}
	$aaq.= "-" x (length($aat)-length($aaq));
    } # end while ($line=<INFILE>)  

    # Throw at arrow at beginning and end
    $aaq=~tr/a-z /A-Z-/;
    $aat=~tr/a-z /A-Z-/;

    if (length($aaq)!=length($aat)) {
	printf ("Error in $program: query and template sequences have different length in $infile: $!\n");
	printf ("Q $query: $aaq\n");
	printf ("T:$template: $aat\n");
	exit;
    }
    
    #Delete columns with gaps in both sequences
    @aaq=split(//,$aaq);
    @aat=split(//,$aat);
    my $col=0;
    $nali=0;
    for ($col1=0; $col1<@aaq; $col1++) {
	if ($aaq[$col1]=~tr/a-zA-Z/a-zA-Z/ || $aat[$col1]=~tr/a-zA-Z/a-zA-Z/) {
	    $aaq[$col]=$aaq[$col1];
	    $aat[$col]=$aat[$col1];
	    $col++;
	    if ($aaq[$col1]=~tr/a-zA-Z/a-zA-Z/ && $aat[$col1]=~tr/a-zA-Z/a-zA-Z/) {$nali++;}
	}
    }
    splice(@aaq,$col); # delete end of @aaq;
    splice(@aat,$col);
    $aaq=join("",@aaq);
    $aat=join("",@aat);
    
    
    # Count query and template residues into @i1 and @j1 
    for ($col1=0; $col1<@aaq; $col1++) {
	if ($aaq[$col1]=~tr/a-zA-Z/a-zA-Z/) {
	    $i1[$col1]=$i++;  #found query residue in $col1
	} else {
	    $i1[$col1]=0;     #found gap in $col1
	}
	if ($aat[$col1]=~tr/a-zA-Z/a-zA-Z/) {
	    $j1[$col1]=$j++;  #found template residue in $col1
	} else {
	    $j1[$col1]=0;     #found gap in $col1
	}
    }
    

    # DEBUG
    if ($v>=3) {
	printf ("col    Q  i1     T  j1\n");
	for ($col1=0; $col1<@aaq; $col1++) {
	    printf ("%3i    %s %3i     %s %3i\n",$col1,$aaq[$col1],$i1[$col1],$aat[$col1],$j1[$col1]);
	}
	printf ("\n");
    }
    return;
}


##################################################################################
# Write Alignment to $buffer
##################################################################################
sub WriteAlignment() {

    # Read protein chain from pdb file
# ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
# ATOM      1  N   SER A  27      38.637  79.034  59.693  1.00 79.70           N
# ATOM   2083  CD1 LEU A  22S     15.343 -12.020  43.761  1.00  5.00           C
    
    if (!open (PDBFILE, "<$pdbfile")) {
	warn ("Error in $program: Couldn't open $pdbfile: $!\n");
	return;
    }
    $aapdb="";
    while ($line=<PDBFILE>) {
	if ($line=~/^ENDMDL/) {last;} # if file contains NMR models read only first one
	if ($line=~/^ATOM\s+\d+  CA .(\w{3}) $chain\s*(-?\d+.)   (\s*\S+\s+\S+\s+\S+)/ ) {
	    $res=$1;
	    $nres[$l]=$2;
	    $coord[$l]=$3."  1.00";
	    $res=&Three2OneLetter($res);
	    $aapdb[$l]=$res;
	    $aapdb.=$res;
	    $l++;
	}
    }
    close (PDBFILE);
    
    # Align template in hh-alignment ($aat) with template sequence in pdb ($aapdb)
    
    my $xseq=$aat;
    my $yseq=$aapdb;
    my ($jmin,$jmax,$lmin,$lmax);
    my $Sstr;
    my $score;  
    #the aligned characters are returend in $j2[$col2] and $l2[$col2]
    $score=&AlignNW(\$xseq,\$yseq,\@j2,\@l2,\$jmin,\$jmax,\$lmin,\$lmax,\$Sstr);  
    
    # DEBUG
    if ($v>=3) {
	printf("Template (hh)  $xseq\n");
	printf("Identities   $Sstr\n");
	printf("Template (pdb) $yseq\n");
	printf("\n");
	if ($v>=4) {
	    for ($col2=0; $col2<@l2 && $col2<200; $col2++) {
		printf("%3i  %3i  %3i\n",$col2,$j2[$col2],$l2[$col2]);
	    }
	}
    }	
    
    # DEBUG
    
    # Construct alignment of $aaq <-> $aapdb via alignments $aaq <-> $aat and $aat <-> $aapdb:  
    # Find $l1[$col1] = line of pdb file corresponding to residue $aat[$col1] and $aaq[$col1]
    $col2=0;
    for ($col1=0; $col1<@aaq; $col1++) {
	if ($j1[$col1]==0 || $i1[$col1]==0) {next;} # skip gaps in query and gaps in template
	while ($j2[$col2]<$col1+1) {$col2++;} # in $j2[col2] first index is 1, in $col1 first column is 0
	$l1[$col1] = $l2[$col2];
	if ($v>=4) {printf("l1[%i]=%i  l2[%i]=%i\n",$col1,$l1[$col1],$col2,$l2[$col2]);}
    }
    
    
    if ($pdbcode ne "NONE") {
	if ($format eq "TS") {
	    for ($col1=0; $col1<@aat; $col1++) {
		if ($i1[$col1]==0) {next;} # skip gaps in query
		if ($j1[$col1]==0) {next;} # skip gaps in template sequence
		if ($l1[$col1]==0) {next;} # skip if corresponding residue was skipped in pdb file
		
		$buffer.=sprintf("ATOM  %5i  CA  %3s  %4i    %-50.50s\n",$i1[$col1],&One2ThreeLetter($aaq[$col1]),$i1[$col1]+$shift,$coord[$l1[$col1]]);
		if ($v>=4) {
		    printf("ATOM  %5i  CA  %3s  %4i    %-50.50s\n",$i1[$col1],&One2ThreeLetter($aaq[$col1]),$i1[$col1]+$shift,$coord[$l1[$col1]]);
		}
	    }
	} else {
	    for ($col1=0; $col1<@aat; $col1++) {
		if ($i1[$col1]==0) {next;} # skip gaps in query
		if ($j1[$col1]==0) {next;} # skip gaps in template sequence
		if ($l1[$col1]==0) {next;} # skip if corresponding residue was skipped in pdb file
		$buffer.=sprintf("%1s %3i    %1s %s\n",$aaq[$col1],$i1[$col1],$aat[$col1],$nres[$l1[$col1]]);
		if ($v>=4) {printf("%1s %3i    %1s %s\n",$aaq[$col1],$i1[$col1],$aat[$col1],$nres[$l1[$col1]]);}
	    }
	}
    }
    $buffer.=sprintf("TER\n");
    return;
}


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
