#!/usr/bin/perl -w
# Read parameters from metaserver or equivalent simplified input form and call hh_internal_meta.pl

use lib	"/cluster/lib";
use lib	"/cluster/bioprogs/hhpred";
use ServerConfig;
use MyPaths;
use strict;
use File::Temp "tempfile";
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use lib	"/cluster/lib/Mail/";
# use lib	"/usr/lib/perl5/vendor_perl/5.8.6/Mail/";
use Mail::Sender;

# Variable declarations
my $address  = param("REPLY-E-MAIL");
my $sequence = param("SEQUENCE");
my $seqname  = param("TARGET-NAME");
my $server   = param("SERVER");

my $myaddress = "johannes.soeding\@tuebingen.mpg.de";
my $hisaddress = "michael.habeck\@tuebingen.mpg.de";
my $fh;
my $basename; # $tmp_dir/$id
my $id;       # five-character random id

if (!$address)  {$address= $myaddress;}
if (!$sequence) {$sequence="undefined_sequence";}
if (!$seqname)  {$seqname="undefined_seqname";}
if (!$server)   {$server ="BayesHH";}

# Check form arguments
&Check($address,$sequence);

# Create random id
($fh, $basename) = tempfile("CASP_XXXXX", DIR => "$tmp_dir");
system("chmod 777 $basename");
$id=$basename;
if ($basename=~/.*\/(.*)?/)  {$id=$1;}                        # remove path 

# Create query file
$sequence=~s///g;          # remove carriage returns (ASCII 13)!
$sequence=~tr/a-z.*-/A-Z/d;  # transform to upper case; remove gaps and ^M
$sequence=~s/\s+//g;         # remove white space among residues
open (SEQ, ">$basename.seq") || die ("Cannot open $basename.seq: $!");;
print (SEQ ">$seqname $id\n$sequence\n");
close (SEQ) or die ("Cannot close: $!");

#my $mail_cmd="/usr/lib/sendmail -t -oi";

my $sender = new Mail::Sender{
    smtp => 'mailgw.tuebingen.mpg.de', 
    from => $myaddress,
    debug => "$basename.mail1.log",
    on_errors => 'die'
    };
$sender->MailMsg({
    to => $myaddress,
    subject => "New $server $seqname $id $address",
    msg => "SERVER:   $server\nTARGET:   $seqname\nSEQUENCE: $sequence\nID:       $id\nADDRESS:  $address\n"});
if ($server=~/Bayes/i) {
    $sender->MailMsg({
	to => $hisaddress,
	subject => "New $server $seqname $id $address",
	msg => "SERVER:   $server\nTARGET:   $seqname\nSEQUENCE: $sequence\nID:       $id\nADDRESS:  $address\n"});
}
$| = 1; # autoflush


# Call h2h_internal_meta.pl to start pipeline

# create commandfile
open(CMD, ">$basename.sh" ) or die("Cannot create $basename.sh: $!\n");
print CMD "#!/bin/sh\n";
print CMD "#PBS -e localhost:$basename.estream\n";
print CMD "#PBS -o localhost:$basename.ostream\n";
print CMD "#PBS -q long\n";
print CMD "#PBS -d $tmp_dir\n";
print CMD "#PBS -m n\n";
print CMD "#PBS -r n\n";
print CMD "# hostname: ".`hostname`;              # write web server name into shell file
print CMD "ulimit -f 1000000 -m 6000000\n";       # file size limit 500Mb, memory limit 6Gb
print CMD "hostname > $basename.exec_host\n";     # write name of execution node into $qid.exec_host
print CMD "perl $bioprogs_dir/hhpred/hh_internal.pl '$basename' '$seqname' '$address' '$server' | tee /tmp/$id.log > $basename.log 2>&1\n"; 
print CMD "mv /tmp/$id.log $basename.log";

close(CMD);
system("chmod 777 $basename.sh");
my $command = "/usr/local/PBS/bin/qsub -q long $basename.sh > /dev/null 2>&1";
system($command);


# Print "Thanks"
print "Content-type: text/html\n\n";
print "<html>";
print "<head>";
print("<title>$server thanks</title>");
print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">";
print "<link rel=\"stylesheet\" href=\"http://10.35.1.25:8080/css/formschrift.css\" type=\"text/css\">";
print "<link rel=\"stylesheet\" href=\"http://10.35.1.25:8080/css/formschrift2.css\" type=\"text/css\">";
print "<link rel=\"stylesheet\" href=\"http://10.35.1.25:8080/css/form_link.css\" type=\"text/css\">";
print "</head>";
print "<body bgcolor=\"#FFFFFF\" text=\"#000000\" topmargin=\"10\" marginwidth=\"10\" marginheight=\"10\" leftmargin=\"10\" link=\"#000000\" vlink=\"#000000\" alink=\"#000000\">";
print "<center>";
print("<h3>Thank you for using our $server structure prediction service.<BR>");
print("Your results for $seqname will be sent to<BR>$address<BR></h3>");
print "ID: $id<br>";
print "</center>";
print "</body>";
print "</html>\n";
exit(0);

sub Check() {
    foreach $_ (@_) {
	$_=~s/\s//g;                        # remove newlines, linebreaks etc.
	if (($_=~tr/a-zA-Z0-9_+=.@ -//c)) { # count the number of special characters
	    print "Content-type: text/html\n\n";
	    print "<html>";
	    print "<head>";
	    print("<title> Server error in $server</title>");
	    print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">";
	    print "<link rel=\"stylesheet\" href=\"http://10.35.1.25:8080/css/formschrift.css\" type=\"text/css\">";
	    print "<link rel=\"stylesheet\" href=\"http://10.35.1.25:8080/css/formschrift2.css\" type=\"text/css\">";
	    print "<link rel=\"stylesheet\" href=\"http://10.35.1.25:8080/css/form_link.css\" type=\"text/css\">";
	    print "</head>";
	    print "<body bgcolor=\"#FFFFFF\" text=\"#000000\" topmargin=\"10\" marginwidth=\"10\" marginheight=\"10\" leftmargin=\"10\" link=\"#000000\" vlink=\"#000000\" alink=\"#000000\">";
	    print "<center>";
	    print "<center>";
 	    print("<h3>Error! Please remove special characters:<BR></h3>");
 	    print("<h4>$_</h4>");
	    print "</center>";
	    print "</body>";
	    print "</html>";
	    exit(1);
	}
    }
    return;
}

sub System {
    print("$_[0]\n");
    system($_[0]);
}



