#!/usr/bin/perl -w
#
# Update to Munich cluster by Michael (Feb 2008)
#
# Update the hhsearch database pdb70
# This script will be launched TWICE a week 
#  * once a week for adding the newly released pdb structures to the HMM database
#  * once a week for rebuilding the oldest 1000 profiles with a new nr
#
##################################################################
# OLD CRONTAB:
# List the cronjob table with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      05      *       *       4       perl /cluster/bioprogs/hhpred/hhpred_update_pdb.pl -u 0 > /cluster/tmp/tkcron/hhpred_update_pdb.log 2>&1
# 00      01      *       *       7       perl /cluster/bioprogs/hhpred/hhpred_update_pdb.pl -u 1000 > /cluster/tmp/tkcron/hhpred_update_pdb.log 2>&1
# 
# Timing:
# Thursdays at 1AM on raid (10.35.1.26):     PDB gets updated on our /raid (10.35.1.26)
# Thursdays at 4AM on raid (10.35.1.26):     PDB gets copied (differentially) to /clusterraid (10.35.1.61)
# Thursdays at 5AM on comphead1v1.eb.local:  hhpred_update_pdb.pl -u 0  builds alignments/HMMs for new structures
# Sundays   at 1AM on comphead1v1.eb.local:  hhpred_update_pdb.pl -u 1000 rebuilds oldest 1000 alignments/HMMs
##################################################################
# NEW CRONTAB
# List the cronjob table with fcrontab -l, edit with fcrontab -e
# # m     h       dom     mon     dow     command
# 00      04      *       *       Wed     /cluster/scripts/update_scripts/hhpred/hhpred_update_pdb.pl -u 0 > /cluster/user/manager/log/db_update/hhpred_update_pdb.log 2>&1
# 30      22      *       *       Sat     /cluster/scripts/update_scripts/hhpred/hhpred_update_pdb.pl -u 1000 > /cluster/user/manager/log/db_update/hhpred_update_pdb.log 2>&1
# 
# Timing:
# Wednesday at 22:00 : PDB gets update and rsync with the /cluster/databases/pdb directory
# Thursday  at 04:00 : hhpred_update_pdb.pl -u 0  builds alignments/HMMs for new structures
# Saturday  at 22:30 : hhpred_update_pdb.pl -u 1000 rebuilds oldest 1000 alignments/HMMs
##################################################################

use strict;

use lib "/cluster/scripts/update_scripts/hhpred";
use UpdatePath;

$|= 1; # Activate autoflushing on STDOUT
 
# Variables/constants
my $v=2;
my $target_dir="/cluster/tmp/db_update/databases/pdb/tmp";

my $toolkit_root = "/cluster/toolkit/production";

my $logfile="/cluster/user/manager/log/db_update/hhpred_update_pdb.log";

my $pdb70 = (glob "$newdbs/pdb70*")[0];
my @scopfiles=glob("$database_dir/scop/dir.cla.scop.txt_*");
my $scopfile;
my $tupdate=90;   # max time in days before rebuilding alignment
my $nupdate=1000; # rebuild up to this many alignments/HMMs older than $tupdate days

my %neff;
my $neff_cut = 1.0;   # PDBwatchlist cutoff for difference of diversity of new and old HMMs by updating the oldest HMMs

my $help="
Update the hhsearch database pdb70
When no -move option is given:
 * run pdb2fasta.pl to create an up-to-date pdb.fas file
 * run pdbfilter.pl to create an up-to-date filtered pdb70.fas file
 * determine the oldest alignment files to be rebuilt
 * run builddb.pl to generate alignments for all new sequences
 * run hhmake to generate HMMs for all new alignments 
 * move all files not anymore belonging to new pdb70 to $pdb70/old/
 * concatenate all *.hhm files to new pdb.hhm

Options:
 -u <int>   rebuild up to this many alignments/HMMs older than $tupdate days (default=$nupdate)
 -f         force rebuild of all alignments

Usage: hhpred_update_pdb.pl [-u <int>|-f]
\n";


my $line;

if (@ARGV<1) {
    print(STDERR $help);
    print(STDERR "Current pdb70 directory: $pdb70\n");
    if (@scopfiles==0) {die("Error: no SCOP files found with $database_dir/scop/dir.cla.scop.txt_*\n");}
    print(STDERR "\nDon't forget to update SCOP:\n");
    my $version=0; 
    foreach my $file (@scopfiles) {
#	$file=~/_(\d+).?(\d*)(\d*)$/ || $file=~/-(\d+)-(\d+)-(\d+)/;
	if ($file=~/_(\d+).?(\d*)(\d*)$/) {
	    if ("$1.$2$3">$version) {$scopfile=$file; $version="$1.$2";}
	}
    }
    print(STDERR "Most up-to-date scop file: $scopfile\n");
    print(STDERR "\n");
    die();
}

if (!defined $pdb70) {
    print(STDERR "Error: the program has to be run on one of the web or cluster nodes\n");
    exit;
}

my $pdb70new;
my $move=0;
my $options="";
for (my $i=0; $i<=$#ARGV; $i++) {$options.=" $ARGV[$i] ";}

# Set E-value thresholds etc. for inclusion in alignment
if ($options=~s/ -u\s+(\S+) / /g) {$nupdate=$1;}
if ($options=~s/ -f / /g) {$nupdate=1000000; $tupdate=0;}

&CreatePath($target_dir);
    
if (@scopfiles==0) {die("Error: no SCOP files found with $database_dir/scop/dir.cla.scop.txt_*\n");}
my $version=0; 
foreach my $file (@scopfiles) {
#   $file=~/_(\d+).?(\d*)(\d*)$/ || $file=~/-(\d+)-(\d+)-(\d+)/;
    if ($file=~/_(\d+).?(\d*)(\d*)$/) {
	if ("$1.$2$3">$version) {$scopfile=$file; $version="$1.$2";}
    }
}
printf(STDERR "\nUpdating pdb70 database for HHsearch on %s",`date`);
print(STDERR "Current pdb70 directory: $pdb70\n");
print(STDERR "Most up-to-date scop file: $scopfile\n");
printf(STDERR "Time now %s",`date`);

# Make new (temporary) pdb directory
my $date=`date`;
$date=~/\S+\s+(\S\S\S)\s+(\d+)\s+\S+\s+\S+\s+\d\d(\d\d)/;
$pdb70new="pdb70"."_".$2.$1.$3;
if (!-e "$target_dir/$pdb70new") {
    &System("mkdir $target_dir/$pdb70new/");
} else {
    print(STDERR "Removing all *.seq files and all *.dont_generate_pdb files from $target_dir/$pdb70new \n");
    unlink (glob "$target_dir/$pdb70new/*.seq");
    unlink (glob "$target_dir/$pdb70new/*.dont_generate_pdb");
}

# Run pdb2fasta.pl to create an up-to-date pdb.fas file
printf(STDERR "\nCreating updated FASTA sequence file ...\n");
&System("$env_vars; echo \"$hh/pdb2fasta.pl '$pdbdir/*.ent' $target_dir/$pdb70new/pdb.fas -scop $scopfile -v 1 \" | $qsub_only -q long -l bg -sync y");
printf(STDERR "Time now %s",`date`);

# Run pdbfilter.pl to create an up-to-date filtered pdb70.fas file
printf(STDERR "\nFiltering updated FASTA sequence file ...\n");
&System("$env_vars; echo \"$hh/pdbfilter.pl $target_dir/$pdb70new/pdb.fas $target_dir/$pdb70new/pdb70.fas -id 70 -cov 90 \" | $qsub_only -q long -l bg -sync y");
&System("cp $target_dir/$pdb70new/pdb70.fas $target_dir/$pdb70new/pdb_nr");
&System("$ncbidir/formatdb -i $target_dir/$pdb70new/pdb_nr");
printf(STDERR "Time now %s",`date`);

# Create a .seq file for all new alignments and push files older than $tupdate into @oldfiles
printf(STDERR "\nGenerating *.seq files for sequences to build profiles for ...\n");
unlink (glob "$target_dir/$pdb70new/*.seq");
my $nseqs=0;
my $nupdated=0;
my @oldfiles=();
my %new_pdbids=();
open(INFILE,"<$target_dir/$pdb70new/pdb70.fas") || die("Error: could not read from $target_dir/$pdb70new/pdb70.fas: $!");
$/="\n>"; # input record separator
$line=<INFILE>;
$line=~s/^\n*>//;
do {
    if ($line=~/^(\S+)/) {
	$nseqs++;
	my $seqname=$1;
	$new_pdbids{$1}=1;
	$line=~s/>$//;
	if (!-e "$pdb70/$seqname.a3m") { 
	    # Alignment file does not yet exist => new sequence
	    printf("%4i File: %6s   NEW FILE \n",$nupdated,$seqname);
	    open (OUTFILE,">$target_dir/$pdb70new/$seqname.seq") || die("ERROR: Can't open $seqname.seq: $!\n");
	    print(OUTFILE ">".$line);
	    close(OUTFILE);
	    # Generate an empty file for all basenames, for which a pdbfile already exists in the current $pdb70 directory 
	    if (-e "$pdb70/$seqname.pdb") {system("touch $target_dir/$pdb70new/$seqname.dont_generate_pdb");}
	    $nupdated++;
	} else {
	    # Alignment file exists already 
	    my @stat=stat("$pdb70/$seqname.a3m");
	    my $days = sprintf("%i",(time-$stat[9])/3600/24);
	    if ($nupdated<$nupdate && $days>$tupdate) { # file older than $tupdate => push into array to find oldest
		push(@oldfiles,("0" x (5-length($days))).$days.":::".$seqname.":::>".$line."\n");
#		printf(("0" x (5-length($days))).$days.":::".$seqname.":::>".$line."\n");
	    }	    
	}
    }
} while ($line=<INFILE>);
close(INFILE);
$/="\n";

if ($nseqs<=10000) {
    #&System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"ERROR in $pdb70new: only $nseqs sequences in pdb70.fas file. See $logfile ");
    die("ERROR in $pdb70new: only $nseqs sequences in pdb70.fas file.");
}

# Sort alignment files by creation date and write seq file for oldest $nupdate-$nupdated
if (@oldfiles>0) {
    my @sortedfiles = sort {$b cmp $a} @oldfiles; 
    for (my $n=0; $n<&min(scalar(@sortedfiles),$nupdate-$nupdated); $n++) { 
	$sortedfiles[$n]=~s/^(\d+):::(\S+)::://;
	my $seqname=$2;
	printf("%4i File: %6s   old file  Date=%s\n",$n,$seqname,$1);
	open (OUTFILE,">$target_dir/$pdb70new/$seqname.seq") || die("ERROR: Can't open $seqname.seq: $!\n");
	print(OUTFILE $sortedfiles[$n]);
	close(OUTFILE);
	# Check NEFF
	if (-e "$pdb70/$seqname.hhm") { 
	    open (IN, "$pdb70/$seqname.hhm");
	    while (my $line = <IN>) {
		if ($line =~ /^NEFF\s+(\S+)\s+$/) {
		    $neff{$seqname} = $1;
		    last;
		}
	    }
	    close IN;
	}
    }
}

# Building alignments
printf(STDERR "\nBuilding new alignments ...\n");
&System("$rsub -g '$target_dir/$pdb70new/*.seq' -c '$bioprogs_dir/hh/builddb.pl -v 2 FILENAME $target_dir/$pdb70new' -m 10 -l bg");

# Building HMMs
printf(STDERR "\nBuilding new HMMs ...\n");
&System("$rsub -g '$target_dir/$pdb70new/*.a3m' -c '$bioprogs_dir/hh/hhmake -i FILENAME -v 2 -qid 0 -diff 100' -m 10 --mult 100 -l bg");
printf(STDERR "Time now %s",`date`);

# Check for new profiles with changed diversity
my $new_pdbs = "";
if (@oldfiles>0) {
    my @files = glob("$target_dir/$pdb70new/*.hhm");
    foreach my $file (@files) {
	$file =~ /^\S+\/(\S+?)\.hhm/;
	my $seqname = $1;
	open (IN, $file);
	while (my $line = <IN>) {
	    if ($line =~ /^NEFF\s+(\S+)\s+$/) {
		if ($1 > ($neff{$seqname} + $neff_cut) || $1 < ($neff{$seqname} - $neff_cut)) {
		    print "$seqname with new NEFF $1  (old NEFF $neff{$seqname})\n";
		    $new_pdbs .= " $seqname.hhm";
		}
		last;
	    }
	}
	close IN;
    }
}

# Make pdb files for all basenames, for which no file basename.dont_generate_pdb exists
printf(STDERR "\n Making PDB files ...\n");
&System("$rsub -g '$target_dir/$pdb70new/*.seq' -c '$bioprogs_dir/hh/makepdbfile.pl FILENAME' -m 10 -e '$target_dir/$pdb70new/*.dont_generate_pdb' -l bg");
printf(STDERR "Time now %s",`date`);

# Remove all intermediate search temporary files
unlink (glob "$target_dir/$pdb70new/*-*"); 
unlink (glob "$target_dir/$pdb70new/*.sq");
unlink (glob "$target_dir/$pdb70new/*.chk");
unlink (glob "$target_dir/$pdb70new/*.sq");
unlink (glob "$target_dir/$pdb70new/*.small.*");

# Update pdb_nr in standard database directory
$date=`date -I`;
&System("mkdir $database_dir/standard/db_update-$date");
&System("mv $target_dir/$pdb70new/pdb_nr* $database_dir/standard/db_update-$date");
&System("/cluster/scripts/update_scripts/make_pal.sh pdb_nr.pal 'PDB non-redundant' pdb_nr $database_dir/standard/db_update-$date");
# Update pdb_nr in HHpred's database directory
&System("cp $target_dir/$pdb70new/pdb*.fas $pdb70/");

&chdir("$target_dir/$pdb70new");

# Concatenate new hmm files for pdbalert
my $run_pdbalert = 0;
if ($nupdate == 0) {
    &System("ls | grep '\.hhm\$' | xargs -ifile cat file > $database_dir/pdbwatchlist/pdb_new.hhm");
    &System("ls | grep '\.hhm\$' | xargs -ifile cat file > $database_dir/pdbwatchlist/archives/$pdb70new.hhm");
    $run_pdbalert = 1;
} elsif ($new_pdbs ne "") {
    &System("cat $new_pdbs > $database_dir/pdbwatchlist/pdb_new.hhm");
    &System("cat $new_pdbs > $database_dir/pdbwatchlist/archives/$pdb70new-updated.hhm");
    $run_pdbalert = 1;
}

# Move all new a3m/hhm/pdb files to database directory
&System("ls | grep '\.a3m\$' | xargs -ifile mv -f file $pdb70/");
&System("ls | grep '\.hhm\$' | xargs -ifile mv -f file $pdb70/");
&System("ls | grep '\.pdb\$' | xargs -ifile mv -f file $pdb70/");

# Remove $target_dir/$pdb70new directory 
&chdir("$target_dir/$pdb70new");
&System("ls | xargs rm ; rm -f .???"); 
&System("rmdir $target_dir/$pdb70new");

# Move all old a3m and hmm files to $pdb70/old
printf(STDERR "\nMoving all old files to old/...\n");
my $files="";
&chdir($pdb70);
foreach my $file (glob("*.hhm *.a3m *.pdb")) {
    $file=~/(.*)\..*?$/;
    if (! defined $new_pdbids{$1}) {$files.=" $file";}
    if (length($files)>=5000) {
	&System("mv $files $pdb70/old");
	$files="";
    }
}
if (length($files)>1) {
    &System("mv $files $pdb70/old");
}

# Concatenate all hmm files in $pdb70
printf("Appending %i files to pdb_new.hhm ...\n",scalar(keys(%new_pdbids)));
&System("rm -f $pdb70/db/pdb_new.hhm");
&System("cd $pdb70; ls | grep '\.hhm\$' | xargs -ifile cat file > $pdb70/db/pdb_new.hhm"); # takes ~3min for 13000 files
&System("mv $pdb70/db/pdb_new.hhm $pdb70/db/pdb.hhm");

# Rename pdb70 directory with current date
printf(STDERR "Renaming pdb with new date...\n");
if ($pdb70 ne "$newdbs/$pdb70new") {&System("mv $pdb70 $newdbs/$pdb70new");}

# Run PDBalert
if ($run_pdbalert == 1) {
    &System("ssh toolkit\@hn01 '$toolkit_root/script/pdb_alert.rb >> $toolkit_root/log/pdbalert.log 2>&1'");
}

# Generating new tar-files
printf(STDERR "\nGenerating new tar-files ...\n");
&chdir ("$newdbs/$pdb70new");
&TarZip("$target_dir/$pdb70new.hhm.tar.gz","*.hhm");   # takes ~ 1.5min for 13000 files
&TarZip("$target_dir/$pdb70new.a3m.tar.gz","*.a3m");   # takes ~ 15min for 13000 files
printf("Time %s",`date`);

# Copy tar files to ftp server
print(STDERR "Transferring tar files to $ftp_server ...\n");
&chdir ("$target_dir/");
open (FTP,"| ftp -n $ftp_server\n") || die("Error: could not open ftp connection: $!\n");
print(STDERR "ftp -n $ftp_server\n");
print(FTP    "quote USER $ftp_user\n");
print(STDERR "quote USER $ftp_user\n");
print(FTP    "quote PASS $ftp_pass\n");
print(STDERR "quote PASS $ftp_pass\n");
print(FTP    "cd HHsearch/databases\n");
print(STDERR "cd HHsearch/databases\n");
print(FTP    "prompt\n");
print(STDERR "prompt\n");
print(FTP    "mdelete pdb*.hhm.tar.gz\n");
print(STDERR "mdelete pdb*.hhm.tar.gz\n");
print(FTP    "put $pdb70new.hhm.tar.gz\n");
print(STDERR "put $pdb70new.hhm.tar.gz\n");
print(FTP    "mdelete pdb*.a3m.tar.gz\n");
print(STDERR "mdelete pdb*.a3m.tar.gz\n");
print(FTP    "put $pdb70new.a3m.tar.gz\n");
print(STDERR "put $pdb70new.a3m.tar.gz\n");
print(FTP    "quit\n");
print(STDERR "quit\n");
close(FTP);

#&System("rm $target_dir/$pdb70new.a3m.tar*"); # Commented for DEBUGGING!!!
#&System("rm $target_dir/$pdb70new.hhm.tar*");
printf(STDERR "Time now %s",`date`);


# Send WARNING mail if errors in logfile found 
#my $error;
#open(LOG,"<$logfile") || die("Error: could not open $logfile: $!\n");
#while ($line=<LOG>) {
#    if ($line=~/error/i || $line=~/uninitialized/ || $line=~/job not finished properly/ || $line=~/{ba}sh: / || $line=~/mv: / || $line=~/cp: / || $line=~/rmdir: /) {$error=$line;}
#}
#close(LOG);
#if ($error) {
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"ERROR in $pdb70new: $error\" $logfile ");
#} else {
#    my $tot = scalar(keys(%new_pdbids));
#    &System("perl $bioprogs_dir/hhpred/mail.pl johannes.soeding\@tuebingen.mpg.de \"$pdb70new New: $nupdated  Total: $tot\" $logfile "); 
#}

exit;



# Make tar file and zip it into $tarfile.gz
# Call with &TarZip(tarfile.gz,globex); 
sub TarZip()
{
    unlink("$_[0]");    # delete old tar file
    my @files = glob($_[1]); # must be in right directory!!
    printf(STDERR "Time now %s",`date`);
    printf(STDERR "TarZip: globbing %i files with '%s'\n",scalar(@files),$_[1]);

    # Write file with all globbed file names
    # Note: piping directly into stdout did not work reliably!! (sometimes broken pipe)
    open(FILENAMES,">$_[0].files.txt") || die("Error: could not open $_[0].files.txt: $!\n");
    foreach my $file (@files) {
	print(FILENAMES "$file\n");
    }
    close(FILENAMES);
    &System("tar -czf $_[0] -T $_[0].files.txt"); # -T file: read file names from file
    &System("ls -l $_[0]*");
    unlink("ls -l $_[0].files.txt");  # DEBUG
    printf(STDERR "Time now %s",`date`);
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

# System call
sub System()
{
    if ($v>=2) {printf(STDERR "%s\n",$_[0]);} 
    return system($_[0])/256;
}

sub chdir()
{
    if ($v>=2) {printf(STDERR "chdir %s\n",$_[0]);} 
    return chdir $_[0];
}


##################################################################################
# Minimum
##################################################################################
sub min {
    my $min = shift @_;
    foreach (@_) {
	if ($_<$min) {$min=$_} 
    }
    return $min;
}
