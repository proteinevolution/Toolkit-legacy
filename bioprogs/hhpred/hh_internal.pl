#!/usr/bin/perl -w
# Run $server pipeline for CASP with sequence $seqname in file $basename.seq 
# and send an email to $address with a model for each kind of prediction:
# - TS: tertiary structure (PDB format)
# - DP: domain prediction
# - FN: function prediction

# This script is sent to the cluster queue by toolkit@cerberus:/home/toolkit/public_html/cgi-bin/hhpred_bench.pl
# Therefore, each cluster node must be able to send mail via the perl Mail:Sender package 
# which is called in /cluster/bioprogs/hhpred/mail.pl

# $server pipelines:
# HHpred1: simple search against pdb+scop plus MODELLER run
# HHpred2: HHpred1 + hhmeta.pl (hierarchical multiple template selection)
# HHpred3: HHpred1 + hhmeta.pl + buildinter.pl
# BayesHH: HHpred3 + Bayes sampling of structure and alternative alignments

use lib	"/home/soeding/perl";
use lib	"/cluster/lib";
use lib "/var/web/toolkit/lib";
use lib "/cluster/bioprogs/hhpred";
use ServerConfig;
use MyPaths;      # config file with path variables for nr, blast, psipred, pdb, dssp etc.
use strict;

$| = 1; # autoflush
my $v=2;

my $pdbdir  = (glob "$newdbs/pdb*")[0];    # PDB database with HMMs
my $scopdir = (glob "$newdbs/scop*")[0];   # PDB database with HMMs
my $modeller= (glob "/cluster/www/toolkit/bioprogs/modeller*/bin/mod?v?")[0];
my $options = "-mac -mact 0.01"; # do not use anything that changes the calibration under default conditions (=>hhmeta.pl)
my $pdbdb=$pdbdir."/db/pdb.hhm";
my $myaddress = "johannes.soeding\@tuebingen.mpg.de";
my $hisaddress = "michael.habeck\@tuebingen.mpg.de";
my %code = ("HHpred1"=>"7120-4163-4333", "HHpred2"=>"1242-1096-1023", "HHpred3"=>"1388-5323-5449", "BayesHH"=>"7809-3994-8158");
my $Bayes="/cluster/user/habeck/projects/casp7/Bayes0.py";
my $cpus=4;

# Create tmp directory (plus path, if necessary)
my $tmpdir="/tmp/$ENV{USER}/$$";  # directory where all temporary files are written: /tmp/UID/PID
my $suffix=$tmpdir;
while ($suffix=~s/^\/[^\/]+//) {
    $tmpdir=~/(.*)$suffix/;
    if (!-d $1) {mkdir($1,0777);}
} 

my $basename = $ARGV[0];
my $seqname = $ARGV[1];
my $address = $ARGV[2];
my $server  = $ARGV[3];
my $id=$basename;
if ($basename=~/.*\/(.*)?/)  {$id=$1;}     # remove path 
$seqname=~s/^\s*(\S*).*/$1/;               # remove all but first word in sequence name

print("basename: $basename\n");
print("seqname:  $seqname\n");
print("address:  $address\n");
print("server:   $server\n\n");
print("pdbdir:   $pdbdir\n");
print("scopdir:  $scopdir\n");

my %method;  # Method descriptions
my $prob;
my $line;
my $templates;
my @modellines=();
my @alignments=();

my $name=$basename;
$name=~s/(.*)\///;   # remove path
my $tmp_dir=$1;      # directory path
$name=~s/\..*?//;    # remove extension
my $tmpname="$tmpdir/$name";
&System("cp $basename.seq $tmpname.seq");

&SetMethodDescription();



#########################################################################################
# Create alignment


print "\nBuilding query multiple alignment ...\n";
if ($server=~/test/i) {
#    &System("perl $hh/buildali.pl -v $v -lc -n 1 $tmpname.seq"); # DEBUG !!!!!!!!!!!!!!!!
} else {
    &System("perl $hh/buildali.pl -cpu $cpus -v $v -lc -n 8  $tmpname.seq");
}

# Call HHsenser if appropriate, then hhmake and hhsearch
if ($server=~/HHpred3/i || $server=~/BayesHH/i) {

    # Start HHsenser     
    &System("perl $hh/buildinter.pl -cpu 2 -v $v -tmax 6:00 -Prob 90 -idmax 0 -extnd 20 $tmpname.a3m");
    &System("rm -f $tmpname-*.fas");
    &System("cp $tmpname"."-X.a3m $tmpname.a3m;");
    &System("$hh/hhmake -i $tmpname.a3m -diff 100");
    &System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d $calhhm -o $tmpname.cal.hhr -cal $options");
    &System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d $pdbdb -o $tmpname.hhr -Z 20 -B 20 $options");

    # Read hhr file
    open(RES,"<$tmpname.hhr" ) || die("Error: Cannot open $tmpname.hhr: $!\n");
    while ($line=<RES>) { if ($line=~/^\s*No Hit/) {last;} }
    $line =~ /^(.*) Prob/;
    my $cutres=length($1);
    $line=<RES>;
    close(RES);
    
    # Use $tmpname-Y.a3m file instead of $tmpname-X.a3m?
    $line=~/.{$cutres}\s*(\S+)/;
    if ($1<=80) {
	print("\nProbability of best hit = $1 <50%. Using $tmpname"."-Y.hhm\n");
	&System("cp $tmpname"."-Y.a3m $tmpname.a3m;");
	&System("$hh/hhmake -i $tmpname.a3m -diff 100");
	&System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d $calhhm -o $tmpname.cal.hhr -cal $options");
	&System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d $pdbdb -o $tmpname.hhr -Z 20 -B 20 $options");
    }

} elsif ($server=~/HHpred1/i || $server=~/HHpred2/i) {

    # No HHsenser, just use $tmpname.a3m from buildali.pl
    &System("$hh/hhmake -i $tmpname.a3m -diff 100");
    &System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d $calhhm -o $tmpname.cal.hhr -cal $options");
    &System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d $pdbdb -o $tmpname.hhr -Z 20 -B 20 $options");
} else {
    print("Warning: unknown server key: $server\n");
}



############################################################################
# Make 3D structure prediction

# Generate global multiple- or single-templates hhr results file
if ($server=~/^HHpred0/i || $server=~/^HHpred1/i) {
#    nothing to be done: realigning is done in hhsearch already
#    &System("perl $hh/hhrealign.pl -i $tmpname.hhr -o $tmpname.tmp.hhr -d $pdbdir "); 
} elsif ($server=~/^HHpred2/i || $server=~/^HHpred3/i) {
    &System("perl $hh/hhmeta.pl -i $tmpname.hhr -o $tmpname.tmp -pc -r '$options' -v 2");  ## DEBUG
} elsif ($server=~/^BayesHH/i) {
    &System("perl $hh/hhmeta.pl -i $tmpname.hhr -o $tmpname.tmp -pc -r '$options'");
} else {
    print("Warning: unknown server key: $server\n");
}


# Parse hhr file for non-overlapping matches and their score(s)
my @m=();
my @prob=();
my $k;
my $MAXOVLAP=20;   # maximum allowable overlap with previously accepted matches 
my $MINDOMLEN=40;  # minimum length of match not overlapping with previous matches
my $MINPROB=25;    # minimum probability for further domains to be modelled
my @aligned;
for (my $i=1; $i<=5000; $i++) {$aligned[$i]=0;}
open (IN, "<$tmpname.tmp.hhr") or die ("Error: cannot open $tmpname.tmp.hhr: $!\n");
while ($line=<IN>) { if ($line=~/^\s+No Hit/) {last;}} 
for ($k=1; $line=<IN>; $k++) {
    if ($line=~/^\s*$/) {last;}
    # No Hit                             Prob E-value P-value  Score    SS Cols Query HMM  Template HMM
    #  1 1v97_A XD, xanthine dehydrogen 100.0       0       0  816.9  28.1  350    1-350     1-350 (1332)
    $line=~/(\S+)\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s+(\d+)-(\d+)\s+\S+\s*\(\S+\)\s*$/; # read query residue range
    $prob[$k]=$1;
    my $first=$3;
    my $last=$4;
    if (($k==1 || $1>=$MINPROB) && $2>=$MINDOMLEN) { # Probab>=25 && aligned columns >=40
	# Count overlaps and non-overlapping match length 
	my $overlap=0; 
	my $mlen=0;
	for (my $i=$first; $i<=$last; $i++) {
	    if ($aligned[$i]==1) {$overlap++;} else {$mlen++;}
	}
#	printf("first=%-3i  last=%-3i  overlap=%-3i  mlen=%-3i  line=%s\n",$first,$last,$overlap,$mlen,$line); ## DEBUG
	if ($overlap>$MAXOVLAP) {next;} # skip match if too much overlap with previously accepted matches
	if ($mlen<$MINDOMLEN) {next;}   # skip match if too few non-overlapping residues
	for (my $i=$first; $i<=$last; $i++) {$aligned[$i]=1}
	push(@m,$k); 
	print ("Found domain: $line");
    }
}
close(IN);


# Generate 3D model with one or more domains
if ($server=~/^HHpred0/i) {
    my $m = join(" ",@m);
    &System("perl $hh/hhmakemodel.pl $tmpname.tmp.hhr -m $m -q $tmpname.a3m -v -ts $tmpname.mod -d $pdbdir");
    &WriteDomain("$tmpname.mod",1);
    
} elsif ($server=~/^HHpred1/i || $server=~/^HHpred2/i  || $server=~/^HHpred3/i) {
    
    if (@m<=1) { # include entire query sequence in modeller alignment
	&System("perl $hh/hhmakemodel.pl $tmpname.tmp.hhr -m 1 -q $tmpname.a3m -v 2 -pir $tmpname.pir -d $pdbdir"); 
	&Modeller("$name.mod",1);  # run MODELLER
	&WriteDomain("$tmpname.mod",1);

    } else {
	foreach $k (@m) {
	    &System("perl $hh/hhmakemodel.pl $tmpname.tmp.hhr -m $k -v 2 -pir $tmpname.pir -d $pdbdir");
	    &Modeller("$name.mod",$k);  # run MODELLER
	    &WriteDomain("$tmpname.mod",$k);
	}
    }    

} elsif ($server=~/^BayesHH/) {

    my @templates;
    $k=0;
    open(IN,"<$tmpname.tmp.hhr") || die("Erro: could not open $tmpname.tmp.hhr \n");
    while ($line = <IN>) {if ($line=~/^ No Hit /) {last;}} 
    while ($line = <IN>) {
	if ($line =~ /^\s*$/) {last;}
	$line =~ /^\s*\d+\s+(\S+)/;
	$templates[++$k]=$1;
    }
    close(IN);

#    if (@m<=1) {
 	# Make simple model in case Bayes0 fails (and to set $templates variable)
	&System("perl $hh/hhmakemodel.pl $tmpname.tmp.hhr -m 1 -q $tmpname.a3m -v 2 -pir $tmpname.pir -d $pdbdir");
	&Modeller("$name.mod",1);  # run MODELLER
	
	# Run Michael's script
	&System("$Bayes $seqname $tmpname.hhm $tmpdir/$templates[1].hhm $pdbdir $tmpname.mod");
	
	# Write domain
        &System("perl $bioprogs_dir/perl/repair_pdb.pl $tmpname.mod > /dev/null 2>&1");
        &WriteDomain("$tmpname.mod",1);
    
#    } else { # This part does not work since aligned parts of template HMMs need to be cut out and residue numbering adapted
#	foreach $k (@m) {
#	# Make simple model in case Bayes0 fails (and to set $templates variable)
#	&System("perl $hh/hhmakemodel.pl $tmpname.tmp.hhr -m $k -q $tmpname.a3m -v 2 -pir $tmpname.pir -d $pdbdir");
#	&Modeller("$name.mod",$k);  # run MODELLER
#	
#	# Run Michael's script
#	&System("$Bayes $seqname $tmpname.hhm $templates[$k].hhm $pdbdir $tmpname.mod");
#	
#	# Add TER line
#	&System("perl $bioprogs_dir/perl/repair_pdb.pl $tmpname.mod 0 > /dev/null 2>&1");
#	&WriteDomain("$tmpname.mod",$k);
# 	}
#    }    

} else {
    &WriteDomain("$tmpname.mod",1);
    print("Warning: unknown server key: $server\n");
}

# Write model file
open (PDB,">$basename.pdb") or die ("Error: cannot open $basename.pdb: $!\n");
print(PDB "PFRMAT TS\n");
print(PDB "TARGET $seqname\n");
if ($address=~/predictioncenter/i) {
    printf(PDB "AUTHOR %s\n",$code{$server});
    print(PDB "METHOD $server (http://hhpred.tuebingen.mpg.de)\n");
} else {
    print(PDB "AUTHOR $server (http://hhpred.tuebingen.mpg.de)\n");
}
print(PDB $method{$server});
print(PDB @alignments);
print(PDB "MODEL  1\n");
print(PDB @modellines);
print(PDB "END\n");
close(PDB);
print "\nDONE\n";

# Send message
&System("cp $tmpname.a3m $tmpname.hhm $tmpname.hhr $tmpname.tmp.hhr $tmpname.pir $tmp_dir");
print "\nSend tertiary structure prediction results to $address ...\n";
&System("perl $bioprogs_dir/hhpred/mail.pl   $address \"Sent $server $seqname TS $id $address\" $basename.pdb"); 
#&System("perl $bioprogs_dir/hhpred/mail.pl $myaddress \"Sent $server $seqname TS $id $address\" $basename.pdb"); 
print "E-mail has been sent to $address.\n\n";


###########################################################################################
# Make function prediction

if ($server=~/HHpred1/i || $server=~/HHpred3/i || $server=~/func/i) {


    my $word;
    my $prob;
    my %word2GO; # $word2GO{"word") is a reference to an array with all GO categories containing "word"
    my %molfunc; # keys are all GO IDs which represent molecular functions
    my $N_GOs=0;
    my ($n,$desc,$category,$GO_ID);
    my %ukfreq;  # frequencies for ~57000 UK words from 16 (very frequent) to 0

    # Read UK word frequencies
    print("Read UK word frequencies ...\n");
    open (IN,"<$database_dir/hhpred/GO/ukwords") 
	or die ("Error: cannot open $database_dir/hhpred/GO/ukwords: $!\n");
    while ($line=<IN>) {
	$line=~/^(\S+)\s+(\d+)/;
	if ($2>0 && $1 ne "transport") {$ukfreq{$1}=$2;}
    }
    close(IN);

    # Read GO file term.txt
    print("Read GO file term.txt ...\n");
    open (IN,"<$database_dir/hhpred/GO/term.txt") 
	or die ("Error: cannot open $database_dir/hhpred/GO/term.txt: $!\n");
    #10	ribosomal chaperone activity	molecular_function	GO:0000005	1	0
    while ($line=<IN>) {
	if ($line=~/^.*?\t(.*?)\tmolecular_function\tGO:(\d+)/) {
	    $N_GOs++;
	    $desc = $1;
	    $GO_ID=$2;
	    if ($2 eq "0005554" || $2 eq "0005488") {next;} # skip "molecular function unknown", "binding"
	    $molfunc{$GO_ID}=$desc;
	    my @words=split(/\s+|-/,$desc);
#	    printf("GO_ID: %-8.8s -> %s\n",$GO_ID,join(", ",@words));
	    foreach $word (@words) {
		$word=~tr/A-Z/a-z/;
		$word=~tr/a-z0-9//cd;
		$word=~s/s$//;
		$word=~s/er$// || $word=~s/ing$// || $word=~s/ly$//;
		if (defined $word2GO{$word}) {
		    push(@{$word2GO{$word}},$GO_ID);
		} else {
		    @{$word2GO{$word}}= ($GO_ID); 
		}
	    }
	}
    }
    close(IN);
    print("Read $N_GOs GO IDs ...\n");
    

    # Read pdb->GO_ID table
    print("Read pdb->GO_ID table ...\n");
    my %pdb2GO;
    my $pdbid;
    my $wrong=0;
    my $ideb=0;
    open (IN,"<$database_dir/hhpred/GO/gene_association.goa_pdb") 
	or die ("Error: cannot open $database_dir/hhpred/GO/gene_association.goa_pdb: $!\n");
    #10	ribosomal chaperone activity	molecular_function	GO:0000005	1	0
    while ($line=<IN>) {
	if ($line=~/^PDB\t(.*?)\t(\S)\t\tGO:(\d+)/) {
	    if (defined $molfunc{$3}) {
		if ($2 eq "@") {$pdbid=lc($1);} else {$pdbid=lc($1)."_$2";}
		if (defined $pdb2GO{$pdbid}) {
		    $pdb2GO{$pdbid} .= " ; $3";
#		    if (++$ideb<=20) {printf("%s -> %s\n",$pdbid,$pdb2GO{$pdbid});}
		} else {
		    $pdb2GO{$pdbid} .= "$3";
#		    if (++$ideb<=20) {printf("%s -> %s\n",$pdbid,$pdb2GO{$pdbid});}
		}
	    }
	} else {
	    printf(STDERR "Error: wrong format in $database_dir/hhpred/GO/gene_association.goa_pdb in line $.\n");
	    if ($wrong++>100) {last;}
	}
    }
    close(IN);
    

    # Get files for Interpro member databases
    my $pfamA  = (glob "$newdbs/pfamA_*")[0];
    my $smart  = (glob "$newdbs/smart_*")[0];
    my $panther = (glob "$newdbs/panther_*")[0];
    my $tigrfam = (glob "$newdbs/tigrfam_*")[0];
    my $pirsf  = (glob "$newdbs/pirsf_*")[0];
    my $supfam = (glob "$newdbs/supfam_*")[0];
    my $CATH   = (glob "$newdbs/CATH_*")[0];
    my $dbs= "$pdbdir $pfamA $smart $panther $tigrfam $pirsf";

    # Remove duplicate databases from @dbs
    my @dbs = split(/\s+/,$dbs);
    my %dbs=();
    for (my $i=0; $i<@dbs; $i++) {
	if (! defined $dbs{$dbs[$i]}) {
	    $dbs{$dbs[$i]}=1;
	} else {
	    $dbs[$i]="";
	}
    }    
 
    # Append /db/scop.hhm or /db/pdb.hhm or /db/cdd.hhm etc. to every database directory
    $dbs="";
    foreach my $db (@dbs) {
	if ($db eq "") {next;}
	if    ($db=~s/\/(cdd|COG|KOG|pfam|smart|cd|pfamA|pfamB)(_\S*)/\/$1$2\/db\/$1.hhm/) {}
	elsif ($db=~s/\/(scop|pdb)([^_]\S*)/\/$1$2\/db\/$1.hhm/) {}
	elsif ($db=~s/\/(panther|tigrfam|pirsf|supfam|CATH)(_\S*)/\/$1$2\/db\/$1.hmm/) {}
	elsif ($db=~s/\/([^\/]+)$/\/$1\/db\/$1.hhm/) {}
	$dbs .= $db." ";
    }
    
    &System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d '$dbs' -o $tmpname.fn.hhr -z 3 -b 3 -Z 6 -B 6 -P 20");

 
    # Read hhsearch results
    open (IN,"<$tmpname.fn.hhr") or die ("Error: cannot open $tmpname.tmp.hhr: $!\n");
    my @lines=<IN>;
    close(IN);

    open (FN,">$basename.fn") or die ("Error: cannot open $basename.fn: $!\n");
    print(FN "PFRMAT FN\n");
    print(FN "TARGET $seqname\n");
    if ($address=~/predictioncenter/i) {
	printf(FN "AUTHOR %s\n",$code{$server});
	print(FN "METHOD $server (http://hhpred.tuebingen.mpg.de)\n");
    } else {
	print(FN "AUTHOR $server (http://hhpred.tuebingen.mpg.de)\n");
    }
              #---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
    print(FN "METHOD Homology-based function prediction by HMM-HMM comparison\n");
    if ($server=~/HHpred3/i) {print(FN "METHOD and transitive profile search\n");}
    print(FN "METHOD The target is compared with the PDB and the Interpro database \n");
    print(FN "METHOD (http://www.ebi.ac.uk/interpro/) using HHsearch. Mappings to GO numbers\n");
    print(FN "METHOD are either provided by the GOA (http://www.ebi.ac.uk/GOA/) and InterPro\n");
    print(FN "METHOD databases or, if these are not available, assigned by weighted word \n");
    print(FN "METHOD counts.\n");
    if ($server=~/HHpred3/i) {
	print(FN "METHOD If no match with probability >=90% is found, our intermediate profile\n");
	print(FN "METHOD search routine HHsenser is employed on the target to boost its \n");
	print(FN "METHOD alignment with remote homologs.\n");
    }
    print(FN "MODEL  1\n");
    
    my $GO="";
    my $i=11;
    my %seen_hit=();
    my %GO2score=(); # scores for GO_IDs
    my %GO2comment=(); # scores of individual words for each GO_ID
    $n=0;            # number of hits with GO assignments found
    while ($n<5) {
	for (; $i<@lines && $lines[$i]!~/^No \d/; $i++) {}
	if ($i>=@lines) {last;}
	$line=$lines[++$i];
	$line =~s/^>(\S+)/$1/;
	my $hitname=$1;
	$lines[$i+1]=~/Probab=(\S+)/;
	$prob = $1;
	print("hitname: $line\n");
	if (defined $seen_hit{$hitname}) {next;}
	$seen_hit{$hitname}=1;
	if ($prob>80 && $hitname=~/^\d\S\S\S(_\S)?$/ && defined $pdb2GO{$hitname}) {
	    $GO = $pdb2GO{$hitname};
	} elsif ($prob>80 && $line=~/ GO:([^;]*)/) {
	    $GO="";
	    $line=$1;
	    while ($line=~s/(\d{7,})//) {
		if (defined $molfunc{$1}) {$GO.=" ; $1";}
	    } 
	}

	# Use frequency-weighted word counts
	if ($GO eq "") {
	    my @words=();     # array with all words in this name + description 
	    my @namewords=(); # array with all words in the name
	    my @descwords=(); # array with all words in the description 
	    my %seen_word=(); # to avoid counting a word twice per hit
	    my $namewords;
	    my %namewords;
	    if ($lines[$i]=~/(.*?);/) {$namewords=$1;} else {$namewords=$lines[$i];}
	    foreach $word (split(/\s+|-/,$namewords)) {
		$word=~tr/A-Z/a-z/;
		$word=~tr/a-z0-9//cd;
		$word=~s/s$//;
		$word=~s/er$// || $word=~s/ing$// || $word=~s/ly$//;
		$namewords{$word}=1;
	    }
	    @words = split(/\s+|-/,$lines[$i]);
	    foreach $word (@words) {
		$word=~tr/A-Z/a-z/;
		$word=~tr/a-z0-9//cd;
		$word=~s/s$//;
		$word=~s/er$// || $word=~s/ing$// || $word=~s/ly$//;

                if ($word eq "" || $word=~/^(in|of|on|up|to|is|or|by|at|as|and|out|for|from|into|onto|has|the|via|have|activity|acting|these|that|which|protein|proteins|domain|unknown|function|hypothetical)$/) {next;}
		my $factor=1;
		if (!defined $namewords{$word}) {$factor=3/scalar(@words);}
		if (defined $seen_word{$word}) {next;}
		$seen_word{$word}=1;
		if (!defined $word2GO{$word}) { # word does not appear in any of the definitions of GO_IDs?
#		    print("Skip $word\n");
		    next;
		} 
#		my  $word_weight = 1E-4 * $factor * $prob*$prob * 1.443*log($N_GOs/scalar(@{$word2GO{$word}}));
		my  $word_weight = 1E-4 * $factor * $prob*$prob;
		if ($ukfreq{$word}) {$word_weight *= ($ukfreq{$word}/17 -1)*($ukfreq{$word}/17 -1);}
		printf("Word='%s'  weight=%6.4f factor=%4.2f\n",$word,$word_weight,$factor);
		foreach $GO_ID (@{$word2GO{$word}}) {
		    if (defined $GO2score{$GO_ID}) {
			$GO2score{$GO_ID} += $word_weight;
			$GO2comment{$GO_ID} .= sprintf("; $word (%5.2f)",$word_weight);
		    } else {
			$GO2score{$GO_ID} = $word_weight;
			$GO2comment{$GO_ID} = sprintf("$word (%5.2f)",$word_weight);
		    }
		}
	    }
	    $lines[++$i]=~s/\s+Score[\S\s]*//;
#	    printf(FN "Comment: No GO number found for %s: %s\n",$hitname,$lines[$i]);
	    next;
	}

	$GO=~s/^ ; //;
	$n++;
	++$i;
	$lines[$i]=~s/\s+Score.*//;
	chomp($lines[$i]);
	printf(FN "GO Molecular Function: %s\n",$GO);
	foreach my $GO_ID (split(/\s*;\s*/,$GO)) {printf(FN "Comment: GO %s '%s'\n",$GO_ID,$molfunc{$GO_ID});}
	printf(FN "Comment: %-10.10s %-60.60s\n",$hitname,$lines[$i]);
	last;
    }

    # Determine GO ID by weighted word counts
    if (scalar(keys(%GO2score)) && $n==0) { # no hits with GO assignment found?
	my @GO_IDs;
	my @scores;
	foreach $GO_ID (keys(%GO2score)) {
	    if ($GO2score{$GO_ID}>=1) {$GO.="; $GO_ID";}
	    push(@GO_IDs,$GO_ID);
	    my @words = split(/(\s+|-)/,$molfunc{$GO_ID});
	    push(@scores,$GO2score{$GO_ID}-0.33*scalar(@words)); 
	}
#	    for (my $k=0; $k<@scores; $k++) {
#		printf("k=%3i  GO_ID:%s  score=%6.3f\n",$k,$GO_IDs[$k],$scores[$k]);
#	    }
	my @k=(0..$#scores);
	my @ks = sort { return $scores[$b]<=>$scores[$a] } @k;

	# For 10 highest scoring GO_IDs print our weight of individual words 
	for (my $k=0; $k<10 && $k<@scores; $k++) {
	    printf("GO: %-8.8s  score = %6.4f  \"%s\"  %s\n",$GO_IDs[$ks[$k]],$scores[$ks[$k]],$molfunc{$GO_IDs[$ks[$k]]},$GO2comment{$GO_IDs[$ks[$k]]});
	}
	
	printf(FN "GO Molecular Function: %s\n",$GO_IDs[$ks[0]]);
	foreach my $GO_ID (split(/\s*;\s*/,$GO_IDs[$ks[0]])) {printf(FN "Comment: GO %s '%s'\n",$GO_ID,$molfunc{$GO_ID});}
	printf(FN "Comment: GO assignment by frequency-weighted word matches\n",$lines[$i]);
    }
    
    print(FN "Prediction techniques: 1.0.0.1.0.0\n");
    print(FN "END\n");
    close(FN);

    # Send message
    &System("cp $tmpname.fn.hhr $tmp_dir");
    print "\nSend function prediction results to $address ...\n";
    &System("perl $bioprogs_dir/hhpred/mail.pl   $address \"Sent $server $seqname FN $id $address\" $basename.fn");
#    &System("perl $bioprogs_dir/hhpred/mail.pl $myaddress \"Sent $server $seqname FN $id $address\" $basename.fn"); 
    print "E-mail has been sent to $address.\n\n";
}




###########################################################################################
# Make domain prediction

if ($server=~/HHpred1/i || $server=~/HHpred3/i || $server=~/test/) {

    my $MINDOMLEN=50; # minimum aligned residues of a domain
    my $MAXOVLAP=20;  # maximum overlap with previously accepted domain
    my $PENALTY=20;   # penalty in percentage points for Pfam vs SCOP hits
    my @domain;       # $domain[$i] = domain assignment (-,1,2,...)
    my @conf;         # $conf[$i]   = confidence value of domain assignment
    my @domains;      # ${$domains[$k]}[$i] = domain assignment for database match $k+1 
    my @probs;        # $probs[$k] = probability for database match $k+1 (including db-specific corrections)
    my @scores;       # $scores[$k] = score for database match $k+1 (including db-specific corrections)
    my @tnames;       # $tnames[$k] is name of k+1st db match
    my $qname;        # 
    my $k=0;          # counts db matches
    my $i;            # counts query residues
    
    # Get files for Interpro member databases
    my $scopdir   = (glob "$newdbs/scop*")[0]; 
    my $pfamAdir  = (glob "$newdbs/pfamA_*")[0];
    my $scopdb  = $scopdir."/db/scop.hhm";
    my $pfamAdb = $pfamAdir."/db/pfamA.hhm";
    
    &System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d '$scopdb' -o $tmpname.dp.hhr -Z 10 -B 10");
#    &System("$hh/hhsearch -cpu $cpus -i $tmpname.hhm -d '$scopdb $pfamAdb' -o $tmpname.dp.hhr -Z 10 -B 10");
    &System("perl $hh/hhrealign.pl -i $tmpname.dp.hhr -o $tmpname.dp.glob.hhr -global -q $tmpname.hhm -d $scopdir $pfamAdir -hhm");
  
    # Read query sequence
    my $qfull="";
    open (QFILE, "<$tmpname.hhm") || die "Error: Couldn't open $tmpname.hhm: $!\n";
    while ($line=<QFILE>) {
	if ($line=~/^>(\S+)/ && $line!~/^>ss_/ && $line!~/^>sa_/ && $line!~/^>aa_/ && $line!~/^>Consensus/) {last;}
    }
    $line=~/^>(\S+)/;
    $qname=$1;
    while ($line=<QFILE>) {
	if ($line=~/^>/ || $line=~/^\#/) {last;}
	$line=~tr/\n\.-//d; 
	$qfull.=$line;
    }
    close(QFILE);
    if ($v>=2) {printf("\nQ(full) %-14.14s %s\n",$qname,$qfull);}
    
    # Parse hhsearch domain assignments for hits $k into arrays @{$domains[$k]}
    $k=0;
    open (IN,"<$tmpname.dp.glob.hhr") or die ("Error: cannot open $tmpname.dp.hhr: $!\n");
    while ($line=<IN>) {
	while ($line && $line!~/^>/) {$line=<IN>;}  # advance to beginning of next alignment
	if (!defined $line) {last;}
	
	# Read name and probability
	$line=~/^>(\S+)/;
	$tnames[$k]=$1;
	$line=<IN>;
	$line=~/^Probab=(\S+).*Aligned_columns=(\S+)/;
	if ($2<$MINDOMLEN) {next;}  # match too short => skip 
	$probs[$k]=0.01*$1;
	$scores[$k]=-$1;
	if ($tnames[$k]=~/^PF/) {$scores[$k]+=$PENALTY;} # if match is to Pfam domain, subtract 20 percentage points!
	
	# Read aligned query residues 
	my $qseq="";
	my $qfirst=0;
	my $qlast=0;
	my $qlength=0;
	my @qres=();
	my $tseq="";
	my $tfirst=0;
	my $tlast=0;
	my $tlength=0;
	my @tres=();
	while (1) {

	    # Scan up to first line starting with Q; stop when line 'No\s+\d+' or 'Done' is found
	    while (defined $line && $line!~/^Q\s(\S+)/) {
		if ($line=~/^No\s+\d/ || $line=~/^Done/) {last;}
		$line=<IN>; next;
	    } 
	    if (!defined $line || $line=~/^No\s+\d/ || $line=~/^Done/) {last;}
	    	    
	    # Scan up to first line that is not secondary structure line or consensus line	
	    while (defined $line && $line=~/^Q\s+(ss_|sa_|aa_|Consens|Cons-)/) {$line=<IN>;} 
	    
	    # Read next block of query sequence
	    if ($line!~/^Q\s+(ss_|sa_|aa_|Consens|Cons-)/ && $line=~/^Q\s*(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s+\((\d+)/) {
		$qname=$1;
		if (!$qfirst) {$qfirst=$2;} # if $qfirst is undefined then this is the first alignment block -> set $qfirst to $1
		if (!$qseq) {$qseq=$3;} else {$qseq.=$3;}
		$qlast=$4; 
		$qlength=$5;
		$line=<IN>;
	    } else {
		die("Error: wrong format in $tmpname.dp.hhr, line $.\n");
	    }

	    # Scan up to first line starting with T	
	    while (defined $line && $line!~/^T\s+(\S+)/) {$line=<IN>;} 
	    
	    # Scan up to first line that is not secondary structure line or consensus line	
	    while (defined $line && $line=~/^T\s+(ss_|sa_|aa_|Consens|Cons-)/)  {$line=<IN>;} 
	    
	    # Read next block of template sequences
	    if ($line!~/^T\s+(ss_|sa_|aa_|Consens|Cons-)/ && $line=~/^T\s*(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s+\((\d+)/){
		$tnames[$k]=$1;
		if (!$tfirst) {$tfirst=$2;} # if $tfirst is undefined then this is the first alignment block -> set $tfirst to $1
		if (!$tseq) {$tseq=$3;} else {$tseq.=$3;}
		$tlast=$4; 
		$tlength=$5;
		$i++;
	    } else {
		die("Error: wrong format in $tmpname.dp.hhr, line $.\n");
	    }
	    $line=<IN>;
	} 
	if ($v>=3 || length($qseq)!=length($tseq)) {
	    print("\n");
	    printf("Q%i: %-10.10s %3i-%-3i (%3i) %s\n",$k,$qname,$qfirst,$qlast,$qlength,$qseq,);
	    printf("T%i: %-10.10s %3i-%-3i (%3i) %s\n",$k,$tnames[$k],$tfirst,$tlast,$tlength,$tseq,);
	    if (length($qseq)!=length($tseq)) {die("Error: different lengths of query and template.\n");}
	}
	
	# Create strings of same length as $qfull that mark the found domain by X's
	@qres=unpack("C*",$qseq);
	@tres=unpack("C*",$tseq);
	$qseq="";
	my $gaplen=0;
	for ($i=0; $i<@qres; $i++) {
	    if ($tres[$i]==45) {
		$gaplen++;
	    } else {
		# Replace inserts in query longer than 40 residues with gaps in query
		if ($gaplen>=$MINDOMLEN) {
		    my $gap = ('-') x $gaplen;
		    $qseq=~s/.{$gaplen}$/$gap/;   
		}
		$gaplen=0;
	    }
	    if ($qres[$i]!=45) {$qseq.="X";}
	}
	$qseq = (("-")x($qfirst-1)).$qseq.(("-")x($qlength-$qlast)); # left_gap . domans_seq . right_gap
	if ($v>=3) {
	    print("\n");
	    printf("Qfull%i: %-10.10s %s\n",$k,$qname,$qfull);
	    printf("D    %i: %-10.10s %s\n",$k,$qname,$qseq);
	}

	@qres = unpack("C*",$qseq);
	for ($i=0; $i<@qres; $i++) {
	    if ($qres[$i]==45) {$qres[$i]=0;} else {$qres[$i]=$k+1;}
	}
	@{$domains[$k]} = @qres;
	$k++; 
    }
    close(IN);

    # Sort hits by @scores vector (necessary due to $PENALTY on Pfam matches)
    &Sort(\@scores,\@probs,\@domains,\@tnames);

    # Calculate domain assigment for query from @{$domains[$k]} and write into @domain
    my @qres = split(//,$qfull); 
    @domain = (0.0) x scalar(@{$domains[0]});
    @conf   = (0.0) x scalar(@{$domains[0]});
    my $n=0;  # domain number
    my $templates="";
    for ($k=0; $k<@scores; $k++) {
	my $overlap=0;
	my $len=0;
	for ($i=0; $i<@{$domains[$k]}; $i++) {
	    if (${$domains[$k]}[$i]) {
		if ($domain[$i]) {
		    $overlap++;
		} else {
		    $len++;
		}
	    }
	}
	
	# Debug
	if ($v>=3) {
	    printf("\nk=%i hit=%s overlap=%i  len=%i\n",$k+1,$tnames[$k],$overlap,$len);
	    printf("Domain %s\n",pack("C*",map($_+48,@{$domains[$k]})) );
	    printf("Total  %s\n",pack("C*",map($_+48,@domain)) );
	}
	
	if ($overlap>$MAXOVLAP) {next;} # match too much overlap with prev. accepted domain => skip
	if ($len<$MINDOMLEN) {next;} # match too short => skip
	
	# Database match $k accepted => update @domain and @conf
	$n++;
	$templates .= $tnames[$k]." ";
	$tnames[$n-1] = $tnames[$k];
	for ($i=0; $i<@{$domains[$k]}; $i++) {
	    if (${$domains[$k]}[$i]) {
		if ($domain[$i]) {
		    $conf[$i] = $conf[$i]/($conf[$i]+$probs[$k]); # reduce reliability value in overlap region
		} else {
		    $domain[$i] = $n;
		    $conf[$i] = $probs[$k];
		}
	    }
	}
	
	if ($v>=3) {
	    printf("Total  %s\n",pack("C*",map($_+48,@domain)) );
	    printf("Conf   %s\n",pack("C*",map(int(9.99*$_)+48,@conf)) );
	}
    }
    
    # Fill holes by sharing between domains
    my $gaplen=0;
    my $len = scalar(@domain);
    $domain[$len]=0; $conf[$len]=0;
    for ($i=0; $i<=$len; $i++) {
	if ($i<$len && $domain[$i]==0) {
	    $gaplen++;	    
	} else {
	    if ($gaplen>0 && $gaplen<$MINDOMLEN) {
		# Share gap between bordering two domains
		my $n1 = $domain[$i-$gaplen-1];
		my $n2 = $domain[$i];
		my $conf1 = $conf[$i-$gaplen-1];
		my $conf2 = $conf[$i];
		my $w1 = ($i-$gaplen-1<0? 0.01 : $tnames[$n1]=~/^PF/? 0.8: 0.2);
		my $w2 = ($i>=$len?       0.01 : $tnames[$n2]=~/^PF/? 0.8: 0.2);
		printf("Gap %i-%i i=$i gaplen=$gaplen :  dom1=%i conf1=%4.2f w1=%4.2f;   dom2=%i conf2=%4.2f w2=%4.2f\n",$i-$gaplen,$i-1,$n1,$conf1,$w1,$n2,$conf2,$w2);
	
		# Share unequally between Pfam and SCOP domains?
		my $w = $w1+$w2; 
		my $j = $i - int($w2/$w*$gaplen);
		for (my $ii=$i-$gaplen; $ii<$j; $ii++) {
		    $domain[$ii] = $n1; 
		    $conf[$ii] = ($j-0.5-$ii)*$conf1/($gaplen*$w1/$w);
		}
		for (my $ii=$j; $ii<$i; $ii++) {
		    $domain[$ii] = $n2;
		    $conf[$ii] = ($ii-$j+0.5)*$conf2/($gaplen*$w2/$w);
		}
 	    }
	    $gaplen=0;
	}    
    }

    # Transform @domain elements from int to char
    @domain  = map($_==0? '-' :chr($_+48), @domain); 

    # Write domain prediction file
    open (DP,">$basename.dp") or die ("Error: cannot open $basename.tmp.hhr: $!\n");
    print(DP "PFRMAT DP\n");  # domain prediction format
    print(DP "TARGET $seqname\n");
    if ($address=~/predictioncenter/i) {
	printf(DP "AUTHOR %s\n",$code{$server});
	print(DP "METHOD $server (http://hhpred.tuebingen.mpg.de)\n");
    } else {
	print(DP "AUTHOR $server (http://hhpred.tuebingen.mpg.de)\n");
    }
                  #---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
    if ($server=~/HHpred3/i) {
	print(DP "METHOD Homology-based domain prediction by HMM-HMM comparison and transitive\n");
	print(DP "METHOD profile search.\n");
	print(DP "METHOD The target is compared with SCOP (http://scop.mrc-lmb.cam.ac.uk/scop)\n");
	print(DP "METHOD and Pfam (http://www.sanger.ac.uk/Software/Pfam/) using HHsearch.\n");
	print(DP "METHOD If no match with probability >=90% is found, our intermediate profile\n");
	print(DP "METHOD search routine HHsenser is employed on the target to boost its \n");
	print(DP "METHOD alignment with remote homologs.\n");
    } else {
	print(DP "METHOD Homology-based domain prediction by HMM-HMM comparison. \n");
	print(DP "METHOD The target is compared with SCOP (http://scop.mrc-lmb.cam.ac.uk/scop)\n");
	print(DP "METHOD and Pfam (http://www.sanger.ac.uk/Software/Pfam/) using HHsearch.\n");
    }
    print (DP "MODEL  1\n");
    printf(DP "PARENT %s\n",$templates);
    for ($i=0; $i<$len; $i++) {  # don't use @domain, has been extended by 1 element
	printf(DP "%3i %s %s %4.2f\n",$i+1,$qres[$i],$domain[$i], &min(1.0,$conf[$i]) );
    }
    print(DP "END\n");
    close(DP);

    # Send message
    &System("cp $tmpname.dp.hhr $tmp_dir");
    print "\nSend domain prediction results to $address ...\n";
    &System("perl $bioprogs_dir/hhpred/mail.pl   $address \"Sent $server $seqname DP $id $address\" $basename.dp");
#    &System("perl $bioprogs_dir/hhpred/mail.pl $myaddress \"Sent $server $seqname DP $id $address\" $basename.dp"); 
    print "E-mail has been sent to $address.\n\n";
}

&System("rm -rf $tmpdir"); 

exit(0);



######################################################################
# Run MODELLER
######################################################################
sub Modeller() 
{
    my $modelfile=$_[0];
    my $k;
    if (defined $_[1]) {$k=$_[1];}
    my $NMODELS=3;
    my $offset;
    
    # Change sequence name to id_temp and get templates -> $templates
    $templates="";
    my $knowns="";
    open (IN, "<$tmpname.pir") or die ("Error: cannot open $tmpname.pir: $!\n");
    my @lines = <IN>;
    close(IN);
    $lines[0]=~s/^>P1;.*/>P1;$name/;
    for (my $i=0; $i<@lines; $i++) {
	if ($lines[$i]=~/^sequence:.*?:\s*(\d+)\s*:/) {
	    $offset=$1-1;
	    $lines[$i]=~s/^sequence:.*?:/sequence:$name:/; # replace sequence name with id
	}
	elsif ($lines[$i]=~/^structureX:/) {
	    $lines[$i-1]=~/>P1;(\S+)/;
	    $knowns .= " '$1'";
	    $templates .= " $1";
	} 
    }
    $templates=~s/^ //;
    open (OUT, ">$tmpname.pir") or die ("Error: cannot open $tmpname.pir: $!\n");
    print(OUT @lines);
    close(OUT);

    # Write the top-file
    open( TOP, ">$tmpname.modeller.top" ) or die("Cannot open: $!");
    print TOP "INCLUDE\n";
    print TOP "SET OUTPUT_DIRECTORY = '$tmpdir'\n";
    print TOP "SET DIRECTORY = '$tmpdir'\n";
    print TOP "SET OUTPUT_CONTROL = 1 1 1 1 1\n";
    print TOP "SET ALNFILE = '$tmpname.pir'\n";
    print TOP "SET KNOWNS = $knowns\n";
    print TOP "SET SEQUENCE = '$name'\n";
    print TOP "SET ATOM_FILES_DIRECTORY = '$pdbdir'\n";
    print TOP "SET STARTING_MODEL = 1\n";
    print TOP "SET ENDING_MODEL = $NMODELS\n";
    print TOP "CALL ROUTINE = 'model'\n";
    print TOP "WRITE_MODEL FILE = '$modelfile', OUTPUT_DIRECTORY = '$tmpdir'\n";
    close (TOP) or die("Cannot close: $!");
    
    system("chmod 777 $tmpname.pir");
    system("chmod 777 $tmpname.modeller.top");
    
    # Run modeller 
    &System("cd $tmpdir ; $modeller $tmpname.modeller.top");
    if (!-e "$tmpname.mod") {
	print("WARNING: MODELLER failed! See log file $tmpname.modeller.log\n\nBuilding single-template rough model...\n");
	&System("perl $hh/hhmakemodel.pl $tmpname.tmp.hhr -m $k -q $tmpname.a3m -v -ts $tmpname.mod -d $pdbdir");

    } else {
	
	my $min=+1E8;
	my $imin=1;
	my $line;
	for (my $i=1; $i<=$NMODELS; $i++) { 
	    open(IN,"<$tmpname.B9999000$i.pdb") || die("Error: can't open $tmpname.B9999000$i.pdb");
	    while ($line=<IN>) {
		if ($line=~/REMARK MODELLER OBJECTIVE FUNCTION:\s*(\S+)/) {last;}
	    }
	    if ($1<$min) {$min=$1; $imin=$i;}
	    close(IN);
	}
	
	&System("cp $tmpname.B9999000$imin.pdb $tmpname.mod");
    }
    &System("rm $tmpname.ini $tmpname.rsr $tmpname.sch $tmpname.V999* $tmpname.D000*");    
    # Add TER line
    &System("perl $bioprogs_dir/perl/repair_pdb.pl $tmpname.mod $offset > /dev/null 2>&1");


    return;
}

######################################################################
# Add markup for CASP TS format
######################################################################
sub WriteDomain()
{
    my $modelfile=$_[0];
    my $k=$_[1];
    push(@modellines,sprintf("SCORE  %5.3f\n",0.01*$prob[$k]) );
    push(@modellines,sprintf("PARENT $templates\n") );
    open (IN, "<$modelfile") or die ("Error: cannot open $modelfile: $!\n");
    my @lines = <IN>;
    close IN;
    shift(@lines); # Drop first two lines
    shift(@lines); 
    pop(@lines);   # Drop the last line: END
    @modellines = (@modellines, @lines); # append coordinates for domain
    # Add PIR alignment to alignment array
    open(PIRFILE,"<$tmpname.pir");
    my $line;
    while ($line=<PIRFILE>) {
	push(@alignments,"ALIGNM ".$k." ".$line);
    }
    close(PIRFILE);
}


##################################################################################
sub SetMethodDescription()
{
    if ($server=~/HHpred0/) {
	$method{$server} ="METHOD Homology-based, single-template structure and 
METHOD function prediction by HMM-HMM comparison and 2ndary structure scoring
METHOD 1. HHpred builds a multiple alignment from the target sequence with 
METHOD PSI-BLAST (up to 8 rounds with E-value threshold 1E-3). PSIPRED 
METHOD (D. Jones) is used for secondary structure prediction. 
METHOD 2. The alignment is converted to an HMM and compared with a database 
METHOD of HMMs derived from representative sequences in the PDB and SCOP 
METHOD (70% maximum sequence identity, updated weekly). 
METHOD 3. The alignment for the best match is used to generate a 3D model by 
METHOD matching the coordinates of the template C_alpha atoms to the target.
REMARK Soding, J. (2005) Protein homology detection by HMM-HMM comparison.
REMARK Bioinformatics 21, 951-960.
REMARK Contact: johannes.soeding\@tuebingen.mpg.de
";
    } elsif ($server=~/HHpred1/) {
	$method{$server} ="METHOD Homology-based, single-template structure and 
METHOD function prediction by HMM-HMM comparison and 2ndary structure scoring
METHOD 1. HHpred builds a multiple alignment from the target sequence with 
METHOD PSI-BLAST (up to 8 rounds with E-value threshold 1E-3). PSIPRED 
METHOD (D. Jones) is used for secondary structure prediction. 
METHOD 2. The alignment is converted to an HMM and compared with a database 
METHOD of HMMs derived from representative sequences in the PDB. 
METHOD (70% maximum sequence identity, updated weekly). 
METHOD 3. The alignment for the best match is submitted to MODELLER (A. Sali 
METHOD et al.) to generate a homology model.
REMARK Soding, J. (2005) Protein homology detection by HMM-HMM comparison.
REMARK Bioinformatics 21, 951-960.
REMARK Contact: johannes.soeding\@tuebingen.mpg.de
";
    } elsif ($server=~/HHpred2/) {
#---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
	$method{$server} ="METHOD Homology-based structure and function prediction by HMM-HMM comparison, 
METHOD secondary structure scoring, and multiple-template selection
METHOD (Steps 1 and 2 are the same as for HHpred1)
METHOD 1. HHpred builds a multiple alignment from the target sequence with 
METHOD PSI-BLAST (up to 8 rounds with E-value threshold 1E-3). PSIPRED 
METHOD (D. Jones) is used for secondary structure prediction. 
METHOD 2. The alignment is converted to an HMM and compared with a database 
METHOD of HMMs derived from representative sequences in the PDB. 
METHOD 3. The top 20 matches are clustered by UPGMA into a forest of separate 
METHOD trees, based on the structure comparison scores of TM-align (Zhang & 
METHOD Skolnick). Each template is aligned to the other templates in its tree 
METHOD using MUSTANG (AS. Konagurthu et al.). The corresponding alignments are 
METHOD merged into a super-alignment in a master-slave fashion and an HMM is 
METHOD generated. The target HMM is compared with these HMMs and the best match 
METHOD defines a set of templates and an alignment for modelling.
METHOD 4. MODELLER (A. Sali et al.) is used to generate a homology model from 
METHOD this alignment.
REMARK Soding, J. (2005) Protein homology detection by HMM-HMM comparison.
REMARK Bioinformatics 21, 951-960.
";
    } elsif ($server=~/HHpred3/) {
	$method{$server} ="METHOD Homology-based structure and function prediction by HMM-HMM comparison, 
METHOD intermediate profile searching, and multiple template selection
METHOD (Steps 1, 2, 4, and 5 are the same as for HHpred2)
METHOD 1. HHpred builds a multiple alignment from the target sequence with 
METHOD PSI-BLAST (up to 8 rounds with E-value threshold 1E-3). PSIPRED 
METHOD (D. Jones) is used for secondary structure prediction. 
METHOD 2. The alignment is converted to an HMM and compared with a database 
METHOD of HMMs derived from representative sequences in the PDB. 
METHOD 3. If the top hit has a probability of less than 90\% to be homologous, 
METHOD our intermediate profile search method HHsenser is used to augment the 
METHOD initial target alignment.
METHOD 4. The top 20 matches are clustered by UPGMA into a forest of separate 
METHOD trees, based on the structure comparison scores of TM-align (Zhang & 
METHOD Skolnick). Each template is aligned to the other templates in its tree 
METHOD using MUSTANG (AS. Konagurthu et al.). The corresponding alignments are 
METHOD merged into a super-alignment in a master-slave fashion and an HMM is 
METHOD generated. The target HMM is compared with these HMMs and the best match 
METHOD defines a set of templates and an alignment for modelling.
METHOD 5. MODELLER (A. Sali et al.) is used to generate a homology model from 
METHOD this alignment.
REMARK Soding, J. (2005) Protein homology detection by HMM-HMM comparison.
REMARK Bioinformatics 21, 951-960.
REMARK Soding, J. et al. (2006) HHsenser: exhaustive transitive profile search
REMARK using HMM-HMM comparison. NAR web server issue.
REMARK Contact: johannes.soeding\@tuebingen.mpg.de
";
    } elsif ($server=~/BayesHH/) {
#---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
	$method{$server} ="METHOD Homology-based structure and function prediction by HMM-HMM comparison
METHOD and Bayesian sampling of target-template alignment and 3D structure.
METHOD (Steps 1 to 4 are the same as for HHpred3)
METHOD 1. BayesHH builds a multiple alignment from the target sequence with 
METHOD PSI-BLAST (up to 8 rounds with E-value threshold 1E-3). PSIPRED 
METHOD (D. Jones) is used for secondary structure prediction. 
METHOD 2. The alignment is converted to an HMM and compared with a database 
METHOD of HMMs derived from representative sequences in the PDB.
METHOD 3. If the top hit has a probability of less than 90\% to be homologous, 
METHOD our intermediate profile search method HHsenser is used to augment the 
METHOD initial target alignment.
METHOD 4. The top 20 matches are clustered by UPGMA into a forest of separate 
METHOD trees, based on the structure comparison scores of TM-align (Zhang & 
METHOD Skolnick). Each template is aligned to the other templates in its tree 
METHOD using MUSTANG (AS. Konagurthu et al.). The corresponding alignments are 
METHOD merged into a super-alignment in a master-slave fashion and an HMM is 
METHOD generated. The target HMM is compared with these HMMs and the best match 
METHOD defines a set of templates and an alignment for modelling.
METHOD 5. The best match defines a set of templates to be used for comparative 
METHOD modelling: The structure-based matrix with log-odds scores describing 
METHOD the structural match of model structure residues with templates residues
METHOD is added to the sequence-based matrix describing the matching of 
METHOD profile-columns. Stochastic backtracing samples alignments best 
METHOD compatible with both sequence-based and structure-based information.
METHOD MODELLER is employed to sample a new structure for these alternative 
METHOD alignments and this model structure in turn is used for sampling new
METHOD alignments. During this process, the weight of the sequence-based
METHOD log-odds scores are exponentially reduced until the sampled model
METHOD structures converge to a stable structure.
REMARK Habeck, M. and Soding, J., unpublished.
REMARK Soding, J. (2005) Protein homology detection by HMM-HMM comparison.
REMARK Bioinformatics 21, 951-960.
REMARK Soding, J. et al. (2006) HHsenser: exhaustive transitive profile search
REMARK using HMM-HMM comparison. NAR web server issue.
REMARK Contact: michael.habeck and johannes.soeding \@tuebingen.mpg.de
";
    } else {
	$method{$server}="METHOD $server (http://hhpred.tuebingen.mpg.de)\n";
    }
} 

##################################################################################
# Sort several arrays according to array0:  &Sort(\@array0,...,\@arrayN)
##################################################################################
sub Sort() 
{
    my $p_array0 = $_[0];
    my @index=();
    @index = (0..$#{$p_array0});
    @index = sort { ${$p_array0}[$a] <=> ${$p_array0}[$b] } @index;
    foreach my $p_array (@_) {
	my @dummy = @{$p_array};
	@{$p_array}=();
	foreach my $i (@index) {
	    push(@{$p_array}, $dummy[$i]);
	}
    }
}

##################################################################################
sub System 
{
    print("\$ $_[0]\n");
    system($_[0]);
}

# Minimum
sub min {
    my $min = shift @_;
    foreach (@_) {
	if ($_<$min) {$min=$_} 
    }
    return $min;
}

