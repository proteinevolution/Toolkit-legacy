#! /usr/bin/perl -w
# Usage: perl rename.pl  
# Rename files in working directory

use strict;

my $subst="";

if (scalar(@ARGV)<1) 
{
    print("Usage:   perl rename.pl \"file-filter\" expression [substitution]\n"); 
    print("Example: 'perl rename.pl \"*.ali.out\" .ali' removes '.ali'\n"); 
    exit;
}
my $filter = $ARGV[0];
my $expr = $ARGV[1];
if (scalar(@ARGV)>=3) {$subst = $ARGV[2];}

print("filter=\'$filter\'\n");
print("expression=\'$expr\'\n");
print("substitution=\'$subst\'\n");



my @files = glob "$filter"; #read all such files into @files 
my $file;
my $oldfile;

print (scalar(@files)." files read in. Starting selection loop ...\n");

foreach $file (@files)
{   
    $oldfile = $file;
    if ($file =~ s/$expr/$subst/)
    {
	print ("Renaming: $oldfile --> $file\n");
	rename ($oldfile,$file);
    }
}
