#! /usr/bin/perl -w
# Usage: hhmaxsub.pl aligment-dir db-file.hh
use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/bioprogs/hhpred";  # forchimaera  webserver: MyPaths.pm
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm
use File::Temp "tempfile";
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with path variables for nr, blast, psipred, pdb, dssp etc.
use strict;
use Align;

# Default parameters for Align.pm
our $d=0.1;  # gap opening penatlty for Align.pm
our $e=0.1;  # gap extension penatlty for Align.pm
our $g=0.09; # endgap penatlty for Align.pm
our $v=2;    # verbose mode

my $ARGC=scalar(@ARGV);
if ($ARGC<2) 
{
    print("
Optimize alignment accuracy of hhsearch as measured by maxsub score.
For each hmm/a3m file in current directory find best hit (hhsearch with fixed search parameters) 
and align query to best hit with parameters to be optimized. Add GL-Score x min(2.0,opt-score) 
to total sum score and append results to outfile.
Usage: hhmaxsub.pl db-file.hhm outfile
\n"); 
    exit;
}

our $hh="/cluster/user/soeding/hh";
my $pdbdir="/raid/db/pdb";
my $maxsub="$bioprogs_dir/maxsub/maxsub";
my $astralfile="/cluster/scop/scop70_1.69";
my %hmmid;                # $hmmid{family-id} = pdb code of first sequence in astralfile with that family name
my $alidir = "";
my $dbfile = $ARGV[0];
my $outfile = $ARGV[1];
my $tmp;
my $ext="hhm";            # extension of alignment files 
my $opt;
my $niter = 4;            # number of iterations with Newtons method

my $fh;
($fh, $tmp) = tempfile("tmp_XXXXX", DIR => ".");
close($fh);

system("touch $outfile");
&ReadAstral();

# global -corr 0.1846 -shift -0.1058 -ssm 2 -ssw 0.0800 -ssa 1 -pca 1 -pcb 3.6557 -pcc 1 -pcd 1 -gapb 0.7159 -gapd 1.1651 -gape 1.0399 -gapf 0.4 -gapg 0.5 -gaph 1.569 -gapi 0.5347 -pcc 0.9493  result=797.82503937

# -local -corr 0.0701 -shift -0.0909 -ssm 2 -ssw 0.1119 -ssa 1 -pca 1 -pcb 5.2708 -pcc 0.7209 -pcd 1 -gapb 0.3217 -gapd 1.0909 -gape 1.0394 -gapf 0.2732 -gapg 0.5 -gaph 1.3636 -gapi 0.5 -shift -0.0909  result=793.3859025

my $loc="local";
my $pca = 1.0;
my $pcb = 3.5;
my $pcc = 1;
my $gapb = 1.0;
my $gapd = 0.08;
my $gape = 1.2;

my $gapf = 0.6;
my $gapg = 0.6;
my $gaph = 0.6;
my $gapi = 0.6;
my $ssm=2;
my $ssw=0.2;
my $shift = 0.0;
my $corr = 0.1;
my $qid = 0;

my $ssa=1;
my $mw=0.0;
my $qeg = 0.00;
my $teg = 0.00;
my $eg  = 0.0;
my $mapt = 0.1;

$opt = "-$loc -corr $corr -shift $shift -ssm $ssm -eg $teg -ssw $ssw -pca $pca -pcb $pcb -gapb $gapb -gapd $gapd -gape $gape -gapf $gapf -gapg $gapg -gaph $gaph -gapi $gapi -map -mapt $mapt";
my $ymax=0;
if (!$ymax) {
    print("$opt\n");
    $ymax = &opt("$opt",""); 
} else {
    printf("START    =>%-7.2f ~/hh/hhsearch -i X.a3m -d $dbfile $opt\n",$ymax);
}

open (OUTFILE, ">>$outfile") or die "Couldn't open $outfile:$!";
print(OUTFILE "\n");
close(OUTFILE);

$mapt = &vary("mapt",$mapt,1.5);
$shift = &vary("shift",$shift,0.05,"add");
$gapf = &vary("gapf",$gapf,1.2);
$gapg = &vary("gapg",$gapg,1.2);
$gaph = &vary("gaph",$gaph,1.2);
$gapi = &vary("gapi",$gapi,1.2);
$gapd = &vary("gapd",$gapd,1.2);
$gape = &vary("gape",$gape,1.2);
$gapb = &vary("gapb",$gapb,1.5);
$pcb = &vary("pcb",$pcb,1.2);
$ssw  = &vary("ssw",$ssw,1.5);

#$mapt = &vary("mapt",$mapt,1.5);
$shift = &vary("shift",$shift,0.02,"add");
$gapf = &vary("gapf",$gapf,1.1);
$gapg = &vary("gapg",$gapg,1.1);
$gaph = &vary("gaph",$gaph,1.1);
$gapi = &vary("gapi",$gapi,1.1);
$gapd = &vary("gapd",$gapd,1.1);
$gape = &vary("gape",$gape,1.1);
$gapb = &vary("gapb",$gapb,1.1);
$pcb = &vary("pcb",$pcb,1.2);
$ssw  = &vary("ssw",$ssw,1.5);



exit;

# Minimizes the result returned by &opt() by varying the parameter $par beginning form value $xmax.
# The parameter space is first probed to the right of xmax and then (if necessary) to the left of xmax,
# until three points (xl,xmax,xr) are found for which the middle point has maximum result.
# Then Newton's method is used to find the best point x between xl and xm.
# One of the four points (xl,xmax,xr,x) is discarded such that the middle point has again the maximum result.
# The method stops when the improvement is smaller than $sensitivity.
sub vary
{
    my $par  = $_[0]; 
    my $xmax = $_[1];  # value of parameter to be optimized, for which the maximum value ymax has been observed
    my $fac  = $_[2];
    my $mode = "mult";
    if (@_>3 && $_[3] eq "add") {
	$mode="add";
    }

    my $xl=0;   # next parameter value to the left of xmax
    my $yl=0;   # result for xl
    my $xr=0;   # next parameter value to the right of xmax
    my $yr=0;   # result for xr
    my $x;      # next paramter value to be evaluated
    my $y;      # result for $x

    my $options;
    my $i;
    
    $opt = "-$loc -corr $corr -shift $shift -ssm $ssm -eg $teg -ssw $ssw -pca $pca -pcb $pcb -gapb $gapb -gapd $gapd -gape $gape -gapf $gapf -gapg $gapg -gaph $gaph -gapi $gapi -map -mapt $mapt";

    open (OUTFILE, ">>$outfile") or die "Couldn't open $outfile:$!";
    print(OUTFILE "\n");
#    print(OUTFILE "hhopt.pl @ARGV:\nStarting from $opt with score $ymax\n");
#    print(OUTFILE "Varying $par: starting with $par=$xmax,max=$ymax, stepping with $fac, mode = $mode\n");
    close(OUTFILE);

    # Move to the right until result smaller than ymax is found
    while (1)
    {
	if ($mode eq "mult") {
	    $x = sprintf("%.4f",$xmax*$fac);
	} else {
	    $x = sprintf("%.4f",$xmax+$fac);
	}
	$y = &opt("$opt","-$par $x"); 
	if ($y<=$ymax) {last;}
	$xl = $xmax; 
	$yl = $ymax;
	$xmax = $x;
	$ymax = $y;
    }
    $xr = $x;  
    $yr = $y;

    if (!$xl)
    {
	# This loop will only be executed if $xl has not yet been assigned in the previous loop
	while (1) # This loop will only be executed if $xl has not yet been assigned in the previous loop
	{
	    if ($mode eq "mult") {
		$x = sprintf("%.4f",$xmax/$fac);
	    } else {
		$x = sprintf("%.4f",$xmax-$fac);
	    }
	    $y = &opt("$opt","-$par $x"); 
	    if ($y<=$ymax) {last;}
	    $xr = $xmax; 
	    $yr = $ymax;
	    $xmax = $x;
	    $ymax = $y;
	}
	$xl = $x;  
	$yl = $y;
    }
    
    for ($i=0; $i<$niter; $i++)
    {
	# Fit y=a*x^2+b*x+c through the three points and set x = -a/2b
	my $xl2 = $xl*$xl;
	my $xr2 = $xr*$xr;
	my $xm2 = $xmax*$xmax;
	$x  = ($yl*($xm2-$xr2)+$ymax*($xr2-$xl2)+$yr*($xl2-$xm2));
	$x /= 1E-10 + abs( $yl*($xmax-$xr)+$ymax*($xr-$xl)  +$yr*($xl-$xmax))*2;
	$x = sprintf("%.4f",$x);
	
	if (abs($x)>abs($xmax)*1.02+1E-6)
	{
	    $y = &opt("$opt","-$par $x"); 
	    if ($y>$ymax)
	    {
		$xl = $xmax;
		$yl = $ymax;
		$xmax = $x;
		$ymax = $y;
	    }
	    else
	    {
		$xr = $x;
		$yr = $y;
	    }
	} # end if($x>$xmax)
	elsif (abs($xmax)>abs($x)*1.02+1E-6)
	{
	    $y = &opt("$opt","-$par $x"); 
	    if ($y>$ymax)
	    {
		$xr = $xmax;
		$yr = $ymax;
		$xmax = $x;
		$ymax = $y;
	    }
	    else
	    {
		$xl = $x;
		$yl = $y;
	    }
	} # end elsif ($x<$xmax)
	else {last;};
    } # end while

    return $xmax;
}


# returns summed up return values, and prints result into $outfile.
sub opt
{
    my $options = $_[0];
    my $vary = $_[1];
    my $GLscore=0;# sum of GL scores
    my $MSscore=0;# sum of maxsub scores
    my $det=0;    # number of alignments with maxsub score >0
    my $tot=0;    # total number of alignments
    my @alis = glob("$alidir*.$ext"); #read all such files into @files 
    my $ali1;
    my $fam1;    
    my $fam2;    
    my $pdbfile;  # filename of query structure
    my $chain;    # chain of query 
    my $hmm1;     # pdb code for ali1 (query alignment)
    my $hmm2;     # pdb code for homolog of ali1 in same superfamily
    my $offset1;  # offset in index between astral sequence and pdb file of query alignment
    my $offset2;  # offset in index between astral sequence and pdb file of query alignment
    my $line;
    my ($GL,$MS);
    my $Sopt=0;   # opt score written by hhsearch -opt and read from buffer
    my $base;     # basename of $ali1

    print (scalar(@alis)." files read in... \n");
    print ("Vary '$vary': $options $vary\n");
    
    foreach $ali1 (@alis)
    {   
	if ($ali1 =~/(.*)\..*/)    {$base=$1;} else {$base=$ali1;}

	$tot++;
#	if (! -e "$base.hhr") {
#	    # hhsearch with default search parameters
#	    &System("/home/soeding/hh/hhsearch -v 1 -i $ali1 -d $dbfile -o $base.hhr -opt $base.buf");
#	    if ($v>=2) {print (".");}
#	}	 
   
#	# Read opt-score
#	open(BUFFER,"<$base.buf") or die ("Couldn't open $base.buf:$!\n");
#	$Sopt=<BUFFER>;
#	chomp ($Sopt);
#	$Sopt+=0.0;
#	close(BUFFER);

#	if ($Sopt<=0) {
#	    printf("%-12.12s: %5.2f\n",$ali1,$Sopt);
#	    next;
#	}

#	# Pick filename of best hit from search output
#	open (RESFILE,"<$base.hhr") or die ("Couldn't open $tmp.out: $!\n");
#	while ($line=<RESFILE>) {if ($line=~/^\s*No\s+Template/) {last;} }
#	$line=<RESFILE>;
#	$line=~/\s*\d+\s+\S+\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+/;
#	my $hitfile="db/$1.1.$ext";  # found filename of best hit
#	close (RESFILE);

#	if (!-e $hitfile) {die("Error: could not open $hitfile: $!\n");}

	$ali1=~/(\S\.\d+\.\d+)\.(\d+)\.\d+/;
        my $hitfile="db/$1".".1.1."."$ext";
	if ($2 eq "1") {$hitfile="db/$1".".2.1."."$ext";}

	# Align best hit with query using parameters to be optimized
	&System("$hh/hhalignmap -v 1 -i $ali1 -t $hitfile -o $tmp.out $options $vary");
	if ($v>=2) {print (".");}

	# Read SCOP code
	open (IN,"<$tmp.out") || die("Error: can't open $tmp.out: $!\n");
	$line=<IN>;
	close(IN);
	$line=~/Query\s+(\S+)/;
	$pdbfile="$newdbs/scop70_1.69/$1.pdb";
	
	# Make structure model from output alignment
	&System("$hh/hhmakemodel.pl -i $tmp.out -ts $tmp.mod -m 1  -d $newdbs/scop70_1.69> /dev/null");
	if ($v>=2) {print (".");}


	# Read maxsub score
	if ($v>=2) {print("$maxsub $tmp.mod $pdbfile 3.5 |\n");}
	if ( open(MAXSUB,"$maxsub $tmp.mod $pdbfile 3.5 |") ) {
	    #REMARK HAS 35 AT RMS 1.920. WITH A COMPUTED GL SCORE OF  28.097 , MAXSUB: 0.208
	    while($line=<MAXSUB>) {if ($line=~/HAS\s+(\d+).*?GL SCORE OF\s+(\S+).*?MAXSUB:\s+(\S+)/) {last;} } 
#	    print($line);
	    if(defined $line) {
		$line=~/HAS\s+(\d+).*?GL SCORE OF\s+(\S+).*?MAXSUB:\s+(\S+)/;
		$GL=$2*0.1;
		$MS=$3*10;
	    } else {
		$GL=0;
		$MS=0;
	    }
	    close(MAXSUB);
	} else {
	    $GL=0;
	    $MS=0;
	    print("$maxsub $tmp.mod $pdbfile 3.5 |\n");
	    warn("Error: can't call MAXSUB: $!\n"); 
	}
	if ($v>=2) {print (".");}

	$GLscore+=$GL;#*&min(2.0,$Sopt);;
	$MSscore+=$MS;#*&min(2.0,$Sopt);;
	if ($MS>1.5) {$det++;}
	printf("%-16.16s: %5.2f => MS=%-7.2f  GL=%-7.2f   MSsum=%-7.2f (av=%-5.2f)   GLsum=%-7.2f (av=%-5.2f)\n",$ali1,$Sopt,$MS,$GL,$MSscore,$MSscore/$tot,$GLscore,$GLscore/$tot);
    }
    
    open (OUTFILE, ">>$outfile") or die "Couldn't open $outfile:$!";
    printf(OUTFILE "%-7.2f <= %-13.13s $options\n",$MSscore,$vary);
    printf("%-7.2f <= %-13.13s $options\n",$MSscore,$vary);
    close(OUTFILE);
    return $MSscore;
}

##################################################################################
# 
##################################################################################
sub ReadAstral()
{
    my $line;
    printf(STDERR "Reading pdb codes for families from $astralfile\n");
    open (ASTRAL, "<$astralfile") or die "Couldn't open $astralfile:$!";
    while ($line=<ASTRAL>) #assign next line of file to $inline while there is a next line
    {
	if ($line=~/^>([a-z]\S+)\s+([a-k]\.\d+\.\d+\.\d+)\s+/)
	{
	    if (!(exists $hmmid{$2})) {$hmmid{$2}=$1;}
	}
    }
    close(ASTRAL);
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

# Minimum
sub min {
    my $min = shift @_;
    foreach (@_) {
	if ($_<$min) {$min=$_} 
    }
    return $min;
}

##################################################################################
# Call system command
##################################################################################
sub System()
{
    if ($v>=2) {print("\$ $_[0]\n"); }
    return system($_[0])/256; 
}

