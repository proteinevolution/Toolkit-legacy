#! /usr/bin/perl -w
#
# HHRParser - Utility Class to extract all data from an HHR file 
# Usage  : hhrparser.pl -i <hhrfile>
# Author : Joern Marialke 2011 Genecenter Munich


use strict;


###########################################################################
# Alignment Container Contains all information on the Alignment Parsed
# by HHR Parser
#
# by Joern Marialke 2011
############################################################################
package AlignmentObject;

############################################################################
# Initialize the Alingment Object Container
# 
############################################################################
sub new {
	my $invocant = shift;
	my $class =ref($invocant) || $invocant;
	my $self = {
        _class => $class,
        _queryName => undef,
        _querySequence => "",
        _queryStart => undef,
        _queryStop => undef,
        _queryConsensus => "",
        _query_ss_pred => "",
        _templateName => undef,
        _templateSequence => "",
        _templateStart => undef,
        _templateStop => undef,
        _templateConsensus => "", 
        _template_ss_dssp => "",
        _template_ss_pred => ""
	};
	bless($self, $class);
	return $self;
}
#################################################################
# Getter and Setter methods for all Fields
#
#################################################################
sub getQueryName {
	my ($self) = @_;
    return $self->{_queryName};
}

sub setQueryName {
    my ( $self, $queryName ) = @_;
    $self->{_queryName} = $queryName if defined($queryName);
    return $self->{_queryName};
}

sub getQuerySequence {
	my ($self) = @_;
    return $self->{_querySequence};
}

sub setQuerySequence {
    my ( $self, $querySequence ) = @_;
    $self->{_querySequence} = $querySequence if defined($querySequence);
    return $self->{_querySequence};
}

sub getQueryStart {
	my ($self) = @_;
    return $self->{_queryStart};
}

sub setQueryStart {
    my ( $self, $queryStart ) = @_;
    $self->{_queryStart} = $queryStart if defined($queryStart);
    return $self->{_queryStart};
}
sub getQueryStop {
	my ($self) = @_;
    return $self->{_queryStop};
}

sub setQueryStop {
    my ( $self, $queryStop ) = @_;
    $self->{_queryStop} = $queryStop if defined($queryStop);
    return $self->{_queryStop};
}

sub getQueryConsensus {
	my ($self) = @_;
    return $self->{_queryConsensus};
}

sub setQueryConsensus {
    my ( $self, $queryConsensus ) = @_;
    $self->{_queryConsensus} = $queryConsensus if defined($queryConsensus);
    return $self->{_queryConsensus};
}

sub getQuery_ssPred {
	my ($self) = @_;
    return $self->{_query_ss_pred};
}

sub setQuery_ssPred {
    my ( $self, $query_ss_pred ) = @_;
    $self->{_query_ss_pred} = $query_ss_pred if defined($query_ss_pred);
    return $self->{_query_ss_pred};
}
sub getTemplateName {
	my ($self) = @_;
    return $self->{_templateName};
}

sub setTemplateName {
    my ( $self, $templateName ) = @_;
    $self->{_templateName} = $templateName if defined($templateName);
    return $self->{_templateName};
}

sub getTemplateSequence {
	my ($self) = @_;
    return $self->{_templateSequence};
}

sub setTemplateSequence {
    my ( $self, $templateSequence ) = @_;
    $self->{_templateSequence} = $templateSequence if defined($templateSequence);
    return $self->{_templateSequence};
}

sub getTemplateStart {
	my ($self) = @_;
    return $self->{_templateStart};
}

sub setTemplateStart {
    my ( $self, $templateStart ) = @_;
    $self->{_templateStart} = $templateStart if defined($templateStart);
    return $self->{_templateStart};
}

sub getTemplateStop {
	my ($self) = @_;
    return $self->{_templateStop};
}

sub setTemplateStop {
    my ( $self, $templateStop ) = @_;
    $self->{_templateStop} = $templateStop if defined($templateStop);
    return $self->{_templateStop};
}

sub getTemplateConsensus {
	my ($self) = @_;
    return $self->{_templateConsensus};
}

sub setTemplateConsensus {
    my ( $self, $templateConsensus ) = @_;
    $self->{_templateConsensus} = $templateConsensus if defined($templateConsensus);
    return $self->{_templateConsensus};
}

sub getTemplate_ssDssp {
	my ($self) = @_;
    return $self->{_template_ss_dssp};
}

sub setTemplate_ssDssp {
    my ( $self, $template_ss_dssp ) = @_;
    $self->{_template_ss_dssp} = $template_ss_dssp if defined($template_ss_dssp);
    return $self->{_template_ss_dssp};
}

sub getTemplate_ssPred {
	my ($self) = @_;
    return $self->{_template_ss_pred};
}

sub setTemplate_ssPred {
    my ( $self, $template_ss_pred ) = @_;
    $self->{_template_ss_pred} = $template_ss_pred if defined($template_ss_pred);
    return $self->{_template_ss_pred};
}
# Validates the Alignment Containers Consistency and existence of parsed elements
sub isValid(){
 my ($self) = @_;
 # initialize local variables
 my $validation_code = 1;
 my $aln_length = length  ($self->{_querySequence});
 
 # Validates the existence of parsed elements
  $validation_code = 0 if !defined($self->{_queryName}); 
  $validation_code = 0 if !defined($self->{_queryStart});
  $validation_code = 0 if !defined($self->{_queryStop});
  $validation_code = 0 if length  ($self->{_querySequence})  == 0;
  $validation_code = 0 if length  ($self->{_queryConsensus}) == 0;
  #$validation_code = 0 if length  ($self->{_query_ss_pred})  == 0;
  $validation_code = 0 if !defined($self->{_templateName});
  $validation_code = 0 if !defined($self->{_templateStart});
  $validation_code = 0 if !defined($self->{_templateStop});
  $validation_code = 0 if length  ($self->{_templateSequence}) == 0;
  $validation_code = 0 if length  ($self->{_templateConsensus}) == 0;
  #$validation_code = 0 if length  ($self->{_template_ss_pred}) == 0;
  #$validation_code = 0 if length  ($self->{_template_ss_dssp}) == 0;
 
 # Validate the input length of the different lines
  $validation_code = 2  if length  ($self->{_querySequence})     != $aln_length;
  $validation_code = 2  if length  ($self->{_queryConsensus})    != $aln_length;
  #$validation_code = 2 && print "Query ss_pred not $aln_length" if length  ($self->{_query_ss_pred})     != $aln_length;
  $validation_code = 2 if length  ($self->{_templateSequence})  != $aln_length;
  $validation_code = 2 if length  ($self->{_templateConsensus}) != $aln_length;
  #$validation_code = 2 if length  ($self->{_template_ss_pred})  != $aln_length;
  #$validation_code = 2 if length  ($self->{_template_ss_dssp})  != $aln_length;
 
 
 # As you have to come to this stage, every parameter has been set
 return  $validation_code;
 }
	
#######################################################################################
# Generate a Copy of the current Alignement Object with all Gaps in Query deleted and 
# all corresponding strings stripped as well 
# 
#######################################################################################
sub masterSlave(){
	
	my ($self) = @_ ;
	my $msAlignment = new AlignmentObject();
	my @QSecArray;  								# The Query String  changed into array
	my @QConsensusArray;							# The Query Consens changed into array
	my @Q_ssPredArray;								# The Query ssPred  changed into array
	
	my @TSecArray;  								# The Template String  changed into array
	my @TConsensusArray;							# The Template Consens changed into array
	my @T_ssPredArray;								# The Template Pred    changed into array
	my @T_ssDsspArray;								# The Template ssDssp  changed into array

	# Push each char into the array bin
	@QSecArray       = split(//,"$self->{_querySequence}");
	@QConsensusArray = split(//,"$self->{_queryConsensus}");
	#@Q_ssPredArray   = split(//,"$self->{_query_ss_pred}");
	
	@TSecArray       = split(//,"$self->{_templateSequence}");
	@TConsensusArray = split(//,"$self->{_templateConsensus}");
	#@T_ssPredArray   = split(//,"$self->{_template_ss_pred}");
	#@T_ssDsspArray   = split(//,"$self->{_template_ss_dssp}");
	
	# Replace Gaps by empty Strings of sequence
	for(my $i=0;$i<scalar(@QSecArray);$i++){
		
		if($QSecArray[$i]=~/-/ ){
			$QSecArray[$i]       = "";
			$QConsensusArray[$i] = "";
			#$Q_ssPredArray[$i]   = "";
			
			$TSecArray[$i]       = "";
			$TConsensusArray[$i] = "";
			#$T_ssPredArray[$i]   = "";
			#$T_ssDsspArray[$i]   = "";
		}
		
	}	
	
	
	# Copy the gapless Master Slave Alignment to the now Alignment object
	
	$msAlignment->setQueryName($self->{_queryName});
	$msAlignment->setQueryStart($self->{_queryStart});
	$msAlignment->setQueryStop($self->{_queryStop});
	$msAlignment->setQuerySequence(join("",@QSecArray));
	$msAlignment->setQueryConsensus(join("",@QConsensusArray));
	$msAlignment->setQuery_ssPred(join("",@Q_ssPredArray)) ;
	
	$msAlignment->setTemplateName($self->{_templateName});
	$msAlignment->setTemplateStart($self->{_templateStart});
	$msAlignment->setTemplateStop($self->{_templateStop});
	$msAlignment->setTemplateSequence(join("",@TSecArray));
	$msAlignment->setTemplateConsensus(join("",@TConsensusArray));
	$msAlignment->setTemplate_ssPred(join("",@T_ssPredArray));
	$msAlignment->setTemplate_ssDssp(join("",@T_ssDsspArray));
	
	return $msAlignment;
}	
	
sub describe(){
	my ($self) = @_ ;
	print "Object Type : ".$self->{_class}."\n";
	print "Query Name  : ".$self->{_queryName}."\n" if defined($self->{_queryName});
	print "Query Seq   : ".$self->{_querySequence}."\n" if defined($self->{_querySequence});;
	print "Query Start : ".$self->{_queryStart}."\n" if defined($self->{_queryStart});
	print "Query Stop  : ".$self->{_queryStop}."\n" if defined($self->{_queryStop});
	print "Query Cons  : ".$self->{_queryConsensus}."\n" if defined($self->{_queryConsensus});
	print "Query Pred  : ".$self->{_query_ss_pred}."\n" if defined($self->{_query_ss_pred});
	print "Temp  Name  : ".$self->{_templateName}."\n" if defined($self->{_templateName});
	print "Temp  Seq   : ".$self->{_templateSequence}."\n" if defined($self->{_templateSequence});
	print "Temp  Start : ".$self->{_templateStart}."\n" if defined($self->{_templateStart});
	print "Temp  Stop  : ".$self->{_templateStop}."\n" if defined($self->{_templateStop});
	print "Temp  Cons  : ".$self->{_templateConsensus}."\n" if defined($self->{_templateConsensus});
	print "Temp  Dssp  : ".$self->{_template_ss_dssp}."\n" if defined($self->{_template_ss_dssp});
	print "Temp  Pred  : ".$self->{_template_ss_pred}."\n" if defined($self->{_template_ss_pred});
	print "Obj  Valid  : ".$self->isValid()."\n\n";

}






package HHRParser;

my $usage = "Parse HHR Input File
Usage  : hhrparser.pl -i <input.hhr> 

Options:

       -i	<input.hhr>		hhr file generated by HHpred / HHBlits
      [-v]	<int>			verbose  0 = silent, 1 = verbose, 2 = debug, 3 = show Query Information, 4 = show template Information
      [-nc]	<int>			name field cutoff default length = 30
      [-a ] <int>           Use alignment data as master 1 = start, stop is consensus 
\n";

# Global variable declaration
my $options;
my $inputfile;
my $v = 0;					# Set Verbose mode 0 = nothing, 1 = verbose, 2 = debug 
my $name_cutoff = 50;
my %alignmentContainer =();


# TO DO --- Move the general Calls to the end of the File


############################################################################
# Initialize the HHR Parser 
# 
# 
############################################################################
sub new {
	my $invocant = shift;
	my $class =ref($invocant) || $invocant;
	my $self = {
        _class => $class,

	};
	bless($self, $class);
	
	# Extract all information and store it
	&ParseData();
	# Test the parsed data for consistency
	&TestData();
	
	# If everything worked out return HHRParser object
	return $self;
}

# Processing command line options
if (@ARGV<1) {die $usage;}
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}


# Set options
if ($options=~s/ -hhr\s+(\S+) / /g)		{$inputfile=$1;}
if ($options=~s/ -v\s+(\d+) / /g)		{$v=$1;}
if ($options=~s/ -nc\s+(\d+) / /g)		{$name_cutoff=$1;}


#######################################################################
# Load and Parse the hhr data 
#
# Extracts each Alignment and sends it for processing to extractData
#
#
#######################################################################
sub ParseData(){
	if($v>1){print "Parsing HHR Data\n";}
	
# Declare local Variables	
	my $line;							# Stores each line from the hhr File 
	my $query_name;
	# For the parser to work properly, a well defined query name is needed of the length 15
	my $query_name_parser;
	my $template_name;
	# For the parser to work properly, a well defined temp name is needed of the length  8
	my $template_name_parser ="";
	# Store the alignment for processing 
	my $alingment_raw_data ="";
	
	 # Read the complete .hhr file and split on each alignment 
	 open (INFILE, "<$inputfile") || die "Error loading query Data: Couldn't open $inputfile: $!\n";	 	
		 	while ($line=<INFILE>) {
		 		# First Line is always the Query Name, strip whitespaces as well
		 		if ($line=~ /^Query\s+(.*)/){
		 			$query_name= substr($1,0,$name_cutoff);
		 			$query_name_parser =substr($1,0,14);	 			
		 		}
		 		
		 		if ($line=~ /No (\d+)/){
		 			
		 			if($1 != 1){
		 				# Extract all information of alignment and save it in an Alignment object4
		 				extractAlignment($alingment_raw_data, $query_name);
		 			}
		 			$alingment_raw_data ="";

		 		}
		 			$alingment_raw_data .= $line;


		 		
		 	}
     close (INFILE);
     # Run ExtractData for a last time to get the last alignment
     extractAlignment($alingment_raw_data, $query_name);


}

#####
# Extract all the data for one alignment and push it into the Alignment Container
#
#
# @input : The data for one Alignment
#####
sub extractAlignment(){
	
	# Init Local Vars
	my $data = $_[0];  									# The input string with the alignment
	my $query_name = $_[1];     						# The query sequence name 
	my $query_name_parser =substr($query_name,0,14);	# The query name substring used in the parser
	my $template_name ="";       						# The template sequence name 
	my $template_name_parser ="";						# The template name substring used in the parser
	
	# Alignment data
	my $align_qstart = 100000;							# Postition where Alignment starts in Query sequence (set on first occurence)
	my $align_qstop  = -1;								# Position where Alignment ends in Query sequence    (set on last occurrence)
	my $align_qseq   = "";								# The complete multiline s; Validity tested by length = $align_stop - $align_start -gaps
	my $q_consensus  = "";								# The consensus structure prediction Sequence 
	
	my $align_tstart = 100000;							# Postition where Alignment starts in Template sequence (set on first occurence)
	my $align_tstop  = -1;								# Position where Alignment ends in Template sequence    (set on last occurrence)
	my $align_tseq   = "";								# The complete multiline Template; Validity tested by length = $align_stop - $align_start - gaps 
	my $t_consensus  = "";								# The consensus structure prediction Sequence 
	
	
	my @data_array = split(/\n/, $data);  				# Split the input String on each newline for processing
	

	# Extract Alignment Number
	$data_array[0]=~ /No (\d+)/;
	my $alignment_id = $1; 
 	
 	if ($alignment_id ==66){
		print "Alignment nr : ".$alignment_id."\n";
		print $data."\n";
		
 	
 	}
	
	# Extract data from local Alignment 
	for(my $i =0;$i<@data_array;$i++){
		# perform all String operations on this string 
		my $local_line = $data_array[$i];  
        # Extract Template Name
		if ($local_line=~ /^>.*/){
		
		 			$template_name = substr($local_line, 0, $name_cutoff ); 
		 			$template_name_parser =substr($template_name,1,7);
		 		}
		# Extract Query Data 		
	
		my $query_name_parser_local = $query_name_parser;
		$query_name_parser_local =~ s/\|/\\|/g;
	
		
		if ($local_line =~ /^Q $query_name_parser_local/){  
				if ($local_line=~/(.*)\s+(.*)\s+(\d+)\s+(\D*)\s+(\d+)/) {		
				# $3 = Start of Alignment (needs only to be set in first line)
		 		# $4 = The Sequence from hhr (has to be concated for each line)
		 		# $5 = End of the Alignment, has to be set on the last line
				if($align_qstart > $3){
					$align_qstart = $3;
				}
				if($align_qstop <= $5){
					$align_qstop =$5;
				}
				my $tmp_qseq = $4;
				$tmp_qseq =~ s/^\s+//; #remove leading spaces
			 	$tmp_qseq  =~ s/\s+$//; #remove trailing spaces
				$align_qseq .= $tmp_qseq;	
				
				}
		
		}
 		# Q Consensus line match 
 		if($local_line=~ /^Q Consensus/){ 
 			if ($local_line=~/(\d+)\s+(\D*)\s+(\d+)/) {
 				my $q_Consensus_local = $2;
 				$q_Consensus_local =~ s/^\s+//; #remove leading spaces
 			   	$q_Consensus_local =~ s/\s+$//; #remove trailing spaces
				$q_consensus .= $q_Consensus_local;
 			}

 		}	
		#### End extract QUERY Data  #####
		
		# Extract Template Data 		
		# Extract the subset data (multiline)
		if ($local_line =~  /^T (.*)/) {
			print "L515 ".$local_line."\n";
			
		#### Start PFAM BLOCK
		my $template_name_parser_local = $template_name_parser;
		if($template_name_parser =~ /PF.*/){			
			$template_name_parser_local = $template_name_parser."_consen";
		}
		
		if ($local_line =~ /^T $template_name_parser_local (.*)/){  
				if ($local_line=~/(.*)\s+(.*)\s+(\d+)\s+(\D*)\s+(\d+)/) {
				
				# $3 = Start of Alignment (needs only to be set in first line)
		 		# $4 = The Sequence from hhr (has to be concated for each line)
		 		# $5 = End of the Alignment, has to be set on the last line
				if($align_tstart > $3){
					$align_tstart = $3;
				}
				if($align_tstop <= $5){
					$align_tstop =$5;
				}
				my $tmp_tseq = $4;
				$tmp_tseq =~ s/^\s+//; #remove leading spaces
			 	$tmp_tseq  =~ s/\s+$//; #remove trailing spaces
				$align_tseq .= $tmp_tseq;	
				}
			}
		}
	 	# T Consensus line match 
 		#if($local_line=~ /^T Consensus/){ 
 			if ($local_line=~/^T Consensus\s+(\d+)\s+(\D*)\s+(\d+)/) {
 				my $t_Consensus_local = $2;
 				$t_Consensus_local =~ s/^\s+//; #remove leading spaces
 			   	$t_Consensus_local =~ s/\s+$//; #remove trailing spaces
				$t_consensus .= $t_Consensus_local;
 			}

 		#}	
	
		
	}

	
	# Create new Alignment Container
	$alignmentContainer{$alignment_id} = new AlignmentObject();
	$alignmentContainer{$alignment_id}->setQueryName($query_name)  ;
	$alignmentContainer{$alignment_id}->setTemplateName("> ".$alignment_id."_".$template_name);
	$alignmentContainer{$alignment_id}->setQueryStart($align_qstart);
	$alignmentContainer{$alignment_id}->setQueryStop($align_qstop);
	$alignmentContainer{$alignment_id}->setQuerySequence($align_qseq);
	$alignmentContainer{$alignment_id}->setQueryConsensus($q_consensus);
	$alignmentContainer{$alignment_id}->setTemplateStart($align_tstart);
	$alignmentContainer{$alignment_id}->setTemplateStop($align_tstop);
	$alignmentContainer{$alignment_id}->setTemplateSequence($align_tseq);
	$alignmentContainer{$alignment_id}->setTemplateConsensus($t_consensus);

	$alignmentContainer{$alignment_id}->describe();

	if ($alignmentContainer{$alignment_id}->isValid()== 2){
		exit;
	}
		
}


###########################################################################
# Test if the parsed Data has been processed correctly
#
###########################################################################
sub TestData(){
	
	my $validation_counter = 0;
	my $alignment_elements;
	# Have all Files of your Dataset been parsed ?
	$alignment_elements = keys( %alignmentContainer);
	print "Parsed Elements:  " .$alignment_elements. "\n";
	# Have all of them been correctly Validated
	while ( my ($key, $alignmentOj) = each(%alignmentContainer) ) {
        $validation_counter = $validation_counter +$alignmentOj->isValid();
        if ($alignmentOj->isValid() != 1){
        	$alignmentOj->describe();
        }
    }
	 print "_> ".$validation_counter."\n";
	 if ($validation_counter == $alignment_elements){
	 	print "Alignments Parsed Correctly\n ";
	 }else{
	 	print "ERROR: Alignment not parsed Correctly";
	 }	
}

#############################################################################
# Retrieve the processed alignment data from HHRParser
#
#############################################################################
sub getAlignmentContainer(){
	
	return %alignmentContainer;
}

1;