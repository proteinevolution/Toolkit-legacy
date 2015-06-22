#!/usr/bin/perl -w

use strict;

my @pdb_entries;
my @dssp_entries;

@pdb_entries = </raid/db/pdb/*.ent>;

foreach (@pdb_entries) {
    system("cp -u -v -p $_ /cluster/pdb");
}

@dssp_entries=</raid/db/dssp/data/*.dssp>;

foreach (@dssp_entries) {
    system("cp -u -v -p $_ /cluster/dssp");
}

exit;
