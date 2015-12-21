#!/usr/bin/perl

use strict;
use Errno qw(EAGAIN);

$| = 1;

if(scalar(@ARGV)<2){
	print("Usage: ./FRpredCreateResultPages.pl id scoremodel grouped?\n");
	exit(1);
}

my $basename	  = $ARGV[0];
my $scoringMethod = $ARGV[1];
my $grouped	  = $ARGV[2];
my $linkdir       = $ARGV[3];
$basename =~ m/^(\S+\/)\S+$/;
my $baseDir       = $1;
$linkdir =~ m/^(\S+)\/(\S+?)$/;
my $tree       = "$1/tree.newick";


############# read scores file #############
my @pos2color;
open(SCORES, "$basename.".$scoringMethod."_scores") or die ("Cannot open $basename.$scoringMethod"."_scores: $!");
while(my $line = <SCORES>){
	if($line =~ /^(\s*)(\d+)(\s+)(\S+)(\s+)(\S+)(\s+)(\d+)/){
		$pos2color[($2-1)]=$8;
	}
}

############ read fasta file ################
my $FastAFile = $basename.".fastaOut".$scoringMethod;
#if ($grouped eq "N") {
#	$FastAFile = $baseDir."treeAln.out";
#}
#if(-e $basename.".group.fasta"){
# 	$FastAFile=$basename.".group.fasta";
#}
my @fasCseq; #holds all sequences which are splitted into chars
my @headers;
my $len = 0;
my $seqlen = 0;
my $count=0;
open (FILE, "$FastAFile") or die("Cannot open $FastAFile: $!");
while(my $line=<FILE>){
	if($line =~ /\s*>\s*(.*?)\s*$/){
		$headers[$count] = $1;
		if($len<length($1)){$len = length($1);}
	}else{
		chomp($line);
		my @tmp = split(//, $line);
		if( scalar(@tmp)>$seqlen ){ $seqlen = scalar(@tmp); }
		$fasCseq[$count++] = \@tmp;
	}
}

##########################

#limit header length
if($len>30){$len=30;}


#create metric
my $ticks = "         |";
my $ticksline="";
my $posline ="";
my $end = int($seqlen/10);
for(my $i=0; $i<=$end; ++$i){
	$ticksline .= $ticks;
	if( ($i+1)%5==0 ){
		$posline .= sprintf("%50i", ($i+1)*10);
	}
}
if(length($ticksline)!=length($posline)){
	my $offset = length($ticksline)-length($posline);
	$posline.=sprintf("%".$offset."s"," ");
}

my $spacer = sprintf("%-$len"."s  ", " ");



####### print html page with results ##################################

open(RES,">$basename.".$scoringMethod."_scores.html") or die("Cannot open $basename.$scoringMethod"."_scores.html: $!\n");

print(RES "<pre>");

print(RES "<table border=0>\n<tr><td>\n");

print(RES "<span style=\"font-size: larger;\" > bad </span>");
for(my $i=1; $i<=9; ++$i){
	my $cl = &getColor($i);
	my $invcl = &invertColor($cl); #color: ".$invcl.";
	print(RES "<span style=\"background-color: ".$cl.";  font-size: larger; padding:3px;\">$i<\/span>");
}
print(RES "<span style=\"font-size: larger;\" > good</span></td>\n\n");

#if ($scoringMethod == "2" || $scoringMethod == "4" || ($grouped eq "N" && ($scoringMethod == "5" || $scoringMethod == "6"))) {
#	print(RES "<td><a href=\"#\" onclick=\"new Ajax.Updater('tree_applet', '/frpred/applet?tree=$tree', {asynchronous:true});\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Show UPGMA2 tree&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>\n");
#}

print(RES "<td><a href=\"$linkdir.$scoringMethod"."_scores\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download score file&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>\n");
if(-e "$basename.$scoringMethod"."_rasmol"){
    print(RES "<td><a href=\"$linkdir.$scoringMethod"."_rasmol\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Download rasmol script&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>\n");
}
print(RES "</tr></table>\n");

print(RES "<span style=\"background-color: #eeeeee;\">$spacer$posline<\/span>\n");
print(RES "<span style=\"background-color: #eeeeee;\">$spacer$ticksline<\/span>\n");

for(my $j=0; $j<scalar(@fasCseq); ++$j){
	my $head = sprintf("%-$len"."s  ", substr($headers[$j],0,$len));

	my $link_in = "";
	my $link_out = "";
	if ($headers[$j] =~ /gi\|(\d+)\|/) {
		$link_in = "<a href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=Protein&list_uids=$1&dopt=GenPept\" >";
		$link_out = "</a>";
	}	
	
	if($j==0){
		print(RES "<span onmouseover=\"return overlib('$headers[$j]');\" onmouseout=\"return nd();\" style=\"background-color: #ffffcc;\">$link_in"."$head"."$link_out<\/span>");
	}else{
		print(RES "<span onmouseover=\"return overlib('$headers[$j]');\" onmouseout=\"return nd();\">$link_in"."$head"."$link_out<\/span>");
	}
	for(my $i=0; $i<scalar(@{$fasCseq[$j]}); ++$i){
		my $color = &getColor($pos2color[$i]);
		my $char = @{$fasCseq[$j]}[$i];
		print(RES "<span style=\"background-color: $color;\">$char<\/span>");
	}
	print(RES "\n");
}


print(RES "<span style=\"background-color: #eeeeee;\">$spacer$ticksline<\/span>\n");
print(RES "<span style=\"background-color: #eeeeee;\">$spacer$posline<\/span>\n");

print(RES "\n");

#my $ras = $basename.".".$scoringMethod."_rasmol";
#if(-e $ras){
#	open(RAS,$ras) or die("Cannot open $_\n");
#	while(<RAS>){
#		print(RES $_);
#	}
#}

print(RES "</pre>");
print(RES "<div id=\"tree_applet\"></div>");
close(RES);
exit(0);


###############################################################################################

sub getColor(){
	my $bin = shift;
	if($bin==1){
	#	return sprintf("#%02x%02x%02x", 255, 180, 180);
	        return sprintf("#%02x%02x%02x", 255, 255, 255);#white
	}elsif($bin==2){
		#return sprintf("#%02x%02x%02x", 255, 205, 205);
		return sprintf("#%02x%02x%02x", 255, 255, 255);#white
	}elsif($bin==3){
		#return sprintf("#%02x%02x%02x", 255, 225, 225);
	        return sprintf("#%02x%02x%02x", 255, 255, 255);#white
	}elsif($bin==4){
		#return sprintf("#%02x%02x%02x", 255, 240, 240);
	        return sprintf("#%02x%02x%02x", 255, 255, 255);#white
	}elsif($bin==5){
		return sprintf("#%02x%02x%02x", 255, 255, 255);
	}elsif($bin==6){
		return sprintf("#%02x%02x%02x", 220, 230, 255);
	}elsif($bin==7){
		return sprintf("#%02x%02x%02x", 180, 200, 255);
	}elsif($bin==8){
		return sprintf("#%02x%02x%02x", 150, 175, 255);
	}elsif($bin==9){
		return sprintf("#%02x%02x%02x", 105, 140, 255);
}

}

sub invertColor(){
	my $ic = shift;
	my $r = substr($ic,1,2);	
	my $g = substr($ic,3,2);
	my $b = substr($ic,5,2);
	
	$r = 255- hex($r);
	$g = 255- hex($g);
	$b = 255- hex($b);
	return sprintf("#%02x%02x%02x", $r, $g, $b);
}
