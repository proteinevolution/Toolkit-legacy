#!/usr/bin/perl -w
# Read infile.hhr, realign all hits with hhalign using the supplied alignment options, 
# and write the results into outfile.hhr. Evalues and Pvalues are kept from the original 
# infile.hhr, whereas score and alignment-related information is updated.
# Usage: hhrealign.pl -i infile.hhr -o outfile.hhr [hhalign-options]

# IF YOU ARE NOT SOEDING DELETE THE FOLLOWING BLOCK AND UNCOMMENT AND COMPLETE ITS LAST LINE 
my $rootdir;
BEGIN {
    if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} else {$rootdir="/cluster";}
};
use lib "$rootdir/bioprogs/hhpred";
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm

use MyPaths;                         # config file with path variables for nr, blast, psipred, pdb, dssp etc.

# IF YOU ARE NOT SOEDING, UNCOMMENT AND FILL IN THE MISSING PATH IN THE FOLLOWING LINE
#my $hh="<path to hhsearch binaries>";

use strict;

my $v=2;           # verbose mode
my $resort=0;      # default: noresort
my $tfileformat="a3m"; # default: use the a3m files for realigning, not the hhm files
my $MAXOVLAP=20;   # for -noov option: maximum allowable overlap with previously accepted matches 
my $MINDOMLEN=40;  # for -noov option: minimum length of match not overlapping with previous matches

my $usage="
 Read infile.hhr, realign all hits with hhalign using the supplied alignment options, 
 and write the results into outfile.hhr. 
  * In -noresort mode, the order of hits, probabilities, E-values and P-values are kept 
 from the original infile.hhr, whereas score and number of matched columns are updated.
  * In -resort mode, the order is changed according to the new probabilities, and all data 
 (probabilities, E-values, P-values, scores etc.) are updated. Each HMM is realigned only
 once (even though it may have alternative alignments appearing in the hit list), but 
 all suboptimal alignments are included in the new hit list.
 
 * Needs the query a3m (or hmm or hhm) file either in the present directory or in one of the directories given by -d

 Usage: hhrealign.pl -i infile.hhr -o outfile.hhr [options]

 Options:
 -i <file>    input file in hhr format
 -o <file>    output file in hhr format
 -q <query>   query a3m, hmm, or hhm file (default=infile.hhm)
 -d <dirs>    input directories with .a3m, .hmm, or .hhm files (default='.')
 -noresort    leave order of hits, probability, and E-value untouched; use only optimal alignment (default)
 -resort      resort all results by new score/probability (query HMM must be calibrated)
 -noov        exclude all aligned query residues from further alignments (for non-overlapping mulit-domain predictions)
 -a3m         use the a3m files for realigning, if available (otherwise hmm or hhm files) (default)
 -hmm         use the hmm files for realigning, if available (otherwise a3m files)
 -hhm         use the hhm files for realigning, if available (otherwise a3m files)
 All hhalign options are allowed

 Example: hhrealign -i T0273.hhr -o T0272.glo.hhr -global -d /home/soeding/pdb70/db/pdb.hhm /home/soeding/scop70_1.67/db/scop.hhm
\n";

my $infile;      # .hhr results file read in
my $outfile;     # .hhr results file with new alignments
my $hhmdir;      # directory where hhm files are found
my @hhmdir;      # directories where hhm files are found
my $options;     # options read in and alignment options for hhalign
my $line;        # input line
my $header;      # everything from $infile.hhr before the first line in hit list
my $titleline;   # title line of hit list
my $basename;    # basename of input file (no path, no extension)
my $rootname;    # rootname of input file (no path)
my $tmpfile;     # [basename of $outfile].tmp
my $indir;       # directory of input file
my $l;           # line number
my $k;           # hit number
my $cutcol;      # everything to the left of ' Score' in the hit list is retained 
my @hitline;     # $hitline[$k]: k'th line in hitlist;
my @names;       # $names[$k]: scop id of k'th hit
my @alignment;   # $alignment[$k]: new alignment for k'th hit 
my @nameline;    # $nameline[$k] is name line of k'th hit
my @probline;    # $probab[$k]: old Probability of k'th hit to be homologous
my @scoreline;   # $scoreline[$k]: new score of k'th hit from hhalign
my @index;       # used for sorting alignments
my @prob;        # in -resort mode: store probabilities of alignments for sorting
my %excluderes;  # residue range (e.g. "3-147,298-353") to exclude from realignment, for the case that there is 
                 # more than one match to the same template (otherwise "")
my $query;       # hhm file belonging to $basename.hhr. May be in present directory or in $hhmdir
my $nooverlap=0; # allow for overlaps between successive hits
my $excluderes=""; # e.g. "253-412,1-93"
my @aligned;     # $aligned[$i] = 0 if query residue $i not yet aligned to any database match, 1 otherwise
my @first;       # first aligned query residue in k'th alignment of infile
my @last;        # last  aligned query residue in k'th alignment of infile
my $overlap;     # overlap of a database match with previously accepted matches
my $mlen;        # number of database match residues not overlapping with previously accepted matches
my $length="?";
my $Neff="?";
my $Nseqs="?";
my $N_searched=1;


# Read options
if (@ARGV<2) {die ($usage);}

$options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

#Verbose mode?
if ($options=~s/ -v\s+(\d) //) {$v=$1;}

# Set input and output file
if ($options=~s/ -i\s+(\S+) //) {$infile=$1;}
if ($options=~s/ -o\s+(\S+) //) {$outfile=$1;}
if ($options=~s/ -d\s+(([^-]\S*\s+)+)/  /) {@hhmdir=split(/\s+/,$1);}
if ($options=~s/ -q\s+(\S+) //) {$query=$1;}
if ($options=~s/ -resort //)    {$resort=1;}
if ($options=~s/ -noresort //)  {$resort=0;}
if ($options=~s/ -noov //)      {$nooverlap=1;}
if ($options=~s/ -a3m //)       {$tfileformat="a3m";}
if ($options=~s/ -hmm //)       {$tfileformat="hmm";}
if ($options=~s/ -hhm //)       {$tfileformat="hhm";}
if (!$infile  && $options=~s/^\s*([^- ]\S*)\s*//) {$infile=$1;} 
if (!$outfile && $options=~s/^\s*([^- ]\S*)\s*//) {$outfile=$1;} 
if (!$hhmdir  && $options=~s/^\s*([^- ]\S*)\s*//) {$hhmdir=$1;} 

# Warn if unknown options found or no infile/outfile
if (!$infile)  {print($usage); die("Error: no input file given\n");}
if (!$outfile) {print($usage); die("Error: no output file given\n");}

$options=~s/ +/ /g;         # remove unnecessary spaces

# Find query HMM
if ($infile =~/(.*)\..*/)       {$basename=$1;} else {$basename=$infile;}
if ($basename =~/(.*)\/(.*?)$/) {push (@hhmdir,$1); $rootname=$2;} else {$rootname=$basename;} # rootname = basename without path
push (@hhmdir,"."); # Current directory is default directory

if (!defined $query){ 
    foreach $hhmdir (@hhmdir) {
	if (-e "$hhmdir/$rootname.hhm") {
	    $query="$hhmdir/$rootname.hhm";
	    last;
	} 
    }
    if (!defined $query) {die("\nError: could not find $rootname.hhm\n");}
}
if ($v>=3) {print("query=$query  options=$options\n");}

if ($v>=3) {
    print("Directories with HMMs:\n");
    for (my $i=0; $i<@hhmdir; $i++) {print("$i  $hhmdir[$i]\n");}
}

# Read header data from query HMM
open(INFILE,"<$query") or die("Error: cannot open $query: $!\n");
while ($line=<INFILE>) {if ($line=~/LENG\s*(\d+)/) {$length=$1; last;} }
while ($line=<INFILE>) {if ($line=~/FILT\s*(\d+)/) {$Nseqs=$1; last;} }
while ($line=<INFILE>) {if ($line=~/NEFF\s*(\S*)/) {$Neff=$1; last;} }
close(INFILE);
my $date=`date`;
chomp($date);

open(INFILE,"<$infile") or die("Error: cannot open $infile: $!\n");

# Read header into @header
$header="";
while ($line=<INFILE>) {
    if ($line=~/^\s*$/) {last;}
    $line=~s/^Match.columns.*/Match_columns $length/;
    $line=~s/^No.of.seqs.*/No_of_seqs    $Nseqs/;
    $line=~s/^Neff.*/Neff          $Neff/;
    $line=~s/^Date.*/Date          $date/;
    if ($line=~/^Searched_HMMs\s+(\d+)/) {$N_searched=$1;}
    $header.=$line;
}
if (!$line) {die("Error: $infile truncated\n");}

# Read title line
$titleline="";
while ($line=<INFILE>) {
    $titleline.=$line;
    if ($line=~/^\s*No\s/) {last;}
}

# Initialize @aligned array (to avoid overlaps)
if ($nooverlap) {
    for (my $i=1; $i<=$length; $i++) {$aligned[$i]=0;}
}


if ($resort) {

    #######################################################################################
    # Resort hits

    # Read hit list
    $line=~/^(.*)E-value/;
    $cutcol=length($1);
    # ... and store names of all HMMs in order of appearance with no HMM stored twice
    my %names; 
    for ($k=0; $line=<INFILE>;) {
	if ($line=~/^\s*$/) {last;}
	$line=~/^\s*\d+\s*(\S+)/;
	if (! defined($names{$1})) {
	    push(@names,$1);
	    $names{$1}=1;
	    $line=~/(\d+)-\s*(\d+)\s+\S+\s*\(\S+\)\s*$/; # read query residue range
	    $first[$k]=$1;
	    $last[$k] =$2;
	    $k++;
	}
    }

    if ($v>=2) {printf("Realigning query with %i templates\n",scalar(@names));}

    for($k=0; $k<@names; $k++) {

	if ($nooverlap) {

	    # Count overlaps and non-overlapping match length 
	    $overlap=0;
	    $mlen=0;
	    for (my $i=$first[$k]; $i<=$last[$k]; $i++) {
		if ($aligned[$i]==1) {$overlap++;} else {$mlen++;}
	    }
	    if ($overlap>$MAXOVLAP) {next;} # skip match if too much overlap with previously accepted matches
	    if ($mlen<$MINDOMLEN) {next;}   # skip match if too few non-overlapping residues
	    &SearchAndRealign($k,$excluderes); # enforce no overlap between any accepted match further up

	} else {
	    &SearchAndRealign($k); 
	}

	while($line=<TMPFILE>) {if($line=~/^ No\sHit/) {last;} }
	# Read hit list (optimal and possibly suboptimal alignments)
	while($line=<TMPFILE>) {	
	    if ($line=~/^\s*$/) {last;}
	    $line=~/(\S+)\s+\S+\s*\(\S+\)\s*$/; # read query residue range
	    my $range=$1;
	    if ($excluderes) {$excluderes.=",".$range;} else {$excluderes=$range;}

	    # Set aligned positions to 1
	    $range=~/(\d+)-(\d+)/;
	    for (my $i=$1; $i<=$2; $i++) {$aligned[$i]=1;}

	    $excluderes=~s/,1-1$//;
	    my $Evalue=substr($line,$cutcol,7)*$N_searched;
	    if ($Evalue<999 && $Evalue>10) {$Evalue=sprintf("%7i",$Evalue);} else {$Evalue=sprintf("%7.2G",$Evalue);}
	    substr($line,$cutcol,7,$Evalue);
	    $line=~/^\s*\d+ (.*)/;
	    push(@hitline,$1);
	}
	while($line=<TMPFILE>) {if($line=~/^No\s/) {last;} }
	# Read alignments
	my $alignment="";
	while ($line=<TMPFILE>) { # read alignment
	    if ($line=~/^Done/) {last;}
	    if ($line=~/^No /)  {push(@alignment,$alignment); $alignment=""; next;}
	    if ($line=~/Probab\s*=\s*(\S+)/) {
		$prob[$#alignment+1]=$1;
		$line=~/E-value\s*=\s*(\S+)/;
		my $Evalue=$1*$N_searched;
		if ($Evalue<999 && $Evalue>10) {$Evalue=sprintf("%7i",$Evalue);} else {$Evalue=sprintf("%7.2G",$Evalue);}
		$line=~s/E-value\s*=\s*(\S+)/E-value=$Evalue/;
	    }
	    $alignment.=$line;
	}
	push(@alignment,$alignment); 
	close(TMPFILE);
    }
    for ($k=0; $k<@alignment; $k++) {$index[$k]=$k;} # initialize sort vector
    my @i=@index;
    @index = sort {$prob[$b]<=>$prob[$a]} @i; # sort hits by score

} else {

    #######################################################################################
    # No resorting

    # Read hit list    
    $line=~/^(.*)Score/;
    $cutcol=length($1)-1;  # ... cut off everything after $cutcol ...
    if ($v>=3) {print("cutcol=$cutcol\n");}
    my %indices; # array with indices of all matches to this template
    for ($k=0; $line=<INFILE>; $k++) {
	if ($line=~/^\s*$/) {last;}
	$line=~/^\s*\d+\s*(\S+)/;
	$names[$k]=$1;
	$hitline[$k]=substr($line,4,$cutcol-4); # cut off second part of hitlist line
	$line=~/(\d+)-\s*(\d+)\s+\S+\s*\(\S+\)\s*$/; # read query residue range
	$first[$k]=$1;
	$last[$k] =$2;
    }

    # ... and read alignment annotation lines
    #Probab=100.00  E-value=0  Score=381.02  Aligned_columns=185  identities=76%
    while ($line=<INFILE>) {
	if ($line=~/^\s*No\s+(\d+)/) {
	    $k=$1-1;
	} elsif ($line=~/^>(\S+)/) {
	    $nameline[$k]=$line;
	} elsif ($line=~/^(Probab=.*)Score=/) {
	    $probline[$k]=$1;
	}
    }

    # Read only best (i.e. first) alignment between query and template
    if ($v>=2) {printf("Realigning query with %i templates\n",scalar(@names));}
    for($k=0; $k<@names; $k++) {
	if ($nooverlap) {

	    if ($k>0) {
		# Count overlaps and non-overlapping match length 
		$overlap=0;
		$mlen=0;
		for (my $i=$first[$k]; $i<=$last[$k]; $i++) {
		    if ($aligned[$i]==1) {$overlap++;} else {$mlen++;}
		}
		if ($overlap>$MAXOVLAP) {next;} # skip match if too much overlap with previously accepted matches
		if ($mlen<$MINDOMLEN) {next;}   # skip match if too few non-overlapping residues
	    }

	    &SearchAndRealign($k,$excluderes); # enforce no overlap between any match further up

	} else {

	    &SearchAndRealign($k,$excluderes{$names[$k]}); # enforce no overlap between matches with same template
	}

	while($line=<TMPFILE>) {if($line=~/^\s*No\s/) {last;} }
	$line=<TMPFILE>;
	$line=~/(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s+(\S+)\s+\S+\s*\(\S+\)\s*$/; # read query residue range
	my $prob=$1;
	my $ncols=$2;
	my $range=$3;

	# If no overlap is enforced and global alignment lead
	if ($nooverlap && $k>0 && $options=~/-glo\S*/ && ($ncols<$mlen || $prob<20)) {
	    $options=~s/-glo\S*/-local/;
	    &SearchAndRealign($k,$excluderes); # enforce no overlap between any match further up
	    $options=~s/-local/-global/;

	    while($line=<TMPFILE>) {if($line=~/^\s*No\s/) {last;} }
	    $line=<TMPFILE>;
	    $line=~/(\S+)\s+\S+\s*\(\S+\)\s*$/; # read query residue range
	    $range=$1;
	} 

	if ($range!~/^(0|1)-(0|1)$/) {
	    if ($excluderes{$names[$k]}) {$excluderes{$names[$k]}.=",".$range;} else {$excluderes{$names[$k]}=$range;}
	    if ($excluderes)             {$excluderes.=",".$range;}             else {$excluderes=$range;}
	} else {
	    next;
	}

	$range=~/(\d+)-(\d+)/;
	for (my $i=$1; $i<=$2; $i++) {$aligned[$i]=1;} 	# set aligned positions to 1

	$excluderes=~s/,1-1$//;
	$line=~/^.{$cutcol}(.*)/;
	$hitline[$k].=$1;
	while($line=<TMPFILE>) {if($line=~/^>/) {last;} }
	$line=<TMPFILE>;
	if ($line=~/(Score\s*=.*)/) {$scoreline[$k]=$1;} 
	$alignment[$k]=sprintf("%s%s  %s\n",$nameline[$k],$probline[$k],$scoreline[$k]);
	while ($line=<TMPFILE>) { # read alignment
	    if ($line=~/^No / || $line=~/^Done/) {last;}
	    $alignment[$k].=$line;
	}
	close(TMPFILE);
	push(@index,$k);
    }
}
close(INFILE);


# Write outfile

open(OUTFILE,">$outfile") or die("Error: cannot open $outfile: $!\n");
# Print header
print(OUTFILE $header); 
printf(OUTFILE "Command       hhrealign.pl %s\n\n",join(" ",@ARGV));
print(OUTFILE $titleline);
# Print hit list
for($k=0; $k<@index; $k++) {  
    printf(OUTFILE "%3i %s\n",$k+1,$hitline[$index[$k]]);
}
print(OUTFILE "\n");
# Print alignments
for($k=0; $k<@index; $k++) { 
    printf(OUTFILE "No %i\n",$k+1);
    print(OUTFILE $alignment[$index[$k]]);
#    print(OUTFILE "\n\n");
}
print(OUTFILE "Done!\n");
 close(OUTFILE);

exit;


sub SearchAndRealign() 
{
    my $k=$_[0];
    my $excluderes=$_[1];
    my $ext;
    close(TMPFILE);

    # Do not change the order of the following TryRealign commands, as this will affect HHpred:
    # HHpred uses -hhm when no realignment is necessary, and -hmm otherwise.
    if ($tfileformat eq "a3m") {
	if    (&TryRealign("a3m",$k,$excluderes)) {$ext="a3m";}
	elsif (&TryRealign("hhm",$k,$excluderes)) {$ext="hhm";}
	elsif (&TryRealign("hmm",$k,$excluderes)) {$ext="hmm";}
    }
    elsif ($tfileformat eq "hmm") 
    {
	if    (&TryRealign("hmm",$k,$excluderes)) {$ext="hmm";}
	elsif (&TryRealign("a3m",$k,$excluderes)) {$ext="a3m";}
    }
    elsif ($tfileformat eq "hhm") 
    {
	if    (&TryRealign("hhm",$k,$excluderes)) {$ext="hhm";}
	elsif (&TryRealign("hmm",$k,$excluderes)) {$ext="hmm";}
	elsif (&TryRealign("a3m",$k,$excluderes)) {$ext="a3m";}
    }
    if (!defined $ext) {die("\nError in hhrealign.pl: could not find $hhmdir/$names[$k].a3m or .hmm or .hhm\n");}
    return $ext;
}

sub TryRealign()
{
    my $ext=$_[0];
    my $k=$_[1];
    my $excluderes=$_[2];
    my $found=0;
    foreach $hhmdir (@hhmdir) {
	if (-e "$hhmdir/$names[$k].$ext") {
	    if ($v>=2) {
		if ($ext eq "a3m") {
		    printf("%3i: Filtering template alignment %s and realigning resulting HMM with %s ... \n",$k+1,$names[$k],$query);
		} else {
		    printf("%3i: Realigning template HMM %s with %s ... \n",$k+1,$names[$k],$query);
		} 
	    }
	    if ($excluderes) {$excluderes="-excl ".$excluderes;} else {$excluderes="";}

	    if ($v>=3) {print("$hh/hhalign -v0 -i $query -t $hhmdir/$names[$k].$ext -o stdout $excluderes $options\n");}
	    open(TMPFILE,"$hh/hhalign -v0 -i $query -t $hhmdir/$names[$k].$ext -o stdout $excluderes $options |");
	    $found=1;
	    last;
	}
    }
    if ($v>=3 && $found==0) {print("\nWARNING in hhrealign.pl: could not find $names[$k].$ext in any of the directories supplied\n");}
    return $found;
}


sub System()
{
    if ($v>=3) {printf("%s\n",$_[0]);} 
    return system($_[0])/256;
}

