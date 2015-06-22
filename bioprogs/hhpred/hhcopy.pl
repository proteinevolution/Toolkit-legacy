#! /usr/bin/perl -w
# For optimization of hhsearch one needs:
# a directory with all scop families that have other families belonging
# to the same superfamily. Two steps are required:
# 1. Go to alignment directory and type 'cp *.*.*.4.1.sf template-dir'
#    This copies a representative set of families from the directory.
# 2. Run the little script below in the template directory 
#    to copy the corresponding files *.3.1.sf to the template-dir

use strict;

if (scalar(@ARGV)<2) 
{
    print("\nhhcopy: read all *.n.m.ext files in current directory and\n"); 
    print("replenish with *.(n-1).m.ext files in source directory\n"); 
    print("Usage:   perl hhcopy.pl source-dir/ ext \n\n"); 
    exit;
}

my $sourcedir = $ARGV[0];
my $ext = $ARGV[1];

my @files = glob("*.$ext"); #read all such files into @files 
my $file;
my $sfname;
my $fam;
my $seq;
my $err;
my $delete="";
foreach $file (@files)
{   
#              cl .fd .sf .  fa  . sq  .ext
    $file =~ /(.*\..*\..*\.)(.*)\.(.*)\..*/;
    $sfname = $1;
    $fam = $2-1;
    $seq = $3;
#    print("sfname=$sfname \t");
#    print("fam =  $fam \t");
#    print("seq =  $seq \t");
    if (! -e "$sourcedir$sfname$fam.1.$ext") 
    {
	while (($delete ne "y") && ($delete ne "n")) 
	{
	    print("$sourcedir$sfname$fam.1.$ext does not exist. Delete $file and others with no conjugate? (y/n)  ");
	    $delete = <STDIN>;
	    chomp $delete;
	}
	if ($delete eq "y") {print("Deleting $file\n"); system("rm -f $file");}
    }
    else
    {
	$err= system("cp $sourcedir$sfname$fam.1.$ext .");
	print("cp $sourcedir$sfname$fam.1.$ext .   err=$err $!\n");
    }
}    
exit(0);
