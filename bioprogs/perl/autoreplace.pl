#! /usr/bin/perl -w

use strict;

if (@ARGV<3) {
    print("\nAutomatically replace a Perl regular expression in all ASCII files read from the command line\n");
    print("(except the ones ending in ~ or %).\n");
    print("The replacement expression may contain \\\$1, \\\$2 etc. (You have to protect \$ by a preceding \\!)\n");
    print("The program makes copies of all modified files, appending '%' to their filenames.\n");
    print("Warning: when renaming variables etc. make sure the new name does not already exist. \n");
    print("Usage:   autoreplace.pl 'regex' 'replacement' [options] files \n");
    print("         autoreplace.pl -d [options] files \n");
    print("         autoreplace.pl -u [options] files \n");
    print("Options:\n");
    print(" -r      recursive mode: do autoreplace for files, directories and subdirectories (be careful!)\n");
    print(" -f      forced mode: do not inquire (make a backup before!)\n");
    print(" -q      quite mode\n");
    print(" -e ext  autoreplace only files with extension ext\n");
    print(" -n      do not create backup files\n");
    print(" -u      undo last autoreplace; MUST be first option! Moves backup 'file%' to 'file' for selected files\n");
    print(" -d      delete backup files;   MUST be first option! Deletes backup files for selected files\n");
    print("\n");
    print("Examples: \n");
    print(" autoreplace.pl '\\s*\\/\\/.*' '' *.C                  -> removes all comments from C++ files\n");
    print(" autoreplace.pl '\\s*\\#.*' '' *.pl                   -> removes all comments from perl files\n");
    print(" autoreplace.pl '\\/perl' '/lib' file.txt            -> replaces '/perl' by '/lib' in file.txt\n");
    print(" autoreplace.pl '\\/home\\/(\\w+)/lib' '/home/\$1' *.pl -> replaces '/home/X/lib' by '/home/X' in file.txt\n");
    print(" autoreplace.pl 'HHPred' 'HHpred' -r -e pl *        -> replaces 'HHPred' by 'HHpred' recursively \n");
    print("                                                       in all subdirectories and files  with extension .pl\n");
    print(" autoreplace.pl -u -r -e pl *                       -> undo all changes by last autoreplace\n");
    print("\n");
    exit(1);
}

my $options="";
my $find;          # the regular expression to be found
my $replace;       # the regular expression that replaces the former
my $nreplaced;     # number of lines in a file that were changed
my $nfound=0;      # number of lines in a file were regex was found
my $line;          # input line
my @files=();      # files to be searched and edited
my $file;
my $v=2;
my $inquire=1;     # inquire mode: ask before each replacement? 0:force
my $recursive=0;   # do autoreplace recursively for all subdirectories 
my $undo=0;        # undo last autoreplace
my $backup=1;      # create backup files
my $delete=0;      # delete backup files
my $ext="not_specified"; # file extension of files to be processed by autoreplace
my $DoForFile;     # Pointer to subroutine thgat performs some action on files (AutoReplace or UndoAutoReplace)
my $nfiles=0;      # counts number of files searched

# Undo mode?
if ($ARGV[0]=~/^-u$/) {$undo=2;}     
elsif ($ARGV[0]=~/^-d$/) {$delete=2;}
else {
     # Read regular expressions
    $find=$ARGV[0];
    $find=~s/([^\\])\$/$1\\\$/g; # replace $ by \$ if not yet protected
    $find=~s/^\$/\\\$/;      # replace $ at beginning of expression by \$
    $replace=$ARGV[1];
    $replace=~s/([^\\])\$/$1\\\$/g; # replace $ by \$ if not yet protected
    $replace=~s/^\$/\\\$/;      # replace $ at beginning of expression by \$
   if ($v>=2) {print("Replace '$find' by '$replace'\n");}
}

# Read command line options and files to run through
for (my $i=2-$undo-$delete; $i<@ARGV; $i++) {
    if ($ARGV[$i]=~/-v/) {$v=2;}
    elsif ($ARGV[$i]=~/^-q$/) {$v=0;}
    elsif ($ARGV[$i]=~/^-f$/) {$inquire=0;}
    elsif ($ARGV[$i]=~/^-r$/) {$recursive=1;}
    elsif ($ARGV[$i]=~/^-n$/) {$backup=0;}
    elsif ($ARGV[$i]=~/^-e$/) {$ext=$ARGV[++$i];}
    else {push(@files,$ARGV[$i]);}   # if no option found this must be a file
}


system("stty cbreak </dev/tty >&1"); # make input unbuffered!

# Undo?
if ($undo) {
    $DoForFile=\&UndoAutoReplace;
} elsif ($delete) {
    $DoForFile=\&DeleteBackupFiles;
} else {
    $DoForFile=\&AutoReplace;
}

# For all files read from command line
foreach $file (@files) {
    if ($file=~/^\s*$/) {next;}
    if (-T $file) {                          # is file a text file?
	&{$DoForFile}($file,"");
	$nfiles++;
    } elsif (-d $file && $recursive) {       # is file a directory and in recursive mode?
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
	} elsif (-T $file) {
	    &{$DoForFile}($file,$indent);
	}
    }
#    if ($v>=2) {printf("\n");}
    return;
}


################################################################################
# Do autoreplace on single file: $file
################################################################################
sub AutoReplace() 
{
    my $file=$_[0];
    my $indent=$_[1];
    my @lines=();  # All lines read in from file
    my $answer=""; # y, n, a, s, e, q
    $nreplaced=0;  # no lines replaced yet
    $nfound=0;     # number of lines in file were regex was found

    # Reject autoreplace backup files (ending in %) and emacs backup files (ending in ~)
    if ($file=~/[%~]$/) {return;}

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
	    if ($inquire) {

		my $exp;
		my $new=$line;
		$line=~/$find/;
		eval("\$new=~s/$find/$replace/g");
		$nfound++;
		printf("$file, line %i:\n",$.);
		printf("%s",$line);
		printf("%s",$new);
		print("Replace upper by lower? enter:no y:yes s:skip_file a:all x:exit q:quit >");
		$answer=getc(STDIN);
		print("<\n");
		if ($answer eq "y") {
		    # REPLACE!!
		    eval("\$line=~s/$find/$replace/g");
		    if ($line!~/^\s+$/) {push(@lines,$line);}
		    $nreplaced++;
		} elsif ($answer eq "q") {
		    exit(1);
		} elsif ($answer eq "x") {
		    push(@lines,$line);
		    $inquire=0;
		    last;
		} elsif ($answer eq "s") {
		    push(@lines,$line);
		    last;
		} elsif ($answer eq "a") {
		    $inquire=0;
		    eval("\$line=~s/$find/$replace/g");
		    if ($line!~/^\s+$/) {push(@lines,$line);}
		    $nreplaced++;
		} else {
		    push(@lines,$line);
		}

	    } else {
		if ($v>=2) {printf("Old: %s",$line);}
		eval("\$line=~s/$find/$replace/g");
		if ($v>=2) {printf("New: %s",$line);}
		if ($line!~/^\s*$/) {push(@lines,$line);}
		$nreplaced++;
	    }
	} else {
	    push(@lines,$line);
	}
    }
    while ($line=<INFILE>) {push(@lines,$line);}  # Push rest of file to @lines (in case $answer eq "x" or "s")
    close(INFILE);

    if ($nfound && ($v>=1 || $inquire)) {print("\n");}
    
    # Write edited lines (if anything was changed at all)
    if ($nreplaced) {
	
	# Make backup copy of file
	if($backup && system("cp $file $file%")) {
	    die("Error: could not copy $file to $file%. Modifications not effected!\n");
	}	    

	# Opening file successfull?
	open (OUTFILE,">$file") || die("Error: could not open $file for writing: $!\n");
	print (OUTFILE @lines);
	close(OUTFILE);

    } else {
	# Make sure old backup files are removed (otherwise -u option undoes earlier replacements as well)
	unlink("$file%");
    }

    if ($answer eq "x") {exit;}
    return ;
}


################################################################################
# Unddo autoreplace for single file: $file
################################################################################
sub UndoAutoReplace() 
{
    my $file=$_[0];
    my $indent=$_[1];
    my @lines=();  # All lines read in from file

    # Reject autoreplace backup files (ending in %) and emacs backup files (ending in ~)
    if ($file=~/[%~]$/) {return;}

    # Filter for extension
    if ($ext ne "not_specified") {   # does user want to process only files with extension $ext?
	if ($file=~/^.*\.(.*?)$/) {  # does file have an extension?
	    if($1 ne $ext) {return;} # does extension agree with $ext?
	} else {
	    if($ext ne "") {return;}
	} 
    }
    
    # Skip if no backup file exists
    if (! -e "$file%") {return;}

    # Move backup copy to original file
    if(system("mv $file% $file")) {
	die("Error: could not move $file% to $file\n");
    } else {
	if ($v>=2) {printf("%sRestoring $file\n",$indent);}
    }	    

    return;
}

################################################################################
# Delete Backup file for $file
################################################################################
sub DeleteBackupFiles() 
{
    my $file=$_[0];
    my $indent=$_[1];
    my @lines=();  # All lines read in from file

    # Filter for extension
    if ($ext ne "not_specified") {   # does user want to process only files with extension $ext?
	if ($file=~/^.*\.(.*?)$/) {  # does file have an extension?
	    if($1 ne $ext) {return;} # does extension agree with $ext?
	} else {
	    if($ext ne "") {return;}
	} 
    }
    
    # Remove backup file if it exists
    if (-e "$file%") {unlink("$file%")}
    return;
}
