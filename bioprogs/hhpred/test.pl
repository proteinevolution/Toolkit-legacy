#!/usr/bin/perl -w
use strict;

system ("/home/soeding/programs/blast-2.2.16/bin/blastpgp -I T -s T -b 20000 -v 1 -e 0.001 -d /home/soeding/nr/nre90 -i /tmp/soeding/24221/BadA_head.seq > /tmp/soeding/24221/BadA_head.bl 2>&1");

print("\n\n******************* Finished! ********************\n\n");
