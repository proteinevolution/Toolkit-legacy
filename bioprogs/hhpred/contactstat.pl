#! /usr/bin/perl -w
# Usage:   contactstat.pl file-glob outfile
BEGIN {
    push (@INC,"/home/soeding/perl"); 
    push (@INC,"/home/soeding/hh"); 
}
use strict;
use Align;

# Default parameters for Align.pm
our $d=3;  # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penatlty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
our $v=2;    # verbose mode
our $matrix="identity";

my $ARGC=scalar(@ARGV);
if ($ARGC<1) {
    
    print("\n");
    print("Read in all hhm files that match the file glob expression, read the corresponding pdb files (if necessary)\n");
    print("and record the statistics of how often each pair of residues a,b is at a certain spatial distance R\n");
    print("and sequence distance |i-j|. The script calls contacts.C which outputs a list of atom-atom contacts \n");
    print("(i j pair R) into a file *.contacts. \n");
    print("(i,j=residue numbers, pair=atom pair index, R=spatial distance in Angstrom)\n"); 
    print("\n");
    print("Usage:   contactstat.pl 'file-glob' outfile\n");
    print("Example: contactstat.pl '*.hhm' contactstat.txt\n");
    print("\n");
    
    exit;
}

my $SEPTHR=5;   # sep=0: j2-j1<=SEPTHR   sep=1: j2-j1>SEPTHR 
my $SEPMAX=2;   # sep runs from 0 to $SEPMAX-1
my $RMIN=3;     # spatial distance is classified from RMIN to RMAX
my $RMAX=8;     # 
my $RNUM=$RMAX-$RMIN+1;
my $PAIRMAX=5;  # pair runs from 0 to PAIRMAX-1
my $INTSCALE=1000;
my $pdbdir="/raid/db/pdb";
my @files = glob($ARGV[0]);
my $outfile = $ARGV[1];
my $infile;
my $base;       # basename of infile (no extension)
my $line;       # input line
my $name;       # name of scop query sequence for infile
my $Naa;        # mean number of amino acids per column of HMM
my $chain;      # chain id of scop query sequence for infile 
my $pdbfile;    # pdbfile corresponding to query sequence
my $i;          # index for column in HMM
my $j;          # index for column in HMM
my $a;          # index for amino acid
my $b;          # index for amino acid
my $r;          # spatial distance
my $sep;        # sequence separation j-i of a pair of residues
my $pair;       # 1 for CB-CB, 2 for CB-O, 3 for O-CB, 4 for CB-N, 5 for N-CB
my @Pnull;      # background frequencies for HMM
my @p;          # $p[i][a]=
my $entropy;    # average entropy of the HMM
my $weight;     # weight = exp(entropy)
my $logodds;    # log-odds values read in from HMM
my $L;          # number of columns in HMM

my @Csprab;     # counts with residues a, b, separation sep, atom pair p, and spatial distance d
my @Cspr;       # counts with separation sep, atom pair p, and spatial distance d
my $C;          # total counts
my @Cnull;      # weighted sum of background frequencies of HMMs (to average $Pnull[])
my @Pab;
my @Pspr;
my @Psprab;

my $PC=1;       # total pseudocounts
my $PCspr  =$PC/$SEPMAX/$PAIRMAX/$RNUM;
my $PCsprab=$PC/$SEPMAX/$PAIRMAX/$RNUM/400;

# Initialize count arrays
$C=$PC;
if ($v>=2) {print("Initializing count arrays ...\n");}
for ($a=1; $a<=20; $a++) {
    for ($b=1; $b<=20; $b++) {
	for ($sep=0; $sep<$SEPMAX; $sep++) {
	    for ($pair=0; $pair<$PAIRMAX; $pair++) {
		for ($r=$RMIN; $r<=$RMAX; $r++) {
		    $Csprab[$sep][$pair][$r][$a][$b]=$PCsprab;
		}
	    }
	}
    }
}

#####################################################################################################
# Read in one hhm-file after the other
foreach $infile (@files) {
    
    my $aaq;        # query amino acids
    if ($infile=~/(.*)\..*$/) {$base=$1;} else {$base=$infile;}

    # Open hhm file and read name and chain id of query
    if ($v>=2) {printf("Reading %-15.15s ... ",$infile);}
    if (!open (INFILE,"<$infile")) {warn("Error: can't open $infile: $!\n"); next;}
    while ($line=<INFILE>) {if ($line=~/NAME/) {last;} }
    if ($line!~/NAME\s+(\S+)/) {warn ("Error: can't fine NAME line in $infile: $!\n"); next;}
    $name=$1;
    $name=~/^[a-z](\w{4})(\S)./;
    $pdbfile="$pdbdir/pdb$1.ent";
    if ($2 eq "_") {$chain="[A ]";} elsif ($2 eq ".") {$chain=".";} else {$chain=uc($2);}

    # Read number of different residues per column
    while ($line=<INFILE>) {if ($line=~/^NAA\s+/) {last;} }
    if ($line!~/^NAA\s+(\S+)/) {warn("Error: can't fine query sequence $name in $infile: $!\n"); next;}
    $Naa=$1;

    # Read query sequence $aaq
    $aaq="";
    while ($line=<INFILE>) {if ($line=~/^>$name/) {last;} }
    if ($line!~/^>$name/) {warn("Error: can't fine query sequence $name in $infile: $!\n"); next;}
    while ($line=<INFILE>) {if ($line=~/^[>\#]/) {last;} chomp($line); $aaq.=$line;}
    $aaq=~tr/a-z.//d;  # remove all inserts

    # Read in whole-protein average frequencies
    @p=();
    while ($line=<INFILE>) {if ($line=~/FREQ\s/ || $line=~/NULE\s/) {last;} }
    if ($line!~s/^NULE\s+// && $line!~s/^FREQ\s+//) {warn("Error: can't fine FREQ line in $infile: $!\n"); next;}
    for ($a=1; $a<=20; $a++) {
	if ($line!~s/(\S+)\s*//) {
	    warn("Error: wrong format in $infile: insufficient number of aa frequencies in NULE line: $!\n'$line'\n");
	    next;
	}
	$Pnull[$a]=0.05*2.0**($1/$INTSCALE);
    }
    
    # Read in amino acid frequencies
    <INFILE>; <INFILE>; <INFILE>;
    $entropy=0;
    while ($line=<INFILE>) {
	if ($line=~s/^.\s(\d+)\s+//) {
	    $i=$1;
	    $p[$i]=();
	    for ($a=1; $a<=20; $a++) {
		if ($line!~s/(\S+)\s*//) {
		    warn("Error: wrong format in $infile: insufficient number of aa frequencies: $!\n'$line'\n");
		    next;
		}
		$logodds=$1;
		if ($logodds eq "*") {
		    $p[$i][$a]=0;
		} else {
		    $p[$i][$a]=$Pnull[$a]*2.0**($logodds/$INTSCALE);
		    $entropy-=$p[$i][$a]*log($p[$i][$a]);
		}
	    }
	}
    }
    $L=$i;
    $entropy/=$L;
    $weight=exp($entropy);
    close (INFILE);

    # Debugging output
    if ($v>=4) {
	printf("FREQ ");
	for ($a=1; $a<=20; $a++) {printf(" %6.2f",$Pnull[$a]*100.0);}
	print("\n");
	for ($i=1; $i<=$L; $i++) {
	    printf("%-3i",$i);
	    for ($a=1; $a<=20; $a++) {printf(" %6.2f",$p[$i][$a]*100.0);}
	    print("\n");
	}
    }
    
    ################################################
    # Generate pdb file for astral/scop sequence?
    if (!-e "$base.contacts" && !-e "$base.pdb") {
	
	my $l;          # index for lines in pdb file 
	my @pdbline;    # $pdbline[$l][$natom] = line in pdb file for lth residue in $aapdb and atom N, CB, or O
	my $natom;      # runs from 0 up to 2 (N, CB, O) 
	my $res;        # residue in pdb line
	my $atom;       # atom code in pdb file (N, CA, CB, O, ...)
	my $aapdb;      # template amino acids from pdb file
	my $col;        # column of alignment query (from hhm file) versus pdb-residues
	
	# Read pdb file corresponding to $infile
	if (!open (PDBFILE,"<$pdbfile")) {warn("Error: can't open $pdbfile: $!\n"); next;}
	$l=0;
	while ($line=<PDBFILE>) {
# ATOM      1  N   GLY A   1     -19.559   8.872   4.925  1.00 16.44           N
# ATOM      2  CA  GLY A   1     -19.004   8.179   6.112  1.00 14.30           C
	    if ($line=~/^ATOM\s+\d+  (..) .(\w{3}) $chain\s*(\d+).*/ ) {
		$atom=$1;
		$res=$2;
		if ($atom eq "N ") { 
		    $l++;
		    $res=&Three2OneLetter($res);
		    $aapdb.=$res;
		    $pdbline[$l][0]=$line;
		    $natom=1;
		} elsif ($atom eq "O " || $atom eq "CB" || $atom eq "CA") {
		    $pdbline[$l][$natom++]=$line;
		}
	    }
	}
	close (PDBFILE);
	
	# Align scop query sequence ($aaq) with query sequence in pdb ($aapdb)	
	my $xseq=$aaq;
	my $yseq=$aapdb;
	my ($imin,$imax,$lmin,$lmax);
	my $Sstr;
	my $score;  
	my (@i,@l);    # The aligned characters are returend in $j[$col] and $l[$col]
	$score=&AlignNW(\$xseq,\$yseq,\@i,\@l,\$imin,\$imax,\$lmin,\$lmax,\$Sstr);  
	
	# DEBUG
	if ($v>=3) {
	}	
	
	# Print pdb file where residue index i corresponds exactly to the i'th scop sequence residue
	if (!open (SHORTFILE,">$base.pdb")) {warn("Error: can't open $base.pdb: $!\n"); next;}
	my $match=0; 
	my $len=length($aaq)-1; # 0'th position not used 
	for ($col=0; $col<@i; $col++) {
	    if ($i[$col] && $l[$col]) {
		$match++;
		for ($natom=0; $natom<scalar(@{$pdbline[$l[$col]]}); $natom++) {
		    $pdbline[$l[$col]][$natom]=~/(^ATOM\s+\d+  .. .\w{3} $chain).{4}(.*)/;
		    if ($v>=3) {printf("%s%4i%s\n",$1,$i[$col],$2);}
		    printf(SHORTFILE "%s%4i%s\n",$1,$i[$col],$2);
		}
	    }
	}
	close (SHORTFILE);
	
	if ($v>=3 || ($v>=1 && $len-$match>1)) {
	    if ($v>=1 && $len-$match>1) {
		printf("\nWARNING: could not find coordinates for %i query residues:\n",$len-$match);
	    } else { printf("\n"); }
	    printf("hhm: $xseq\n");
	    printf("id:  $Sstr\n");
	    printf("pdb: $yseq\n");
	    printf("\n");
	    if ($v>=4) {
		for ($col=0; $col<@l && $col<200; $col++) {
		    printf("%3i  %3i  %3i\n",$col,$i[$col],$l[$col]);
		}
	    }
	}
	
    } # end Generate pdb file for scop sequence
    ################################################
    
    # Call contacts.C to get list of contacts: i j pi R(i,j,pi)
    if (!-e "$base.contacts") {&System("~/hh/contacts $base.pdb $base.contacts");}
    
    # Read list of contacts and add counts
    if ($v>=3) {print("Adding counts from contacts ...\n");}
    if (!open (INFILE,"<$base.contacts")) {warn("Error: can't open $base.contacts: $!\n"); next;}
    my $l=0;
    while ($line=<INFILE>) {
	$l++;
	($i,$j,$pair,$r) = split(/\s+/,$line);
	if ($v>=5) {printf("i=%-3i j=%-3i pair=%1i  d=%1i\n",$i,$j,$pair,$r);}
	if ($j-$i>$SEPTHR) {$sep=1;} else {$sep=0;}
	if ($r<$RMIN) {$r=$RMIN;}
	for ($a=1; $a<=20; $a++) {
	    for ($b=1; $b<=20; $b++) {
		$Csprab[$sep][$pair][$r][$a][$b]+=$weight*$p[$i][$a]*$p[$j][$b];  # $Naa is used as weight factor
	    }
	}
    }
    close (INFILE);
    if ($v>=2) {printf("counted %i contacts\n",$l);}

    # Sum up whole-protein average frequencies
    for ($a=1; $a<=20; $a++) {$Cnull[$a]+=$weight*$Pnull[$a];}

} # end Reading in hhm files
#####################################################################################################


# Normalize amino acid frequencies
my $sum=0;
for ($a=1; $a<=20; $a++) {$sum+=$Cnull[$a];}
for ($a=1; $a<=20; $a++) {$Pnull[$a]=$Cnull[$a]/$sum;}
for ($a=1; $a<=20; $a++) {
    for ($b=1; $b<=20; $b++) {
	$Pab[$a][$b]=$Pnull[$a]*$Pnull[$b];
    }
}

# Calculate partial sums
if ($v>=2) {print("Summing up everything...\n");}
for ($pair=0; $pair<$PAIRMAX; $pair++) {
    for ($r=$RMIN; $r<=$RMAX; $r++) {
	for ($sep=0; $sep<$SEPMAX; $sep++) {
	    for ($a=1; $a<=20; $a++) {
		for ($b=1; $b<=20; $b++) {
		    $Cspr[$sep][$pair][$r]   +=$Csprab[$sep][$pair][$r][$a][$b];
		}
	    }
	    $C+=$Cspr[$sep][$pair][$r];
	}
    }
}

# Calculate probabilities
for ($a=1; $a<=20; $a++) {
    for ($b=1; $b<=20; $b++) {
	for ($sep=0; $sep<$SEPMAX; $sep++) {
	    for ($pair=0; $pair<$PAIRMAX; $pair++) {
		$Psprab[$sep][$pair][$RMIN][$a][$b] = $Csprab[$sep][$pair][$RMIN][$a][$b]/$C;
		for ($r=$RMIN+1; $r<=$RMAX; $r++) {
		    $Psprab[$sep][$pair][$r][$a][$b] = $Psprab[$sep][$pair][$r-1][$a][$b]+$Csprab[$sep][$pair][$r][$a][$b]/$C;
		}
	    }
	}
    }
}
for ($sep=0; $sep<$SEPMAX; $sep++) {
    for ($pair=0; $pair<$PAIRMAX; $pair++) {
	$Pspr[$sep][$pair][$RMIN] = $Cspr[$sep][$pair][$RMIN]/$C;
	for ($r=$RMIN+1; $r<=$RMAX; $r++) {
	    $Pspr[$sep][$pair][$r] = $Pspr[$sep][$pair][$r-1]+$Cspr[$sep][$pair][$r]/$C;
	}
    }
}



# Print out constant parameters
if(!open (OUTFILE,">$outfile")) {warn("Error: can't open $outfile: $!\n"); next;}
printf(OUTFILE "%i\t%i\t%i\n",$SEPTHR,$RMIN,$RMAX);

# Print out counts
if ($v>=2) {print("Writing score matrix into $outfile ...\n");}
for ($sep=0; $sep<$SEPMAX; $sep++) {
    printf(OUTFILE "sep=%i\n",$sep);
    for ($pair=0; $pair<$PAIRMAX; $pair++) {
	for ($r=$RMIN; $r<=$RMAX; $r++) {
	    printf(OUTFILE "%4.0f ",$Cspr[$sep][$pair][$r]/100);
	}
	printf(OUTFILE "\n");
    }
}
printf(OUTFILE "\n");

# Print out statistical scores
my $S; # Score matrix element
for ($sep=0; $sep<$SEPMAX; $sep++) {
    for ($pair=0; $pair<$PAIRMAX; $pair++) {
	for ($r=$RMIN; $r<=$RMAX; $r++) {
	    printf(OUTFILE ">sep=%1i  pair=%-2i r=%-2i\n",$sep,$pair,$r);
	    for ($a=1; $a<=20; $a++) {
		for ($b=1; $b<=20; $b++) {
		    $S = log($Psprab[$sep][$pair][$r][$a][$b]/$Pab[$a][$b]/$Pspr[$sep][$pair][$r]);
		    printf(OUTFILE "%+5i ",144.27*$S);
		}
		printf(OUTFILE "\n");
	    }
	}
    }
}

close(OUTFILE);

exit(0);



##################################################################################
# Call system command
##################################################################################
sub System()
{
    my $command=$_[0];
    if ($v>=2) {print("$command\n"); }
    return system($command)/256;
}

##################################################################################
# Convert three-letter amino acid code into one-letter code
##################################################################################
sub Three2OneLetter {
    my $res=uc($_[0]);
    if    ($res eq "GLY") {return "G";}
    elsif ($res eq "ALA") {return "A";}
    elsif ($res eq "VAL") {return "V";}
    elsif ($res eq "LEU") {return "L";}
    elsif ($res eq "ILE") {return "I";}
    elsif ($res eq "MET") {return "M";}
    elsif ($res eq "PHE") {return "F";}
    elsif ($res eq "TYR") {return "Y";}
    elsif ($res eq "TRP") {return "W";}
    elsif ($res eq "ASN") {return "N";}
    elsif ($res eq "ASP") {return "D";}
    elsif ($res eq "GLN") {return "Q";}
    elsif ($res eq "GLU") {return "E";}
    elsif ($res eq "CYS") {return "C";}
    elsif ($res eq "PRO") {return "P";}
    elsif ($res eq "SER") {return "S";}
    elsif ($res eq "THR") {return "T";}
    elsif ($res eq "LYS") {return "K";}
    elsif ($res eq "HIS") {return "H";}
    elsif ($res eq "ARG") {return "R";}
    elsif ($res eq "SEC") {return "U";}
    elsif ($res eq "ASX") {return "B";}
    elsif ($res eq "GLX") {return "Z";}
    elsif ($res eq "KCX") {return "K";}
    elsif ($res eq "MSE") {return "M";} # SELENOMETHIONINE 
    elsif ($res eq "SEP") {return "S";} # PHOSPHOSERINE 
    else                  {return "X";}
}

