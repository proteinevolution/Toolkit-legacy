#! /usr/bin/perl -w
# Extract a multiple alignment of hits from hmmsearch output
# Usage:   alignhmmhits.pl [options] hmm-results.hms alignment-file
#
# coverage is approximated by hit_length / query_length, 
# NOT by (last_query_residue - first_query_residue) / query_length 
# Therefore if the query has gaps in the alignment, coverage here may exceed 100.
use strict;

# Default options
my $E_thrshd=1E+10;
my $cov_thrshd=0;  ;
my $sc_thrshd=-10;
my $outformat="a3m";
my $append=0;
my $v=2;
my $query_file="";
my $infile;
my $outfile;

sub fexit()
{
    print("\nExtract a multiple alignment of hits from hmmsearch output\n");
    print("Usage:   alignhmmhits.pl [options] hmm-results.hms alignment-file\n");
    print("Options for thresholds\n");
    print("  -e   e-value : maximin e-value for inclusion into alignment  (default=$E_thrshd)\n");
    print("  -s/c value   : minium score-per-column in bits for inclusion into alignment  (default=$sc_thrshd) \n");
    print("  -cov coverage: minimum coverage in % for inclusion into alignment  (default=$cov_thrshd) \n");
    print("Options for output format:\n");
    print("  -psi         : PsiBlast-readable format (like -fas, but inserts relative to query sequence omitted)\n");
    print("  -fas         : aligned fasta; all residues upper case, all gaps '-'\n");
    print("  -a2m         : aligned fasta; inserts: lower case, matches: upper case, deletes: '-', gaps aligned to inserts: '.'\n");
    print("  -a3m         : a3m format (like -a2m, but gaps aligned to inserts omitted  (default)\n");
    print("  -ufas        : unaligned fasta format (without gaps)\n");
    print("Other options:\n");
    print("  -append      : append output to file (default=overwrite)\n");
    print("  -q   file    : write query sequence (from input file in FASTA format) as first sequence of alignment\n");
    print("  -v           : verbose mode (default=off)\n");
    print("\n");
    print("Examples: \n");
    print("alignhmmhits.pl 1enh.hms 1enh.a2m\n");
    print("alignhmmhits.pl -e 1E-4 -cov 50 -s/c 1 -a3m 1enh.hms 1enh.a3m\n");
    print("\n");
    exit;
}



###################################################################################################
# Process input options

my $ARGC=scalar(@ARGV);
if ($ARGC<2) {&fexit;}
$infile=$ARGV[$ARGC-2];
$outfile=$ARGV[$ARGC-1];

# variable declarations
my $options="";
my $line;              # line read in from file
my $nameline;          # >template_name
my $Evalue;            # e-value of hit
my $score;             # bit score of hit
my $seq_id;            # percent sequence identity
my $coverage;          # $hit_length/$query_length
my $score_col;         # score per column
#my %first;             # column in HMM were alignment with hit begins
#my %last;              # column in HMM were alignment with hit ends
#my $key;               # key used for %first and %last consisting of the name, ':', and the domain index
my @first;             # column in HMM were alignment with hit begins
my @last;              # column in HMM were alignment with hit ends
my $idom;              # domain index
my $name_printed;      # has the nameline of this sequence already been printed?
my $query_residues="";
my $template_residues="";
my $n;                 # counts the number of hits per sequence
my $line_number=0;
my $nhit=0;            # counts the number of sequences already in alignment
my @hitnames;          # $hitnames[$nhit] is the nameline of the ihit'th hit
my @hitseqs;           # $hitseqs[$nhit] contains the residues of the ihit'th hit
my $len=0;             # longest hit found (including leading gaps)
my $i;                 # counts position in HMM
my $k;                 # counts number of sequences


for ($i=0; $i<$ARGC-2; $i++) {$options.=" $ARGV[$i] ";}

#Set E-value threshold for inclusion in alignment
if ($options=~s/ -e\s+(\S+)\s+/ /g) {$E_thrshd=$1;}
if ($options=~s/ -cov\s+(\S+)\s+/ /g) {$cov_thrshd=$1;}
if ($options=~s/ -s\/c\s+(\S+)\s+/ /g) {$sc_thrshd=$1;}

#Set output format
if ($options=~s/ -psi\s+/ /g) {$outformat="psi";}
if ($options=~s/ -a2m\s+/ /g) {$outformat="a2m";}
if ($options=~s/ -a3m\s+/ /g) {$outformat="a3m";}
if ($options=~s/ -fas\s+/ /g) {$outformat="fas";}
if ($options=~s/ -ufas\s+ / /g) {$outformat="ufas";}
if ($options=~s/ -q\s+(\S+)\s+/ /g) {$query_file=$1;}

# Append to outfile?
if ($options=~s/ -append\s+/ /g) {$append=1;}

#Verbose mode?
if ($options=~s/ -v\s*(\d+)\s+/ /g) {$v=$1;}
if ($options=~s/ -v\s+//g) {$v=2;}

# Activate autoflushing on STDOUT?
if ($v>=3) {$|= 1;}

#Include query sequence as first sequence in alignment?
if ($query_file) 
{
    open(QUERYFILE,"<$query_file");
    my $query_name;
    while($line=<QUERYFILE>) # Read name line
    {
	if ($line=~/^>(.*)/) 
	{
	    $query_name=$1;
	    last;
	}
    }
    my $query_residues="";
    while($line=<QUERYFILE>) # Read residues
    {
	if ($line=~/^>/) {last;}
	chomp($line);
	$line=~s/\s//;       # remove white space
	$query_residues.=$line;
    }
    close(QUERYFILE);

    if ($outformat eq "a3m" || $outformat eq "a2m" || $outformat eq "fas" || $outformat eq "ufas")
    {
	$hitnames[$nhit] = sprintf(">$query_name E=0 id=100%% cov=100%% s/c=2\n"); 
    }
    elsif ($outformat eq "psi")
    {
	$query_name=~s/^(\S{1,18}).*/$1/;
	$line=sprintf("%-21.21s",$query_name);
	$line=~ tr/ /_/;
	$line=sprintf("%s_E=%g      ",$line,0);
	$hitnames[$nhit] = sprintf("%-31.31s ",$line);
    }
    $hitseqs[$nhit] = $query_residues;
    $nhit++;
}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}

if ($v>=3) 
{
    print("\n");
    print("E-value threshold      : $E_thrshd\n");
    print("coverage threshold     : $cov_thrshd\n");
    print("score/column threshold : $sc_thrshd\n");
    print("Input file             : $infile\n");
    print("Alignment file         : $outfile\n");
    if ($query_file) {print("Query sequence file    : $query_file\n");}
    print("Output format          : $outformat\n");
    print("Append?                : ");
    if ($append) {print("yes\n");} else {print("no\n");}
}
    
open INFILE,"<$infile" || die ("cannot open $infile: $!");

# Move to beginning of summary hit listing for domains...
while ($line=<INFILE>)
{
    if ($line =~ /^Parsed for domains:/) {last;}
    $line_number++;
}
$line=<INFILE>; #read 'Sequence                             Domain  seq-f seq-t    hmm-f hmm-t      score  E-value'
$line=<INFILE>; #read '--------                             ------- ----- -----    ----- -----      -----  -------'
$idom=0;
# ... and read in first and last residue position of hits (hmm-f and hmm-t)
while ($line=<INFILE>)
{               #read 'gi|266346|sp|Q01292|ILV5_SPIOL         1/1     308   591 ..     1   287 []   723.2   6e-215'
    if ($line =~ /^\s*$/){last;}
    $line =~ /\s*(\S{1,36})\S*?\s*(\d+)\/\d*\s*\S+\s*\S+\s*\S+\s*(\d+)\s*(\d+).*\s+(\S+)\s*$/;
    if (!$line) {die("ERROR while reading summary hit list line '$line'\n");}
#    $key="$1:$2:$5";
#    $first{$key}=$3;
#    $last{$key}=$4;
    $first[$idom]=$3;
    $last[$idom]=$4;
    $idom++;
    if ($4>$len) {$len=$4;} 
}
#if ($query_file) {$len=length($query_residues);} # This is only correct if query seq defines match state columns


# Move to beginning of alignments
while ($line=<INFILE>)
{
    if ($line =~ /^Alignments of top-scoring domains:/) {last;}
    $line_number++;
}


# Read template namelines, Evalue etc. and, if hit is accepted, the alignment
$idom=-1;
$line = <INFILE>;
while (1) #scan through HMMer output line by line
{
    if ($line=~/^(\S{1,36})\S*?:\s* domain\s*(\d+)\s+.*score\s+(\S+),.*E\s*=\s*(\S+)$/) # nameline detected
    {
	$idom++;
	$n=0;
	$line=$1;
	$score=$3;
	$Evalue=$4;
	$nameline=$line;
#	$key="$1:$2:$4";

	# First check whether E-value is small enough
#	print("Name:$nameline  score:$score  Evalue:$Evalue\n"); 
	if ($Evalue>$E_thrshd) {next;} # reject hit

      	# Read following line
	$line=<INFILE>;
	$name_printed=0;
	
	# cycle in this loop until no new alignment lines are found
	while (1) 
	{
	    #no new alignment lines found? -> jump out of while(1)-loop
	    if ($line!~/\s{10}\s*(\S+)/) {last;} 

	    # Skip reference line
	    if ($line=~/\s+RF\s+/) {$line=<INFILE>;} 
	    if ($line!~/\s{10}\s*(\S+)/) {last;} 

	    my $q_res=$1;
	    $query_residues .=$1;
	    
	    if ($v>=3) {print("Q: $line");}
	    
	    # Skip middle line and read next (template line of alignment)
	    $line=<INFILE>;
	    $line=<INFILE>;
	    if ($v>=3) {print("T: $line\n");}
	    $line=~/\s*\S+\s+(\S+)\s+(\S+)/; 
	    my $number=$1;
	    my $t_res=$2;

	    # This crazy expression needs to be tested for to be sure there are really residues or '-' to add
	    if ($q_res=~/[a-zA-Z\.-]</ || $q_res !~/\*$/) {$template_residues .= $t_res;}
	    
	    # Print name line of hit?
	    if (!$name_printed)
	    {
		$n++;
		if ($outformat eq "a3m" || $outformat eq "a2m")
		{
		    if ($n>1) 
		    {
			$nameline=~s/^(\S*)_\d*/$1_$n/; # delete the _n-1 at end of first non-gapped block
		    }
		}
		elsif ($outformat eq "fas")
		{
		    $nameline=~s/^(\S*).*/$1/;          # delete everything after first block
		    if ($n>1) 
		    {
			$nameline=~s/^\d*:/$n:/;        # insert a new _n at beginning
		    }
		}
		elsif ($outformat eq "psi")
		{
		    $nameline=~s/^(\S{1,18}).*/$1/;
		    $line=sprintf("%-21.21s",$nameline);
		    $line=~ tr/ /_/;
		    $nameline = sprintf("%-31.31s",$line);
		}
		$name_printed=1;
	    }
	    

	    # Skip one line and read following line
	    $line=<INFILE>;
	    $line=<INFILE>;
	} # end while(1)
	
	# Print residues in UPPER case if aligned with a query residue (match state), 
	# print residues in lower case if aligned with a gap in the query (insert state) 
	if ($outformat eq "psi")
	{
	    $template_residues=~tr/a-z//d; #delete lower case characters
	}

	$query_residues =~s/\*->//g;
	$query_residues =~s/<-\*//g;
	if (length($template_residues)!=length($query_residues)) 
	{
	    print("ERROR: Query and template lines do not have the same length!\n");
	    print("Q: $query_residues\n");
	    print("T: $template_residues\n");
	    my $bla;
	    print($bla);
	    exit;
	}

	# Check whether hit has sufficient coverage and score per column)
	my $residues_in_matches = $template_residues;
	$residues_in_matches =~ tr/-a-z//d;
	my $n_residues_in_matches=length($residues_in_matches);
	my $matches_or_deletes=$template_residues;
	$matches_or_deletes=~tr/a-z//d;
	my $n_matches_or_deletes=length($matches_or_deletes);
	$coverage = 100*$n_residues_in_matches/$n_matches_or_deletes;
	$score_col=$score/$n_matches_or_deletes;

#	print("n:$nhit  seq:$template_residues\n");
	if ($coverage>=$cov_thrshd && $score_col>=$sc_thrshd) { # print sequence record? 
	    if ($outformat eq "a3m" || $outformat eq "a2m" || $outformat eq "fas" || $outformat eq "ufas") {
		$hitnames[$nhit] = sprintf(">$nameline E=%g s/c=%4.2f cov=%.0f%% \n",$Evalue,$score_col,$coverage); 
	    } else {
		$hitnames[$nhit] = sprintf("$nameline ");
	    }

	    # Print template residues before residues in alignment with hmm
#	    if ($first{$key}>1)     {$template_residues = ("-"x($first{$key}-1)).$template_residues;}
#	    if ($len>$last{$key}) {$template_residues = $template_residues.("-"x($len-$last{$key}));}
	    if ($first[$idom]>1)     {$template_residues = ("-"x($first[$idom]-1)).$template_residues;}
	    if ($len>$last[$idom]) {$template_residues = $template_residues.("-"x($len-$last[$idom]));}

	    $hitseqs[$nhit] = $template_residues; 
	    $nhit++;
	}
	$template_residues="";
	$query_residues="";
	next;
    } # end elseif found a new occurence of Expect = some-value
    $line = <INFILE>;
    if (!$line) {last;}
} # end while ($line)
close INFILE;


# If output format is fasta we have to insert gaps:
if ($outformat eq "a2m" || $outformat eq "fas")
{
    my @len_ins; # $len_ins[$j] will count the maximum number of inserted residues after match state $j.
    my $j;       # counts match states
    my @inserts; # $inserts[$j] contains the insert (in small case) of sequence $k after the $j'th match state
    my $insert;

    for ($k=0; $k<$nhit; $k++)
    {
	# split into list of single match states and variable-length inserts
	# ([A-Z]|-) is the split pattern. The parenthesis indicate that split patterns are to be included as list elements
	# The '#' symbol is prepended to get rid of a perl bug in split
	$j=0;
 	@inserts = split(/([A-Z]|-)/,"#".$hitseqs[$k]."#");
#	printf("Sequence $k: $hitseqs[$k]\n");
#	printf("Sequence $k: @inserts\n");
	foreach $insert (@inserts) 
	{
	    if( !defined $len_ins[$j] || length($insert)>$len_ins[$j]) {$len_ins[$j]=length($insert);}
	    $j++;
#	    printf("$insert|");
	}
#	printf("\n");
    }
    my $ngap;

    for ($k=0; $k<$nhit; $k++)
    {
	# split into list of single match states and variable-length inserts
	@inserts = split(/([A-Z]|-)/,"#".$hitseqs[$k]."#");
	$j=0;
	
	# append the missing number of gaps after each match state
	foreach $insert (@inserts) 
	{
	    if($outformat eq "fas") {for (my $l=length($insert); $l<$len_ins[$j]; $l++) {$insert.="-";}}
	    else                    {for (my $l=length($insert); $l<$len_ins[$j]; $l++) {$insert.=".";}}
	    $j++;
	}
	$hitseqs[$k] = join("",@inserts);
	$hitseqs[$k] =~ tr/\#//d; # remove the '#' symbols inserted at the beginning and end
	if ($outformat eq "fas") {$hitseqs[$k] =~ tr/a-z./A-Z-/d;}
    }
}

if ($outformat eq "ufas")
{
    for ($k=0; $k<$nhit; $k++)
    {
	$hitseqs[$k]=~tr/a-z/A-Z/; #transliterate lower case to upper case
	$hitseqs[$k]=~tr/.-//d;    #delete all gaps
    }
}

#Append to output file?
if ($append) {open (OUTFILE, ">>$outfile")|| die ("cannot open $outfile:$!");}
else {open (OUTFILE, ">$outfile") || die ("cannot open $outfile:$!");}

#Write sequences into output file
for ($k=0; $k<$nhit; $k++)
{
    printf(OUTFILE "%s%s\n",$hitnames[$k],$hitseqs[$k]);
}
close OUTFILE;

if ($v>=2) {print("alignhmmer.pl: $nhit sequences written to file $outfile\n");}

# Return number of hits in one byte (0-255)
if    ($nhit<110)  {exit $nhit;}
elsif ($nhit<1100) {exit 100+int($nhit/10);}
elsif ($nhit<5500) {exit 200+int($nhit/100);}
else               {exit 255;}              
exit(0);
