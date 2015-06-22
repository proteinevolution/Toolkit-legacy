#! /usr/bin/perl -w
# Usage: hhallself.pl dbfile [options]
# hhalign all globbed files in current directory with themself 

use strict;

# Default values:
my $hh="/cluster/user/soeding/hh";               #perl directory: querydb.pl, alignhits.pl
my $calfile="/cluster/databases/hhpred/cal.hhm";
my $PVALMAX=1e-2;

print (STDERR "Running $0 @ARGV:\n");
if (scalar(@ARGV)<1) 
{
    print("\nRepeat detection within a set of *.hhr files\n"); 
    print("If the -make, -cal, or -align options are given, hhmake, hhsearch -cal,\n"); 
    print("or hhalign are executed on the globbed files before analysis of the hhr files.\n"); 
    print("For all templates whose best self-hit has P-value<$PVALMAX the summary hit list \n"); 
    print("is printed to STDOUT.\n"); 
    print("Usage:    hhallself.pl 'globex' [-make] [-cal] [-align] [options]\n"); 
    print("Examples: hhallself.pl '*.hhr'\n"); 
    print("          hhallself.pl '*.a3m' -make  -cal -align -ssm 0\n"); 
     exit (1);
}

my $glob = $ARGV[0];
my @files = glob("$glob"); #read all such files into @files 
my $file;
my $basename;
my $options;
my $line;
my $n=0;

if (@ARGV>2) {
    $options.=join(" ",@ARGV[1..$#ARGV]);
}
my $make=0;
my $cal=0;
my $align=0;
if ($options=~s/\s*-make//)  {$make=1;}
if ($options=~s/\s*-cal//)   {$cal=1;}
if ($options=~s/\s*-align//) {$align=1;}

my @templates;
my @folds=();
my @sfams=();
my @fams=();
#my $name;
my $fold;
my $sfam;
my $fam;
my $repeats;

print (STDERR scalar(@files)." files read in. Starting selection loop ...\n");

foreach $file (@files)
{   
    printf(STDERR ">>> %i: $file <<<\n",++$n);
    if ($file =~/^(.*)\..*?$/) {$basename=$1;} else {$basename=$file;}

    if ($make) {
	&System("$hh/hhmake -i $basename.a3m -o $basename.hhm $options");
    }
    if ($cal) {
	&System("$hh/hhsearch -i $basename.hhm -cal -d $calfile -cpu 2 $options");
    }
    if ($align) {
	&System("$hh/hhalign -i $basename.hhm -o $basename.hhr $options");
    }

    open(INFILE,"<$basename.hhr") or die("Error: could not open $basename.hhr for reading: $!\n");
    $line=<INFILE>;
    $line=~/Query\s+(\S+)\s+(\w\.\d+)(\.\d+)(\.\d+)/;
#    $name=$1;
    $fold=$2;
    $sfam=$2.$3;
    $fam =$2.$3.$4;
    my $new_template;

    while ($line=<INFILE>) { if($line=~/^\s*No Hit/) {last;} }
    while ($line=<INFILE>) { 
#                         No      Hit      Prob        Eval   Pval Scor   SS    Cols   beg - end      beg-end
	if ($line=~/^\s*(\d+)\s+(.*\S)\s+(\d+\.\d+)\s+(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)-(\d+)\s+(\d+)-(\d+)\s*\((\d+)\)/) {
	    if ($1>1 || $4<$PVALMAX) {
		if ($1==1) {
		    $new_template="";
		}
		$new_template.=$line;
		$repeats=$1;
	    } 
	} else {last;}
    }
    close(INFILE);
    if (defined $new_template) {
	push(@folds,$fold);
	push(@sfams,$sfam);
	push(@fams,$fam);
	push(@templates,$new_template);
	printf(STDERR "%s\n",$new_template);
    }
    print(STDERR "\n");
}

# Print results to standard output

&Sort(\@folds,\@templates);

for (my $n=0; $n<@templates; $n++) {
    $line=$templates[$n];
    $line=~s/\n/\n            /g;
    printf("%11s %s",$folds[$n], $line);
    print("\n");
}


printf("\nFinished hhallself.pl, processed $n files\n");
exit(0);


# Resort arrays alphabetically according to sorting array0:
# Resort(\@array0,\@array1,...,\@arrayN)
sub Sort() 
{
    my $p_array0 = $_[0];
    my @index=();
    for (my $i=0; $i<@{$p_array0}; $i++) {$index[$i]=$i;}
    @index = sort { ${$p_array0}[$a] cmp ${$p_array0}[$b] } @index;
    foreach my $p_array (@_) {
	my @dummy = @{$p_array};
	@{$p_array}=();
	foreach my $i (@index) {
	    push(@{$p_array}, $dummy[$i]);
	}
    }
}

sub System {
    print(STDERR $_[0]."\n"); 
    return system($_[0]); 
}

