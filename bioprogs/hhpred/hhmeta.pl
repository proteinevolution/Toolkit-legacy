#!/usr/bin/perl -w
# Read all matches in HHsearch results file, do all-against-all structure comparison with TM-align 
# and build a forest of trees with UPGMA. For each node in the forest, construct a multiple structural
# alignment of its templates by MAMMOTH-mult. Create a super-HMM by merging the individual template
# alignments into a super-alignment. The output is the set of super-HMMs and super-alignments,
# as well as links to the original HMMs and alignments.

my $rootdir;
BEGIN {
    if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} else {$rootdir="/cluster";}
};
use lib "$rootdir/bioprogs/hhpred";
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm

use strict;
use MyPaths;                         # config file with path variables for nr, blast, psipred, pdb, dssp etc.

# Default values
our $v=2;                     # verbose mode
my $TMmin=0.0;                # minimum TMscore needed to merge nodes
my $TMminc=0.7;               # minimum TMscore needed to merge nodes
my $TMalign="$bioprogs_dir/TMalign/TMalign";
my $mustang="$bioprogs_dir/MUSTANG_v.3/bin/MUSTANG_v.3";
my $caldb  ="$database_dir/hhpred/cal.hhm";
my $Z=20;                     # use only the first $Z hits from hhr file

my $usage="
 Read all matches in an HHsearch results file, do all-against-all structure comparison with TM-align 
 for clustering and build a forest of trees with UPGMA (threshold: TMscore>$TMminc). For each non-leaf 
 node in the forest, construct a multiple structural alignment of its templates by MAMMOTH-mult. 
 Create one or n super-HMMs for each tree or node with n leaves (depending on mode -mode <int>),
 by merging the individual template alignments into a super-alignment. The output is the set of 
 diff-100 filtered leaf and super-alignments together with their HMMs. 
 Optionally, the hhsearch results against this new database can be realigned globally, keeping the 
 ranking and scores unchanged.

 Usage: hhmeta.pl -i <file.hhr>  -o <basename> [options] 
  -i <file.hhr>         HHsearch results file containing the names and paths of templates 
  -o <basename>         basename for all output files (a3m and HMM files of all nodes, hhr results file)
  -r <options>          realign with specific hhalign options without changing order of hits (must be last option)
  -m <int> [<int> ...]  generate a PIR alignment for matches with specified indices (default = no alignment)
  -Z <int>              use only the first <int> hits from hhr file [def=$Z]
  -v <int>              verbose mode (0: no output, 1: minimal output, 2,3..: verbose) (default=$v)
  -mode 0               generate 1 HMM  per node
  -mode 1 (-c)          generate 1 HMM  per tree by using alignment of topmost node only; 
  -mode 2 (-p)          generate n HMMs per node with n leafs by permuting each template in turn to the top
  -mode 3 (-pc)         generate n HMMs per tree by using alignment of topmost node only and permuting [default] 
  -calt                 use template score calibration instead of query score calibration 
\n";

# Variable declarations
my $infile;             # input file
my $inbase;             # base name of input file
my $outbase;            # output basename
my $outroot;            # output rootname
my $outdir;             # directory of output basename
my $line;
my $command;
my @name;               # names of templates read from $infile
my @file;               # base file names of templates read from $infile
my @leng;               # lengths of templates read from $infile
my @TMscore;            # $TMscore[$i][$j] = TM-score between templates i and j
my @node;               # $node[$k] contains list of template indices below node $k of the forest. 
                        # Node index $k is smallest index of contained template 
my ($i,$j);             # template indices
my ($k,$l);             # node indices
my $N;                  # number of templates found in $infile = number of leaf nodes in forest
my $M;                  # indices of non-leaf nodes in forest will be from $N to $M-1
my $dirs;               # string with concatenated directories where to find the pdb and a3m files
my $queryfile;          # queryfile of the input HHR-search
my %name2i;             # e.g. $name2i{"d1vioa2"}=3
my $realign_options=""; # hhalign options for realignment step at the end
my $pickhits;           # string with indices of matches to generate PIR files from 
my $mode=3;             # 0: one HMM per node  1: n HMMs per node with n leafs 2: one HMM per tree 3:n HMMs per tree with n leafs 
my $calt="";            # use template score calibration?
my $use_hhalign=0;

###############################################################################################
# Processing command line input

if (@ARGV<1) {die ($usage);}
my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# General options
if ($options=~s/ -v\s*(\d) / /) {$v=$1;}
if ($options=~s/ -v / /) {$v=2;}
if ($v>=3) {print("$0 $options\n");}
if ($options=~s/ -i\s*(\S*) //) {$infile=$1;}
if ($options=~s/ -o\s*(\S*) //) {$outbase=$1;}
if ($options=~s/ -r\s*(\S.*\S) //)  {$realign_options=$1;}
if ($options=~s/ -m\s+((\d+\s+)+)//g) {$pickhits=$1; }
if ($options=~s/ -mode\s+(\d) //g) {$mode=$1;}
if ($options=~s/ -p //g) {$mode=1;}
if ($options=~s/ -c //g) {$mode=2; $TMmin=-log(2*(1.0001-$TMminc));}
if ($options=~s/ -pc //g) {$mode=3; $TMmin=-log(2*(1.0001-$TMminc));}
if ($options=~s/ -calt //g) {$calt="-calm 1";}
if ($options=~s/ -hh //g) {$use_hhalign=1;}

# Warn if unknown options found
while ($options=~s/\s*(\S.*)//) {print("WARNING: unknown options $1\n");}
if (!defined $infile)  {die("Error: not input file name given\n");}
if (!defined $outbase) {die("Error: not output base name given\n");}
if ($outbase=~/^(.*?)\/([^\/]*)$/) {$outdir=$1; $outroot=$2} else {$outdir="."; $outroot=$outbase;}
if ($infile=~/^(.*)\.[^\.]*$/) {$inbase=$1;} else {$inbase=$infile;}

###############################################################################################
# Read infile

if ($v>=2) {print("\nReading $infile ...\n");}
 
open (INFILE,"<$infile") or die("Error in $0: can not open $infile: $!\n"); 

# Read template directories
while ($line=<INFILE>) { if ($line=~/^Command\s+\S*hhsearch/) {last;} }
$line=~/ -i\s+(\S+) /;
$queryfile = $1;
$line=~/ -d\s+(.*?) -/ || $line=~/ -d\s+(.*)\s*$/; 
$dirs=$1;
$dirs =~s/\/db\/\S+\.hhm//g;
my @dirs = split(/\s+/,$dirs);

# Update paths e.g. for pdb70_<date>
for (my $i=0; $i<@dirs; $i++) {
    if (!-e $dirs[$i]) {
	if ($dirs[$i]=~/(\S*)\/(\S+)_\d\S{0,8}/) { # found version string
	    my @d = glob($1."/".$2."_*");
	    if (@d==0) {die("Error in hhmeta.pl: new version of directory $dirs[$i] could not be globbed\n");}
	    $dirs[$i] = $d[$#d]; # use updated name
	} else {
	    printf("WARNING in hhmeta.pl: directory %s not found\n",$dirs[$i]);
	}
    }
}


# Read template names
$N=0; # number of templates found
while ($line=<INFILE>) { if ($line=~/^\s+No Hit  /) {last;} }
while (defined($line=<INFILE>) && $N<$Z) {
    if ($line=~/^\s*$/) {last;} 
    $line=~/^\s*\d+\s+(\S+).*\((\d+)\)\s*/ or die("Errror in $0: wrong format in $infile: '$line'\n");
    if (defined $name2i{$1}) {next;} # skip template if already found once
    my $tmp_name = $1;
    my $tmp_leng = $2;   
    if ($tmp_name !~ /^[defgh]\d[a-z0-9]{3}[a-z0-9_.][a-z0-9_]$/ && 
	$tmp_name !~ /^\d[a-z0-9]{3}(_[A-Za-z0-9])?$/) {next;} # skip template if no SCOP or PDB
   $name[$N]=$tmp_name;
   $leng[$N]=$tmp_leng;
   $name2i{$tmp_name}=$N++; # store index of template name in hash
}
close(INFILE);

# Find template files
for ($i=0; $i<$N; $i++) {
    foreach my $dir (@dirs) {
	$file[$i]=$dir."/".$name[$i];
	if (-e $file[$i].".pdb") {last;}
    }
    if (! -e $file[$i].".pdb") {die("Errror in $0: can't find template $file[$i].pdb in any of the databases $dirs\n");}
    if (! -e $file[$i].".hhm") {die("Errror in $0: can't find template $file[$i].hhm in any of the databases $dirs\n");}
    if (! -e $file[$i].".a3m") {die("Errror in $0: can't find template $file[$i].a3m in any of the databases $dirs\n");}
    if ($v>=3) {print("Found $file[$i].pdb\n");}
}
$infile=~s/\.hhr$//;
if ($v>=2) {print("\n");}


###############################################################################################
# Do all-against-all comparison with TM-align

if ($use_hhalign==0) {
    if ($v>=2) {print("\nDoing all-against-all comparison with TM-align ...\n");}
    
    for ($i=0; $i<$N; $i++) {
	$TMscore[$i][$i]=0; # (just to define this matrix element, needed later to avoid error)
    }
    for ($j=1; $j<$N; $j++) {
	if ($v==2) {printf("%2i  ",$j+1);}
	for ($i=0; $i<$j; $i++) {
	    
	    my $L = &min($leng[$i],$leng[$j]);
	    system("$TMalign $file[$i].pdb $file[$j].pdb -L $L > $inbase.tmalign");
	    if ($v>=3) {print("$TMalign $file[$i].pdb $file[$j].pdb -L $L > $inbase.tmalign\n");}
	    open(TMALIGN,"<$inbase.tmalign") || die("Error in $0: can not open $inbase.tmalign: $!\n");;
	    while ($line=<TMALIGN>) { if ($line=~/^Aligned length/) {last;} }
	    close(TMALIGN);
	    $line=~/TM-score=(\S+),/ or die("Error in $0: wrong format in TMalign output: '$line'\n");
	    my $tmscore = $1;
	    if ($tmscore > 1.0) { $tmscore = 1.0; }
	    $TMscore[$i][$j]=$TMscore[$j][$i]=-log(2*(1.0001-$tmscore));
	    if ($v>=3) {printf("TM(%2i,%2i) = %7.3f => %7.3f\n",$i,$j,$tmscore,$TMscore[$i][$j]);} elsif ($v==2) {print(".");}
	    
	}
	if ($v==2) {print("\n");}
    }
    if ($v>=2) {print("\n");}
 
} else {
    
    # This part has never been tested!!!!!!!!!!!!!!!!!!!
    if ($v>=2) {print("\nDoing all-against-all comparison with hhalign ...\n");}
    
    for ($i=0; $i<$N; $i++) {
	$TMscore[$i][$i]=0; # (just to define this matrix element, needed later to avoid error)
	system("$hh/hhsearch -i $file[$i].hhm -d $caldb -cal -v 1");
    }
    for ($j=1; $j<$N; $j++) {
	if ($v==2) {printf("%2i  ",$j+1);}
	for ($i=0; $i<$j; $i++) {
	    
	    $TMscore[$i][$j]= system("$hh/hhalign -i $file[$i].hhm -t $file[$j].hhm -calm 2");
	    if ($v>=3) {printf("$hh/hhalign -i $file[$i].hhm -t $file[$j].hhm -calm 2 returned %7.2f\n",$TMscore[$i][$j]);}
	    if ($v>=3) {printf("HHalign(%2i,%2i) = %7.2f \n",$i,$j,$TMscore[$i][$j]);} elsif ($v==2) {print(".");}
	    
	}
	if ($v==2) {print("\n");}
    }
    if ($v>=2) {print("\n");}
    $TMmin = 2*log(1E+6)/log(2);
}



###############################################################################################
# Filter original alignments (leaf nodes) and make HMMs in output directory

if ($v>=2) {print("\nFiltering original alignments and making HMMs ...\n");}
&System("rm $outbase.*.hhm");
for ($i=0; $i<$N; $i++) {
    &System("$hh/hhfilter -i $file[$i].a3m -o $outbase.$i.a3m -diff 100 -id 90 -v 1");
    if ($mode==0 || $mode==1) {
	&System("$hh/hhmake -i $outbase.$i.a3m -mark -seq 1 -v 1 -name $outroot.$i");
	if ($calt) {&System("$hh/hhsearch -i $outbase.$i.hhm -cal -d $caldb -v 1");}
    }
}

###############################################################################################
# Cluster templates by UPGMA 

if ($v>=2) {print("\nUPGMA clustering into forest ...\n");}

# Initialize node lists with single template index
for ($i=0; $i<$N; $i++) {
    @{$node[$i]}=($i);
}
$M=$N;

# Merge nodes until maximum similarity < $TMmin
my $TMmax;
my ($i0,$j0);
while (1) {

    # Find next nodes (i,j) to merge. Break if nothing more to merge
    $TMmax=-1E6;
    for ($j=1; $j<$N; $j++) {
	for ($i=0; $i<$j; $i++) {
	    if ($TMscore[$i][$j]>$TMmax) {
		$TMmax=$TMscore[$i][$j];
		$i0=$i; $j0=$j;
	    }
	}
    }
    if ($TMmax<=$TMmin) {last;} # quit if no more nodes can be merged 
    if (scalar(@{$node[$i0]}) + scalar(@{$node[$j0]}) > 6 ) { # skip merging of nodes with more than 6 leafs 
	$TMscore[$i0][$j0]=-1E6;
	next;
    } 
    if ($v>=3) {
	printf("%3i: TMscore=%7.3f:  merging $i0 (%s) with $j0 (%s)\n",$M,$TMmax,join(", ",@{$node[$i0]}),join(", ",@{$node[$j0]}));
    }

    # Merge i0 and j0 => update $TMscore[][] 
    my $wi0 = scalar(@{$node[$i0]}); # number of sequences under node i0 = weight
    my $wj0 = scalar(@{$node[$j0]}); # number of sequences under node j0 = weight
    for ($i=0; $i<$N; $i++) { $TMscore[$i][$i0] = ($wi0*$TMscore[$i][$i0]+$wj0*$TMscore[$i][$j0])/($wi0+$wj0); }
    for ($j=0; $j<$N; $j++) { $TMscore[$i0][$j] = ($wi0*$TMscore[$i0][$j]+$wj0*$TMscore[$j0][$j])/($wi0+$wj0); }
    for ($i=0; $i<$N; $i++) { $TMscore[$i][$j0] = -1E6;}
    for ($j=0; $j<$N; $j++) { $TMscore[$j0][$j] = -1E6}
    @{$node[$i0]} = ( @{$node[$i0]}, @{$node[$j0]});
    @{$node[$j0]}=();

    if ($mode==0 || $mode==1) {&MakeSuperHMM($i0);} # generate super-HMMs *for each node*
    
}

if ($v>=3) {
    printf("%3i: TMscore=%7.3f:  NOT merging $i0 (%s) with $j0 (%s)\n",$M,$TMmax,join(", ",@{$node[$i0]}),join(", ",@{$node[$j0]}));
}

# If only one or n HMMs *for each tree* is to be generated, do it here
if ($mode==2 || $mode==3) {
    if ($v>=2) {print("\nMerging trees into super-HMMs ...\n");}
    for ($i=0; $i<$N; $i++) { 
	if ($TMscore[$i][$i]>-1E-6) {
	    if (scalar(@{$node[$i]})>=2) {
		&MakeSuperHMM($i);
	    } else {
		my $file=$file[${$node[$i]}[0]]; # get file name including path
		$file=~s/^(.*\/)//; # remove path 
		&System("$hh/hhmake -i $outbase.$i.a3m -mark -seq 1 -v 1 -name $outroot.$i");
		if ($calt) {&System("$hh/hhsearch -i $outbase.$i.hhm -cal -d $caldb -v 1 ");}
	    }
	}
    }
}



###############################################################################################
# Concatenate HMMs from all nodes of forest into database file and search query against it

unlink("$outbase.db.hhm");
&System("cat $outbase.*.hhm > $outbase.db.hhm");
&System("$hh/hhsearch -i $queryfile -d $outbase.db.hhm -o $outbase.hhr -p 1 -seq 20 $calt $realign_options");

#if ($realign_options) { # realigning with no overlap between domains (can't be done with hhsearch)
#    &System("cp $outbase.hhr $outbase.hhr.sav");
#    &System("perl $hh/hhrealign.pl -i $outbase.hhr -q $inbase.hhm -d $outdir -o $outbase.hhr -noresort -hhm -seq 20 $realign_options -v 3");
#}

if ($pickhits) {
    my @pickhits = split(/\s+/,$pickhits);
    foreach my $hit (@pickhits) {
	&System("perl $hh/hhmakemodel.pl -i $outbase.hhr -pir $outbase.$hit.pir -m $hit -q $inbase.a3m -d $dirs");
    }
}

exit(0);


################################################################################################
### Multiply align all structures in node i0, merge corresponding aligments, and build super-HMM
################################################################################################
sub MakeSuperHMM()
{
    my $i0=$_[0];
    my $i;

    # Build multiple alignment in FASTA format
    my $files = "";
    my $file=$file[${$node[$i0]}[0]];
    my $dir="";
    if ($file=~/^(.*\/)/) {$dir=$1;}
    foreach $i (@{$node[$i0]}) {
	$file = $file[$i];
	$file =~s/^$dir//;
	$files.=" $file.pdb";
    }
    
    unlink("$outbase.$M.afasta");
    if ($v>=2) {print("Building multiple structural alignment of $files ...\n");}
    &System("cd $dir ; $mustang -i $files -o $outbase.$M -F fasta -s OFF > /dev/null"); # FASTA alignment written to $infile.afasta
    if ($v>=2) {print("\n");}

    if (!-e "$outbase.$M.afasta") {
	if ($mode==3) {
	    print("WARNING: MUSTANG failed!! Making single-template alignments instead.\n\n");
	    foreach $i (@{$node[$i0]}) {
		&System("$hh/hhfilter -i $file[$i].a3m -o $outbase.$i.a3m -diff 100 -id 90 -v 1");
		&System("$hh/hhmake -i $outbase.$i.a3m -mark -seq 1 -v 1 -name $outroot.$i");
		if ($calt) {&System("$hh/hhsearch -i $outbase.$i.hhm -cal -d $caldb -v 1");}
	    }
	} else {
	    print("WARNING: MUSTANG failed!! Skipping alingment.\n\n");
	}
	return;
    }   

    # Read multiple alignment and replace names with $outbase.$name2i{$name}
    $/="\n>"; # set input record separator 
    open(ALIFILE,"<$outbase.$M.afasta") || die("Error in $0: can not open $outbase.$M.afasta: $!\n");
    my @seqs=<ALIFILE>;
    close(ALIFILE);
    $seqs[0]=~s/^>//; # remove > at the beginning
    my $ids="";
    my $id="";
    for ($i=0; $i<@seqs; $i++) {
	$seqs[$i]=~s/>$//; # remove > at the end
	$seqs[$i]=~s/^(\S+)\.pdb/>$outbase.$name2i{$1}/;
	$ids.="$1 ";
	if ($id eq "") {$id=$1;}
    }
    $/="\n";
    my $ids0=$ids;

    if ($mode==0 || $mode==2) {

	open(ALIFILE,">$outbase.$M.afasta") || die("Error in $0: can not open $outbase.$M.afasta: $!\n");
	print(ALIFILE @seqs);
	close(ALIFILE);
    
	# Merge alignments into super-alignment (match states are all columns with a residue in EITHER of the seed sequences)
	&System("perl $hh/mergeali.pl $outbase.$M.afasta $outbase.$M.a3m -name $id ".scalar(@seqs)."templ: $ids0 -mark -all -full ");	
    
	# Make super-HMM
#	&System("$hh/hhmake -i $outbase.$M.a3m -mark -diff 100 -v 1  -name '$id ".scalar(@seqs)." templ: $ids0'");
#	if ($calt) {&System("$hh/hhsearch -i $outbase.$M.hhm -cal -d $caldb -v 1");}
	&System("$hh/hhmake -i $outbase.$M.a3m -o $outdir/$id.hhm -mark -diff 100 -v 1  -name '$id ".scalar(@seqs)." templ: $ids0'");
	if ($calt) {&System("$hh/hhsearch -i $outdir/$id.hhm -cal -d $caldb -v 1");}

	$M++;

    } elsif ($mode==1 || $mode==3) { # put each of n templates in turn to the top

	for ($i=0; $i<@seqs; $i++) {
	    $line=pop(@seqs);
	    unshift(@seqs,$line);
	    $ids=~s/(\S+ )$//;
	    $ids=$1.$ids;
	    $id=$1;
	    $id=~tr/ //d;

	    open(ALIFILE,">$outbase.$M.afasta") || die("Error in $0: can not open $outbase.$M.afasta: $!\n");
	    print(ALIFILE @seqs);
	    close(ALIFILE);
	    
	    # Merge alignments into super-alignment (match states are columns with a residue in the FIRST seed sequence)
	    &System("perl $hh/mergeali.pl $outbase.$M.afasta $outbase.$M.a3m -name $id".scalar(@seqs)."templ: $ids -mark -all -full ");	
	    
	    # Turn also residues in first sequence with no structure coordinates to match states (these are missing in .fasta file)
#	    &System("perl $hh/reformat.pl -M first $outbase.$M.a3m $outbase.$M.a3m"); 	

	    # Make super-HMM
	    &System("$hh/hhmake -i $outbase.$M.a3m -mark -diff 100 -v 1 -name '$id ".scalar(@seqs)." templ: $ids0'");
	    if ($calt) {&System("$hh/hhsearch -i $outbase.$M.hhm -cal -d $caldb -v 1");}
	    
	    $M++;
	}
       
    } else { 
	die("Error in $0: unknown mode number $mode\n");
    }
}


################################################################################################
### System command
################################################################################################
sub System()
{
    if ($v>=3) {printf("\$ %s\n",$_[0]);} 
    return system($_[0])/256;
}


##################################################################################
# Minimum, maximum etc.
##################################################################################
sub min {
    my $min = shift @_;
    foreach (@_) {
	if ($_<$min) {$min=$_} 
    }
    return $min;
}
sub max {
    my $max = shift @_;
    foreach (@_) {
	if ($_>$max) {$max=$_} 
    }
    return $max;
}
sub av {
    my $sum=0;
    for(my $i=0; $i<@_; $i++) {
	$sum+=$_[$i];
    }
    return $sum/scalar(@_);
}
sub av2 {
    my $sum=0;
    for(my $i=0; $i<@_; $i++) {
	$sum+=$_[$i]*$_[$i];
    }
    return sqrt($sum/scalar(@_));
}
