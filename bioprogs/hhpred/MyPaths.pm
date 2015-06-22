package MyPaths;

my $rootdir;
BEGIN {
   if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} 
   else {$rootdir="/cluster";}
};

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
use Exporter;
our $VERSION=1.00;
our @ISA          = qw(Exporter);
#our @EXPORT       = qw($nr $nre $nrf $nr90 $nr70 $nr90f $nr70f $dummydb $perl $hh $hhblits $dsspdir $dssp $pdbdir $pdbdivdir $ncbidir $execdir $datadir $blastpgp $calhhm $hmmerdir $newdbs $olddbs $ftp_server $ftp_user $ftp_pass $ftp_protevo $database_dir $bioprogs_dir $pdb_dir $tmp_dir $env_vars $qsub $rsub);
our @EXPORT       = qw($nr $nre $nr90 $nr70 $dummydb $perl $hh $hhblits $dsspdir $dssp $pdbdir $pdbdivdir $ncbidir $execdir $datadir $blastpgp $calhhm $hmmerdir $newdbs $olddbs $ftp_server $ftp_user $ftp_pass $ftp_protevo $database_dir $bioprogs_dir $pdb_dir $tmp_dir $env_vars $qsub $rsub); # replaced nrf by nr, nr90f by nr90 and nr70f by nr70 in Tuebingen

# Set directory paths and file locations
our $database_dir="$rootdir/databases";   # database directory
our $bioprogs_dir="$rootdir/bioprogs";    # bioprogs directory
our $hh   = "$bioprogs_dir/hhpred";
our $hhblits = "$bioprogs_dir/hhblits";
our $perl = "$bioprogs_dir/hhpred";

# Sequence databases
our $nr    =   "$database_dir/standard/nr";             # nr database to be used
our $nre   =   "$database_dir/standard/nre";            # nr database to be used
#our $nrf   =   "$database_dir/standard/nr";            # nr database to be used # replaced nrf by nr in Tuebingen
our $nr90  =   "$database_dir/standard/nr90";           # large nr database to be used
our $nr70  =   "$database_dir/standard/nr70";           # large nr database to be used
#our $nr90f =   "$database_dir/standard/nr90";          # large nr database to be used # replaced nr90f by nr90 in Tuebingen
#our $nr70f =   "$database_dir/standard/nr70";          # reduced nr database to be used # replaced nr70f by nr70 in Tuebingen
our $dummydb=  "$database_dir/do_not_delete/do_not_delete"; # blast database consisting of just one sequence

# HHpred databases
our $calhhm=   "$database_dir/hhpred/cal.hhm";     # 
our $newdbs=   "$database_dir/hhpred/new_dbs";     # directory containing new HHpred databases
our $olddbs=   "$database_dir/hhpred/old_dbs";     # directory containing old HHpred databases

# Structures
our $pdbdir=   "$database_dir/pdb/all";            # where are the pdb files?
our $pdb_dir=   $pdbdir;                           # where are the pdb files?
our $pdbdivdir ="$database_dir/pdb/divided";
our $dsspdir=  "$database_dir/dssp/data";          # where are the dssp files?
our $dssp=     "$database_dir/dssp/bin/dsspcmbi";  # where is the dssp binary

# PSIPRED etc
our $ncbidir = "$bioprogs_dir/blast/bin";          # Where the NCBI programs have been installed 
our $execdir = "$bioprogs_dir/psipred/bin";        # Where the PSIPRED V2 programs have been installed
our $datadir = "$bioprogs_dir/psipred/data";       # Where the PSIPRED V2 data files have been installed    
our $blastpgp= "$ncbidir/blastpgp";
our $hmmerdir= "$bioprogs_dir/hmmer/binaries";

# FTP
our $ftp_server="ftp.tuebingen.mpg.de";   # our ftp server
our $ftp_user="protevo";                  # our userid 
our $ftp_pass="fzeS8Y";                   # our psswd
our $ftp_protevo ="ftp.tuebingen.mpg.de/pub/protevo";

# Environment variables for SGE and rsub
our $env_vars=":";#". /usr/local/sge/default/common/settings.sh; export RUBYLIB=/cluster/user/toolkitmgr/lib; export GEM_HOME=/cluster/user/toolkitmgr/gems";
our $qsub="$env_vars; qsub";        # qsub command to submit one single job
our $rsub="$env_vars; export GEM_PATH=/ebio/abt1_share/toolkit_dev/lib/gems:/var/lib/gems/1.8; $rootdir/script/rsub"; # rsub command to submit various jobs

return 1;
