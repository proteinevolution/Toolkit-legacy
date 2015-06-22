#!/usr/bin/perl -w

# This is a simple script which will carry out all of the basic steps
# required to make a PSIPRED V2 prediction. Note that it assumes that the
# following programs are in the appropriate directories:
# blastpgp - PSIBLAST executable (from NCBI toolkit)
# makemat  - IMPALA utility (from NCBI toolkit)
# psipred  - PSIPRED V2 program
# psipass2 - PSIPRED V2 program
# (Changes by Johannes Soeding, 9.Oct 2003)

use strict;
use IO::Handle;

my $smoothing;
my $biasheli;
my $biasstra;

my $rootdir;
{
    if (defined $ENV{TK_ROOT}) { $rootdir = $ENV{TK_ROOT}; }
    else { $rootdir="/cluster/toolkit/production"; }
}
my $DATABASES = $rootdir."/databases/standard";
my $BIOPROGS = $rootdir."/bioprogs";

$|=1;
if (@ARGV<1) {die("Usage: psipred.pl fastafile [smoothing] [bias_helix] [bias_strand]\n\n");}
my $file      = $ARGV[0];
if (@ARGV==4) {
    $smoothing = $ARGV[1];
    $biasheli  = $ARGV[2];
    $biasstra  = $ARGV[3];
}else{
    $smoothing = 1;
    $biasheli  = 0.98;
    $biasstra  = 1.09;
}
my $dbname  = "$DATABASES/nr90";         # The name of the BLAST data bank for psipred # replaces nr90f by nr90 in Tuebingen
my $ncbidir = "$BIOPROGS/blast";          # Where the NCBI programs have been installed 
my $execdir = "$BIOPROGS/psipred/bin";    # Where the PSIPRED V2 programs have been installed
my $datadir = "$BIOPROGS/psipred/data";   # Where the PSIPRED V2 data files have been installed    
my $blastpgp= "$ncbidir/blastpgp";
my $basename;                                 #file name without extension
my $rootname;                                 #basename without directory path

if ($file =~/(.*)\..*/)    {$basename=$1;} else {$basename=$file;}
if ($basename=~/.*\/(.*)/) {$rootname=$1;} else {$rootname=$basename;}

my $psitmpfas     = $basename . "_psitmp.fasta";
my $psitmpchk     = $basename . "_psitmp.chk";
my $psitmplog     = $basename . "_psitmp.log";
my $psitmpsn      = $basename . "_psitmp.sn";
my $printsn       = $rootname . "_psitmp.fasta";
my $psitmppn      = $basename . "_psitmp.pn";
my $printpn       = $rootname . "_psitmp.chk";
my $psitmpmakemat = $basename . "_psitmp";
my $psitmpmtx     = $basename . "_psitmp.mtx";
my $psitmprm      = $basename . "_psitmp*";

# copy $file into psitmp.fasta
open(FILE,"<$file") || die("Error: cannot open $file: $!\n");
my @file=<FILE>;
close(FILE);
open(FILE,">$psitmpfas") || die("Error: cannot open $psitmpfas: $!\n");
print(FILE @file);
close(FILE);

print("Running PSI-BLAST with sequence ...\n");

# Start Psiblast from checkpoint file tmp.chk that was generated to build the profile
#### was: my $pid=open(PSIOUT,"$blastpgp -b 0 -j 3 -h 0.001 -d $dbname -i $file -C $psitmpchk -a 2|");
#### removed the need for running on two processors!
my $pid=open(PSIOUT,"$blastpgp -b 0 -j 3 -h 0.001 -d $dbname -i $file -C $psitmpchk -a 1 |");

PSIOUT->autoflush(1);
# Did fork work?
if (!defined $pid) {die("Error: could not fork: $!\n");}
if (! $pid) {die("Psiblast did not finish round 2. Inspect $psitmplog to find out what went wrong.\n");}

# Monitor psiblast progress
my $status=0;
open (PSILOG,">$psitmplog") || print("Warning: cannot open psiblast logfile $psitmplog for writing: $!\n");
while (<PSIOUT>) {
    print(PSILOG $_);
#    print($_);
    if (/^\s*$/ && $status>=11) {last;}
    elsif (/^CONVERGED!/)      {$status=0; last;}
    elsif (/^MATRIX:/)         {$status=0; last;}
    elsif (/^Sequences not found previously/ && $status>=10) {$status++;}
    elsif (/^Results from round 1/) {print("Finished round 1\n");}
    elsif (/^Results from round 2/) {print("Finished round 2\n"); $status=10; }
}

if ($status>0) { # Waiting for 'Searching ...'
    my $char;
    my $buffer="";
    my $cycles=0;
    while ($buffer!~/Searching$/ && $cycles<=3*60*5) { # wait 3 minutes maximum
	if (read(PSIOUT,$char,1,0)) {
	    $buffer.=$char;
	    print(PSILOG $char);
	} else {
	    sleep(0.2);	
	    $cycles++;
	}
    }
}
close (PSILOG);
close (PSIOUT);
kill('KILL',$pid); # Kill blastpgp


print("Predicting secondary structure...\n");

# Make human-readable PSSM matrix from binary checkpoint file
open(PNTMP,">$psitmppn") || die("Error: cannot open $psitmppn: $!\n");
print(PNTMP "$printpn");
close(PNTMP);
open(SNTMP,">$psitmpsn") || die("Error: cannot open $psitmpsn: $!\n");
print(SNTMP "$printsn");
close(SNTMP);
system("$ncbidir/makemat -P $psitmpmakemat");

# Do psipred prediction
print("Pass1 ...\n");
system("$execdir/psipred $psitmpmtx $datadir/weights.dat $datadir/weights.dat2 $datadir/weights.dat3 $datadir/weights.dat4 > $basename.ss");

print("Pass2 ...\n");
system("$execdir/psipass2 $datadir/weights_p2.dat $smoothing $biasheli $biasstra $basename.ss2 $basename.ss > $basename.horiz");

# Remove temporary files
unlink (glob("$psitmprm"));

print("Final output files: $basename.ss and $basename.horiz\nFinished.\n");
exit(0);


