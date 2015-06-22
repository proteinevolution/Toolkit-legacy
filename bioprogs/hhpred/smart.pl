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

my $v=2;
my $usage="
Call buildali.pl for all files in fileglob (.fas or .a3m)

Steps to generate SMART database:
* Download SMART database including CLUSTAL alignments (*.aln files) from
  http://smart.embl-heidelberg.de/distribution  LOGIN: smith  PASSWORD: sMarT00
* Reformat *.aln files to FASTA
  > reformat.pl -M 50 '*.aln' .fas
  (You may have to correct a few files manually, i.e. when gap '-' is replaced by blank ' ')
* Call smart.pl to build alignments (*.a3m) around SMART seed alignments 
  > smart.pl -n 3 '*.fas'
* Make HMMs from alignments (*.hhm)
  > hhmake.pl '*.a3m' > hhmake.log 2>&1 &
* copy *.a3m files and *.hhm files to webservers
  soeding@chimaera> cd /cluster/databases/hhpred/new_dbs/
  soeding@chimaera> mkdir smart_01Apr2004
  > scp *.a3m soeding@chimaera:/cluster/databases/hhpred/new_dbs/smart_01Apr2004
  > scp *.hhm soeding@chimaera:/cluster/databases/hhpred/new_dbs/smart_01Apr2004
  soeding@chimaera> cat *.hhm > smart.hhm

Usage:   smart.pl [options] 'fileglob'
Options (in addition to buildali.pl options): 
 -u      update: skip buildali.pl for infile if infile.seq exists
Example: smart.pl -n 0 '*.fas'
\n";

my $options="";
for (my $i=0; $i<@ARGV-1; $i++) {$options.="$ARGV[$i] ";}

if (@ARGV<1) {die("$usage");}

my @infiles=glob($ARGV[@ARGV-1]);
my $infile;
my $format;
my $update=0;
my $base;
my $line;

printf("%i files to process\n",scalar(@infiles));
foreach $infile (@infiles) 
{
    if ($infile!~/(\S+)\.(a3m)/ && $infile!~/(\S+)\.(fas)/) {die("\nError: input extension must be a3m or fas\n");}
    $base=$1;
    $format=$2;
    if ($update && -e $infile.".seq") {next;}
    &System("$hh/buildali.pl -n 3 -$format $options $infile ");
    open(INFILE,"<$base.a3m") || die("Error: cannot open $infile for reading:$!\n");
    my @lines=<INFILE>;
    close(INFILE);
    open(OUTFILE,">$base.a3m") || die("Error: cannot open $infile for reading:$!\n");
    print(OUTFILE "#$base $base-domain (SMART)\n");
    foreach $line (@lines) {print(OUTFILE $line);}
    close(OUTFILE);
    

} # end foreach $infile
exit;

################################################################################################
### System command
################################################################################################
sub System()
{
    if ($v>=2) {printf("%s\n",$_[0]);} 
    return system($_[0])/256;
}

