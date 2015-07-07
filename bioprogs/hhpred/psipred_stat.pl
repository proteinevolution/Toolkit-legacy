#! /usr/bin/perl -w
#
# For all sequences found in astralfile, compare psipred-predicted secondary structure
# with dssp-determined secondary structure and calculate statistical scores S(A;B,c)
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
my @ss_pred;     #psipred predictions for residues (H,E,L)
my @conf;        #confidence value (0-9) of psipred prediction
my @aa_pred;     #residues in psipred file
my $ss_dssp;     #dssp states as string
my $aa_dssp;     #residues from dssp file as string
my $ss_pred;     #psipred predictions as string
my $conf;        #confidence values as string
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
my @NcAB;        #NcAB[$c]{$A}{$B} = frequency of predicted aa B AND observed aa A AND confidence value $c 
my @NcABn;       #NcAB[$c]{$A}{$B} = frequency of n'th predicted aa B AND observed aa A AND conf value $c 
my @NcABAB;      #NcABAB[$c]{$A}{$B}{$Ap}{$Bp} = freq of pred B, obs A, previous pred Ap, previous obs Bp, AND conf value $c 

# Initialization and pseudocounts
for ($c=0; $c<=9; $c++)       # sum over confidence values
{
    foreach $A (split(//,"HE~")) # sum over observed states
    {
	foreach $B (split(//,"HE~"))
	{
	    foreach $Ap (split(//,"HE~")) # sum over observed states
	    {
		foreach $Bp (split(//,"HE~"))
		{
		    $NcABAB[$c]{$A}{$B}{$Ap}{$Bp}=1; #Add pseudocounts
		}
	    }
	}
    }
}

# Initialization and pseudocounts
for ($c=0; $c<=9; $c++)       # sum over confidence values
{
    foreach $A (split(//,"HE~STGB")) # sum over observed states
    {
	foreach $B (split(//,"HE~"))
	{
	    if ($B eq "E") {$N=10;} else {$N=20;}
	    for ($n=1; $n<=$N; $n++)
	    {
		$NcABn[$c]{$A}{$B}[$n]=2; #Add pseudocounts
	    }
	}
    }
}

# Initialization and pseudocounts
for ($c=0; $c<=9; $c++)       # sum over confidence values
{
    foreach $B (split(//,"HE~"))
    {
	foreach $A (split(//,"HE~STGB")) # sum over observed states
	{
	    $NcAB[$c]{$A}{$B}=2;  #Add pseudocounts
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
    # Read psipred file into @ss_pred and @conf

    $psipredfile="$psipreddir/$name.horiz";
    $nfile++;


    $ss_pred=""; $conf=""; $aa_pred="";
    if (! open (PSIPREDFILE, "<$psipredfile"))
    {printf(STDERR "ERROR: cannot open $psipredfile: $!\n"); next;}
    while ($line=<PSIPREDFILE>) 
    {
	if ($line=~/^Conf:\s+(\S+)/)    {$conf.=$1;}    
	elsif ($line=~/^Pred:\s+(\S+)/) {$ss_pred  .=$1;}    
	elsif ($line=~/^  AA:\s+(\S+)/) {$aa_pred .=$1;}    
    }
    close(PSIPREDFILE);
     
    if (length($ss_pred)!=length($conf)) 
    {print(STDERR "ERROR: unequal lengths of psipred predicted and residues in $name\n"); next;}
    
    $ss_pred=~tr/C/~/;
    @ss_pred   = split(//,$ss_pred);
    @conf = split(//,$conf);
    @aa_pred  = split(//,$aa_pred);
    $length=length($ss_pred);


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
		$aa_dssp= join("",@aa_dssp);
		$ss_dssp= join("",@ss_dssp);
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
#    print("Conf    '$conf'\n\n");

# Record statistics






   # Record simple statistics
   for ($i=0; $i<$length; $i++)
   {
	if ($ss_dssp[$i] eq " "){next;}
	$NcAB[$conf[$i]]{$ss_dssp[$i]}{$ss_pred[$i]}++;
   }

#    # Record length statistics
#    my $trans=0; #number of transitions between predicted states since last non-assigned residue (" ")
#    for ($i=0; $i<$length; $i++)
#    {
#	if ($ss_dssp[$i] eq " "){$trans=0; next;}
#	if ($i>0 && $ss_pred[$i] ne $ss_pred[$i-1]) {$trans++; $n=1;} else {$n++;}
#	if ($trans<=1) {next;}
#	if ($ss_pred[$i] eq "E" && $n>10) {$n=10;} elsif ($n>20) {$n=20;}
#	$NcABn[$conf[$i]]{$ss_dssp[$i]}{$ss_pred[$i]}[$n]++;
#    }

#    # Record transition statistics
#    for ($i=1; $i<$length; $i++)
#    {
#	if ($ss_dssp[$i] eq " " || $ss_dssp[$i-1] eq " ") {next;}
#	$NcABAB[$conf[$i]]{$ss_dssp[$i]}{$ss_pred[$i]}{$ss_dssp[$i-1]}{$ss_pred[$i-1]}++;
#    }



} 


 &SimpleStat();
# &LengthStat();
#&TransStat();

exit;




############################################################################################
sub TransStat()
{
    my %NApBp;   #NApBp{$Ap{$Bp}= freq of observed $A AND predicted $B
    my %NAA;     #NAA{$A}{$Ap} = freq of observed $A AND prev observed $Ap
    my @NcBB;    #NcBB[$c]{$B}{$Bp} = freq of predicted $B AND prev pred $Bp AND confidence $c
    my %NA;      #NcA[$c]{$A} = freq of observing state $A AND confidence $c
    my %NB;      #NcA[$c]{$A} = freq of observing state $A AND confidence $c
    my $Ntot=0;
    my @NcBAp;   #NcBAp[$c]{$B}{$Ap} = freq of pred $B AND prev obs $Ap AND confidence $c
    my @NcABA;   #NABAp{$A}{$B}{$Ap} = freq of obs $A AND pred $B AND prev obs $Ap AND confidence $c

    # Calculate NApBp
    foreach $Ap (split(//,"HE~")) # sum over observed states
    {
	foreach $Bp (split(//,"HE~"))
	{
	    $NApBp{$Ap}{$Bp}=0;
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		foreach $A (split(//,"HE~")) # sum over observed states
		{
		    foreach $B (split(//,"HE~"))
		    {
			$NApBp{$Ap}{$Bp}+=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
			$Ntot           +=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
		    }
		}
	    }
	}
    }

    # Calculate NAA
    foreach $A (split(//,"HE~")) # sum over observed states
    {
	foreach $Ap (split(//,"HE~"))
	{
	    $NAA{$A}{$Ap}=0;;
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		foreach $B (split(//,"HE~")) # sum over observed states
		{
		    foreach $Bp (split(//,"HE~"))
		    {
			$NAA{$A}{$Ap}+=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
		    }
		}
	    }
	}
    }

    # Calculate NA
    foreach $A (split(//,"HE~")) # sum over observed states
    {
	$NA{$A}=0;;
	foreach $Ap (split(//,"HE~"))
	{
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		foreach $B (split(//,"HE~")) # sum over observed states
		{
		    foreach $Bp (split(//,"HE~"))
		    {
			$NA{$A}+=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
		    }
		}
	    }
	}
    }

    # Calculate NcBB
    foreach $B (split(//,"HE~")) # sum over observed states
    {
	foreach $Bp (split(//,"HE~"))
	{
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		$NcBB[$c]{$B}{$Bp}=0;
		foreach $A (split(//,"HE~")) # sum over observed states
		{
		    foreach $Ap (split(//,"HE~"))
		    {
			$NcBB[$c]{$B}{$Bp}+=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
		    }
		}
	    }
	}
    }

    # Calculate NB
    foreach $B (split(//,"HE~")) # sum over observed states
    {
	$NB{$B}=0;;
	foreach $Bp (split(//,"HE~"))
	{
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		foreach $A (split(//,"HE~")) # sum over observed states
		{
		    foreach $Ap (split(//,"HE~"))
		    {
			$NB{$B}+=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
		    }
		}
	    }
	}
    }

    # Print out P(c,A,B|Aprev,Bprev)/P(A|Aprev)/P(c,B|Bprev)
    print("\nP(c,A,B|Aprev,Bprev)/P(A|Aprev)/P(c,B|Bprev)\n");
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	print("\nConfidence=$c\n");
	print("obs\\pred    HH    HE    H~    EH    EE    E~    ~H    ~E    ~~\n");
	foreach $A (split(//,"HE~")) # sum over observed states
	{
	    foreach $Ap (split(//,"HE~"))
	    {
		printf("$A$Ap       ");
		foreach $B (split(//,"HE~")) # sum over observed states
		{
		    foreach $Bp (split(//,"HE~"))
		    {
			if ($NcABAB[$c]{$A}{$B}{$Ap}{$Bp}<10) {printf("%5.2f ",1.00);}
			else 
			{printf("%5.2f ",$NcABAB[$c]{$A}{$B}{$Ap}{$Bp}/$NApBp{$Ap}{$Bp}/$NAA{$A}{$Ap}*$NA{$Ap}/$NcBB[$c]{$B}{$Bp}*$NB{$Bp});}
		    }
		}
		print("\n");
	    }
	}
    }

    # Print out P(c,A,B|Aprev,Bprev)
    print("\nn(c,A,B,Aprev,Bprev)\n");
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	print("\nConfidence=$c\n");
	print("obs\\pred    HH    HE    H~    EH    EE    E~    ~H    ~E    ~~\n");
	foreach $A (split(//,"HE~")) # sum over observed states
	{
	    foreach $Ap (split(//,"HE~"))
	    {
		printf("$A$Ap       ");
		foreach $B (split(//,"HE~")) # sum over observed states
		{
		    foreach $Bp (split(//,"HE~"))
		    {
			printf("%5i ",$NcABAB[$c]{$A}{$B}{$Ap}{$Bp});
		    }
		}
		print("\n");
	    }
	}
    }


    # Calculate NcABAp
    foreach $A (split(//,"HE~")) # sum over observed states
    {
	foreach $B (split(//,"HE~"))
	{
	    foreach $Ap (split(//,"HE~")) # sum over observed states
	    {
		for ($c=0; $c<=9; $c++)       # sum over confidence values
		{
		    $NcABA[$c]{$A}{$B}{$Ap}=0;		
		    foreach $Bp (split(//,"HE~"))
		    {
			$NcABA[$c]{$A}{$B}{$Ap}+=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
		    }
		}
	    }
	}
    }

    # Calculate NcBAp
    foreach $B (split(//,"HE~")) # sum over observed states
    {
	foreach $Ap (split(//,"HE~"))
	{
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		$NcBAp[$c]{$B}{$Ap}=0;
		foreach $A (split(//,"HE~")) # sum over observed states
		{
		    foreach $Bp (split(//,"HE~"))
		    {
			$NcBAp[$c]{$B}{$Ap}+=$NcABAB[$c]{$A}{$B}{$Ap}{$Bp};
		    }
		}
	    }
	}
    }

    # Print out P(A|Aprev,B,c)/P(A|Aprev)
    print("\nnP(A|Aprev,B,c)/P(A|Aprev)\n");
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	print("\nConfidence=$c\n");
	print("obs\\pred    HH    HE    H~    EH    EE    E~    ~H    ~E    ~~\n");
	foreach $A (split(//,"HE~")) # sum over observed states
	{
	    foreach $Ap (split(//,"HE~"))
	    {
		printf("$A$Ap       ");
		foreach $B (split(//,"HE~")) # sum over observed states
		{
		    foreach $Bp (split(//,"HE~"))
		    {
			printf("%5.2f ",$NcABA[$c]{$A}{$B}{$Ap}/$NcBAp[$c]{$B}{$Ap}/$NAA{$A}{$Ap}*$NA{$Ap});
		    }
		}
		print("\n");
	    }
	}
    }

 

}

#End TransStat()


############################################################################################
sub LengthStat()
{
    my @NcA;    #NcA[$c]{$A} = freq of observing state $A AND confidence value c
    my @NcB;    #NcB[$c]{$B} = freq of observing state $B AND confidence value c
    my %NBn;    #NBn{$B}[$n] = freq of predicting state $B as n'th residue in a row
    my @NcBn;    #NBn{$B}[$n] = freq of predicting state $B as n'th residue in a row
    my %NA;    #NBn{$B}[$n] = freq of predicting state $B as n'th residue in a row
    my $Ntot=0; #Total number of counts (assigned residues)
    
    # Calculate NcA[$c]{$A}
    foreach $A (split(//,"HE~STGB")) # sum over observed states
    {
	for ($c=0; $c<=9; $c++)       # sum over confidence values
	{
	    $NcA[$c]{$A}=0;
	    foreach $B (split(//,"HE~"))
	    {
		if ($B eq "E") {$N=10;} else {$N=20;}
		for ($n=1; $n<=$N; $n++)
		{
		    $NcA[$c]{$A}+=$NcABn[$c]{$A}{$B}[$n];
		    $Ntot+=$NcABn[$c]{$A}{$B}[$n];
		}
	    }
	}
    }
    
    # Calculate $NBn{$B}[$n]
    foreach $B (split(//,"HE~"))
    {
	if ($B eq "E") {$N=10;} else {$N=20;}
	for ($n=1; $n<=$N; $n++)
	{
	    $NBn{$B}[$n]=0;
	    foreach $A (split(//,"HE~STGB"))
	    {
		for ($c=0; $c<=9; $c++)   
		{
		    $NBn{$B}[$n]+=$NcABn[$c]{$A}{$B}[$n];
		}
	    }
	}
    }


    # Calculate NA{$A}
    foreach $A (split(//,"HE~STGB")) # sum over observed states
    {
	$NA{$A}=0;
	for ($c=0; $c<=9; $c++)       # sum over confidence values
	{
	    foreach $B (split(//,"HE~"))
	    {
		if ($B eq "E") {$N=10;} else {$N=20;}
		for ($n=1; $n<=$N; $n++)
		{
		    $NA{$A}+=$NcABn[$c]{$A}{$B}[$n];
		}
	    }
	}
    }

    # Calculate NcBn{$A}
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	foreach $B (split(//,"HE~"))
	{
	    if ($B eq "E") {$N=10;} else {$N=20;}
	    for ($n=1; $n<=$N; $n++)
	    {
		$NcBn[$c]{$B}[$n]=0;
		foreach $A (split(//,"HE~STGB")) # sum over observed states
		{
		    $NcBn[$c]{$B}[$n]+=$NcABn[$c]{$A}{$B}[$n];
		}
	    }
	}
    }
    

    # Print out P(nB)
    print("\nP(n,B)\n");
    print("   ");
    for ($n=1; $n<=20; $n++) {printf("%5i ",$n);}
    print("\n");
    foreach $B (split(//,"HE~"))
    {
	print("$B  ");
	if ($B eq "E") {$N=10;} else {$N=20;}
	for ($n=1; $n<=$N; $n++)
	{
	    printf("%5.2f ",100*$NBn{$B}[$n]/$Ntot);
	}
	print("\n");
    }
    print("\n");

    # Print out NcABn
    print("\nN(n,B,c,A)\n");
    for ($c=0; $c<=9; $c++)
    {
	foreach $A (split(//,"HE~STGB")) 
	{
	    print("\nobs=$A  conf=$c\n");
	    print("   ");
	    for ($n=1; $n<=20; $n++) {printf("%5i ",$n);}
	    print("\n");
	    foreach $B (split(//,"HE~"))
	    {
		print("$B  ");
		if ($B eq "E") {$N=10;} else {$N=20;}
		for ($n=1; $n<=$N; $n++)
		{
		    printf("%5i ",$NcABn[$c]{$A}{$B}[$n]);
		}
		print("\n");
	    }
	}
    }
    
    # Print out P(nB|cA)
    print("\nP(n,B|c,A)\n");
    for ($c=0; $c<=9; $c++)
    {
	foreach $A (split(//,"HE~STGB")) 
	{
	    print("\nobs=$A  conf=$c\n");
	    print("   ");
	    for ($n=1; $n<=20; $n++) {printf("%5i ",$n);}
	    print("\n");
	    foreach $B (split(//,"HE~"))
	    {
		print("$B  ");
		if ($B eq "E") {$N=10;} else {$N=20;}
		for ($n=1; $n<=$N; $n++)
		{
		    printf("%5.2f ",$NcABn[$c]{$A}{$B}[$n]/$NA{$A}/$NcBn[$c]{$B}[$n]*$Ntot);
		}
		print("\n");
	    }
	}
    }
    


}
#End LengthStat()


############################################################################################
sub SimpleStat()
{
    my %NAB;  #NAB[$c]{$A}{$B} = frequency of predicted aa B AND observed aa A
    my @NcA;  #NcA[$c]{$A} = freq of observing state $A AND confidence value c
    my @NcB;  #NcB[$c]{$B} = freq of observing state $B AND confidence value c
    my %NA;   #P{$B} = freq of observing state $A
    my %NB;   #P{$B} = freq of predicting state $B
    my @Nc;   #P[$c] = freq of obtaining confidence value c
    my @P;    #P[$c]{$A}{$B} = frequency of predicted aa B GIVEN observed aa A and given conf value $c
    my $Ntot; #Total number of counts (assigned residues)
    
    # Calculate NcA[$c]{$A}
    foreach $A (split(//,"HE~STGB")) # sum over observed states
    {
	for ($c=0; $c<=9; $c++)       # sum over confidence values
	{
	    $NcA[$c]{$A}=0;
	    foreach $B (split(//,"HE~"))
	    {
		$NcA[$c]{$A}+=$NcAB[$c]{$A}{$B};
	    }
	}
    }
    
    # Calculate NcB[$c]{$B}
    foreach $B (split(//,"HE~"))
    {
	for ($c=0; $c<=9; $c++)       # sum over confidence values
	{
	    $NcB[$c]{$B}=0;
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		$NcB[$c]{$B}+=$NcAB[$c]{$A}{$B};
	    }
	}
    }
    
    # Calculate NA{$A}
    foreach $A (split(//,"HE~STGB"))
    {
	$NA{$A}=0;
	foreach $B (split(//,"HE~")) # sum over observed states
	{
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		$NA{$A}+=$NcAB[$c]{$A}{$B};
	    }
	}
    }
    
    # Calculate NB{$B}
    foreach $B (split(//,"HE~"))
    {
	$NB{$B}=0;
	foreach $A (split(//,"HE~STGB")) # sum over observed states
	{
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		$NB{$B}+=$NcAB[$c]{$A}{$B};
	    }
	}
    }
    
    # Calculate Nc[$c]
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	$Nc[$c]=0;
	foreach $B (split(//,"HE~"))
	{
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		$Nc[$c]+=$NcAB[$c]{$A}{$B};
	    }
	}
    }
    
    # Calculate NAB{$A}{$B}
    foreach $B (split(//,"HE~"))
    {
	foreach $A (split(//,"HE~STGB")) # sum over observed states
	{
	    $NAB{$A}{$B}=0;
	    for ($c=0; $c<=9; $c++)       # sum over confidence values
	    {
		$NAB{$A}{$B}+=$NcAB[$c]{$A}{$B};
	    }
	}
    }
    
    # Calculate total number of counts Ntot
    $Ntot=0;
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	$Ntot+=$Nc[$c];
    }
    
    # Print out Pc[$c]
    print("P(conf-value) = @Nc\n");
    
    
    # Print out NcAB
    print("\nNcAB\n");
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	print("\nConfidence value: $c\n");
	print("pred/obs   H      E      ~      S      T      G      B\n");
	foreach $B (split(//,"HE~"))
	{
	    print("$B     ");
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		printf("%6i ",$NcAB[$c]{$A}{$B});
	    }
	    print("\n");
	}
    }
    
    # Print out PcAB
    print("\nPcAB/PcB/PA\n");
    print("//pred/obs  -      H      E      ~      S      T      G      B\n");
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
    print("        0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000, // - conf=$c\n");
	foreach $B (split(//,"HE~"))
	{
	    print("        0.000, ");
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		printf("%5.3f, ",$NcAB[$c]{$A}{$B}/$NcB[$c]{$B}/$NA{$A}*$Ntot);
	    }
	    print("// $B\n");
	}
    }

    print("\nAverage probabilities over confidence values: \n");
    print("pred/obs   H      E      ~      S      T      G      B\n");
    foreach $B (split(//,"HE~"))
    {
	print("$B     ");
	foreach $A (split(//,"HEST~GB")) # sum over observed states
	{
	    printf("%6.3f ",$NAB{$A}{$B}/$Ntot);
	}
	print("\n");
    }


    # Calculate mutual information for A and (B,cf):
    my $Minf=0;
    for ($c=0; $c<=9; $c++)       # sum over confidence values
    {
	foreach $B (split(//,"HE~"))
	{
	    foreach $A (split(//,"HE~STGB")) # sum over observed states
	    {
		$Minf += $NcAB[$c]{$A}{$B}/$Ntot * log($NcAB[$c]{$A}{$B}/$NcB[$c]{$B}/$NA{$A}*$Ntot)/log(2);
	    }
	}
    }
    printf("Mutual information of A and (B,cf): %5.3f bits\n",$Minf);

} 
#End SimpleStat()
    

