#! /usr/bin/perl -w

if ( @ARGV != 1 ) {
        print "USAGE: stop_hhsenser.pl exec_host-file\n\n";
        exit(1);
}

my $file = $ARGV[0];
my $host;
my $ppid;

open (FILE, "$file") or die("Cannot open!");
$host = <FILE>;
chomp($host);
$ppid = <FILE>;
chomp($ppid);
close FILE;

my $command = "ssh comphead1v1.eb.local 'ssh $host \"ps -eo \\\"%p %P %c\\\" |grep buildinter.pl\"'";
print "Command: $command\n";
$line = `$command`;

print "Line: $line\n";
print "PPID: $ppid\n";

@array = split(/\n/, $line);
foreach $tmp (@array) {
    $tmp =~ /^\s*(\d+)\s+(\d+)/;
    my $pid = $1;
    if ($2 == $ppid) {
	$command = "ssh comphead1v1.eb.local 'ssh $host \"kill -10 -$pid\"'";
		print "Command: $command\n";	
	system($command);
    }
}

exit;
