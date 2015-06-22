#!/usr/bin/perl -w

# Cuts a given fasta alignments
# Author:	Angermueller Christof
# Date:		10-07-16

use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);
my $root_dir;
BEGIN {
	if (defined($ENV{TOOLKIT_ROOT})) { $root_dir = $ENV{TOOLKIT_ROOT}; } 
	else { $root_dir = dirname(dirname(dirname(abs_path($0)))); }
};
use lib "$root_dir/bioprogs/perl";
use File::Temp qw(tempfile);
use FastaReader;

if (scalar(@ARGV) < 4) { print STDERR "Missing arguments!\nUsage: alicutter.pl INFILE OUTFILE START END [COV]\n"; exit 1; }
my $infile = $ARGV[0];
my $outfile = $ARGV[1];
my $start = $ARGV[2];
my $end = $ARGV[3];
my $cov = $ARGV[4];
unless ($cov) { $cov = 20; }
my $ali_start;
my $ali_end;

# get start and end of the alignemnt to be cutted
@_ = unpack("c*", new FastaReader($infile)->next->[1]);
my $i = 0;
for ($ali_start = 0; $ali_start < scalar(@_); $ali_start++) {
	if ($_[$ali_start] != 45 && ++$i == $start) { last; }
}
for ($ali_end = $ali_start; $ali_end < scalar(@_); $ali_end++) {
	if ($_[$ali_end] != 45 && $i++ == $end) { last; }
}
if ($ali_start == scalar(@_) || $ali_end == scalar(@_)) { print STDERR "Range does not fit to the alignment!\n"; exit 1; }

# cut alignment
#print "Cutting alignment...\n";
my ($fh, $tmpfile) = tempfile("aliXXXX", DIR=>"/tmp");
my $fr = new FastaReader($infile);
while ($fr->has_next) {
	my $seq = $fr->next;
	print $fh ">", $seq->[0], "\n";
	print $fh substr($seq->[1], $ali_start, $ali_end - $ali_start + 1), "\n";
}
$fr->close;

# filter alignment
#print "Filtering alignment by hhfilter...\n";
system("$root_dir/bioprogs/hhpred/hhfilter -i $tmpfile -o $outfile -cov $cov > /dev/null");

#print "Results written to $outfile!\n";







