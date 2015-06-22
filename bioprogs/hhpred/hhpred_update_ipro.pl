#!/usr/bin/perl -w
#
# Update for Munich cluster by Michael (Jan 2008)
#
# Update the hhsearch InterPro database, or rather, its member databases:
# panther, tigrfam, pirsf, superfamily and CATH/Gene3D (not Pfam and Smart)
# This script will be launched once a week (se below) by fcron on the vnode1 (comphead1v1)
#
# What the script needs:
#  * vnode1 must be able to log into the compcluster without password via ssh/rsync with public/private key pairs
#  * vnode1 must be able to send mail (using my perl script mail.pl, which uses perls Mail::Sender package. 
#  * local tmp directory for vnode1 at /mnt/spare0/tmp/
#
# Wall time for interpro_14.0 on single CPU of vnode1: ~2h:30m
#
# List the cronjob table (Tuebingen cluster) with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      03      *       *       6       perl /cluster/bioprogs/hhpred/hhpred_update_ipro.pl 1 > /cluster/tmp/tkcron/hhpred_update_ipro.log 2>&1
# dow = day of week (0=Sun, 1=Mon, ...)

# List the cronjob table with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      03      *       *       6       perl /cluster/bioprogs/hhpred/hhpred_update_ipro.pl 1 > /cluster/tmp/tkcron/hhpred_update_ipro.log 2>&1
# dow = day of week (0=Sun, 1=Mon, ...)

# Directory structure 
# $target_dir/interpro2go
#             names.dat
#             shortnames.dat
#             iprscan/data/interpro.xml
#                          Gene3D.hmm
#                          Pfam.hmm
#                          TIGRFAMs_HMM.LIB
#                          sf_hmm
#                          smart_HMMs
#                          superfamily.tab
#                          superfamily.hmm
#                          panther/globals/names.tab
#                          panther/books/PTHR10001/hmmer.hmm
#                                        PTHR10002/hmmer.hmm
#                                        ...

use strict;
use lib "/cluster/scripts/update_scripts/hhpred";
use UpdatePath;

$|= 1; # Activate autoflushing on STDOUT
 
# Member databases that will be extracted from InterPro
my @db = ("panther",  "tigrfam", "pirsf", "supfam", "CATH" ); 

# Variables/constants
my $v=2;
my $target_dir="/cluster/tmp/db_update/databases/ipro";

my $logfile="/cluster/user/manager/log/db_update/hhpred_update_ipro_calc.log";

my $ftp="ftp://ftp.ebi.ac.uk/pub/databases/interpro";

my $help="
Update the HMMER InterPro database for HHsearch in directory $newdbs
 * Write log to '$logfile' and send by mail 

Usage:    hhpred_update.pl 1 <options>
Options:
 -f       force rebuild of database (even if no updated version available)


Example:  hhpred_update_ipro.pl 
\n";

my $line;         # input line
my @lines;        # to read in a whole file at once
my $acc;          # accession code of HMM
my $name;         # single-word name of HMM
my $desc;         # DESC record of HMM
my $id;           # 
my $IPR;          # InterPro ID
my $db;           # Takes values $db[0] ... $db[4]
my $i;
my $n;
my $max_hmms_per_db=100000;
my $dbcat = " ".join(" ",@db)." ";
my $force=0;      # force rebuilt of interpro
my $updated=0;    # one of the files of remote InterPro was updated => update local InterPro
my $version;      # new interpro version (e.g. "15.0")


if (@ARGV<1) {die($help);}

# Options from command line
my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}
if ($options=~s/ -f / /g) {$force=1;}

&CreatePath($target_dir);

# Check if updates of PfamA or PfamB exist on the remote server. Exit if no update
if (! &CheckInterPro() && !$force) {exit;}

print("Updating InterPro database version $version in $target_dir\n");

###############################################################################################################################

# Get short form of date, e.g. 22Dec05
my $date=`date`;
$date=~/\S+\s+(\S\S\S)\s+(\d+)\s+\S+\s+\S+\s+\d\d(\d\d)/;
printf("Time %s\n",$date);
$date=$2.$1.$3;

# Remove old directories and make new ones
chdir($target_dir) || die("Can't change to $target_dir: $!\n");
foreach my $db (@db) {
    &System("rm -rf $db"."_*/");
    mkdir("$db"."_$date/");
    mkdir("$db"."_$date/db/");
}

###############################################################################################################################
# Running calculation on queue

print("\nCall hhpred_update_ipro_calc.pl for calculations on cluster\n");
if (&System("$env_vars; echo '/cluster/scripts/update_scripts/hhpred/hhpred_update_ipro_calc.pl -target $target_dir -date $date >> $logfile ' | $qsub_only -q normal -l bg -sync y") != 0) {
    print "Error while sending sending jobs to queue!\n";
    exit(1);
}
printf("Time now %s",`date`);

###############################################################################################################################

print "\nBuild database files...\n";

# Move all files to new_dbs and concatenate all hmm files into database file 
my $cur_interpro = (glob "$newdbs/interpro_*")[0];
if (!$cur_interpro) {$cur_interpro="$newdbs/interpro_dummy";}
foreach my $db (@db) {

    &chdir("$target_dir/$db"."_$date/") || die("Can't chdir: $!\n");
    &MakeCoreA3mFiles("$target_dir/$db"."_$date/");

    # Copy db to $newdbs/interpro_XXYYYZZ directory
    &System("rsync -a  $target_dir/$db"."_$date $cur_interpro/");

    # Concatenate all hmm files
    &System("cd $cur_interpro/$db"."_$date/; ls | grep \.hmm | xargs -ifile cat file > $cur_interpro/$db"."_$date/db/$db.hmm"); # takes ~2min for 8000 files

    # Move new database to $newdbs
    my $olddb = (glob "$newdbs/$db"."_*")[0];                # store name of old version of db
    if (defined $olddb) {&System("mv -f $olddb $olddbs/");}  # migrate old version of db to hhpred/old_dbs/
    &System("mv -f $cur_interpro/$db"."_$date $newdbs/");    # move new db to hhpred/new_dbs/

    # Make tar file
    &chdir("$target_dir/$db"."_$date/");
    &TarZip("$target_dir/$db"."_$date.hmm.tar.gz","*.hmm");

##################################    &System("rm -rf $target_dir/$db"."_$date/");              # clean up local disk
}

# Rename interpro dummy directory after newest version
&System("cd $newdbs/; rm -rf interpro_* ; mkdir interpro_$version");

# Copy interpro.xml and interpro2go file into dummy directory (needed by hhpred_update_pfam.pl -> pfam.pl)
&System("cp $target_dir/iprscan/data/interpro.xml $newdbs/interpro_$version/");
&System("cp $target_dir/interpro2go  $newdbs/interpro_$version/");


# Copy tar files to ftp server
print("Transferring tar files to $ftp_server ...\n");
&chdir("$target_dir/");
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
foreach my $db (@db) {
    print(FTP "mdelete $db"."_*.hmm.tar.gz\n");
    print(    "mdelete $db"."_*.hmm.tar.gz\n");
    print(FTP "put $db"."_$date.hmm.tar.gz\n");
    print(    "put $db"."_$date.hmm.tar.gz\n");
}
print(FTP "quit\n");
print(    "quit\n");
close(FTP);
printf("Time %s",`date`);

#&System("rm $target_dir/*.hmm.tar.gz"); # Commented for DEBUGGING!!!
printf("Time now %s",`date`);

exit;



#####################################################################################################
# Check Interpro for new version of database. 
#  (Compare size of $ftp/$files[0] with size of $newdbs/<interpro_??.?>/update/<interpro_??.?>.gz)
#####################################################################################################
sub CheckInterPro() 
{
    my @files=("iprscan/DATA/iprscan_DATA_*",
	       "iprscan/DATA/iprscan_PTHR_DATA_*",
	       "interpro2go",
	       "names.dat",
	       "short_names.dat"
	       );
    my $new_ipro_file="000";
    my $new_ipropthr_file="000";
    my $line;

    # Check InterPro ftp site for update of iprscan_DATA* file
    &chdir("$target_dir");
    my @iprscan = glob($files[0]);
    my @iprscan_PTHR = glob($files[1]);

    # Get directory .listing to find out which is the newest version
    &System("wget --no-remove-listing --passive-ftp $ftp/iprscan/DATA/");
    &System("rm -f index.html*");
    open(LISTING,"<.listing") || die("Error: cannot open .listing: $!\n");
    while ($line=<LISTING>) {
	if ($line=~/(iprscan_DATA_.*\..*\.tar.gz)/) {
	    if ( ($new_ipro_file cmp $1)<0 ) {$new_ipro_file=$1;}
	} elsif ($line=~/(iprscan_PTHR_DATA_.*\..*\.tar.gz)/) {
	    if ( ($new_ipropthr_file cmp $1)<0 ) {$new_ipropthr_file=$1;}
	}
    }
    close(LISTING);

    $updated  = &CheckDownloadUntar($files[0],"$new_ipro_file");
    $updated  = &CheckDownloadUntar($files[1],"$new_ipropthr_file");
    
    $new_ipro_file=~/iprscan_DATA_(.*)\.tar/;
    $version=$1;

    if ($updated>0) { 
	print("\n******* New InterPro version $version found!  *******\n");
	printf("\nUpdating InterPro database. Time %s",`date`);
	
	# Download accessory tables
	for(my $i=2; $i<@files; $i++) {
	    &System("wget --passive-ftp --progress=dot:mega -N $ftp/".$files[$i]);
	    if ($files[$i]=~/\.gz$/) {&System("gunzip $files[$i]");}
	}
    	return 1;
 
   } else {

	print("\n******* No new InterPro version found *********\n\n");
	return 0;

    }
}


# Compare size of local and remote files and download new version if appropriate
sub CheckDownloadUntar() {

    my $glob = $_[0];
    my $new_data_file=$_[1];
    $glob=~s/.*\///;  # remove path from glob 
    my $size;          
    my @data_files=(glob $glob);
    my $data_file =$data_files[$#data_files];
    if (@data_files>0) {
	$size=(stat "$target_dir/$data_file")[7];     # record size of current InterPro-A.full file
    } else {
	$size=0;
	$data_file = "undefined";
    }

    &System("wget --passive-ftp --progress=dot:mega -N $ftp/iprscan/DATA/".$new_data_file);   # wget with update option -N
    my $new_size=(stat "$target_dir/$new_data_file")[7];
    print("Size of current file  $data_file = $size\n");   
    print("Size of new file      $new_data_file = $new_size\n");
    
    # New version of InterPro found? 
    if ($size!=$new_size) {
	
	# Uncompress and untar InterPro data file
	&System("tar -xzf $target_dir/$new_data_file");  
	return 1;

    } else {
	return 0;
    }
}

#####################################################################################################


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


sub MakeCoreA3mFiles() {
    print("Generating core a3m files for $_[0]\n");
    my @infiles = glob("$_[0]/*.hhm");
    foreach my $infile (@infiles) {
	my $outfile = $infile;
	$outfile =~s/hhm$/a3m/;
	open(INFILE, "<$infile")  || die("Error: could not open $infile: $!\n");
	open(OUTFILE,">$outfile") || die("Error: could not open $outfile: $!\n");
	while ($line=<INFILE>) {if ($line=~/^SEQ\s/) {last;}}
	while ($line=<INFILE>) {
	    if ($line=~/^\#/) {last;}
	    if ($line=~/^>Consens/) {
		while ($line=<INFILE>) {if ($line=~/^>/ || $line=~/^\#/) {last;}} 
	    }
	    print(OUTFILE $line);
	}
	close(INFILE);
	close(OUTFILE);
    }
}


# System call
sub System()
{
    if (defined $_[1]) {
	if ($_[1]<0)  {printf("%s\n",$_[0]); return;}
	if ($_[1]>=2) {printf("%s\n",$_[0]);} 
    } else {
	if ($v>=2) {printf("%s\n",$_[0]);} 
    }
    return system($_[0])/256;
}

# Create tmp directory (plus path, if necessary)
sub CreatePath() 
{
    my $suffix=$_[0];
    while ($suffix=~s/^\/[^\/]+//) {
	$_[0]=~/(.*)$suffix/;
	if (!-d $1) {mkdir($1,0777);}
    } 
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

