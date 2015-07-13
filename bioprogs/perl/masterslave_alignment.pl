#! /usr/bin/perl -w
#
# Generate a master Slave Aligment from an input File and the output alignment of hhsearch. 
# Usage  : masterslave_alignment.pl -q <input.fas> -hhr <result.hhr> <outputfile>
# Author : Joern Marialke 2011 Gencenter Munich

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
require "$root_dir/bioprogs/perl/hhrparser.pl";

my $usage = "Build a Master Slave alignment with a single Query Sequence or a multiple 
Sequence Alignment.
Usage  : masterslave_alignment.pl -q <input.fas> -hhr <result.hhr> -o <outputfile>

Options:
      
      -q	<input.fas>    	Query File with Alignemnt /Single Sequence
      -hhr	<result.hhr>	Result .hhr file generated by HHpred / HHBlits
      -o	<output.fas>    Master Slave Output file 
      [-v]	<int>		Verbose mode 1 = Verbose 2 = Debug
\n";


# Global variable declaration
my $queryfile;         		# File with query Sequence / Consesus aligment
my $templatefile;      		# HHR File with the results from HHPred / HHBlits
my $options="";	
my $v = 0;					# Set Verbose mode 0 = silent, 1 = verbose, 2 = debug 
my $align = 0;				# Set Query Sequence mode 0 = single Sequence, 1 = Alignment
my $sequence_length = 0; 	# Length of the ungapped Query Sequence
my @output_container;       # Output Fasta Container
my $outputfile;				# Output File Location

my %alignmentContainer;

# Processed query data
my $consensus_master_sequence;			# Master Sequence used for the Jalview Output
my $consensus_master_header;            # Master Header   used for the Jalview Output
my $additional_master_sequences="";		# If more than one Master Sequence exists add rest here	

    

# Processing command line options
if (@ARGV<1) {die $usage;}
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

# Set options
if ($options=~s/ -hhr\s+(\S+) / /g)		{$templatefile=$1;}
if ($options=~s/ -q\s+(\S+) / /g)		{$queryfile=$1;}
if ($options=~s/ -v\s+(\d+) / /g)		{$v=$1;}
if ($options=~s/ -a\s+/ /ig)			{$align=1;}
if ($options=~s/ -o\s+(\S+) / /g)	{$outputfile=$1;}

&loadQueryData();
&LoadAlignmentData();
#&buildUngappedQuery();
&MasterSlaveAlignment();
&writeOutputData();
#if($v>1){&listVariables();}

######################################################################
# Create Master Slave Alignment from a given hhr file 
#
######################################################################
sub MasterSlaveAlignment(){
	if($v>-1){
		print "\nCreating Master Slave Alignment\n";
	}
	
	# Init global Vars
	my $template_string_master = $consensus_master_sequence; # Copy of the master
	my $template_string_length = length($template_string_master);
	$template_string_master =~ tr/[A-Z]/-/; 				  # Replace all chars by -
	
	# 1a Step: Load Master Query Header and Master Sequence into outputContainer
	push(@output_container,($consensus_master_header,$consensus_master_sequence));
	
	# 1b Step: Load additional (if existing) Alignment Query Sequences
	push(@output_container, $additional_master_sequences);
	# 2 Step: Sort keys
	my @alignment_keys = keys(%alignmentContainer);
	# Keys are just numerical values, sort them according the values
	@alignment_keys = sort { $a <=> $b } @alignment_keys; 
	
	# 3 Step copy Ungapped Sequence Data to Output Container
	foreach my $key ( @alignment_keys )
	{   
		# Create a new String for each alignment
		my $template_string = $template_string_master;
		my $tSeq;
		my $qSeq;
		my $start;
		my $stop;
  		my $aoj = $alignmentContainer{$key};
  		# master slave generates a copy, is not inplace
  		$aoj   = $aoj->masterSlave();
  		$start = $aoj->getQueryStart();
  		$stop  = $aoj->getQueryStop(); 
  		$tSeq  = $aoj->getTemplateSequence();
  		$qSeq  = $aoj->getQuerySequence();
  		# Replace at from start to end of query with template Sequence
  		#print "---------------------------------------\n";
  		#print "Templ : ".$aoj->getTemplateName()."\n";
  		#print "Start : ".$start."\n";
  		#print "Stop  : ".$stop."\n"; 
  		#print "Seq   : ".$qSeq."\n";
  		#print "Length of Gap ".($stop -$start)."\n";
  		#print "Length of Insertion ".length($tSeq)."\n";
  		#print "Length before : ".length($template_string)."\n";
  		my $beg = substr($template_string,0,$start-1);
  		my $rest  = substr($template_string,$stop,$template_string_length-1);
  		$template_string = $beg.$tSeq.$rest;
  		#print "Length after  : ".length($template_string)."\n";
  		
  		# push the processed template Sequence into Container
  		push(@output_container,($aoj->getTemplateName,$template_string));
	}
	
   

}
###########################################################################
# Write Output Data to File 
#
###########################################################################
sub writeOutputData(){
	print "Output Data File : ".$outputfile."\n";
	if(!defined $outputfile ){
		print "Please Set output path\n$usage\n";
		return;
	}
	
	open (OUTFILE, ">$outputfile") || die "Cannot Write to $outputfile ";	
	  for my $value (@output_container) {
	  	
	    print OUTFILE $value."\n";
	    print $value."\n";
    } 
    close (OUTFILE);
	
	
}


#######################################################################
# Load and preprocess the template alignments from hhr File
#
#######################################################################
sub LoadAlignmentData(){
	if($v>1){print "Loading Template Data\n";}
	
	my $parser = new HHRParser();	
    %alignmentContainer = $parser->getAlignmentContainer();
}


######################################################################
# Load and preprocess the query Sequence / Alignment
#
######################################################################
sub loadQueryData(){
 if($v>1){
 	print "Loading Query Data\n";
 	print "Query is Alignment ".$align."\n";
 }
 
# Declare local Variables  
my $line;
my $q_header;
my $q_sequence;	 	

# Query is only one sequence, Extract the Header and the sequence	 	
#if($align == 0){	 	
#	 open (INFILE, "<$queryfile") || die "Error loading query Data: Couldn't open $queryfile: $!\n";
#		while ($line=<INFILE>) {
#			if ($line=~/^>(\S+)/) {
#				# chomp is inplace removal of newline char
#				chomp($line);
#            	$q_header =  $line;
#			}
#			else{
#				# chomp is inplace removal of newline char
#				chomp($line);
##				$q_sequence = $line;
#				# Query is ungapped, as it is just the input Sequence given
#				$sequence_length = length($q_sequence);
#			}
#		}
#	
#	 close (INFILE);
#	 $consensus_master_header   = $q_header;
#	 $consensus_master_sequence = $q_sequence;
#	 
#}

#if($align ==1){
	my @queryHeaders;
	my @querySequences;
	my $seqCounter = 0;  # Needed to identify if a new Query has started and we can push the sequence to array
	my $seqCounterChange = 1;
	my $seqline;
	open (INFILE, "<$queryfile") || die "Error loading query Data: Couldn't open $queryfile: $!\n";
	while ($line=<INFILE>) {
		if ($line=~/^>(\S+)/) {
					print $line."\n";
					# chomp is inplace removal of newline char
					chomp($line);
	            	$q_header =  $line;
	            	push(@queryHeaders, $q_header);
	            	$seqCounter++;
				}
				else{
					# chomp is inplace removal of newline char
					chomp($line);
					
					if($seqCounter != $seqCounterChange){
						push(@querySequences, $seqline);
						$seqline ="";
						$seqCounterChange++;
					}
					$seqline = $seqline.$line;
				}
		}
		# The last Sequence has to be pushed as well
		push(@querySequences, $seqline);
	close (INFILE);
	 # Instead of using just one Sequence, we take the whole alignment, we have to
	
	 if (@queryHeaders >2){
	 	# The first Header is pushed separately, so we do not have to change internal structure for header
	 	$consensus_master_header   = $queryHeaders[0];
	 	$consensus_master_sequence = $querySequences[0];
	 	$sequence_length = length($consensus_master_sequence);
	 	
	 	for(my $i=1;$i< @queryHeaders;$i++){
	 		$additional_master_sequences = $additional_master_sequences."\n".$queryHeaders[$i]."\n".$querySequences[$i]."\n"; 
	 	}
	 	
	 }else{
	 	$consensus_master_header   = $queryHeaders[0];
	 	$consensus_master_sequence = $querySequences[0];
	 	$sequence_length = length($consensus_master_sequence);
	 }
	 
#}


	 if($v>1){
	 	print "Master sequence Header : ".$consensus_master_header."\n";
	 	print "Master Sequence : ".$consensus_master_sequence."\n";
		print "Master Sequence Length : ".$sequence_length."\n";
	 }
	 
	 	
}

#####################################################################################################
# Remove Gaps from the consensus Master Sequence and fill the Gap Array needed for the master Slave
# Alignment
#
#####################################################################################################
sub buildUngappedQuery(){
	if($v>1){
 		print "Ungapping Sequence\n";
 		print "Building Gap Array\n";
 	}
	
    # Declare local Variables	
	my @gap_array;
	my $seqlength_gaps_removed = 0;
	
	# Split the master String to generate the gap Array
	@gap_array = split(//,"$consensus_master_sequence");
    

	# Replace Gaps by position numbers of sequence
	for(my $i=0;$i<scalar(@gap_array);$i++){
		#print $gap_array[$i];
		if($gap_array[$i]=~/-/ ){
			$gap_array[$i]= $i;
		}
		# Remove the other elements
		else{
			$seqlength_gaps_removed++;
			$gap_array[$i]=" ";
		}
		if($v>1){print $gap_array[$i]}
	}
	 if($v>1){print "\n";
	 	      print "Ungapped Sequence Length : ".$seqlength_gaps_removed."\n";
	 }
	
	# After the removal of query_gaps the Sequence Length is set
	$sequence_length = $seqlength_gaps_removed;
}

########################################################################################################
# List all global Variables  
#
#######################################################################################################
sub listVariables(){
my $varlist="".	
	$queryfile."\t\t# File with query Sequence / Consesus aligment\n".
	$templatefile."\t\t# HHR File with the results from HHPred / HHBlits\n".
	$options."\n".	
	$v."\t\t# Set Verbose mode 0 = nothing, 1 = verbose, 2 = debug\n". 
	$align."\t\t# Set Query Sequence mode 0 = single Sequence, 1 = Alignment\n".
	$sequence_length."\t\t# Length of the ungapped Query Sequence\n";


print $varlist;		
	
}
