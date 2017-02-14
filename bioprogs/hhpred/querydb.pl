#! /usr/bin/perl -w
#
# Prepare a FASTA-formatted database from PSIBLAST hits to a query sequence or alignment
# The database can be used to speed up search programs such as hmmsearch.
# The E-value, seqe-id, and coverage is appended to the name lines (e.g. E=1.3E-5). 
# The sequences are sorted in order of ascending E-values.
# Upper/lower case resicues of the first seuqence in the alignment (=query) are interpreted as 
# match/insert states and are transferred to the db sequences
# The BLAST database must contain gi numbers and must be formatted with -o T option (for fastacmd)!
#
# Usage:   querydb.pl [PsiBlast-options] -d BLAST-db(s) query-alignment output-db
# 
# Example: 
# querydb.pl -e 1000 -j 3 -h 1E-3 -d \"/raid/blastdb/nr /raid/blastdb/archaea\" query.a2m query.db

my $rootdir;
BEGIN {
   if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} 
   else {$rootdir="/cluster";}
};

use strict;
use lib $rootdir."/bioprogs/hhpred"; # for toolkit
use lib $rootdir."/perl";            # for soeding
use MyPaths;                         # config file with path variables for nr, blast, psipred, pdb, dssp etc.

$|= 1; # Activate autoflushing on STDOUT

# Default parameters
my $v=2;        # verbose mode
my $E_max=1000;
my $E_min=0;
my $qid_max=100;
my $sc_max=100;
my $r_min=1;
my $cov_min=0;
my $n_min=0;
my $append=0;
my $max_num_seq=10000;                      #maximum number of sequences in blast output 
my $nrounds=1;
my $Epsi=1E-4;
my $qfile="";
my $program="querydb.pl";

sub help()
{
    print("\nPrepare a FASTA-formatted database from PSIBLAST hits to a query (sequence or alignment)\n");
    print("The database can be used to speed up search programs such as hmmsearch or blast.\n");
    print("The query sequence or alignment has to be in aligned fasta or a2m format.\n");
    print("The first sequence of the alignment (=query) is the sequence that specifies which columns\n");
    print("are used for the PSI-BLAST profile\n");
    print("Upper/lower case residues of the query sequence are interpreted as match/insert states \n");
    print("and are transferred to the db sequences\n");
    print("When -extnd option is not used, full length sequences are returned.\n");
    print("\nUsage:   querydb.pl [options] -d BLAST-db query-file outfile\n"); 
    print("Options for thresholds: \n");
    print("  -Emax <float> : max e-value for inclusion in database (default=$E_max)\n");
    print("  -qid  <int>   : max sequence identity with query for inclusion in database (default=$qid_max)\n");
    print("  -s/c  <float> : max score per column in bits (with query or -P alignment) (default=$sc_max) \n");
    print("  -Emin <float> : min e-value for inclusion in database (default=$E_min)\n");
    print("  -rmin <int>   : min number of upper case query residues in HSP for inclusion in database (default=$r_min)\n");
    print("  -cov  <int>   : min coverage in % (default=$cov_min) \n");
    print("  -nmin <int>   : best nmin HSPs are accepted, irrespective of whether other conditions are met (default=$n_min)\n");
    print("PSI-BLAST options:\n");
    print("  -j <int>      : number of PsiBlast iterations to do (default=$nrounds)\n");
    print("  -h <float>    : e-value threshold for inclusion in multipass model (default=$Epsi)\n");
    print("  -d <file>     : BLAST database\n");
    print("Other options:\n");
    print("  -q <file>     : the query sequence in FASTA format defines match/insert states by upper/lower case characters.\n");
    print("                  Only residues in the output sequences that are aligned to upper case query residues will be upper case.\n");
    print("                  When this option is used, the sequence identity with the query (qid) is calculated as \n");
    print("                  number of identical residues IN MATCH STATES / hit length");
    print("  -extnd <int>  : keep a maximum of l residues left and right of HSP (default=keep all)\n");
    print("  -sec          : return also secondary HSPs, i.e. those that occur in the same sequence as an already accepted HSP,");
    print("                  irrespective of E-value threshold (in combination with -extnd)");
    print("  -append       : append to database (default=overwrite)\n");
    print("  -v <int>      : verbose mode (def=$v)\n");
    print("Examples: \n");
    print("querydb.pl -d /raid/db/blast/nr90 query.fas query.db\n"); # replaced nr90f by nr90 in Tuebingen
    print("querydb.pl -e 1000 -j 3 -h 1E-3 -append -d /raid/blastdb/nr query-aln.fas query.db\n\n");
    print("\n");
}

# Activate autoflushing on STDOUT
$|= 1; 

###################################################################################################
# Processing of input arguments
###################################################################################################

my $ARGC=scalar(@ARGV);
if ($ARGC<3 or $ARGV[$ARGC-2]=~/^-/ or $ARGV[$ARGC-2]=~/^-/) {&help(); exit;}
my $infile=$ARGV[$ARGC-2];
my $outdb=$ARGV[$ARGC-1];

# Set basename
my $basename;
if ($infile=~/(\S+)\.(\w+)/) {$basename=$1} else {$basename=$infile;}

# Variable declarations
my $elemstodo;
my $psiblast_db;
my $query_seq=$basename."_seq.tmp";         #FASTA-file with first sequence from alignment
my $query_ali=$basename."_ali.tmp";         #alignment file in Selex format
my $psiblast_output=$basename."_psiblast.tmp";    #Output file for PsiBlast

my $err;
my $line;
my $nseq;       # number of sequences to be written to outfile
my $i;          # counts residues in query
my $j;          # counts residues in template
my $l;          # counts columns in pairwise PSI-BLAST alignment
my $extnd=-1;   # extend HSPs by extnd residues on either side; -1: full-length sequences
my $qres="";    # query residues read in from pairwise alignments (including gaps)
my $tres="";    # template residues read in from pairwise alignments (including gaps)
my @qres=();    # query residues read in from pairwise alignments (including gaps)
my @tres=();    # template residues read in from pairwise alignments (including gaps)
my @qseq=();    # query sequence residues without gaps
my $qseq;       # query sequence residues without gaps
my $tseq;       # template sequence residues without gaps
my @qmatch=();  # $qmatch[$i]=1 if $qseq[$i] is match state (upper case), 0 otherwise
my $name;       # name of seuqence 
my $nameline;   # entire name line of sequence (not only first word)
my @namelines;  # name lines of all sequences to be output
my @seqs;       # residues of all sequences to be output
my %nseq;       # $nseq{$name}=nseq index for @namelines and @seqs
my @fullseqs;   # full length sequences of hits
my $qlen;
my @gis;        # gi numbers of all HSPs to be extracted from database
my $gi;         # gi number of HSP
my $sec=0;      # 0: do not accept secondary HSPs automatically

# Process non-psiblast options (rest is handed over to psiblast)
my $options="";
for (my $i=0; $i<$ARGC-2; $i++) {$options.=" $ARGV[$i] ";}
if ($options=~s/ -v\s*(\d) //g) {$v=$1;}
if ($options=~s/ -v //g) {$v=2;}
if ($options=~s/ -Emax\s+(\S+) //g)    {$E_max=$1;}
if ($options=~s/ -Emin\s+(\S+) //g) {$E_min=$1;}
if ($options=~s/ -qid\s+(\S+) //g)  {$qid_max=$1;}
if ($options=~s/ -s\/c\s+(\S+) //g) {$sc_max=$1;}
if ($options=~s/ -rmin\s+(\d+) //g) {$r_min=$1;}
if ($options=~s/ -cov\s+(\S+) //g)  {$cov_min=$1;}
if ($options=~s/ -nmin\s+(\S+) //g) {$n_min=$1;}
if ($options=~s/ -app\S* //g)       {$append=1;}
if ($options=~s/ -extnd\s+(\d+) //g){$extnd=$1;}
if ($options=~s/ -sec //g)  {$sec=1;}
if ($options=~s/ -j\s+(\d+) //g)    {$nrounds=$1;}
if ($options=~s/ -h\s+(\S+) //g)    {$Epsi=$1;}
if ($options=~s/ -q\s+(\S+) //g)    {$qfile=$1;}

#Get the database names
if ($options=~/ -d\s*\"(.+?)\" /) {$psiblast_db=$1;}
elsif ($options=~/ -d\s*(\S+) /)  {$psiblast_db=$1;}

# Set input and output file
if ($options=~s/ -i\s+(\S+) //g) {$infile=$1;}
if ($options=~s/ -o\s+(\S+) //g) {$outdb=$1;}
if (!$infile  && $options=~s/^\s*([^-]\S*)\s*//) {$infile=$1;} 
if (!$outdb   && $options=~s/^\s*([^-]\S*)\s*//) {$outdb=$1;} 

# Warn if unknown options found or no infile/outfile
if (!$infile) {&help(); print("\nError: No input file given\n"); exit(1);}
if (!$outdb)  {&help(); print("\nError: No output file given\n"); exit(1);}
if (!$psiblast_db)  {&help(); print("\nError: No psiblast database file given\n"); exit(1);}

#Set option for multiple iterations and E-value inclusion in profile
if ($nrounds>1) {$options.="-j $nrounds -h $Epsi";}



###################################################################################################
# Prepare input files ($query_seq_file and $query_ali_file) for psiblast call
###################################################################################################

open (INFILE, "<$infile") || die ("cannot open $infile: $!");
open (QUERYALI, ">$query_ali") || die ("cannot open $query_ali: $!");
open (QUERYSEQ, ">$query_seq") || die ("cannot open $query_seq: $!");

# Read one sequence after the other and convert it to Selex-format for Psiblast input
# Write first sequence into query sequence file
my $addedX;
$nseq=0; $qseq="";
$/=">"; # change input field seperator
while ($line=<INFILE>){
    if ($line eq ">") {next;}
    while (1) {if($line=~s/(.)>/$1/) {$line.=<INFILE>;} else {last;}} # in the case that nameline contains a '>': '.' matches anything except '\n'
    $line=~s/^(.*)//;     # divide into nameline and residues; '.' matches anything except '\n'
    $nameline=">$1";      # don't move this line away from previous line $line=~s/([^\n]*)//;
    $nameline=$1;
    $nameline=~/(\S+)/;
    $name=$1;
    $line=~s/[^a-zA-Z.-]//g;  # remove all invalid symbols from sequence, including ">" at the end
    if($nseq==0) {
	$qlen=($line=~tr/a-zA-Z/a-zA-Z/);
	if ($qlen<26) {$addedX='X'x(26-$qlen);} else {$addedX="";}
	$qseq=$line.$addedX;
	print(QUERYSEQ ">$nameline\n$qseq\n");
    }
    printf(QUERYALI "%-19.19s %s\n",$name,$line.$addedX);
    $nseq++;
} 
close INFILE;
close QUERYALI;
close QUERYSEQ;
$/="\n"; # reset input field seperator

# Read query sequence from file and record match/insert state assignments?
if ($qfile) {
    open (QFILE, "<$qfile") || die ("cannot open $qfile: $!");
    $qseq="";
    while ($line=<QFILE>){if($line=~/^>/) {last;} }
    while ($line=<QFILE>){
	if( $line=~/^>/) {last;}
	chomp($line);
	$line =~ tr/ //d; # delete blanks
	$qseq.=$line;
    } 
    close(QFILE);

    # Prepare query match state vector
    @qseq=unpack("C*",$qseq);
    $i=0;
    foreach my $ord (@qseq) {
	if    ($ord>=65 && $ord<=90)  {$qmatch[$i++]=1;}
	elsif ($ord>=97 && $ord<=122) {$qmatch[$i++]=0;}
    }
}
     
# Do jumpstart with alignment?
my $jumpstart;
if ($nseq<=1) {$jumpstart="";} else {$jumpstart="-B $query_ali";}

# Set maximum E-value
my $E_blast=$E_max;
if ($n_min>0 && $E_max<10) {$E_blast=10;}

# Do Psiblast search
if ($extnd<0 && $qid_max>=100 && $sc_max>=100 && $r_min<=1 && $cov_min<=0) {
    # Extract full-length sequence => need only gi numbers
    $err = &System("$blastpgp -I T -b 1 -v $max_num_seq -e $E_blast $options -i $query_seq $jumpstart > $psiblast_output 2>&1");
} else {
    # Cut off ends of sequences (l>=0) => get alignments
    $err = &System("$blastpgp -I T -v 1 -b $max_num_seq -e $E_blast $options -i $query_seq $jumpstart > $psiblast_output 2>&1");
}

if (!$err) { 
    if ($v>=3) {print ("Successfully finished PsiBlast run\n");}
} else {die("ERROR: blastpgp returned error code $err\n");}

# Remove tmp-files
unlink $query_ali;
unlink $query_seq;
    
###################################################################################################
# Parse PsiBlast output and record sequence identifiers in @Evalues
###################################################################################################
    
if ($v>=2) {print ("Extracting sequence identifiers from PsiBlast output ...\n");}

my @Evalues=(); # hash with Evalues of all sequence identifiers found in psiblast output
my @tfirst=();  # array with index of first residue of HSP
my @tlast=();   # arrawith index of last  residue of HSP
my $qfirst;     # first residue of query
my $qlast;      # last residue of query (not used)
my $tfirst;     # first residue of template
my $tlast;      # last residue of template
my $Evalue;        # E-value of hit
$nseq=0;        # number of sequences to be written to outfile

# Scan Blast output file for query length (needed for coverage)
open(PSIBLASTOUT,"<$psiblast_output") or die ("Error: cannot open $psiblast_output: $!\n");
while ($line=<PSIBLASTOUT>) {
    if ($line =~ /^\s*\((\d+)\s+letters\)/) {$qlen = $1; last;}
}
if ($v>=3) {print("Query length = $qlen\n");}

# Search for "Results from round X"?
if ($nrounds>1) {
    while ($line=<PSIBLASTOUT>) {if ($line=~/^Results from round $nrounds/) {last;} }
}


# Parse hit list or alignments?
if ($extnd<0 && $qid_max>=100 && $sc_max>=100 && $r_min<=1 && $cov_min<=0) {
    
    # Parse only hit list and write sequnce names and Evalues into hashes
    #....+....1....+....2....+....3....+....4....+....5....+....5....+....7....+...
    #gi|4503373|ref|NP_000101.1| dihydropyrimidine dehydrogenase [Hom...   834   0.0
    #gi|15887986|ref|NP_353667.1| AGR_C_1146p [Agrobacterium tumefaci...    32  0.93
    while ($line=<PSIBLASTOUT>){
	if( $line=~/^(gi\S+).*\s(\S+)\s*$/){ 
	    $name=$1; 
	    $Evalue=$2;
	    $Evalue=~s/^([eE].*)/1$1/;
	    if ($line=~/(\[synthetic| synthetic|construct|cloning|vector|chimeric|fusion)/i) {next;}
	    if ($nseq<$n_min || ($Evalue<=$E_max && $Evalue>=$E_min && !exists($nseq{$name}))) {
		$Evalues[$nseq]=$Evalue; 
		$line=~/^gi\|(\d+)/;
		$gis[$nseq]=$1;
		$nseq{$name}=$nseq; 
		$nseq++;
	    } 
	}
    }
    
} else {
    
    # Parse psiblast alignments in order to
    #  - transfer the query uppercase/lowercase assignments to template sequences
    #  - Cut off ends of sequences (l>=0) 
    #  - filter for Emin, qid, s/c, or coverage
    
    #>gi|27529702|dbj|BAA13206.2| KIAA0216 [Homo sapiens]
    #          Length = 2067
    #                                                                      
    # Score = 1920 bits (4973), Expect = 0.0
    # Identities = 1194/1860 (64%), Positives = 1397/1860 (75%), Gaps = 242/1860 (13%)
    #                                
    #Query: 565  QPPQVKTEEQMAAEQAWYESEKVWLVHKDGFSLATVTQTEAGSLPEGKLRIRLEQDGTVL 624
    #            +P   KTEEQ+AAE+AW E+EKVWLVH+DGFSLA+  ++E  +LPEGK+R++L+ DG +L
    #Sbjct: 343  EPSDAKTEEQIAAEEAWNETEKVWLVHRDGFSLASQLKSEELNLPEGKVRVKLDHDGAIL 402
    # 
    #Query: 625  DVDEDDVEKANPPSYDRCQDLASLLYLNESSVMHSLRQRYGGNLIYTHAGPNMVVVNPVS 684
    #            DVDEDDVEKAN PS DR +DLASL+YLNESSV+H+LRQRYG +L++T+AGP+++V+ P
    #Sbjct: 403  DVDEDDVEKANAPSCDRLEDLASLVYLNESSVLHTLRQRYGASLLHTYAGPSLLVLGPRG 462
    # 
    #
    #>gi|...

    my $skip=0;        # skip this sequence?
    my $nameline="";   # name line of new hit
    my $tseq="";       # sequence of new hit
    my $score;         # score of hit
    my $hit_length;    # length of hit
    my $matchcols;     # number of match columns in pairwise alignment
    my $cov;           # coverage of hit
    my $sc;            # score per column for hit
    my $qid;           # seq id with query
    my $secondaryHSP=0; # flag is >0 only for secondary HSPs, i.e. those that occur in same sequence as 
                       # another HSP and that are not the best HSPs

    ########################################################################################
    # Read template namelines and HSPs (Evalue, score etc. and pairwise alignment)
    
    while ($line=<PSIBLASTOUT>) #scan through PsiBlast-output line by line
    {
	# New nameline found?
	if ($line=~s/^>//) {
	    chomp($line);
	    $nameline=$line;
	    if ($v>=3) {print("$line\n");}
	    while ($line=<PSIBLASTOUT>) {
		if ($line=~/^\s+Length =/) {last;}
		chomp($line);
		$nameline.=$line;
	    }
	    $nameline=~s/\s+|/ /g;
	    $nameline=~s/\s+gi\|/  gi\|/g; # remove ^A characters and replace by three spaces
	    # Is sequence a synthetic fusion protein ?
	    if ($nameline=~/(\[synthetic| synthetic|construct|cloning|vector|chimeric|fusion)/i) {$skip=1;} else {$skip=0;}
	    $nameline=~/^gi\|(\d+)\|/;
	    $gi=$1;
	    $secondaryHSP=0;
	}
	
	# New HSP found? 
	elsif (!$skip && $line=~/^ Score =/) 
	{

	    # First check whether E-value is small enough
	    if($line =~ /^ Score =\s*(\S+)\s*bits\s*\S*\s*Expect =\s*(\S+)/) {
		$score=$1;
		$Evalue=$2;
	    } else { 
		print("\nWARNING in $program: wrong format in blast output. Expecting Score = ... Expect = ..\n$line\n");
	    }
	    $Evalue=~s/^(e|E)/1$1/;   # Expect = e-123 -> 1e-123
	    $Evalue=~tr/,//d; 
	    if ($nseq>=$n_min && !$secondaryHSP && ($Evalue>$E_max || $Evalue<$E_min) ) {next;} # reject hit
	    
#	    # Record sequence identity 
#	    # qid calculated by including count of template residues aligned to gaps in query (as opposed to hhfilter)
	    $line=<PSIBLASTOUT>;
	    $line =~ /^ Identities =\s*\S+\/(\S+)\s+\((\S+)%\)/;
	    $qid=$2;
	    
	    # Skip another line and read following line
	    $line=<PSIBLASTOUT>;
	    $line=<PSIBLASTOUT>;
	    
	    # Read pairwise alignment 
	    if ($line!~/^Query:\s*(\d+)\s+\S+/) {die("Error: wrong format of blast output in $infile: $!\n");} 
	    $line=~/^Query:\s*(\d+)\s+(\S+)/;
	    $qfirst=$1;
	    $qres  =$2;
#	    $qlast =$3;  # not used
	    $line=<PSIBLASTOUT>;
	    $line=<PSIBLASTOUT>;
	    if ($line!~/^Sbjct:\s*(\d+)\s+(\S+)\s+(\d+)/) {die("Error: wrong format of blast output in $infile: $!\n");} 
	    $tfirst=$1;
	    $tres  =$2;
	    $tlast =$3;
	    $line=<PSIBLASTOUT>;
	    $line=<PSIBLASTOUT>;
	    while ($line=~/Query:/) # Cycle in this loop until no new "Query:" lines are found
	    {
		$line=~/Query:\s*\d+\s+(\S*)/;
		$qres.=$1;
		$line=<PSIBLASTOUT>;
		$line=<PSIBLASTOUT>;
		if ($line!~/^Sbjct:\s*\d+\s+(\S*)\s+(\d+)/) {die("Error: wrong format of blast output in $infile: $!\n");} 
		$tres.=$1;
		$tlast=$2;
		$line=<PSIBLASTOUT>;
		$line=<PSIBLASTOUT>;
	    } # end while(1)
	    
	    # Check lengths
	    if (length($qres)!=length($tres)) {
		print("ERROR: Query and template sequences do not have the same length!\n");
		print("Q: $qres\n");
		print("T: $tres\n");
		exit 1;
	    }
	    
	    # Check whether hit has sufficient length and score per column
	    $hit_length=($tres=~tr/a-zA-Z/a-zA-Z/);
	    $sc=$score/$hit_length;
	    if ($nseq>=$n_min && ($hit_length<$r_min || $sc>$sc_max)) {next;}                # Reject hit?

	    if ($qfile) {
		my $identies=0;
		@qres = unpack("C*",$qres);
		@tres = unpack("C*",$tres);
		$i=$qfirst-1;   # counts residues in query (residue with index 1 is at pos 0)
		$tseq="";
		for ($l=0; $l<@qres; $l++) {
		    if ($tres[$l]==45) {
			$i++;                               # gap in template and no gap in query
		    } else {
			if ($qres[$l]==45) {
			    $tseq.=lc(chr($tres[$l]));   # gap in query    and insert in template
			} elsif ($qmatch[$i]) {          
			    $tseq.=uc(chr($tres[$l]));   # match in query  and match in template
			    $i++;
			    if ($tres[$l]==$qres[$l]) {$identies++;}
			} else {
			    $tseq.=lc(chr($tres[$l]));   # insert in query and insert in template
			    $i++;
			}
		    }
		}
		$qid=100.0*$identies/$hit_length;

	    } else {
		$tseq=uc($tres);
		$tseq=~tr/-//d;
	    }

	    if ($qid>$qid_max) {next;}

#	    print("Q: $qres\n");
#	    print("T: $tres\n");
#	    print("T: $tseq\n\n");

	    # Check length of $tseq
	    if (length($tseq)!=$tlast-$tfirst+1 || $hit_length!=$tlast-$tfirst+1) {
		printf("Error in $program: length of template sequence = %i =? %i =?  %i - %i = i_last - i_first +1\n",length($tseq),$hit_length,$tlast,$tfirst);
	    }

	    # Check overlap and coverage
	    my $qmatches  =($qseq=~tr/A-Z/A-Z/);
	    $matchcols =($tseq=~tr/A-Z/A-Z/);
	    if ($matchcols<$r_min) {next;}
	    $cov=100.0*$matchcols/$qmatches;
	    if ($cov<$cov_min) {next;}
	    
	    # Record hit for later output to outfile
	    $nameline=~/^(\S+)/;
	    $nseq{$1}=$nseq;
	    $namelines[$nseq] = sprintf(">%s  E=%g s/c=%.2f id=%.0f%% cov=%.0f%% matches=%i",$nameline,$Evalue,$sc,$qid,$cov,$matchcols); 
	    $tseq =~ tr/Uu/Cc/;
	    $seqs[$nseq] = $tseq; 
#	    printf("%s\n",$tseq);
	    $tfirst[$nseq]=$tfirst;
	    $tlast[$nseq]=$tlast;
	    $gis[$nseq]=$gi;
	      
	    if ($v>=3) {printf("nhit=%-2i  qlen=%-3i  qid=%-3i%% s/c=%-6.3f\n",$nseq,$qlen,$qid,$sc);}
	    # increase count for HSPs only if $sec option is active (i.e. secondary HSPs get accepted automatically)
	    if ($sec) {$secondaryHSP++;} 

	    $nseq++;    
	} # end elseif new HSP found
	
    } # end while ($line)
    ########################################################################################
    
}

close PSIBLASTOUT;
    
if ($v<=2) {
    unlink $psiblast_output;
}

###################################################################################################
# Write all sequences with identifiers in %Evalues into output db
###################################################################################################

if ($v>=2) {print ("Extracting $nseq sequences from $psiblast_db\n");}

#$psiblast_db=$nr;  # CHANGE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
$nameline="";
for (my $n=0; $n<$nseq; $n++) {
    $gi = $gis[$n];  # id of n'th template 
	
    if ($v>=3) {print("$ncbidir/fastacmd -d $psiblast_db -s '$gi'\n");} 
    if (open(FASTACMD,"$ncbidir/fastacmd -d $psiblast_db -s '$gi' |")) { # db must have been formatted with -o T !
	$nameline=<FASTACMD>;
	chomp($nameline);
	if ($nameline!~/^>/) {
	    print("\nError in $program in fastacmd! Skipping ExtendSequence\n\n");
	    return $qseq;
	}
	$fullseqs[$n]="";
	while ($line=<FASTACMD>) {chomp($line); $fullseqs[$n].=$line;};
	close(FASTACMD);
	if ($extnd<0 && $qid_max>=100 && $sc_max>=100 && $r_min<=1 && $cov_min<=0) {
	    $nameline=~s/\s+|/ /g;
	    $nameline=~/^(.*)/;
	    $namelines[$n] = sprintf("%s  E=%g",$nameline,$Evalues[$n]); 
	}
    } else {
	print("WARNING in $program: Could not find sequence gi|$gi in $psiblast_db\n");
	next;
    }
}

if ($extnd>=0) {

    # Cut off ends of sequences (l>=0) => get alignments
    my $leftmost=0;
    my $residues;
    for ($nseq=0; $nseq<@seqs; $nseq++) {
	if (exists $fullseqs[$nseq]) {
	    
	    $leftmost=$tfirst[$nseq]-$extnd; 
	    if ($leftmost<1) {$leftmost=1;}
	    $residues=" ".$fullseqs[$nseq];  # add " " to make numbering start at 1 instead of 0
	    $fullseqs[$nseq]= lc(substr($residues,$leftmost,$tfirst[$nseq]-$leftmost));
	    $fullseqs[$nseq].=$seqs[$nseq];
	    $fullseqs[$nseq].=lc(substr($residues,$tlast[$nseq]+1,$extnd));
#	    if (!$qfile) {$fullseqs[$nseq]=uc($fullseqs[$nseq]);}

	} elsif ($v>=1) {
	    printf("WARNING in $program: could not find sequence %-20.20s in database\n",$namelines[$nseq],);
	}
    }
}



if ($append==0) {open (OUTDB, ">$outdb")|| die ("cannot open $outdb:$!");}
else            {open (OUTDB, ">>$outdb")|| die ("cannot open $outdb:$!");}

foreach ($nseq=0; $nseq<@namelines; $nseq++) {
    print(OUTDB "$namelines[$nseq]\n$fullseqs[$nseq]\n");
#    print("$nseq: $namelines[$nseq]\n$fullseqs[$nseq]\n");
}
close OUTDB;

if ($v>=1) {print ("Database file $outdb with $nseq sequences written\n");}

exit 0;


################################################################################################
### System command
################################################################################################
sub System()
{
    my $command=$_[0];
    if ($v>=2) {print("$command\n");} 
    return system($command)/256;
}
