#! /usr/bin/perl -w
# Usage:   envmat.pl
use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/bioprogs/hhpred";  # forchimaera  webserver: MyPaths.pm
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm
use strict;
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with path variables for nr, blast, psipred, pdb, dssp etc.
 
if (@ARGV<2) {
    print("\nMake environment-specific, assymetric mutation matrices P(a|b,s,r) for hhsearch's -envi option.\n");
    print(" a = amino acid in sequence alignment to mutate into {0,...,19}\n");
    print(" b = amino acid in pdb file that mutates into a {0,...,19}\n");
    print(" s = secondary structure state {H,E,C}\n");
    print(" r = rel. solvent accessibility state  -: no coord, A:<2%, B:<14%, C:<33%, D:<55%, E:>55%, F:S-S bridge\n");
    print("Read DSSP data on SS and rel. SA state from hhm files.\n");
    print("Usage:   envmat.pl <file-glob> <outfile>  [<Neff_min>]\n");
    print("Example: envmat.pl '*.hhm' env.mat 7\n");
    exit;
}

my $v=2;
my $Neff_min=7; # Minimum Neff for column to contribute
my @files = glob($ARGV[0]);
my $outfile = $ARGV[1];
if (@ARGV>=3) {$Neff_min=$ARGV[2];} 
my $infile;
my $base;       # basename of hmmfile (no extension)
my $line;       # input line
my $files=0;    # number of files read in
my $ss_dssp;    # SS state string
my @ss_dssp;    # SS state array
my $sa_dssp;    # rel. SA state string
my @sa_dssp;    # rel. SA state array
my $qres;       # query amino acids string
my @qres;       # query amino acids array
my $i;          # index for column in HMM
my $l;          # index for line in hhm file
my ($a,$aa);
my ($b,$bb);
my ($s,$ss);
my ($r,$rr);
my @Csrab;      # $Cabsr[$a][$b][$s][$r] = summed frequencies of amino acid a aligned to pdb residue b at struc env s,r;
my @Csr;        # $Cabsr summed over a, b
my @Csrb;       # $Cabsr[$a][$b][$s][$r] = summed frequencies of pdb residue b at struc env s,r;
my @Ca;         # total counts of amino acid a in alignment
my @Cb;         # total counts of amino acid b from pdb file
my $C=0;        # sum of all counts
my @Cab;        # for debugging purposes
my @Csab;       # average of Csrab over r; used to set matrix for r:S-S bridges when b!=Cys
my $cols=0;     # number of profile columns contributing to counts

#         A    R    N    D    C    Q    E    G    H    I     L    K    M    F    P    S    T    W    Y    V
@Ca = ( 9.1, 5.2, 3.4, 4.6, 1.4, 3.5, 6.4, 4.7, 2.2, 8.0, 11.6, 5.1, 2.4, 4.7, 2.7, 5.6, 5.0, 1.4, 3.6, 8.5);
@Cb = (10.1, 5.2, 2.9, 4.1, 1.2, 4.0, 7.0, 4.3, 2.1, 7.5, 11.6, 5.4, 2.5, 4.5, 2.2, 4.6, 5.1, 1.5, 3.9, 9.5);

# Initialize count vectors
if ($v>=2) {printf("Initialize count vectors ...\n");}
for ($s=0; $s<=3; $s++) {
    for ($r=0; $r<=6; $r++) {	    
	if (($s==0 && $r!=0) || ($s!=0 && $r==0)) {next;} 
	$Csr[$s][$r]=0;
	for ($a=0; $a<20; $a++) {
	    for ($b=0; $b<20; $b++) {
		$Csrab[$s][$r][$a][$b] = $Ca[$a]*$Cb[$b]; #pseudocounts
	    }
	}
	for ($b=0; $b<20; $b++) {
	    $Csrb[$s][$r][$b]=0;
	}
    }
}
for ($a=0; $a<20; $a++) {$Ca[$a]=0;}
for ($b=0; $b<20; $b++) {$Cb[$b]=0;}
for ($a=0; $a<20; $a++) {
    for ($b=0; $b<20; $b++) {
	$Cab[$a][$b]=0;
	for ($s=1; $s<=3; $s++) {
	    $Csab[$s][$a][$b] = 0;
	}
    }
}

# Read in one hhm-file after the other
if ($v>=2) {printf("Reading %i files ...\n\n",scalar(@files));}
foreach $infile (@files) {
    
    if ($v>=3) {printf("Reading %s ... \n",$infile);}
    if ($infile=~/(.*)\..*$/) {$base=$1;} else {$base=$infile;}
    if (!open (INFILE,"<$infile")) {warn("\nError: can't open $infile: $!\n"); next;}
    
    while ($line=<INFILE>) {if ($line=~/^SEQ/) {last;}}
    
    # Read secondary structure states
    while ($line!~/^>ss_dssp/) {if (!($line=<INFILE>)) {last;}} # advance to >ss_dssp line
    if (!$line) {warn("\nWARNING: did not find >ss_dssp line in $infile\n"); next;}
    $ss_dssp="";
    while ($line=<INFILE>) { # read >ss_dssp line
	if ($line=~/^>/) {last;}
	$ss_dssp.=$line;
    } 
    $ss_dssp=~tr/\n//d;
    @ss_dssp = map(&ss2i($_), unpack("C*",$ss_dssp) );

    # Read solvent accessibility states
    while ($line!~/^>sa_dssp/) {if (!($line=<INFILE>)) {last;}} # advance to >ss_dssp line
    if (!$line) {warn("WARNING: did not find >sa_dssp line in $infile\n"); next;}
    $sa_dssp="";
    while ($line=<INFILE>) { # read >ss_dssp line
	if ($line=~/^>/) {last;}
	$sa_dssp.=$line;
    } 
    $sa_dssp=~tr/\n//d;
    @sa_dssp = map(&sa2i($_), unpack("C*",$sa_dssp) );

    # Read query amino acid residues
    while (($line!~/^>/ || $line=~/^>(ss_|sa_|aa_|Consensus)/)) {if (!($line=<INFILE>)) {last;}} # advance to >query line
    if (!$line) {warn("\nWARNING: did not find >query line in $infile\n"); next;}
    $qres="";
    while ($line=<INFILE>) { # read >query line
	if ($line=~/^>/) {last;}
	$qres.=$line;
    } 
    $qres=~tr/\n//d;
    @qres = map(&aa2i($_), unpack("C*",$qres) );

    if ($v>=4) {
	printf("qres     %s\n",$qres);
	printf("ss_dssp  %s\n",$ss_dssp);
	printf("sa_dssp  %s\n\n",$sa_dssp);
	print(" No  AA  SS  SA\n");
	for($i=0; $i<@qres; $i++) {
	    printf("%3i  %2i  %2i  %2i\n",$i+1,$qres[$i],$ss_dssp[$i],$sa_dssp[$i]);
	}
    }

    # Read amino acid frequencies
    while ($line=<INFILE>) {if ($line=~/^HMM    /) {last;}} # advance to beginning of frequency table
    <INFILE>; <INFILE>;
    while ($line=<INFILE>) {
	if ($line=~/^\/\//) {last;}
	if ($line=~/^\s*$/) {next;} # skip blank lines
	my @fields = split(/\s+/,$line);
	$a = shift(@fields);        # drop first field (consensus amino acid)
	$i = shift(@fields)-1; # read match state -1 
	pop(@fields);          # drop last field
	if (@fields!=20) {die("Error: wrong number of fields in $infile, line $.\n");}
	$line = <INFILE>; # read Neff in transition line
	if ($line !~ /^\s*\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)/) {die("Error in $infile, line $.: wrong format\n")}
	my $Neff = 0.001*$1; # Neff-1 is used as weight for the aa frequency counts
#	printf("%3i  %1s  %2i  %2i  %2i\n",$i+1,$a,$qres[$i],$ss_dssp[$i],$sa_dssp[$i]);
	if ($Neff<=$Neff_min) {next;}
	my $sum=0;
	for($a=0; $a<20; $a++) {
	    my @s2a = (0, 4, 3, 6,13, 7, 8, 9,11,10,12, 2,14, 5, 1,15,16,19,17,18,20);
	    if ($fields[$a] ne "*") {
		my $aa = $s2a[$a]; # transform from sorted alphabetical to ARND... order
		$Csrab[$ss_dssp[$i]][$sa_dssp[$i]][$aa][$qres[$i]] += ($Neff-1)* 2.0**(-0.001*$fields[$a]); 
#		$sum += 2.0**(-0.001*$fields[$a]);
	    }
	}
#	printf("=> sum=%6.4f\n",$sum);
	$cols++;
    }
    close (INFILE);
    if ($v>=2) {
	printf(STDERR ".");
	if (!(++$files % 100)) {printf(STDERR " %i\n",$files);}
    }
}
if ($v>=2) {printf("\nFound %i profile columns with Neff>%6.2f ...\n",$cols,$Neff_min);}


# Sum up partial counts
if ($v>=2) {print("\nSumming up partial counts ...\n");}
for ($s=0; $s<=3; $s++) {
    for ($r=0; $r<=6; $r++) {	    
	if (($s==0 && $r!=0) || ($s!=0 && $r==0)) {next;} 
	for ($a=0; $a<20; $a++) {
	    for ($b=0; $b<20; $b++) {
		my $c = $Csrab[$s][$r][$a][$b];
		$Cab[$a][$b]      += $c;
		$Csrb[$s][$r][$b] += $c;
		$Csr[$s][$r]      += $c;
		$Csab[$s][$a][$b] += $c;
	    }
	}
	$C += $Csr[$s][$r];
    }
}
for ($a=0; $a<20; $a++) {
    for ($b=0; $b<20; $b++) {
	$Ca[$a] += $Cab[$a][$b];
	$Cb[$b] += $Cab[$a][$b];
    }
}

# Calculate matrix P(a|b,s,S-S) = average_r P(a|b,s,r)
for ($s=1; $s<=3; $s++) {
    for ($b=0; $b<20; $b++) {
	if ($b!=4) {
	    $Csrb[$s][6][$b] = 0;
	    for ($a=0; $a<20; $a++) {
		$Csrab[$s][6][$a][$b] = $Csab[$s][$a][$b];
		$Csrb[$s][6][$b] += $Csab[$s][$a][$b];
	    }
	}
    }
}


# Calculate averages

# Display aa frequencies and average substitution matrix 
if ($v>=2) {
    print("\nProfile amino acid frequencies:\n");
    print("    A    R    N    D    C    Q    E    G    H    I    L    K    M    F    P    S    T    W    Y    V\n ");
    for($a=0; $a<20; $a++) {printf("%4.1f ",100*$Ca[$a]/$C);}
    print("\n\n");
    print("PDB amino acid frequencies:\n");
    print("    A    R    N    D    C    Q    E    G    H    I    L    K    M    F    P    S    T    W    Y    V\n ");
    for($b=0; $b<20; $b++) {printf("%4.1f ",100*$Cb[$b]/$C);}
    print("\n\n");

    print("\nAveraged substitution matrix:\n");
    print("     A    R    N    D    C    Q    E    G    H    I    L    K    M    F    P    S    T    W    Y    V\n");
    my $sum=0;
    for($a=0; $a<20; $a++) {
	printf("  ");
	for($b=0; $b<20; $b++) {
	    printf("%4.1f ",3*1.4426*log($Cab[$a][$b]*$C/$Ca[$a]/$Cb[$b]));
	}
	$sum += $Cab[$a][$a]/$C;
	print("\n");
    }
    printf("Sum of P(a,a) = %6.2f%%\n\n",100*$sum);
}




# Writing environment-specific substitution matrices
if ($v>=2) {print("Writing environment-specific rate matrices P(a|b,s,r) ...\n");}
open(OUT,">$outfile") || die("Error: can't open $outfile: $!\n");
for ($s=0; $s<=3; $s++) {
    for ($r=0; $r<=6; $r++) {	    
	if (($s==0 && $r!=0) || ($s!=0 && $r==0)) {next;} 
	printf(OUT ">ss=%i sa=%i\n",$s,$r);
	for ($a=0; $a<20; $a++) {
	    for ($b=0; $b<20; $b++) {
		printf(OUT "%3.0f ", 1000*$Csrab[$s][$r][$a][$b]/$Csrb[$s][$r][$b]);
	    }
	    print(OUT "\n");
	}
	print(OUT "\n");
    }
}
close(OUT);
exit(0);

#############################################################################################

# Transform SS letter code into integer
sub ss2i() 
{
    if ($_[0]==ord('H')) {return 1;}
    if ($_[0]==ord('E')) {return 2;}
    if ($_[0]==ord('C')) {return 3;}
    if ($_[0]==ord('S')) {return 3;}
    if ($_[0]==ord('T')) {return 3;}
    if ($_[0]==ord('B')) {return 3;}
    if ($_[0]==ord('G')) {return 3;}
    if ($_[0]==ord('I')) {return 3;}
    if ($_[0]==ord('-')) {return 0;}
    return 99;
}

# Transform rel. SA letter code into integer
sub sa2i() 
{
    if ($_[0]==ord('-')) {return 0;}
    if ($_[0]==ord('A')) {return 1;}
    if ($_[0]==ord('B')) {return 2;}
    if ($_[0]==ord('C')) {return 3;}
    if ($_[0]==ord('D')) {return 4;}
    if ($_[0]==ord('E')) {return 5;}
    if ($_[0]==ord('F')) {return 6;}
    return 99;
}

# Transform SS letter code into integer

# A  R  N  D  C  Q  E  G  H  I  L  K  M  F  P  S  T  W  Y  V  X
sub aa2i() 
{
    if ($_[0]==ord('A')) {return 0;}
    if ($_[0]==ord('R')) {return 1;}
    if ($_[0]==ord('N')) {return 2;}
    if ($_[0]==ord('D')) {return 3;}
    if ($_[0]==ord('C')) {return 4;}
    if ($_[0]==ord('Q')) {return 5;}
    if ($_[0]==ord('E')) {return 6;}
    if ($_[0]==ord('G')) {return 7;}
    if ($_[0]==ord('H')) {return 8;}
    if ($_[0]==ord('I')) {return 9;}
    if ($_[0]==ord('L')) {return 10;}
    if ($_[0]==ord('K')) {return 11;}
    if ($_[0]==ord('M')) {return 12;}
    if ($_[0]==ord('F')) {return 13;}
    if ($_[0]==ord('P')) {return 14;}
    if ($_[0]==ord('S')) {return 15;}
    if ($_[0]==ord('T')) {return 16;}
    if ($_[0]==ord('W')) {return 17;}
    if ($_[0]==ord('Y')) {return 18;}
    if ($_[0]==ord('V')) {return 19;}
    if ($_[0]==ord('X')) {return 20;}
    if ($_[0]==ord('U')) {return 4;}
    if ($_[0]==ord('B')) {return 3;}
    if ($_[0]==ord('Z')) {return 6;}
    return 99;
}

