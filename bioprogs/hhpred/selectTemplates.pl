#!/usr/bin/perl -w

# read all matches in hhsearch results file
# do filtering and ranking procedure
# output: filtered hhr-file (contains all filtered hits ranked by a predicted TM-Score)		  

my $rootdir;
BEGIN {
    if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} else {$rootdir="/cluster";}
};
use lib "$rootdir/bioprogs/hhpred";
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm

use strict;
use MyPaths;                         # config file with path variables for nr, blast, psipred, pdb, dssp etc.

# Default values
our $v=0; # verbose mode
my $cpus=4;
my $options = "-mact 0.01";			# do not use anything that changes the calibration under default conditions
my $pdbdir  = (glob "$newdbs/pdb*")[0];    	# PDB database with HMMs
my @scopdirs = (glob "$newdbs/{scop,SCOPe}*");   	# SCOP database with HMMs
my $pdb_on_hold_dir = (glob "$newdbs/pdb_on_hold*")[0];    	# PDB database with HMMs


my $usage="\nRead all matches in an hhsearch results file, do filtering and ranking procedure\nOutput: hhr-file containing all filtered hits ranked by a predicted TM-score + optimal templates

Usage: selectTemplates.pl -i <basename>  -o <basename> [options] 
  -i <basename>         basename for all input files (a3m and hhm file of query, hhr results file)  
  -o <basename>         basename for all output files (a3m and hhm files of all nodes, hhr results file)
  -mode	<s/m>		s: singel template modeling, m: multiple template modeling (default=m)
  -v <int>              verbose mode (0: no output, 1: minimal output, 2,3..: verbose) (default=$v)
  -d <pdbdirs>         	directory containing pdb files (for PDB, SCOP, or DALI sequences) (default=/cluster/databases/pdb/all) 
\n";

# Variable declaration
my $inbase;             # base name of input files (a3m, hmm, hhr)
my $outbase;            # output basename
my $outroot;            # output rootname
my $outdir;             # directory of output basename (storage of all output files)
my $mode = "m";		# s: singel template modeling, m: multiple template modeling (if available) (default=s)


#################################
# Processing command line input #
#################################
if (@ARGV<1) {die ($usage);}
my $inputoptions="";
for (my $i=0; $i<@ARGV; $i++) {$inputoptions.=" $ARGV[$i] ";}

# General options
if ($inputoptions=~s/ -v\s*(\d) / /) {$v=$1;}
if ($inputoptions=~s/ -v / /) {$v=2;}
if ($v>=3) {print("$0 $inputoptions\n");}

if ($inputoptions=~s/ -i\s+(\S+) //) {$inbase=$1;}
if ($inputoptions=~s/ -o\s+(\S+) //) {$outbase=$1;}
if ($inputoptions=~s/ -mode\s+(m|s) / /) {$mode=$1;}
if ($inputoptions=~s/ -d\s+(\S+) //) {$pdbdir=$1;}

# Warn if unknown options found
while ($inputoptions=~s/\s*(\S.*)//) {print("WARNING: unknown inputoptions $1\n");}
if (!defined $inbase)  {die("Error: not input base name given\n");}
if (!defined $outbase) {die("Error: not output base name given\n");}
if ($outbase=~/^(.*?)\/([^\/]*)$/) {$outdir=$1; $outroot=$2} else {$outdir="."; $outroot=$outbase;}

my $a3mfile = "$inbase.a3m";			# a3m file (in order to filter alignment)
my $hhmfile = "$inbase.hhm";			# hmm file 
my $hhrfile = "$inbase.hhr";			# hhr file 

if (!-e $a3mfile) {die("Error: no a3m file given!\n");}
if (!-e $hhmfile) {&System("$hh/hhmake -i $a3mfile -diff 100 -o $hhmfile -v $v");}
if (!-e $hhrfile) {die("Error: no hhr file given!\n");}
if (!-d $pdbdir) {die("Error: wrong directory (containing pdb files) given!\n");}


################
# MAIN PROGRAM #
################


#build HHR file containing ONLY!!! PDB or SCOP Hits
my @prediction = &CreateInfoArray("$hhrfile");
my @alignment_lines=();
my $hitnr = 1;
open (HHR,">$outbase.usedhhr") or die ("Error: cannot open $outbase.usedhhr\n");
for (my $v=0; $v<@prediction; $v++){
		
	open (IN, "<$hhrfile") or die ("Error: cannot open $hhrfile!\n");
	my $check=0;
	my $begin;
	my $e=0;
	my $end;							
	my $line;	
	while ($line = <IN>){				
	      #copy first lines:
	      if (($line !~ /^\s*\d+\s+\S+.+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$/) && ($check==0) && ($v==0)){
		      print (HHR "$line");
	      }				
	      else {$check=1;}
		      
	      #get hit Info:
	      #check if hit is in PDB or SCOPE:	1 2jp9_A Wilms tumor 1; DNA bind 100.0 1.1E-34 7.4E-36  168.3   0.3   90    1-90      3-94  (119)
	      if ($line =~ /^\s*$prediction[$v][1]\s+(\d[a-z0-9]{3}_?[A-Za-z0-9]?\s+.+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$)/){
			$line = sprintf("%3s $1\n",$hitnr);	
			print (HHR "$line");
			$e=1;
			last;
	      }		      
	      if ($line =~ /^\s*$prediction[$v][1]\s+([defgh]\d[a-z0-9]{3}[a-z0-9_\.][a-z0-9_]\s+.+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$)/){
			$line = sprintf("%3s $1\n",$hitnr);	
			print (HHR "$line");
			$e=1;
			last;
	      }	
	}
	if ($e==1){	  
	      # Find beginning of alignment end replace hit index by new one
	      while ($line = <IN>){ if($line=~/^No\s+$prediction[$v][1]/) {last;}} # skip all lines up to alignment block
	      #print("Line with No : $line");
	      $line =~s/^No\s+\d+/No $hitnr/;
	      push(@alignment_lines,$line);
      
	      # Push alignment block onto array				
	      while ($line = <IN>){
	      if($line=~/^No\s/) {last;}
		push(@alignment_lines,$line);
	      }
	      $hitnr++;
	}	
	close (IN);						
}
print(HHR "\n");
print(HHR @alignment_lines);
print(HHR "Done!\n");
close (HHR);	

system ("cp  $outbase.usedhhr $outbase.hhr"); 
#FILTERING (all steps)
@prediction = &Filtering("$outbase.hhr");

#RANKING (Neural Network):
@prediction = &PredTMscore(@prediction);

my $optimalTemplates;
if ($mode eq "s"){$optimalTemplates = &searchDOMAINS_buildHHR(@prediction);}		
if ($mode eq "m"){$optimalTemplates = &selectMultiTemplates(@prediction);}

#system("perl $hh/hhmakemodel.pl $outbase.tmp.hhr -m $optimalTemplates -q $a3mfile -v 2 -pir $outbase.pir -d $pdbdir");

system ("rm $outdir/*.filt.*");
system ("rm $outbase.*.hhr");
exit;


###########
# METHODS #
###########
sub Filtering{
	my $hhrfile=$_[0];	#hhr file	
	my $qscmax=0;		#-qsc (max similarity)
	my $HITS=20;		#number of hits to be filtered
	my %bestscores;		#hash with raw scores for each hit (in order to update SCOREs correctly)	
	my $MAXOVLAP=20; 	#maximum allowable overlap to treat same templatehits independently

	#get array with feature information:
	my @orgprediction = &CreateInfoArray("$hhrfile");	
	#array contains:HHR HIT TEMPLATE PROB RAWSCORE SS/Length SIM SumProb/Length QUERYSTART QUERYEND COLS TEMPLATESTART TEMPLATEEND	
	#             	0   1   2        3    4        5         6   7		    8          9        10   11		   12
	
	print "\nFILTERING:\n\n";		
	my @hits = ();	#array with hits 
	my $db = "";	#contains hhms of templates (for filtering)
	my $temps = ""; #contains a3ms of templates (for filtering)
	foreach my $c (@orgprediction){
		#hit belongs to hits 1-$HITS
		if (@{$c}[1]<=$HITS){
			my $hhm = "$outdir/@{$c}[2].filt.hhm";
			if ($db !~ /$hhm/){	#check for double entries!
				$db .= "$hhm ";	
				$temps .=  "$outdir/@{$c}[2].filt.a3m ";			
				my $command = "";
				if (-e "$pdbdir/@{$c}[2].a3m") { 
				    $command = "cp $pdbdir/@{$c}[2].a3m $outdir/@{$c}[2].filt.a3m";
				} elsif (-e "$pdb_on_hold_dir/@{$c}[2].a3m") { 
				    $command = "cp $pdb_on_hold_dir/@{$c}[2].a3m $outdir/@{$c}[2].filt.a3m";
				} else {
				    foreach my $dir (@scopdirs) {
					if (-e "$dir/@{$c}[2].a3m") {
					    $command = "cp $dir/@{$c}[2].a3m $outdir/@{$c}[2].filt.a3m";
					}
				    }
				}
				if ($command ne "") {
				    &System($command);
				} else {
				    die("Error: no a3m in database given!\n");
				} 
				push (@hits,@{$c}[2]);									   
			}	
		}		
	}	
	#############
	#filtersteps:
	#############	
	&System("cp $a3mfile $outbase.filt.a3m");
	my @prediction="";
	my $hhrnr = 0;			
	for (my $qsc=0;$qsc<$qscmax+0.1;$qsc+=0.1)	
	{
		#if there are hits (more then 80% probability):
		if (@hits>0){		
			#filter all hits with prob>= 80% from previous search with "-qsc $qsc"
			
			#multithread.pl: Call a program multiple times with different files as arguments and process in parallel 
			print "\nFILTER TEMPLATES with -qsc $qsc\n";
			
			system("$hh/multithread.pl '$temps' '$hh/hhfilter -i \$file -id 100 -diff 0 -qsc $qsc -o \$file -v $v' -cpu 4 > /dev/null 2>&1");
			system("$hh/multithread.pl '$temps' '$hh/hhmake -i \$file -diff 100 -o \$base.hhm -v $v' -cpu 4 > /dev/null 2>&1");
			
			#filter query:
			print "FILTER QUERY  with -qsc $qsc\n";
			system("$hh/hhfilter -i $outbase.filt.a3m -id 100 -diff 0 -qsc  $qsc -o $outbase.filt.a3m -v $v > /dev/null 2>&1");
			system("$hh/hhmake -i $outbase.filt.a3m -diff 100 -o $outbase.filt.hhm -v $v > /dev/null 2>&1");
	    	
			#hhsearch:
			print "SEARCH IN FILTERED HMMs\n";
			system("$hh/hhsearch -cpu $cpus -i $outbase.filt.hhm -d $calhhm -o $outbase.cal.hhr -cal $options  -Z $HITS -B $HITS -v $v");
			system("$hh/hhsearch -cpu $cpus -i $outbase.filt.hhm -d \"$db\" -o $outbase.$hhrnr.hhr $options -Z $HITS -B $HITS -v $v");
			print "\n";			
	
			if($hhrnr == 0){
				@prediction = &CreateInfoArray("$outbase.$hhrnr.hhr");	
				@hits=();
				$db="";
				$temps="";  
				####################
				#search for -qsc max	
				####################
				foreach my $c (@prediction){if (@{$c}[6]>$qscmax) {$qscmax = @{$c}[6];}}#print "$qscmax\n";

				##########################################################################
				#get hash with raw scores of each hit (for SCORE UPDATES) & SumProb/Length 	
				##########################################################################
				foreach my $c (@prediction){
					#print "HIT:\t"; foreach my $d (@{$c}){print "$d\t";} print "\n";
					  
					#new template:
					if (! $bestscores{@{$c}[2]}){
						#print "push: @{$c}[8]	@{$c}[9]	@{$c}[4]	@{$c}[7]\n";			
						push (@{$bestscores{@{$c}[2]}}, [@{$c}[8],@{$c}[9],@{$c}[4],@{$c}[7]]); 	#array of arrays: key=TEMPLATE -> values= QUERYSTART,QUERYEND,RAWSCORE,SumProb/Length
					}
					#template exists already: check if independence one		
					else {
						#print "check:	$bestscores{@{$c}[2]}[0][0] & @{$c}[8]	$bestscores{@{$c}[2]}[0][1] & @{$c}[9]	$bestscores{@{$c}[2]}[0][2] & @{$c}[4]		$bestscores{@{$c}[2]}[0][3] & @{$c}[7]\n";	
						#                    existing start           new start      existing end             new end           existing score       new score  	   existing SumProbs/Length     new one
									
						if ($bestscores{@{$c}[2]}[0][0] < @{$c}[8]) {					#existing template "in front of" new one
							if (($bestscores{@{$c}[2]}[0][1]-@{$c}[8])<=$MAXOVLAP){			#overlap <= 20 residues
								#print "own template\n";
								#push to key -> additional array
								push (@{$bestscores{@{$c}[2]}}, [@{$c}[8],@{$c}[9],@{$c}[4],@{$c}[7]]);					
							} 
							else{
								if ($bestscores{@{$c}[2]}[0][2]< @{$c}[4]){			#if existing score is smaller than the score of another part of the query-template alignment: update it
									$bestscores{@{$c}[2]}[0][2] = @{$c}[4];
								}					
							}
						}		
						else {										#existing template "behind" 
							if ((@{$c}[9]-$bestscores{@{$c}[2]}[0][0])<=$MAXOVLAP){			#overlap <= 20 residues
								#print "own template\n";
								#push to key -> additional array
								push (@{$bestscores{@{$c}[2]}}, [@{$c}[8],@{$c}[9],@{$c}[4],@{$c}[7]]);		
							}
							else{
								if ($bestscores{@{$c}[2]}[0][2]< @{$c}[4]){			#if existing score is smaller than the score of another part of the query-template alignment		: update it
									$bestscores{@{$c}[2]}[0][2] = @{$c}[4];
								}					
							} 
						}																
					}

		  			#HITS#################################################################	
					if (@{$c}[3]>=80){	
						my $hhm = "$outdir/@{$c}[2].filt.hhm";					
						if ($db !~ /$hhm/){								#check for double entries!
							$db .= "$hhm ";	
							$temps .=  "$outdir/@{$c}[2].filt.a3m ";
							push (@hits,@{$c}[2]);									   
						}	
					}
				}
				#for my $hit (keys %bestscores) {foreach my $c (@{$bestscores{$hit}}){print "%BESTSCORES	$hit: @{$c}[0]	@{$c}[1]	@{$c}[2]	@{$c}[3]\n";}}
			}
			else{	
				my @pred = &CreateInfoArray("$outbase.$hhrnr.hhr");	
				###########################################
				#update rawscores & SumProbs/Length & @hits 
				###########################################
				@hits=();
				$db="";
				$temps="";
				foreach my $c (@pred){
					#print "HITS:\t"; foreach my $d (@{$c}){print "$d\t";} print "\n";	    			  
					
					#my $filtercheck =0;	    			    		    		
					#SCORES & SumProbs/Length############################################check for each possible appearances of a template
					my $difference = 1000;
					my $chooseScore;	
					my $templ=-1;
					my $choostempl; 									#to distinguish between "same" or "different" covered part of query			
					foreach my $e (@{$bestscores{@{$c}[2]}}){
						$templ++;
						#                   existing start    		 existing end            existing score	   sumProbsOLD sumProbsNEW
						#print "check:   @{$e}[0] & @{$c}[8]	       @{$e}[1] & @{$c}[9]	  @{$e}[2] & @{$c}[4]	@{$e}[3] & @{$c}[7]\n";	    			
						
						my $startdifference = abs(@{$e}[0]-@{$c}[8]);					#difference between start of observed and start of actual queryalignmentpositon 
						#score belongs to template with smallest difference between startpositions
						if ($startdifference<$difference){
							$chooseScore=@{$e}[2];
							$choostempl=$templ;
							$difference=$startdifference;	    				 				
						}	
					}
					if ($chooseScore< @{$c}[4]){								#if existing score is smaller than the filtered score: update it					
							$bestscores{@{$c}[2]}[$choostempl][2] = @{$c}[4];			#update scores in  %bestscores					
					}								
					#HITS#################################################################	    					
					if (@{$c}[3]>=80){	
						my $hhm = "$outdir/@{$c}[2].filt.hhm";					
						if ($db !~ /$hhm/){							#check for double entries!
							$db .= "$hhm ";	
							$temps .=  "$outdir/@{$c}[2].filt.a3m ";
							push (@hits,@{$c}[2]);									   
						}	
					}				
				}
				push (@prediction, @pred);
			}				
		}
		$hhrnr++;
	}	
	#update rawscores in array with all possible templates########################################################################
	#for my $hit (keys %bestscores) {foreach my $c (@{$bestscores{$hit}}){print "$hit: @{$c}[0]	@{$c}[1]	@{$c}[2]\n";}}	

	foreach my $c (@prediction){
		#print "Pred:\t"; foreach my $d (@{$c}){print "$d\t";} print "\n";
		my $difference = 1000;	
		my $templ=-1;
		my $choostempl;		
		foreach my $e (@{$bestscores{@{$c}[2]}}){
			$templ++;
			my $startdifference = abs(@{$e}[0]-@{$c}[8]);					#difference between start of observed and start of actual queryalignmentpositon 
	    	if ($startdifference<$difference){$choostempl=$templ;$difference=$startdifference;}	#score belongs to template with smallest difference between startpositions
		}		
		@{$c}[4] = $bestscores{@{$c}[2]}[$choostempl][2];					#update scores in @prediction								
	}	
		
	return @prediction;	
}

sub CreateInfoArray{
	#method constructs from input hhr-file an array of: 
	#HHR-file-number, HIT in hitlist, TEMPLATE name, PROBability, RAWSCORE, SS/Length, SIMilarity, SumProb/Length, QUERYSTART, QUERYEND, aligned COLS, TEMPLATESTART, TEMPLATEEND
	my $hhrfile=$_[0];
	my $hhrnr="XXX";
	if ($hhrfile=~/$outbase\.(\S+)\.hhr/){
		$hhrnr=$1;
	}
	#print "$hhrnr\n";	
	my @prediction;		
		
		# No Hit                             Prob E-value P-value  Score    SS Cols Query HMM  Template HMM
	  	#  1 1x9n_A DNA ligase I; DNA ligas 100.0       0       0  421.8  27.9  310    1-348   305-648 (688)
	  	#  ...
	  	#No 1  
		#>1x9n_A DNA ligase I; ...
		#Probab=100.00  E-value=0  Score=421.83  Aligned_cols=310  Identities=19%  Similarity=0.217  Sum_probs=236.0
		#...
	
	#get values			
	my $matchC;		#querylength
	my $hit;		#emplateindex
	my $prob;		#probability
	my $template;		#templatename
	my $score;		#raw score
	my $SSL;		#SS-Score/Querylength
	my $simil;		#similarity
	my $SumProbL;		#SumProbs/Querylength	
	my @cols;		#aligned residues
	my @aliquerystart;	
	my @aliqueryend;
	my @tempstart;
	my @tempend;
	
	open(HHR,"<$hhrfile") || die("Error in file: $hhrfile\n");
	while (my $line = <HHR>){		
		if ($line=~/^Match_columns\s*(\S+)/) {$matchC = $1;}
					   #     No     Hit       Prob E-val  P-val  Score    SS      Cols  Query(start end) Template HMM
					   #      1      2         3                   4       5       6       7     8       9     10
		elsif ($line=~/^\s*(\d+)\s+(\S+).+\s+(\S+)\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)-(\d+)\s+(\d+)-(\d+)\s*\(\S+\)$/){	
		    $hit = $1;
		    $template = $2; 
		    $prob = $3;	    			
		    $score = $4;   
		    $SSL = $5/$matchC; $SSL = sprintf("%.4f" , $SSL);
		    push (@cols, $6);
		    push (@aliquerystart, $7);
		    push (@aliqueryend, $8);    
		    push (@tempstart, $9);
		    push (@tempend, $10); 		    
		    #print ("$matchC	$hit	$template	$score	$SSL	$aliquery\n");		    
		    push (@prediction, [$hhrnr,$hit,$template,$prob,$score,$SSL]);		        		      															
		}
		elsif($line =~ /^No (\d+)/){
			$hit = $1;			
		    $line=<HHR>;
		    if ($line!~/^>(\S+)\s/) {die("Error: wrong format in $line \n");}
		    $template = $1;
		    $line=<HHR>;
		    if ($line!~/Similarity=(\S+)\s+Sum_probs=(\S+)\s/) {die("Error: wrong format in $line \n");}	    
		    $simil = $1;
		    $SumProbL = $2/$matchC;
		    $SumProbL = sprintf("%.4f" , $SumProbL);	    
		    #print ("$matchC	$hit	$template	$simil	$SumProbL\n");		    	
		    push (@{$prediction[$hit-1]}, $simil,$SumProbL);   
		    											
		}				
	}	
	close(HHR);
	my $i=-1;
	foreach my $c (@prediction){
		$i++;
		push (@{$c}, $aliquerystart[$i], $aliqueryend[$i], $cols[$i], $tempstart[$i], $tempend[$i]);			
	}	
	return @prediction;		
}

sub PredTMscore{
	my @prediction=@_;
		
	my $NN = 1;
	#predict TM Scores with AMOEBA:
	if ($NN == 0){
		my @predictionparams = (0.677  ,0.003  ,0.657  ,2.794  ,8.692  ,-1.238 ,0.174);	
		                       # a0       a1      b0      b1      b2       c0     c1 
		my $tmscore = 0;	
		my $i=-1;
		foreach my $c (@prediction){
			$i++;
			#print "Pred:\t"; foreach my $d (@{$c}){print "$d\t";} print "\n";		
			
			#array contains: HHR  HIT  TEMPLATE  PROB   RAWSCORE  SS/Length  SIM   SumProb/Length QUERYSTART   QUERYEND   COLS  TEMPLATESTART   TEMPLATEEND	
								
			my $x1 = $predictionparams[0] + $predictionparams[1]*@{$c}[4];
			my $x2 = $predictionparams[2] + $predictionparams[3]*(@{$c}[7]-0.5) + $predictionparams[4]*(@{$c}[5]-0.0714);				
			my $x3 = $predictionparams[5] + $predictionparams[6]*@{$c}[4];
			
			my $tmscore = 1.0/(1.0+exp(-$x1)) * 1.0/(1.0+exp(-$x2)) * 1.0/(1.0+exp(-$x3));	
			$tmscore = sprintf("%.6f", 	$tmscore);			
			push (@{$c}, $tmscore)	
		}
	}	
	#predict TM-score with Neural Network	
	elsif ($NN == 1){		
		#RAWSCORE/50 -> normalized!!!		
		my $hidden = 3; 
		my @bias = (0.00242, 1.25840, 0.21822);#bias of hidden units! 
		my @weights = (-0.06255, -3.10914, -1.45941, -1.49997, 0.09633, -0.94335, 1.90401,  0.11515, -0.78965, -2.20885, 0.68521, 0.98681); 
			 
		foreach my $c (@prediction){
			my $tmscore = 0;		
			for (my $unit = 0; $unit<$hidden; $unit++){
				#calculate input of hidden unit (sum of all inputs * weights)
				my $input = (@{$c}[4]/50) * $weights[0 + $unit * 3] + @{$c}[5] * $weights[1 + $unit * 3] + @{$c}[7] * $weights[2 + $unit * 3];
				#calculate output of hidden unit
				my $output = 1 / (1 + exp(-($input + $bias[$unit])));			
				$tmscore += $output * $weights[ $hidden*3 + $unit];	
			}		
			$tmscore = sprintf("%.6f", 	$tmscore);			
			push (@{$c}, $tmscore)		
		}		
	} 	
	
	#sort by TMscore:	
	@prediction = sort { $a->[13] <=> $b->[13] } @prediction;
	@prediction = reverse(@prediction);		
	
	print"HHR   HIT   TEMPLATE   PROB   SCORE   SS/Length   SIM   SumPr/L	QueryStart-End	COLS	TempStart-End	TMSCORE\n";
	foreach my $c (@prediction){foreach my $d (@{$c}){print "$d\t";} print "\n";}		
	return @prediction;	#HHR   HIT   TEMPLATE   PROB   RAWSCORE   SS/Length   SIM   SumProb/Length QUERYSTART   QUERYEND   COLS	  TEMPLATESTART   TEMPLATEEND	TMSCORE	
}

sub searchDOMAINS_buildHHR{
	my @prediction=@_;	#list contains ranked HITS
		
	open (ALLHITS,">$outbase.afh") or die ("Error: cannot open $outbase.afh\n"); #file contains all filtered hits ranked by TM-Score	
	print (ALLHITS "HHR   HIT   TEMPLATE   PROB   SCORE   SS/Length   SIM   SumPr/L	QueryStart-End	COLS	TempStart-End	TMSCORE\n");
	foreach my $c (@prediction){foreach my $d (@{$c}){print (ALLHITS "$d\t");} print (ALLHITS "\n");}	

	#foreach my $c (@prediction){print "Pred:\t"; foreach my $d (@{$c}){print "$d\t";} print "\n";}
	
	my @selectedHITs; 	#list of selected Hits for final hhr file (which contains all filtered hits ranked by tm-score)
	my @alignment_lines =();#content of final hhr file
	open (HHR,">$outbase.hhr") or die ("Error: cannot open $outbase.hhr\n");
	###############################
	#search for DOMAINS in hitlist:	
	###############################
	my $MAXOVLAP=20;   	#maximum allowable overlap with previously accepted matches
	my $MINDOMLEN=40;  	#minimum length of match not overlapping with previous matches
	my $MINPROB=10;    	#minimum probability for further domains to be modelled
	my @aligned;
	my $d=1;		#domain nr.	
	for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}	
	for (my $v=0; $v<@prediction; $v++){
		#             HHR	                HIT	             TEMPLATE              PROB	           RAWSCORE              SS/Length             SIM	          SumProb/Length	    QUERYSTART          QUERYEND		      COLS			    TEMPLATESTART      TEMPLATEEND			   TMSCORE            
		#print "$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11] $prediction[$v][12] $prediction[$v][13]\n";
		my $first=$prediction[$v][8];
		my $last=$prediction[$v][9];
		
		#initialisation
		if ($v==0){
			push(@selectedHITs,($v+1));
			print "\nSINGLE TEMPLATE:\n$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11]	$prediction[$v][12]	$prediction[$v][13]\n";
			print (ALLHITS "\nSINGLE TEMPLATE:\n$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11]	$prediction[$v][12]	$prediction[$v][13]\n");
			for (my $i=$first; $i<=$last; $i++) {$aligned[$i]=1}
		}
		if ($prediction[$v][3]>=$MINPROB && $prediction[$v][10]>=$MINDOMLEN) {	#Probab>=10 && aligned columns >=40				
			my $overlap=0; 
			my $mlen=0;
			for (my $i=$first; $i<=$last; $i++) {
			    if ($aligned[$i]==1) {$overlap++;} else {$mlen++;}
			}
			if ($overlap>$MAXOVLAP) {next;}
			if ($mlen<$MINDOMLEN) {next;}
		
			for (my $i=$first; $i<=$last; $i++) {$aligned[$i]=1}
		
			push(@selectedHITs,($v+1));
			$d++;
			print "$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11]	$prediction[$v][12]	$prediction[$v][13]	\n";
			print (ALLHITS "$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11]	$prediction[$v][12]	$prediction[$v][13]\n");
		}
	}
	my $optimalTemplates;
	for (my $t=0; $t<@selectedHITs; $t++) {$optimalTemplates .= "$selectedHITs[$t]  ";}
	
	for (my $v=0; $v<@prediction; $v++){
		###############################################################
		#build HHR file containing all filtered Hits ranked by TM-score
		###############################################################
		open (IN, "<$outbase.$prediction[$v][0].hhr") or die ("Error: cannot open $outbase.$prediction[$v][0].hhr!\n");
		#print "$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]		$outbase.$prediction[$v][0].hhr\n";
		my $check=0;
		my $begin;
		my $e=0;
		my $end;							
		my $line;
		my $hitnr = $v+1;
		while ($line = <IN>){				
		#copy first lines:
		if (($line !~ /^\s*\d+\s+\S+.+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$/) && ($check==0) && ($v==0)){
			if ($line=~ /^Command/) {$line=~ s/(^Command\s*)(.*)$/$1$hh\/hhsearch artificial hhr file (containing all hits generated by a filtering procedure) optimal template(s): $optimalTemplates/;}
			if ($line=~ /\s+No\s+Hit\s+Prob\s+E-value\s+P-value\s+Score\s+SS\s+Cols\s+Query\s+HMM\s+Template\s+HMM\s+/) {
				#print $line;
				$line =~s/(\s*No\s+Hit\s+Prob\s+E-value\s+)(P-value)(\s+Score\s+SS\s+Cols\s+Query\s+HMM\s+Template\s+HMM\s+)/$1TMScore$3/;
			}	
			print (HHR "$line");				
		}				
		else {$check=1;}
		
		#get hit Info:
		if ($line =~ /^\s*$prediction[$v][1](\s+\S+.+\s+\S+\s+\S+)\s+\S+(\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$)/)	{
			#$line=~ s/(^\s*)($prediction[$v][1])(\s+\S+.+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$)/$1$hitnr$3/;
			$line = sprintf("%3s$1  %1.4f$2\n",$hitnr,$prediction[$v][13]);		
			print (HHR "$line");
			last;
			}
		}
		# Find beginning of alignment end replace hit index by new one
		while ($line = <IN>){ if($line=~/^No\s+$prediction[$v][1]/) {last;}} # skip all lines up to alignment block
		#print("Line with No : $line");
		$line =~s/^No\s+\d+/No $hitnr/;
		push(@alignment_lines,$line);

		#Push alignment block onto array				
		while ($line = <IN>){
		if(($line=~/^No\s/)) {last;}
			if ($line =~ /Done!/){}
			else {push(@alignment_lines,$line);}
		}	
		close (IN);						
	}
	print(HHR "\n");
	print(HHR @alignment_lines);
	print(HHR "Done!\n");
	close (HHR);	
	
	return $optimalTemplates;
}

sub selectMultiTemplates{
	my @prediction=@_;	#list contains ranked HITS		
	
	open (ALLHITS,">$outbase.afh") or die ("Error: cannot open $outbase.afh\n"); #file contains all filtered hits ranked by TM-Score	
	print (ALLHITS "HHR   HIT   TEMPLATE   PROB   SCORE   SS/Length   SIM   SumPr/L	QueryStart-End	COLS	TempStart-End	TMSCORE\n");
	foreach my $c (@prediction){foreach my $d (@{$c}){print (ALLHITS "$d\t");} print (ALLHITS "\n");}	
	
	#ranking - in ordert to obtain selected optimal templates in final artificial hhr.file (which contains all filtered hits ranked by tm-score)
	my $num=0;
	foreach my $c (@prediction){push (@{$c}, "$num");$num++;}
	my @selectedHITsSingleT;#list of selected single template(s) for final artificial hhr file   
	my @selectedHITs; 	#list of selected multiple template(s) (including single hits!!!) for final artificial hhr file 	
		
	###############################
	#search for DOMAINS in hitlist:	
	###############################	
	my $MAXOVLAP=20;   		#maximum allowable overlap with previously accepted matches
	my $MINDOMLEN=40;  		#minimum length of match not overlapping with previous matches
	my $MINPROB=10;    		#minimum probability for further domains to be modelled
	my @aligned;
	my @hhrHITS=();			#hits (hhrfile hit templatename)
	my $d=1;				#domain nr.	
	for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}	
	
	for (my $v=0; $v<@prediction; $v++){
		#HHR   HIT   TEMPLATE   PROB   RAWSCORE   SS/Length   SIM   SumProb/Length QUERYSTART   QUERYEND   COLS	  TEMPLATESTART   TEMPLATEEND	TMSCORE		ranking
		#print "$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11] $prediction[$v][12]	$prediction[$v][13]  $prediction[$v][14]\n";
		my $first=$prediction[$v][8];
		my $last=$prediction[$v][9];
		
		#initialisation
		if ($v==0){
			push(@selectedHITsSingleT,($v+1));
			push(@hhrHITS,[$prediction[$v][0],$prediction[$v][1],$prediction[$v][2],$prediction[$v][3],$prediction[$v][4],$prediction[$v][5],$prediction[$v][6],$prediction[$v][7],$prediction[$v][8],$prediction[$v][9],$prediction[$v][10],$prediction[$v][11],$prediction[$v][12],$prediction[$v][13],$prediction[$v][14]]);
			print "\nSINGLE TEMPLATE:\n$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11]	$prediction[$v][12]	$prediction[$v][13]	$prediction[$v][14]\n";
			for (my $i=$first; $i<=$last; $i++) {$aligned[$i]=1}
		}
		if ($prediction[$v][3]>=$MINPROB && $prediction[$v][10]>=$MINDOMLEN) {	#Probab>=10 && aligned columns >=40				
			my $overlap=0; 
			my $mlen=0;
			for (my $i=$first; $i<=$last; $i++) {
			    if ($aligned[$i]==1) {$overlap++;} else {$mlen++;}
			}
			if ($overlap>$MAXOVLAP) {next;}
			if ($mlen<$MINDOMLEN) {next;}
		
			for (my $i=$first; $i<=$last; $i++) {$aligned[$i]=1}

			push(@selectedHITsSingleT,($v+1));		
			push(@hhrHITS,[$prediction[$v][0],$prediction[$v][1],$prediction[$v][2],$prediction[$v][3],$prediction[$v][4],$prediction[$v][5],$prediction[$v][6],$prediction[$v][7],$prediction[$v][8],$prediction[$v][9],$prediction[$v][10],$prediction[$v][11],$prediction[$v][12],$prediction[$v][13],$prediction[$v][14]]);
			$d++;
			print "$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]	$prediction[$v][4]	$prediction[$v][5]	$prediction[$v][6]	$prediction[$v][7]	$prediction[$v][8]	$prediction[$v][9]	$prediction[$v][10]	$prediction[$v][11]	$prediction[$v][12]	$prediction[$v][13]	$prediction[$v][14]\n";
			}
	}		
					
	####################################################################################
	#foreach DOMAIN (selected as Template for Modeller) search for multiple Templates:##
	####################################################################################
	#HHR   HIT   TEMPLATE   PROB   RAWSCORE   SS/Length   SIM   SumProb/Length QUERYSTART   QUERYEND   COLS	  TEMPLATESTART   TEMPLATEEND	TMSCORE
	my @hhrmultiHITS=();	
	my @checkedTemplates=();
	
	for (my $h=0; $h<@hhrHITS; $h++){
		my $MULTIS=0;
		#Viterbi Score (local) / aligned Columns (mact)
		my $ScoreColsQ = $hhrHITS[$h][4] / $hhrHITS[$h][10];
		my $coverage = ($hhrHITS[$h][4]-$hhrHITS[$h][3])/2;			#50% of the alignment has to be covered!		
		my $TMminscore = $hhrHITS[$h][13]-0.2;
		print "SCORE/COL: $ScoreColsQ\n"; 
		for (my $v=0; $v<@prediction; $v++){
			if($MULTIS<5){	
						
				print"check $v: $prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]\t";
				#selfhit -> donttake!!!
					if (($hhrHITS[$h][0] eq $prediction[$v][0]) && ($hhrHITS[$h][1] ==$prediction[$v][1])){
						print"selfhit\n";
						push(@selectedHITs,($prediction[$v][14]+1));
						$MULTIS++;
						push(@hhrmultiHITS,[$prediction[$v][0],$prediction[$v][1],$prediction[$v][2],$prediction[$v][8],$prediction[$v][9],$prediction[$v][11],$prediction[$v][12],$prediction[$v][13]]);
					}			
				#other hits:
					else{	
						#print"check2\t";					
						my $positionsTbestQ = "$hhrHITS[$h][8] $hhrHITS[$h][9] $prediction[$v][8] $prediction[$v][9]"; #start end & start end	
						my $overlapTbestQ = &overlap($positionsTbestQ);	
						my $positionsTbestT = "$hhrHITS[$h][11] $hhrHITS[$h][12] $prediction[$v][11] $prediction[$v][12]"; #start end & start end	
						my $overlapTbestT = &overlap($positionsTbestT);	
						my $ScoreColsT = $prediction[$v][4]/$prediction[$v][10];			
						#print "$overlapTbestQ	$overlapTbestT	$ScoreColsT\n";					
						
						#same Template but different domains & score/cols >= score/cols from QandbestT
							if ($hhrHITS[$h][2] eq $prediction[$v][2]){
								#print"check3\n";
								
								if (($overlapTbestT<20)&&($overlapTbestQ>$coverage)&&($ScoreColsT>=$ScoreColsQ)&&($prediction[$v][13]>=$TMminscore)){
									print "MULTITEMPLATE S $ScoreColsT: $prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	Q: $prediction[$v][8]-$prediction[$v][9]	T:$prediction[$v][11]-$prediction[$v][12]\n";
									push(@hhrmultiHITS,[$prediction[$v][0],$prediction[$v][1],$prediction[$v][2],$prediction[$v][8],$prediction[$v][9],$prediction[$v][11],$prediction[$v][12],$prediction[$v][13]]);
									push(@selectedHITs,($prediction[$v][14]+1));
									$MULTIS++;
								}
								else{
									print"out\n";
								}
							}
						#different template as optimal single Template:
							elsif(($overlapTbestQ>$coverage)&&($ScoreColsT>=$ScoreColsQ)&&($prediction[$v][13]>=$TMminscore)){
								#print"check4\t";
								
								my $searchT=0;							
								foreach my $g (@checkedTemplates){
									#same template as one selected multi Template?
										if(@{$g}[0] eq $prediction[$v][2]){																																						
											
											my $positionsTmultiTinQ = "$prediction[$v][8] $prediction[$v][9] @{$g}[1] @{$g}[2]"; #start end & start end	
											my $overlapTmultiTinQ = &overlap($positionsTmultiTinQ);																	
																					
											#different domains!
											if ($overlapTmultiTinQ>20){
												$searchT=1;																															
											}																			
										}
								}								
								#different template as one selected multi Template?
								if ($searchT==0){
									$MULTIS++;	
									print "MULTITEMPLATE $ScoreColsT: $prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	Q: $prediction[$v][8]-$prediction[$v][9]	T:$prediction[$v][11]-$prediction[$v][12]\n";
									push(@hhrmultiHITS,[$prediction[$v][0],$prediction[$v][1],$prediction[$v][2],$prediction[$v][8],$prediction[$v][9],$prediction[$v][11],$prediction[$v][12],$prediction[$v][13]]);
									push(@selectedHITs,($prediction[$v][14]+1));
									push (@checkedTemplates, [$prediction[$v][2],$prediction[$v][8],$prediction[$v][9],$prediction[$v][11],$prediction[$v][12]]);									
								}
								else{
									print"out\n";
								}							
							}
						#else:
							else{
								print"out\n";
							}			
					}
			}			
		}	
	}
	###########################################
	#OLD STRATEGY TO SELECT MULTIPLE TEMPLATES:
	###########################################
	  # 	my @hhrmultiHITS=();	#hits (hhrfile hits: multiple templates)
	  # 	for (my $h=0; $h<@hhrHITS; $h++){
	  # 		my @hhrinfo = &CreateInfoArray("$outbase.$hhrHITS[$h][0].hhr");	
	  # 		#contains: HHR(0)   HIT(1)   TEMPLATE(2)   PROB(3)   RAWSCORE(4)   SS/Length(5)   SIM(6)   SumProb/Length(7)   QUERYSTART(8)   QUERYEND(9)   COLS(10)  TEMPLATESTART(11)   TEMPLATEEND(12)   TMSCORE(13)
	  # 		my $qsc;
	  # 		my $dbtemplates = "";
	  # 		my $templatefilter = "";
	  # 		my $templatemake = "";
	  # 		my $ScoreColsQ = $hhrinfo[($hhrHITS[$h][1]-1)][4] / $hhrinfo[($hhrHITS[$h][1]-1)][10]; #Viterbi Score (local) / aligned Columns (mact)
	  # 		#print "selected Template* Score: $ScoreColsQ\n";
	  # 		
	  # 		#filter each template in hhr.file and query with $qsc from filterstep in which Template achieved best predicted TM-Score
	  # 	   	foreach my $c (@hhrinfo){
	  # 			my $hhm = " $outdir/@{$c}[2].filt.hhm";
	  # 			if ($dbtemplates !~ /$hhm/){														
	  # 				$dbtemplates .= "$hhm ";
	  # 				if (-e "$pdbdir/@{$c}[2].a3m"){$templatefilter .= "$pdbdir/@{$c}[2].a3m ";}
	  # 				elsif (-e "$scopdir/@{$c}[2].a3m"){$templatefilter .= "$scopdir/@{$c}[2].a3m ";}
	  # 				else {die("Error: no a3m in database given!\n");} 				
	  # 				$templatemake .= "$outdir/@{$c}[2].filt.a3m ";
	  # 			}						
	  # 		}
	  # 
	  # 		$qsc = $hhrHITS[$h][0] * 0.1;
	  # 			
	  # 		#filter template a3ms:
	  # 		system("$hh/multithread.pl '$templatefilter' '$hh/hhfilter -i \$file -id 100 -diff 0 -qsc $qsc -o $outdir/\$root.filt.a3m -v 1' -cpu 4 > /dev/null 2>&1");
	  # 		system("$hh/multithread.pl '$templatemake' '$hh/hhmake -i \$file -diff 100 -o \$base.hhm -v 1' -cpu 4 > /dev/null 2>&1");
	  # 			
	  # 		#filter query.a3m:
	  # 		system("$hh/hhfilter -i $a3mfile -id 100 -diff 0 -qsc  $qsc -o $outbase.filt.a3m -v 1 ");
	  # 		system("$hh/hhmake -i $outbase.filt.a3m -diff 100 -o $outbase.filt.hhm -v 1");
	  # 
	  # 		#search with selected Template through filtered HMMs 
	  # 	   	print "\nSEARCH FOR MULTIPLE TEMPLATES (DOMAIN: $hhrHITS[$h][2])\n";
	  # 		system("$hh/hhsearch -cpu $cpus -i $outdir/$hhrHITS[$h][2].filt.hhm -d $calhhm -o $outbase.cal.hhr -cal $options -v $v");
	  # 		system("$hh/hhsearch -cpu $cpus -i $outdir/$hhrHITS[$h][2].filt.hhm -d \"$dbtemplates\" -o $outbase.template_$hhrHITS[$h][2].hhr $options -v $v"); 
	  # 		print "\n";
	  # 		
	  # 		my @hhrinfoTemplate = &CreateInfoArray("$outbase.template_$hhrHITS[$h][2].hhr");		
	  # 		$dbtemplates = "";		
	  # 		foreach my $c (@hhrinfoTemplate){		
	  # 			#foreach my $d (@{$c}){print "$d\t";} print "\n";
	  # 			my $ScoreColsT = @{$c}[4] / @{$c}[10] + 0.05;					
	  # 			#print "selected Template Score: $ScoreColsT\n";
	  # 			if (($ScoreColsT > $ScoreColsQ) || (@{$c}[1] == 1)){			
	  # 				#if score/cols of Template|selectedTemplate > score/clos of Query|selectedTemplate or selfhit
	  # 				#print "selected as Multi Template: @{$c}[2]\n";
	  # 				my $hhm = "$outdir/@{$c}[2].filt.hhm";
	  # 				if ($dbtemplates !~ /$hhm/){															
	  # 					$dbtemplates = $dbtemplates."$hhm ";
	  # 				}	
	  # 			}
	  # 		}		
	  # 
	  # 		#search with Query through filtered & selected (as multiple template) HMMs 
	  # 	   	print "\nSEARCH WITH QUERY TROUGH POSSIBLE MULTIPLE TEMPLATES\n";
	  # 		system("$hh/hhsearch -cpu $cpus -i $outbase.filt.hhm -d $calhhm -o $outbase.cal.hhr -cal $options  -v $v");
	  # 		system("$hh/hhsearch -cpu $cpus -i $outbase.filt.hhm -d \"$dbtemplates\" -o $outbase.multitemplate_$h.hhr $options  -v $v"); 
	  # 		print "\n";
	  # 		my @multiTemplate = &CreateInfoArray("$outbase.multitemplate_$h.hhr");
	  # 		#predict TM Scores:
	  # 		print "\nPOSSIBLE TEMPLATES:\n";	
	  # 		@multiTemplate = &PredTMscore(@multiTemplate);
	  # 		print "\n";
	  # 		
	  # 				
	  # 		##########################################################################################################
	  # 		#select top hits (max. 5) which lie in according region of query - 50% of the alignment has to be covered!
	  # 		##########################################################################################################
	  # 		#check for enough overlap:
	  # 		my $multihits=0;		
	  # 		my $coverage = ($hhrHITS[$h][4]-$hhrHITS[$h][3])/2; #50% of the alignment has to be covered!
	  # 		#print "coverage: $coverage\n";	
	  # 		for (my $t=0; $t<@multiTemplate; $t++){
	  # 			if ($multihits<5){			
	  # 				#print "$hhrHITS[$h][3] & $multiTemplate[$t][8]		$hhrHITS[$h][4] & $multiTemplate[$t][9]\n";
	  # 				for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}
	  # 				my $first=$hhrHITS[$h][3];
	  # 				my $last=$hhrHITS[$h][4];
	  # 				
	  # 				for (my $i=$first; $i<=$last; $i++) {$aligned[$i]=1}
	  # 				$first=$multiTemplate[$t][8];
	  # 				$last=$multiTemplate[$t][9];
	  # 				my $overlap=0;
	  # 				my $mlen=0;
	  # 				for (my $i=$first; $i<=$last; $i++) {if ($aligned[$i]==1) {$overlap++;} else {$mlen++;}}
	  # 				#print "$overlap\n";
	  # 				
	  # 				if ($overlap>$coverage){				
	  # 					push(@hhrmultiHITS,[$multiTemplate[$t][0],$multiTemplate[$t][1],$multiTemplate[$t][2],$multiTemplate[$t][8],$multiTemplate[$t][9],$multiTemplate[$t][11],$multiTemplate[$t][12],$multiTemplate[$t][13]]);														
	  # 					$multihits++;
	  # 				}				
	  # 			}
	  # 		}				
	  # 	}		
	  # 	#print "\nSELECTED AS MULTIPLE TEMPLATE:\nHHR	HIT	TEMPLATE	QUERYSTART-END TEMPLATESTART-END	TMSCORE\n";	
	  # 	#foreach my $c (@hhrmultiHITS){foreach my $d (@{$c}){print "$d\t";} print "\n";}
	  # 	#print "\n";
	  # 	
	  # 	#check if same template is used several times and in overlapping parts in template
	  # 	my @finalHITS;
	  # 	#if more than one domain/multitemplates found				
	  # 	if(@hhrmultiHITS>1){						
	  # 		my $donttake = "";
	  # 		for (my $h=0; $h<@hhrmultiHITS; $h++){
	  # 			for (my $i=$h+1; $i<@hhrmultiHITS; $i++){
	  # 				if ($donttake !~ /$hhrmultiHITS[$h][2]_$hhrmultiHITS[$h][0]_$hhrmultiHITS[$h][1]/){	
	  # 					#print "look: $hhrmultiHITS[$h][0]	$hhrmultiHITS[$h][1]	$hhrmultiHITS[$h][2]		& 		$hhrmultiHITS[$i][0]	$hhrmultiHITS[$i][1]	$hhrmultiHITS[$i][2]\n";
	  # 					my $queryov=0;	
	  # 					my $templov=0;		
	  # 					#check: same templates?				
	  # 					if ($hhrmultiHITS[$h][2] eq $hhrmultiHITS[$i][2]){	
	  # 						#check: overlap?
	  # 						#print "same-domains: $hhrmultiHITS[$h][2]\t";	
	  # 						#print "$hhrmultiHITS[$h][3] 	$hhrmultiHITS[$i][3]	$hhrmultiHITS[$h][4]	$hhrmultiHITS[$i][4]	$hhrmultiHITS[$h][5] 	$hhrmultiHITS[$i][5]	$hhrmultiHITS[$h][6]	$hhrmultiHITS[$i][6]	\n";	
	  # 						
	  # 						#check: overlap in query!?!	
	  # 						for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}
	  # 						my $firstq=$hhrmultiHITS[$h][3];
	  # 						my $lastq=$hhrmultiHITS[$h][4];						
	  # 						for (my $i=$firstq; $i<=$lastq; $i++) {$aligned[$i]=1}
	  # 						$firstq=$hhrmultiHITS[$i][3];
	  # 						$lastq=$hhrmultiHITS[$i][4];
	  # 						my $queryov=0;
	  # 						my $mlenq=0;
	  # 						for (my $i=$firstq; $i<=$lastq; $i++) {if ($aligned[$i]==1) {$queryov++;} else {$mlenq++;}}						
	  # 						
	  # 						#check: overlap in template!?!			
	  # 						for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}
	  # 						my $firstt=$hhrmultiHITS[$h][5];
	  # 						my $lastt=$hhrmultiHITS[$h][6];						
	  # 						for (my $i=$firstt; $i<=$lastt; $i++) {$aligned[$i]=1}
	  # 						$firstt=$hhrmultiHITS[$i][5];
	  # 						$lastt=$hhrmultiHITS[$i][6];
	  # 						my $templov=0;
	  # 						my $mlent=0;
	  # 						for (my $i=$firstt; $i<=$lastt; $i++) {if ($aligned[$i]==1) {$templov++;} else {$mlent++;}}						
	  # 						#print "Overlap: Query: $queryov	Template: $templov\n";						
	  # 						if ($queryov>20){
	  # 							#print "donttake: $hhrmultiHITS[$h][2]_$hhrmultiHITS[$i][0]_$hhrmultiHITS[$i][1]\n";						
	  # 							$donttake .= "$hhrmultiHITS[$h][2]_$hhrmultiHITS[$i][0]_$hhrmultiHITS[$i][1] ";
	  # 						}															
	  # 					}									
	  # 				}								
	  # 			}
	  # 			if ($donttake !~ /$hhrmultiHITS[$h][2]_$hhrmultiHITS[$h][0]_$hhrmultiHITS[$h][1]/){
	  # 				#print "take: $hhrmultiHITS[$h][0]	$hhrmultiHITS[$h][1]	$hhrmultiHITS[$h][2]\n";				
	  # 				push (@finalHITS,$hhrmultiHITS[$h]);
	  # 			}				
	  # 		}
	  # 	}
	  # 	elsif (@hhrmultiHITS==1){
	  # 		@finalHITS = @hhrmultiHITS;		
	  # 	}
	  # 	else {
	  # 		print "WARNING: Multi-template-selection failed! Take single template!\n";
	  # 		my $optimalTemplates = &searchDOMAINS_buildHHR(@prediction);
	  # 		return $optimalTemplates;
	  # 	}

	
	print "\nSELECTED AS MULTIPLE TEMPLATES:\nHHR	HIT	TEMPLATE	QUERYSTART-END TEMPLATESTART-END	TMSCORE\n";	
	foreach my $c (@hhrmultiHITS){foreach my $d (@{$c}){print "$d\t";} print "\n";}
	
	###############################################################
	#build HHR file containing all filtered Hits ranked by TM-score
	###############################################################
	my $optimalTemplatesSingleT="";
	for (my $t=0; $t<@selectedHITsSingleT; $t++) {$optimalTemplatesSingleT .= "$selectedHITsSingleT[$t] ";}	
	my $optimalTemplates="";
	for (my $t=0; $t<@selectedHITs; $t++) {$optimalTemplates .= "$selectedHITs[$t] ";}
	
	my @alignment_lines =();#content of final hhr file
	open (HHR,">$outbase.hhr") or die ("Error: cannot open $outbase.hhr\n");
	
	for (my $v=0; $v<@prediction; $v++){
		open (IN, "<$outbase.$prediction[$v][0].hhr") or die ("Error: cannot open $outbase.$prediction[$v][0].hhr!\n");
		#print "$prediction[$v][0]	$prediction[$v][1]	$prediction[$v][2]	$prediction[$v][3]		$outbase.$prediction[$v][0].hhr\n";
		my $check=0;
		my $begin;
		my $e=0;
		my $end;							
		my $line;
		my $hitnr = $v+1;
		while ($line = <IN>){
						
		#copy first lines:
		if (($line !~ /^\s*\d+\s+\S+.+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$/) && ($check==0) && ($v==0)){
			if ($line=~ /^Command/) {$line=~ s/(^Command\s*)(.*)$/$1$hh\/hhsearch artificial hhr file (hits generated by a filtering procedure)\nRemark        optimal single template(s): $optimalTemplatesSingleT\nRemark        optimal multiple template(s): $optimalTemplates/;}
			if ($line=~ /\s+No\s+Hit\s+Prob\s+E-value\s+P-value\s+Score\s+SS\s+Cols\s+Query\s+HMM\s+Template\s+HMM\s+/) {
				#print $line;
				$line =~s/(\s*No\s+Hit\s+Prob\s+E-value\s+)(P-value)(\s+Score\s+SS\s+Cols\s+Query\s+HMM\s+Template\s+HMM\s+)/$1TMScore$3/;
			}	
			print (HHR "$line");				
		}				
		else {$check=1;}
		
		#get hit Info:
		if ($line =~ /^\s*$prediction[$v][1](\s+\S+.+\s+\S+\s+\S+)\s+\S+(\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$)/)	{
			#$line=~ s/(^\s*)($prediction[$v][1])(\s+\S+.+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\d+-\d+\s+\S+\s*\(\S+\)$)/$1$hitnr$3/;
			$line = sprintf("%3s$1  %1.4f$2\n",$hitnr,$prediction[$v][13]);		
			print (HHR "$line");
			last;
			}
		}
		# Find beginning of alignment end replace hit index by new one
		while ($line = <IN>){ if($line=~/^No\s+$prediction[$v][1]/) {last;}} # skip all lines up to alignment block
		#print("Line with No : $line");
		$line =~s/^No\s+\d+/No $hitnr/;
		push(@alignment_lines,$line);

		#Push alignment block onto array				
		while ($line = <IN>){
		if(($line=~/^No\s/)) {last;}
			if ($line =~ /Done!/){}
			else {push(@alignment_lines,$line);}
		}	
		close (IN);					
	}
	print(HHR "\n");
	print(HHR @alignment_lines);
	print(HHR "Done!\n");
	close (HHR);
	
	return $optimalTemplates;		
}

sub overlap{
	my $positions=$_[0];
	#print "$positions\n";
	my @positions=split(/ /,$positions);
	my @aligned;
	for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}
	my $first=$positions[0];
	my $last=$positions[1];				
	for (my $i=$first; $i<=$last; $i++) {$aligned[$i]=1}
	$first=$positions[2];
	$last=$positions[3];
	my $overlap=0;
	my $mlen=0;
	for (my $i=$first; $i<=$last; $i++) {if ($aligned[$i]==1) {$overlap++;} else {$mlen++;}}
	return $overlap;		
}
	
sub System {
    print("\$ $_[0]\n");
    system($_[0]);
}

#TEST RUN######################################################################################################################################################################################################
#./selectTemplates.pl -i /cluster/user/andrea/Data_and_Programs/DATA/TOOLKIT/1pqv_S/1pqv_S -o /cluster/user/andrea/Data_and_Programs/DATA/TOOLKIT/1pqv_S/1pqv_S -mode m
