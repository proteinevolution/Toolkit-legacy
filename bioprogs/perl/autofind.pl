#! /usr/bin/perl -w

use strict;

if (@ARGV<2) {
    print("\nUsage:   autofind.pl 'regex' [options] files \n");
    print("Find a Perl regular expression in all ASCII files read from the command line\n");
    print("Options:\n");
    print(" -r      recursive mode: do autofind for files, directories and subdirectories\n");
    print(" -q      quite mode\n");
    print(" -v      verbose mode\n");
    print(" -e ext  search only files with extension ext\n");
    print(" -i      case insensitive\n");
    print("\n");
    print("Example: autofind.pl 'Endonuclease' -r -i *\n");
    print("\n");
    exit(1);
}

my $options="";
my $find;          # the regular expression to be found
my $line;          # input line
my @files=();      # files to be searched and edited
my $file;
my $v=1;
my $insens=0;      # case-insensitive find
my $recursive=0;   # do autoreplace recursively for all subdirectories 
my $ext="not_specified"; # file extension of files to be processed by autoreplace
my $DoForFile;     # Pointer to subroutine that performs some action on files (AutoReplace or UndoAutoReplace)
my $nfiles=0;      # counts number of files searched

$find=$ARGV[0];
$find=~s/([^\\])\$/$1\\\$/g; # replace $ by \$ if not yet protected
$find=~s/^\$/\\\$/;          # replace $ at beginning of expression by \$


# Read command line options and files to run through
for (my $i=1; $i<@ARGV; $i++) {
    if ($ARGV[$i]=~/-v/) {$v=2;}
    elsif ($ARGV[$i]=~/^-r$/) {$recursive=1;}
    elsif ($ARGV[$i]=~/^-q$/) {$v=0;}
    elsif ($ARGV[$i]=~/^-e$/) {$ext=$ARGV[++$i];}
    elsif ($ARGV[$i]=~/^-i$/) {$insens=1;}
    else {push(@files,$ARGV[$i]);}   # if no option found this must be a file
}

if ($v>=2) {print("Find '$find'\n");}

# Do case-insensitive search: change 'Endonuclease' -> 'E[nN][dD][oO][nN][uU][cC][lL][eE][aA][sS][eE]'
if ($insens) {
    $find=~s/([a-z])/[$1\U$1]/g;
}

system("stty cbreak </dev/tty >&1"); # make input unbuffered!

$DoForFile=\&Find;

# For all files read from command line
foreach $file (@files) {
    if ($file=~/^\s*$/) {next;}
    if (-T $file) {             # is text file?
	&{$DoForFile}($file,"");
    } elsif (-d $file && $recursive) {  # is directory and in recursive mode ?
	&DoForDirectory($file,$DoForFile,"");
    }
}
if ($v>=2) {printf("Searched %i files\n",$nfiles);}
exit(0);


################################################################################
# Do action for file or directory (and recursively for all files below)
################################################################################
sub DoForDirectory()
{
    my $subdir = $_[0];
    my $DoForFile=$_[1]; # Pointer to subroutine acting on files
    my $indent=$_[2];
    my @files = glob($subdir."/*"); #read files $sourcesubdir/* into @files 
    my $file;             # file in source subdirectory

    if ($v>=2) {
	printf("%sChecking directory $subdir/ with %i files\n",$indent,scalar(@files));
	$indent.="   ";
    }

    # Look at each file in subdirectory ...
    foreach $file (@files) {
	
#	print ("$file\n"); 

	# Is file a directory?
	if (-d $file) {
	    &DoForDirectory($file,$DoForFile,$indent);
	} elsif(-T $file) { # Is file a text file?
	    &{$DoForFile}($file,$indent);
	}
    }
#    if ($v>=2) {printf("\n");}
    return;
}


################################################################################
# Find regex in file
################################################################################
sub Find() 
{
    my $file=$_[0];
    my $indent=$_[1];
    my @lines=();      # All lines read in from file
    my $nfound=0;      # number of lines in a file were regex was found

    # Filter for extension
    if ($ext ne "not_specified") {   # does user want to process only files with extension $ext?
	if ($file=~/^.*\.(.*?)$/) {  # does file have an extension?
	    if($1 ne $ext) {return;} # does extension agree with $ext?
	} else {
	    if($ext ne "") {return;}
	} 
    }
    
    if ($v>=2) {printf("%sSearching $file ...\n",$indent);}

    # Read all lines from $file and do replacements
    if (!open (INFILE,"<$file")) {
	warn("Error: could not open $file for reading: $!\n");
	return;
    }
    while ($line=<INFILE>) {
	if($line=~/$find/) {

	    if ($nfound==0) {printf("$file \n");}
	    printf("line %4i: %s",$.,$line);
	    $nfound++;
	}
    }
    close(INFILE);
    if ($nfound>0) {print("\n");}
    return;
}


