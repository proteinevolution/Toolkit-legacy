#!/usr/bin/perl -w

# sequence retrival
# Usage:   seq_retrival.pl -i ident-file -o output-file -b blast-dir -d database-dir -m max-seqs -unique

use strict;

my $infile;
my $outfile;
my $line;
my %id;
my $num_fast = 1500;
my $max_seqs = 100000;
my $counter = 0;

my $num_ident = 0;
my $num_ident_unique = 0;
my $num_unretrieve = 0;
my $num_extr = 0;
my $num_extr_unique = 0;

my $seq = "";
my %seqs;

my $unique = "F";
my $blast_dir = "/cluster/toolkit/production/bioprogs/blast";
my $db_dir = "/cluster/toolkit/production/databases/standard";

# shall only ask to search a single database!
#my $db = "'$db_dir/nre $db_dir/nt'";
my $db = "'$db_dir/nre'";
my @dbs;
my @unsupported;
my $rubydir = "/cluster/user/denis/toolkit/bioprogs/ruby";
# check arguments
if ( @ARGV < 2 ) {
	error();
	exit(1);
}

for ( my $j = 0 ; $j < @ARGV ; $j++ ) {
    
    if ( $ARGV[$j] eq "-i" ) {
	$j++;
	$infile = $ARGV[$j];
    } elsif ($ARGV[$j] eq "-o") {
	$j++;
	$outfile = $ARGV[$j];
    } elsif ($ARGV[$j] eq "-b") { 
	$j++;
	$blast_dir = $ARGV[$j];	
   } elsif ($ARGV[$j] eq "-m") { 
	$j++;
	$max_seqs = $ARGV[$j];	
    } elsif ($ARGV[$j] eq "-d") { 
	$j++;
	$db = $ARGV[$j];
    } elsif ( $ARGV[$j] eq "-unique") {
	$unique = "T";
    } else {
	print("\nERROR: Don't know this Argument: $ARGV[$j] \n\n");
	error();
	
	exit(1);
    }
}

 

if ( !defined($infile) || $infile eq "" || !(-r $infile)) {
    print("\nERROR: No or unreadable inputfile!!! \n\n");
    error();
    exit(1);
}
if (!defined($outfile) || $outfile eq "") {
    print("\nERROR: No outputfile!!! \n\n");
    error();
    exit(1);
}


# check for big input file
open (IN, "$infile" ) or die("Cannot open!");
my @array = <IN>;
close IN;
if (scalar(@array) > $num_fast) {
    if (!($db =~ /Pfam-A-fasta/) || !($db =~ /pdb_nr/) || !($db =~ /uniprot_trembl.fasta/)  || !($db =~ /uniprot_sprot.fasta/)) {
	fast();
	exit;
    }
}

open (IN, "$infile" ) or die("Cannot open!");
open (OUT, ">$outfile") or die ("Cannot open!");

while ($line = <IN>) {

    if ($counter > $max_seqs) { last; }

    $line =~ s/\s+/ /g;
    $line =~ s/^\s+//g;
    my @ids = split(/ /, $line);
    foreach my $ident(@ids) {

	$counter++;
	$num_ident++;
	my $tmp = $ident;
	if ($ident =~ /gi\|(\d+)/ || $ident =~ /^\S*?\|(\S+?)\|/ || $ident =~ /^(\S+)\|/) {
	    $ident = $1;
	}
	if ($unique eq "T") {
	    if (exists $id{$ident}) {
		next;
	    } 
	    $id{$ident} = 1;
	    $num_ident_unique++;
	}
	my $command = "";
	if (($db =~ /Pfam-A-fasta/) ||($db =~ /pdb_nr/) || ($db =~ /uniprot_trembl.fasta/)  || ($db =~ /uniprot_sprot.fasta/)) {
	    $command = "ruby $rubydir/seq_retrieve_helper.rb '$db' '$ident'";
	}
	else {
	    $command = "$blast_dir/fastacmd -d '$db' -s '$ident'";
	    print $command
	}

	print "Command: $command\n";
	my $ret = `$command`;
	
	if ($ret eq "") {
	    print "Identifier $tmp not found!\n";
	    $num_unretrieve++;
	    next;
 	}
	$num_extr++;

	if ($unique eq "T") {
	    $seq = $ret;
	    $seq =~ s/^.*?\n//;
	    if (exists $seqs{$seq}) {
		next;
	    }
	    $seqs{$seq} = 1;
	    $num_extr_unique++;
	}

	print OUT $ret;

    }
}

close IN;
close OUT;

print "\nSummary:\n";

print "Number of given identifier: $num_ident\n";
if ($unique eq "T") {
    print "Number of unique identifier: $num_ident_unique\n";
}
print "Number of unretrievable sequences: $num_unretrieve\n";
print "Number of extracted sequences: $num_extr\n";
if ($unique eq "T") {
    print "Number of unique extracted sequences: $num_extr_unique\n";
}

exit;




#####################################################
#### sub functions

sub error {
	print("Usage: seq_retrival.pl [options] \n");
	print("\n");
	print("Options:\n\n");
	print("-i ident-file:\t file with identifier \n");
	print("-o output-file:\t output-file \n");
	print("-b blast-dir:\t blast-directory with fastacmd [default: /cluster/bioprogs_stable/blast]\n");
	print("-d db:\t database [default: /cluster/databases]\n");
	print("-d max-seqs:\t max. number of retrievable sequences [default: 100.000]\n");
	print("-unique:\t retrieve identical sequences only once \n\n");
	print("Optional:\n\n");
	print("\n");
}

sub fast {

    open (IN, "$infile" ) or die("Cannot open!");
    open (PREPARE, ">$infile.prepare") or die ("Cannot open!");
    
    while ($line = <IN>) {
	
	if ($counter > $max_seqs) { last; }
	
	$line =~ s/\s+/ /g;
	$line =~ s/^\s+//g;
	my @ids = split(/ /, $line);
	foreach my $ident(@ids) {
	    
	    $counter++;
	    $num_ident++;
	    my $tmp = $ident;
	    if ($ident =~ /gi\|(\d+)/ || $ident =~ /^\S*?\|(\S+?)\|/ || $ident =~ /^(\S+)\|/) {
		$ident = $1;
	    }
	    if ($unique eq "T") {
		if (exists $id{$ident}) {
		    next;
		} 
		$id{$ident} = 1;
		$num_ident_unique++;
	    }
	    
	    print PREPARE "$ident\n";
	    
	}
    }
    
    close IN;
    close PREPARE;

    # cannot place more than one database in the parameter list to fastacmd!
    # my $command = "$blast_dir/fastacmd -d '$db_dir/nre $db_dir/nt' -i $infile.prepare > $outfile.prepare 2> $outfile.errlog";
    my $command = "$blast_dir/fastacmd -d $db -i $infile.prepare > $outfile.prepare 2> $outfile.errlog";
    system($command);
	
    open (OUT, ">$outfile" ) or die("Cannot open!");
    open (PREPARE, "$outfile.prepare") or die ("Cannot open!");   

    my $header = "";
    while ($line = <PREPARE>) {

	if ($line =~ /^>.*/) {

	    if ($seq ne "") {
		if ($unique eq "T") {
		    if (!exists $seqs{$seq}) {
			$seqs{$seq} = 1;
			$num_extr_unique++;
		    
			print OUT $header;
			print OUT $seq;
		    }
		} else {
		    print OUT $header;
		    print OUT $seq;
		}
	    }
	    $header = $line;
	    $seq = "";
	    $num_extr++;
	} else {
	    $seq .= $line;
	}
    }


    if ($seq ne "") {
	if ($unique eq "T") {
	    if (!exists $seqs{$seq}) {
		$seqs{$seq} = 1;
		$num_extr_unique++;
		
		print OUT $header;
		print OUT $seq;
	    }
	} else {
	    print OUT $header;
	    print OUT $seq;
	}
    }

    close PREPARE;
    close OUT;

    if ($unique eq "T") {
	$num_unretrieve = $num_ident_unique - $num_extr;
    } else {
	$num_unretrieve = $num_ident - $num_extr;
    }

    open (ERRLOG, "$outfile.errlog") or die ("Cannot open!");

    while ($line = <ERRLOG>) {
	if ($line =~ /^\s*\[fastacmd\] ERROR: (.*)$/) {
	    print "$1\n";
	}
	print STDERR $line;
    }

    close ERRLOG;

    print "\n\nSummary:\n";

    print "Number of given identifier: $num_ident\n";
    if ($unique eq "T") {
	print "Number of unique identifier: $num_ident_unique\n";
    }
    print "Number of unretrievable sequences: $num_unretrieve\n";
    print "Number of extracted sequences: $num_extr\n";
    if ($unique eq "T") {
	print "Number of unique extracted sequences: $num_extr_unique\n";
    }
    
}
