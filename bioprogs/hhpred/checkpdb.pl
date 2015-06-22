#! /usr/bin/perl -w
#
# Check whether all files in astralfile are present in the pdb 
# Usage checkpdb.pl astralfile pdbdir

my $usage="
 Check whether all files in fasta-formatted infile are present in the pdb 
 Usage checkpdb.pl infile pdbdir
\n"; 

if (@ARGV<1) {die $usage;}

my $infile=$ARGV[0];
my $pdbdir=$ARGV[1];
my $pdbfile;
my %pdbfiles;
my $line;
my $notfound=0;
my $found=0;


foreach $pdbfile (glob("$pdbdir/*")) {
    $pdbfile=~s/.*\///g;
    $pdbfiles{$pdbfile}="present";
}

open (INFILE, "<$infile") || die "ERROR: Couldn't open $infile: $!\n";
while ($line=<INFILE>) {
    if ($line=~/^>[a-z](.{4})/) {
	$pdbfile="pdb$1.ent";
	if (! exists $pdbfiles{$pdbfile}) {
	    printf ("Warning: not found in $pdbdir: $line");
	    $notfound++;
	} else {$found++;}
    }
}

print ("Found $found files, did not find $notfound files\n");
exit;
