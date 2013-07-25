#! /usr/bin/env perl

use Test::More tests => 1 + 18;

BEGIN {
	use_ok( 'Bio::SeqWare::Config' );
}

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
    	fail( "NOT IMPLEMENTED" );
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
    	fail( "NOT IMPLEMENTED" );
	}
}

sub testIsKnownKey {
	plan( tests => 1 );
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
