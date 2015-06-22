#!/usr/bin/perl -w
# Reformat pubmed record to bibtex record

use strict;

my @record;

print("
Reformat PubMed citation record to bibtex record.
Paste PubMed record into standard input. Result will be appended to <file>.
Usage: pubmed2bibtex.pl <file>

Example:

Authors:  Andrade MA, Perez-Iratxeta C, Ponting CP. 	Related Articles, Links
Title:    Abstract 	Protein repeats: structures, functions, and evolution.
Journal:  J Struct Biol. 2001 May-Jun;134(2-3):117-31. Review.

\@ARTICLE{Andrade:2002,
AUTHOR  = {Andrade, M. A., Perez-Iratxeta, C., Ponting, C. P.},
TITLE   = {Protein repeats: structures, functions, and evolution.},
YEAR    = {2001},
JOURNAL = {J. Struct. Biol.},
VOLUME  = {134},
PAGES   = {117-131}
}

Quit program with Ctrl-D (end of file)

");


my $outfile;
my $line;
my $authors;
my $firstauthor;
my $initials;
my $title;
my $journal;
my $year;
my $volume;
my $firstpage;
my $lastpage;

if (@ARGV<1) {exit;} else {$outfile=$ARGV[0];}

open (OUTFILE,">>$outfile") || die("Error: cannot open $outfile: $!\n");

while (1) {

    $authors="";
    print("Enter next PubMed record:  \n");
    $line = <STDIN>;
    if (!$line) {last;}
    $line=~s/\s*Related Articles, Links\s*//;
    $line=~s/\.\s*/, /;
    while ($line) {
	$line=~s/^\s*(.*?)\s([A-Z]+),\s*//;
	$authors.=$1.", ";
	$initials=$2;
	$initials=~s/(\S)/$1\. /g;
	$initials=~s/ $//;
	$authors.=$initials." and ";
    }
    $authors=~s/, $//; # remove trailing colon and space
    $authors=~s/\s*and\s*$//;  # remove last and
    $authors=~/([^,]+)/;
    $firstauthor=$1;
    $firstauthor=~tr/ //d;

    $title = <STDIN>;
    if (!$title) {last;}
    $title =~s/Abstract\s*//;
    $title =~s/Free Full Text\s*//;
    $title =~s/Free in PMC\s*//;
    $title =~s/\.\s*$//;

    $line = <STDIN>;
    if (!$line) {last;}
    $line=~/^\s*(\D*?)\s(\d+).*?;(.*?\d+).*?:(\w*?\d+)-?(\w*?\d*)\.?/;
    $journal = $1;
    $year = $2;
    $volume = $3;
    $firstpage = $4;
    if ($5 && $5 ne "") {
	$lastpage = $4;
	substr($lastpage,length($firstpage)-length($5),length($5),$5);
	$lastpage="-".$lastpage;
    } else {
	$lastpage="";
    }

    # If journal name is composed of more than one word it is probably an abbreviation => add full stops
    if ($journal!~s/(\S+)?\s/$1. /g) {
	$journal=~s/\.\s*//; # otherwise remove last fullstop
    }

    
    printf("\n");
    printf("\@ARTICLE{%s:%s,\n",$firstauthor,$year);
    printf("AUTHOR  = {%s},\n",$authors);
    printf("TITLE   = {{%s}},\n",$title);
    printf("YEAR    = {%s},\n",$year);
    printf("JOURNAL = {%s},\n",$journal);
    printf("VOLUME  = {%s},\n",$volume);
    printf("PAGES   = {%s%s}\n}\n",$firstpage,$lastpage);
    printf("\n");
}
print("\n");

close(OUTFILE);
