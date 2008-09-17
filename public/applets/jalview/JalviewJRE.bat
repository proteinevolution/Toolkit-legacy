rem Windows script file to run JalView using the JRE
rem ------------------------------------------------
rem Author: Michele Clamp June 1998
rem Usage: jalview.bat <alignfile> <format>


rem Change the next line to reflect where your jalview.jar file is
set CLASSPATH=<path to jalview>\jalview.jar

rem Change the next line to the path to your java jre.exe binary
rem This is installed in your windows directory by default I think

set JAVA_EXE=c:\windows\jre

rem This next command runs jalview
rem %1 is the alignment file
rem %2 is the alignment format
rem Allowed formats are MSF CLUSTAL FASTA PIR BLC

%JAVA_EXE% -cp %CLASSPATH% jalview.AlignFrame %1 File %2

rem if you like add extra command line options to the previous command as follows:

rem   -mail <mailserver>
rem   -srsServer <srsServer>  - see the README file for details
rem   -database <database>    - srs database name

rem example :  %JAVA_EXE% jalview.AlignFrame %1 File %2 -mail circinus.ebi.ac.uk -srsServer srs.ebi.ac.uk/srs5bin/cgi-bin/ -database swissprot
~

