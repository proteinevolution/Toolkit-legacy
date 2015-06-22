#! /usr/bin/perl -w
# 
# Superpose two structures by RMS minimization over the set of residues aligned by HHsearch

my $rootdir;
BEGIN {
    if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} else {$rootdir="/cluster";}
};
use lib "$rootdir/bioprogs/hhpred";

use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm

use strict;
use MyPaths;      # config file with paht variables for nr, blast, psipred, pdb, dssp etc.

my $help="
Superpose two structures by RMS minimization over the set of residues aligned by HHsearch
Usage:   superpose3d.pl -i <infile.hhr> -m <hit>  [-d <dir>] -o <superpos.pdb> 
Example: superpose3d.pl -i d1a0aa_.hhr -m 3 -d /data/scop70_1.69 -o test.pdb 
\n";

# Variable declarations
my $dir = "/data/scop70_1.69";  # directory where the structures can be found

if (@ARGV<1) {die($help);}

my $v=2;         # verbose mode
my $infile;
my $outfile;
my $hit;
my $templpdb;    # file that contains the template pdb structure
my $querypdb;    # file that contains the query pdb structure
my $templ;       # id of template
my $query;       # id of query
my $command;
my $line;

my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# Set options
if ($options=~s/ -i\s+(\S+) //g)   {$infile=$1;}
if ($options=~s/ -o\s+(\S+) //g)   {$outfile=$1;}
if ($options=~s/ -m\s+(\S+) //g)   {$hit=$1;}
if ($options=~s/ -d\s+(\S+) //g)   {$dir=$1;}


###############################################################
# Open $id.hhr file and parse out set of aligned residues
my $aaq="";  # query residues
my $aat="";  # template residues 
my $qfirst;  # index of first query residue in alignment
my $tfirst;  # index of first template residue in alignment


# Search for alignment number $hit
open (INFILE,"<$infile") ||  die("Error in $0: Can't open $infile: $!\n");
while ($line=<INFILE>) {
    if ($line=~/^No $hit/) {last;}
}
$line=<INFILE>;    
$line=<INFILE>;    


# Search for first line beginning with Q ot T and not followed by aa_, ss_pred, ss_conf, or Consensus
while (1) {
    # Scan up to first line starting with Q; stop when line 'No\s+\d+' or 'Done' is found
    while (defined $line && $line!~/^Q\s(\S+)/) {
	if ($line=~/^No\s+\d/ || $line=~/^Done/) {last;}
	$line=<INFILE>; next;
    } 
    if (!defined $line || $line=~/^No\s+\d/ || $line=~/^Done/) {last;}
    
    # Scan up to first line that is not secondary structure line or consensus line	
    while (defined $line && $line=~/^Q\s+(ss_dssp|sa_dssp|ss_pred|ss_conf|aa_pred|Consensus|Cons-)/)  {$line=<INFILE>; next;} 
    
    if ($line=~/^Q\s*(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s+\((\d+)\)/) {
	$query=$1;
	if (!$qfirst) {$qfirst=$2;} # if $qfirst==0 then this is the first query line read -> set $qfirst to >0
	$aaq.=$3;
	$line=<INFILE>;
    } else {
	die("\nError in $0: bad format in $infile, line $.: code 3\n");
    } 
    
    # Scan up to first line starting with T	
    while (defined $line && $line!~/^T\s+(\S+)/) {$line=<INFILE>; next;} 
    
    # Scan up to first line that is not secondary structure line or consensus line	
    while (defined $line && $line=~/^T\s+(ss_|sa_|aa_|Consensus|Cons-)/)  {$line=<INFILE>; next;} 
    
    # Read next block of template sequences
    my $i=0;
    while ($line=~/^T\s*(\S+)\s+(\d+)\s+(\S+)/) {
	$templ=$1;
	if (!$tfirst) {$tfirst=$2;} # if $tfirst is undefined then this is the first alignment block -> set $tfirst to $1
	$aat.=$3;
	$i++;
	$line=<INFILE>;
    } 
    if ($i==0) {
	die("\nError in $0: bad format in $infile, line $.: code 4\n");
    }
    
} # end while ($line=<INFILE>)  
close(INFILE);
printf("Q %-14.14s  $aaq\n",$query);
printf("T %-14.14s  $aat\n",$templ);

# Set name of pdb files
$querypdb="$dir/$query.pdb";
$templpdb="$dir/$templ.pdb";
if (!-e $querypdb) {
    &System("$hh/makepdbfile.pl $dir/$query.a3m");
    if (!-e $querypdb) {die("Error: could not open $querypdb: $!\n");}
    
}
if (!-e $templpdb) {
    &Sytem("$hh/makepdbfile.pl $dir/$templ.a3m");
    die("Error: could not open $templpdb: $!\n");
}

# Make arrays with indices of pairs of aligned residues
my @i;
my @j;
my @aaq = unpack("C*",$aaq);
my @aat = unpack("C*",$aat);
my $i=$tfirst;
my $j=$qfirst;
for (my $c=0; $c<@aaq; $c++) {
    if ($aaq[$c]!=45 && $aaq[$c]!=46 && $aat[$c]!=45 && $aat[$c]!=46) {
	push(@i,$i++); 
	push(@j,$j++);
    }
    elsif ($aat[$c]!=45 && $aat[$c]!=46) {$i++}
    elsif ($aaq[$c]!=45 && $aaq[$c]!=46) {$j++}
}
printf("Last residue in T: %i \n",$i-1);
printf("Last residue in Q: %i \n",$j-1);

# Superpose the template with the query structure and write the result into $tmp_dir/$id.templ.pdb
#open (SUPERPOSE3D,"| $hh/superpose3d - $templpdb $querypdb $outfile") || die("Error in $0: Can't execute $hh/superpose3d: $!\n");
open (SUPERPOSE3D,">test.txt") || die("Error in $0: Can't open test.txt: $!\n");
for (my $c=0; $c<@i; $c++) { 
    printf(SUPERPOSE3D "%i %i\n",,$i[$c],$j[$c]); 
#    printf("%i %i\n",$i[$c],$j[$c]); 
}
print(SUPERPOSE3D "\n"); # end of input => continue execution of superpose3d
close(SUPERPOSE3D);

exit(0);


sub System()
{
    if ($v>=2) {printf("\$ %s\n",$_[0]);}
    return system($_[0])/256;
}


