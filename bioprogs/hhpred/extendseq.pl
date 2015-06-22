#!/usr/bin/perl -w
BEGIN {
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/home/soeding/pp"); 
    push (@INC,"/home/data/bioprogs/hh");  # On cerberus
}
use strict;   
use Align;

$|=1;  # force flush after each print

#############################################################################
####                    Main                                             ####
#############################################################################


# Default parameters
our $d=0.5*6;  # gap opening penatlty for Align.pm
our $e=0.5*1;  # gap extension penatlty for Align.pm
our $g=0.5*0;  # endgap penatlty for Align.pm
our $v=4;

my $usage = "
Extend sequences:
Read input file with (sub-)sequences in fasta format and for each query sequence 
find corresponding full-length template sequence in database. 
Write LONGEST of the five best-fitting full-length sequence into fasta output file
with original subsequence (or equivalent residues) in capital letters, other residues in lower case.
Usage: extendseq.pl infile dbfile outfile
\n";

if (@ARGV<3) {die $usage;}

# Variable declarations 
my $infile=$ARGV[0];
my $dbfile=$ARGV[1];
my $outfile=$ARGV[2];
my $qfile="query.seq";
my $qblast="query.blast";
my $ncbidir;

if (@ARGV>4) {          # For call by web server with randomized ids
    $qfile = $ARGV[3];
    $qblast = $ARGV[4];
}


# Set directory paths
if (defined $ENV{"SERVER_ADMIN"} && $ENV{"SERVER_ADMIN"}=~ /cerberus/) {
    $ncbidir = "/home/data/bioprogs/blast";        # Where the NCBI programs have been installed # set ncbidir = /usr/local/bin
} else {
    $ncbidir = "/home/soeding/programs/blast";        # Where the NCBI programs have been installed
}

my $line;
my $qname="";          # name of the query sequence (segment) read in from infile
my $tname="";          # name of the full-length template sequence in dbfile that contains qname sequence
my $description;       # description of qname sequence
my $qseq="";           # sequence residues of pdbsequence
my @tnames;            # $tnames[$k] points to an array with the names of full-length template sequences for query sequence k
my %tseqs;             # $tseqs[$tname] contains the residues of template sequence $tname
my @qnames;            # $qnames[$k] is name of k'th sequence read in 
my @qdesc;             # $qdesc[$k] is description of the query
my @qseqs;             # $qseqs[$k] is the string of residues of the k'th query sequence read in
my $k=0;               # index of sequence read in
my $kmax;              # number of sequences read in
my $n=0;               # number of sequences extracted from database

# Go through infile sequence by sequence 
if ($v>2) {print(STDERR "Searching sequences in database ... \n");}
open (INFILE, "<$infile") || die "ERROR: Couldn't open $infile: $!\n";
while (1) {
    $line=<INFILE>;
    if(!$line || $line=~/^>/) {
	if ($qseq ne "") {
	    &FindSequence;
	} 
	if (!$line) {last;}
	chomp($line);
	$line=~/^>\s*(\S+\s*\S*\s*\S*)\s*(.*)/;
	$qname = $1;   
	$description = $2;   
	$qseq="";
    } else {
	chomp($line);
	$qseq.=$line;
    }
}
close (INFILE);
if ($v>2) {print(STDERR "Found $k sequences in database\n");}
$kmax=$k;

# Extract full-length sequences from database
if ($v>2) {print(STDERR "Extracting full-length sequences from database ... ");}
open (DBFILE, "<$dbfile") || die "ERROR: Couldn't open $dbfile: $!\n";
$tname="";
$n=0;
while ($line=<DBFILE>) {
    if( $line=~/^>\s*(\S*)/)
    {
	if (exists $tseqs{$1})
	{ 
	    $tname=$1;
	    $tseqs{$tname}="";
	    $n++;
	} else {
	    $tname="";
	}
    }
    elsif ($tname)
    {
	chomp($line);
	$tseqs{$tname}.=$line;
    }
}
close DBFILE;
if ($v>2) {print(STDERR "found $n sequences.\n")};

# Align full-length sequences to sequences from infile and writing to $outfile
my @subseqs;
my $subseq;
my $tseq;
my $next;
my $xseq;
my $yseq;
my $len;
my $score;  
my $err;
my (@i,@j,@S);
my ($imin,$imax,$jmin,$jmax);
my $Sstr;

if ($v>2) {print(STDERR "Aligning full-length sequences to sequences from infile and writing to $outfile ...\n");}
open (OUTFILE, ">$outfile") || die "ERROR: Couldn't open $outfile: $!\n";
for ($k=0; $k<$kmax; $k++) {
    # Transform subsequences of $tseqs[$k] contained in $qseqs[$k] between Xs to upper case
    @subseqs = split(/X/,$qseqs[$k]);
#   printf(STDERR ">tseq_before\n%s\n",$tseqs[$k]);
    
    # Find $subseq in $tseqs[$k] by SW-alignment and transform aligned residues of $tseqs[$k] into upper case 
    if ($v>2) {printf(STDERR "\n%3i: aligning sequence %-34.34s ...",$k,$qnames[$k]); }
    $err=1;
    while (@{$tnames[$k]}) {
	$tname= shift(@{$tnames[$k]});
	$tseq = lc($tseqs{$tname});
	$next = 0; $err=0;
	foreach $subseq (@subseqs) {
	    # Align $subseq with $tseqs[$k] and return alignment in @i, @j
	    $xseq=$subseq;
	    $yseq=$tseq;
	    $len = length($subseq);
	    $score=&AlignNW(\$xseq,\$yseq,\@i,\@j,\$imin,\$imax,\$jmin,\$jmax,\$Sstr);  
	    $jmin--; $jmax--; # first=0 (instead of first=1)
	    if ($v>2) {printf(STDERR " score/length = %6.2f  ",$score/$len);}
	    if ($score/$len<1.15) {
		if (scalar(@{$tnames[$k]})>0) {
		    $next=1;
		    last;
		} else {
		    $err=1;
		    if ($v>=2) {
			printf(STDERR "\n\nWARNING: bad match in %s: score/length=%6.2f\n",$qnames[$k],$score/$len);
			printf(STDERR "xseq:  $xseq\n");
			printf(STDERR "Match: $Sstr\n");
			printf(STDERR "yseq:  $yseq\n");
		    }
		}
		$next=0;
	    } elsif ($imin>0 && $imax<$len-1) {
		if (scalar(@{$tnames[$k]})>0) {
		    $next=1;
		    last;
		} else {
		    $err=1;
		    if ($v>=2) {
			printf(STDERR "\n\nWARNING: could not match whole length of sequence from $infile: imin=%-3i imax=%-3i len=%-3i\n",$imin,$imax,$len);
			printf(STDERR "xseq:  $xseq\n");
			printf(STDERR "Match: $Sstr\n");
			printf(STDERR "yseq:  $yseq\n");
		    }
		}
	    } else {
		if ($v>=3) {
		    printf(STDERR "\nxseq:  $xseq\n");
		    printf(STDERR "Match: $Sstr\n");
		    printf(STDERR "yseq:  $yseq\n");
		}
		# replace the substring of the template sequence that is aligned to the query with the query subsequence
		substr($tseq,$jmin,$jmax-$jmin+1) = uc($subseq);	
	    }
	} # end foreach $subseq (@subseqs)
	if (!$next) {last;}
	if ($v>2) {printf(STDERR " \nTrying next template sequence ...");}
    } # end while (@{$tseqs[$k]})

    if ($err) {
	if ($v>2) {printf(STDERR "Using original sequence from $infile\n");}
	$qseqs[$k]=~tr/X//d;
	$qseqs[$k]=uc($qseqs[$k]);
	printf(OUTFILE ">%s %s\n",$qnames[$k],$qdesc[$k]);
	printf(OUTFILE "%s\n",$qseqs[$k]);
    } else {
	# Leave a maximum of 100 lower-case residues at either end of sequence
	$tseq=~/([a-z]{0,100}[A-Z].*[A-Z][a-z]{0,100})/;
	$tseq=$1;
	if ($v>=3) {printf(STDERR "completed sequence:\n$tseq\n");}
	printf(OUTFILE ">%s (%s) %s\n",$qnames[$k],$tname,$qdesc[$k]);
	printf(OUTFILE "%s\n",$tseq);
    }
}
if ($v>2) {print("\n");}
close (OUTFILE);

#unlink ($qfile);
#unlink ($qblast);
exit;



# Find all possible full-length supersequences of $qseq in database 
sub FindSequence {
    open (QFILE, ">$qfile") || die "ERROR: Couldn't open $qfile: $!\n";
    print(QFILE ">$qname\n$qseq\n");
    if ($v==1) {print(STDERR ".");}
    if ($v==1 && $k && !($k%100)) {print(STDERR " $k\n");}
    if ($v>=2) {print(STDERR ">$qname\n$qseq\n");}
    close(QFILE);
    &System("$ncbidir/blastpgp -a 2 -I T -b 10 -A 10 -v 10 -f 15 -i $qfile -d $dbfile > $qblast");
    
    my $line;
    my $nseqs=5;  # number of full-length db sequences to be stored per query
    my $n=0;      # counts number of full-length db sequences read in
    my $maxlen=0; # length of longest of 5 best hits
    my $tname;
    $qnames[$k]=$qname;
    $qdesc[$k] =$description;
    $qseqs[$k] =$qseq;
    @{$tnames[$k]}=();
    open (QBLAST, "<$qblast") || die "ERROR: Couldn't open $qblast: $!\n";
    while ($line=<QBLAST>) {
	if ($line=~/^>\s*(\S+)/) {
	    $tname = $1;
	    $tseqs{$tname}="residues not read in yet";
	    do {
		$line=<QBLAST>
		} until ($line=~/Length =\s+(\d+)/);
	    # make sure the LONGEST sequence is first
	    if ($1>$maxlen) {
		unshift(@{$tnames[$k]},$tname);
		$maxlen=$1;
	    } else {
		push(@{$tnames[$k]},$tname);
	    }
	    if (++$n>=$nseqs) {last;}
	}
    }
    close(QBLAST);
    $k++;
    return;
}

# Executing system command and print out command
sub System {
    my $command=$_[0];
    if ($v>=2) {print(STDERR "Calling '$command'\n");}
    return system($command)/256; # && die("\nERROR: $!\n\n"); 
}






