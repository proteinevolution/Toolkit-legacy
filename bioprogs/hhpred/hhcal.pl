#! /usr/bin/perl -w
# Usage: hhcal.pl dbfile  
# calibrate all globbed files in current directory to db-file

use strict;

# Default values:
# Filter thresholds for sequences before aligning with clustal and building an HMM 
# directory path
my $hh="/home/soeding/hh";    #perl directory: querydb.pl, alignhits.pl

if (scalar(@ARGV)<2) 
{
    print("\nCalibrate all globbed HMMs against calibration database\n"); 
    print("Usage:   hhcal.pl 'file glob' calib-db [options]\n"); 
    print("Example: hhcal.pl '*.hhm' cal.hhm > hhcal.log 2>&1\n\n"); 
    exit;
}

my $glob = $ARGV[0];
my $caldb = $ARGV[1];
my $options="";
if (@ARGV>2) {
    $options.=join(" ",@ARGV[2..$#ARGV]);
}
my @files = glob("$glob"); #read all such files into @files 
my $file;
my $basename;
my $line;

print (scalar(@files)." files read in. Starting selection loop ...\n");

foreach $file (@files)
{   
    print(">>>>>>>> $file <<<<<<<<\n");
    if ($file =~/(.*)\..*/)    {$basename=$1;} else {$basename=$file;}
    &System("$hh/hhsearch -v -cal -i $file -d $caldb $options");
    print("\n");

}
exit(0);

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

