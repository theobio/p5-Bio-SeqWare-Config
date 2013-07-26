#! /usr/bin/env perl

use File::Spec;
use Test::More tests => 1 + 21;

BEGIN {
	use_ok( 'Bio::SeqWare::Config' );
}

our $CLASS = 'Bio::SeqWare::Config';

subtest( 'new()' => \&testNewDefault     );
subtest( 'new()' => \&testNewFile        );
subtest( 'new()' => \&testNewCfgGenParam );
subtest( 'new()' => \&testNewBad         );

subtest( 'getDefaultFile()' => \&testGetDefaultFile );

subtest( 'getAll()'  => \&testGetAll  );
subtest( 'getKeys()' => \&testGetKeys );
subtest( 'hasKey()'  => \&testHasKey  );
subtest( 'get()'     => \&testGet     );

subtest( 'getNovel()'     => \&testGetNovel     );
subtest( 'getNovelKeys()' => \&testGetNovelKeys );
subtest( 'hasNovelKey()'  => \&testHasNovelKey  );

subtest( 'getKnown()'     => \&testGetKnown     );
subtest( 'getKnownKeys()' => \&testGetKnownKeys );
subtest( 'hasKnownKey()'  => \&testHasKnownKey  );

subtest( 'isValid()'         => \&testIsValid         );
subtest( 'getAllKnownKeys()' => \&testGetAllKnownKeys );
subtest( 'isKnownKey()'      => \&testIsKnownKey      );

subtest( 'errorIfUndefined()'   => \&test_ErrorIfUndefined   );
subtest( 'errorIfRef()'         => \&test_ErrorIfRef         );
subtest( 'errorIfEmptyString()' => \&test_ErrorIfEmptyString );


sub testNewDefault {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testNewFile {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testNewCfgGenParam {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testNewBad {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGetDefaultFile {
	plan( tests => 1 );
	{
        my $homeDir = $ENV{"HOME"};
        my $file = $Bio::SeqWare::Config::DEFAULT_FILE_NAME;
        my $want = File::Spec->catfile( $homeDir, $file);
        my $got = $CLASS->getDefaultFile();
    	is( $want, $got );
	}
}

sub testGetAll {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGetKeys {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testHasKey {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGet {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGetNovel {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGetNovelKeys {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testHasNovelKey {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGetKnown {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGetKnownKeys {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testHasKnownKey {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testGetAllKnownKeys {
	plan( tests => 1 );
	{
	    my @want = sort( qw( dbUser dbPassword ));
	    my @got = $CLASS->getAllKnownKeys();
    	is_deeply( \@want, \@got );
	}
}

sub testIsKnownKey {
    my @keys = $CLASS->getAllKnownKeys().length;
	plan( tests => @keys.length );
	{
	    
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testIsValid {
	plan( tests => 1 );
	{
    	fail( "NOT IMPLEMENTED" );
	}
}

sub test_ErrorIfUndefined {
	plan( tests => 4 );
	{
        my $goodval = "Not undefined";
        is( $CLASS->_errorIfUndefined( $goodVal ), "", "String is defined" );
	}
	{
        my $goodval = "";
        is( $CLASS->_errorIfUndefined( $goodVal ), "", "Empty is defined" );
	}
	{
        my $goodval = {};
        is( $CLASS->_errorIfUndefined( $goodVal ), "", "Hash ref is defined" );
	}
	{
        my $badVal;
        $want = "Error: undefined value.\n";
        $got = $CLASS->_errorIfUndefined( $badVal );
        is( $got, $want, "Error when undefined" );
	}
}

sub test_ErrorIfRef {
	plan( tests => 4 );
	{
        my $goodval = "Not ref";
        is( $CLASS->_errorIfRef( $goodVal ), "", "String is not ref" );
	}
	{
        my $goodval = "";
        is( $CLASS->_errorIfRef( $goodVal ), "", "Empty is not ref" );
	}
	{
        my $goodval;
        is( $CLASS->_errorIfRef( $goodVal ), "", "Undefined is not ref" );
	}
	{
        my $badVal = {};
        $want = "Error: ref value (HASH).\n";
        $got = $CLASS->_errorIfRef( $badVal );
        is( $got, $want, "Error if refernece type" );
	}
}

sub test_ErrorIfEmptyString {
	plan( tests => 4 );
	{
        my $goodval = "Not empty string";
        is( $CLASS->_errorIfEmptyString( $goodVal ), "", "String is not empty" );
	}
	{
        my $badval = "";
        $want = "Error: empty string.\n";
        $got = $CLASS->_errorIfEmptyString( $badval );
        is( $got, $want, "Error when empty" );
	}
	{
        my $badval = "";
        $want = "Error: undefined.\n";
        $got = $CLASS->_errorIfEmptyString( $badval );
        is( $got, $want, "Error when empty" );
	}
	{
        my $badVal = {};
        $want = "Error: ref value (HASH).\n";
        $got = $CLASS->_errorIfEmptyString( $badVal );
        is( $got, $want, "Error if refernece type" );
	}
}
