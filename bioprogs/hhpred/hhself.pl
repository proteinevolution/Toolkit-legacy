#!/usr/bin/perl -w
# Show dot plot comparison of query HMM with itself 
# If HMM does not yet exist build alignment and HMM 
# Usage: hhself.pl infile (without extension)

BEGIN { 
#    push (@INC,"/home/soeding/perl"); 
}
use strict;
$|= 1; # Activate autoflushing on STDOUT

# Default values:
our $v=2;                         #verbose mode
my $buildali="~/hh/buildali.pl";
my $hhmake  ="~/hh/hhmake";
my $hhalign ="~/hh/hhalign";
my $win=10;
my $thr=0.5;
my $scale=2;

    my $usage="
 Show dot plot comparison of query HMM with itself 
 If HMM (query.hhm) does not yet exist use alignment to build HMM  
 If alignment (query.a3m) does not yet exist use query or query.seq to build alignment
 Usage: hhself.pl query [options] 
 Options:
  -w int     average score in dotplot over window [i-W..i+W] (default=$win)
  -t float   score threshold for dotplot (default=$thr)
  -s int     size of unit cell in pixels  (default=$scale)
\n";

if (@ARGV<1) {die ($usage);}

###############################################################################################
# Processing command line input
###############################################################################################

my $query=shift(@ARGV);
my $infile;              # sequence file
if ($query =~/(.*)\..*/)  {$infile=$query; $query=$1;} else {$infile="$query.seq";}

my $options=join(" ",@ARGV);

#Verbose mode? 
if ($options=~s/-v\s*(\d)//g) {$v=$1;}
if ($options=~s/-v//g) {$v=2;}

#Set paramteres
if ($options=~s/-w\s+(\d+)//g) {$win=$1;}
if ($options=~s/-t\s+(\S+)//g) {$thr=$1;}
if ($options=~s/-s\s+(\d+)//g) {$scale=$1;}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}


# Build alignment and HMM
if (! -e "$query.hhm") {
    if (! -e "$query.a3m") {
	&System("$buildali -cov 80 $infile");
    }
    &System("$hhmake -i $query.a3m");
}

# Run self-comparison
&System("$hhalign -i $query.hhm -t $query.hhm -p $query.png -ssm 0 -pthr $thr -psca $scale -pwin $win -v $v ");

exit(0);






################################################################################################
### System command
################################################################################################
sub System()
{
    my $command=$_[0];
    if ($v>=2) {print("$command\n");} 
    return system($command)/256; # && die("\nERROR: $!\n\n"); 
}

