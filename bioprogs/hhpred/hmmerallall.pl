#! /usr/bin/perl -w
# Search with all globbed sequences against data base file and record score distribution
# Usage: hmmerallall.pl dbfile  

BEGIN { 
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/cluster/usr/soeding/perl");  # for cluster
    push (@INC,"/cluster/bioprogs/hhpred");   # forchimaera  webserver: MyPaths.pm
    push (@INC,"/cluster/lib");               # for chimaera webserver: ConfigServer.pm
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
our $v=3;    # verbose mode
our $matrix="identity";

# directory path
my $hmmer ="$bioprogs_dir/hmmer/hmmer-2.3.2/binaries";    #perl directory: querydb.pl, alignhits.pl
my $maxsub="$bioprogs_dir/maxsub/maxsub"; # location of maxsub executable

my $RELMIN =2;                    # minimum relationship at fold level to calculate MAXSUB score 
my $EVALMAX=10.0;                 # maximum Evalue to calculate MAXSUB score for
my $NDB=3691;                     # database size
my $update=1;                     # do not overwrite existing .scores files? !!!!!!!!!!!!!!!!!!1

if (scalar(@ARGV)<3) {
    print("
Search with all globbed sequences against data base file and record score distribution
Usage:   hmmerallall.pl fileglob database [hmmbuild-options] 
Example: hmmerallall.pl '/home/soeding/scop20.3/*.a3m' ~/scop20.3/hmmer ~/nr/scop20.1.63
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
my %tlen;     # $tlen{$template} is length of $template
my $template;   # name of template sequence
my $tfam;     # family of template
my $rel;      # relationship of query and template
my $rawscore; # raw score of hmmer
my $evalue;   # evalue of template with query
my $MSscore="0";  # MAXSUB score of query with template
my $hit;      # index of hit in hmmer output file
my $ncol=0;   # count number of Match-Match columns
my $naligned; # number of aligned atoms with RMS < 3.5A
my $options="";

if (scalar(@ARGV)>2) {$options=join(" ",@ARGV[2..$#ARGV]);}

print (scalar(@files)." files read in. Starting selection loop ...\n");

# Read scop20 fasta file template lengths
open(INFILE,"<$db") or die("Error: cannot open $db: $!\n");
$tlen=0;
$template="undefined";
while($line=<INFILE>) {
    if ($line=~/^>(\S+)/) {
#	print("id=$template length=$tlen\n");
	$tlen{$template}=$tlen;
	$template=$1;
	$tlen=0;
    } else {
	$tlen+=($line=~tr/a-zA-Z/a-zA-Z/);  # add number of residues
    }
}
$tlen{$template}=$tlen;
close(INFILE);

# For each query sequence do hmmer search and generate *.scores file from hmmer output
foreach $file (@files) {   

    $n++;
    if ($file =~/(.*)\..*?$/)   {$basename=$1;} else {$basename=$file;} # basename = name without extension
    if ($basename =~/.*\/(.*?)$/) {$rootname=$1;} else {$rootname=$basename;} # rootname = basename without path
    if (-e "$dir/$rootname.scores" && $update==1) {next;} 

#    if (-e "$dir/$rootname.scores" && $update) { print("Skipping $dir/$rootname\n"); next;} 
    print("\n>>> $n: $file $basename $dir/$rootname <<<\n");

    if (!-e "$dir/$rootname+.hmm" || $update==0) { 
#	&System("$perl/reformat.pl a3m a2m $basename.a3m $dir/tmp.a2m");
#	&ReformatToStockholm("$dir/tmp.a2m","$dir/tmp.sto"); # include reference line that specifies all query residues to be match states
#	&System("$hmmer/hmmbuild $options --hand -F $dir/$rootname.hmm $dir/tmp.sto > $dir/tmp.log"); # build hmm with each query residue a match state
	&System("$hh/hhmake -hmmer -i $basename.a3m -o $dir/$rootname+.hmm > $dir/tmp.log"); # build hmm with each query residue a match state
	&System("$hmmer/hmmcalibrate --num 1000 $dir/$rootname+.hmm >> $dir/tmp.log");
    } 

    if (!-e "$dir/$rootname.hmr" || $update==0) {
	&System("$hmmer/hmmsearch -E 100000 $dir/$rootname+.hmm $db > $dir/$rootname.hmr");
    }

    # Open hmmer output and read query name and count query length
    open(INFILE,"<$file") or die("Error: could not open $file: $!\n");
    while($line=<INFILE>) {
	if ($line=~/^>(\S+)/) {
	    my $name=$1;
	    if ($name!~/^(aa|ss)_/) {last;}
	}
    }
    $line=~/^>(\S+)\s+(\S+)/;
    $query=$1; $qfam=$2; 
    $qfam=~/^(\S\.\d+\.\d+)\.\d+$/;
    $qsf=$1;
    $qfam=~/^(\S\.\d+)\.\d+\.\d+$/;
    $qcf=$1;
    $qfam=~/^(\S)\.\d+\.\d+\.\d+$/;
    $qcl=$1;
    close(INFILE);


    open(OUTFILE,">$dir/$rootname.scores") or die("Error: could not open $dir/$rootname.scores: $!\n");
    print(OUTFILE "NAME  $query\n");
    print(OUTFILE "FAM   $qfam\n");
    printf(OUTFILE "LENG  %i\n",$tlen{$query});
    print(OUTFILE "\n");
    print(OUTFILE "TARGET REL LEN COL RAW-SCORE SCORE   MS NALI\n");

    # Read hit list one by one and write into scores file
#Sequence Description                                    Score    E-value  N
#-------- -----------                                    -----    ------- ---
#d16pk__  c.86.1.1 (-) Phosphoglycerate kinase {Trypan   876.2   6.4e-261   1
#d1jjya_  e.26.1.2 (A:) Ni-containing carbon monoxide   -296.9       0.95   1

    open(INFILE,"<$dir/$rootname.hmr") or die("Error: could not open $dir/$rootname.hmr: $!\n");
    while ($line=<INFILE>) {if ($line=~/^Sequence Description/) {last;} }
    $line=<INFILE>;
    $hit=0;
    while($line=<INFILE>) {
	if ($line=~/^\s*$/) {last;}
	$line=~/^(\S+)\s+(\S+).*\s+(-?\d+\.?\d*)\s+(\S+)\s+\d+$/;
	$template=$1;
	$tfam=$2;
	$rawscore=$3;
	$evalue=$4;
	if ($evalue=~/^e/) {$evalue="1$evalue";}
	if (! defined $tfam) {print("WARNING: wrong format in $dir/$rootname.hmr: line: $line"); next;}
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

	printf(OUTFILE "%7s  %1i %3i %3i %6.2f %5.1f %4s %3i\n",$template,$rel,$tlen{$template},$ncol,$rawscore,-1.443*log($evalue/$NDB+1E-99),$MSscore,$naligned);
    }

    close(OUTFILE);
    close(INFILE);
    print("Done $file \n");

}
exit(0);

##################################################################################
# Calculate MAXSUB score: generate pdb file and model file from hmmer alignment
##################################################################################
sub CalculateMSScore() 
{
    my $line;

    # Make pdb file for scop sequence?
    if (!-e "$basename.pdb") {
	&MakePdbFile("$basename");
    }
    # Make model from hmmer alignment and compare it with pdb structure
    open(MAKEMODEL,"$hh/hmmermakemodel.pl $dir/$rootname.hmr -m $hit -ts $dir/$rootname.mod -v |");
    if ($v>=2) {print("$hh/hmmermakemodel.pl $dir/$rootname.hmr -m $hit -ts $dir/$rootname.mod -v \n");}
    $line=<MAKEMODEL>;
    if ($v>=2) {print($line);}
    $line=~/(\d+)\s+match columns/;
    $ncol=$1;
    close(MAKEMODEL);

    # Read maxsub score
    if ($v>=2) {print("$maxsub $dir/$rootname.mod $basename.pdb 3.5 |\n");}
    if (open(MAXSUB,"$maxsub $dir/$rootname.mod $basename.pdb 3.5 |") ) {
	#REMARK HAS 35 AT RMS 1.920. WITH A COMPUTED GL SCORE OF  28.097 , MAXSUB: 0.208
 
	while($line=<MAXSUB>) {if ($line=~/^REMARK HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {last;} } 
	if (defined $line && $line=~/^REMARK HAS\s+(\d+).*?MAXSUB:\s+(\S+)/) {
	    if($1>40 || ($1>25 && $2>0.125)) {
		$naligned=$1;
		$MSscore=sprintf("%4.2f",10*$2);
	    } else {$MSscore=" 0.0"; $naligned=$1;}
	    if ($v>=2) {
		print($line);
		if($v>=3) {
		    print ("                                                                  E-value $evalue\n");
		}
	    }
	} else {
	    print("Warning: found no MAXSUB score for $basename: $!\n"); 
	    $MSscore="0"; $naligned=0; $ncol=0;
	} 
	close(MAXSUB);
    } else {
	warn("Error: can't call MAXSUB at $maxsub $!\n"); 
    }
    return;
}

##################################################################################
# Make a pdb file $base.pdb with correct resdiue numbers from query sequence in $base.hhm 
##################################################################################
sub MakePdbFile() 
{
    my $base=$_[0];
    my $a3mfile="$base.a3m";
    my $aaq;        # query amino acids
    my $scopid;     # scopid of query sequence in hmmfile
    my $chain;      # chain id of query sequence for hmmfile 
    my $pdbfile;    # pdbfile corresponding to query sequence
    my $i;          # index for column in HMM
    
    $scopid=$query;
    $scopid=~/^[a-z](\w{4})(\S)./;
    $pdbfile="$pdbdir/pdb$1.ent";
    if ($2 eq "_") {$chain="[A ]";} # sequence has no chain id in name, e.g. d1hz4__
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
    $aaq=~tr/.//d;  # remove gaps '.'
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
sub Three2OneLetter 
{
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

sub ReformatToStockholm() 
{
    my $infile=$_[0];
    my $outfile=$_[1];
    my $line;
    my $name="";
    my $res="";
    my $n=0;
    my $skip=1;
    my @name;
    my @seq;
    open(INFILE,"<$infile") or die("Error: could not open $infile: $!\n");
    while($line=<INFILE>) {
	if ($line=~/^>(\S+)/) {
	    if ($skip==0) {
		if ($n==0) {
		    # Write reference line	
		    $seq[$n]=$res;
		    $name[$n]="#=RF";
		    $n++;
		}
		# Write sequence
		$seq[$n]=$res;
		$name[$n]=$name;
		$n++;
	    }
	    $name=$1;
	    if($name=~/^(aa|ss)_/) {$skip=1;} else {$skip=0;}
	    $res="";
	} elsif ($skip==0) {
	    chomp($line);
	    $res.=$line;
	}
    }
    # Write last sequence
    if ($skip==0) {
	if ($n==0) {
	    # Write reference line	
	    $seq[$n]=$res;
	    $name[$n]="#=RF";
	    $n++;
	}
	# Write sequence
	$seq[$n]=$res;
	$name[$n]=$name;
	$n++;
    }




    close(INFILE);

    # Write sequences in Stockholm format
    my $numres=100; # number of residues per line
    my $len=length($seq[0]);
    open(OUTFILE,">$outfile") or die("Error: could not open $outfile: $!\n");
    while ($len>0) {
	if ($len<100) {$numres=$len};
	for ($n=0; $n<@seq; $n++) {
	    printf(OUTFILE "%-20.20s %s\n",$name[$n],substr($seq[$n],0,$numres));
	    $seq[$n]=substr($seq[$n],$numres)
	}
	printf(OUTFILE "\n");
	$len-=$numres;
    }
    close(OUTFILE);
    return;
}


sub System 
{
    if ($v>=2) {print($_[0]."\n");}
    return system($_[0]); 
}

