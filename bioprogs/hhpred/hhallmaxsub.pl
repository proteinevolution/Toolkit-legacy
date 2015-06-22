#! /usr/bin/perl -w
# For all globbed *.score files: add maxsub scores for hits with E-value<1=$EVALMAX
# *.hhm files must be in directory hhmdir
# Usage: hhallmaxsub.pl fileglob hhmdir 
# Example: hhallmaxsub.pl '*.scores' ..

BEGIN { 
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/cluster/usr/soeding/perl");     # for cluster
    push (@INC,"/cluster/user/soeding/perl");     # for cluster
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
our $v=2;    # verbose mode
our $matrix="identity";

# directory paths
my $maxsub= "$bioprogs_dir/maxsub/maxsub";               
my $TMscore="$bioprogs_dir/TMscore";               

# Constants
my $RELMIN =2;                # minimum relationship at fold level to calculate MAXSUB score 
my $EVALMAX=10.0;             # maximum Evalue to calculate MAXSUB score for
my $SCOREMIN=15.0;            # Eval=10 => Pval=10/3691 => log2(Pval)=8.5 => SCOREMIN ~ 1.38*8.5=11.8
my $NDB=3691;                 # database size
my $update=0;                 # do not overwrite existing .scores files? !!!!!!!!!!!!!!!!!!

if (scalar(@ARGV)<2) {
    print("
 For all globbed *.score files: add maxsub scores for hits with E-value<$EVALMAX
  *.hhm files must be in directory hhmdir
 Usage:   hhallmaxsub.pl fileglob hhmdir [options]
 Options:
  -realign      : realign with default options -global -shift 0.25 -ssw 0.25
  -v <int>      : verbose mode
 Example: hhallmaxsub.pl '*.scores' ..
\n"); 
    exit;
}

my $options="";
my $glob = $ARGV[0];
my $hhmdir = $ARGV[1]; # where to find *.hhm files (for MakePdbFile() )
my @files = glob("$glob"); #read all such files into @files 
my $file;
my $base;          # basename of *.scores file (name without extension)
my $root;          # rootname of *.scores file (base name without path)
my $qname;         # query  scop id 
my $tname;         # template scop id 
my $line;          # input line
my @lines;         # lines of $base.scores to be written 
my $n=0;           # counts input files
my $rel;           # relationship of template to query from *.score file
my $rawscore;      # rawscore of template from *.score file
my $score_aass;    # score of template from *.score file
my $MSscore;       # MAXSUB score of hit
my $naligned;      # number of aligned atoms with RMS < 3.5A
my $ncols=0;       # number of MM columns in sequence alignment

# Create tmp directory (plus path, if necessary)
my $tmpdir="/tmp/$ENV{USER}/$$";  # directory where all temporary files are written: /tmp/UID/PID
my $suffix=$tmpdir;
while ($suffix=~s/^\/[^\/]+//) {
    $tmpdir=~/(.*)$suffix/;
    if (!-d $1) {mkdir($1,0777);}
} 
print("mkdir $tmpdir\n");

# Override default options?
if (@ARGV>2) {
    for (my $i=2; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}
}

# Set E-value thresholds etc. for inclusion in alignment
if ($options=~s/ -realign\s+//g) {
    $options="-local -map -mapt 0.05".$options;
}
if ($options=~s/ -v\s+(\d+) //g) {$v=$1;}
if ($options=~s/ -v //g) {$v=2;}

print (scalar(@files)." files read in. Starting selection loop ...\n");

for ($n=0; $n<@files; $n++) {  
 
    if ($files[$n] =~/^(.*)\..*?$/) {$base=$1;} else {$base=$files[$n];} # get basename for file
    if ($base =~/.*\/(.*?)$/) {$root=$1;} else {$root=$base;} # rootname = basename without path
    print("\n>>> Adding maxsub scores to $base.scores ($n) <<<\n");

    # Read all lines of $base.scores
#    print("Reading $base.scores\n");
    open(SCORESFILE,"<$base.scores") or die("Error: can't open $base.scores: $!\n");
    @lines=<SCORESFILE>;
    close(SCORESFILE);

    # Make pdb file to compare model to
#    print("Adding maxsub scores to $base.scores\n");
    if (!-e "$hhmdir/$root.pdb") {
	if (&MakePdbFile("$hhmdir/$root")) {next;}
    }
    &System("cp $hhmdir/$root.hhm $tmpdir/$root.hhm");

    # Add maxsub scores to lines
    #   TARGET     FAMILY   REL LEN COL LOG-PVA  S-AASS PROBAB   MS NALI
    my $nhit=0;
    my $nmaxsub=0;
    my $nfalse=0;
    for (my $l=0; $l<@lines; $l++) {
	if ($lines[$l]=~/^NAME\s+(\S+)/) {$qname=$1; next;}
	if ($lines[$l]=~/^TARGET/) {$lines[$l]="TARGET     FAMILY   REL LEN COL LOG-PVA  S-AASS PROBAB   MS NALI\n"; next;}
# TARGET     FAMILY   REL LEN COL LOG-PVA  S-AASS PROBAB   MS NALI
# d153l__    d.2.1.5    5 185 185 336.109  520.61 100.00 10.00 185
#                           TARGET FAMILY   REL    LEN   COL    LOG-PVA      S-AASS PROBAB   MS NALI
	if ($lines[$l]!~/^\s*(\S+)\s+\S+\s+(\d+)\s+\d+\s+\d+\s+(-?\d\S*)\s+(-?\d\S*)/) {next;}

	if ($nhit++>=200) {last;} # look only at first 200 hits!

	$tname=$1;
	$rel=$2;
	$MSscore="   0"; 
	$naligned=0;

	if ($rel==2 || ($rel<2 && $nfalse<10)) { # look at all hits related at fold level AND first 10 false ones below fold level (from first 200 hits)
	    
	    $nmaxsub++;

	    if ($v>=2)    {printf("%3i Q:%-7.7s  T:%-7.7s  rel=$rel  Score=%8.2G\n",$nmaxsub,$base,$tname,$4);}
            elsif ($v>=1) {printf("%3i Q:%-7.7s  T:%-7.7s  rel=$rel  Score=%8.2G  ",$nmaxsub,$base,$tname,$4);}

	    &System("$hh/hhalign -i $tmpdir/$root.hhm -t $hhmdir/$tname.hhm -o $tmpdir/$root.tmp.hhr -v 1 $options");
	    &System("$hh/hhmakemodel.pl $tmpdir/$root.tmp.hhr -m 1 -ts $tmpdir/$root.tmp.mod -v");

	    # Read number of match-match columns from $base.tmp.hhr ...
	    open(HHRFILE,"<$tmpdir/$root.tmp.hhr") || die ("Error: could not open $tmpdir/$root.tmp.hhr for reading: $!\n");
	    while ($line=<HHRFILE>) {
		if ($line=~/^\s*No\s+Hit/) {last;}
	    }
	    $line=<HHRFILE>;
	    close(HHRFILE);
	    $line=~/(\d+)\s+\S+\s+\S+\s+\S+$/;
	    $ncols=sprintf("%4i",$1);
	    $lines[$l]=~s/^\s*(\S+\s+\d+\s+\d+)\s+\d+/$1$ncols/;  # write number of MM cols into scores file

	    if (0) {
		# Read TMscore score
		if ( open(TMSCORE,"$TMscore $hhmdir/$root.pdb $tmpdir/$root.tmp.mod |") ) {
		    # Number of residues in common=   28
		    while($line=<TMSCORE>) {if ($line=~/^Number of residues in common/) {last;} } 
		    if (defined $line && $line=~/^Number of residues in common\s*=\s+(\S+)/) {
			$naligned=$1;
		    } else {
			print("Warning: found no TMscore for $base: $!\n"); 
		    } 
		    # TM-score    = 0.4401  (d0= 1.12, TM10= 0.4401)
		    while($line=<TMSCORE>) {if ($line=~/^TM-score\s+=\s+(\S+)/) {last;} } 
		    $line=~/^TM-score\s+=\s+(\S+)/;
		    $MSscore=sprintf("%4.2f",10*$1);
		    if ($v>=2) {print($line);}
		    close(TMSCORE);
		    if ($MSscore<4.0) {$nfalse++;} # NEEDS TO BE ADJUSTED!! 
		} else {
		    print("$TMscore $tmpdir/$root.tmp.mod $hhmdir/$root.pdb \n");
		    warn("Error: can't call TMscore at $TMscore: $!\n"); 
		    $MSscore=" 0.0"; $naligned=0;
		}

	    } else {

		# Read maxsub score
		if ( open(MAXSUB,"$maxsub $tmpdir/$root.tmp.mod $hhmdir/$root.pdb 3.5 |") ) {
		    #REMARK HAS 35 AT RMS 1.920. WITH A COMPUTED GL SCORE OF  28.097 , MAXSUB: 0.208
		    while($line=<MAXSUB>) {if ($line=~/HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {last;} } 
		    if (defined $line && $line=~/HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {
			if($1>40 || ($1>25 && $2>0.125)) {
			    $naligned=$1;
			    $MSscore=sprintf("%4.2f",10*$2);
			} else {$MSscore=" 0.0"; $naligned=$1;}
			if ($v>=2) {print($line);}
			if ($MSscore<1.0) {$nfalse++;}
		    } else {
			print("Warning: found no MAXSUB score for $base: $!\n"); 
		    } 
		    close(MAXSUB);
		} else {
		    print("$maxsub $base.mod $hhmdir/$root.pdb 3.5\n");
		    warn("Error: can't call MAXSUB at $maxsub: $!\n"); 
		    $MSscore=" 0.0"; $naligned=0;
		}
	    }

	}
    #   ----+----|----+----|----+----|----+----|----+----|----+----|
    #   TARGET     FAMILY   REL LEN COL LOG-PVA  S-AASS PROBAB   MS NALI
	$lines[$l]=~/^\s*(\S+\s+\S+\s+\d+\s+\d+\s+\d+\s+-?\d+\.?\d*\s+-?\d+\.?\d*\s*\S*)/;
	$lines[$l]=sprintf("%-54.54s %5s %3i\n",$1,$MSscore,$naligned);
    }
    
    # Write lines to $base.scores
    if (open(SCORESFILE,">$base.scores")) {
	for (my $l=0; $l<@lines; $l++) {print(SCORESFILE $lines[$l]);}
	close(SCORESFILE);
    } else {
	warn("Error: can't open $base.scores: $!\n");
    }

    print("\nFinished hhallmaxsub.pl @ARGV\n");
}
if (length($tmpdir)>=10) {&System("rm -rf $tmpdir/");} # length("/tmp//pidX")==10

exit(0);


##################################################################################
# Make a pdb file $base.pdb with correct resdiue numbers from query sequence in $base.hhm 
##################################################################################
sub MakePdbFile() 
{
    my $base=$_[0];
    my $hhmfile="$hhmdir"."/$root".".hhm";
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
	$chain=~tr/A-Z0-9//cd;   # remove everything but the chain identifiers 
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
    if ($v>=3) {print($_[0]."\n");} 
    return system($_[0]); 
}

