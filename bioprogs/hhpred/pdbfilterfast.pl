#! /usr/bin/perl -w

BEGIN { 
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/cluster/soeding/perl");     # for cluster
    push (@INC,"/cluster/bioprogs/hhpred");  # forchimaera  webserver: MyPaths.pm
    push (@INC,"/cluster/lib");             # for chimaera webserver: ConfigServer.pm
}
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;

# Default options
my $idmax=90;
my $covmin=90;
my $v=2;

my $help="
 Read pdb sequences from infile and write representative set of sequences to outfile
 Compare each sequence with all others. If >90% of the sequence with lower resolution 
 is covered by the alignment AND the sequence identity is larger than \$idmin 
 then throw out the sequence with lower resolution. 
 The input file must have been prepared with pdb2fas.pl 

 Divide all sequences into 20 files and filter them seperately first, then apped them
 all and filter one last time. Program calls pdbfilter.pl 

 Usage:   pdbfilter.pl infile filtered_file [-u old_filtered_file] [-id int] [-cov int]
 Options
  -id int    minimum sequence identity between representative sequences (default=$idmax)
  -cov int   minimum coverage of a sequence with a similar one to get thrown out (default=$covmin)
  -u file    update the old filtered file; this saves a lot of execution time 
  -v file    verbose mode
 Example: pdbfilter.pl pdb.fas pdb70.fas -u pdb70.fas -id 70 -cov 90\n
";
if (@ARGV<2) {print($help); exit;}

my $options="";
my $infile;
my $outfile;
my $oldfile;
my $root="";       # $outfile without extension
my $line;
my $pdbid="";      # e.g. 1ahs_C
my $qpdbid;        # pdbid of query sequence
my $seq="";        # sequence record (name+residues) in FASTA
my @seqs;          # sequence records as they were read
my @sortedseqs;    # sequence records sorted by X-ray resolution
my $len=0;         # length of sequence to be read in
my %lens;          # $lens{$pdbid} is length of sequence 
my %excluded;      # representative sequences are all those not in this hash
my $id;            # sequence identity to query
my $cov;           # coverage 
my $nold=0;        # number of sequences in oldfile
my $ntot=0;        # total number of sequences in oldfile and infile
my $k=0;           # counts sequences read in so far

# Read command line options
for (my $i=0; $i<=$#ARGV; $i++) {$options.=" $ARGV[$i]";}
if ($options=~s/ -id\s+(\S+)//) {$idmax=$1;}
if ($options=~s/ -cov\s+(\S+)//) {$covmin=$1;}
if ($options=~s/ -u\s+(\S+)//) {$oldfile=$1;} 
if ($options=~s/ -v\s*(\d+)//) {$v=$1;} 
if ($options=~s/ -v//) {$v=2;} 
if (!$infile  && $options=~s/^\s*([^- ]\S+)\s*//) {$infile=$1;} 
if (!$outfile && $options=~s/^\s*([^- ]\S+)\s*//) {$outfile=$1;} 

# Warn if unknown options found or no infile/outfile
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; die("Error: unknown options '$options'\n");}
if (!$infile)  {print($help); print("Error: no input file given\n"); exit;}
if (!$outfile) {print($help); print("Error: no output file given\n"); exit;}

$covmin*=0.01;
if ($outfile=~/^(\S*?)\.(.*)$/) {$root=$1;} else {$root=$outfile;}

if ($oldfile) {
    &System("$hh/pdbfilter.pl $infile $outfile -u $oldfile -id $idmax -cov $covmin");
} else {
    # Read NEW sequences from infile (the ones that are not yet in oldfile)
    $ntot=&ReadSequences($infile,0);
    $k=0;
    &System("touch $root++.fas");  
    for (my $i=1; $i<=20; $i++) {
	open(TMPFILE,">$root++.in") || die("ERROR: cannot open $root++.fas for writing: $!\n");
	for (; $k<int($i/20*$ntot+0.5); $k++) {print(TMPFILE $seqs[$k]);}
	close(TMPFILE);
	&System("$hh/pdbfilter.pl $root++.in $root++.out -id $idmax -cov $covmin");
	&System("cat $root++.out >> $root++.fas");
    }
    &System("$hh/pdbfilter.pl $root++.fas $outfile -id $idmax -cov $covmin");
}
exit;


# Read sequences in infile beginning at index $k
sub ReadSequences() 
{
    my $infile=$_[0];
    my $k=$_[1];
    my $k0=$k;
    if ($v>=3) {printf("Reading $infile ... \n");}
    open (INFILE,"<$infile") || die ("ERROR: cannot open $infile for reading: $!\n");
    while ($line=<INFILE>) {
	if ($line=~/^>(\S+)/o) {
	    if ($pdbid && !$lens{$pdbid}) {
		if ($len<26) {$seq.=('X'x(26-$len))."\n";} # add 'X' to make $seq at least 26 resiudes long
		$lens{$pdbid}=$len;
		$seqs[$k++]=$seq;	    
	    }
	    $pdbid=$1;
	    $seq=$line;
	    $len=0;
	} else {
	    $seq.=$line;
	    $len+=length($line)-1;
	}
    }
    if ($pdbid && !$lens{$pdbid}) {
	if ($len<26) {$seq.=('X'x(26-$len))."\n";} # add 'X' to make $seq at least 26 resiudes long
	$lens{$pdbid}=$len;
	$seqs[$k++]=$seq;
    }
    close(INFILE);
    if ($v>=2) {printf("Read %i sequences from $infile ... \n",$k-$k0);}
    return $k;
}


sub System() {
    if ($v>=2) {print("$_[0]\n");} 
    return system($_[0]);
}
