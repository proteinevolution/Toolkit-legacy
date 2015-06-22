#!/usr/bin/perl -w
# Build a database from a fasta sequence file
# Read sequences from file one by one:
# 
#  I 1. querydb.pl      iterated psiblast search (e.g. 3 rounds) with h=1E-10 and E=1000 
#    2. alignhits.pl    align the psiblast hits into alignment file
#    3. ppfilter        filter the hits for coverage, sequence diversity and similarity to query
#    4. clustal         do Clustal alignment
#
# II 1. hmmbuild        build HMM from alignment
#    2. hmmsearch       search with HMM against database from step 1
#    3. alignhmmhits.pl aligns hits with E<1E-5 from hmmsearch results file
#III 1. hmmbuild        build HMM from alignment
#    2. hmmsearch       search with HMM against database from step 1
#    3. alignhmmhits.pl aligns hits with E<1E-4 from hmmsearch results file

# Usage: builddb_hmm.pl infile outdir
# Example: 
# nice -19 builddb_hmm.pl ../seq/pdb95.seq ./ > ./builddb.log &

use strict;
$|= 1; # Activate autoflushing on STDOUT

sub fexit()
{
    print("\nBuild a database from a fasta sequence file.\n");
    print("Read sequences from file one by one an do:                                    -> name.seq\n"); 
    print("  I 1. querydb.pl      iterated psiblast search with E<Epsi                   -> name.db,    name_psiblast.tmp \n"); 
    print("    2. alignhits.pl    align the psiblast hits into alignment file            -> name.0.a3m  name.0.fas\n"); 
    print("    3. ppfilter        filter for coverage, diversity and similarity to query -> name.1.a3m, name.1.fas, name.ufas\n");
    print("    4. clustal         do Clustal alignment                                   -> name.aln\n"); 
    print(" II 1. hmmbuild        build HMM from alignment                               -> name.hmm\n");  
    print("    2. hmmsearch       search with HMM against database from step 1           -> name.2.hms\n"); 
    print("    3. alignhmmhits.pl aligns hits with E<Epenult from hmmsearch results file -> name.2.a3m, name.2.fas \n"); 
    print("III 1. hmmbuild        build HMM from alignment                               -> name.hmm\n"); 
    print("    2. hmmsearch       search with HMM against database from step 1           -> name.3.hms\n"); 
    print("    3. alignhmmhits.pl aligns hits with E<Eult from hmmsearch results file    -> name.a3m,   name.fas\n"); 
    print("\n"); 
    print("Usage: builddb_hmm.pl infile outdir\n");
    print("Example: nice -19 builddb_hmm.pl ../seq/pdb95.seq . > ./builddb.log &\n\n");
    exit;
};


# Default values:

# Programs used
my $hmmbuild="hmmbuild -F -g";   #'-g': global HMM; '-s': local HMM (-F: force overwriting)
my $alignment="clustal";          #alignment program: clustal or pcma
# E-value thresholds
my $Epsi=1E-5 ;                   #Psiblast Evalue threshold for building profile
my $Epsi2=1E-5;                   #Evalue threshold for building HMM from psiblast output 
my $Epenult=1E-5;                 #penultimate Evalue threshold for hmmsearch
my $Eult=1E-4;                    #ultimate Evalue threshold for building output alignment from hmmsearch results
# Filter thresholds for sequences before aligning with clustal and building an HMM 
my $id=90;                        #maximum sequence identity before clustal  
my $qid=30;                       #minimum sequence identity before clustal
my $cov=0;                        #minimum coverage before clustal
my $min_hitlen=50;                #minimum number of residues in match states 
my $Ndiff=50;                     #number of maximally different sequences before clustal
# Directory paths
my $nr = "/home/soeding/nr/nr70"; #nr database to be used
my $perl="/home/soeding/perl";    #perl directory: querydb.pl, alignhits.pl
my $pp="/home/soeding/pp";        #ppfilter


# Variable declarations
my $infile=$ARGV[0];
my $outdir=$ARGV[1];
my $currfile="delme.tmp";
my $query_length;
my $query_residues;
my $line;
my %nfiles=();         # how many files already exist for a certain scop classification?
my $scopid;
my $name;
my $nhits_last=0;
my $overwrite=0;       # 1: overwrite  -1:skip existing files  0:inquire 


print ("Running builddb_hmm.pl @ARGV:\n");
print ("$hmmbuild\n");
print ("alignment= $alignment\n");
print ("Epsi     = $Epsi\n");
print ("Epsi2    = $Epsi2\n");
print ("Epenult  = $Epenult\n");
print ("Eult     = $Eult\n");
print ("id       = $id\n");
print ("qid      = $qid\n");
print ("cov      = $cov\n");
print ("min_len  = $min_hitlen \n");
print ("Ndiff    = $Ndiff\n");
print ("nr db    = $nr\n");
print ("\n");

if (scalar(@ARGV)<2) {&fexit();}

open (INFILE, "<$infile") || die ("cannot open $infile: $!");
open (ALIFILE, ">delme.tmp")|| die ("cannot open delme.tmp: $!");

# Take one sequence after the other, write it into its file $name.seq 
# and run iterative PsiBlast for each sequence by calling &PsiBlast()
while (1) #assign next line of file to $inline while there is a next line
{
    $line=<INFILE>;
    if( (!$line) || ($line=~/^>/) )
    {
	close ALIFILE;

	if ($currfile ne "delme.tmp") {&BuildAlignment();} #build alignment around sequence in $currfile
	if( (!$line)) {last;} # if no more new line => stop reading in

#	print("Reading $line");

	# Read nameline and extract SCOP family code
	if ($line=~/^>([a-z]\S+)\s+([a-k]\.\d+\.\d+\.\d+)\s+/)
	{
	    $name=$line;
	    $name=~tr/ /~/;
 	    $scopid=$2;
	    print("pdb=$1   SCOP-ID=$scopid\n");
	    # determine number $nfiles{$scopid} of sequences already found with same scop-id	    
	    if (exists $nfiles{$scopid})  {$nfiles{$scopid}++;}  else {$nfiles{$scopid}=1;}
	    $currfile="$outdir/$scopid.$nfiles{$scopid}";
	}
	else 
	{
	    $line=~/>(\S+)/;
	    $currfile="$outdir/$1";
	    $name=$line;
	}

	# Open next sequence file (Does it exist already? If yes: overwrite or skip?)
	if (-s "$currfile.a3m")  # does the a3m file already exist?
	{
	    if ($overwrite==0) 
	    {
		print("$currfile.a3m already exists. Overwrite existing alignment files? (y)  "); 
		$line=<STDIN>;
		if ($line =~/^[Yy]/) {$overwrite=1; print("Overwriting existing alignments\n");} 
		else {$overwrite=-1; print("Skipping exsting alignments\n");}
	    }
	    if ($overwrite==-1) {$currfile="delme.tmp"; open(ALIFILE,">delme.tmp");}	
	}
	else {print("$currfile.a3m does not exist yet\n");}
	if ( (!(-s "$currfile.a3m") || $overwrite==1) && $currfile ne "delme.tmp")
	{
	    # Open new file to hold query sequence. Later used to append aligned hits 
	    open (ALIFILE, ">$currfile.seq")|| die("can't open $currfile.seq: $!");
	    print(ALIFILE "$name"); # Write query name in first line of file
	    $query_residues="";
	    $query_length=0;
	}
    }
    elsif ($currfile ne "delme.tmp")
    {
#	print("Residues: $line");
	$line=~tr/a-z/A-Z/; # transform into upper case
	$query_length+=length($line);
	$query_residues.=$line;
	print(ALIFILE "$line");
     }
}
close ALIFILE;
close INFILE;

print ("\nFinished  builddb_hmm.pl @ARGV\n\n");
exit;

sub System()
{
    my $command=$_[0];
    print("\nCalling '$command'\n"); 
    return system($command)/256; # && die("\nERROR: $!\n\n"); 
}


# Build an alignment around sequence in $currfile	    
sub BuildAlignment
{
    print("\n\n********************************\n");
    print("Building alignment for $currfile\n");
    print("********************************\n  ");

    my $nhits;     # number of sequences returned from ppfilter: 0:0, 1-100: 1, 101-200: 2, etc. >=25401: 255

    # Minimum length of hits is 50 residues in match states
    my $cov0 = $min_hitlen/$query_length;
    if ($cov0>=90) {$cov0=90;}
    if ($cov0<=$cov) {$cov0=$cov;}

    #   I 1. Create a fasta database file of all hits with E<1E4 (for j=4 ca. 2 min)
    #        The psiblast results file will be in $currfile_psiblast.tmp
    &System("$perl/querydb.pl -j 4 -h $Epsi -b 30000 -e 1000 -d $nr $currfile.seq $currfile.db");
    open (QUERYDB,">>$currfile.db");
    printf(QUERYDB ">Query\n$query_residues\n"); #do not use query name (otherwise it will appear twice at the end)
    close (QUERYDB);

    #   I 2. Align hits in $currfile_psiblast.tmp
    &System("$perl/alignhits.pl -e $Epsi2 -a3m $currfile"."_psiblast.tmp $currfile.0.a3m");
    &System("$perl/reformat.pl a3m fas $currfile.0.a3m $currfile.0.fas");

    #   I 3. Align hits in $currfile_psiblast.tmp
    $nhits = &System("$pp/ppfilter -id $id -qid $qid -cov $cov -diff $Ndiff -i $currfile.0.a3m -o $currfile.1.a3m");
    print("ppfilter returned $nhits\n");
    &System("$perl/reformat.pl a3m fas  $currfile.1.a3m $currfile.1.fas");
    &System("$perl/reformat.pl -num a3m ufas $currfile.1.a3m $currfile.1.ufas");

    #   I 4. Align sequences with clustal => $currfile.aln (20 s)
    if ($alignment eq "clustal" && $nhits>1) {&System("clustalw $currfile.1.ufas > log");}
    elsif ($alignment eq "pcma" && $nhits>1) {&System("pcma $currfile.1.ufas > log");}


    #  II 1. Build HMM from $currfile.aln 
    if ($nhits>1) {&System("$hmmbuild $currfile.hmm $currfile.1.aln");}
    else           {&System("$hmmbuild $currfile.hmm $currfile.seq");}

    #  II 2. Search with HMM against database $currfile.db (1.5 min)
    &System("hmmsearch $currfile.hmm $currfile.db > $currfile.2.hms");

    #  II 3. Extract hits with E<Epenult from hmmsearch results
    &System("$perl/alignhmmhits.pl -fas -e $Epenult $currfile.2.hms $currfile.2.fas");


    # III 1. Build HMM from $currfile.aln  (5 s)
    &System("$hmmbuild $currfile.hmm $currfile.2.fas");

    # III 2. Search with HMM against database $currfile.db (1.5 min)
    &System("hmmsearch $currfile.hmm $currfile.db > $currfile.3.hms");

    # III 3. Extract hits with E<Epenult from hmmsearch results
    &System("$perl/alignhmmhits.pl -q $currfile.seq -ufas -e $Epenult $currfile.3.hms $currfile.ufas");

    # III 4.
    &System("hmmalign -o $currfile.sto $currfile.hmm $currfile.ufas");
    &System("$perl/reformat.pl sto a3m $currfile.sto $currfile.a3m");
    &System("$perl/reformat.pl sto fas $currfile.sto $currfile.fas");


    # Substitute name of first sequence in $currfile.a3m by its full name
    my $n=0;   #number of sequences
    my @nam;   #names of sequences     
    my @seq;   #residues of sequences
    my $in;
    open (OUTFILE, "<$currfile.a3m") || die ("cannot open $currfile.a3,: $!");
    while ($in=<OUTFILE>) 
    {
	if ($in=~/>(\S+)/)
	{
	    $n++;
	    $nam[$n]=$in;
	    $seq[$n]="";
	}
	else {$seq[$n].=$in;}
    }
    close(OUTFILE);
    $nam[1]=$name;

    open (OUTFILE, ">$currfile.a3m") || die ("cannot open $currfile.a3m: $!");
    for (my $m=1; $m<=$n; $m++) {print(OUTFILE $nam[$m].$seq[$m]);}
    close(OUTFILE);


    unlink ("$currfile.tmp");
#    unlink("$currfile.seq");
     unlink("$currfile"."_seq.tmp");
     unlink("$currfile"."_ali.tmp");
#    unlink("$currfile.db");
#    unlink("$currfile_psiblast.tmp");
#    unlink("$currfile.a2m");

} 

