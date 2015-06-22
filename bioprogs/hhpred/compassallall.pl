#! /usr/bin/perl -w
# Use compass to search with all globbed sequences against data base file and record score distribution 
# Usage: compassallall.pl compass-dbfile  

BEGIN { 
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/cluster/soeding/perl");     # for cluster
    push (@INC,"/cluster/bioprogs/hhpred");  # forchimaera  webserver: MyPaths.pm
    push (@INC,"/cluster/lib");             # for chimaera webserver: ConfigServer.pm
}
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;
use Align;
$|=1; # autoflush on

# Default parameters for Align.pm
our $d=3;    # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penatlty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
our $v=1;    # verbose mode
our $matrix="identity";

# directory paths
my $hmmer ="$bioprogs_dir/hmmer/hmmer-2.2g/binaries";    
my $maxsub="$bioprogs_dir/maxsub/maxsub";               
my $compass="$bioprogs_dir/compass/compass_vs_db";
my $scopfile="/cluster/soeding/nr/scop20.1.63";

# Constants
my $RELMIN =2;                # minimum relationship at fold level to calculate MAXSUB score 
my $EVALMAX=10.0;             # maximum Evalue to calculate MAXSUB score for
my $NDB=3691;                 # database size
my $update=0;                 # default: no updating

# Variables
my $infile;   # file being read in
my $basename; # basename = name without extension
my $line;
my $nhit;     # number of alignments from compass output file read in
my $query;    # name of query sequence
my $template;   # name of template sequence
my $qfam;     # family of query
my ($qsf,$qcf,$qcl); # query superfamily, fold, and class
my $tfam;     # family of template
my $qlen;     # length of query
my $tlen;     # length of template
my $aaq;      # query residues from pairwise alignment
my $aat;      # template residues from pairwise alignment
my $qfirst;   # index of first residue of query
my $tfirst;   # index of first residue of template
my $ncol=0;   # count number of Match-Match columns
my $naligned; # number of aligned atoms with RMS < 3.5A

my %fam=();   # $fam{$scopid} : SCOP family code for $scopid
my $rel;      # relationship of query and template
my $evalue;   # evalue of template with query
my $MSscore;  # MAXSUB score of query with template
my $hit;      # index of hit in compass output file
my $options="";

if (scalar(@ARGV)<2) {
    print("
Use compass to search with all globbed sequences against data base file and record score distribution
Generates pdb-file in same directory if not yet there
Usage:   compassallall.pl fileglob database [-u]
Options:  
 -u      update: skip if file.scores exists already; use existing COMPASS result files (*.compr) and pdb files (*.pdb)

Example: compassallall.pl '*.aln' scop20.3.compass
\n"); 
    exit;
}


# Process command line input
my @files = glob("$ARGV[0]"); #read all such files into @files 
my $db = $ARGV[1];
if (scalar(@ARGV)>2) {$options=join(" ",@ARGV[2..$#ARGV]);}

#Verbose mode?
if ($options=~s/-v\s*(\d)//g) {$v=$1;}
if ($options=~s/-v//g) {$v=2;}
if ($options=~s/-u//g) {$update=1;}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}


# Read scop20 fasta file to get scopid -> family relationships
open(INFILE,"<$scopfile") or die("Error: cannot open $scopfile: $!\n");
while($line=<INFILE>) {
    if ($line=~/^>(\S+)\s+(\S+)/) {
	$fam{$1}=$2;
#	print("id=$1 fam=$2\n");
    }
}
close(INFILE);

print (scalar(@files)." files read in. Starting selection loop ...\n");

# For each query sequence do compass search and generate *.scores file from compass output
my $nfiles=0;
foreach $infile (@files) {   

    $nfiles++;
    if ($infile =~/(.*)\..*?$/)   {$basename=$1;} else {$basename=$infile;} # basename = name without extension

    if ($update && -e "$basename.scores") {
	print("Skipping $infile ...\n"); 
	next;
    }
    print(">>> $nfiles: $infile $basename<<<\n");

    # Do COMPASS search against SCOP20 (or other database)
    if (!$update || !-e "$basename.compr") {
	&System("$compass -g 1.0 -db $db -i $infile > $basename.compr");
    } else {
	print("$basename.compr already exists. Skipping compass search ...\n");
    }

    # Open compass output, read query name and determine query family, sf, fold, and class
    open(INFILE,"<$basename.compr") or die("Error: could not open $basename.compr: $!\n");
    while ($line=<INFILE>) {if ($line=~/^Ali1:\s*\S*(\S{7})\.aln/) {$query=$1; last;} }
    $qfam=$fam{$query};
#    print("query=$query qfam=$qfam\n");
    $qfam=~/^(\S\.\d+\.\d+)\.\d+$/;
    $qsf=$1;
    $qfam=~/^(\S\.\d+)\.\d+\.\d+$/;
    $qcf=$1;
    $qfam=~/^(\S)\.\d+\.\d+\.\d+$/;
    $qcl=$1;

    # Read alignments one by one and write results into @hits
    my @hits=(); $nhit=0;
    while($line) {

	# Read template name and determine relationship $rel
	if ($line=~/Ali2:\s*\S*(\S{7})\.aln/) {$template=$1;} else {
	    die("Error: wrong format in $infile, line $.\n");
	}
	$tfam=$fam{$template};
	if ($query eq $template) {
	    $rel=5;
	} elsif ($tfam eq $qfam) { 
	    $rel=4;
	} else {
	    $tfam=~/^(\S\.\d+\.\d+)\.\d+$/;
	    if ($1 eq $qsf) { 
		$rel=3;
	    } else {
		$tfam=~/^(\S\.\d+)\.\d+\.\d+$/;
		if ($1 eq $qcf) { 
		    $rel=2;
		} else {
		    $tfam=~/^(\S)\.\d+\.\d+\.\d+$/;
		    if ($1 eq $qcl) {$rel=1;} else {$rel=0;}
		}
	    }
	}	

	<INFILE>;          # 'Threshold of effective gap content in columns: 0.5'
	$line=<INFILE>;    # 'length1=188	filtered_length1=187	length2=130	filtered_length2=126'
	if ($line=~/filtered_length1=\s*(\S+).*?filtered_length2=\s*(\S+)/) {$qlen=$1; $tlen=$2;} else {
	    die("Error: wrong format in $infile, line $.\n");
	}
	<INFILE>;          # 'Nseqs1=546	Neff1=15.984	Nseqs2=1	Neff2=8.335'
	$line=<INFILE>;    # 'Smith-Waterman score = 33	 Evalue = 7.09e+02'
	if ($line=~/Evalue\s*=\s*(\S+)/) {$evalue=$1;} else {
	    die("Error: wrong format in $infile, line $.\n");
	}
	<INFILE>;          # read blank line

	# Read alignment
	$aaq=""; $aat="";

	# Read first line with query residues
	$line=<INFILE>;	    
	$line=~/\S+\s+(\d+)\s+(\S+)/;
	$qfirst=$1;
	$aaq.=$2;
	<INFILE>;          # read symbol line
	
	# Read first line with template residues
	$line=<INFILE>;	    
	$line=~/\S+\s+(\d+)\s+(\S+)/;
	$tfirst=$1;
	$aat.=$2;
	<INFILE>;          # read blank line
	$line=<INFILE>;	

	# Read more lines of alignment ?
	while (defined $line && $line!~/^Ali1:/) {
	    # Read query residues
	    $line=<INFILE>;	    
	    $line=~/\S+\s+(\S+)/;
	    $aaq.=$1;
	    <INFILE>;      # read symbol line
	    
	    # Read template residues
	    $line=<INFILE>;	    
	    $line=~/\S+\s+(\S+)/;
	    $aat.=$1;
	    <INFILE>;  # read blank line
	    $line=<INFILE>;	
	}

	if (!$qfirst) {$qfirst=1;}  # if still $qfirst==0 then set $qfirst to 1
	if (!$tfirst) {$tfirst=1;}  # if still $tfirst==0 then set $tfirst to 1
	$aaq=~tr/=~/--/;
	$aat=~tr/=~/--/;
	$aaq=~tr/a-z/A-Z/;
	$aat=~tr/a-z/A-Z/;

	# Check lengths
	if (length($aaq)!=length($aat)) {
	    print("\nError: query and template lines do not have the same length in $infile, line $.\n");
	    printf("Q %-14.14s $aaq\n",$query);
	    printf("T %-14.14s $aat\n\n",$template);
	    exit 1;
	}
	if ($v>=3) {
	    printf("Q %-14.14s $aaq\n",$query);
	    printf("T %-14.14s $aat\n\n",$template);
	}	    

	# Calculate MaxSub score?
	if ($evalue<=$EVALMAX || $rel>=$RELMIN) {
	    my $line; # we need local $line here, since the global $line still contains the next line in infile
	    
	    # Make pdb file for scop sequence?
	    if (!$update || !-e "$basename.pdb") {if (&MakePdbFile($basename)) {next;} }
	    
	    # Make model from compass alignment
	    &MakeModel("$basename.mod");
	    
	    # Read maxsub score
	    if ( open(MAXSUB,"$maxsub $basename.mod $basename.pdb 3.5 |") ) {
		#REMARK HAS 35 AT RMS 1.920. WITH A COMPUTED GL SCORE OF  28.097 , MAXSUB: 0.208
		while($line=<MAXSUB>) {if ($line=~/HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {last;} } 
		if (defined $line && $line=~/HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {
		    if($1>40 || ($1>25 && $2>0.125)) {
			$naligned=$1;
			$MSscore=sprintf("%4.2f",10*$2);
		    } else {$MSscore=" 0.0"; $naligned=$1;}
		    if ($v>=1) {print($line);}
		} else {
		    print("Warning: found no MAXSUB score for $basename: $!\n"); 
		    $MSscore="0"; $naligned=0;
		} 
		close(MAXSUB);
	    } else {
		warn("Error: can't call MAXSUB at $maxsub: $!\n"); 
	    }
	    
	} else {$MSscore="0"; $naligned=0; $ncol=0;}

	
	$hits[$nhit]=sprintf("%7s  %1i %3i %3i %8.1E %6.2f %4s %3i",$template,$rel,$tlen,$ncol,$evalue,-1.443*log($evalue/$NDB+1E-99),$MSscore,$naligned);
	$nhit++;
    }
    close(INFILE);
    
    # Sort hit list by Evalue
    @hits = sort(ByScore @hits);

    # Write scores file
    open(OUTFILE,">$basename.scores") or die("Error: could not open $basename.scores: $!\n");
    print(OUTFILE "NAME  $query\n");
    print(OUTFILE "FAM   $qfam\n");
    print(OUTFILE "LENG  $qlen\n");
    print(OUTFILE "\n");
    print(OUTFILE "TARGET REL LEN COL RAW-SCORE SCORE   MS NALI\n");

    for (my $n=0; $n<@hits; $n++) {
	print(OUTFILE "$hits[$n]\n");
    }
    close(OUTFILE);
    print("\n");

} # foreach ($infile)

exit(0);


# Subroutine for sorting by score
sub ByScore()
{
    $a=~/(\S+)\s+\S+\s+\S+\s*$/;
    my $S_a=$1;
    $b=~/(\S+)\s+\S+\s+\S+\s*$/;
    my $S_b=$1;
    return $S_b<=>$S_a;
}



##################################################################################
# Make model pdb file from alignment or $query vs $template in vectors @i and @j
##################################################################################
sub MakeModel() 
{
    my $modelfile=$_[0];
    my $line;

    #Delete columns with gaps in both sequences
    $aaq=uc($aaq);
    $aat=uc($aat);
    my @aaq=split(//,$aaq);
    my @aat=split(//,$aat);
    my $col1=0;    # counts columns from pairwise alignment of $aaq vs $aat (query vs template)
    my $col=0;     # counts columns with residue in either of the two sequences
    my $col2=0;    # counts columns from pairwise alignment of $aat vs $aapdb (template vs pdb structure)
    my (@i1, @j1); # index vectors for alignment of $aaq vs $aat (query vs template)
    my (@j2, @l2); # index vectors for alignment of $aat vs $aapdb (template vs pdb structure)
    my @l1;        # index vector  for alignment of $aaq vs $aapdb (query vs pdb structure)

    $ncol=0;       # count number of Match-Match columns
    for ($col1=0; $col1<@aaq; $col1++) {
	if ($aaq[$col1]=~tr/a-zA-Z/a-zA-Z/ || $aat[$col1]=~tr/a-zA-Z/a-zA-Z/) {
	    $aaq[$col]=$aaq[$col1];
	    $aat[$col]=$aat[$col1];
	    $col++;
	}
	if ($aaq[$col1]=~tr/a-zA-Z/a-zA-Z/ && $aat[$col1]=~tr/a-zA-Z/a-zA-Z/) {$ncol++;}
    }
    splice(@aaq,$col); # delete end of @aaq;
    splice(@aat,$col);
    $aaq=join("",@aaq);
    $aat=join("",@aat);
    
    # Count query and template residues into @i1 and @j1 
    for ($col1=0; $col1<@aaq; $col1++) {
	if ($aaq[$col1]=~tr/a-zA-Z/a-zA-Z/) {
	    $i1[$col1]=$qfirst++;  #found query residue in $col1
	} else {
	    $i1[$col1]=0;     #found gap in $col1
	}
	if ($aat[$col1]=~tr/a-zA-Z/a-zA-Z/) {
	    $j1[$col1]=$tfirst++;  #found template residue in $col1
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


    # Read protein chain from pdb file
# ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
# ATOM      1  N   SER A  27      38.637  79.034  59.693  1.00 79.70           N
# ATOM   2083  CD1 LEU A  22S     15.343 -12.020  43.761  1.00  5.00           C
    
    # Extract pdbcode and construct name of pdbfile
    $template=~/[a-z](\S{4})(.)./;
    my $pdbcode=lc($1);
    my $pdbfile="$pdbdir/pdb".$pdbcode.".ent";
    my $chain=uc($2);
    if ($chain eq "_") {$pdbcode.="_"; $chain="[A ]";} elsif ($chain eq ".") {;} else {$pdbcode.="_$chain";}

    # Read sequence from pdb file
    if (!open (PDBFILE, "<$pdbfile")) {
	die ("Error: Couldn't open $pdbfile: $!\n");
    }
    my $aapdb="";    # residues in pdb file
    my @aapdb=();    # same in array
    my $l=1;         # counts residues in pdb file
    my @nres;        # $nres[$l] = pdb residue index for residue $aapdb[$l]
    my @coord;       # $coord[$l] = coordinates of CA atom of residue $aapdb[$l]
    my $res;         # residue (3letter code -> one-letter code)$
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
    
    # Construct alignment of $aaq <-> $aapdb via alignments $aaq <-> $aat and $aat <-> $aapdb:  
    # Find $l1[$col1] = line of pdb file corresponding to residue $aat[$col1] and $aaq[$col1]
    $col2=0;
    for ($col1=0; $col1<@aaq; $col1++) {
	if ($j1[$col1]==0 || $i1[$col1]==0) {$l1[$col1]=0; next;} # skip gaps in query and gaps in template
	while ($j2[$col2]<$col1+1) {$col2++;} # in $j2[col2] first index is 1, in $col1 first column is 0
	$l1[$col1] = $l2[$col2];
	if ($v>=4) {printf("l1[%i]=%i  l2[%i]=%i\n",$col1,$l1[$col1],$col2,$l2[$col2]);}
    }
    
    
    # Print model file
    my $shift=0;
    open(MODELFILE,">$modelfile") || die("Error: could not open $modelfile: $!\n");
    for ($col1=0; $col1<@aat; $col1++) {
	if ($i1[$col1]==0) {next;} # skip gaps in query
	if ($j1[$col1]==0) {next;} # skip gaps in template sequence
	if ($l1[$col1]==0) {next;} # skip if corresponding residue was skipped in pdb file
	
	printf(MODELFILE "ATOM  %5i  CA  %3s  %4i    %-50.50s\n",$i1[$col1],&One2ThreeLetter($aaq[$col1]),$i1[$col1]+$shift,$coord[$l1[$col1]]);
	if ($v>=4) {
	    printf("ATOM  %5i  CA  %3s  %4i    %-50.50s\n",$i1[$col1],&One2ThreeLetter($aaq[$col1]),$i1[$col1]+$shift,$coord[$l1[$col1]]);
	}
    }
    printf(MODELFILE "TER\n");
    close(MODELFILE);
    return;
}



##################################################################################
# Make a pdb file $basename.pdb with correct resdiue numbers from query sequence in $basename.hhm 
##################################################################################
sub MakePdbFile() 
{
    my $basename=$_[0];
    my $aaq;        # query amino acids
    my $scopid;     # scopid of query sequence in hmmfile
    my $chain;      # chain id of query sequence for hmmfile 
    my $pdbfile;    # pdbfile corresponding to query sequence
    my $i;          # index for column in HMM
    my $line;
    
    $scopid=$query;
    $scopid=~/^[a-z](\w{4})(\S)./;
    $pdbfile="$pdbdir/pdb$1.ent";
    if ($2 eq "_") {$chain="[A ]";} # sequence has no chain id in name, e.g. d1hz4__
    elsif ($2 eq ".") {          # sequence is composed of more than one pdb chain, e.g. d1hz4.1
	$chain=".";
    } else {
	$chain=uc($2);           # sequence has just one chain, e.g. d1hz4a_
    }      
    
    # Open infile and read name and chain id of query
    $infile="$basename.aln";
    if ($v>=2) {printf("Reading %s ... \n",$infile);}
    if (!open (SEQFILE,"<$infile")) {warn("Error: can't open $infile: $!\n"); return 1;}
    while ($line=<SEQFILE>) {if ($line=~/^$scopid/) {last;} }
    if ($line!~/^$scopid\s+(\S+)/) {warn("Error: can't find query sequence $scopid in $infile: $!\n"); return 1;}
    $aaq=$1;
    $aaq=~tr/.-//d;  # $aaq=~tr/a-z.//d;  # remove all inserts
    close (SEQFILE);
    
    my $l;          # index for lines in pdb file 
    my @pdbline;    # $pdbline[$l][$natom] = line in pdb file for l'th residue in $aapdb and atom N, CB, or O 
    my $natom;      # runs from 0 up to 2 (N, CB, O)
    my $res;        # residue in pdb line
    my $atom;       # atom code in pdb file (N, CA, CB, O, ...)
    my $aapdb;      # template amino acids from pdb file
    my $col;        # column of alignment query (from a3m file) versus pdb-residues
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
	    if ($3!=$nres) {
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
    if (!open (SHORTFILE,">$basename.pdb")) {warn("Error: can't open $basename.pdb: $!\n"); return 3;}
    my $match=0; 
    my $len=length($aaq)-1; # 0'th position not used 
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
    
    if ($v>=3 || ($v>=2 && $len-$match>1)) {
	if ($v>=1 && $len-$match>1) {
	    printf("\nWARNING: could not find coordinates for %i query residues:\n",$len-$match);
	} else { printf("\n"); }
	printf("a3m: $xseq\n");
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

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

