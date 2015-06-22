#!/usr/bin/perl -w
#
# hhpred_update_ipro_calc.pl
# Calculation of the script hhpred_update_ipro.pl to run on the queue

use strict;
use lib "/cluster/scripts/update_scripts/hhpred";
use UpdatePath;

$|= 1; # Activate autoflushing on STDOUT
 
# Member databases that will be extracted from InterPro
my @db = ("panther",  "tigrfam", "pirsf", "supfam", "CATH" ); 

# Variables/constants
my $v=4;
my $target_dir="/cluster/tmp/db_update/databases/ipro";

my $logfile="/cluster/user/manager/log/db_update/hhpred_update_ipro_calc.log";

my $hmmer="$bioprogs_dir/hmmer/binaries";

my $line;         # input line
my @lines;        # to read in a whole file at once
my $acc;          # accession code of HMM
my $name;         # single-word name of HMM
my $desc;         # DESC record of HMM
my $id;           # 
my $IPR;          # InterPro ID
my $db;           # Takes values $db[0] ... $db[4]
my $i;
my $n;
my $max_hmms_per_db=100000;
my $dbcat = " ".join(" ",@db)." ";
my $date;

# Options from command line
my $options="";
for (my $i=0; $i<@ARGV; $i++) {$options.=" $ARGV[$i] ";}

if ($options=~s/\s+-date\s+(\S+)/ /g) {$date=$1;}
if ($options=~s/\s+-target\s+(\S+)/ /g) {$target_dir=$1;}

my $ipr_dir = "$target_dir/iprscan/data";
chdir($ipr_dir) || die("Can't change to $ipr_dir: $!\n");

open (LOG, ">$logfile") or die ("Cannot open $logfile!");

# Read tables IPR_ID -> abstracts and member_db_id -> IPR_ID 
print LOG "Read abstracts and InterPro ids from interpro.xml\n";
my %id2ipr;  
my %ipr2abstract; 
my $ipr=""; 
my $abstract;
my $dbkey;
open (INFILE, "<interpro.xml") || die("ERROR: cannot open: $!\n");
while ($line=<INFILE>) {
    if    ($line=~/^\s*<interpro id=\"(\S+)\"/) {$ipr=$1;}
    elsif ($line=~/^\s*<abstract>/)  {
	$abstract="";
	while ($line=<INFILE>) {
	    if ($line=~/^\s*<\/abstract>/) {last;}
	    $abstract.=$line;
	}
    }
    elsif ($line=~/^\s*<member_list>/)  {
	while ($line=<INFILE>) {
	    if ($line=~/dbkey=\"(\S+)\"/) {
		$dbkey=$1;
		$dbkey=~s/^G3D\.//; # G3D.1.10.1200.10 -> 1.10.1200.10
		$id2ipr{$dbkey}=$ipr;
	    } else {
		last;
	    }
	}
    }
    elsif ($line=~/^\s*<\/interpro>/) {
	chomp($abstract);
	$abstract =~s/\s+/ /g;          # remove newlines and multiple spaces
	$abstract =~s/<\/?taxon.*?>//g;    # remove xml tags
	$abstract =~s/<\/?cite.*?>//g;     # remove xml tags
	$abstract =~s/<\/?db_xref db=\"(\S+?)\" dbkey=\"(\S+)\"\/>/$2 from $1/g;  # remove xml tags
	$abstract =~s/&lt;p&gt;/  /g;   # remove html tags
	$abstract =~s/&lt;\/p&gt;//g;   # remove html tags
	$abstract =~s/&lt;sub&gt;/_/g;  # remove html tags
	$abstract =~s/&lt;sup&gt;/^/g;  # remove html tags
	$abstract =~s/&lt;.{0,4}&gt;//g;  # remove html tags
	$ipr2abstract{$ipr}=$abstract;
    }
}
close(INFILE);

# Read short_names.dat into hash
chdir($target_dir) || die("Can't change to $target_dir: $!\n");
print LOG "Read short_names.dat into hash\n";
my %IPR;  # InterPro IDs for short_names
open (INFILE, "<short_names.dat") || die("ERROR: cannot open: $!\n");
while ($line=<INFILE>) {
    $line=~/^(\S+)\s+(\S+)/;
    $IPR{$2}=$1;
}
close(INFILE);

# Read names.dat into hash
print LOG "Read names.dat into hash\n";
my %descriptions;  # DESCriptions for $IPR
open (INFILE, "<names.dat") || die("ERROR: cannot open: $!\n");
while ($line=<INFILE>) {
    $line=~/^(\S+)\s+(\S+)/;
    $descriptions{$1}=$2;
}
close(INFILE);

# Read interpro2go into hash
print LOG "Read interpro2go into hash\n";
my %GO;
open (INFILE, "<interpro2go") || die("ERROR: cannot open: $!\n");
while ($line=<INFILE>) {
    if ($line=~/^InterPro:(\S+)\s+.*?>\s+GO:(.*)\s+;\s+GO:(\d+)/) {
	if ($3 ne "0005554" && $3 ne "0005488") { # "molecular function unknown", "binding"
	    my $desc=$2;
	    my $GOID=$3;
	    $desc=~tr/,//d;
	    if (! defined $GO{$1}) {
		$GO{$1}="GO: $GOID $desc";
	    } else {
		$GO{$1}.=", $GOID $desc";
	    }
	}
#	if ($1 eq "IPR011772") {print("$GO{$1}\n");}
    }
}
close(INFILE);

##############################################################################
# Update Panther
if ($dbcat=~/ (panther) /) {
    $db = $1;
    
    # Read names/descriptions file
    print LOG "\nRead Panther/globals/names.tab into hash\n";
    my %pantherdesc;  # DESCriptions for pantherid
    my $family_not_named=0;
    open (INFILE, "<$ipr_dir/Panther/globals/names.tab") || die("ERROR: cannot open: $!\n");
    # PTHR11668.SF57.mod     SERINE/THREONINE PROTEIN PHOSPHATASE 2A
    while ($line=<INFILE>) {
	if ($line=~/^(PTHR\d+)\.(\w+)\.mod\s+(.*)/) {
	    $line=~/^(PTHR\d+)\.(\w+)\.mod\s+(.*\S)/;
	    my $id  = $1;
	    my $ext = $2;
	    my $desc = $3;
	    
	    # Family name/description?
	    if ($ext eq "mag") { 
		if ($desc=~/FAMILY NOT NAMED/) {
		    $pantherdesc{$id}="";
		    $family_not_named=1;
		} else {
		    $pantherdesc{$id}=$desc;
		    $family_not_named=0;
		}
		
		# If family not named, add descriptions from SUBfamilies together
	    } else {
		my $desc1=$desc;
		$desc1=~s/\W/./g;
		if ($family_not_named && $pantherdesc{$id}!~/$desc1/ && $desc!~/NOT NAMED/) {
		    if ($pantherdesc{$id} eq "") {
			$pantherdesc{$id} = $desc;
		    } else {
			$pantherdesc{$id} .= ", ".$desc;
		    }
		}
	    }
	} else {
	    print LOG "No match: line = $line";
	}
    }
    close(INFILE);
    
    # Read all HMMER files in books directories and concatenate into $db.tmp
    my @books = (glob "$ipr_dir/Panther/books/PTHR*");
    $n=0;
    foreach my $book (@books) {
	if ($n++>$max_hmms_per_db) {last;}
	print LOG "Reading $book ...  ";
	open (INFILE, "<$book/hmmer.hmm") || die("ERROR: cannot open: $book/hmmer.hmm!\n");
	$line=<INFILE>;
	if ($line!~/^HMMER/) {
	    # File in binary format; needs to be converted to ASCII
	    close(INFILE);
	    &System("$hmmer/hmmconvert -F $book/hmmer.hmm $book/hmmer.ascii");
	    open (INFILE, "<$book/hmmer.ascii") || die("ERROR: cannot open: $book/hmmer.ascii!\n");
	    $line=<INFILE>;
	}
	@lines=();
	push(@lines,$line);
	while ($line=<INFILE>) {
	    if ($line=~/^NAME/) {
		$line=~/^NAME  .*\/(PTHR\d+)\//;
		$acc = $1;
		push(@lines,"ACC   $acc\n");
		if (defined $id2ipr{$acc}) {
		    $line = "DESC  ".$pantherdesc{$acc}."; InterPro: ".$id2ipr{$acc}." ".$ipr2abstract{$id2ipr{$acc}};  # add description 
		    if (defined $GO{$id2ipr{$acc}} && $GO{$id2ipr{$acc}} ne "") {
			$line .= "; ".$GO{$id2ipr{$acc}};
		    }
		} else {
		    $line = "DESC  ".$pantherdesc{$acc};  # add description 
		}
		$line .= ".\n";
	    }
	    push(@lines,$line);
	}
	close(INFILE);
	print LOG "writing edited file to $target_dir/$db"."_$date/$acc.tmp ... \n";
	open (OUTFILE, ">$target_dir/$db"."_$date/$acc.tmp") || die("ERROR: cannot open: $target_dir/$db"."_$date/$acc.tmp!\n");
	foreach $line (@lines) {
	    print(OUTFILE $line);
	}
	close(OUTFILE);
	&System("$hh/addpsipred.pl $target_dir/$db"."_$date/$acc.tmp $target_dir/$db"."_$date/$acc.hmm -hmm");
	print LOG "and writing model with predicted SS to $target_dir/$db"."_$date/$acc.hmm \n\n";
	
	# Make h.hhm file
	&System("$hh/hhmake -v 1 -i $target_dir/$db"."_$date/$acc.hmm -o $target_dir/$db"."_$date/$acc.hhm");
	&System("cd $target_dir/$db"."_$date/ ; rm -f $acc.ss $acc.ss2 $acc.tmp $acc.mtx");
    }

    printf LOG "Time %s",`date`;
    print LOG "\n\n";
    
    # Add PSIPRED secondary structure prediction (do SS prediction on the CLUSTER)
#    &System("$bioprogs_dir/hhpred/globjobs.pl '$target_dir/$db"."_$date/*.tmp' '$hh/addpsipred.pl $file $base.hmm -hmm ; echo \"Done\"' -max 10");
}



##############################################################################
# Update TIGRFAMs
if ($dbcat=~/ (tigrfam) /) {
    $db = $1;


    # Read HMMER file, delete short_name in DESC record and do SS prediction
    if (!-e "$target_dir/$db"."_$date/") {
	mkdir("$target_dir/$db"."_$date/"); # (do SS prediction on this node)
    }
    $n=0;
    print LOG "Reading $ipr_dir/TIGRFAMs_HMM.LIB ...";
    open (INFILE, "<$ipr_dir/TIGRFAMs_HMM.LIB") || die("ERROR: cannot open: $!\n");
    $line=<INFILE>;
    if ($line!~/^HMMER/) {
	# File in binary format; needs to be converted to ASCII
	close(INFILE);
	&System("$hmmer/hmmconvert -F $ipr_dir/TIGRFAMs_HMM.LIB $ipr_dir/TIGRFAMs_HMM.ascii");
	open (INFILE, "<$ipr_dir/TIGRFAMs_HMM.ascii") || die("ERROR: cannot open: $!\n");
	$line=<INFILE>;
    }
    @lines=();
    push(@lines,$line);
    while ($line=<INFILE>) {
	if ($line=~/^ACC /) {
	    $line=~/^ACC\s+(\S+)/;
	    $acc = $1;
	} elsif ($line=~/^NAME/) {
	    $line=~/^NAME\s+(\S+)/;
	    $name = $1;
	} elsif ($line=~/^DESC/) {
	    $line=~/^DESC\s+\S+:\s+(.*\S)/;
	    $line = "DESC  $1";
	    if (defined $id2ipr{$acc}) {
		$line .= "; InterPro: ".$id2ipr{$acc}." ".$ipr2abstract{$id2ipr{$acc}};  # add description 
		if (defined $GO{$id2ipr{$acc}} && $GO{$id2ipr{$acc}} ne "") {
		    $line .= "; ".$GO{$id2ipr{$acc}};
		}
	    }
	    $line .= ".\n";
	}
	push(@lines,$line);
	if ($line=~/^\/\//) {
	    if ($n++>$max_hmms_per_db) {last;}
	    print LOG "\nWriting edited file to $target_dir/$db"."_$date/$acc.tmp \n";
	    open (OUTFILE, ">$target_dir/$db"."_$date/$acc.tmp") || die("ERROR: cannot open: $!\n");
	    foreach $line (@lines) {
		print(OUTFILE $line);
	    }
	    close(OUTFILE);
	    &System("$hh/addpsipred.pl $target_dir/$db"."_$date/$acc.tmp $target_dir/$db"."_$date/$acc.hmm -hmm");
	    @lines=();
	    
	    # Make h.hhm file
	    &System("$hh/hhmake -v 1 -i $target_dir/$db"."_$date/$acc.hmm -o $target_dir/$db"."_$date/$acc.hhm");
	    &System("cd $target_dir/$db"."_$date/ ; rm -f $acc.ss $acc.ss2 $acc.tmp $acc.mtx");
	}
    }
    close(INFILE);
    printf LOG "Time %s",`date`;
    print LOG "\n\n";
}


##############################################################################
# Update PIRSF
if ($dbcat=~/ (pirsf) /) { 
    $db = $1;
        
    # Read HMMER file and do SS prediction
    if (!-e "$target_dir/$db"."_$date/") {
	mkdir("$target_dir/$db"."_$date/"); # (do SS prediction on this node)
    }
    $n=0;
    print LOG "Reading $ipr_dir/sf_hmm ...";
    open (INFILE, "<$ipr_dir/sf_hmm") || die("ERROR: cannot open: $!\n");
    $line=<INFILE>;
    if ($line!~/^HMMER/) {
	# File in binary format; needs to be converted to ASCII
	close(INFILE);
	&System("$hmmer/hmmconvert -F $ipr_dir/sf_hmm $ipr_dir/sf_hmm.ascii");
	open (INFILE, "<$ipr_dir/sf_hmm.ascii") || die("ERROR: cannot open: $!\n");
	$line=<INFILE>;
    }
    @lines=();
    push(@lines,$line);
    while ($line=<INFILE>) {
	if ($line=~/^ACC /) {
	    $line=~/^ACC\s+(\S+)/;
	    $acc = $1;
	} elsif ($line=~/^NAME/) {
	    $line=~/^NAME\s+(\S+)/;
	    $name = $1;
	} elsif ($line=~/^DESC/) {
	    $line=~/^DESC\s+(.*\S)/;
	    $line = "DESC  $1";
	    if (defined $id2ipr{$acc}) {
		$line .= "; InterPro: ".$id2ipr{$acc}." ".$ipr2abstract{$id2ipr{$acc}};  # add description 
		if (defined $GO{$id2ipr{$acc}} && $GO{$id2ipr{$acc}} ne "") {
		    $line .= "; ".$GO{$id2ipr{$acc}};
		}
	    }
	    $line .= ".\n";
	}
	push(@lines,$line);
	if ($line=~/^\/\//) {
	    if ($n++>$max_hmms_per_db) {last;}
	    print LOG "\nWriting edited file to $target_dir/$db"."_$date/$acc.tmp \n";
	    open (OUTFILE, ">$target_dir/$db"."_$date/$acc.tmp") || die("ERROR: cannot open: $!\n");
	    foreach $line (@lines) {
		print(OUTFILE $line);
	    }
	    close(OUTFILE);
	    &System("$hh/addpsipred.pl $target_dir/$db"."_$date/$acc.tmp $target_dir/$db"."_$date/$acc.hmm -hmm");
	    @lines=(); 
	    # Make h.hhm file
	    &System("$hh/hhmake -v 1 -i $target_dir/$db"."_$date/$acc.hmm -o $target_dir/$db"."_$date/$acc.hhm");
	    &System("cd $target_dir/$db"."_$date/ ; rm -f $acc.ss $acc.ss2 $acc.tmp $acc.mtx");
	}
    }
    close(INFILE);
    printf LOG "Time %s",`date`;
    print LOG "\n\n";
}


##############################################################################
# Update superfamily
if ($dbcat=~/ (supfam) /) {
    $db = $1;
 
    my %sf_sfid;
    my %sf_scop;
    my %sf_desc;
    
    # Read accessory table
    open (INFILE, "<$ipr_dir/superfamily.tab") || die("ERROR: cannot open: $!\n");
    while ($line=<INFILE>) {
	$line=~/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.*)/;
	$sf_sfid{$1}=$3;
	$sf_scop{$1}=$4;
	$sf_desc{$1}=$5;
    }
    close(INFILE);
    

    # Read HMMER file, fill in ACC, NAME and DESC from previous file and do SS prediction
    if (!-e "$target_dir/$db"."_$date/") {
	mkdir("$target_dir/$db"."_$date/"); # (do SS prediction on this node)
    }
    $n=0;
    print LOG "Reading $ipr_dir/superfamily.hmm ...";
    open (INFILE, "<$ipr_dir/superfamily.hmm") || die("ERROR: cannot open: $!\n");
    $line=<INFILE>;
    if ($line!~/^HMMER/) {
	# File in binary format; needs to be converted to ASCII
	close(INFILE);
	&System("$hmmer/hmmconvert -F $ipr_dir/superfamily.hmm $ipr_dir/superfamily.ascii");
	open (INFILE, "<$ipr_dir/superfamily.ascii") || die("ERROR: cannot open: $!\n");
	$line=<INFILE>;
    }
    @lines=();
    push(@lines,$line);
    while ($line=<INFILE>) {
	if ($line=~/^NAME\s+(\S+)\s+(\S+)/) {
	    $id = $1;
	    my $fam = $2;
	    $acc = "SSF$fam";
	    $line = "NAME  ".$sf_sfid{$id}."\n";
	    push(@lines,$line);
	    $name = $sf_desc{$id};
	    $line = "DESC  ".$name." (".$fam.")"." SCOP seed sequence: ".$sf_scop{$id};
	    if (defined $id2ipr{$acc}) {
		$line .= "; InterPro: ".$id2ipr{$acc};  # add InterPro reference, but no description 
		if (defined $GO{$id2ipr{$acc}} && $GO{$id2ipr{$acc}} ne "") {
		    $line .= "; ".$GO{$id2ipr{$acc}};
		}
	    }
	    $line .= ".\n";
	}
	elsif ($line=~/^ACC\s+(\S+)/) {
	    $acc = "SUPFAM".$1;
	    $line = "ACC   $acc\n";
	}
	elsif ($line=~/^DESC\s+(\S+)/) {
	    next;
	}
	
	push(@lines,$line);
	if ($line=~/^\/\//) {
	    if ($n++>$max_hmms_per_db) {last;}
	    print LOG "\nWriting edited file to $target_dir/$db"."_$date/$acc.tmp \n";
	    open (OUTFILE, ">$target_dir/$db"."_$date/$acc.tmp") || die("ERROR: cannot open: $!\n");
	    foreach $line (@lines) {
		print(OUTFILE $line);
	    }
	    close(OUTFILE);
	    &System("$hh/addpsipred.pl $target_dir/$db"."_$date/$acc.tmp $target_dir/$db"."_$date/$acc.hmm -hmm");
	    @lines=();
	    
	    # Make h.hhm file
	    &System("$hh/hhmake -v 1 -i $target_dir/$db"."_$date/$acc.hmm -o $target_dir/$db"."_$date/$acc.hhm");
	    &System("cd $target_dir/$db"."_$date/ ; rm -f $acc.ss $acc.ss2 $acc.tmp $acc.mtx");
	}
    }
    close(INFILE);
    printf LOG "Time %s",`date`;
    print LOG "\n\n";
}


##############################################################################
# Update CATH/Gene3D
if ($dbcat=~/ (CATH) /) {
    $db = $1;
    
    # Read HMMER file and do SS prediction
    if (!-e "$target_dir/$db"."_$date/") {
	mkdir("$target_dir/$db"."_$date/"); # (do SS prediction on this node)
    }
    $n=0;
    print LOG "Reading $ipr_dir/Gene3D.hmm ...";
    open (INFILE, "<$ipr_dir/Gene3D.hmm") || die("ERROR: cannot open: $!\n");
    $line=<INFILE>;
    if ($line!~/^HMMER/) {
	# File in binary format; needs to be converted to ASCII
	close(INFILE);
	&System("$hmmer/hmmconvert -F $ipr_dir/Gene3D.hmm $ipr_dir/Gene3D.ascii");
	open (INFILE, "<$ipr_dir/Gene3D.ascii") || die("ERROR: cannot open: $!\n");
	$line=<INFILE>;
    }
    @lines=();
    my $l=0;      # line count
    my $lname=-1;
    my $lacc=-1;
    my $ldesc=-1;
    push(@lines,$line); $l++; # do not lose first line 
    $desc="";
    while ($line=<INFILE>) {
	if ($line=~/^COM /) {
	    $line=~/(\S+)\.con\.hmm/;
	    $id = $1;
	} elsif ($line=~/^NAME/) {
	    $line =~ /NAME\s+(\S.*\S)/;
	    $desc = $1;
	    $lname = $l;
	} elsif ($line=~/^ACC  /) {
	    $line =~ /ACC\s+(\S*)/;
	    $acc = $1;
	    $lacc = $l;
	} elsif ($line=~/^DESC/) {
	    $ldesc=$l;
	} 
	push(@lines,$line); $l++;
	if ($line=~/^\/\//) {
	    if ($n++>$max_hmms_per_db) {last;}
	    $lines[$lname] = "NAME  ".$acc."\n";
	    $lines[$lacc]  = "ACC   ".$id."\n";
	    if ($desc ne $acc || defined $id2ipr{$acc}) {
		if ($ldesc==-1) {
		    $ldesc = $lname+1;
		    splice(@lines,$ldesc,0,"");
		}
		if ($desc ne $acc) {
		    $lines[$ldesc] = "DESC  ".$desc;
		    if (defined $id2ipr{$acc}) {$lines[$ldesc].="; ";}
		} else {
		    $lines[$ldesc] = "DESC  ";
		}
		if (defined $id2ipr{$acc}) {
		    $lines[$ldesc] .= "InterPro: ".$id2ipr{$acc}." ".$ipr2abstract{$id2ipr{$acc}};  # add description 
		    if (defined $GO{$id2ipr{$acc}} && $GO{$id2ipr{$acc}} ne "") {
			$lines[$ldesc] .= "; ".$GO{$id2ipr{$acc}};
		    }
		}
		$lines[$ldesc] .= ".\n";
	    } else {
		splice(@lines,$ldesc,1);
	    }
	    
	    print LOG "\nWriting edited file to $target_dir/$db"."_$date/$id.tmp \n";
	    open (OUTFILE, ">$target_dir/$db"."_$date/$id.tmp") || die("ERROR: cannot open: $!\n");
	    foreach $line (@lines) {
		print(OUTFILE $line);
	    }
	    close(OUTFILE);
	    &System("$hh/addpsipred.pl $target_dir/$db"."_$date/$id.tmp $target_dir/$db"."_$date/$id.hmm -hmm");
	    @lines=();
	    $desc="";
	    $l=0;
	    
	    # Make h.hhm file
	    &System("$hh/hhmake -v 1 -i $target_dir/$db"."_$date/$id.hmm -o $target_dir/$db"."_$date/$id.hhm");
	    &System("cd $target_dir/$db"."_$date/ ; rm -f $acc.ss $acc.ss2 $acc.tmp $acc.mtx");
	}
    }
    close(INFILE);
    printf LOG "Time %s",`date`;
    print LOG "\n\n";
}


###############################################################################################################

close LOG;

exit;

# System call
sub System()
{
    if (defined $_[1]) {
	if ($_[1]<0)  {printf("%s\n",$_[0]); return;}
	if ($_[1]>=2) {printf("%s\n",$_[0]);} 
    } else {
	if ($v>=2) {printf("%s\n",$_[0]);} 
    }
    return system($_[0])/256;
}

sub mkdir()
{
    if ($v>=2) {printf("mkdir %s\n",$_[0]);} 
    return mkdir $_[0];
}

sub chdir()
{
    if ($v>=2) {printf("chdir %s\n",$_[0]);} 
    return chdir $_[0];
}

