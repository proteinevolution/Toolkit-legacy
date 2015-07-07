#! /usr/bin/perl -w
# Search with all globbed sequences against data base file and record score distribution
# Usage:   blastallall.pl fileglob directory database [-psi] 

BEGIN { 
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/cluster/soeding/perl");     # for cluster
    push (@INC,"/cluster/bioprogs/hhpred");  # forchimaera  webserver: MyPaths.pm
    push (@INC,"/cluster/lib");              # for chimaera webserver: ConfigServer.pm
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
our $v=4;    # verbose mode
our $matrix="identity";

# directory paths
my $maxsub= "$bioprogs_dir/maxsub/maxsub";               

# Constants
my $RELMIN =2;                # minimum relationship at fold level to calculate MAXSUB score 
my $EVALMAX=10.0;             # maximum Evalue to calculate MAXSUB score for
my $NDB=5457;                 # database size
my $update=0;                 # do not overwrite existing .scores files? !!!!!!!!!!!!!!!!!!

if (scalar(@ARGV)<2) {
    print("
Search with all globbed sequences against data base file and record score distribution
With option -psi (use PSIBLAST instead of BLAST) it needs *.psi files in same directory as *.a3m files. 
Generates pdb-file in same directory if not yet there
Usage:   blastallall.pl fileglob directory database [options] 
Options:
 -psi     use PSIBLAST instead of BLAST
 -u       update: don't recalculate existing *.scores files
Example: blastallall.pl '*.seq' . ~/nr/scop20.1.63 -psi
\n"); 
    exit;
}

my @files = glob("$ARGV[0]"); #read all such files into @files 
my $dir = $ARGV[1];
my $db = $ARGV[2];
my $file;
my $basename; # basename = name without extension
my $rootname; # rootname = basename without path
my $line;
my $n=0;
my $query;    # name of query sequence
my $qfam;     # family of query
my ($qsf,$qcf,$qcl); # query superfamily, fold, and class
my $qlen;     # length of query
my $tlen;     # length of template
my $template;   # name of template sequence
my $tfam;     # family of template
my $rel;      # relationship of query and template
my $rawscore; # raw score of hmmer
my $evalue;   # evalue of template with query
my $MSscore;  # MAXSUB score of query with template
my $hit;      # index of hit in blast output file
my $options="";
my $psi=0;    # default: use blast instead of psiblast
my $ncol=0;   # count number of Match-Match columns
my $naligned; # number of aligned atoms with RMS < 3.5A
if (scalar(@ARGV)>3) {$options=join(" ",@ARGV[2..$#ARGV]);}
if ($options=~s/-psi//) {$psi=1;}
if ($options=~s/-u//)   {$update=1;}

print (scalar(@files)." files read in. Starting selection loop ...\n");

# For each query sequence do blast search and generate *.scores file from blast output
foreach $file (@files) {   
    $n++;
    if ($file =~/(.*)\..*?$/)   {$basename=$1;} else {$basename=$file;} # basename = name without extension
    if ($basename =~/.*\/(.*?)$/) {$rootname=$1;} else {$rootname=$basename;} # rootname = basename without path
    if (-e "$dir/$rootname.scores" && $update) { print("Skipping $dir/$rootname\n"); next;} 
    print(">>> $n: $file $basename $dir/$rootname <<<\n");

    if ($psi) {
	&System("$blastpgp -v 1 -b 10000 -e 10000000 -d $db -i $file -o $dir/$rootname.bla -B $basename.psi");
    } else {
	&System("$blastpgp -v 1 -b 10000 -e 10000000 -d $db -i $file -o $dir/$rootname.bla");
    }    
    # Open blast output and read query name 
    open(INFILE,"<$dir/$rootname.bla") or die("Error: could not open $dir/$rootname.bla: $!\n");
    while ($line=<INFILE>) {if ($line=~/^Query=\s*(\S+)\s+(\S+)/) {$query=$1; $qfam=$2; last;} }
    while ($line=<INFILE>) {if ($line=~/^\s*\((\d+) letters\)/) {$qlen=$1; last;} }
    while ($line=<INFILE>) {if ($line=~/^Sequences producing/) {last;} }
    $line=<INFILE>;
    $qfam=~/^(\S\.\d+\.\d+)\.\d+$/;
    $qsf=$1;
    $qfam=~/^(\S\.\d+)\.\d+\.\d+$/;
    $qcf=$1;
    $qfam=~/^(\S)\.\d+\.\d+\.\d+$/;
    $qcl=$1;

    open(OUTFILE,">$dir/$rootname.scores") or die("Error: could not open $dir/$rootname.scores: $!\n");
    print(OUTFILE "NAME  $query\n");
    print(OUTFILE "FAM   $qfam\n");
    print(OUTFILE "LENG  $qlen\n");
    print(OUTFILE "\n");
    print(OUTFILE "TARGET     FAMILY   REL LEN COL LOG2PVAL  SCORE   PROBAB MS NALI\n");

    # Read hit list one by one and write into scores file
    $hit=0;
    while($line=<INFILE>) {
	if ($line=~/^>\s*(\S+)\s+(\S+)/) {
	    $template=$1;
	    $tfam=$2;
	    while($line=<INFILE>) {if ($line=~/^\s+Length =/) {last;}}
	    $line=~/^\s+Length\s+=\s+(\d+)/;
	    $tlen=$1;
	    while($line=<INFILE>) {if ($line=~/^\s+Score =/) {last;}}
	    $line=~/^\s+Score\s+=\s+(\S+) bits \S+\s+Expect\s+=\s+([0-9\.eE+-]+)/;
	    $rawscore=$1;
	    $evalue=$2;
	    if ($evalue=~/^e/) {$evalue="1$evalue";}
	    if (! defined $tfam) {print("WARNING: wrong format in $dir/$rootname.bla: line: $line"); next;}
	    $hit++;
	    
	    # Determine relationship $rel
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
	    
	    # Calculate MAXSUB score?
	    if ($evalue<=$EVALMAX || $rel>=$RELMIN) {
		&CalculateMSScore();
	    } else {
		$MSscore="0"; $naligned=0; $ncol=0;
	    }
	    
	    printf(OUTFILE "%-10.10s %-10.10s %1i %3i %3i %7.2f %7.2f %6.2f %5.2f %4i\n",$template,$tfam,$rel,$tlen,$ncol,-1.443*log($evalue/$NDB+1E-99),$rawscore,0.0,$MSscore,$naligned);
	}
    }
    close(OUTFILE);
    close(INFILE);
    print("\n");
}
exit(0);

##################################################################################
# Calculate MAXSUB score: generate pdb file and model file from blast alignment
##################################################################################
sub CalculateMSScore() 
{
    # Make pdb file for scop sequence?
    if (!-e "$basename.pdb") {
	if (&MakePdbFile($basename)) {next;}
    }
    # Make model from blast alignment and compare it with pdb structure
    open(MAKEMODEL,"$hh/blastmakemodel.pl $dir/$rootname.bla -m $hit -ts $basename.mod |");
    if ($v>=2) {print("$hh/blastmakemodel.pl $dir/$rootname.bla -m $hit -ts $basename.mod |\n");}
    $line=<MAKEMODEL>;
    if ($v>=2) {print($line);}
    $line=~/(\d+)\s+match columns/;
    $ncol=$1;
    close(MAKEMODEL);
    
    # Read maxsub score
    if ($v>=2) {print("$maxsub $basename.mod $basename.pdb 3.5 |\n");}
    if (open(MAXSUB,"$maxsub $basename.mod $basename.pdb 3.5 |") ) {
	#REMARK HAS 35 AT RMS 1.920. WITH A COMPUTED GL SCORE OF  28.097 , MAXSUB: 0.208
	while($line=<MAXSUB>) {if ($line=~/HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {last;} } 
	if (defined $line && $line=~/HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {
	    if($1>40 || ($1>25 && $2>0.125)) {
		$naligned=$1;
		$MSscore=sprintf("%4.2f",10*$2);
	    } else {$MSscore=" 0.0"; $naligned=$1;}
	    if ($v>=2) {print($line);}
	} else {
	    print("Warning: found no MAXSUB score for $basename: $!\n"); 
	    $MSscore="0"; $naligned=0; $ncol=0;
	} 
	close(MAXSUB);
    } else {
	warn("Error: can't call MAXSUB at $maxsub: $!\n"); 
    }
    return;
}

##################################################################################
# Make a pdb file $base.pdb with correct resdiue numbers from query sequence in $base.hhm 
##################################################################################
sub MakePdbFile() 
{
    my $base=$_[0];
    my $a3mfile="$base.seq";
    my $aaq;        # query amino acids
    my $scopid;     # scopid of query sequence in hmmfile
    my $chain;      # chain id of query sequence for hmmfile 
    my $pdbfile;    # pdbfile corresponding to query sequence
    my $i;          # index for column in HMM
    
    $scopid=$template;
    $scopid=~/^[a-z](\w{4})(\S)./;
    $pdbfile="$pdbdir/pdb$1.ent";
    if ($2 eq "_") {$chain="[ A]";} # sequence has no chain id in name, e.g. d1hz4__
    elsif ($2 eq ".") {          # sequence is composed of more than one pdb chain, e.g. d1hz4.1
	$line=~/\S+\s+\S+\s+\((\S+)\)/;
	$chain=$1;               # e.g. (A:,B:). (B:,A:) will cause an incomplete alignment!!
	$chain=~tr/A-Z//cd;      # remove everything but the chain identifiers 
	$chain="[".$chain."]";   # extract all lines from pdb file belonging to one of these chains
    } else {$chain=uc($2);}      # sequence has just one chain, e.g. d1hz4a_
    
    # Open a3m file and read name and chain id of query
    if ($v>=2) {printf("Reading %s ... \n",$a3mfile);}
    if (!open (A3MFILE,"<$a3mfile")) {warn("Error: can't open $a3mfile: $!\n"); return 1;}
    while ($line=<A3MFILE>) {if ($line=~/^>$scopid/) {last;} }
    if ($line!~/^>$scopid/) {warn("Error: can't find query sequence $scopid in $a3mfile: $!\n"); return 1;}

    # Read query sequence $aaq
    $aaq="";
    while ($line=<A3MFILE>) {
	if ($line=~/^>/) {last;} 
	if ($line=~/^\#/) {last;} 
	else {chomp($line); $aaq.=$line;}
    }
    $aaq=~tr/.//d;  # $aaq=~tr/a-z.//d;  # remove all inserts
    close (A3MFILE);
    
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
    if (!open (SHORTFILE,">$base.pdb")) {warn("Error: can't open $base.pdb: $!\n"); return 3;}
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
    
    if ($v>=3 || ($v>=1 && $len-$match>1)) {
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

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

