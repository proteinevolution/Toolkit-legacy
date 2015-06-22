#!/usr/bin/perl -w
#
# Update for Munich cluster by Michael (Feb 2008)
#
# Update the hhsearch SCOP database

use strict;

use lib "/cluster/scripts/update_scripts/hhpred";
use UpdatePath;

$|= 1; # Activate autoflushing on STDOUT

 
# Variables/constants
my $v=2;
my $logfile="/cluster/user/manager/log/db_update/hhpred_update_scop.log"; # log file 
my @scopdirs=glob "$newdbs/scop70*";
my $scoptxtdir="/cluster/databases/scop";

my $help="
Update the hhsearch database scop70. 

 1. Download the newest SCOP sequence file from the ASTRAL server at 
      http://astral.berkeley.edu/seq.cgi?ver=X.XX&get=scopdom-seqres-gd-sel-gs-bib&item=seqs&cut=70
    (fill in the newest version number in place of the X.XX) 
    and store it as /cluster/databases/scop/scop70_X.XX on the cluster raid. 
 2. Download the newest SCOP file dir.cla.scop.txt at
      http://scop.mrc-lmb.cam.ac.uk/scop/parse/dir.des.scop.txt_1.69 etc. 
    and store it in /cluster/databases/scop/. 
    This is needed for setting links from the PDB to SCOP (not for SCOP itself). 
 3. Run this script! 
 
The script will
 * run builddb.pl on the cluster to generate alignments for all SCOP sequences
 * run hhmake on  the cluster to generate HMMs for all alignments 
 * tar all files into scop70_X.XX.a3m.tar.gz and scop70_X.XX.hhm.tar.
 * concatenate all *.hhm files to new $newdbs/scop70_X.XX/db/scop.hhm
 * put tar file onto ftp server
 * send mail with log file

Execute on the fileserver to create minimum NFS load.
A dummy parameter (0) has to be supplied as option.
If the same SCOP database is to be rebuilt (e.g. new version of SCOP70_1.69) then 
you have to force a rebuild with '-f'. 
 
Usage: hhpred_update_scop.pl [0|-f] &; tail -f $logfile
\n";


if (!@scopdirs) {
    print("Error: no directory $newdbs/scop70*   Note that the program has to be run on the cluster raid\n");
    exit;
}

if (@ARGV==0) {print("$help"); exit;}

&System("touch $logfile",0);
print("Piping STDOUT and STDERR to $logfile\n");
open(STDOUT,">$logfile") || die("Error: can not open $logfile for writing: $!");
open(STDERR,">>$logfile") || die("Error: can not open $logfile for writing: $!");


my $scopold = pop(@scopdirs); # old SCOP directory with a3m and hhm files
my $scopnew;                   # new SCOP directory with a3m and hhm files
my $scopname;                  # new name of SCOP (e.g. SCOP70_1.69)
my $scopfile;                  # name of new SCOP FASTA file (e.g. SCOP70_1.69)
my $line;
my $files="";        
my $file;
my $len;

my $version=0; 
foreach $file (glob("$scoptxtdir/scop70*")) {
    if ($file=~/scop70_([\d.]+)/ && $1>$version) {$scopfile=$file; $version=$1;}
}
if (!$scopfile) {die("Error: no file $scoptxtdir/scop70_([\\d.]+) found \n");}
$scopname=$scopfile;
$scopname=~s/\d+\.\d\d\.\S+?$//; # remove extension (if present)
$scopname=~s/^\S*\///; # remove path name
printf("\nUpdating scop database for HHsearch on %s",`date`);
print("Current scop70 directory: $scopold\n");
print("Most up-to-date scop file: $scopfile\n");
print("New name of SCOP : $scopname\n");
if ($scopold=~/$scopname/ && $ARGV[0] ne "-f") {
    die ("New SCOP database is the same as old version. Use '-f' option to force rebuild. Exiting.\n");
}
printf("Time now %s",`date`);

# Create new directory
$scopnew="$scopold/update/$scopname";
printf("\nCreating new directory $scopnew ...\n");
if (!-e "$scopold/update/") {&mkdir("$scopold/update/");}
if (!-e $scopnew) {&mkdir("$scopnew");}

# The following three numbers should be the same. If not, the script stops with an error message.
my $numseq;   # number of sequences in SCOP file
my $numa3m;   # number of A3M files generated
my $numhhm;   # number of HHM files generated. 
my $numpdb;   # number of HHM files generated. 

# Write single sequences into separate files 
printf("\n Generating sequence files ...\n");
&chdir($scopnew);
&System("$hh/splitfasta.pl $scopfile");  # split scop70_X.XX FASTA file up into one sequence per file: seqname.seq
$numseq=&Count("\.seq");
print("Found $numseq sequences in $scopfile\n");
printf("Time now %s",`date`);

# Build alignments for all files
printf("\n Building A3M alignments ...\n");
if (&System("$rsub -g '$scopnew/*.seq' -c '$hh/builddb.pl -v 2 -pmax 1e-7 FILENAME' -m 20 -l bg") != 0) {
    print "Error while sending sending jobs to queue!\n";
    exit(1);
}
$numa3m=&Count("\.a3m");
print("Generated $numa3m a3m files for $numseq sequence files\n");
printf("Time now %s",`date`);

# Make HMMs
printf("\n Making HMM files ...\n");
if (&System("$rsub -g '$scopnew/*.a3m' -c '$hh/hhmake -i FILENAME -v 2 -diff 100' -m 20 -l bg") != 0) {
    print "Error while sending sending jobs to queue!\n";
    exit(1);
}
$numhhm=&Count("hhm\$");
print("Generated $numhhm hhm files for $numseq sequence files\n");
printf("Time now %s",`date`);

# Make pdb files
printf("\n Making PDB files ...\n");
if (&System("$rsub -g '$scopnew/*.a3m' -c '$hh/makepdbfile -i FILENAME' -m 20 -l bg") != 0) {
    print "Error while sending sending jobs to queue!\n";
    exit(1);
}
$numpdb=&Count("pdb\$");
print("Generated $numpdb hhm files for $numseq sequence files\n");
printf("Time now %s",`date`);

print("\n");
print("Number of *.seq files = $numseq\n");
print("Number of *.a3m files = $numa3m\n");
print("Number of *.hhm files = $numhhm\n");
print("Number of *.hhm files = $numpdb\n");
print("\n");
if ($numseq!=$numa3m || $numa3m!=$numhhm) {
    print("\nError: number of sequences $numseq != number of hhm files $numhhm! \n\n");
    exit(1);
}


# Concatenate all hmm files in $scopnew/db/scop.hhm
printf("Appending hhm files to $scopnew/db/scop.hhm ...\n");
&mkdir("$scopnew/db/");
unlink("$scopnew/db/scop.hhm");
$files=""; $len=0;
foreach $file (glob("*.hhm")) {
    $files.=" $file";
    $len+=length($files)+1;
    if ($len>10000) {
	system("cat $files >> $scopnew/db/scop.hhm");
	$files=""; $len=0;
    }
}
if ($len>0) {system("cat $files >> $scopnew/db/scop.hhm");}

# Rename scopold directory with current date
if ($scopold=~/$scopname/) {&System("mv $scopold $scopold"."old"); $scopold="$scopold"."old";}
&System("mv $scopnew $newdbs/$scopname");
&System("mv $scopold $olddbs/");
$scopnew="$newdbs/$scopname";

# Generating new hhm tar-files
printf("\nGenerating new tar-files ...\n");
$files=""; $len=0;
unlink("$scopnew/$scopname.hhm.tar");    # delete old tar file?
unlink("$scopnew/$scopname.hhm.tar.gz"); # delete old tar file?
&chdir ("$scopnew");
foreach $file (glob("*.hhm")) {
    $files.=" $file";
    $len+=length($files)+1;
    if ($len>20000) {
	system("tar -rvf $scopnew/$scopname.hhm.tar $files > /dev/null");
	$files=""; $len=0;
    }
}
if ($len>0) {system("tar -rvf $scopnew/$scopname.hhm.tar $files > /dev/null");}
&System("gzip $scopnew/$scopname.hhm.tar > /dev/null");

# Generating new a3m tar-files
unlink("$scopnew/$scopname.a3m.tar"); # delete old tar file?
unlink("$scopnew/$scopname.a3m.tar.gz"); # delete old tar file?
$files=""; $len=0;
&chdir ("$scopnew");
foreach $file (glob("*.a3m")) {
    $files.=" $file";
    $len+=length($files)+1;
    if ($len>20000) {
	system("tar -rvf $scopnew/$scopname.a3m.tar $files > /dev/null");
	$files=""; $len=0;
    }
}
if ($len>0) {system("tar -rvf $scopnew/$scopname.a3m.tar $files > /dev/null");}
&System("gzip $scopnew/$scopname.a3m.tar > /dev/null");
printf("Time %s",`date`);

# Copy tar files to ftp server
my $ftp_server="ftp.tuebingen.mpg.de";
my $ftp_user="protevo"; 
my $ftp_pass="fzeS8Y";
&chdir ("$scopnew");
print("Transferring tar files to $ftp_server ...\n");
#open(FTP,"| ftp -n $ftp_server\n");
#print(FTP "quote USER $ftp_user\n");
#print(FTP "quote PASS $ftp_pass\n");
#print(FTP "cd HHsearch/databases\n");
#print(FTP "prompt\n");
#print(FTP "mdelete scop*.tar.gz\n");
#print(FTP "put $scopname.hhm.tar.gz\n");
#print(FTP "put $scopname.a3m.tar.gz\n");
#print(FTP "quit\n");
#close(FTP);

printf("Time now %s",`date`);

close(STDOUT);
close(STDERR);

# Send WARNING mail if errors in logfile found 
#my $error;
#open(LOG,"<$logfile") || die("Error: could not open $logfile: $!\n");
#while ($line=<LOG>) {
#    if ($line=~/error/i || $line=~/uninitialized/ || $line=~/job not finished properly/ || $line=~/{ba}sh: / || $line=~/mv: / || $line=~/cp: / || $line=~/rmdir: /) {$error=$line;}
#}
#close(LOG);
#if ($error) {
#    # Mail log files to me (official sender is hardcoded in mail.pl: mpi-toolkit)
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"ERROR in $scopnew: $line\" $logfile ");  
#} else {
#    # Mail log files to me (official sender is hardcoded in mail.pl: mpi-toolkit)
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"New $scopnew\" $logfile "); 
#}

exit;


# Count files in current directory which contain $_[0] pattern 
sub Count() {
    my $num;
    open(COUNT,"ls | grep '$_[0]' | wc |") or die("Error: could not execute 'ls | grep '\.seq' | wc |': $!\n");
    $num=<COUNT>;
    close(COUNT);
    $num=~/^\s*(\d+)/;
    return $1;
}

# System call
sub System()
{
    if ($v>=2) {printf("%s\n",$_[0]);} 
    return system($_[0])/256;
}

sub chdir()
{
    if ($v>=2) {printf("chdir %s\n",$_[0]);} 
    return chdir $_[0];
}

sub mkdir()
{
    if ($v>=2) {printf("mkdir %s\n",$_[0]);} 
    return mkdir $_[0];
}
