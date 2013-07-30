# NAME

Bio::SeqWare::Config - The SeqWare settings file object

# VERSION

Version 0.000001

# SYNOPSIS

Accesses SeqWare settings config file data as a hash.

    use Bio::SeqWare::Config;

    my $cfgObj = Bio::SeqWare::Config->new();
    my $cfgObj = Bio::SeqWare::Config->new( "path/to/file.cfg" );
    my $cfgObj = Bio::SeqWare::Config->new( { -param=value, } );

    # Get the default filename (~/.seqware/settings).
    my $file = Bio::SeqWare::Config->getDefaultFile();

    # Retrieve file names
    my @files = $cfgObj->getFiles();

    # Working with novel or known key/values from file.
    my $allConfigHR = $cfgObj->getAll();
    my @allKeys     = $cfgObj->getKeys();
    my $isFoundKey  = $cfgObj->hasKey( "keyToLookFor" );
    my $val         = $cfgObj->get( "key" );

    # Working with novel keys. These can not be validated.
    my $novelConfigHR = $cfgObj->getNovel();
    my @novleKeys     = $cfgObj->getNovelKeys();

    # Working with known keys. These can be validated.
    my $knownConfigHR = $cfgObj->getKnown();
    my @knownKeys     = $cfgObj->getKnownKeys();

    # Validation
    my $allKnownKeys = Bio::SeqWare::Config::getAllKnownKeys();
    my $isKnownKey   = Bio::SeqWare::Config::isKnownKey( "keyToCheck" );
    my $isValid      = Bio::SeqWare::Config->isValid( "knownKey", "valToCheck" );

# DESCRIPTION

Represents the seqware settigs object. The object is created from a settings
file (usually the one in the default location but a different file can be
specified). The settings can be retrieved as key-value pairs. Keys are either
known or novel. Known keys are keys that are in the list returned by
`Bio::SeqWare::Config->getAllKnownKeys()`. All other keys are novel. The value
of known keys is validated, unknown keys are passed through without validation.
If validity is specifically checked for a novel key, it will fail;
`Bio::SeqWare::Config->isValid( "noveKey", "anyValue" ) == false`.

This class uses [Config::General ](http://search.cpan.org/perldoc?https:#/metacpan.org/module/Config::General)
to do the file parsing and relies on that module for the heavy lifting.

WARNING: This module is an alpha release, it is subject to future major
revisions and API changes.

# CLASS METHODS

## new( ... )

    my $ConfigObj = Bio::Seqware::Config->new()
    my $ConfigObj = Bio::Seqware::Config->new( $filename )
    my $ConfigObj = Bio::Seqware::Config->new( $configGeneralOptHR )

Create a new `Bio::SeqWare::Config` object from a settings/config file. If no
`$filename` is specified, it will use the default filename, _i.e._ `new()`
is equivalent to `new( Bio::SeqWare::Config->getDefaultFile() )`.

It is also possible to specify the file name as well as a bunch of other
parameters as a hash reference. See [Config::General ](http://search.cpan.org/perldoc?https:#/metacpan.org/module/Config::General)
for details about these configuration parameters. `Config:General` is used
behind the scene to parse the config file.

NOTE: If a parameters hash is used to set config file options, but no
\-ConfigFile parmater is set, the default config file will be parsed/used.

## getDefaultFile()

Returns the default config filepath, if found, or undefined. This is
normally `~/.seqware/settings` but could be something else.

## getAllKnownKeys()

Returns an array of all known keys, in alphabetical order.

## isKnownKey( $key )

Returns true if "$key" is a known key, false otherwise (including false if
undefined 

## isValid( $key, $value )

Validate $value as allowed for $key, returning true if allowed, false if not.
If key is not a known key, will return false for any value (including undefined).

Note: Validation is the minimal, up-front validation that can be performed on
one $key's-$value independently of any others.

# INSTANCE METHODS

## getFiles()

Returns the file read to get settings values. Returned as an array as the
backing code of Config::General allows multiple config files to be read and
merged, and we might want to support that in future. Currently will only ever
return a 1 element array.

## hasKey( $key )

Returns true if $key was found in the settings file, false otherwise. Will die
if check a $key that can not be used as a perl hash key.

## get( $key )

Retrieve specified value from the config file. If the key is not present in the
config file, returns undefined.

## getAll()

Retrieve all key-value results as a hash-reference

## getKnown

Return a hash ref of all known settings from the config file.

## getNovel

Return a hash ref of all novel settings from the config file.

## getKeys()

Retrieve all keys from the config file, in alphabetical order.

## getKnownKeys

Retrieve all keys from the config file that are understood/expected, in
alphabetical order. These are the known keys and can be validated.

## getNovelKeys

Retrieve all novel keys from the config file that are unknown/unexpected, in
alphabetical order. These are the novel keys and can not be validated. They
are included to allow for extension or shared use of this settings file parser.

# INTERNAL METHODS

NOTE: These are methods are for _internal use only_. They are documented here
mainly due to the effort needed to separate user and developer documentation.
Pay no attention to code behind the curtain; these are not the methods you are
looking for. If you use these function _you are doing something wrong._

## \_errorIfUndefined( $val )

Takes a value as a parameter. Returns an error message if the tested value
is undefined, otherwise returns an empty string.

## \_errorIfRef( $val )

Takes a value as a parameter. Returns an error message if the tested value
is a reference. Returns an empty string if the value is undefined or a normal
scalar value.

## \_errorIfEmptyString( $val )

Takes a value as a parameter. Returns an error message if the tested value
is undefined, a reference, or an empty string. Otherwise returns an empty
string.

# AUTHOR

Stuart R. Jefferys, `srjefferys (at) gmail (dot) com`

# CONTRIBUTING

This module is developed and hosted on GitHub, at
[p5-Bio-SeqWare-Config ](http://search.cpan.org/perldoc?https:#/github.com/theobio/p5-Bio-SeqWare-Config). It
is not currently on CPAN, and I don't have any immediate plans to post it
there unless requested by core SeqWare developers (It is not my place to
set out a module name hierarchy for the project as a whole :)

# INSTALLATION

You can install this module directly from github using

    $ cpanm git://github.com/theobio/p5-Bio-SeqWare-Config.git

or by downloading the module as a zip arckive using your web browser (from
( [https://github.com/theobio/p5-Bio-SeqWare-Config/archive/master.zip](https://github.com/theobio/p5-Bio-SeqWare-Config/archive/master.zip) )
unzipping it, and then executing the normal (`Module::Build`) incantation:

     perl Build.PL
     ./Build
     ./Build test
     ./Build install

# BUGS AND SUPPORT

No known bugs are present in this release. Unknown bugs are a virtual
certainty. Please report bugs (and feature requests) though the
Github issue tracker associated with the development repository, at:

[https://github.com/theobio/p5-Bio-SeqWare-Config/issues](https://github.com/theobio/p5-Bio-SeqWare-Config/issues)

Note: you must have a GitHub account to submit issues.

# ACKNOWLEDGEMENTS

This module was developed for use with [SegWare ](http://search.cpan.org/perldoc?http:#/seqware.github.io).

# LICENSE AND COPYRIGHT

Copyright 2013 Stuart R. Jefferys.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
