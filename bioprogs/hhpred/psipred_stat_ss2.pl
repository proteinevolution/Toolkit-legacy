#! /usr/bin/perl -w
#
# For all sequences found in astralfile, compare psipred-predicted secondary structure
# with dssp-determined secondary structure and calculate statistical scores S(A;B,cH,cE)
# Usage: psipred_stat.pl astralfile psipred-dir dssp-dir


use strict;

if (scalar(@ARGV)<1) 
{
    print("\nFor all sequences found in astralfile, compare psipred-predicted secondary structure\n"); 
    print("with dssp-determined secondary structure and calculate statistical scores.\n"); 
    print("Usage: psipred_stat.pl astralfile psipred-dir [dssp-dir]\n\n"); 
    exit;
}

my $astralfile = $ARGV[0];
my $psipreddir = $ARGV[1]; # 
my $dsspdir = "/raid/db/dssp/data";

if (scalar(@ARGV)==3) {$dsspdir = $ARGV[2];}

my $i;           #counts residues
my $line;        #input line
my $name;        #name of sequence in astral file, e.g. d1g8ma1
my %longname;    #full name of sequence incl. description
my %range;       #chain and residue range of astral sequence in pdb file

my $psipredfile;
my $dsspfile;
my $nfile=0;     #number of files read in
my $pdbcode;     #pdb code for accessing dssp file; shortened from astral code, e.g. 1g8m 
my @ss_dssp;     #dssp states for residues (H,E,L)
my @aa_dssp;     #residues read from dssp file
my @cH;          #psipred output for H
my @cE;          #psipred output for E
my @conf;        #confidence value (0-9) of psipred prediction
my @aa_pred;     #residues in psipred file
my $ss_dssp;     #dssp states as string
my $aa_dssp;     #residues from dssp file as string
my $ss_pred;     #psipred predictions as string
my $cH;          # @cH as string
my $cE;          # @cE as string
my $aa_pred;     #residues as string
my $length;      #length of sequence

my $aa;          #current amino acid in dssp file
my $ss;          #current secondary structure state in dssp file
my $chain;       #two-letter code for chain in dssp file
my $range;       #range description for $name in dssp file
my $thisres;     #index of present residue in dssp file
my $lastres;     #index of last residue in dssp file
my $contained;   #is the current line in dssp file contained in the chain and residue ranges of $name?
my $gap;         #did last line in dssp file indicate missng residues? ->1 else 0
my $error;       #1: wrong assignment of residues dssp<->psipred
my $errinarow;   #how many errors have been made in a row?
my $assigned;    #number of correctly assigned residues
my $skipchain;   #found too many errors in this chain; try next chain with same 2nd letter (eg. PA SA A)
my $thischain;

my $A;           #abserved state H,G,I,E,B,S,T, or ~
my $B;           #bredicted state H,E, or ~
my $Ap;          #previous observed state H,G,I,E,B,S,T, or ~
my $Bp;          #previous predicted state H,E, or ~
my $c;           #confidence value from PsiPred
my $n;           #number of same residues predicted in a row
my $N;           #ceiling for n: 20 for H and ~, 10 for E
my %NAcc;        #NAcc{$A}[$cH][$cE] = freq of obs state A AND psipred outputs $cH and $cE (rounded down to int) 


# Initialization and pseudocounts
for ($cH=0; $cH<=9; $cH++)       # sum over confidence values
{
    for ($cE=0; $cE<=9-$cH; $cE++)       # sum over confidence values
    {
	foreach $A (split(//,"HE~STGB")) # sum over observed states
	{
	    $NAcc{$A}[$cH][$cE]=1;  #Add pseudocounts
	}
    }
}

# Read astral file and prepare hashes %first, %last, %chain, $longname
open (ASTRALFILE, "<$astralfile") || die ("cannot open $astralfile: $!");
while ($line=<ASTRALFILE>) 
{
    if ($line=~/>(\S+)\s+\S+\s+\((\S+)\)/)
    {
	$name=$1;
	chomp($line);
	$range{$name}=$2;
	$longname{$name}=$line;
    }
}
close(ASTRALFILE);


# Read dssp files and psipred files one after another and do statistics
foreach $name (keys(%range))
{
    # Read psipred file into @cH and @cE

    $psipredfile="$psipreddir/$name.ss2";  # READ .ss2 FILE (NOT .horiz FILE)
    $nfile++;


    if (! open (PSIPREDFILE, "<$psipredfile"))
    {printf(STDERR "ERROR: cannot open $psipredfile: $!\n"); next;}
    $i=0;
    $ss_pred="";
    while ($line=<PSIPREDFILE>) 
    {
	if ($line=~/^\s*\d+ (\w) (\w)\s+(\S+)\s+(\S+)\s+(\S+)/) {
	    $aa_pred[$i]=$1;
	    $ss_pred.=$2;
	    $cH[$i]=sprintf("%1i",10*$4/($3+$4+$5));
	    $cE[$i]=sprintf("%1i",10*$5/($3+$4+$5));
	    $i++;
	}    
    }
    close(PSIPREDFILE);
    $length=$i;
    $cH=join("",@cH[0..$i-1]);
    $cE=join("",@cE[0..$i-1]);
    $aa_pred=join("",@aa_pred[0..$i-1]);


    # Read dssp file into @ss_dssp

    @ss_dssp={}; @aa_dssp={};
    for ($i=0; $i<$length; $i++) {$ss_dssp[$i]=" "; $aa_dssp[$i]=" ";}
    $name=~/[a-z](\S{4})/;
    $pdbcode=$1;
    $dsspfile="$dsspdir/$pdbcode.dssp";
    if (! open (DSSPFILE, "<$dsspfile"))
    {printf(STDERR "ERROR: cannot open $dsspfile: $!\n"); next;}
    while ($line=<DSSPFILE>) {if ($line=~/^\s*\#\s*RESIDUE\s+AA/) {last;}}

    $gap=0; $i=-1; $error=0; $assigned=0; $skipchain=""; $errinarow=0;
    while ($line=<DSSPFILE>) 
    {
	if ($line=~/^.{5}(.{5})(.)(.)\s(.).\s(.)/)
	{
	    $thisres=$1;
	    $thisres=~tr/ //d;
	    if ($2.$3 eq $skipchain) {next;} 
	    $skipchain="";
	    $thischain=$2.$3;
	    $chain=$3;
	    $chain=~tr/ //d;
	    $aa=$4;
	    $ss=$5;
	    if ($aa eq "!")  {$gap=1; next;}    # missing residues!
	    $range=$range{$name};  $contained=0;

	    # Check whether at least one range descriptor fits, e.g. (B:1-127,B:254-362)
	    do{
		if    ($range=~s/^(\S):(-?\d+)\w?-(\d+)(\w?)//      #syntax (A:56S-135S) or (R:56-135)
		    && $chain eq "$1" && $2<=$thisres && $thisres<=$3) {$contained=1;}
		elsif ($range=~s/^(-?\d+)\w?-(\d+)(\w?)//           #syntax (56-135)
		    && $chain eq "" && $1<=$thisres && $thisres<=$2) {$contained=1;}
		elsif ($range=~s/^(\S):// && $chain eq "$1") {$contained=1;} #syntax (A:) or (A:,2:)
		elsif ($range=~s/^-$// && $chain eq "") {$contained=1;}      #syntax (-)
		$range=~s/^,//;
	    } while($contained==0 && $range ne "");

	    # line not contained in specified range for $name?
	    if (!$contained) {$lastres=$thisres; $gap=0; next;}    

	    if (!exists $aa_pred[$i+1]) {last;}
	    if($gap && $i!=-1)
	    {
		while ($aa_pred[$i+1] eq "X") {$i++;}
		if ((exists($aa_pred[$i+$thisres-$lastres])) 
		    && $aa_pred[$i+$thisres-$lastres] eq $aa && $aa_pred[$i+1] ne $aa)
		{
		    $i+=$thisres-$lastres;
		    if (!exists $aa_pred[$i]) {$error=1000; $i=0;}
		}
		else 
		{
		    $i++;
		    if (!exists $aa_pred[$i]) {$error=1000; $i=0;}
		}
	    }
	    else {$i++;}	
	    
	    $aa=~tr/a-z/CCCCCCCCCCCCCCCCCCCCCCCCCC/;

	    # Count wrong assignments
	    if ($error<1000 && $aa ne $aa_pred[$i] && $aa ne "X")
	    {
		if ($errinarow>=1) 
		{
		    $error++; $errinarow++;
		    my $j=$i;
		    while (exists $aa_pred[$i] && $aa_pred[$i] ne $aa) {$i++;}
		    if (!exists $aa_pred[$i]) {$i=$j;}
		}
		else {$errinarow++; $error++;}

	    }
	    else {$errinarow=0;}


	    if ($error>6) 
	    {
#		print("Errors:$error   i:$i   aa_pred:$aa_pred[$i]   aa:$aa\n");
#		print("$longname{$name}\n");
#		$aa_dssp= join("",@aa_dssp);
#		$ss_dssp= join("",@ss_dssp);
#		print("DSSP    '$aa_dssp'\n");
#		print("Psipred '$aa_pred'\n");
		for ($i=0; $i<$length; $i++) {$ss_dssp[$i]=" "; $aa_dssp[$i]=" ";}
		$skipchain=$thischain;
		$error=0; $assigned=0; $i=-1; $gap=0; $errinarow=0;
		next;
	    }
	    $assigned++;
	    if ($ss eq " ") {$ss="~";}
	    elsif ($ss eq "I") {$ss="~";}
#	    elsif ($ss eq "S") {$ss="~";}
#	    elsif ($ss eq "T") {$ss="~";}
#	    elsif ($ss eq "G") {$ss="~";}
#	    elsif ($ss eq "B") {$ss="~";}
	    $ss_dssp[$i]=$ss;
	    $aa_dssp[$i]=$aa;
	    $lastres=$thisres; 
	    $gap=0;
	}
    }
    close(DSSPFILE);
    if ($skipchain || $error>6) 
    {printf (STDERR "WARNING in $name ($nfile): too many wrong assingments of residues\n"); next;}
    elsif ($assigned<0.5*$length) 
    {printf (STDERR "WARNING in $name ($nfile): too few correct assignments of residues\n"); next;}

#    printf(STDERR "%4i: %-100.100s  ",$nfile,$longname{$name});
#    printf(STDERR "%1i errors, %3i%% assigned\n",$error,int(100*$assigned/$length));

    $ss_dssp= join("",@ss_dssp);
    $aa_dssp= join("",@aa_dssp);
    $ss_dssp=~s/ \S /   /g;
    $ss_dssp=~s/ \S\S /    /g;

#    print("$longname{$name}\n");
#    print("DSSP    '$aa_dssp'\n");
#    print("Psipred '$aa_pred'\n");
#    print("DSSP    '$ss_dssp'\n");
#    print("Psipred '$ss_pred'\n");
#    print("c(H)    '$cH'\n");
#    print("c(E)    '$cE'\n\n");

# Record statistics

   # Record statistics
   for ($i=0; $i<$length; $i++)
   {
	if ($ss_dssp[$i] eq " "){next;}
	$NAcc{$ss_dssp[$i]}[$cH[$i]][$cE[$i]]++;
   }

} 


 &Statistics();

exit;

############################################################################################
############################################################################################
sub Statistics()
{
    my @Ncc;  #NAcc[$cH][$cE] = freq of obs state A AND psipred outputs $cH and $cE (rounded down to int) 
    my %NA;   #freq of observing state $A
    my %Pcc;  #Pcc{$A}[$cH][$cE] = frequency of observed aa A GIVEN predicted cH and cE
    my $Ntot; #Total number of counts (assigned residues)
    
    # Calculate Ncc[$cH][$cE]
    $Ntot=0;
    for ($cH=0; $cH<=9; $cH++)       # sum over confidence values
    {
	for ($cE=0; $cE<=9-$cH; $cE++)       # sum over confidence values
	{
	    $Ncc[$cH][$cE]=0;
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		$Ncc[$cH][$cE]+=$NAcc{$A}[$cH][$cE];
	    }
	    $Ntot+=$Ncc[$cH][$cE];
	}
    }

    
    # Calculate NA{$A}
    foreach $A (split(//,"HE~STGB"))
    {
	$NA{$A}=0;
	for ($cH=0; $cH<=9; $cH++)       # sum over confidence values
	{
	    for ($cE=0; $cE<=9-$cH; $cE++)       # sum over confidence values
	    {
		$NA{$A}+=$NAcc{$A}[$cH][$cE];
	    }
	}
    }
    
    # Print out NAcc
    print("\nN(A;cc)\n");
    print("cH cE      H      E      ~      S      T      G      B    sum\n");
    for ($cH=0; $cH<=9; $cH++)       # sum over confidence values
    {
	for ($cE=0; $cE<=9-$cH; $cE++)       # sum over confidence values
	{
	    printf("%2i %2i  ",$cH,$cE);
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		printf("%5i  ",$NAcc{$A}[$cH][$cE]);
	    }
	    printf("%5i",$Ncc[$cH][$cE]);
	    print("\n");
	}
    }
    # Print out PAcc
    print("\nP(A;cc) in %\n");
    print("cH cE      H      E      ~      S      T      G      B\n");
    for ($cH=0; $cH<=9; $cH++)       # sum over confidence values
    {
	for ($cE=0; $cE<=9-$cH; $cE++)       # sum over confidence values
	{
	    printf("%2i %2i  ",$cH,$cE);
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		printf("%5.2f  ",100*$NAcc{$A}[$cH][$cE]/$Ntot);
	    }
	    print("\n");
	}
    }
    
    # Print out SAcc
    print("\nS(A;cc) in %\n");
    print("cH cE      H      E      ~      S      T      G      B\n");
    for ($cH=0; $cH<=9; $cH++)       # sum over confidence values
    {
	for ($cE=0; $cE<=9-$cH; $cE++)       # sum over confidence values
	{
	    printf("%2i %2i  ",$cH,$cE);
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		printf("%5.2f  ",log($NAcc{$A}[$cH][$cE]/$Ncc[$cH][$cE]/$NA{$A}*$Ntot)/log(2));
	    }
	    print("\n");
	}
    }
    
#    # Print out PcAB
#    print("\nPcAB/Pc/PA/PB\n");
#    print("//pred/obs  -      H      E      ~      S      T      G      B\n");
#    for ($c=0; $c<=9; $c++)       # sum over confidence values
#    {
#    print("        0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, // - conf=$c\n");
#	foreach $B (split(//,"HE~"))
#	{
#	    print("        0.000, ");
#	    foreach $A (split(//,"HE~STGB")) # sum over observed states
#	    {
#		printf("%5.3f, ",$NcAB[$c]{$A}{$B}/$NcB[$c]{$B}/$NA{$A}*$Ntot);
#	    }
#	    print("// $B\n");
#	}
#    }


    # Calculate mutual information for A and (B,cf):
    my $Minf=0;
    for ($cH=0; $cH<=9; $cH++)       # sum over confidence values
    {
	for ($cE=0; $cE<=9-$cH; $cE++)       # sum over confidence values
	{
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		$Minf += $NAcc{$A}[$cH][$cE]/$Ntot * log($NAcc{$A}[$cH][$cE]/$Ncc[$cH][$cE]/$NA{$A}*$Ntot)/log(2);
	    }
	}
    }
    
    printf("Mutual information of A and (cH,cE): %5.3f bits\n",$Minf);

} 
#End SimpleStat()
    

