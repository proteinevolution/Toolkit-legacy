#! /usr/bin/perl -w
# Read in all globbed *.scores files, bin results by score and write out a list
# with Score, TruePositives, and FalsePositives above Score.
# Usage:   hhallbin.pl fileglob outfile  
# Example: hhallbin.pl '*.scores' scop20_scores.dat   

use strict;

if (scalar(@ARGV)<2) {
    print("
Read in all globbed *.scores files, bin results by score and write out a list
with Score, TruePositives, and FalsePositives.
Usage:   hhallbin.pl fileglob outfile [options]  
Example: hhallbin.pl '*.scores' scop20_bin.dat    
\n"); 
    exit;
}

# Constants/Parameters
my $MINSCORE=0.5;              # minimum score up to which to bin results (speed-up)
my $MINMS=10.0;              # above this Maxsub score hit is true positive
my $UNKMS=10.0;              # above this Maxsub score hit is at least unknown (if not true positive)
my $POSREL=3;                # at or above this degree of relation hit is true positive
my $MAXREL=5;                # ignore all pairs with degree of relation at or above this value
my $NEGREL=1;                # all relationships with MS=0 at or below this level are considered negatives
my $NBINS=400;               # bins: 0,1,2,..,$NBINS ($NBINS+1 in all)
my $MIN=0;                   # left margin of smallest bin for -log10(P-value)
my $MAX=40;                  # left margin of largest bin for -log10(P-value)
my $DBIN=($MAX-$MIN)/$NBINS; # width of bins
my $MINLEN=0;                # minimum number of residues for query
my $Gough=0;
my $LOG2TO10=log(2)/log(10);
my $LOGETO10=1/log(10);



# Variables
my @files = glob($ARGV[0]); 
my $outfile = $ARGV[1];

if    ($outfile=~/bin3\..*dat/) {$MINMS=10.0; $UNKMS=10.0; $MAXREL=5; $POSREL=3; $NEGREL=0;} #fig-tpfp-a.pcm; Fig 2
elsif ($outfile=~/bin1\..*dat/) {$MINMS=1.0;  $UNKMS=0.0;  $MAXREL=5; $POSREL=3; $NEGREL=0;} #fig-tpfp-b.pcm; Fig 3
elsif ($outfile=~/bin2\..*dat/) {$MINMS=1.0;  $UNKMS=0.0;  $MAXREL=4; $POSREL=3; $NEGREL=0;} #fig-tpfp-c.pcm; Fig 4
elsif ($outfile=~/bin4\..*dat/) {$MINMS=10.0; $UNKMS=10.0; $MAXREL=4; $POSREL=3; $NEGREL=0;} #fig-tpfp-c.pcm; 
elsif ($outfile=~/bin5\..*dat/) {$MINMS=10.0; $UNKMS=10.0; $MAXREL=5; $POSREL=3; $NEGREL=1;} #Fig 2b
elsif ($outfile=~/bin6\..*dat/) {$MINMS=1.0;  $UNKMS=0.0;  $MAXREL=5; $POSREL=3; $NEGREL=1;} #Fig 3b
elsif ($outfile=~/bin7\..*dat/) {$MINMS=1.0;  $UNKMS=0.0;  $MAXREL=4; $POSREL=3; $NEGREL=1;} #Fig 4b
elsif ($outfile=~/bin8\..*dat/) {$MINMS=10.0; $UNKMS=10.0; $MAXREL=5; $POSREL=3; $NEGREL=1;} # TP:same sfam  FP:diff fold
elsif ($outfile=~/bin9\..*dat/) {$MINMS=10.0; $UNKMS=10.0; $MAXREL=5; $POSREL=2; $NEGREL=1;} # TP:same fold  FP:diff fold
elsif ($outfile=~/bin10\..*dat/) {$MINMS=10.0; $UNKMS=10.0; $MAXREL=5; $POSREL=3; $NEGREL=0;}# TP:same sfam  FP:diff class
elsif ($outfile=~/bin11\..*dat/) {$MINMS=10.0; $UNKMS=10.0; $MAXREL=5; $POSREL=2; $NEGREL=0;}# TP:same fold  FP:diff class
elsif ($outfile=~/bin0\..*dat/) {$Gough=1;} #fig-tpfp-c.pcm; Fig 4b
else {die("\nYou need to specify parameters MINMS, UNKMS, MAXREL, POSREL, and NEGREL first\n");}

my $infile;
my $line;
my $bin;                     # counts bins 
my @truepos =(0)x($NBINS+1); # number of homologs with score in bin
my @falsepos=(0)x($NBINS+1); # number of non-homologs with score in bin
my @unknown =(0)x($NBINS+1); # number of sequences with unknown relationship and with score in bin
my $sumtruepos=0;            # number of homologs with score > left margin of bin
my $sumfalsepos=0;           # number of non-homologs with score > left margin of bin
my $sumunknown=0;            # number of sequences with unknown relationship and with score > left margin of bin
my $log10Pval;               # log10(Pvalue)
my $n; 
my $query;                   # name of query
my $template;                # name of template
my %fam;                     # $fam{$scopid} = scop family code
my $famq;                    # family code of query
my $famt;                    # family code of template
my $len;                     # length of query
my $MS;                      # Maxsub score
my $REL;                     # relationship degree
my $s1;
my $sraw;


# Read each score file and bin scores
print (scalar(@files)." files read in ...\n");
$n=0;
foreach $infile (@files) {   
    $n++;
    if ($n%100 == 0) {print("$n\n");}
#    print("Reading $infile ($n)\n");
    
    my ($base,$root);
    my %Eval=();
    my %Pval=();
    my %score=();
    if ($infile =~/^(.*)\..*?$/) {$base=$1;} else {$base=$infile;} # get basename for file
    if ($base =~/.*\/(.*?)$/) {$root=$1;} else {$root=$base;} # rootname = basename without path

    open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");
    # Read query name
    while($line=<INFILE>) {if ($line=~/^NAME\s+(\S+)\s+(\S+)/) {$query=$1; $famq=$2; last;} }

#    while($line=<INFILE>) {if ($line=~/^LENG\s+(\S+)/) {$len=$1; last;} }
#    if ($len<=$MINLEN) {next;} # Query too short?

    # Advance to title line
    while($line=<INFILE>) {if ($line=~/^TARGET\s+(\S+)/) {last;} }
    # Read data
    while($line=<INFILE>) {

#                   TARGET    FAMILY  REL     LEN     COL   LOG-PVA  S-AASS  PROBAB SCORE
#                   TARGET    FAMILY  REL     LEN     COL   LOG-PVA  S-AASS  PROBAB    MS    NALI
#                   d153l__   d.2.1.5   5     185     185   418.121  550.39  100.00 10.00      31
	if ($line=~/^(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s*(\S*)/) {
#	if ($line=~/^(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
	    $template=$1;
	    $famt=$2;
	    $REL=$3;
#	    $MS=$9;
	    if (!$MS) {$MS=0;}
#	    if ($REL>=5 && $MS<9.0) {printf("WARNING: in $infile MaxSub score for self-hit is only %5.2f\n",$MS);} # Skip identical HMMs
	    if ($REL>=$MAXREL) {next;} # Skip identical HMMs

#	    $log10Pval=$7;
	     $log10Pval=0.5*$LOG2TO10*$6;
#	     $log10Pval=$7*$LOG2TO10*0.2;
#            $log10Pval=$7*$LOG2TO10; # including SS
#            $log10Pval=($7-3)*0.45*$LOGETO10;
#	    $log10Pval=0.5*$LOG2TO10*$9;

	    if ($log10Pval<$MINSCORE) {last;} # Minimum score reached?
#	    if ($7>=8.5 && defined $pval1{$template}) {$log10Pval=-log($pval1{$template}+1E-100)*$LOGETO10;}
#	    if ($7>=8.5 && defined $pval2{$template}) {$log10Pval=-log($pval2{$template}+1E-100)*$LOGETO10;}
#	    if ($7>=8.5 && defined $score{$template}) {$log10Pval=$score{$template}*$LOG2TO10*0.4;}
		
#	    if (! defined $pval1{$template}) {printf("%s  %s  %6.2f  %6.2f\n",$query,$template,$6,0.4*$5); last;}
#	    $s1=-log($pval1{$template}+1E-100)*$LOGETO10;
#	    $sraw=0.4*$6*$LOG2TO10;
#	    if ($s1<99 && ($s1>1.5*$sraw || $sraw>1.9*$s1)) {
#		printf("%s  %s  %6.2f    %6.2f  %6.2f  %6.2f  %6.2f  %6.2f\n",$query,$template,$s1/$sraw,-log($pval1{$template}+1E-100)*$LOGETO10,-log($pval2{$template}+1E-100)*$LOGETO10,$7*$LOG2TO10,0.4*$score{$template}*$LOG2TO10,0.4*$5*$LOG2TO10);
#	    }
	    
	    $bin= int(($log10Pval-$MIN)/$DBIN);
#	    printf("%s  %s  %6.2f    %6.2f  %6.2f  %6.2f  %6.2f  %6.2f\n",$famq,$famt,$REL,$log10Pval,$bin,);
	    if ($bin<0) {$bin=0;} elsif ($bin>$NBINS) {$bin=$NBINS;}

	    if ($Gough) {
		my $tpfp=&Criteria($fam{$query},$fam{$template});
		if ($tpfp==1) {
		    $truepos[$bin]++;  # true positive
		} elsif ($tpfp==-1) {
		    $falsepos[$bin]++; # false positive
		} else {
		    $unknown[$bin]++;  # unknown relationship
		}

	    } else {

		if ($REL<=$NEGREL && $MS<=$UNKMS) {
#		    $famt=$fam{$template};
		    if ($famq=~/^b\.(66|67|68|69|70)/ && $famt=~/^b\.(66|67|68|69|70)/) {
			$unknown[$bin]++;  # unknown
		    } elsif  ($famq=~/c\.(2|3|4|5|30|66|78|79|111)\./  && $famt=~/c\.(2|3|4|5|30|66|78|79|111)\./) {
			$unknown[$bin]++;  # unknown
		    } else {
			$falsepos[$bin]++; # false positive
		    }
		} elsif ($MS>=$MINMS || $REL>=$POSREL) {
		    $truepos[$bin]++;  # true positive
		} elsif (0) {
		    $famt=$fam{$template};
		    if ($famq=~/^b\.(67|68|69|70)/ && $famt=~/^b\.(67|68|69|70)/) {
			$truepos[$bin]++;  # true positive
		    } elsif  ($famq=~/c\.(2|3|4|5|30|66|78|79|111)\.1\./  && $famt=~/c\.(2|3|4|5|30|66|78|79|111)\.1\./) {
			$truepos[$bin]++;  # true positive
		    } elsif  ($famq=~/c\.(23\.9|69\.1)\./  && $famt=~/c\.(23\.9|69\.1)\./) {
			$truepos[$bin]++;  # true positive
		    } elsif  ($famq=~/c\.(23\.12|2\.1)\./  && $famt=~/c\.(23\.12|2\.1)\./) {
			$truepos[$bin]++;  # true positive
		    } elsif  ($famq=~/d\.(51|52)\./  && $famt=~/d\.(51|52)\./) {
			$truepos[$bin]++;  # true positive
		    } elsif  ($famq=~/c\.(93|89)\.1\./  && $famt=~/c\.(93|89)\.1\./) {
			$truepos[$bin]++;  # true positive
		    } elsif  ($famq=~/c\.1\./  && $famt=~/c\.1\./) {
			$truepos[$bin]++;  # true positive
		    } else {
			$unknown[$bin]++;  # unknown relationship
		    }
		} else {
		    $unknown[$bin]++;  # unknown relationship
		}
	    }
	}
    }
    close(INFILE);
}

# Print out binned score distribution
open(OUTFILE,">$outfile") or die("Error: cannot open $outfile: $!\n");
print(OUTFILE "log10(P)     TP       FP  Unknown       TP       FP  Unknown\n");
for ($bin=$NBINS; $bin>=0; $bin--) {
    $sumtruepos +=$truepos[$bin];
    $sumfalsepos+=$falsepos[$bin];
    $sumunknown +=$unknown[$bin];
    printf(OUTFILE "%8.2f %6i %8i %8i   %6i %8i %8i\n",$bin*$DBIN+$MIN,$sumtruepos,$sumfalsepos,$sumunknown,$truepos[$bin],$falsepos[$bin],$unknown[$bin]);
}
close(OUTFILE);
exit(0);

sub Criteria{
#1.65 version
#Takes as an input two SCOP classifications, and returns a flag. 
#1 if they're the same, 0 if it's ambiguous, and -1 if they're different
my $flag=-1;
my $one=$_[0];
my $two=$_[1];
my $cf1;
my $cf2;
my $sf1;
my $sf2;
my $fa1;
my $fa2;
my %rossmann=('c.2',0,'c.3',0,'c.4',0,'c.5',0,'c.27',0,'c.28',0,'c.30',0,'c.31',0);
#these all have notes in SCOP

if ($one =~ /^(\w\.\d+)(\.\d+)(\.\d+)/){
$fa1="$1$2$3";
$sf1="$1$2";
$cf1="$1";
}
else{
print STDERR "Error parsing classification: $one\n";
}
if ($two =~ /^(\w\.\d+)(\.\d+)(\.\d+)/){
$fa2="$1$2$3";
$sf2="$1$2";
$cf2="$1";
}
else{
print STDERR "Error parsing classification: $two\n";
}

#Same fold ambiguous
if ($cf1 eq $cf2){
$flag=0;
}
#plain right
if ($sf1 eq $sf2){
$flag=1;
}

#Fixed as of SCOP 1.63!
##Unless Membrane all-alpha
#if (($sf1 eq 'f.2.1' or $sf2 eq 'f.2.1') and $fa1 ne $fa2){
#$flag=-1;
#}

#TIM barrels
#first 7 similar -note in SCOP-
if (($sf1 eq 'c.1.1' or $sf1 eq 'c.1.2' or $sf1 eq 'c.1.3' or $sf1 eq 'c.1.4' or $sf1 eq 'c.1.5' or $sf1 eq 'c.1.6' or $sf1 eq 'c.1.7') and ($sf2 eq 'c.1.1' or $sf2 eq 'c.1.2' or $sf2 eq 'c.1.3' or $sf2 eq 'c.1.4' or $sf2 eq 'c.1.5' or $sf2 eq 'c.1.6' or $sf2 eq 'c.1.7')){
$flag=1;
}
elsif (($cf1 eq 'c.1' and $cf2 eq 'c.1')){
$flag=0;
}

#Rossmann-like
if (exists($rossmann{$cf1}) and exists($rossmann{$cf2})){
if ($cf1 eq $cf2){
$flag=1;
}
else{
$flag=0;
}
}
#Nah! Julian thinks now it's a grower, since 1.63
##as of 1.57  c.23.12 looks like superposes OK
#if ((exists($rossmann{$cf1}) and $sf2 eq 'c.23.12') or (exists($rossmann{$cf2}) and $sf1 eq 'c.23.12')){
#$flag=1;
#}
#Old note -correspondance checked-
#1ykf, residues 151-314 superpose with 1eiz: 2.26382 ANGSTROMS/ATOM over 98 residues
if ((exists($rossmann{$cf1}) and $cf2 eq 'c.66') or (exists($rossmann{$cf2}) and $cf1 eq 'c.66')){
$flag=0;
}
#1lvh superposes with 1ek6 to 2.19488 ANGSTROMS/ATOM over 88 residues(same topology), BUT is VERY different
if ((exists($rossmann{$cf1}) and $cf2 eq 'c.108') or (exists($rossmann{$cf2}) and $cf1 eq 'c.108')){
$flag=0;
}
#Can't find it and there are no cross-hits anyway.
##Old note -correspondance checked-
#if ((exists($rossmann{$cf1}) and $cf2 eq 'c.32') or (exists($rossmann{$cf2}) and $cf1 eq 'c.32')){
#$flag=0;
#}
#note: the ATP nucleotide-binding site is similar to that of the NAD-binding Rossmann-folds
if ((exists($rossmann{$cf1}) and $sf2 eq 'c.111.1') or (exists($rossmann{$cf2}) and $sf1 eq 'c.111.1')){
$flag=0;
}

#Other rules
#beta propellors 4-8 blades
if (($cf1 eq 'b.66' or $cf1 eq 'b.67' or $cf1 eq 'b.68' or $cf1 eq 'b.69' or $cf1 eq 'b.70') and ($cf2 eq 'b.66' or $cf2 eq 'b.67' or $cf2 eq 'b.68' or $cf2 eq 'b.69' or $cf2 eq 'b.70')){
if ($cf1 eq $cf2){
$flag=1;
}
else{
$flag=0;
}
}
#Note in SCOP, Similar in architecture but partly differs in topology
if (($cf1 eq 'c.94' and $cf2 eq 'c.93') or( $cf2 eq 'c.94' and $cf1 eq 'c.93')){
$flag=0;
}
#Cutinase-like
if (($sf1 eq 'c.23.9' and $sf2 eq 'c.69.1') or ($sf2 eq 'c.23.9' and $sf1 eq 'c.69.1')){
$flag=0;
}
#This re-classified in 1.63
#if (($fa1 eq 'f.2.1.10' and $sf2 eq 'c.108.1') or ($fa2 eq 'f.2.1.10' and $sf1 eq 'c.108.1')){
#$flag=1;
#}
#Very similar alpha super-helix
if (($sf1 eq 'a.118.8' and $sf2 eq 'a.118.6') or ($sf2 eq 'a.118.8' and $sf1 eq 'a.118.6')){
$flag=0;
}
#Similar motif sulphur binding
if (($sf1 eq 'd.58.1' and $sf2 eq 'a.1.2') or ($sf2 eq 'd.58.1' and $sf1 eq 'a.1.2')){
$flag=0;
}
#OK note in SCOP one of the previous cases
if (($sf1 eq 'a.137.4' and $sf2 eq 'c.96.1') or ($sf2 eq 'a.137.4' and $sf1 eq 'c.96.1')){
$flag=0;
}
#OK same fold and general look
if (($sf1 eq 'b.42.5' and $sf2 eq 'b.42.1') or ($sf2 eq 'b.42.5' and $sf1 eq 'b.42.1')){
$flag=0;
}
#Leucine rich repeats both of them,  structures look the same OK
if (($sf1 eq 'c.10.1' and $sf2 eq 'c.10.2') or ($sf2 eq 'c.10.1' and $sf1 eq 'c.10.2')){
$flag=0;
}
#Obvious sequence homology with blast,  one is beta-beta-alpha superhelix,  and one is beta-alpha togethor in PFAM
if (($sf1 eq 'c.11.1' and $sf2 eq 'c.10.2') or ($sf2 eq 'c.11.1' and $sf1 eq 'c.10.2')){
$flag=0;
}
#Obvious sequence homology with blast,  one is beta-beta-alpha superhelix,  and one is beta-alpha togethor in PFAM
if (($sf1 eq 'c.11.1' and $sf2 eq 'c.10.1') or( $sf2 eq 'c.11.1' and $sf1 eq 'c.10.1')){
$flag=0;
}
#Note in SCOP, contains P-loop
if (($sf1 eq 'c.91.1' and $sf2 eq 'c.37.1') or( $sf2 eq 'c.91.1' and $sf1 eq 'c.37.1')){
$flag=0;
}
#Note in SCOP, shared motif
if (($sf1 eq 'd.51.1' and $sf2 eq 'd.52.3') or( $sf2 eq 'd.51.1' and $sf1 eq 'd.52.3')){
$flag=0;
}
#Note in SCOP: variant of beta/alpha barrel
if (($cf1 eq 'c.6' and $cf2 eq 'c.1') or( $cf2 eq 'c.6' and $cf1 eq 'c.1')){
$flag=0;
}
#Note in SCOP, possible link
if (($sf1 eq 'a.24.1' and $sf2 eq 'a.63.1') or( $sf2 eq 'a.24.1' and $sf1 eq 'a.63.1')){
$flag=0;
}
#-----------------------------------

return ($flag);
}
