#! /usr/bin/perl -w
# Read in all globbed *.scores files, bin results and write out a table counts
# SCORE   TOT  FAM  SFAM  FOLD
# which lists how many pairs where found at the family, superfamily and fold level 
# with Maxsub or S3D scores at or above the given value
# Usage:   hhallbinali.pl [-ms|-comb|-s3d|-av] [-cum|-dens] fileglob outfile  
# Example: hhallbinali.pl -s3d '*.scores' scop20_cum3.dat   

use strict;

if (scalar(@ARGV)<2) {
    print("
 Read in all globbed *.scores files, bin results and write out a table with counts
 SCORE   TOT  FAM  SFAM  FOLD
 which lists how many best hits where found at or below the family, superfamily and fold level 
 with Maxsub or S3D or combined or average scores in each bin (-dens) or at or above the given value (-cum)
 Usage:   hhallbinali.pl [-ms|comb|-s3d|av] [-cum|-dens] fileglob outfile  
 Example: hhallbest.pl -ms -dens '*.scores' scop20_best1.dat
\n"); 
    exit;
}

# Constants/Parameters
my $NBINS=10;                # bins: 0,1,2,..,$NBINS ($NBINS+1 in all)
my $MIN=0.0;                 # left margin of smallest bin for -log10(P-value)
my $MAX=1.0;                 # left margin of largest bin for -log10(P-value)
my $DBIN=($MAX-$MIN)/$NBINS; # width of bins
my $FBIN=1/$DBIN;
my $MINLEN=40;               # minimum length for score=s3d
my $v=2;


# Variables
my $cum=1;                   # cumulate scores
my $score="ms";
while ($ARGV[0]=~/^-(\S+)$/) {
    if    ($1 eq "ms")   {$score=lc($1); shift(@ARGV); $FBIN*=0.1;}
    elsif ($1 eq "s3d")  {$score=lc($1); shift(@ARGV);}
    elsif ($1 eq "comb") {$score=lc($1); shift(@ARGV);}
    elsif ($1 eq "av")   {$score=lc($1); shift(@ARGV);}
    elsif ($1 eq "cum")  {$cum=1; shift(@ARGV);}
    elsif ($1 eq "dens") {$cum=0; shift(@ARGV);}
    else {die("Error: unknown option '$1'\n");}
}
my @files = glob($ARGV[0]); 
my $outfile = $ARGV[1];
my $infile;
my $line;
my $qlen;                    # length of query  
my $rel;                     # 4:same family  3:same superfam  2:same fold  1:same class  0:diff class
my $bin;                     # counts bins 
my @fam =(0)x($NBINS+1);     # number of homologs with score in bin
my @sfam=(0)x($NBINS+1);     # number of non-homologs with score in bin
my @fold=(0)x($NBINS+1);     # number of sequences with unknown relationship and with score in bin
my @diff=(0)x($NBINS+1);     # number of sequences with unknown relationship and with score in bin
my $nfiles; 
my $relmin=5;                # minimum relationship level seen so far
my $fold=0;
my $sfam=0;
my $fam=0;

#NAME  d12asa_ d.104.1.1 (A:) Asparagine synthetase {Escherichia coli}
#FAM   d.104.1.1
#FILE  d12asa_
#LENG  327
# 
#TARGET REL LEN COL RAW-SCORE SCORE   MS NALI
#d12asa_  5 327 327 995.13 938.93  10.00 327
#d1b8aa2  4 335 264  39.74  67.88   3.93 156


# Read each score file and bin scores
print (scalar(@files)." files read in ...\n");
$nfiles=0;
foreach $infile (@files) {   
    $nfiles++;
    if ($v>=3) {
	print("Reading $infile ($nfiles)\n");
    } elsif ($v==2 && !($nfiles%100)) {
	print("$nfiles\n");
    }
    $relmin=5; 
    open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");
    # Read query length
    while ($line=<INFILE>) {if ($line=~/^LENG\s/) {last;}};
    $line=~/LENG\s+(\d+)/;
    $qlen=$1;
    # Advance to title line
    while($line=<INFILE>) {if ($line=~/^TARGET\s\S+/) {last;} }
    # Read data
    while($line=<INFILE>) {
	#           TARGET   REL     LEN     COL  RAW-SCORE SCORE  MS-SCORE SUBLEN
	if ($line=~/^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/o) {
	    if ($2>=$relmin) {next;}  # go to next hit if relationship is not more remote than already found
	    $rel=$2;
#	    print($line);
	    
	    # Calculate score
	    if ($score eq "ms") {
		$bin = int(($7-$MIN)*$FBIN+0.5);
	    } elsif ($score eq "s3d") {
		if ($8>=$MINLEN) {
		    $bin = int(( (2*$8-$4)/&min($qlen,$3) -$MIN)*$FBIN+0.999);
		} else { $bin=0;}
#		printf("rel=%1i sublen=%-3i alilen=%-3i Lq=%-3i Lt=%-3i score=%5.2f bin=%i\n",$rel,$8,$4,$qlen,$3,(2*$8-$4)/&min($qlen,$3),$bin);
	    } elsif ($score eq "comb") {
		if ($8>=$MINLEN) {
		    $bin = int(( 2*$8/($4+&min($qlen,$3)) -$MIN)*$FBIN+0.999);
		} else { $bin=0;}
#		printf("rel=%1i sublen=%-3i alilen=%-3i Lq=%-3i Lt=%-3i score=%5.2f bin=%i\n",$rel,$8,$4,$qlen,$3,(2*$8-$4)/&min($qlen,$3),$bin);
	    } elsif ($score eq "av") {
		if ($8>=$MINLEN) {
		    $bin = int(( 0.5*$8*(1/&min($qlen,$3)+1/$4)  -$MIN)*$FBIN+0.999);
		} else { $bin=0;}
#		printf("rel=%1i sublen=%-3i alilen=%-3i Lq=%-3i Lt=%-3i score=%5.2f bin=%i\n",$rel,$8,$4,$qlen,$3,(2*$8-$4)/&min($qlen,$3),$bin);
	    } else {
		die ("Error: wrong score string \n\n");
	    }
	    
	    if ($bin>$NBINS) {$bin=$NBINS;} elsif ($bin<0) {$bin=0;}
	    
	    for (my $r=$rel; $r<$relmin; $r++) {
		if ($r==2) {
		    $fold[$bin]++;     # same fold
#		    $fold++;
#		    printf("fold=%3i  r=%1i  rel=%1i  relmin=%1i\n",$fold,$r,$rel,$relmin)
		} elsif ($r==3) {
		    $sfam[$bin]++;     # same superfamily
#		    $sfam++;
#		    printf("sfam=%3i  r=%1i  rel=%1i  relmin=%1i\n",$sfam,$r,$rel,$relmin)
		} elsif ($r==4) {	
		    $fam[$bin]++;      # same family
#		    $fam++;
#		    printf("fam=%3i   r=%1i  rel=%1i  relmin=%1i\n",$fam,$r,$rel,$relmin)
		}
	    }
	    $relmin=$rel;
	    if ($rel<=2) {last;} # stop if first hit at or below fold level found
	    
	}
    }
    close(INFILE);
}

# Print out binned score distribution
open(OUTFILE,">$outfile") or die("Error: cannot open $outfile: $!\n");
print(OUTFILE "SCORE   TOT   FAM  SFAM  FOLD\n");
for ($bin=$NBINS; $bin>=0; $bin--) {
    if ($cum) {
	$fam +=$fam[$bin];
	$sfam+=$sfam[$bin];
	$fold+=$fold[$bin]; 
    } else {
	$fam =$fam[$bin];
	$sfam=$sfam[$bin];
	$fold=$fold[$bin]; 
    }
    printf(OUTFILE "%5.2f %5i %5i %5i %5i\n",($bin-1)*$DBIN+$MIN,$fam+$sfam+$fold,$fam,$sfam,$fold);
}
close(OUTFILE);


# Minimum
sub min {
    my $min = shift @_;
    foreach (@_) {
	if ($_<$min) {$min=$_} 
    }
    return $min;
}

