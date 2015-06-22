#! /usr/bin/perl -w
# Generate an HMM-HMM distance matrix file for input to CLANS visual clustering program
# Usage: hhclans.pl scores-dir ['regex'] [options]

use strict;
$|=1; # autoflush on

# Variables
my $pmin=1E-20;
my $pcut=0.001;
my $logpmin;
my $logpcut;
my $v=2;             # verbose mode
my $scoresdir;       # scores directory
my @scoresdirs;      # array with scores directory
my $regex="";        # regular expression to filter HMM namelines
my @regex="";        # array with regular expressions to filter HMM namelines
my $infile;          # file being read in
my $outfile;         # clans attraction file to be written
my $options;         # command line arguments
my $line;            # line read in from file
my $query;           # name of query HMM
my $nameline;        # nameline of HMM seed sequence
my $family;          # family of HMM seed sequence
my %index=();        # $index{$scopid} : matrix index of HMM with $scopid
my @records=();      # "$infile:::$nameline:::$family" for all HMMs that passed filter
my @namelines;       # $namelines[$i] is name of HMM with index $i
my @files;           # $files[$i] is file name of HMM with index $i
my @families;        # $families[$i] is family code of HMM with index $i
my @infiles;         # all globbed scorefiles in score-dir
my $n=0;             # number of HMMs that matched the regex
my @logpval=();      # matrix with all log-pvalues read in from scores files
my ($i,$j);          # indices to count HMMs 
my @i;               # trivial index array: $i[$i]=$i
my $col=0;           # color according to 1:class 2: fold 3:superfamily 4:family  0:no coloring/grouping
my $grp=2;           # minimum number of members in a group
my %groupsize=();    # contains the number of elements for each group
my $ngroups;         # number of groups in data set
my @groups;          # array contains "groupsize group" for each group
my @groups_sorted;   # same as @groups, but sorted by group size
my %groupmembers;    # $groupmembers{$group}[] is the array of member indices for $group
my $group;


my $usage="
Generate a CLANS save file with HMM-HMM distance matrix for input to CLANS visual clustering program
The scores directory must contain all *.scores files produced with hhsearch. 
If a regular expression is given the matrix is restricted to HMMS whose nameline matches the regex. 
Usage: hhclans.pl -i scores-dir -o outfile [-r 'regex'] [-i scores-dir [-r 'regex'] ..] [options]

Options:  
 -i directory  directory with *.scores files (more than one directory can be given)
 -r 'regex'    regular expression to filter *.scores files by the NAME line; refers to PREVIOUS directory!
 -v [int]      verbose mode
 -pcut         above this p-value attractive force is ignored (default=$pcut) 
 -pmin         below this value p-value is artificially set to pmin (default=$pmin)
 -col int      automatically color groups with at least <int> members (default=off)
 -grp [1,4]    group HMMs according to scop class, fold, superfamily, or family (default=$grp)

Examples: hhclans.pl -i . -o scop20.clans
          hhclans.pl -i /cluster/soeding/scop20.3/hhcs2 -r 'b\\\.(66|67|68|69|70)\\\.' -o betaprop.clans
          hhclans.pl -i /cluster/soeding/scop20.3/hhc -r 'c\\\.1\\\.' -i ~/hartl/tim -o tim_GroES.clans
\n"; 

if (scalar(@ARGV)<1) {print($usage); exit;}

# Override default options?
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

#Verbose mode?
my $ndirs=-1;
while (1) {
    if ($options=~s/ -i\s*(\S+) //g) {
	$scoresdirs[++$ndirs]=$1;
	$regex[$ndirs]="";
    } elsif ($options=~s/ -r\s*(\S+) //g) {
	$regex[$ndirs]=$1;
    } else {last;}
}
$ndirs++;

if ($options=~s/ -v\s*(\d) //g) {$v=$1;}
if ($options=~s/ -v //g) {$v=2;}
if ($options=~s/ -pmin\s*(\S+) //g) {$pmin=$1;}
if ($options=~s/ -pcut\s*(\S+) //g) {$pcut=$1;}
if ($options=~s/ -o\s*(\S+) //g)   {$outfile=$1;}
if ($options=~s/ -grp\s*(\S+) //g) {$grp=$1;}
if ($options=~s/ -col\s*(\S+) //g) {$col=$1;}

#if (!$scoresdir && $options=~s/^\s*([^-]\S*)\s*//) {$scoresdir=$1;} 
#if (!$outfile   && $options=~s/^\s*([^-]\S*)\s*//) {$outfile=$1;} 
#if (!$regex     && $options=~s/^\s*([^-]\S*)\s*//) {$regex=$1;} 

# Warn if unknown options found or no infile/outfile
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; die("Error: unknown options '$options'\n");}
if (!$outfile) {print($usage."Error: no outfile given\n"); exit(1);}
if (!$ndirs)   {print($usage."Error: no scores directory given\n"); exit(1);}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}

if ($v>=3) {
    for (my $ndir=0; $ndir<$ndirs; $ndir++) {
	print("Scores directory: $scoresdirs[$ndir]\n");
	print("Regex:            $regex[$ndir]\n");
    }
}    

$logpcut=-log($pcut)/log(2.0);
$logpmin=-log($pmin)/log(2.0);

# Prepare hashes with sequence files and sequence names to be used in all-against-all comparison
if ($v>=2) {printf("Making list of HMMs and count group sizes ...\n",scalar(@files));}
for (my $ndir=0; $ndir<$ndirs; $ndir++) {

    @infiles=();
    @infiles=glob("$scoresdirs[$ndir]/*.scores");
    for ($i=0; $i<@infiles; $i++) {
        $infile=$infiles[$i];

	open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");
	$line=<INFILE>;
	$family=<INFILE>;
	close(INFILE);
	if ($line!~/^NAME\s+(\S+)(.*)/) {die("Error: no nameline found in first line of $infile\n");}
	$query=$1;
	$nameline="$1$2";

	if (!$regex[$ndir] || $nameline=~/$regex[$ndir]/) {

	    $family=~/FAM\s+(\S*)/;
	    $family=$1;
	    $records[$n]="$infile".":::$nameline".":::$family";
#	    print("$infile".":::$nameline\n");
	    if ($v>=4) {print("$n '$query' '$nameline'\n");}
	    if ($col) { # count size of groups?
		if ($family ne "") {
		    if ($grp==1)    {$family=~/^(\S)/; $group=$1;}
		    elsif ($grp==2) {$family=~/^(\S\.\d+)/; $group=$1;}
		    elsif ($grp==3) {$family=~/^(\S\.\d+\.\d+)/; $group=$1;}
		    elsif ($grp==4) {$family=~/^(\S\.\d+\.\d+\.\d+)/; $group=$1;}
#	        else {die("Error: invalid group level in -grp option. Use 1, 2, 3, or 4\n");}
		} else {$group="";}

		if (defined $groupsize{$group}) {
		    $groupsize{$group}++;
		    push(@{$groupmembers{$group}},$query);
		} elsif ($group ne "") {
		    $groupsize{$group}=1;
		    $groupmembers{$group}[0]=$query;
		};
	    }
	    $n++;
	}
    }
}
if ($v>=2) {printf("Found $n matching HMMs\n",scalar(@files));}


# Sort HMMs by family
if ($v>=2) {printf("Sorting HMMs by family names ...\n",scalar(@files));}
my @records_sorted = sort(ByFamily @records);
for ($i=0; $i<@records; $i++) {
    $records_sorted[$i]=~/^(\S+):::(\S+)(.*):::(\S*)/;
    $files[$i]=$1;
    $namelines[$i]=$2.$3;
    $index{$2}=$i;
}


# Read attraction values from scores files
if ($v>=2) {printf("Reading log P-values from scores files ...\n");}
for ($i=0; $i<$n; $i++) {
    $infile=$files[$i];
    open(INFILE,"<$infile") || die("Error: cannot open $infile: $!\n");
    
    # Find title line
    while($line=<INFILE>) {if ($line=~/^TARGET/) {last;} }
    if ($line!~/^TARGET/) {die("Error: no TARGET line found in $infile\n");}

    # Run through pair comparison records ...
    # TARGET     FAMILY   REL LEN COL LOG-PVA  S-AASS PROBAB   MS NALI
    if ($v>=3) {print("Reading scores for $i $namelines[$i]\n");}
    while($line=<INFILE>) {
	if ($line=~/^(\S+)\s+\S+\s+\d+\s+\d+\s+\d+\s+(-?\d+\.?\d*)\s+-?\d+\.?\d*/) {
	    if (defined $index{$1}) { # && $2+3.3>$logpcut) { # +3.3>logpcut: for taking the average together with the reciprocal p-value
		if (!defined $logpval[$i][$index{$1}]) { # otherwise this is just the second hit to the same template
 		    $logpval[$i][$index{$1}]=$2;   
		}
	    } 
	}
    }
    close(INFILE);
}

# Sort groups by size and allocate colors to groups
if ($v>=2) {print("Sort groups by size and allocate colors ...\n");}
if ($col) {
    $ngroups=0;
    foreach $group (keys(%groupsize)) {
	$groups[$ngroups++]="$groupsize{$group}:$group";
    }
#    for ($i=0; $i<$ngroups; $i++) {printf("%s\n",$groups[$i]);}
    @groups_sorted = sort(ByGroupSize @groups);
#    for ($i=0; $i<$ngroups; $i++) {printf("%s\n",$groups_sorted[$i]);}
}



# Open CLANS file and write HMM names  etc
if ($v>=2) {print("Open $outfile and write HMM names ...\n");}
open (OUTFILE,">$outfile") || die("Error: cannot open $outfile: $!\n");
print(OUTFILE "sequences=$n\n");
print(OUTFILE "<param>
maxmove=10.0
pval=1.0
cooling=1.0
currcool=1.0
attfactor=100.0
attvalpow=1.0
repfactor=100.0
repvalpow=1.0
dampening=0.0
minattract=100.0
cluster2d=false
</param>\n");
print(OUTFILE "<rotmtx>\n1.0;0.0;0.0;\n0.0;1.0;0.0;\n0.0;0.0;1.0;\n</rotmtx>\n");

# Print HMM names
print(OUTFILE "<seq>\n");
#for ($i=0; $i<@files; $i++) {printf(OUTFILE ">%s\n",$namelines[$i_sorted[$i]]);}
my $base;
for ($i=0; $i<@files; $i++) {
#    printf(OUTFILE ">%s\n",$namelines[$i]);
    if ($files[$i] =~/(.*)\..*?/) {$base=$1;} else {$base=$files[$i];}
    if ($base=~/.*\/(.*)?/)       {$base=$1;}
    printf(OUTFILE ">%s\n",$namelines[$i]);
}
print(OUTFILE "</seq>\n");

if (0) {
# Read sequence weights
my %weights=();
open(WFILE,"<clans.weights") or die("Error: cannot open clans.weights: $!\n");
while($line=<WFILE>) {
    if ($line=~/^>(\S+)/) {
	my $name=$1;
	$line=<WFILE>;
	chomp($line);
	$weights{$name}=1.0*$line;
    }
}
close(WFILE);
# Print sequence weights
print(OUTFILE "<weight>\n");
for ($i=0; $i<@files; $i++) {
    $namelines[$i]=~/(\S+)/;
    printf(OUTFILE ">%s\n%8.6f\n",$1,$weights{$1});
}
print(OUTFILE "</weight>\n");
}


# Print groups and their colors
if ($col) {
if ($v>=2) {print("   and groups and their colors ...\n");}

# Color palette with 42 medium-to-light colors (for black background).
# For white background take 255-x as RGB values for all but first row!
    my @color=(
	       "255;0;0","0;255;0","0;0;255","255;255;0","0;255;255","255;0;255",
	       "255;128;0","128;255;0","255;0;128","128;0;255","0;255;128","0;128;255",
	       "255;128;128","128;255;128","128;128;255",
	       "128;128;0","0;128;128","128;0;128",
	       "255;64;0","255;192;0","255;0;64","255;0;192","255;192;64","255;64;192",
	       "64;255;0","192;255;0","0;255;64","0;255;192","192;255;64","64;255;192",
	       "64;0;255","192;0;255","0;64;255","0;192;255","192;64;255","64;192;255",
	       "192;0;0","0;192;0","0;0;192",
	       "128;255;255","255;128;255","255;255;128"
	       );
    print(OUTFILE "<seqgroups>\n");
    for ($i=0; $i<$ngroups; $i++) {
	$groups_sorted[$i]=~/^(\d+):(\S+)$/;
	if ($1<$col) {last;}
	printf(OUTFILE "name=$2\n");
	printf(OUTFILE "color=%s\n",$color[$i%(scalar(@color))]);
	printf(OUTFILE "numbers=");
	for (my $j=0; $j<@{$groupmembers{$2}}; $j++) {
	    printf(OUTFILE "%i;",$index{${$groupmembers{$2}}[$j]});
	}
	printf(OUTFILE "\n");
    }
    print(OUTFILE "</seqgroups>\n");
    if ($v>=2) {printf("   => colored %i groups from palette with %i colors\n",$i,scalar(@color));}
}

# Print random HMM positions
if ($v>=2) {print("   and random initial coordinates ...\n");}
print(OUTFILE "<pos>\n");
for ($i=0; $i<$n; $i++) {
    printf(OUTFILE "%-3i %5.3f %5.3f %5.3f\n",$i,rand(),rand(),rand());
}
print(OUTFILE "</pos>\n");

# Print matrix of attraction values
if ($v>=2) {print("   and log P-values ...\n");}
print(OUTFILE "<hsp>\n");
my ($ii,$jj);
for ($i=0; $i<$n; $i++) {
    for ($j=$i+1; $j<$n; $j++) {
	if (!defined $logpval[$i][$j]) {$logpval[$i][$j]=$logpval[$j][$i];}
	if (!defined $logpval[$j][$i]) {$logpval[$j][$i]=$logpval[$i][$j];}
	if (defined $logpval[$i][$j]) {
	    my $logpval=0.5*($logpval[$i][$j]+$logpval[$j][$i]);
	    if ($logpval>=$logpcut) {
		if ($logpval>$logpmin) {$logpval=$logpmin;}
		$logpval-=$logpcut; # REMOVE WHEN TANCRED HAS BUILT THIS INTO CLANS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 		my $val=2**(-$logpval);
		printf(OUTFILE "%i %i:%-9.2E\n",$i,$j,$val);
		printf(OUTFILE "%i %i:%-9.2E\n",$j,$i,$val);
	    }
	}
    }
}
print(OUTFILE "</hsp>\n");

close (OUTFILE);
exit;

sub ByFamily () 
{
    $a=~/:::(\S*)$/;
    my $na=$1;
    $b=~/:::(\S*)$/;
    my $nb=$1;
    if (defined $na && defined $nb) {return $na cmp $nb;} else {return 0;}
#    return $families[$a] cmp $families[$b];
}
sub ByGroupSize () 
{
    $a=~/(\d+)/;
    my $na=$1;
    $b=~/(\d+)/;
    my $nb=$1;
    return $nb <=> $na;
}
