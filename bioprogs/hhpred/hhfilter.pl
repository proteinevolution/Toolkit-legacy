#! /usr/bin/perl -w
# Usage: hhfilter.pl dbfile  
# hhfilter all globbed files in current directory to db-file

my $rootdir;
BEGIN {
    if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} else {$rootdir="/cluster";}
};
use lib "$rootdir/bioprogs/hhpred";
use lib "/cluster/lib";

use strict;
use MyPaths;      # config file with paht variables for nr, blast, psipred, pdb, dssp etc.

# Default values:
# Filter thresholds for sequences before aligning with clustal and building an HMM 
my $cov=0;                        #minimum coverage before clustal

# directory path

print ("Running hhfilter.pl @ARGV:\n");

if (scalar(@ARGV)<1) 
{
    print("\nRun hhfilter on each file (edit manually in this file!)\n"); 
    print("OR prepare FASTA files *.fas and *.reduced.fas for an update opf the hhcluster database\n"); 
    print("Usage:   hhfilter.pl 'file glob'\n"); 
    print("Example: hhfilter.pl '*.a3m' [hhfilter options] > hhfilter.log 2>&1\n\n"); 
    exit;
}

my $update=0;
my $options="";
for (my $i=1; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# General options
#if ($options=~s/ -u //g) {$update=1;}

my $glob = $ARGV[0];
my @files = glob("$glob"); #read all such files into @files 
my $file;
my $base;
my $root;
my $line;
if (@ARGV>=2 && $ARGV[1] eq "-u") {$update=1;}

print (scalar(@files)." files read in. Starting selection loop ...\n");
my $n=0;
foreach $file (@files)
{   
    $n++;
    if ($file =~/^(.*)\..*?$/) {$base=$1;} else {$base=$file;}
    if ($base =~/^.*\/(.*?)$/) {$root=$1;} else {$root=$base;}
    print(">>>>>>>> $n: $file <<<<<<<<\n");
    if (0) {
	# Put whatever you like here
	&System("$hh/hhfilter -M a3m -i $base.a3m -o $base.fil.a3m -diff 100");
    } else {
	# This generates the FASTA files for the database update of hhcluster (for 'Show Query Alignment')
	&System("$hh/hhfilter -M a3m -i $base.a3m -o /tmp/$root.tmp.a3m -diff 100");
	&System("$perl/reformat.pl /tmp/$root.tmp.a3m $base.fas");
	&System("$hh/hhfilter -M a3m -i $base.a3m -o /tmp/$root.tmp.a3m -diff 50");
	&System("$perl/reformat.pl -r /tmp/$root.tmp.a3m $base.reduced.fas");
	&System("rm /tmp/$root.tmp.a3m");
    }
    print("\n");
}
sleep(1);
print("Finished hhfilter.pl\n");
exit(0);

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

