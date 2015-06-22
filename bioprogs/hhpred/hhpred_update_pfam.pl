#!/usr/bin/perl -w
#
# Update for Munich cluster by Michael (Feb 2008)
#
# Check for new version of pfam A and B databases and update the hhsearch Pfam A and B databases if necessary
# This script will be launched once a week 
#
#
# Wall time for pfamA/B_21.0 on vnode1: ~12h ??
#
# List the cronjob table (Tuebingen cluster) with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      03      *       *       1       perl /cluster/bioprogs/hhpred/hhpred_update_pfam.pl 2.0 -A > /cluster/tmp/tkcron/hhpred_update_pfam.log 2>&1
# dow = day of week (0=Sun, 1=Mon, ...)
#
# new crontab
# List the cronjob table with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      22      *       *       Thu     /cluster/scripts/update_scripts/hhpred/hhpred_update_pfam.pl 2.0 -A > /cluster/user/manager/log/db_update/hhpred_update_pfam.log 2>&1

use strict;

use lib "/cluster/scripts/update_scripts/hhpred";
use UpdatePath;

$|= 1; # Activate autoflushing on STDOUT
 
# Variables/constants
my $v=2;
my $target_dir="/cluster/tmp/db_update/databases/pfam";

my $logfile="/cluster/user/manager/log/db_update/hhpred_update_pfam.log";

my $pfamftp="ftp://ftp.sanger.ac.uk/pub/databases/Pfam/current_release"; # remote directory
my $pfamAfile="Pfam-A.full"; 
my $pfamBfile="Pfam-B";

my $help="
Check pfam ftp site for new version of pfam database. 
  (Compare size of $pfamftp/$pfamAfile.gz 
   with size of $newdbs/<pfam??.?>/$pfamAfile.gz)
If new version found, update the hhsearch pfam database in directory $newdbs
 * run pfam.pl <pfamfile> to create *.a3m files
 * run hhmake.pl to create *.hhm files
 * copy all files from local HD to $newdbs/
 * concatenate all *.hhm files to new pfam??.?/db/pfamA.hhm
 * make tar files and put to ftp.tuebingen.mpg.de/pub/protevo/HHsearch/databases 
 * Write log to $logfile and send by mail 

Usage:   hhpred_update.pl Neff <options>
Options:
 -f          force recalculation of PfamA/B even if no new version is found
 -A          make PfamA (default)
 -B          make PfamB
 -AB         make PfamA with Neff and PfamB with Neff=2.0

Example: hhpred_update.pl 0 -AB
Example: hhpred_update.pl 2.0 -B 
\n";

my $line;         # input line
my $pfamfile;
my $pfamdb,       # "pfamA" or "pfamB"
my $oldpfamdir;   # directory for current pfam on web cluster, excluding path
my $newpfamdir;   # directory for new pfam on web cluster, EXCLUDING path
my $size;         # size of pfamfile (Pfam_a.full) (to check whether there is a new version)
my @old;          # old/current pfam files/directories
my $Neff_min=0;   # ignore alignments with Neff<Neff_min;  0: don't ignore any
my $force=0;      # force rebuilt of pfamA/B
my $AorB="A";     # build PfamA or PfamB?
my $both=1;
my $i;


if (@ARGV<1) {die($help);}
$Neff_min=$ARGV[0];

my $options="";
for (my $i=1; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# Options
if ($options=~s/ -f / /g) {$force=1;}
if ($options=~s/ -A / /g) {$AorB="A"; $both=0;}
if ($options=~s/ -B / /g) {$AorB="B"; $both=0;}
if ($options=~s/ -AB / /g){$AorB="A"; $both=1;}
if ($AorB eq "B" && $Neff_min<1) {$Neff_min=1.0; print("Forcing Neff to 1.0\n");}

&CreatePath($target_dir);

# Check if updates of PfamA or PfamB exist on the remote server. Exit if no update
if (! &CheckPfam() && !$force) {exit;}

print("Updating pfam database from $oldpfamdir to $newpfamdir\n");
printf("Time %s\n",`date`);

# Run pfam.pl on queue to create a3m alignment files and hhm files in local dir
printf("\nCreating a3m alignment files ...\n");
&chdir("$target_dir/$newpfamdir");
&System("$env_vars; echo 'cd $target_dir/$newpfamdir; $hh/pfam.pl -Neff $Neff_min -i $target_dir/$pfamfile' | $qsub_only -q long -l bg -sync y");
printf("Time %s",`date`);

# Move all new a3m, hhm, tar, and tar.gz files to new pfam directory
&mkdir("$target_dir/$newpfamdir/db");
&System("rsync -a $target_dir/$newpfamdir $newdbs/$oldpfamdir/"); # copy pfam directory to within old one

# Concatenate all hmm files in $newpfamdir
printf("\nConcatenate all hmm files in $newpfamdir ...\n");
$newpfamdir=~/(pfam.*)_/;
$pfamdb=$1;
&System("cd $newdbs/$oldpfamdir/$newpfamdir/; ls | grep '\.hhm' | xargs -ifile cat file > $newdbs/$oldpfamdir/$newpfamdir/db/$pfamdb.hhm"); # takes ~2min for 8000 files
printf("\nTime %s",`date`);

# Moving $newpfamdir to $newdbs and $oldpfamdir to $olddbs
printf("\nMoving $newpfamdir to $newdbs and $oldpfamdir to $olddbs/ ...\n");
if (-e "$olddbs/$oldpfamdir" && $oldpfamdir) {&System("rm -rf $olddbs/$oldpfamdir");}
&System("mv $newdbs/$oldpfamdir/$newpfamdir $newdbs/");
&System("mv $newdbs/$oldpfamdir $olddbs/");
printf("Time %s",`date`);
#print("Press enter to continue...\n"); <STDIN>;

# Generating new tar-files
printf("\nGenerating new tar-files ...\n");
&chdir ("$target_dir/$newpfamdir/");
&TarZip("$target_dir/$newpfamdir.hhm.tar.gz","*.hhm");
&TarZip("$target_dir/$newpfamdir.a3m.tar.gz","*.a3m");
printf("Time %s",`date`);

# Copy tar files to ftp server
&chdir ($target_dir);
print("Transferring tar files to $ftp_server ...\n");
open (FTP,"| ftp -n $ftp_server\n") || die("Error: could not open ftp connection: $!\n");
print("ftp -n $ftp_server\n");
print(FTP "quote USER $ftp_user\n");
print(    "quote USER $ftp_user\n");
print(FTP "quote PASS $ftp_pass\n");
print(    "quote PASS $ftp_pass\n");
print(FTP "cd HHsearch/databases\n");
print(    "cd HHsearch/databases\n");
print(FTP "prompt\n");
print(    "prompt\n");
print(FTP "mdelete $oldpfamdir.*.tar.gz\n");
print(    "mdelete $oldpfamdir.*.tar.gz\n");
print(FTP "put $newpfamdir.hhm.tar.gz\n");
print(    "put $newpfamdir.hhm.tar.gz\n");
print(FTP "put $newpfamdir.a3m.tar.gz\n");
print(    "put $newpfamdir.a3m.tar.gz\n");
print(FTP "quit\n");
print(    "quit\n");
close(FTP);

#&System("rm $target_dir/$newpfamdir.hhm.tar.gz"); # Commented for DEBUGGING!!!
#&System("rm $target_dir/$newpfamdir.a3m.tar.gz"); # Commented for DEBUGGING!!!
#&System("rm -rf $target_dir/$newpfamdir");        # Commented for DEBUGGING!!!
printf("Time now %s",`date`);

# Send WARNING mail if errors in logfile found 
#my $error;
#open(LOG,"<$logfile") || die("Error: could not open $logfile: $!\n");
#while ($line=<LOG>) {
#    if ($line=~/error/i || $line=~/uninitialized/ || $line=~/job not finished properly/ || $line=~/{ba}sh: / || $line=~/mv: / || $line=~/cp: / || $line=~/rmdir: /) {$error=$line;}
#}
#close(LOG);
#if ($error) {
#    # Mail log files to me (official sender is hardcoded in mail.pl: mpi-toolkit)
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"ERROR in $newpfamdir: $line\" $logfile "); 
#} else {
#    # Mail log files to me (official sender is hardcoded in mail.pl: mpi-toolkit)
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"New $newpfamdir\" $logfile "); 
#}

if ($both==1) {
    $AorB="B";
    &System("/cluster/scripts/update_scripts/hhpred/hhpred_update_pfam.pl 2.0 -B");
}

exit;


# Make tar file and zip it into $tarfile.gz
# Call with &TarZip(tarfile.gz,globex); 
sub TarZip()
{
    unlink("$_[0]");    # delete old tar file
    my @files = glob($_[1]); # must be in right directory!!
    # Read file list from STDIN (-T -), tar into file $_[0] (-cf $_[0]) and gzip (-z):  
    open(FILENAMES,"| tar -czf $_[0] -T-") || die("Error: could not execute '| tar -czf $_[0] -T-': $!\n");
    my $n=0;
    foreach my $file (@files) {
	print(FILENAMES "$file\n");
    }
    close(FILENAMES);
}


######################################################################################################################
# Check if update of PfamA or B is available on remote ftp server
######################################################################################################################
sub CheckPfam() 
{
    my $oldversion=0;   # current version number of pfam for hhpred
    my $newversion=0;   # new version number of pfam for hhpred
    my $size;           # size of current pfam-A/B file  (to check whether there is a new version)
    my $newsize;        # size of new pfam-A/B file

    if ($AorB eq "A") {$pfamfile=$pfamAfile;} else {$pfamfile=$pfamBfile;}

    chdir "$newdbs" || die "cannot chdir to $newdbs: $!";     # change to update directory for wget
    $oldpfamdir=(glob "pfam".$AorB."*")[0];
    if (!defined $oldpfamdir) {
	print("Error: no old pfam??.? version found. The program has to be run on one of the web or cluster nodes\n");
    exit;
    }
    if ($oldpfamdir=~/pfam[AB]_(\d\S*)/) {$oldversion=$1;}
    
    # Check pfam ftp site for Pfam-A/B update 
    if (-e "$target_dir/$pfamfile.gz") {
	$size=(stat "$target_dir/$pfamfile.gz")[7];                            # record size of current Pfam-A.full file
    } else {$size=0;}

    # Download version file and pfam file
    &chdir("$target_dir");
    &System("rm -f version*");
    &System("wget --passive-ftp --progress=dot:mega -N $pfamftp/version*");  # wget version file
    my @pfams = glob "version*";
    $pfams[$#pfams]=~/version_(\S+)\.gz/;
    $newversion=$1;

    $newpfamdir="pfam".$AorB."_".$newversion;
    if (!-e "$target_dir/$newpfamdir") {&mkdir("$target_dir/$newpfamdir");}

    if ($oldversion eq $newversion) {
	print("Pfam version number has not changed. (Probably my file $target_dir/$pfamfile.gz got deleted somehow.) $oldversion still up-to date\n");
	print("\n******* No new pfam-$AorB version found *********\n\n");
	return 0;
    }

    &System("wget --passive-ftp --progress=dot:mega -N $pfamftp/$pfamfile.gz"); # wget pfamfile with update option -N
    $newsize=(stat "$target_dir/$pfamfile.gz")[7];
    print("Size of current $pfamfile.gz = $size   Size of new $pfamfile.gz = $newsize\n");
    
    # New version of Pfam-A/B found? 
    if ($size<$newsize) {
	
	print("******* New pfam-$AorB version found! New version is pfam$AorB"."_$newversion *******\n");
	
	# Uncompress pfam-A/B file
	if (-e "$target_dir/$pfamfile") {&System("rm $target_dir/$pfamfile");}
	&System("gunzip -c $target_dir/$pfamfile.gz > $target_dir/$pfamfile"); # we want to keep the .gz version
	return 1;

    } else {
	print("\n******* No new pfam-$AorB version found *********\n\n");
	return 0;
    }
}
    
#####################################################################################################

# Create tmp directory (plus path, if necessary)
sub CreatePath() 
{
    my $suffix=$_[0];
    while ($suffix=~s/^\/[^\/]+//) {
	$_[0]=~/(.*)$suffix/;
	if (!-d $1) {mkdir($1,0777);}
    } 
}

# System call
sub System()
{
    if ($v>=2) {printf("%s\n",$_[0]);} 
    return system($_[0])/256;
}

sub mkdir()
{
    if ($v>=2) {printf("mkdir %s\n",$_[0]);} 
    return mkdir $_[0];
}

sub chdir()
{
    if ($v>=2) {printf("chdir %s\n",$_[0]);} 
    return chdir $_[0];
}

