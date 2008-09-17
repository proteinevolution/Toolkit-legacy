#!/usr/bin/perl -w



#
#
#
#     DO NOT USE THIS SCRIPT FOR MODIFICATION OF THE PRODUCTION TABLES !!!!!!
#
#
#
#



my $script = "create.sql";

my $r = system("mysql -u toolkit -p -h 10.35.1.61 -t toolkit_development < $script");
if($r!=0){
    print("Error creating MySQL database from $script \n");
}else{
    print("done.\n");
}
