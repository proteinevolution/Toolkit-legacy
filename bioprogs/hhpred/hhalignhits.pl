#! /usr/bin/perl -w
# Extract a multiple alignment of hits from hhsearch output

use strict;
$|= 1; # Activate autoflushing on STDOUT


# Set directory paths
my $hostname=`hostname`;
if ($hostname=~/cerberus/) {
    # Directory paths for Webserver
} elsif ($hostname=~/lamarck/) {
    # Directory paths for SUN
} elsif ($hostname=~/compute|seth/) {
    # Directory paths for cluster
} else {
    # Directory paths for my PC
}

# Default options
my $evalue=0;          # E-value threshold for inclusion in alignment: disabled
my @m=(1);             # list of hits to pick: default=first
my $nextr=1;           # number of sequences to extract from each template aligment
my $outformat="fas";   # default output format = FASTA
my $v=2; 

sub fexit()
{
    print("
 Extract a multiple alignment of hits from hhsearch output file 
 Usage: hhalignhits.pl [-i] file.hhr [-o] alignment-file [options]
 Options:
  -i  file.hhr      results file from hhsearch with hit list and alignments
  -o  file.al       output file for alignment
  -q  query-file    read query sequence/alignment from file (a2m/a3m format) for inclusion in output alignment
  -m  m1 [m2 m3...] pick only specified hits for alignment (overrides -e option) (default='-m 1')
  -e  E-value       E-value threshold for hits (overrides -m option)
  -q  [file]        include query sequence or query alignment in output alignment
  -v  int           verbose mode (default=2)
  -fas              output format FASTA (default)
  -a2m              output format a2m (match columns are columns with residues in query!)
  -a3m              output format a3m (dito)
  -pir              output format PIR as input for MODELLER (only works for SCOP templates)
\n");
    if (defined $_[0]) {print($_[0]);}
    exit;
}


# Variable declarations
my $infile;            # *.hhr file
my $outfile;           # output alignment
my $qfile="";          # FASTA file containing query sequence; default=do not include query sequence 
my $options="";        # options read in from command line
my $i;                 # residue index
my $j;                 # residue index
my $k;                 # sequence index
my $line;              # line read in from file
my $qname;             # name of query
my $tname;             # name of hit being read
my $qid;               # "Q query-name"
my $tid;               # "T template-name"
my $qnameline;         # nameline of query
my $tnameline;         # nameline of hit being read
my %m=();              # hash of hits to pick: default=first
my $m;                 # hit index
my $first_res;         # index of first query residue in pairwise alignment
my $last_res;          # index of last  query residue in pairwise alignment
my @qres;              # query residues from current pairwise alignment 
my @tres;              # template residues from current pairwise alignment 
my $qres;              # query residues from current pairwise alignment 
my $tres;              # template residues from current pairwise alignment 
my $new_hit="";        # new sequence record; is only written if coverage threshold is exceeded
my $nseq=0;            # counts the number of sequences already in alignment (including query sequences)
my $nhit=0;            # counts the number of sequences extracted from input file
my @hitnames;          # $hitnames[$nseq] is the nameline of the ihit'th hit
my @hitseqs;           # $hitseqs[$nseq] contains the residues of the ihit'th hit
my $qlength=0;         # number of residues in query sequence


###################################################################################################
# Process input options

if (@ARGV<1) {&fexit;}
for ($i=0; $i<@ARGV; $i++) {$options.="$ARGV[$i] ";}

# Set E-value threshold for inclusion in alignment
if ($options=~s/-e\s+(\S+)//g)    {$evalue=$1;}

# include query sequence?
if ($options=~s/-q\s+(\S+)//g)    {$qfile=$1;}

# Read hit indices to align
if ($options=~s/-m\s+((\d+\s+)+)//g) {
    my $mstring=$1;
    @m=split(/\s+/,$mstring); 
}

# Set output format
if ($options=~s/-fas//g) {$outformat="fas";}
if ($options=~s/-a2m//g) {$outformat="a2m";}
if ($options=~s/-a3m//g) {$outformat="a3m";}
if ($options=~s/-pir//g) {$outformat="pir";}

# Verbose mode?
if ($options=~s/-v\s*(\d)//g) {$v=$1;}
if ($options=~s/-v//g) {$v=2;}

# Read infile and outfile 
if ($options=~s/-i\s+(\S+)//g) {$infile=$1;}
if ($options=~s/-o\s+(\S+)//g) {$outfile=$1;}
if (!$infile  && $options=~s/^\s*([^- ]\S+)\s*//) {$infile=$1;} 
if (!$outfile && $options=~s/^\s*([^- ]\S+)\s*//) {$outfile=$1;} 

# Warn if unknown options found or no infile/outfile
if ($options=~/^\s*(\S+.*?)\s*$/) {die("Error: unknown options '$1'\n");}
if (!$infile)  {&fexit("Error: Missing input file\n");}
if (!$outfile) {&fexit("Error: Missing output file\n");}

if ($evalue==0) {    
    foreach $m (@m) {$m{$m}=1;}
}

# Read query sequence(s)
if ($qfile ne "") {
    $nseq--;
    my $qname;
    my $qnameline;
    my $qdescr;
    open(QFILE,"<$qfile") || die ("cannot open $qfile: $!");
    while ($line = <QFILE>) { #scan through PsiBlast-output line by line 
	if ($line=~/^>(\S+)\s+(.*)/) { # nameline detected
	    $nseq++;
	    $hitseqs[$nseq]="";
	    $qname=$1;
	    $qnameline="$1 $2";
	    $qdescr=sprintf("%-.30s",$2);
	    $qdescr=~s/\s+\S{1,4}$//;  # delete last characters if less than 5

	    # Prepare name line of hit
	    if ($outformat eq "pir") {
		$hitnames[$nseq] = sprintf(">P1;$qname\nsequence:    :    : :    : :$qdescr: : 0.00: 0.00\n");
	    } else {
		# outformat is "fas" or "a2m" or "a3m" or ...
		$hitnames[$nseq] = ">$qnameline\n";
	    } 
	    
	}
	elsif ($line=~/^\#/) {next;} # commentary detected
	else {
	    chomp($line);
	    $line=~tr/A-Za-z.-/A-Za-z.-/d;
	    $hitseqs[$nseq].=$line;
	}
    }
    close(QFILE);
    $nseq++;
    if ($v>=2) {print("Read $qfile with $nseq sequences\n");}
}

# Open hhsearch file and scan for ...
open(INFILE,"<$infile") || die ("cannot open $infile: $!");

while ($line=<INFILE>) { if ($line=~/^Query\s+(\S+)(.*)/) {last;} }
if ($line=~/^Query\s+(\S+)(.*)/) {$qname=$1; $qnameline=$1.$2; $qid="Q $qname             ";}
else {die("\nError: bad format in $infile, line $.".". Found no 'Query' line\n");}    


########################################################################################
# Read alignments and extract sequences

while($line!~/^No\s+(\d+)/) {$line=<INFILE>;} # search for beginning of next alignment
if ($line!~/^No\s+(\d+)/) {die("Error: found no alingments in $infile\n");}

while ($line) # search for beginning of next alignment
{
    while($line && $line!~/^No\s+(\d+)/) {$line=<INFILE>;} # search for beginning of next alignment
    if (!$line) {last;}
    $line=~/^No\s+(\d+)/;
    $m=$1;

    # Is index of alignment contained in hash with hits to pick?
    if ($evalue>0 || defined $m{$m}) {

	$line = <INFILE>;
	if ($line=~/^>(\S+)(.*)/) {$tname=$1; $tnameline=$1.$2; $tid="T $tname               ";}
	else {die("\nError: bad format in $infile, line $.\n");}

	$line = <INFILE>;
	if ($line=~/^E-value\s*=\s*(\S+)/) {
	   if ($evalue>0 && $1>$evalue) {last;} # E-value too high -> finished
	}
	else {die("\nError: bad format in $infile, line $.\n");}

	# If we arrive here the hit is accepted
	$line = <INFILE>; # Read blank line
	
	# Find index of first residue and length of query sequence
	while (substr($line,0,16) ne substr($qid,0,16)) {$line = <INFILE>;} # search for next query line
	if ($line!~/^Q \S+\s+(\d+)\s+\S+\s+\d+\s+\((\d+)\)/) {die("\nError: bad format in $infile, line $.\n");} 
	$first_res=$1;
	$qlength=$2;

	# Read pairwise alignment 
	$qres=""; $tres="";
	while (1) # Cycle in this loop until no new lines are found
	{
	    while (substr($line,0,16) ne substr($qid,0,16)) {$line = <INFILE>;} # search for next query line
	    if ($line!~/^Q \S+\s+\d+\s+(\S+)\s+(\d+)/) {die("\nError: bad format in $infile, line $.\n");}
	    $qres .= $1;
	    $last_res=$2;
	    $line=<INFILE>;
	    while (substr($line,0,16) ne substr($tid,0,16)) {$line = <INFILE>;} # search for next template line
	    if ($line!~/^T \S+\s+\d+\s+(\S+)/) {die("\nError: bad format in $infile, line $.\n");}
	    $tres .= $1;
	    $line=<INFILE>;
	    while ($line && $line!~/^\s*$/) {$line = <INFILE>;} # search for next blank line
	    $line=<INFILE>;  # read in second blank line after alignment block
	    $line=<INFILE>;  # read in first line of new block of first line of new alignment?
	    if ($line=~/No\s+\d+/) {last;} # Found end of alignment and beginning of next alignment
	} # end while(1)
	
	# Check lengths
	if (length($tres)!=length($qres)) {
	    print("\nError: query and template lines do not have the same length in $infile, line $.\n");
	    printf("Q %-14.14s $qres\n",$qname);
	    printf("T %-14.14s $tres\n\n",$tname);
	    exit 1;
	}

	if ($v>=3) {
	    printf("Q %-14.14s $qres\n",$qname);
	    printf("T %-14.14s $tres\n\n",$tname);
	}	    

	# Record template residues in a3m format
	@qres = unpack("C*",$qres);
	@tres = unpack("C*",$tres);
	$new_hit = "-" x ($first_res-1);     	     # print gaps at beginning of sequence
	for ($i=0; $i<scalar(@qres); $i++) {
	    if ($qres[$i]!=45 && $qres[$i]!=46) {
		if($tres[$i]==46) {
		    $new_hit.="-";                   # transform '.' to '-' if aligned with a query residue
		} else {
		    $new_hit .= uc(chr($tres[$i]));  # UPPER case if aligned with a query residue (match state)
		}
	    } else {
		if($tres[$i]!=45 && $tres[$i]!=46) { # no gap in template?
		    $new_hit.=lc(chr($tres[$i]));    # lower case if aligned with a gap in the query (insert state) 
		}
	    }
	}

	$new_hit .= "-" x ($qlength-$last_res);      # print gaps at end of sequence
	$hitseqs[$nseq] = $new_hit; 
#	printf("%s\n",$new_hit);
	
	# Prepare name line of hit
	if ($outformat eq "pir") {
	    if ($tnameline=~/^[a-z](\d[a-z0-9]{3})([a-z_\.])\S\s+(\S+)\s+\S+\s+(.*)\s+\{(.*)\}/ ) {
		# template is SCOP/ASTRAL sequence
		my $pdbid=lc($1);
		my $chain=lc($2);
		my $descr="$4 $3";
		my $organism=$5;
		if ($chain eq "_") {$chain="A";}
		if ($chain eq ".") {$chain="@";}
		$hitnames[$nseq] = sprintf(">P1;$tname\nstructureX:%4s:\@:%1s:\@:%1s:%s:%s:-1.00:-1.00\n",$pdbid,$chain,$chain,$descr,$organism);
	    } else {
		die ("\nError: template not a SCOP/ASTRAL sequence in $infile, line $.: $tnameline\n");
	    }
	} else {
	    # outformat is "fas" or "a2m" or "a3m" or ...
	    $hitnames[$nseq] = ">$tnameline\n";
	} 
	
	$nseq++; $nhit++;
	# end if($evalue>0 || defined $m{$1})
	
    } else { 
	# else skip alignment ($evalue==0 && !defined $m{$1})
	$line=<INFILE>;
    }

} # end while ($line)
########################################################################################
close INFILE;


########################################################################################
# Transform into correct ouput format

# If output format is fasta or a2m we have to insert gaps:
if ($outformat eq "fas" || $outformat eq "a2m" || $outformat eq "pir")
{
    my @len_ins; # $len_ins[$j] will count the maximum number of inserted residues after match state $j.
    my @inserts; # $inserts[$j] contains the insert (in small case) of sequence $k after the $j'th match state
    my $insert;
    my $ngap;

    # For each match state determine length of LONGEST insert after this match state and store in @len_ins
    for ($k=0; $k<$nseq; $k++) {
	# split into list of single match states and variable-length inserts
	# ([A-Z]|-) is the split pattern. The parenthesis indicate that split patterns are to be included as list elements
	# The '#' symbol is prepended to get rid of a perl bug in split
	$j=0;
 	@inserts = split(/([A-Z]|-)/,"#".$hitseqs[$k]."#");
#	printf("Sequence $k: $hitseqs[$k]\n");
#	printf("Sequence $k: @inserts\n");
	foreach $insert (@inserts) {
	    if( !defined $len_ins[$j] || length($insert)>$len_ins[$j]) {
		$len_ins[$j]=length($insert);
	    }
	    $j++;
#	    printf("$insert|");
	}
#	printf("\n");
    }

    # After each match state insert residues and fill up with gaps to $len_ins[$i] characters
    for ($k=0; $k<$nseq; $k++) {
	# split into list of single match states and variable-length inserts
	@inserts = split(/([A-Z]|-)/,"#".$hitseqs[$k]."#");
	$j=0;
	
	# append the missing number of gaps after each match state
	foreach $insert (@inserts) {
	    if($outformat eq "fas") {
		for (my $l=length($insert); $l<$len_ins[$j]; $l++) {$insert.="-";}
	    }
	    else {
		for (my $l=length($insert); $l<$len_ins[$j]; $l++) {$insert.=".";}
	    }
	    $j++;
	}
	$hitseqs[$k] = join("",@inserts);
	$hitseqs[$k] =~ tr/\#//d; # remove the '#' symbols inserted at the beginning and end
    }
}



# Remove gaps? Captialize?
if ($outformat eq "fas" || $outformat eq "pir") {
    for ($k=0; $k<$nseq; $k++) {$hitseqs[$k]=~tr/a-z./A-Z-/;}  # Transform to upper case
} elsif ($outformat eq "a3m") {
    for ($k=0; $k<$nseq; $k++) {$hitseqs[$k]=~tr/.//d;}        # Remove gaps aligned to inserts
}

# Write sequences into output file
open (OUTFILE, ">$outfile") || die ("cannot open $outfile:$!");
if ($outformat eq "pir") {
    for ($k=0; $k<$nseq; $k++) {
	print(OUTFILE "$hitnames[$k]$hitseqs[$k]*\n");
    }
} else {
    for ($k=0; $k<$nseq; $k++) {
	print(OUTFILE "$hitnames[$k]$hitseqs[$k]\n");
    }
}
close OUTFILE;

if ($v>=2) {printf("$nhit sequences extracted from $infile and written to $outfile\n");}

# Return number of hits in one byte (0-255)
if    ($nhit<110)  {exit $nhit;}
elsif ($nhit<1100) {exit 100+int($nhit/10);}
elsif ($nhit<5500) {exit 200+int($nhit/100);}
else                {exit 255;}              
exit(0);

