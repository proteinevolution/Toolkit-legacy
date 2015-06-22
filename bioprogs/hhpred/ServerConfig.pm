#!/usr/bin/perl -w

package ServerConfig;

use strict;
use vars qw(@ISA @EXPORT);
use Exporter;

our @ISA          = qw(Exporter);
our @EXPORT       = qw($tmp_dir $doc_rootdir $cgi_rootdir $doc_rooturl $cgi_rooturl $pdb_dir $database_dir 
$bioprogs_dir $is_public $queue_port $queue_ip $java_exec $cluster_dir $data_dir $smtp_server);

# server config variables
our $tmp_dir;
our $doc_rootdir;
our $cgi_rootdir;
our $doc_rooturl;
our $cgi_rooturl;
our $pdb_dir;
our $database_dir;
our $bioprogs_dir;
our $is_public;
our $queue_port;
our $queue_ip;
our $java_exec;
our $cluster_dir;
our $data_dir;
our $smtp_server = "mailhost.tuebingen.mpg.de";

my $hostname=`hostname`;


if ( (defined $ENV{'SERVER_NAME'} && ($ENV{'SERVER_NAME'} =~ /10\.35\.1\.25/ || $ENV{'SERVER_NAME'} =~ /protevo\.eb\.tuebingen\.mpg\.de/)) || $hostname=~/web/ || $hostname=~/cerberus/ || $hostname=~/10.35.1.25/) {
    # cerberus, production environment
    $tmp_dir = "/cluster/tmp";
    $doc_rootdir = "/var/web/html";
    $cgi_rootdir = "/var/web/cgi-bin";
    $doc_rooturl = "http://10.35.1.25";
    $cgi_rooturl = "http://10.35.1.25/cgi-bin";
    $database_dir = "/cluster/databases";
    $bioprogs_dir = "/cluster/bioprogs";
    $pdb_dir = "/cluster/databases/pdb/all";
    $is_public = 0;
    $queue_ip = "10.35.1.25";
    $queue_port = 10300;
    $java_exec = "/cluster/queue/node_java";
    $cluster_dir = "/cluster";
    $data_dir = "/cluster/data"; 
} else {
    # chimaera, development environment
    $tmp_dir = "/cluster/tmp";
    $doc_rootdir = "/var/web/html";
    $cgi_rootdir = "/var/web/cgi-bin";
    $doc_rooturl = "http://10.35.1.40";
    $cgi_rooturl = "http://10.35.1.40/cgi-bin";
    $database_dir = "/cluster/databases";
    $bioprogs_dir = "/cluster/bioprogs";
    $pdb_dir = "/cluster/databases/pdb/all";
    $is_public = 0;
    $queue_ip = "10.35.1.40";
    $queue_port = 10300;
    $java_exec = "/cluster/queue/node_java"; 
    $cluster_dir = "/cluster";
    $data_dir = "/cluster/data";
}

return 1;
