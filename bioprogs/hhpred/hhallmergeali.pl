#!/usr/bin/perl 
# Binary custering all hhm files in current directory with UPGMD (*.scores files must already exist) 
# with an E-value cut-off of $Emax and generation of new hhm and scores files for each node in UPGMD forest. 
# During program runtime, tmp/ contains all hhm files that have been replaced by node HMMs.
# After termination, original hhm files are back in current dir and complemented by HMMs for 
# each node generated in forest

use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/bioprogs/hhpred";  # forchimaera  webserver: MyPaths.pm
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with path variables for nr, blast, psipred, pdb, dssp etc.
use Align;

$|= 1; # Activate autoflushing on STDOUT

# Default values:
our $v=2;            # verbose mode
my $Pmax=1e-7;       # maximum P-value for merging alignments
my $SMIN=9.0;        # minimum total score (for speed-up)
my $scoresdir;       # directory with *.scores files
my $tmpdir="./TMP";  # directory where merged HMMs are temporarily moved
my $usage="
 Binary custering of all hhm files in current directory with UPGMA (*.scores files must already exist) 
 with an P-value cut-off of $Pmax and generation of new hhm and scores files for each node in UPGMA forest. 
 During program runtime, tmp/ contains all hhm files that have been replaced by node HMMs.
 After termination, original hhm files are back in current dir and complemented by HMMs for 
 each node generated in forest

 Usage: hhallmergeali.pl -d <dir> [options]
  
 Options:
  -d <dir>    directory with *.scores files
  -p <value>  P-value threshold for binary clustering; below this E-value, HMMs will be merged (default=$Pmax)
  -v <int>    verbose mode
\n";

if (@ARGV<1) {die ($usage);}

my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}
print("$0 $options\n");

# General options
if ($options=~s/ -d\s*(\S+) //g) {$scoresdir=$1;}
if ($options=~s/ -p\s*(\S+) //g) {$Pmax=$1;}
if ($options=~s/ -v\s*(\d) //g) {$v=$1;}
if ($options=~s/ -v //g)        {$v=2;}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}

if ($scoresdir eq "") {print($usage); die("Error: you must supply a directory containing the *.scores files\n");}

my $v2 = $v-1;
if ($v2>2) {$v2=2;}
if ($v2<0) {$v2=0;}

my $logPmin = -1.4426*log($Pmax);
my %logP;           # hash containing log P-value for each pair of HMMs, $name1.$name2
my %lname;          # $lname{name} = SCOP-ID and SCOP family code of HMM name: 'd12asa_ d.104.1.1'
my %fam;            # $fam{name} = SCOP family code of HMM name: 'd.104.1.1'
my %len;            # $len{name} = len of HMM name
my $i=0;            # counts pairs of HMMs       
my $line;           # line read from input
my $name1;          # first name of HMM
my $name2;          # first name of HMM
my @name1;          # first name of pairs of HMMs
my @name2;          # second name of pairs of HMMs
my @logP;           # log P-value of pairs of HMMs 
my $i;
my $j; 
my $id;             # sequence identity threshold for filtering

if (! -e $tmpdir) {&System("mkdir $tmpdir");}
if (! -e "db") {&System("mkdir db; cat *.hhm > db/scop.hhm");}

# Read all *.scores files and store pairs of HMMs plus their pairwise log P-value
if ($v>=2) {print("Globbing $scoresdir/*.scores ...\n");}
my @scorefiles=glob("$scoresdir/*.scores");
if ($v>=2) {printf("%i files found\n",scalar(@scorefiles));}
if ($v>=2) {print("Reading scores files ...\n");}
foreach my $scoresfile (@scorefiles) {
    if ($v>=4) {print("Reading $scoresfile\n");}
    open(INFILE,"<$scoresfile") || die("Error: can't open $scoresfile for reading: $!\n");
    $line=<INFILE>;   
    $line=~/^NAME\s+(\S+)/;
    $name1=$1;
    $line=<INFILE>;   
    $line=~/^FAM\s+(\S+)/;
    $fam{$name1}=$1;
    $lname{$name1}="$name1 $1";
    $line=<INFILE>;   
    $line=<INFILE>;   
    $line=~/^LENG\s+(\S+)/;
    $len{$name1}=$1;
    <INFILE>; # blank line
    <INFILE>; # TARGET REL LEN COL ...
    <INFILE>; # self hit
    while ($line=<INFILE>) {
	$line=~/^(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)/;
	if ($2<$SMIN) {last;}  # skip lines with low total scores to accelerate reading
	if (defined $logP{"$1:$name1"}) {
	    $logP{"$1:$name1"}=0.5*($logP{"$1:$name1"}+$3);
	    if ($v>=4) {printf("name1=%-9.9s    name2=%-9.9s  logP = 0.5*(%7.2f + %7.2f) = %7.2f\n",$name1,$1,$3,$logP{"$1:$name1"},0.5*($logP{"$1:$name1"}+$3));}
	} else {
	    $logP{"$name1:$1"}=$3; 
	}
    }
    close(INFILE);
}
if ($v>=3) {printf("Read %i pairs of HMMs with total scores above %f-4.1\n",scalar(keys(%logP)),$SMIN);}


# Make arrays of pairs of HMMs with log P-value better than threshold
my $n=0;            # total number of pairs of HMMs in @name1, @name2, @logP
if ($v>=4) {print("\n  Nr  name1     len    name2     len     logP\n");}
foreach my $pair (keys(%logP)) {
    if ($logP{$pair}>=$logPmin) {
	$logP[$n]=$logP{$pair};
	$pair=~/^(.*):(.*)/;
	if (! -e "$1.hhm" || ! -e "$2.hhm") {next;}
	# Store longer of two HMMs as second name
	if ($len{$1} < $len{$2}) {
	    $name1[$n]=$1;
	    $name2[$n]=$2;
	} else {
	    $name1[$n]=$2;
	    $name2[$n]=$1;
	}
	if ($v>=4) {printf("%4i  %-9.9s %3i    %-9.9s %3i  %7.2f\n",$n,$name1[$n],$len{$name1[$n]},$name2[$n],$len{$name2[$n]},$logP[$n]);}
	$n++;
    }
}
if ($v>=3) {printf("Found %i pairs of HMMs with P-value below %f\n",$n,$Pmax);}



##########################################################################################
# While there are still pairs of HMMs in @name1, @name2 that can be merged ...
while (@logP) {
    
    # Determine largest logP
    my $max=$logP[0];
    my $imax=0;
    for($i=1; $i<@logP; $i++) {if ($logP[$i]>$max) {$imax=$i; $max=$logP[$i];}}
    $name1=$name1[$imax]; 
    $name2=$name2[$imax]; 
    if ($v>=2) {
	printf("\n\nPairs left: %i\n",scalar(@logP));
	printf("name1=%s    name2=%s  logP=$max i=$imax\n",$lname{$name1},$lname{$name2});
    }
    if ($name1 eq "" || $name2 eq "") { 
	splice(@name1,$imax,1);
	splice(@name2,$imax,1);
	splice(@logP,$imax,1);
	print("WARNING: one of the names is empty!\n\n\n");
	next;
    }

    # Align $name1.a3m to $name2
    my $k;
    my $base2;          # name2 without extension
    if ($name2=~/^(.*)-(\d+)/) {$base2=$1; $k=$2+1;} else {$base2=$name2; $k=1;}
    my $new="$base2-$k";
    &System("cp $name2.a3m $new.a3m");

    # Change name of $new.a3m
    open (NEWALI,"<$new.a3m") || die("Error: can't open $new.a3m: $!\n");
    my @lines=<NEWALI>;
    close(NEWALI);
    for ($i=0; $i<@lines && $lines[$i]!~/^>$name2 /; $i++) {}
    $lname{$new}="{$lname{$name2}, $lname{$name1}}";
    $lines[$i]=">$new $fam{$new} $lname{$new}\n";
    open (NEWALI,">$new.a3m") || die("Error: can't open $new.a3m: $!\n");
    print (NEWALI @lines);
    close(NEWALI);

    # Align and append name1 to name2 and 
    &System("$hh/hhalign -i $name1.a3m -t $name2.hhm -aa $new.a3m -shift -0.1 -v $v2");

    # Determine number of sequences in $new.a3m
    my $nseqs=scalar(@lines);
    open(ALI,"<$name1.a3m") || die("Error: could not open $name1.a3m for counting sequences: $!\n");
    @lines=<ALI>;
    close(ALI);
    $nseqs+=scalar(@lines);   
    if ($nseqs<100) {$id=90;}
    elsif ($nseqs<500) {$id=80;}
    elsif ($nseqs<5000) {$id=70;}
    elsif ($nseqs<10000) {$id=60;}
    else {$id=50;}

    # Filter and make HMM
    &System("$hh/hhfilter -i $new.a3m -o $new.a3m -id $id -v $v2");
    &System("$hh/hhmake   -i $new.a3m -o $new.hhm -id 101 -v $v2");


    # Move merged alignments to tmp directory and updated db.hhm
    &System("mv $name1.hhm $tmpdir/");
    &System("mv $name2.hhm $tmpdir/");
    &System("rm db/db.hhm");
    &System("cat *.hhm > db/db.hhm");
    
    # Remove all pairs from @name1, @name2, @logP which contain $name1 or $name2
    $j=0;
    for($i=0; $i<@logP; $i++) {
	if ($name1[$i] ne $name1 && $name1[$i] ne $name2 && $name2[$i] ne $name1 && $name2[$i] ne $name2) {
	    $name1[$j]=$name1[$i];
	    $name2[$j]=$name2[$i];
	    $logP[$j] =$logP[$i];
	    $j++;
	}
    }
    splice(@name1,$j);
    splice(@name2,$j);
    splice(@logP,$j);

    # Search db.hhm
    &System("$hh/hhsearch -cpu 2 -i $new.hhm -d db/db.hhm -o $scoresdir/$new.hhr -scores $scoresdir/$new.scores -shift -0.15 -ssm 4 -v $v2");
    
    # Add all pairs with P-values better than threshold (name2 has to be longer than name1!)
    open(INFILE,"<$scoresdir/$new.scores") || die("Error: can't open $scoresdir/$new.scores for reading: $!\n");
    <INFILE>; # NAME
    <INFILE>; # FAM
    <INFILE>; # FILE
    <INFILE>; # LENG
    <INFILE>; # 
    <INFILE>; # TARGET REL LEN COL ...
    <INFILE>; # self hit
    my $len=$len{$new}=$len{$name2};
    while ($line=<INFILE>) {
	$line=~/^(\S+)\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)/;
	if ($2<9) {last;}  # skip lines with low total scores to accelerate reading
	if ($3>=$logPmin) {
	    if ($len<$len{$1}) {
		push(@name1,$new);
		push(@name2,$1);
	    } else {
		push(@name2,$new);
		push(@name1,$1);
	    }
	    push(@logP,$3);
	}
    }

    if ($v>=4) {
	print("\n  Nr  name1     len    name2     len     logP\n");
	for($n=0; $n<@logP; $n++) {
	    printf("%4i  %-9.9s %3i    %-9.9s %3i  %7.2f\n",$n,$name1[$n],$len{$name1[$n]},$name2[$n],$len{$name2[$n]},$logP[$n]);
	}
    }

}

&System("mv $tmpdir/*.hhm .");
exit;


##########################################################################################
### System command
################################################################################################
sub System()
{
    if ($v>=2) {printf("%s\n",$_[0]);} 
    return system($_[0])/256;
}

