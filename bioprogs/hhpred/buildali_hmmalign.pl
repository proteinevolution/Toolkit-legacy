#!/usr/bin/perl 
# Build alignment from sequence or alignment input file
# Usage: buildali.pl infile
#

use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/bioprogs/hhpred";  # forchimaera  webserver: MyPaths.pm
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with path variables for nr, blast, psipred, pdb, dssp etc.
use Align;

# Default values:
our $v=2;            # verbose mode
$nr90f =   "$database_dir/nre90";          # nr database to be used # replaced nre90f by nre90 in Tuebingen
$nr70f =   "$database_dir/nre70";          # sequence-id-filtered nr database to be used # replaced nre70f by nre70 in Tuebingen
if (!-d "/tmp/$ENV{USER}") {mkdir("/tmp/$ENV{USER}",0777);}

# Default values for building alignments
my $maxiter=8;       # maximum number of psiblast iterations
my $MAXRES=6000;     # maximum number of allowed residues

# Thresholds for inclusion into iterated psiblast alignments
my $E=1E-3;          # Psiblast Evalue threshold for collecting set of homologs
my $Ecore=1E-5;      # Psiblast Evalue threshold for core alignment
my $id=90;           # maximum sequence identity
my $cov=20;          # minimum coverage
my $min_hitlen=0;    # minimum number of residues in match states 
my $Ndiff=0;         # number of maximally different sequences
my $bl=0.0;          # lenient minimum per-residue bit score with query at ends of HSP
my $bs=0.5;          # strict  minimum per-residue bit score with query at ends of HSP
my $bg=20;           # maximum number of HSP residiues missing at ends of query to use lenient $bl
my $qid="";          # minimum sequence identity with query
my $sc="";           # minimum score per column with query
my $best="";         # extract only the best HSP per sequence, except during last round
my $do_dssp=1;       # DO determine DSSP states by default
my $noss=0;          # default= include predicted and DSSP secondary structure
my $olddir="";       # do a real update of old database (rerun PSI-BLAST)
my $cpu=1;           # no multithreading

my $usage="
Build alignment for query sequence or alignment (A2M, A3M, or FASTA):
* Do up to $maxiter iterations of PSI-BLAST to collect homologous sequences
* On each set of homologs found by PSI-BLAST do hmmsearch until convergence 
* include dssp states if available
* include psipred secondary structure prediction  

Usage: buildali_new.pl infile [outdir] [options] 

General options:
 -v   <int>   verbose mode (def=$v)
 -u           update: do not overwrite *.a3m files already existing (def=off)
 -old <dir>   if a file with same name is found in old database, jumpstart PSI-BLAST with this file
 -cpu  int    number of CPUs to use when calling blastpgp (default=$cpu)

Options for building alignments:
 -n   <int>   maximum number of psiblast iterations  (def=$maxiter)
 -e   <float> PSI-BLAST E-value for inclusion into profile for next iteration
 -id  <int>   maximum pairwise sequence identity in % (def=$id)
 -qid <int>   minimum sequence identity with query in % (def=$id)
 -diff <int>  maximum number of maximally different sequences in output alignment (default=off) 
 -cov <int>   minimum coverage in % (Coverage = length of HSP / length of query) (def=$cov)
 -len <int>   minimum number of residues in HSP (def=$min_hitlen)
 -bl  <float> lenient minimum per-residue (1/3)-bit score for pruning ends of HSP (default=$bl)
 -bs  <float> strict  minimum per-residue (1/3)-bit score for pruning ends of HSP (default=$bs)
 -bg  <float> use the lenient bl below this number of end gaps and the strict bs otherwise (default=$bg)
 -noss        omit secondary structure (predicted or DSSP)

Input formats:
 -fas         aligned FASTA input format; the first sequence (=query sequence) will define match columns
 -a3m         A3M input format (default); the first sequence (=query sequence) will (re)define match columns
 -clu         CLUSTAL format
 -sto         Stockholm format; sequences in just one block, one line per sequence
  

Example: buildali.p test.a3m > ./builddb.log &
\n";

# Variable declarations
my $tmpdir="/tmp/$ENV{USER}/$$";  # directory where all temporary files are written: /tmp/UID/PID
my $line;
my $base;              # base name of infile (filename without extension)
my $root;              # root name of infile (filename without extension and path)
my $qseq;              # residues of query sequence
my $q_match;           # number of match states in query
my $qnameline;         # query in fasta format: '>$qnameline\n$qseq'
my $update=0;          # 0:overwrite  1:do not overwrite
my $nfile=0;           # number of alignent file currently being generated
my $cov0;              # effective minimum coverage (including $mi_-hitlen threshold)
my $informat="a3m";    # input format
my $infile="";         # input sequence/alignment file
my $outdir="";         # write output files into other that present directory?
my $nseqin=1;          # number of sequences in infile
my $ss_dssp;           # dssp states as string
my $aa_dssp;           # residues from dssp file as string
my $aa_astr;           # residues from infile as string
my $ss_pred="";        # psipred ss states
my $ss_conf="";        # psipred confidence values
my $aa_pred="";        # residues from psipred file
my $M="first";         # match state assignment rule
our $sizedb=0;          # size of last database searched with PSI-BLAST (determined from PSI-BLAST output)
$blastpgp.=" -I T";    # show gi's in defline; (use Smith-Waterman: "-s T")

###############################################################################################
# Processing command line input
###############################################################################################

if (@ARGV<1) {die ($usage);}

my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# General options
if ($options=~s/ -v\s*(\d) //g) {$v=$1;}
if ($options=~s/ -v //g) {$v=2;}
if ($v>=2) {print("$0 $options\n");}
if ($options=~s/ -u //g) {$update=1;}
if ($options=~s/ -cpu \s+(\d+)//g) {$cpu=$1;}
if ($options=~s/ -old\s+(\S+) / /g) {$olddir=$1;}

# Options for building alignments:
if ($options=~s/ -n\s+(\d+) //g) {$maxiter=$1;}
if ($options=~s/ -E\s+(\S+) //g) {$E=$1;}
if ($options=~s/ -ecore\s+(\S+) //g) {$Ecore=$1;}
if ($options=~s/ -id\s+(\d+) //g) {$id=$1;}
if ($options=~s/( -qid\s+\S+) //g) {$qid=$1;}
if ($options=~s/ -diff\s+(\d+) //g) {$Ndiff=$1;}
if ($options=~s/ -cov\s+(\d+) //g) {$cov=$1;}
if ($options=~s/ -len\s+(\d+) //g) {$min_hitlen=$1;}
if ($options=~s/ -best //g) {$best="-best";}
if ($options=~s/( -s\/c\s+\S+) //g) {$sc=$1;}
if ($options=~s/ -bl\s+(\S+) / /g)  {$bl=$1;}
if ($options=~s/ -bs\s+(\S+) / /g)  {$bs=$1;} 
if ($options=~s/ -bg\s+(\S+) / /g)  {$bg=$1;} 
if ($options=~s/ -dssp //g) {$do_dssp=1;}
if ($options=~s/ -nodssp //g) {$do_dssp=0;}
if ($options=~s/ -maxres\s+(\S+) //g) {$MAXRES=$1;}
if ($options=~s/ -noss //g) {$noss=1;}

#Input format fasta?
if ($options=~s/ -fas\s//g) {$informat="fas";}
if ($options=~s/ -a2m\s//g) {$informat="a2m";}
if ($options=~s/ -a3m\s//g) {$informat="a3m";}
if ($options=~s/ -clu\s//g) {$informat="clu";}
if ($options=~s/ -sto\s//g) {$informat="sto";}

# Set input and output file
if ($options=~s/ -i\s+(\S+) //g) {$infile=$1;}
if ($options=~s/ -o\s+(\S+) //g) {$outdir=$1;}
if (!$infile  && $options=~s/^\s*([^-]\S*)\s* //) {$infile=$1;} 
if (!$outdir  && $options=~s/^\s*([^-]\S*)\s* //) {$outdir=$1;} 
if ($options=~s/ -tmp\s+(\S+) / /g) {$tmpdir=$1;}

# Warn if unknown options found or no infile/outfile
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; die("Error: unknown options '$options'\n");}
if (!$infile) {print($usage); exit(1);}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}

my $v2 = $v-1;
if ($v>=2) {$|= 1;} # Activate autoflushing on STDOUT}
if ($v2>2) {$v2=2; $|= 1; } # Activate autoflushing on STDOUT}
if ($v2<0) {$v2=0;}

if ($v>=2) {printf("Hostname=%s",`hostname`);}
if (!-d $tmpdir) {mkdir($tmpdir,0777);}

###############################################################################################
# Reformat input alignment to a3m and psiblast-readable format and generate file with query sequence
###############################################################################################

if ($infile=~/(.*)\..*/) {$base=$1;} else {$base=$infile;}  # remove extension
if ($base=~/.*\/(.*)/)  {$root=$1;} else {$root=$base;} # remove path 
my $tmp="$tmpdir/$root.tmp";

#print("check if exists: $olddir/$root.a3m\n");
if ($olddir ne "" && -e "$olddir/$root.a3m") {
    $nseqin=&System("$perl/reformat.pl -v $v2 -M first -noss a3m a3m  $olddir/$root.a3m $tmp.a3m");
} else {

    # Use first sequence to define match states and reformat input file to a3m and psi
    if ($informat eq "fas") {
	$nseqin=&System("$perl/reformat.pl -v $v2 -M first -noss fas a3m $infile $tmp.a3m");
    } elsif ($informat eq "a2m") {
	$nseqin=&System("$perl/reformat.pl -v $v2 -M first -noss a2m a3m $infile $tmp.a3m");
    } elsif ($informat eq "clu") {
	$nseqin=&System("$perl/reformat.pl -v $v2 -M first -noss clu a3m $infile $tmp.a3m");
    } elsif ($informat eq "sto") {
	$nseqin=&System("$perl/reformat.pl -v $v2 -M first -noss sto a3m $infile $tmp.a3m");
    } else {
	$nseqin=&System("$perl/reformat.pl -v $v2 -M first -noss a3m a3m $infile $tmp.a3m");
    }
}
	    
# Read query sequence
open (INFILE, "<$tmp.a3m") or die ("ERROR: cannot open $tmp.a3m: $!\n");
while ($line=<INFILE>) {if($line=~/^>/) {last;} } # Find first nameline
if ($line!~/^>(\S+)(.*)/) {die("Error: couldn't find sequence name line in $infile. Wrong format?\n");}
$qnameline=$1.$2;
$qseq="";
while ($line=<INFILE>) {
    if($line=~/^>/) {last;} 
    chomp($line);
    $qseq.=uc($line);
}
close(INFILE);
$q_match = ($qseq=~tr/A-Z/A-Z/); # count number of capital letters
$qseq=~tr/a-zA-Z//cd; # purge all non-residue symbols from $qseq



# If less than 26 match states
if ($q_match<=25) { 

    # Add Xs to the end of each sequence in $tmp.a3m because PSI-BLAST needs at least 26 residues in query
    my $addedXs='X' x (26-$q_match);
    $qseq.=$addedXs;     # add 'X' to query to make it at least 26 resiudes long
    open (INFILE, "<$tmp.a3m") or die ("ERROR: cannot open $tmp.a3m: $!\n");
    my @lines=<INFILE>;
    close (INFILE);
    open (OUTFILE, ">$tmp.a3m") or die ("ERROR: cannot open $tmp.a3m: $!\n");
    $lines[$#lines+1]=">dummy\n";
    for (my $i=1; $i<@lines; $i++) {
	if ($lines[$i]=~/^>/) {
	    chomp($lines[$i-1]);
	    print(OUTFILE $lines[$i-1].$addedXs."\n");
	} else {
	    print(OUTFILE $lines[$i-1]);
	}
    }
    close(OUTFILE);

} elsif ($q_match>$MAXRES) {    

    # Query has more than $MAXRES residues. Cut down to the first $MAXRES residues
    print("WARNING: maximum number of query sequence residue exceeded. Using first $MAXRES residues\n\n");
    my @seqs=();  # sequences read in from $tmp.a3m
    my $i=0;
    $/=">"; # set input field seperator
    open (INFILE, "<$tmp.a3m") or die ("ERROR: cannot open $tmp.a3m: $!\n");
    while (my $seq=<INFILE>) {
	if ($seq eq ">") {next;}
	while ($seq=~s/(.)>$/$1/) {$seq.=<INFILE>;} # in the case that nameline contains a '>'
	$seq=~s/^(.*)//;        # divide into nameline and residues; '.' matches anything except '\n'
	my $nameline=">$1";        # don't move this line away from previous line $seq=~s/([^\n]*)//;
	$seq=~tr/\n> .//d;      # remove all newlines, '.'

	# Now cut off everything after first $MAXRES residues
	my @seq=split(/([A-Z-][a-z]*)/,$seq);
	$seq=join("",@seq[0..2*$MAXRES-1]);
	$seqs[$i++]="$nameline\n$seq\n";
#       for (my $j=0; $j<@seq; $j++) {printf("%2i:%s\n",$j,$seq[$j]);}
    }
    close (INFILE);
    $/="\n"; # reset input field seperator
    $qseq=$seqs[0];  # shorten also query residues
    open (OUTFILE, ">$tmp.a3m") or die ("ERROR: cannot open $tmp.a3m: $!\n");
    for ($i=0; $i<@seqs; $i++) {
# 	print($seqs[$i]);
 	print(OUTFILE $seqs[$i]);
    }
    close(OUTFILE);
}

# Write query sequence file in FASTA format
open (QFILE, ">$tmp.seq") or die("ERROR: can't open $tmp.seq: $!\n");
printf(QFILE ">%s\n%s\n",$qnameline,$qseq);
close (QFILE);

# Build alignment around sequence/alignment in $tmp.seq, $tmp.a3m, $tmp.psi
&BuildAlignmentWithSS();

if ($v>=3) {
    print ("Temporary files are not removed\n");
} else {
    unlink( glob "$tmp.*");
    rmdir( "$tmpdir");
}
if ($v>=2) {
    print ("Finished $0 @ARGV\n");
} else {
    print ("Finished $0\n");
}
exit;


###############################################################################################
#### Build an alignment around sequence in $base (called by main)	    
###############################################################################################
sub BuildAlignmentWithSS()
{
    $nfile++;
    if ($v>=2) {
	print("\n");
	print("************************************************\n");
	printf(" Building alignment for $base (%-.60s)\n",$qnameline);
	print("************************************************\n");
    }
    
    # Minimum length of hits is $min_hitlen residues in match states
    $cov0 = sprintf("%.0f",100*$min_hitlen/$q_match);
    if ($cov0>=80) {$cov0=80;}
    if ($cov>=$cov0) {$cov0=$cov;}
    	
    # Iterative PSI-BLAST/HMMer search
    &BuildAlignment("$base");
	
#    $qseq=~tr/a-z//d; # remove 'x' symbols that signify domain insertions in scop/astral sequences
   
    if (!$noss) {
    
	my @nam=();            #names of sequences in alignment  
	my @seq=();            #residues of sequences in alignment

	# Read query sequence and write dssp state sequence (plus dssp residues for verif) into $tmp.a3m
	if ($do_dssp && $dsspdir ne "") {
	    if (!&AppendDsspSequences("$tmp.seq")) {
		push(@nam,">ss_dssp"); 
		push(@seq,"$ss_dssp");
		push(@nam,">aa_dssp");
		push(@seq,"$aa_dssp");
	    }
	}
	
	# Secondary structure prediction with PSIPRED
	if ($v>=1) {printf ("Predicting secondary structure with PSIPRED ...\n");}
	&RunPsipred("$tmp.seq");
	if (open (PSIPREDFILE, "<$tmp.horiz")) {
	    my $in;             #input line
	    $ss_conf="";
	    $ss_pred="";
	    $aa_pred="";
	    # Read Psipred file
	    while ($in=<PSIPREDFILE>) {
		if    ($in=~/^Conf:\s+(\d+)/) {$ss_conf.=$1;}
		elsif ($in=~/^Pred:\s+(\S+)/) {$ss_pred.=$1;}
		elsif ($in=~/^  AA:\s+(\S+)/) {$aa_pred.=$1;}
	    }
	    close(PSIPREDFILE);
	    
	    push(@nam,">ss_pred");
	    push(@seq,"$ss_pred");
	    push(@nam,">ss_conf");
	    push(@seq,"$ss_conf");
	    push(@nam,">aa_pred");
	    push(@seq,"$aa_pred");
	}
	
	# Write DSSP and PSIPREd seqs to $tmp.pre.a3m
	if (!open (ALIFILE, ">$tmp.pre.a3m")) {warn ("ERROR: cannot open $tmp.pre.a3m: $!\n"); return 1;}
	for (my $i=0; $i<@nam; $i++) {print(ALIFILE "$nam[$i]\n$seq[$i]\n");}
	close(ALIFILE);
    }

    # Append alignment sequences to dssp- and psipred sequences
    &System("cat $tmp.a3m >> $tmp.pre.a3m ");
    &System("mv $tmp.pre.a3m $base.a3m ");

#    &System("$perl/reformat.pl -v $v2 -r -num a3m clu  $base.a3m $base.clu");
#    &System("$perl/reformat.pl -v $v2 -r -num a3m fas  $base.a3m $base.fas");
#    &System("$perl/reformat.pl -v $v2 -num a2m fas  $base.a2m $base.fas");

    return;
} 



###################################################################################################
# Build alignment for seqfile
###################################################################################################
sub BuildAlignment() {
    my $base=$_[0];               # name of file without extension
    my $seqfile="$tmp.seq";       # query sequence in fasta format
    my $a3mfile="$tmp.a3m";       # alignment with all seqs found so far (master alignment), in a3m format
    my $psifile="$tmp.psi";       # alignment with all seqs found so far (from a3m alignment), in psi format
    my $stofile="$tmp.sto";       # alignment with all seqs found so far (from a3m alignment), in STOCKHOLM format
    my $prefile="$tmp.seqs";      # alignment with prefiltered seqs extracted from last PSI-BLAST search, in unaligned FASTA format
    my $corefile="$tmp.core.psi"; # core alignment containing only safest homologs, in PSIBLAST-readable format 
    my $blafile="$tmp.bla";       # BLAST output file
    my $hmmfile="$tmp.hmm";       # HMM file
    my $hmrfile="$tmp.hmr";       # HMMer results file
    my $bcore="-bl 1 -bs 2";            # score per col in 1/3 bits for end pruning core alignment
    my $bopt="-bl $bl -bs $bs -bg $bg"; # score per col in 1/3 bits for end pruning PSI-BLAST alignments
    my $iter=0;                        # number of PSIBLAST iterations done
    my $nhits=0;                       # number of nhits in filtered alignment after current PSI-BLAST search
    my $nhits_prev=-1    ;             # number of nhits in filtered alingment after previous PSI-BLAST search
    my $nhits_psi=0;                   # number of nhits from current PSIBLAST search
    my $db=$nr90f;                     # database against which to blast (first nr90f, then nr70f)
    my $db_nopath=$db;                 # $db without path
    $db_nopath=~s/.*\///;

    if ($bl<-1 && $bs<-1) {$bopt="";}

    # Switch from nr90f to nr70f?
    if ($nseqin>=50) {$db=$nr70f; $db_nopath=$db; $db_nopath=~s/.*\///;}

    if ($nseqin<=1) {
	# Start from single sequence 
	if ($v>=1) {printf ("Using query sequence to build alignment ...\n");}

	# Prepare $corefile
	# Search database for a set of homologs up to E-value $E
	&blastpgp("-e $E -d $db -i $seqfile","$blafile");
	# Extract core alignment from BLAST output and write to $corefile (in psi format)
	&System("$perl/alignhits.pl -v 2 -cov $cov0 $qid -e $Ecore $bcore -best -psi -q $seqfile $blafile $corefile");
	# Extract seed alignment from BLAST output and write to $a3mfile (in a3m format)
	&System("$perl/alignhits.pl -v $v2 -cov $cov0 $qid -e $Ecore $bcore -best -a3m -q $seqfile $blafile $a3mfile");

    } else {
	# Start from multiple alignment
	if ($v>=1) {printf ("Using query alignment to jumpstart PSI-BLAST ...\n");}
    }

    # From here on use $corefile for end pruning of $psifile
    if ($bopt ne "")  {$bopt.=" -B $corefile -q $seqfile";}  

   # Iterate PSI-BLAST searches
    while ($nhits<250 && $nhits_prev<$nhits && $iter<$maxiter) {
	$iter++;
	
	# Switch from nr90f to nr70f?
	if ($db eq $nr90f && $nhits>=50) {
	    $db=$nr70f; $db_nopath=$db; $db_nopath=~s/.*\///; 
	    $nhits=0; $nhits_psi=0; 
	    $sizedb=0;
	}

	if ($nseqin>1 || $iter>1) {
	    # Reformat a3m alignment into $psifile for jumpstarting PSI-BLAST
	    &System("$perl/reformat.pl -v $v2 -r a3m psi $a3mfile $psifile");
	    # If this is the first iteration (and hence $nseqin>1) copy input alignment to corefile
	    if ($iter==1) {&System("cp $psifile $corefile");}
	    # Search database for a set of homologs up to E-value $E
	    &blastpgp("-e $E -d $db -i $seqfile -B $psifile","$blafile");
 	}
	 
	# Extract set of homologs from BLAST output and write to $prefile
	$nhits_prev=$nhits;
	$nhits = &System("$perl/alignhits.pl -v $v2 -cov $cov0 $qid $sc $best -e $E $bopt -ufas $blafile $prefile");

	# Reformat alignment into sto for making an HMM file
	&System("$perl/reformat.pl -v $v2 -num a3m sto $a3mfile $stofile");
	# Build HMM 
	&System("$hmmerdir/hmmbuild --amino -s -F --hand $hmmfile $stofile > /dev/null");

	# Align sequences to HMM
	&System("$hmmerdir/hmmalign --outformat A2M  -o $tmp.1.a3m $hmmfile $prefile > /dev/null");
	&System("cat $tmp.1.a3m >>  $a3mfile");
	
#	$nhits=&System("$hh/hhfilter -v $v -M a3m -id 95 -diff $Ndiff -i $a3mfile -o $a3mfile ") || die();

	if ($v>=1) {printf ("Found >>%s<< sequences in round $iter (E-value=$E, db=%s))\n\n",&NHits($nhits),$db_nopath);}
    }

    &System("$hh/hhfilter -v $v -M a3m -id $id $qid -cov $cov0 -diff $Ndiff -i $a3mfile -o $a3mfile ") || die();
    &System("$perl/reformat.pl -v $v2 -r a3m psi $a3mfile $psifile");

    return;
}



##############################################################################################
# Read query sequence and write dssp state sequence into $base.a3m (called by BuildAlignment)
##############################################################################################
sub AppendDsspSequences() {
    my $qfile=$_[0];

    my $line;        #input line
    my $name;        #name of sequence in in file, e.g. d1g8ma1
    my $qrange;      #chain and residue range of query sequence
    my $aas="";      #amino acids from in file for each $name
    
    my $dsspfile;
    my $pdbfile;
    my $pdbcode;     #pdb code for accessing dssp file; shortened from in code, e.g. 1g8m 
    my @ss_dssp=();  #dssp states for residues (H,E,L)
    my @aa_dssp=();  #residues in dssp file
    my @aa_astr=();  #residues from infile
    my ($xseq,$yseq,$Sstr);

    # Default parameters for Align.pm
    our $d=3;    # gap opening penatlty for Align.pm
    our $e=0.1;  # gap extension penatlty for Align.pm
    our $g=0.09; # endgap penatlty for Align.pm
    our $matrix="identity";
   

    # Read query sequence -> $name, $range, $aas 
    open (QFILE, "<$qfile") || die ("cannot open $qfile: $!");
    while ($line=<QFILE>) {
	if ($line=~/>(\S+)/) {
	    $name=$1;
		
	    # SCOP ID? (d3lkfa_,d3grs_3,d3pmga1,g1m26.1)
	    if ($line=~/^>[defgh](\d[a-z0-9]{3})[a-z0-9_.][a-z0-9_]\s+[a-z]\.\d+\.\d+\.\d+\s+\((\S+)\)/) {
		$pdbcode=$1;
		$qrange=$2;
	    } 

	    # DALI ID? (8fabA_0,1a0i_2)
	    elsif ($line=~/^>(\d[a-z0-9]{3})[A-Za-z0-9]?_\d+\s+\d+\.\d+.\d+.\d+.\d+.\d+\s+\((\S+)\)/) {
		$pdbcode=$1;
		$qrange=$2;
	    }

	    # PDB ID? (8fab_A, 1a0i)
	    elsif ($line=~/^>(\d[a-z0-9]{3})_?(\S?)\s/) {
		$pdbcode=$1;
		if ($2 ne "") {$qrange="$2:";} else {$qrange="-";}
	    }

	    else {
		if ($v>=3) {print("Warning: no pdb code found in sequence name '$name'\n");} 
		close(QFILE);
		return 1; # no astral/DALI/pdb sequence => no dssp states available
	    }
	    $aas="";

	}
	else
	{
	    chomp($line);
	    $line=~tr/a-z \t/A-Z/d;
	    $aas.=$line;
	}
    }
    close(QFILE);
    if ($v>=2) {printf("\nSearching DSSP state assignments...\nname=%s  range=%s\n",$name,$qrange);}

    # Try to open dssp file 
    $dsspfile="$dsspdir/$pdbcode.dssp";
    if (! open (DSSPFILE, "<$dsspfile")) {
	printf(STDOUT "WARNING: Cannot open $dsspfile: $!\n"); 
	$pdbfile="$pdbdir/pdb$pdbcode.ent";
	if (! -e $pdbfile) {
	    printf(STDOUT "WARNING Cannot open $pdbfile: $!\n"); 
	    return 1;
	} else  {
	    &System("$dssp $pdbfile $dsspfile >> $base.log");
	    if (! open (DSSPFILE, "<$dsspfile")) {
		printf(STDERR "ERROR: dssp couldn't generate file from $pdbfile. Skipping $name\n");
		return 1;
	    } 
	}
    }

    #....+....1....+....2....+....3....+....4
    #  623  630 A R     <        0   0  280  etc. 
    #  624        !*             0   0    0  etc. 
    #  625    8 B A              0   0  105  etc. 
    #  626    9 B P    >>  -     0   0   71  etc. 
    #  292   28SA K  H  4 S+     0   0   71  etc.  (1qdm.dssp)
    #  293   29SA K  H  > S+     0   0   28  etc.    

    # Read in whole DSSP file
    for (my $try = 1; $try<=2; $try++) {
	$aa_dssp="";
	$ss_dssp="";
	while ($line=<DSSPFILE>) {if ($line=~/^\s*\#\s*RESIDUE\s+AA/) {last;}}
	while ($line=<DSSPFILE>) 
	{
	    if ($line=~/^.{5}(.{5})(.)(.)\s(.).\s(.)/)
	    {
		my $thisres=$1;
		my $icode=$2;
		my $chain=$3;
		my $aa=$4;
		my $ss=$5;
		my $contained=0;
		my $range=$qrange;  
		if ($aa eq "!")  {next;}    # missing residues!
		$thisres=~tr/ //d;
		$chain=~tr/ //d;
		$icode=~tr/ //d;
		if ($try==1) {
		    do{
			if    ($range=~s/^(\S):(-?\d+)[A-Z]-(\d+)([A-Z])// && $chain eq $1 && $icode eq $4 && $2<=$thisres && $thisres<=$3) {
			    $contained=1; #syntax (A:56S-135S)
			}
			elsif ($range=~s/^(\S):(-?\d+)[A-Z]?-(\d+)[A-Z]?// && $chain eq $1 && $2<=$thisres && $thisres<=$3) {
			    $contained=1; #syntax (R:56-135)
			}
			elsif ($range=~s/^(-?\d+)[A-Z]-(\d+)([A-Z])// && $chain eq "" && $icode eq $3 && $1<=$thisres && $thisres<=$2) {
			    $contained=1; #syntax (56-135)
			}
			elsif ($range=~s/^(-?\d+)[A-Z]?-(\d+)[A-Z]?// && $chain eq "" && $1<=$thisres && $thisres<=$2) {
			    $contained=1; #syntax (56-135)
			}
			elsif ($range=~s/^(\S):// && $chain eq $1) {
			    $contained=1; #syntax (A:) or (A:,2:)
			} 
			elsif ($range=~s/^-$// && $chain eq "") {
			    $contained=1; #syntax (-) 
			}
			$range=~s/^,//;
#			print("qrange=$qrange  range='$range'  ires=$thisres  chain=$chain contained=$contained\n");
		    } while($contained==0 && $range ne "");
		    if ($contained==0) {next;}
		} # end if try==1
		$aa_dssp.=$aa;
		$ss_dssp.=$ss;
	    }
	}
	# if not enough residues were found: chain id is wrong => repeat extraction without checking chain id 
	if (length($aa_dssp)>=10) {last;} 
	close(DSSPFILE);
	open (DSSPFILE, "<$dsspfile");
   }
    close(DSSPFILE);

    if (length($aa_dssp)==0) {print("WARNING: no residues found in $dsspdir/$pdbcode.dssp\n"); return 1;} 
    if (length($aa_dssp)<=20) {printf("WARNING: only %i residues found in $dsspdir/$pdbcode.dssp\n",length($aa_dssp)); return 1;} 

    # Postprocess $aa_dssp etc
    $aa_dssp =~ tr/a-z/CCCCCCCCCCCCCCCCCCCCCCCCCC/;
    $ss_dssp =~ tr/ I/CC/;
    $ss_dssp =~ s/ \S /   /g;
    $ss_dssp =~ s/ \S\S /    /g;

    # Align query with dssp sequence
    $aa_astr = $aas;
    $xseq=$aas;
    $yseq=$aa_dssp;
    my ($imax,$imin,$jmax,$jmin);
    my (@i,@j);
    my $score=&AlignNW(\$xseq,\$yseq,\@i,\@j,\$imin,\$imax,\$jmin,\$jmax,\$Sstr);  

    # Initialize strings (=arrays) for dssp states with "----...-"
    my @ss_dssp_ali=();   # $ss_dssp_ali[$i] is dssp state aligned to $aa_astr[$i] 
    my @aa_dssp_ali=();   # $aa_dssp_ali[$i] is dssp residue aligned to $aa_astr[$i] 
    for (my $i=0; $i<=length($aa_astr); $i++) { # sum up to len+1 
	                                        # because 0'th element in @ss_dssp and @aa_dssp is dummy "-" 
	$ss_dssp_ali[$i]="-";	
	$aa_dssp_ali[$i]="-";	
    }
    
    # To each residue (from i=0 to len-1) of input sequence $aa_astr assign aligned dssp state
    @ss_dssp = split(//,$ss_dssp);
    @aa_dssp = split(//,$aa_dssp);
    @aa_astr = split(//,$aa_astr);
    my $len = 0;
    unshift(@aa_dssp,"-"); #add a gap symbol at beginning -> first residue is at 1!
    unshift(@ss_dssp,"-"); #add a gap symbol at beginning -> first residue is at 1!
    unshift(@aa_astr,"-"); #add a gap symbol at beginning -> first residue is at 1!
    for (my $col=0; $col<@i; $col++) {
	if ($i[$col]>0) {
	    if ($j[$col]>0) {$len++;} # count match states (for score/len calculation)
	    $ss_dssp_ali[$i[$col]]=$ss_dssp[$j[$col]];
	    $aa_dssp_ali[$i[$col]]=$aa_dssp[$j[$col]];
	}
	if ($v>=4) {
	    printf ("%s %3i   %s %3i\n",$aa_astr[$i[$col]],$i[$col],$aa_dssp[$j[$col]],$j[$col]);
	}
    }
    shift (@ss_dssp_ali);   # throw out first "-" 
    shift (@aa_dssp_ali);   # throw out first "-" 
    $aa_dssp=join("",@aa_dssp_ali);
    $ss_dssp=join("",@ss_dssp_ali);

    # Debugging output
    if ($v>=3) {printf(STDOUT "DSSP: %4i  %s: length=%-3i  score/len:%-5.3f\n",$nfile,$name,$len,$score/$len);}
    if ($v>=4) {
	printf("IN:    %s\n",$xseq);
	printf("MATCH: %s\n",$Sstr);
	printf("DSSP:  %s\n",$yseq);
	printf("\n");
	printf(">ss_dssp $name\n$ss_dssp\n");
	printf(">aa_dssp $name\n$aa_dssp\n");
	printf(">aa_astra $name\n$aa_astr\n\n");
    }    
    if ($score/$len<0.5) {
	printf (STDOUT "\nWARNING: in $name ($nfile): alignment score with dssp residues too low: Score/len=%f.\n\n",$score/$len);
	return 1;
    }

#    printf(">ss_dssp\n$ss_dssp\n");
#    printf(">aa_dssp\n$aa_dssp\n");
    return 0;
}


##############################################################################################
# Run SS prediction starting from alignment in $base.psi (called by BuildAlignment)
##############################################################################################
sub RunPsipred() {
    # This is a simple script which will carry out all of the basic steps
    # required to make a PSIPRED V2 prediction. Note that it assumes that the
    # following programs are in the appropriate directories:
    # blastpgp - PSIBLAST executable (from NCBI toolkit)
    # makemat - IMPALA utility (from NCBI toolkit)
    # psipred - PSIPRED V2 program
    # psipass2 - PSIPRED V2 program

    my $infile=$_[0];
    my $basename;  #file name without extension
    my $rootname;  #basename without directory path
   
    if ($infile =~/^(.*)\..*?$/)  {$basename=$1;} else {$basename=$infile;}
    if ($basename=~/^.*\/(.*?)$/) {$rootname=$1;} else {$rootname=$basename;}

    # Does dummy database exist?
    if (!-e "$dummydb.phr") {print("WARNING: did not find $dummydb.phr... using $nr70f\n"); $dummydb=$nr70f; }

    # Start Psiblast from checkpoint file tmp.chk that was generated to build the profile
    &System("$blastpgp -b 0 -a $cpu -j 1 -h 0.001 -d $dummydb -i $infile -B $basename.psi -C $basename.chk > $basename.bla 2>&1");
    
#    print("Predicting secondary structure...\n");
    
    system("echo $rootname.chk > $basename.pn\n");
    system("echo $rootname.seq > $basename.sn\n");
    system("$ncbidir/makemat -P $basename");
    
    &System("$execdir/psipred $basename.mtx $datadir/weights.dat $datadir/weights.dat2 $datadir/weights.dat3 $datadir/weights.dat4 > $basename.ss");

    &System("$execdir/psipass2 $datadir/weights_p2.dat 1 0.98 1.09 $basename.ss2 $basename.ss > $basename.horiz");
    
    # Remove temporary files
    system ("rm -f $basename.pn $basename.sn $basename.mn $basename.mtx $basename.aux $basename.ss $basename.ss2");
    system ("rm -f $basename.chk $basename.bla");
    return;
}


################################################################################################
### Calculate number of sequences from alignhits return code (called by BuildAlignment)
################################################################################################
sub NHits() {
    if ($_[0]<110) {return $_[0];}
    elsif ($_[0]<210) {return ($_[0]-100)*10;}
    elsif ($_[0]<255) {return ($_[0]-200)*100;} 
    else              {return ">5500";}
}

################################################################################################
### Determine size of database last searched by PSI-BLAST
################################################################################################
sub SizeDB() {
    if (!$sizedb) {
	open(BLAFILE,"<$_[0]") || die ("Error: could not open $_[0] for reading: $!\n");
	while ($line=<BLAFILE>) {
	    if ($line=~/Database:/) {
		$line=<BLAFILE>;
		$line=~/^\s*(\S+) sequences/;
		$sizedb=$1;
		$sizedb=~tr/0-9//cd;
		last;
	    }
	}
	close(BLAFILE);
    }
    return $sizedb;
}

################################################################################################
### Execute blastpgp
################################################################################################
sub blastpgp() {
    if ($v>=2) {printf("\$ $blastpgp -a $cpu -b 20000 -v 1 %s > $_[1] 2>&1\n",$_[0]);} 
    if (system("$blastpgp -a $cpu -b 20000 -v 1 $_[0] > $_[1] 2>&1")) {
	die("Error: PSI-BLAST returned with error. Consults blast output in $_[1]\n\n");
    }
    return;
}

################################################################################################
### System command
################################################################################################
sub System()
{
    if ($v>=2) {printf("\$ %s\n",$_[0]);} 
    return system($_[0])/256;
}


