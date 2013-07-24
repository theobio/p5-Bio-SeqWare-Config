#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Bio::SeqWare::Config' ) || print "Bail out!\n";
}

diag( "Testing Bio::SeqWare::Config $Bio::SeqWare::Config::VERSION, Perl $], $^X" );
