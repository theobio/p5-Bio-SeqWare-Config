#! /usr/bin/env perl

# Using support methods to create temporary config file for parsing.
# This file can get left behind, so note its name if tests fail.
use File::Spec;   # Portable file handling for creating temp files
use Carp;         # Caller-relative error messages
use IO::File;     # File handles as variables

use Test::More tests => 1 + 17;

BEGIN {
	use_ok( 'Bio::SeqWare::Config' );
}

my $CLASS = 'Bio::SeqWare::Config';

my $GOOD_CONFIG_FILE = File::Spec->catfile(
    File::Spec->tmpdir(), "testingBioSeqWareConfig.cfg"
);

my $GOOD_CONFIG_FILE_CONTENTS = <<END;

# Config file created for testing of Bio::SeqWare::Config

dbUser      = "seqware"
dbPassword  = "seqware"
dbHost      = "swprod.bioinf.unc.edu"
dbSchema    = "seqware_meta_db"

seqWareVersion   0.7.0
seqWareHome "/Users/srj/Documents/Dev/Seqware/UNC_20110808/seqware-pipeline"
dataRoot    "/Users/srj/BigData"

clusterName = SRJ

novelKey = 42

K=V

END

my $KNOWN_DATA_HR = {
    'dbUser'      => "seqware",
    'dbPassword'  => "seqware",
    'dbHost'      => "swprod.bioinf.unc.edu",
    'dbSchema'    => "seqware_meta_db",
    'seqWareVersion'   => '0.7.0',
    'seqWareHome'      => "/Users/srj/Documents/Dev/Seqware/UNC_20110808/seqware-pipeline",
    'dataRoot'         => "/Users/srj/BigData",
    'clusterName'      => "SRJ",
};

my $NOVEL_DATA_HR = {
    'novelKey' => 42,
    'K' => 'V',
};

my $ALL_DATA_HR = { %$KNOWN_DATA_HR, %$NOVEL_DATA_HR };

my @KNOWN_KEYS = sort( keys( %$KNOWN_DATA_HR ));
my @NOVEL_KEYS = sort( keys( %$NOVEL_DATA_HR ));
my @ALL_KEYS   = sort( keys( %$ALL_DATA_HR ));
my @NOT_KEYS = ("NotAkey", "", undef);

_makeFile($GOOD_CONFIG_FILE, $GOOD_CONFIG_FILE_CONTENTS);

# Objects to use
my $cfg     = $CLASS->new( $GOOD_CONFIG_FILE );
my $defaultCfg = $CLASS->new( );
my $paramCfg   = $CLASS->new( { -ConfigFile => $GOOD_CONFIG_FILE } );


subtest( 'new()' => \&testNew );

subtest( 'getDefaultFile()' => \&testGetDefaultFile );
subtest( 'getFiles()'       => \&testGetFiles       );

subtest( 'getAll()'  => \&testGetAll  );
subtest( 'getKeys()' => \&testGetKeys );
subtest( 'hasKey()'  => \&testHasKey  );
subtest( 'get()'     => \&testGet     );

subtest( 'getNovel()'     => \&testGetNovel     );
subtest( 'getNovelKeys()' => \&testGetNovelKeys );

subtest( 'getKnown()'     => \&testGetKnown     );
subtest( 'getKnownKeys()' => \&testGetKnownKeys );

subtest( 'isValid()'         => \&testIsValid         );
subtest( 'getAllKnownKeys()' => \&testGetAllKnownKeys );
subtest( 'isKnownKey()'      => \&testIsKnownKey      );

subtest( 'errorIfUndefined()'   => \&test_ErrorIfUndefined   );
subtest( 'errorIfRef()'         => \&test_ErrorIfRef         );
subtest( 'errorIfEmptyString()' => \&test_ErrorIfEmptyString );

_removeFile( $GOOD_CONFIG_FILE );

sub testNew {
	plan( tests => 6 );
	{
	    ok( $defaultCfg, "Default config object creatable" );
	}
	{
	    ok( $cfg, "Specified config object creatable" );
	}
	{
	    ok( $paramCfg, "Parameterized config object creatable" );
	}
	{
	    eval{ $CLASS->new( "NO_sUCH_fILE.I_hope" ); };
	    $got = $@;
	    $want = qr/^Specified settings file not found: "NO_sUCH_fILE.I_hope"\./;
	    like($got, $want, "Error for new without existing file" );
	}

    my $defaultParamCfg = $CLASS->new( {} );
	{
        ok( $defaultParamCfg, "Parameterized config object with default file createable.");
	}
	{
        my @got = $defaultParamCfg->getFiles();
        my @want = ($CLASS->getDefaultFile());
        is_deeply( \@got, \@want);
	}
}

sub testGetDefaultFile {
	plan( tests => 1 );
	my $expectedFileName = ".seqware/settings";
	{
        my $homeDir = $ENV{"HOME"};
        my $file = $expectedFileName;
        my $want = File::Spec->catfile( $homeDir, $file);
        my $got = $CLASS->getDefaultFile();
    	is( $got, $want );
	}
}

sub testGetFiles {
	plan( tests => 1 );
    {
            my @want = ( $GOOD_CONFIG_FILE );
            my @got = $cfg->getFiles();
            is_deeply( \@got, \@want, "manually set files retrieved");
	}
}

sub testGetAll {
	plan( tests => 2 );
	{
	    my $want = $ALL_DATA_HR;
	    my $got = $cfg->getAll();
        is_deeply( $got, $want, "manually set file contents available");
	}
	{
	    my $want = $ALL_DATA_HR;
	    my $dummy = $cfg->getAll();
	    my $keyToChange = $KNOWN_KEYS[0];
	    $dummy->{$keyToChange} = "INDEPENDENCE";
	    my $got = $cfg->getAll();
        is_deeply( $got, $want, "Retrieved hashref safe for modify");
	}
}

sub testGetKeys {
	plan( tests => 1 );
	{
	    my @want = @ALL_KEYS;
	    my @got = $cfg->getKeys();
        is_deeply( \@got, \@want, "All keys retrieved in order");
	}
}

sub testHasKey {
	plan( tests => scalar @ALL_KEYS + scalar @NOT_KEYS);
	for my $key (@ALL_KEYS) {
        {
            ok( $cfg->hasKey( $key ), "For config file key $key");
 	    }
	}
	for my $key (@NOT_KEYS) {
        {
            ok( ! $cfg->hasKey( $key ), "For unknown config file key " . _undefAsString($key));
 	    }
	}
}

sub testGet {
	plan( tests => scalar @ALL_KEYS + scalar @NOT_KEYS);
	for my $key (@ALL_KEYS) {
        {
 	        my $want = $ALL_DATA_HR->{$key};
 	        my $got = $cfg->get($key);
            is( $got, $want, "$key value retrieved correctly");
 	    }
	}
	for my $key (@NOT_KEYS) {
        {
            ok( ! defined $cfg->get($key), "Undefined for unknown keys");
        }
	}
}

sub testGetNovel {
	plan( tests => 2 );
	{
	    my $want = $NOVEL_DATA_HR;
	    my $got = $cfg->getNovel();
        is_deeply( $got, $want, "All novel data retrieved");
	}
    {
	    my $want = $NOVEL_DATA_HR;
	    my $dummy = $cfg->getNovel();
	    my $keyToChange = $NOVEL_KEYS[0];
	    $dummy->{$keyToChange} = "INDEPENDENCE";
	    my $got = $cfg->getNovel();
        is_deeply( $got, $want, "Retrieved novel hashref safe for modify");
	}
}

sub testGetNovelKeys {
	plan( tests => 1 );
	{
	    my @want = @NOVEL_KEYS;
	    my @got = $cfg->getNovelKeys();
        is_deeply( \@got, \@want, "All novel keys retrieved in order");
	}
}

sub testGetKnown {
	plan( tests => 2 );
	{
	    my $want = $KNOWN_DATA_HR;
	    my $got = $cfg->getKnown();
        is_deeply( $got, $want, "All known data retrieved");
	}
    {
	    my $want = $KNOWN_DATA_HR;
	    my $dummy = $cfg->getKnown();
	    my $keyToChange = $KNOWN_KEYS[0];
	    $dummy->{$keyToChange} = "INDEPENDENCE";
	    my $got = $cfg->getKnown();
        is_deeply( $got, $want, "Retrieved known hashref safe for modify");
    }
}

sub testGetKnownKeys {
	plan( tests => 1 );
	{
	    my @want = @KNOWN_KEYS;
	    my @got = $cfg->getKnownKeys();
        is_deeply( \@got, \@want, "All known keys retrieved in order");
	}
}

sub testGetAllKnownKeys {
	plan( tests => 2 );
	{
	    my @want = @KNOWN_KEYS;
	    my @got = $CLASS->getAllKnownKeys();
    	is( scalar @want, scalar @got, "Number of knwon keys correct." );
    }
	{
	    my @want = @KNOWN_KEYS;
	    my @got = $CLASS->getAllKnownKeys();
    	is_deeply( \@want, \@got, "Ordered list of known keys correct" );
    }
}

sub testIsKnownKey {
	plan( tests => scalar @KNOWN_KEYS + scalar @NOVEL_KEYS + scalar @NOT_KEYS );
	{
        for my $knownKey (@KNOWN_KEYS) {
            ok( $CLASS->isKnownKey($knownKey), "$knownKey is known key");
        }
	}
	{
        for my $novelKey (@NOVEL_KEYS) {
            ok( ! $CLASS->isKnownKey($novelKey), "$novelKey is unknown key");
        }
	}
	{
        for my $unknownKey (@NOT_KEYS) {
            ok( ! $CLASS->isKnownKey($unknownKey), _undefAsString($unknownKey) . " is unknown key");
        }
	}
}

sub testIsValid {
	plan( tests => 2 * (scalar @KNOWN_KEYS + scalar @NOVEL_KEYS + scalar @NOT_KEYS) );
	{
        for my $knownKey (@KNOWN_KEYS) {
            ok( $CLASS->isValid($knownKey, "OK"), "$knownKey is valid for value \"OK\"");
        }
	}
	{
        for my $knownKey (@KNOWN_KEYS) {
            ok( ! $CLASS->isValid($knownKey, ""), "$knownKey is not valid for value \"\"");
        }
	}
	{
        for my $novelKey (@NOVEL_KEYS) {
            ok( ! $CLASS->isValid($novelKey, "OK"), "$novelKey is not valid for value \"OK\"");
        }
	}
	{
        for my $novelKey (@NOVEL_KEYS) {
            ok( ! $CLASS->isValid($novelKey, ""), "$novelKey is not valid for value \"\"");
        }
	}
	{
        for my $unknownKey (@NOT_KEYS) {
            ok( ! $CLASS->isValid($unknownKey, "OK"), _undefAsString($unknownKey) . " is not valid for value \"OK\"");
        }
	}
	{
        for my $unknownKey (@NOT_KEYS) {
            ok( ! $CLASS->isValid($unknownKey, ""), _undefAsString($unknownKey) . " is not valid for value \"\"");
        }
	}
}

sub test_ErrorIfUndefined {
	plan( tests => 4 );
	{
        my $goodVal = "Not undefined";
        is( $CLASS->_errorIfUndefined( $goodVal ), "", "String is defined" );
	}
	{
        my $goodVal = "";
        is( $CLASS->_errorIfUndefined( $goodVal ), "", "Empty is defined" );
	}
	{
        my $goodVal = {};
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
        my $goodVal = "Not ref";
        is( $CLASS->_errorIfRef( $goodVal ), "", "String is not ref" );
	}
	{
        my $goodVal = "";
        is( $CLASS->_errorIfRef( $goodVal ), "", "Empty is not ref" );
	}
	{
        my $goodVal;
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
        my $goodVal = "Not empty string";
        is( $CLASS->_errorIfEmptyString( $goodVal ), "", "String is not empty" );
	}
	{
        my $badVal = "";
        $want = "Error: empty string.\n";
        $got = $CLASS->_errorIfEmptyString( $badVal );
        is( $got, $want, "Error when empty" );
	}
	{
        my $badVal;
        $want = "Error: undefined value.\n";
        $got = $CLASS->_errorIfEmptyString( $badVal );
        is( $got, $want, "Error when empty" );
	}
	{
        my $badVal = {};
        $want = "Error: ref value (HASH).\n";
        $got = $CLASS->_errorIfEmptyString( $badVal );
        is( $got, $want, "Error if refernece type" );
	}
}

sub _makeFile{
	my $fileName = shift;
	my $fileContentString = shift;
	
	if (-e $fileName || -l $fileName) {
		croak "Can't make file, it already exists: $fileName";
	}
	
	my $fh = IO::File->new( "> $fileName" )
			or croak( "Can\'t open output new output file \"$fileName\": $!\n" );
	print( $fh $fileContentString);
	$fh->close();
}

sub _removeFile{
	my $fileName = shift;
	if (-e $fileName || -l $fileName) {
		unlink($fileName)
			or carp "Can't delete tempfile: must delete manually: $fileName";
	}
}

sub _undefAsString {
    my $key = shift;
    if (defined $key) {
        return "$key"
    }
    return "_UNDEF_";
}
