#! /usr/bin/perl -w
#
use lib "/home/soeding/perl";  
use strict;
use MyPaths;      # config file with paht variables for nr, blast, psipred, pdb, dssp etc.

my $v=2;
my $help="
Make new directory and tar file for hhsearch package with all *.C and *.perl files 
Usage:   newversion.pl newdir version_string
Example: newversion.pl hh_1.1.4 'version 1.1.4 (December 2004)'
";
if (@ARGV<2) {die ($help);}
my $newdir=$ARGV[0];
my $version=$ARGV[1];

&System("$perl/autoreplace.pl 'const char VERSION_AND_DATE.*' 'const char VERSION_AND_DATE[]=\"$version\";' -n -f $hh/hhdecl.C");

&System("mkdir $newdir");
&System("cp $hh/util.C $newdir");
&System("cp $hh/list.h $newdir");
&System("cp $hh/list.C $newdir");
&System("cp $hh/hash.h $newdir");
&System("cp $hh/hash.C $newdir");
&System("cp $hh/hhdecl.C $newdir");
&System("cp $hh/hhutil.C $newdir");
&System("cp $hh/hhmatrices.C $newdir");
&System("cp $hh/hhalignment.h $newdir");
&System("cp $hh/hhalignment.C $newdir");
&System("cp $hh/hhfullalignment.h $newdir");
&System("cp $hh/hhfullalignment.C $newdir");
&System("cp $hh/hhhalfalignment.h $newdir");
&System("cp $hh/hhhalfalignment.C $newdir");
&System("cp $hh/hhhmm.h $newdir");
&System("cp $hh/hhhmm.C $newdir");
&System("cp $hh/hhhit.h $newdir");
&System("cp $hh/hhhit.C $newdir");
&System("cp $hh/hhhitlist.h $newdir");
&System("cp $hh/hhhitlist.C $newdir");
&System("cp $hh/hhfunc.C $newdir");
&System("cp $hh/hhsearch.C $newdir");
&System("cp $hh/hhmake.C   $newdir");
&System("cp $hh/hhfilter.C $newdir");
&System("cp $hh/hhalign.C  $newdir");
&System("cp $hh/hhcorr.C   $newdir");
&System("cp $hh/pngwriter.cc $newdir");
&System("cp $hh/pngwriter.h  $newdir");
&System("cp $hh/hhmakemodel.pl $newdir");


if (0) { # adapt perl scripts (remove use lib commands etc.)
    &System("cp $hh/hhmakemodel.pl   $newdir");
    &System("cp $hh/addpsipred.pl $newdir");
    &System("cp $hh/buildali.pl    $newdir");
    &System("cp $perl/alignhits.pl $newdir");
    &System("cp $perl/reformat.pl  $newdir");
    &System("cp $perl/Align.pm     $newdir");
#&System("cp $hh/buildinter.pl $newdir");
#&System("cp $hh/mergeali.pl $newdir");
}

&System("cp $hh/HHsearch-guide.pdf $newdir");
&System("cp $hh/CHANGES $newdir");
&System("cp $hh/LICENSE $newdir");


if (1) { # Win32 (compiled under MinGW)
    &System("cp $hh/pthread*.dll $hh/libpng*.dll $hh/zlib*.dll $newdir");
    &System("cp $hh/hhsearch.exe $hh/hhmake.exe $hh/hhalign.exe $hh/hhfilter.exe $newdir");
    &System("cd $newdir; strip hhsearch.exe hhalign.exe hhmake.exe hhfilter.exe");
    &System("cd $newdir; tar -czvf $newdir.win32.tar.gz hhsearch.exe hhalign.exe hhmake.exe hhfilter.exe *.pl *.pm HHsearch-guide.pdf CHANGES LICENSE pthread*.dll libpng*.dll zlib*.dll");
}

if (0) { # MacOSX 
    &System("cp $hh/hhsearchMac $newdir/hhsearch");
    &System("cp $hh/hhmakeMac $newdir/hhmake");
    &System("cp $hh/hhalignMac $newdir/hhalign");
    &System("cp $hh/hhfilterMac $newdir/hhfilter");
    &System("cd $newdir; strip hhsearch hhalign hhmake hhfilter");
    &System("cd $newdir; tar -czvf $newdir.mac_ppc.tar.gz hhsearch hhalign hhmake hhfilter *.pl *.pm HHsearch-guide.pdf CHANGES LICENSE");
    &System("mv hhsearch hhsearchMac; mv hhmake hhmakeMac; mv hhalign hhalignMac; mv hhfilter hhfilterMac");
}

if (0) { # SunOS
    &System("cp $hh/hhsearchSUN $newdir/hhsearch");
    &System("cp $hh/hhmakeSUN $newdir/hhmake");
    &System("cp $hh/hhalignSUN $newdir/hhalign");
    &System("cp $hh/hhfilterSUN $newdir/hhfilter");
    &System("cd $newdir; strip hhsearch hhalign hhmake hhfilter");
    &System("cd $newdir; tar -czvf $newdir.win32.tar.gz hhsearch hhalign hhmake hhfilter *.pl *.pm HHsearch-guide.pdf CHANGES LICENSE");
    &System("mv hhsearch hhsearchSUN; mv hhmake hhmakeSUN; mv hhalign hhalignSUN; mv hhfilter hhfilterSUN");
}

if (1) { # Linux AMD64
    &System("g++ $hh/hhsearch.C -o $newdir/hhsearch -O3 -march=athlon64 -lpthread -static -fno-strict-aliasing");
    &System("g++ $hh/hhmake.C   -o $newdir/hhmake   -O3 -march=athlon64 -static -fno-strict-aliasing");
    &System("g++ $hh/hhfilter.C -o $newdir/hhfilter -O3 -march=athlon64 -static -fno-strict-aliasing"); 
    &System("g++ $hh/hhalign.C  -o $newdir/hhalign  -O3 -march=athlon64 -I/usr/include/ -L/usr/lib -lpng -lz -static -fno-strict-aliasing");
    &System("cd $newdir; strip hhsearch hhalign hhmake hhfilter");
    &System("cd $newdir; tar -czvf $newdir.linux64.tar.gz hhsearch hhalign hhmake hhfilter *.pl *.pm HHsearch-guide.pdf CHANGES LICENSE"); 
    &System("cd $newdir; mv hhsearch hhsearch64; mv hhmake hhmake64; mv hhalign hhalign64; mv hhfilter hhfilter64");
}    
    
if (1) { # Linux i86
    &System("g++ $hh/hhsearch.C -o $newdir/hhsearch -O3 -march=i686 -m32 -lpthread -static -fno-strict-aliasing");
    &System("g++ $hh/hhmake.C   -o $newdir/hhmake   -O3 -march=i686 -m32 -static -fno-strict-aliasing");
    &System("g++ $hh/hhfilter.C -o $newdir/hhfilter -O3 -march=i686 -m32 -static -fno-strict-aliasing");
    &System("g++ $hh/hhalign.C  -o $newdir/hhalign  -O3 -march=i686 -m32 -I/usr/include/ -L/usr/lib -lpng -lz -static -fno-strict-aliasing");
    &System("cd $newdir; strip hhsearch hhalign hhmake hhfilter");
    &System("cd $newdir; tar -czvf $newdir.linux32.tar.gz hhsearch hhalign hhmake hhfilter *.pl *.pm HHsearch-guide.pdf CHANGES LICENSE");
}


print("\n");
exit;

################################################################################################
sub System()
{
    if ($v>=2) {printf("%s\n",$_[0]);} 
    return system($_[0])/256;
}
