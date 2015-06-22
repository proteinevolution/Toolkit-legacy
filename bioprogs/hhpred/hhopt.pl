#! /usr/bin/perl -w
# Usage: hhopt.pl aligment-dir db-file.hh
use lib "/home/soeding/perl";  
use lib "/cluster/soeding/perl";     # for cluster
use lib "/cluster/bioprogs/hhpred";  # forchimaera  webserver: MyPaths.pm
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm
use File::Temp "tempfile";
use ServerConfig; # config file with path variables for common webserver dirs
use MyPaths;      # config file with path variables for nr, blast, psipred, pdb, dssp etc.
use strict;

$hh="/cluster/user/soeding/hh";

my $ARGC=scalar(@ARGV);
if ($ARGC<3) 
{
    print("\nOptimize sensitivity of hhsearch by varying parameters.\n");
    print("Append results to outfile.\n");
    print("Usage:   hhopt.pl aligment-dir db-file.hhm outfile \n\n"); 
    exit;
}


my $alidir = $ARGV[0];
my $dbfile = $ARGV[1];
my $outfile = $ARGV[2];
my $ext="hhm";          # extension of alignment files 
my ($fh,$buffer);

system("touch $outfile");


my $ssm=2;
my $loc="local -ssm 2";
my $qid=0;
my $pca = 1.0;
my $pcb = 1.5;
my $pcc = 1;
my $gapb = 1.0;
my $gapd = 0.15;
my $gape = 1.0;

my $gapf = 0.6;
my $gapg = 0.6;
my $gaph = 0.6;
my $gapi = 0.6;

my $corr = 0.1;
my $ssw=0.11;
my $envr=0.9;

my $ssa=1;

my $shift = -0.01;
my $cshift = 0.1;

my $opt;
my $niter = 2;          # number of iterations with Newtons method

($fh, $buffer) = tempfile("buffer.XXXXX", DIR => ".");
close($fh);

my $envmat="/cluster/user/soeding/scopfam_1.69/env7.mat";

my $ymax=0;

if (!$ymax)
{
    $opt = "-alt 1 -$loc -shift $shift -ssw $ssw -pca $pca -pcb $pcb -pcc $pcc -gapb $gapb -gapd $gapd -gape $gape -gapf $gapf -gapg $gapg -gaph $gaph -gapi $gapi -cshift $cshift -corr $corr";
    print("$opt\n");
    $ymax = &opt("$opt"); 
}

open (OUTFILE, ">>$outfile") or die "Couldn't open $outfile:$!";
print(OUTFILE "\n");
close(OUTFILE);

$cshift = &vary("cshift",$cshift,1.5);
$corr = &vary("corr",$corr,1.5);
$cshift = &vary("cshift",$cshift,1.5);
$corr = &vary("corr",$corr,1.5);
$shift = &vary("shift",$shift,0.01,"add");
$ssw = &vary("ssw",$ssw,1.5);
$cshift = &vary("cshift",$cshift,1.2);
exit;

$gapf = &vary("gapf",$gapf,1.5);
$gapg = &vary("gapg",$gapg,1.5);
$gapd = &vary("gapd",$gapd,1.5);
$gape = &vary("gape",$gape,1.5);
$gapb = &vary("gapb",$gapb,1.5);
$gaph = &vary("gaph",$gaph,1.2);
$gapi = &vary("gapi",$gapi,1.2);
$pcb  = &vary("pcb",$pcb,1.2);
$shift = &vary("gapf",$gapf,0.04,"add");
#$pca  = &vary("pca",$pca,1.2);

unlink($buffer);
exit;

$envmat="/cluster/user/soeding/scopfam_1.69/env7.mat";
$ymax = &opt("$opt"); 
$pca  = &vary("pca",$pca,1.2);
$pcb  = &vary("pcb",$pcb,1.5);
$envr = &vary("envr",$envr,1.1);

$envmat="/cluster/user/soeding/scopfam_1.69/env6.mat";
$pca  = &vary("pca",$pca,1.2);
$pcb  = &vary("pcb",$pcb,1.5);
$envr = &vary("envr",$envr,1.1);

$envmat="/cluster/user/soeding/scopfam_1.69/env5.mat";
$ymax = &opt("$opt"); 
$pca  = &vary("pca",$pca,1.2);
$pcb  = &vary("pcb",$pcb,1.5);
$envr = &vary("envr",$envr,1.1);

$envmat="/cluster/user/soeding/scopfam_1.69/env8.mat";
$ymax = &opt("$opt"); 
$pca  = &vary("pca",$pca,1.2);
$pcb  = &vary("pcb",$pcb,1.5);
$envr = &vary("envr",$envr,1.1);

unlink($buffer);
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
    my $varopt;
    my $i;

    $opt = "-alt 1 -$loc -shift $shift -ssw $ssw -pca $pca -pcb $pcb -pcc $pcc -gapb $gapb -gapd $gapd -gape $gape -gapf $gapf -gapg $gapg -gaph $gaph -gapi $gapi -cshift $cshift -corr $corr";

    open (OUTFILE, ">>$outfile") or die "Couldn't open $outfile:$!";
    print(OUTFILE "hhopt.pl @ARGV:\nStarting from $opt with score $ymax\n");
    print(OUTFILE "Varying $par: starting with $par=$xmax,max=$ymax, stepping with $fac, mode = $mode\n");
    close(OUTFILE);

    # Move to the right until result smaller than ymax is found
    while (1)
    {
	if ($mode eq "mult") {
	    $x = sprintf("%.4f",$xmax*$fac);
	} else {
	    $x = sprintf("%.4f",$xmax+$fac);
	}
	$varopt = $par;
	$varopt =~s/(\S+)/-$1 $x/g;
	$options = "$opt $varopt";
	print("$options\n");
	$y = &opt("$options"); 
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
	while (1) 
	{
	    if ($mode eq "mult") {
		$x = sprintf("%.4f",$xmax/$fac);
	    } else {
		$x = sprintf("%.4f",$xmax-$fac);
	    }
	    $varopt = $par;
	    $varopt =~s/(\S+)/-$1 $x/g;
	    $options = "$opt $varopt";
	    print("$options\n");
	    $y = &opt("$options"); 
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
	
	if (($mode eq "mult" && $x/$xmax>1.01+1E-6) || 
	    ($mode eq "add"  && $x-$xmax>0.005))
	{
	    $varopt = $par;
	    $varopt =~s/(\S+)/-$1 $x/g;
	    $options = "$opt $varopt";
	    print("$options\n");
	    $y = &opt("$options"); 
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
	elsif (($mode eq "mult" && $xmax/$x>1.01+1E-6) || 
	       ($mode eq "add"  && $xmax-$x>0.005))
	{
	    $varopt = $par;
	    $varopt =~s/(\S+)/-$1 $x/g;
	    $options = "$opt $varopt";
	    print("$options\n");
	    $y = &opt("$options"); 
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

# Makes a call to hhsearch for each alignment file in $alidir,
# returns summed up return values, and prints result into $outfile.
sub opt
{
    my $options = $_[0];
    my $value;
    my $sum=0;
    my @files = glob("$alidir/*.*.*.$ext"); #read all such files into @files 
    my $file;

    
    print (scalar(@files)." files read in. Starting loop ...\n");
    
    foreach $file (@files)
    {   

	&System("$hh/hhsearch -cpu 1 -v1 -norealign -i $file -d $dbfile -opt $buffer $options -o /dev/null");
#	&System("$hh/hh_1.2.0/hhsearch64 -cpu 4 -v1 -i $file -d $dbfile -opt $buffer $options -o /dev/null");
	
	open(BUFFER,"<$buffer") or die "Couldn't open $buffer:$!";
	$value=<BUFFER>;
	chomp ($value);
	close(BUFFER);
	$sum+=$value;
	printf("  returned %6.2f => sum=%6.2f\n",$value ,$sum);
    }
    
    open (OUTFILE, ">>$outfile") or die "Couldn't open $outfile:$!";
    print(OUTFILE "$dbfile $options  result=$sum\n");
    close(OUTFILE);
    return $sum;
}

sub System()
{
    my $command=$_[0];
    print("$command\n"); 
    return system($command)/256; # && die("\nERROR: $!\n\n"); 
}



