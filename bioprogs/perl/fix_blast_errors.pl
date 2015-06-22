#! /usr/bin/perl -w
# Fix errors in Blast-output
# Also add links for Uniprot Identifiers to psiblast input
# Usage:   fix_blast_errors.pl -i blast-file  [-u]

use strict;

my $file;
my @res;
my $beg_hitlist;
my $end_hitlist;
my $sequence;
my $i = 0;
my $gi;
my $fix_uniprot = 1;

# check arguments
if ( @ARGV < 1 ) {
	error();
	exit(1);
}

for ( my $j = 0 ; $j < @ARGV ; $j = $j + 2 ) {

	if ( $ARGV[$j] eq "-i" ) {
		$file = $ARGV[ $j + 1 ];
	}
	elsif ( $ARGV[$j] eq "-u" ) {
		$fix_uniprot = 0;
		print "Disabling Uniprot Fix\n";
	}
	else {
		print("\nERROR: Don't know this Argument: $ARGV[$j] \n\n");
		error();

		exit(1);
	}
}

if ( !defined($file) || $file eq "" || !(-r $file)) {
	print("\nERROR: No or unreadable inputfile!!! \n\n");
	error();
	exit(1);
}

if (-z $file) {
    print "ERROR! Empty result file!\n";
    exit(1);
}

open( IN, "$file" ) or die("Cannot open!");
@res = <IN>;
close IN;

# Search for empty name tags

$i = 0;
check_hits();

my %linknum;

# Identify the region before the link block, stops at first hit !
# Only Links that shall be set are ncbi Uniprot and Ensembl Links 
while ($i < scalar(@res) && ($res[$i] !~ /<a href = \#\d+/o) && ($res[$i] !~ /(^sp|^tr)\|\w\d+/) && ($res[$i] !~ /(ENS)/)  && ($res[$i] !~ /(FBpp)/)) {
	$i++;
	
}
# Counter for processing the Linkes in the header section
$beg_hitlist = $i;

# Traverse through all lines that show the following behavior 

while ($i < scalar(@res) && ($res[$i] =~ /<a href = \#(\d+)/o || $res[$i] !~ /^>/ ||$res[$i]=~ /(^sp|^tr)\|\w\d+/ )) {

	
	if($fix_uniprot){
    	$res[$i] = fix_uniprot_links($res[$i]);	
    }
    # we find a match for ensembl and we fix the ensemble links
    if($res[$i] =~ /^(ENS.*?)<\/a> /){
    	$res[$i] = fix_ensembl_links($res[$i]);	
    	
    } 
    # we find a match for flybase and we fix the flybase links
    if($res[$i] =~ /^(FBpp.*?)<\/a> /){
    	$res[$i] = fix_flybase_links($res[$i]);	
    	
    } 
    
	$linknum{$i} = ' ';
	$i++;
}
$end_hitlist = $i;
#print "end hitlist  ".$end_hitlist."\n";

# start processing the lower sequence block after the heatmap 
while ($i < scalar(@res) && $res[$i] !~ /Database:/) {
	# Identify the sequence headers 
	if($res[$i]=~ /^>/){
		if($fix_uniprot){
			$res[$i] = fix_uniprot_links_body($res[$i]);
		}
	}

	# kft 11 Feb 2015: These blast errors weren't encountered by me yet with blastpgp version 2.2.26 from 2011.
	# Keeping the fixes, in case they still occur.
	if ( $res[$i] =~ /<a name = 0>/ ) {
		$res[$i] =~ /gi\|(\d+)\|/;
		$gi = $1;
		if ( defined $gi ) {
			for ( my $j = $beg_hitlist ; $j < $end_hitlist ; $j++ ) {
				if ( $res[$j] =~ /gi\|$gi\|/ ) {
					$res[$j] =~ /<a href = \#(\d+)>/;
					my $tmp = $1;
					$res[$i] =~ s/<a name = 0>/<a name = $tmp>/;
					last;
				}
			}
		}
	}
	elsif ( $res[$i] =~ /<a name = (\d+)>/ ) {
		if ( !defined $linknum{$1} ) {
			$res[$i] =~ /gi\|(\d+)\|/;
			$gi = $1;
			if ( defined $gi ) {
				for ( my $j = $beg_hitlist ; $j < $end_hitlist ; $j++ ) {
					if ( $res[$j] =~ /gi\|$gi\|/ ) {
						$res[$j] =~ /<a href = \#(\d+)>/;
						my $tmp = $1;
						$res[$i] =~ s/<a name = \d+>/<a name = $tmp>/;
						last;
					}
				}
			}
		}
	}
	$i++;
}


$i = 0;
while ($res[$i] !~ /<PRE>/i && $i < scalar(@res)) {
    $i++;
}
my $endi = scalar(@res) - 1;
while ($endi >=0 && ($res[$endi] =~ m'</HTML>' || $res[$endi] =~ m'</BODY>' || $res[$endi] !~ /\S/)) {
    --$endi;
}

open( OUT, ">$file" ) or die("Cannot open!");
while ($i <= $endi) {
    print OUT $res[$i];
    $i++;
}
close OUT;

exit(0);

#####################################################
#### sub functions

####
# For the given Sequence line in the overview (heatmap) add the appropriate uniprot URL
# input  :<String> Corrupted Blast line
# Output :<String> Fixed line with params
####
sub fix_uniprot_links{
    my $uniprot_link ='<a href="http://www.uniprot.org/uniprot/';
	my $inputline = shift(@_);
	
	if($inputline=~ /(^sp|^tr)\|(.*)\|/ ){
	   $inputline = $uniprot_link.$2."\">".$inputline;
	}
	return $inputline;
}
####
# For the given Sequence line in the overview (heatmap) add the appropriate uniprot URL
# input  :<String> Corrupted Blast line
# Output :<String> Fixed line with params
####
sub fix_ensembl_links{
    my $ensembl_link ='<a href="http://www.ensembl.org/Multi/Search/Results?species=all;idx=;q=';
	my $inputline = shift(@_);
	print "L173 Replacing $inputline \n";
	 if($res[$i] =~ /^(ENS.*?)<\/a> /){
		$inputline = $ensembl_link.$1."\">".$inputline;
	}
	return $inputline;
}

####
# For the given Sequence line in the overview (heatmap) add the appropriate uniprot URL
# input  :<String> Corrupted Blast line
# Output :<String> Fixed line with params
####
sub fix_flybase_links{
    my $flybase_link ='<a href="http://flybase.org/reports/';
	my $inputline = shift(@_);
	print "L173 Replacing $inputline \n";
	 if($res[$i] =~ /^(FBpp.*?)<\/a> /){
		$inputline = $flybase_link.$1.".html\">".$inputline;
	}
	return $inputline;
}



####
# For the given Sequence in the Sequence description, add the appropriate uniprot URL
# input  :<String> Corrupted Blast line
# Output :<String> Fixed line with params
####
sub fix_uniprot_links_body{
    my $uniprot_link ='<a href="http://www.uniprot.org/uniprot/';
    my $inputline = shift(@_);
    
    if($inputline=~ /(\>(<a name = (.*)>)<\/a>(((sp|tr).*\|.*)<\/a>(.*)))/ ){
	###### blastpgp output
	# $inputline eg.: ><a name = A8JV00></a>tr|A8JV00|A8JV00_DROME</a> CG34417, isoform H OS=Drosophila melanogaster GN=CG34417 PE=4 SV=1
	# $2 = Uniprot ID Tag    : <a name = A8JV00>
	# $3 = Uniprot ID        : A8JV00
	# $5 = Name without Tags : tr|A8JV00|A8JV00_DROME
	# $7 = Description       : CG34417, isoform H OS=Drosophila melanogaster GN=CG34417 PE=4 SV=1
	#######
	$inputline = ">".$2."</a>".$uniprot_link.$3."\">".$5."</a>".$7;
    } elsif ($inputline =~ m'^>((sp|tr).*\|.*)(<a name=(.*)>)</a>(.*)') {
	###### psiblast output
	# $inputline eg.: >tr|A0A067DLQ2|A0A067DLQ2_CITSI<a name=A0A067DLQ2></a> Uncharacterized protein OS=Citrus sinensis GN=CISIN_1g046461mg
	# $1 = Name without Tags : tr|A0A067DLQ2|A0A067DLQ2_CITSI
	# $3 = Uniprot ID Tag    : <a name=A0A67DLQ2>
	# $4 = Uniprot ID        : A0A067DLQ2
	# $5 = Description       : Uncharacterized protein OS=Citrus sinensis GN=CISIN_1g046461mg
        ######
	# $inputline = ">".$3."</a>".$uniprot_link.$4."\">".$1."</a>".$5;
	## trying to keep most of psiblast output formatting (i.e. Sequence and trailing newline)
	$inputline = ">".$uniprot_link.$4."\">".$1."</a>".$3."</a>".$5."\n";
    }
    return $inputline;
}


sub error {
	print("Usage: fix_blast_errors.pl [options] \n");
	print("\n");
	print("Options:\n\n");
	print("-i blast-file\n\n");
	print("Optional:\n\n");
	print("\n");
}

sub check_hits {
	foreach (@res) {
		if ( $_ =~ /No hits found/ ) {
			exit(0);
		}
	}
}
