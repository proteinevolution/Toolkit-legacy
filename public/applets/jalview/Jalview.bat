echo off
rem Windows script file to run JalView
rem ----------------------------------
rem Author: Michele Clamp June 1998
rem Usage: jalview.bat <alignfile> <format>

rem Change the next line to reflect where your JDK classes are
rem and where your jalview.jar file is.
set CLASSPATH=c:\jdk1.1.6\lib\classes.zip;<path to jalview>\jalview.jar

rem Change the next line to the path to your java binary
set JAVA_EXE=c:\jdk1.1.6\bin\java

rem This next command runs jalview
rem %1 is the alignment file
rem %2 is the alignment format
rem Allowed formats are MSF CLUSTAL FASTA PIR

%JAVA_EXE% jalview.AlignFrame %1 File %2

rem if you like add extra command line options to the previous command as follows:

rem   -mail <mailserver>
rem   -srsserver <srsServer>  - see the README file for details
rem   -database <database>    - srs database name

rem example :  %JAVA_EXE% jalview.AlignFrame %1 File %2 -mail circinus.ebi.ac.uk -srsServer srs.ebi.ac.uk/srs5bin/cgi-bin/ -database swissprot
