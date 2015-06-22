#!/usr/bin/perl -w

#read hhsearch results file (containing all filtered hits ranked by a predicted TM-Score)
#create pir alignment for MODELLER software
#if necessary create artificial pdb files (add 50 Angstrom)	

my $rootdir;
BEGIN {
    if (defined $ENV{TK_ROOT}) {$rootdir=$ENV{TK_ROOT};} else {$rootdir="/cluster";}
};
use lib "$rootdir/bioprogs/hhpred";
use lib "/cluster/lib";              # for chimaera webserver: ConfigServer.pm

use strict;
use MyPaths;                         # config file with path variables for nr, blast, psipred, pdb, dssp etc.

# Default values
our $v=2; 					# verbose mode
#my $pdbdir  = (glob "$newdbs/pdb*")[0];    	# PDB database with HMMs
my $pdbdir = "$database_dir/pdb/all";
my $hh_dbs = "";

my $usage="\n...

Usage: ....pl -i <basename>  -o <basename> [options] 
  -i <file.hhr>         	name for input hhr file
  -q <file.a3m>         	name for query sequence file
  -m <int> [<int> ...] 		pick hits with specified indices to be checked (default='-m 1')
  -pir <file.pir>               outfile: write a PIR-formatted alignment to file.pir 
  -v <int>              	verbose mode (0: no output, 1: minimal output, 2,3..: verbose) (default=$v)
  -d <pdbdirs>         		directory containing pdb files (for PDB, SCOP, or DALI sequences) (default=/cluster/databases/pdb/all)  -hhdbs <dirs>      	      directories with HHpred DBs searched 
\n";

# Variable declaration
my $infile;             # hhr file
my $qfile;		# a3m file
my $outfile;		# folder/name.pir
my $outdir;		# folder/	
my $outname;		# name
my $outformat;		# pir
my $hits;
my @hits;

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

if ($inputoptions=~s/ -i\s+(\S+) / /g)    {$infile=$1;}
if ($inputoptions=~s/ -q\s+(\S+) / /g)    {$qfile=$1;}
if ($inputoptions=~s/ -m\s+((\d+\s+)+)/ /g) {$hits=$1;}
if ($inputoptions=~s/ -pir\s+(\S+) / /ig) {$outfile=$1;}
if ($inputoptions=~s/ -d\s+(\S+) //) {$pdbdir=$1;}
if ($inputoptions=~s/ -hhdbs\s+(([^-\s]\S*\s+)*)//) {$hh_dbs=$1;}

# Warn if unknown options found
while ($inputoptions=~s/\s*(\S.*)//) {print("WARNING: unknown inputoptions $1\n");}
if (!defined $outfile) {die("Error: no outfile name given\n");}
if ($outfile =~ /^(.*)\/(\S*)\.(\S*)$/) {$outdir=$1; $outname=$2; $outformat=$3} else {die("Error: wrong output file name given!\n");}

if (!-e $infile) {die("Error: no hhr file given!\n");}
if (!-e $qfile) {die("Error: no query sequence file given!\n");}
if (!-d $pdbdir) {die("Error: wrong directory containing pdb files given!\n");}

# option '-m m1 m2 m3':
if ($hits){@hits = split(/\s+/,$hits);}
else {$hits[0] = "1"; print "WARNING: no hits explicitly selected, take first Alignment in hit list!\n";}

if (@hits==1){ 
  print "\n\ncreate pir-alignment: $hh/hhmakemodel.pl $infile -m $hits[0] -q $qfile -v $v -pir $outdir/$outname.$outformat  -d $pdbdir $hh_dbs\n\n";
  system("$hh/hhmakemodel.pl $infile -m $hits[0] -q $qfile -v $v -pir $outdir/$outname.$outformat -d $pdbdir $hh_dbs"); 
  exit;
}
else { print "\nCheck Hits for overlap and repeat domains:\n";}


#####################################################################################################################################
#read selected hits in hhr-file
#####################################################################################################################################
#check for overlap and repeat domains!
#  1  2                                3     4       5       6       7   8    9   10     11  12  13 
# No Hit                             Prob E-value TMScore  Score    SS Cols Query HMM  Template HMM
#  1 2bt9_A Lectin; sugar recogniti 100.0 4.6E-37  0.2657  230.7   6.7   88  164-254     1-90  (90) 
my @hits_check;
my $hit;my $ID;
my $qstart;my $qend;
my $tstart;my $tend;

open(HHR,"<$infile") || die("Error in file: $infile\n");
while (my $line = <HHR>){
  for (my $h=0; $h<@hits; $h++){  
    if ($line=~/^\s*($hits[$h])\s+(\S+).+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)-(\d+)\s+(\d+)-(\d+)\s*\((\S+)\)$/){	
      $hit= $1;
      $ID= $2;
      $qstart= $9;$qend= $10;
      $tstart= $11;$tend= $12;      
      if ($ID =~ /^[defgh](\d[a-z0-9]{3})([a-z0-9_\.])[a-z0-9_]/) {
	  $ID=$1;
	  my $chain;
	  if ($2 eq "_") {$chain="[A ]";} else {$chain=uc($2);}
	  $ID.= "_$chain";
      } 
      push(@hits_check, [$hit,$ID,$qstart,$qend,$tstart,$tend]);      
    }  
  }
}
close (HHR);
foreach my $c (@hits_check){foreach my $d (@{$c}){print "$d\t";} print "\n";}
print "\n";
###############################################################################################################################################
#check if same template is used several times and in overlapping parts (e.g repeatproteins!!!) -> because of problems with MODELLER restraints!
###############################################################################################################################################
#hit(0) tem(1) qstart(2) qend(3) tstart(4) tend(5)
my @aligned;
my $donttake="";
my $added="";
my $doubles=0;
for (my $h=0; $h<@hits_check-1; $h++){
  for (my $i=$h+1; $i<@hits_check; $i++){
    if (($donttake !~ /,$hits_check[$h][0],/)&&($donttake !~ /,$hits_check[$i][0],/)){

	  my $queryov=0;
	  my $templov=0;			  
	  #check: same templates?
	  if ($hits_check[$h][1] eq $hits_check[$i][1]){
	    print "L133 Hit: $hits_check[$h][0] & $hits_check[$i][0] same templates!\t";
	    #check: overlap?
	    #print "$hits_check[$h][2]&$hits_check[$i][2]\n$hits_check[$h][3]&$hits_check[$i][3]\n$hits_check[$h][4]&$hits_check[$i][4]\n$hits_check[$h][5]&$hits_check[$i][5]\n\n";
	    
	      #check: overlap in query!?!	
	      for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}
	      my $firstq=$hits_check[$h][2];
	      my $lastq=$hits_check[$h][3];						
	      for (my $i=$firstq; $i<=$lastq; $i++) {$aligned[$i]=1}
	      $firstq=$hits_check[$i][2];
	      $lastq=$hits_check[$i][3];
	      my $queryov=0;
	      my $mlenq=0;
	      for (my $i=$firstq; $i<=$lastq; $i++) {if ($aligned[$i]==1) {$queryov++;} else {$mlenq++;}}
      
	      #check: overlap in template!?!			
	      for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}
	      my $firstt=$hits_check[$h][4];
	      my $lastt=$hits_check[$h][5];						
	      for (my $i=$firstt; $i<=$lastt; $i++) {$aligned[$i]=1}
	      $firstt=$hits_check[$i][4];
	      $lastt=$hits_check[$i][5];
	      my $templov=0;
	      my $mlent=0;
	      for (my $i=$firstt; $i<=$lastt; $i++) {if ($aligned[$i]==1) {$templov++;} else {$mlent++;}}
						      
	      print "Overlap: in Query:  $queryov AA	in Template:  $templov AA\t";
      
	      if ($queryov<=20 && $templov>20){			
			print "repeat-domain: $hits_check[$h][0] & $hits_check[$i][0]\t";		
			if (($added eq "")||($added !~ /$hits_check[$h][1]/)){
				print "\nL163 If statement\n";
				$doubles++;
				print " -> create $outdir/$hits_check[$h][1]_$h.pdb\n";
				# Db that is accessed only contains Protein file withoud chain Information and labled like this pdb{id}.ent
				#system ("cp $pdbdir/$hits_check[$h][1].pdb	$outdir/$hits_check[$h][1]_$h.pdb\n");
				# Extract the PDB Id from Hit 
				my $tmp = $hits_check[$h][1];
				$tmp= substr($tmp, 0 , 4);
				print "L170 $tmp\n";
				#use this to copy the complete ent to local folder als {id}.pdb
				system("cp $pdbdir/pdb$tmp.ent	$outdir/$hits_check[$h][1]_$h.pdb\n");
				#add 50 Angstrom to x coordinate in pdb file:
				open (PDB,"<$outdir/$hits_check[$h][1]_$h.pdb") or die ("Error: cannot open $outdir/$hits_check[$h][1]_$h.pdb\n");
				my @lines = <PDB>;
				close(PDB);    				 
				for (my $i=0; $i<@lines; $i++) {
					if ($lines[$i]=~ /^(.{30})(\s*)(-?\d+.\d+)(\s*-?\d+.\d+\s*-?\d+.\d+\s*.*)/){
						my $xcoord = $3+50;							
						$lines[$i] = sprintf("$1%8.3f$4\n",$xcoord);								
					}						
				}						   
				open (PDBnew,">$outdir/$hits_check[$h][1]_$h.pdb") or die ("Error: cannot open $outdir/$hits_check[$h][1]_$h.pdb\n");
				print(PDBnew @lines);	
				close (PDBnew);	
				$added.= " $hits_check[$h][1]_$h";	
			}
 			elsif($added !~ /$hits_check[$h][1]_$h/){
 				print "L184 elseIf statement\n";
				$doubles++;
 				print " -> create $outdir/$hits_check[$h][1]_$h.pdb\n";
				my $copy;				
				if ($added =~ /.*($hits_check[$h][1]_\d*).*?$/){$copy="$outdir/$1.pdb";}     
 				system ("cp $copy $outdir/$hits_check[$h][1]_$h.pdb\n");
 				#add 50 Angstrom to x coordinate in pdb file:
 				open (PDB,"<$outdir/$hits_check[$h][1]_$h.pdb") or die ("Error: cannot open $outdir/$hits_check[$h][1]_$h.pdb\n");
 				my @lines = <PDB>;
 				close(PDB);    				 
 				for (my $i=0; $i<@lines; $i++) {
 					if ($lines[$i]=~ /^(.{30})(\s*)(-?\d+.\d+)(\s*-?\d+.\d+\s*-?\d+.\d+\s*.*)/){
 						my $xcoord = $3+50;							
 						$lines[$i] = sprintf("$1%8.3f$4\n",$xcoord);								
 					}						
 				}						   
 				open (PDBnew,">$outdir/$hits_check[$h][1]_$h.pdb") or die ("Error: cannot open $outdir/$hits_check[$h][1]_$h.pdb\n");
 				print(PDBnew @lines);	
 				close (PDBnew);	
				$added.= " $hits_check[$h][1]_$h";
			}
			else{print "\n";}																    
		}
		elsif ($queryov>20){
			print "ignore HIT $hits_check[$i][0] for modeling\n";						
			$donttake .= ",$hits_check[$i][0],";		      
		}	
		else{print "\n"}
	}
    }
  }
}
my @hits_take;
for (my $h=0; $h<@hits; $h++){
  if ($donttake !~ /,$hits[$h],/){
    push(@hits_take,$hits[$h]);
  }
}
print "\n\ncreate pir-alignment: $hh/hhmakemodel.pl $infile -m @hits_take -q $qfile -v $v -pir $outdir/$outname.$outformat -d $pdbdir $hh_dbs\n\n";
system("$hh/hhmakemodel.pl $infile -m @hits_take -q $qfile -v $v -pir $outdir/$outname.$outformat -d $pdbdir $hh_dbs"); 

if ($doubles>0){
      my @pdbs = <$outdir/*.pdb>;
      my $checkedPDBs=""; 
      my $duplis=1;	  
      open (PIR,"<$outdir/$outname.$outformat") or die ("Error: cannot open $outdir/$outname.$outformat\n");
      my @lines = <PIR>;
      close(PIR);
      for (my $i=0; $i<@lines; $i++) {    
	  if ($lines[$i]=~/^structureX:/) {
	      $lines[$i-1]=~/>P1;(\S+)/;
	      my $pdbid = $1;
	      for (my $j=0; $j<@pdbs; $j++) { 
		  if (($pdbs[$j] =~ /$outdir\/$pdbid\_\d+\.pdb/)&&($checkedPDBs !~ /$pdbid/)) {$checkedPDBs.="$pdbid ";last;}
		  elsif (($pdbs[$j] =~ /$outdir\/$pdbid\_\d+\.pdb/)){
			print"\nReplace $pdbid by DUPLICATEPDB$duplis.$pdbid.pdb!\n";
			system "mv $pdbs[$j] $outdir/DUPLICATEPDB$duplis.$pdbid.pdb";
			#$lines[$i-1]=~ s/>P1;$pdbid/>P1;DUPLICATEPDB$duplis.$pdbid/;
			#$lines[$i]=~s/^structureX:$pdbid:(.*)/structureX:DUPLICATEPDB$duplis.$pdbid:$1/;
			$duplis++;
			@pdbs = grep !/$pdbs[$j]/, @pdbs;
			last;
		  }
	      }
	  }	
      }
      open (OUT, ">$outdir/$outname.$outformat") or die ("Error: cannot open pir-file!\n");
      print(OUT @lines);
      close(OUT);      
}
exit;
