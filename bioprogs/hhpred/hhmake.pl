#! /usr/bin/perl -w
# Usage: hhmake.pl dbfile  
# hhmake all globbed files in current directory to db-file

BEGIN { 
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/cluster/soeding/perl");     # for cluster
    push (@INC,"/cluster/bioprogs/hhpred");  # for chimaera  webserver: MyPaths.pm
    push (@INC,"/cluster/lib");              # for chimaera webserver: ConfigServer.pm
}
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with paht variables for nr, blast, psipred, pdb, dssp etc.

# Default values:
# Filter thresholds for sequences before aligning with clustal and building an HMM 
my $cov=0;                        #minimum coverage before clustal

# directory path

print ("Running hhmake.pl @ARGV:\n");

if (scalar(@ARGV)<1) 
{
    print("\nGenerate an HMM with hhmake for each file matching the given file glob\n"); 
    print("Usage:   hhmake.pl 'file glob'\n"); 
    print("Example: hhmake.pl '*.a3m' [-u] [hhmake options] > hhmake.log 2>&1\n\n"); 
    exit;
}

my $update=0;
my $options="";
for (my $i=1; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# General options
if ($options=~s/ -u //g) {$update=1;}

my $glob = $ARGV[0];
my @files = glob("$glob"); #read all such files into @files 
my $file;
my $basename;
my $line;
if (@ARGV>=2 && $ARGV[1] eq "-u") {$update=1;}

print (scalar(@files)." files read in. Starting selection loop ...\n");
my $n=0;
foreach $file (@files)
{   
    $n++;
    if ($file =~/(.*)\..*/)    {$basename=$1;} else {$basename=$file;}
    if (!$update || !-e "$basename".".hhm") {
	print(">>>>>>>> $n: $file <<<<<<<<\n");
	&System("$hh/hhmake -M a3m -i $file $options");
	print("\n");
    }
}
sleep(1);
print("Finished hhmake.pl\n");
exit(0);

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

