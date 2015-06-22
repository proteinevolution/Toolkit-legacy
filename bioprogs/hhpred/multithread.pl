#! /usr/bin/perl -w
# Usage:   multithread.pl <fileglob> '<program call>' [-cpu <int>] 
# Example: multithread.pl '*.scores' '/home/soeding/hh/hhallmaxsub.pl $file /home/soeding/scop20.1' -cpu <int> 

use strict;
use POSIX;
$|=1; # autoflush on


if (scalar(@ARGV)<2) {
    print("
 Call a program multiple times with different files as arguments and process in parallel 
 Usage: multithread.pl <fileglob> '<program call>' [-cpu <int>]

 * <program call> can include symbol \$file for the full filename, \$base for the filename without extension,
   and \$root for the filename without extension and path.
 * Each command is submitted to the cluster queue using queuesubmit.pl. The output of this submission is
   written into a file PID.tmp of the current directory.(PID is the process id of the job on this computer.

 Example: multithread.pl '*.scores' '/homje/soeding/hh/hhallmaxsub.pl \$file /home/soeding/scop20.1' -cpu 2
\n"); 
    exit;
}
# Variables 
my $cpus=2;        # number of cpus to use
my $parent_pid=$$; # main process id
my $pid;           # process id of child
my %pid=();        # hash has all running PIDs as keys and the file name as data
my $children=0;    # number of child processes running
my @files=glob($ARGV[0]); 
my $programcall=$ARGV[1]; 
my $options="";
my $file;
my $ifile=0;

$SIG{'CHLD'}='IGNORE';
$SIG{'USR1'}=\&ChildFinished;
$SIG{'INT'} =\&KillAllProcesses;

if (@ARGV>2) {
    $options.=join(" ",@ARGV[2..$#ARGV]);
}
# Set number of cpus to use
if ($options=~s/-cpu\s*(\d)\s*//g) {$cpus=$1;}

# Warn if unknown options found
if ($options!~/^\s*$/) {$options=~s/^\s*(.*?)\s*$/$1/g; print("WARNING: unknown options '$options'\n");}

print (scalar(@files)." files read in ...\n");

foreach $file (@files) {   
    $ifile++;

    # All cpus occupied? -> wait for a cpu to become free
    if ($children>=$cpus) {
	print("Parent $$ is sleeping (children=$children) ");
	my $count=0;
	while ($children>=$cpus) {
	    if ($count++>=10) {
		$count=0;
		print("\nProcesses running:\n");
		$children=0;
		foreach $pid (keys(%pid)) { 
		    if (! kill(0,$pid)) {    # kill($pid,0) returns false if process is dead (finished)
			printf("PID %5.5s: %s is removed from process table\n",$pid,$pid{$pid});
			delete($pid{$pid});  # remove process from hash of PIDs
		    } else {
			printf("PID %5.5s: %s\n",$pid,$pid{$pid});
			$children++;   # In case a USR1 signal was caught twice (??)
		    }
		}
		print(STDERR "\n");
	    } else {
		print("."); 
		select(undef, undef, undef, 0.1); # sleep 0.1 seconds
	    }
	} 
	print("\n"); 
    }
    
    if ($pid=fork()) {
	# Main process
	$children++;
	$pid{$pid}="$file ($ifile)";

	# Print out running processes and remove defunct ones
	select(undef, undef, undef, 0.1); # sleep 0.1 seconds

    } elsif (defined $pid) {
	# Child process
	my $base;   # filename without extension
	my $root;   # basename without path
	if ($file =~/(.*)\..*?$/) {$base=$1;} else {$base=$file;}  
	if ($base =~/.*\/(.*?)$/) {$root=$1;} else {$root=$base;} 
	my $command=$programcall;
	$command=~s/\$file/$file/g;
	$command=~s/\$base/$base/g;
	$command=~s/\$root/$root/g;
	&System("$command ");
	print("\n");
	printf("Process $$ for file %s (%i) finished.\n",$file,$ifile);
	kill(USR1 => $parent_pid);
	$SIG{'CHLD'}='IGNORE';
	exit;
    } else {
	die("Error: fork returned undefined PID: $!\n");
    }
}
wait;
print ("All processes should be finished now\n");
exit(0);


sub ChildFinished() {
    $children--;
    $SIG{'USR1'}=\&ChildFinished;
    printf("Children counter reduced to children=$children \n",$file,$ifile);
    return;
}

sub KillAllProcesses() 
{
    foreach $pid (keys(%pid)) { 
	printf("Kill process $pid: returned %i\n",kill(-9,$pid));
    }
    die ("Killed main process $$\n");
}

sub System {
    print($_[0]."\n"); 
    return system($_[0]); 
}

