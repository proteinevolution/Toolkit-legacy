#!/usr/bin/perl -w
#
# updated for Munich cluster by michael (Jan 2008)
#
# Update the CDD database, consisting of Pfam, SMART, COG, KOG, cd 
# Download from a single zipped file of all FASTA alignments and sort alignments into constituent dbs
# This script will be launched once a week (se below) by fcron on the vnode1 (comphead1v1)
#
# WARNING: in Dec06, wget of the data files was VERY unreliable. Most of the times, wget retrieved only a 
# partial file. Therefore, .FASTA files are not removed after retrieval, since then FASTA files from an
# older version are used at least.
#
# What the script needs:
#  * vnode1 must be able to log into the compcluster without password via ssh/rsync with public/private key pairs
#  * vnode1 must be able to send mail (using my perl script mail.pl, which uses perls Mail::Sender package. 
#  * local tmp directory for vnode1 at /mnt/spare0/tmp/
#  * global tmp directory at /cluster/tmp/
#
# Runs about ~40 h on 15 CPUs of cluster
#
# OLD crontab
# List the cronjob table with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      03      *       *       5       perl /cluster/bioprogs/hhpred/hhpred_update_cdd.pl 0 > /cluster/tmp/tkcron/hhpred_update_cdd.log 2>&1

# new crontab
# List the cronjob table with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      20      *       *       Sat     /cluster/scripts/update_scripts/hhpred/hhpred_update_cdd.pl 0 > /cluster/user/manager/log/db_update/hhpred_update_cdd.log 2>&1

use strict;

use lib "/cluster/scripts/update_scripts/hhpred";
use UpdatePath;

$|= 1; # Activate autoflushing on STDOUT
 
# Variables/constants
my $v=2;
my $download_dir="/cluster/tmp/db_update/download";
my $target_dir="/cluster/tmp/db_update/databases/cdd/temp";

my $logfile="/cluster/user/manager/log/db_update/hhpred_update_cdd.log";

my $cddhost="ftp.ncbi.nih.gov";
my $cdddir="pub/mmdb/cdd/";
my $cddftp="ftp://ftp.ncbi.nih.gov/pub/mmdb/cdd";
my $cddfile="fasta.tar";
my $cddidtbl="cddid.tbl";

my @dbs = ("pfam",  "smart", "COG", "KOG", "cd"); # cd must be last database (since it gets all files not contained in other dbs)

my $help="
Check cdd ftp site for new version of cdd database and 
do update on cluster if necessary (runs ~ 4hours, needs <<1GB memory)
 * for each downloaded file:
   - run ccd.pl to generate updated or new alignment and HMM 
   - add files to CDD database and copy links to constituent database that new HMM belongs to
   - set update flag for constituent database 

Usage: hhpred_update_cdd.pl 0|1 [options]
Options:
  0       rebuild if new CDD version is found 
  1       force rebuild: force execution of cdd.pl for all downloaded files and update all constituent databases
 -u       update: build only those a3m and hhm files for which the hmm does not yet exist
 -remind  do not update, only send a reminder by mail
\n";

if (@ARGV<1) {print ($help); exit;}

my $update="";
my $remind=0;

# Options
my $options="";
for (my $i=1; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}
if ($options=~s/ -u / /g) {$update="-e '$target_dir/*.hhm'";}
if ($options=~s/ -remind / /g) {$remind=1;}


printf("Updating CDD database on %s",`date`);
&CreatePath($target_dir);
my $force=$ARGV[0];

if (!&CheckCDD() && !$force) {exit;};

#if ($remind) {
#    printf(STDERR "*************************************************************************************************\n");
#    printf(STDERR "Update cdd with: \n");
#    printf(STDERR "  /cluster/user/soeding/hh/hhpred_update_cdd.pl 1 > /cluster/tmp/tkcron/hhpred_update_cdd.log 2>&1\n");
#    printf(STDERR "*************************************************************************************************\n");
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"New cdd: Please update manually!!\" $logfile "); 
#    exit;
#}

print("Updating CDD database in $target_dir\n");
printf("Time now %s",`date`);

# Genereate a3m and hhm files with cdd.pl on cluster (This will take ~40 h)
print("\n***************************************************************************************************\n");
print("\nCall cdd.pl to generate new alignments on cluster\n");
if (&System("$rsub -g '$target_dir/*.FASTA' -c '$hh/cdd.pl -f $target_dir/cddid.tbl FILENAME' -m 20 -l bg $update") != 0) {
    print "Error while sending sending jobs to queue!\n";
    exit(1);
}
printf("Time now %s",`date`);

my $date=`date`;
$date=~/\S+\s+(\S\S\S)\s+(\d+)\s+\S+\s+\S+\s+\d\d(\d\d)/;
$date=$2.$1.$3;
if (length($date)<=6) {$date="0".$date;}



# For each constituent database: create new database first in $olddbs, then mv to $newdbs
&chdir ($target_dir);
foreach my $db (@dbs) {
    
    print("\nPreparing $db"."_$date ...\n");

    # Create empty $olddbs/$db_$date/
    if (-e "$olddbs/$db"."_$date") {
	&System("rm -f $olddbs/$db"."_$date/*");
    } else {
	&System("mkdir $olddbs/$db"."_$date");
    }

    # Create empty $olddbs/$db_$date/db/
    if (-e "$olddbs/$db"."_$date/db") {
	&System("rm -f $olddbs/$db"."_$date/db/*");
    } else {
	&System("mkdir $olddbs/$db"."_$date/db");
    }
 
    my $dbglob=$db;
    if ($db eq "cd") {$dbglob="";}

    # Copy a3m and hhm files to appropriate directory in $olddbs
    &System("ls |egrep '$dbglob.*\.hhm' |xargs -Iname rsync -a name $olddbs/$db"."_$date/"); 
    &System("ls |egrep '$dbglob.*\.a3m' |xargs -Iname rsync -a name $olddbs/$db"."_$date/"); 

    # Make tar files in target-dir
    &System("ls |egrep '$dbglob.*\.hhm' | tar -czf ../$db"."_$date.hhm.tar.gz -T-"); # read filenames from STDIN
    &System("ls |egrep '$dbglob.*\.a3m' | tar -czf ../$db"."_$date.a3m.tar.gz -T-");

    # Remove copied and tarred files from target-dir/tmp
    &System("ls |egrep '$dbglob.*\.hhm' |xargs rm"); 
    &System("ls |egrep '$dbglob.*\.a3m' |xargs rm"); 

    # Concatenate hhm files in $olddbs/$db_$date/ directory
    &System("cd $olddbs/$db"."_$date/; ls | grep \.hhm | xargs -ifile cat file > $olddbs/$db"."_$date/db/$db.hhm");    
    
    # Move old db from $newdbs to $olddbs and new db from $olddbs to $newdbs 
    &System("mv  $newdbs/$db"."_* $olddbs/");    
    &System("mv  $olddbs/$db"."_$date $newdbs/");    
}

# Rename dummy cdd with new date
&System("rm -rf $newdbs/cdd_*");    
&System("mkdir $newdbs/cdd_$date");    

# Copy tar files to ftp server
&chdir ("$target_dir/..");
print ("\nTransferring tar files to $ftp_server ...\n");
open (FTP,"| ftp -n $ftp_server\n") || die("Error: could not open ftp connection: $!\n");
print("ftp -n $ftp_server\n");
print(FTP "quote USER $ftp_user\n");
print("quote USER $ftp_user\n");
print(FTP "quote PASS $ftp_pass\n");
print("quote PASS $ftp_pass\n");
print(FTP "cd HHsearch/databases\n");
print("cd HHsearch/databases\n");
print(FTP "prompt\n");
print("prompt\n");
foreach my $db (@dbs) {
    print(FTP "mdelete $db"."_*.hhm.tar.gz\n");
    print(    "mdelete $db"."_*.hhm.tar.gz\n");
    print(FTP "mdelete $db"."_*.a3m.tar.gz\n");
    print(    "mdelete $db"."_*.a3m.tar.gz\n");
    print(FTP "put $db"."_$date.hhm.tar.gz\n");
    print(    "put $db"."_$date.hhm.tar.gz\n");
    print(FTP "put $db"."_$date.a3m.tar.gz\n");
    print(    "put $db"."_$date.a3m.tar.gz\n");
}
print(FTP "quit\n");
print("quit\n");
close(FTP);

printf("\nFinished update. Time now %s",`date`);

#&System("rm $localtmp/*.hhm.tar.gz"); # Commented for DEBUGGING!!!
#&System("rm $localtmp/*.a3m.tar.gz"); # Commented for DEBUGGING!!!

# Send WARNING mail if errors in logfile found 
#my ($error, $line);
#open(LOG,"<$logfile") || die("Error: could not open $logfile: $!\n");
#while ($line=<LOG>) {
#    if ($line=~/error/i || $line=~/uninitialized/ || $line=~/job not finished properly/ || $line=~/{ba}sh: / || $line=~/mv: / || $line=~/cp: / || $line=~/rmdir: /) {$error=$line;}
#}
#close(LOG);
#if ($error) {
#    # Mail log files to me (official sender is hardcoded in mail.pl: mpi-toolkit)
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"ERROR in cdd_$date: $line\" $logfile "); 
#} else {
#    # Mail log files to me (official sender is hardcoded in mail.pl: mpi-toolkit)
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"New cdd_$date\" $logfile "); 
#}

exit(0);



######################################################################################################################
# Check if update of CDD is available on remote ftp server
######################################################################################################################
sub CheckCDD()
{

    my $oldcdddir;    # directory for current cdd, excluding path
    my $newcdddir;    # directory for new cdd, EXCLUDING path
    my $size;         # size of cddfile (fasta.tar.gz) (to check whether there is a new version)
    
    # Check cdd ftp site for update
    if (-e "$download_dir/$cddfile.gz") {
	$size=(stat "$download_dir/$cddfile.gz")[7];                              # record size of current Cdd-A.full file
    } else {$size=0;}
    &chdir("$download_dir");
    &System("wget --progress=dot:mega -N $cddftp/$cddfile.gz");   # wget cddfile with update option -N # UNCOMMENT!
    my $newsize=(stat "$download_dir/$cddfile.gz")[7];
    print("Size of current $cddfile.gz = $size   Size of new $cddfile.gz = $newsize\n");
    
    # New version found? 
    if ($size<$newsize || $force) {
	
	printf("\nUpdating CDD database\n");

	# Uncompress and untar cdd file into $globaltmp directory
	&chdir("$target_dir");
	if (&System("tar -xzf $download_dir/$cddfile.gz") != 0) {
	    print "Error with downloaded file! Exit without update!";
	    exit(1);
	}
	
	# Download and uncompress cddid table in $globaltmp 
	&System("wget --progress=dot:mega -N $cddftp/$cddidtbl.gz");   # wget cddfile with update option -N
	if (&System("gunzip -f $target_dir/$cddidtbl.gz") != 0) {
	    print "Error with downloaded file! Exit without update!";
	    exit(1);
	}
	return 1;
	
    } else {
	print("No new cdd version found. Exiting.\n");
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

sub chdir()
{
    if ($v>=2) {printf("chdir %s\n",$_[0]);} 
    return chdir $_[0];
}

# System call
sub System()
{
    if ($v>=2) {printf("%s\n",$_[0]);} 
    return system($_[0])/256;
}

