package Bio::SeqWare::Config;

use 5.008;         # No reason, just being specific. Update your per.!
use strict;        # Don't allow unsafe perl constructs.
use warnings;      # Enable all optional warnings.
use Carp;          # Base the locations of reported errors on caller's code.
use File::Spec;    # Use portable file paths
use File::HomeDir; # Portably identify user's home directory
use Config::General; # Parse config files, does the heavy lifting.

=head1 NAME

Bio::SeqWare::Config - The SeqWare settings file object

=head1 VERSION

Version 0.000001

=cut

our $VERSION = '0.000001';
our $_KNOWN_KEYS = {
    'dbUser'      => [\&_errorIfEmptyString],
    'dbPassword'  => [\&_errorIfEmptyString],
    'dbHost'      => [\&_errorIfEmptyString],
    'dbSchema'    => [\&_errorIfEmptyString],

    'seqWareVersion'  => [\&_errorIfEmptyString],
    'seqWareHome'     => [\&_errorIfEmptyString],
    'dataRoot'        => [\&_errorIfEmptyString],
    'clusterName'     => [\&_errorIfEmptyString],
};


=head1 SYNOPSIS

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


=head1 DESCRIPTION

Represents the seqware settigs object. The object is created from a settings
file (usually the one in the default location but a different file can be
specified). The settings can be retrieved as key-value pairs. Keys are either
known or novel. Known keys are keys that are in the list returned by
Bio::SeqWare::Config->getAllKnownKeys(). All other keys are novel. The value
of known keys is validated, unknown keys are passed through without validation.
If validity is specifically checked for a novel key, it will fail;
Bio::SeqWare::Config->isValid( "noveKey", "anyValue" ) == false.

This class uses Config::General to do the file parsing and relies on that
module for the heavy lifting.

WARNING: This module is an alpha release, it is subject to future major
revisions and API changes.

=cut

=head1 CLASS METHODS

=head2 new

    my $ConfigObj = Bio::Seqware::Config->new()
    my $ConfigObj = Bio::Seqware::Config->new( $filename )
    my $ConfigObj = Bio::Seqware::Config->new( $configGeneralOptHR )

Create a new C<Bio::SeqWare::Config> object from a settings/config file. If no
C<$filename> is specified, it will use the default filename, I<i.e.> C<new()>
is equivalent to C<new( Bio::SeqWare::Config->getDefaultFile() )>.

It is also possible to specify the file name as well as a bunch of other
parameters as a hash reference. See L<Config::General | https://metacpan.org/module/Config::General>
for details about these configuration parameters. C<Config:General> is used
behind the scene to parse the config file.

NOTE: If a parameters hash is used to set config file options, but no
-ConfigFile parmater is set, the default config file will be parsed/used.

=cut

sub new {
    my $class = shift;
    my $fileOrOptions = shift;
    my $self = {};

    if (! defined $fileOrOptions) {
        my $file = Bio::SeqWare::Config->getDefaultFile();
        if (! -f $file) {
            croak( "Default settings file not found: \"$file\"." );
        }
        $self->{'_cfgGenObj'} = new Config::General( $file );
    }
    elsif (! ref $fileOrOptions ) {
        my $file = $fileOrOptions;
        if (! -f $file) {
            croak( "Specified settings file not found: \"$file\"." );
        }
        $self->{'_cfgGenObj'} = new Config::General( $file );
    }
    elsif (ref $fileOrOptions eq "HASH") {
        my $optionsHR = $fileOrOptions;
        if (! exists $optionsHR->{"-ConfigFile"}) {
             my $file = Bio::SeqWare::Config->getDefaultFile();
             $optionsHR = { %$optionsHR, -ConfigFile => $file };
        }
        $self->{'_cfgGenObj'} = new Config::General( %$optionsHR );
    }
    else {
        croak( "Invalid parameter: \"$fileOrOptions\"." );
    }

    my %settings = $self->{'_cfgGenObj'}->getall();
    $self->{"_settings"} = \%settings;

    bless $self, $class;
    return $self;
}

=head2 getDefaultFile()

    Returns the default config filepath, if found, or undefined. This is
    normally ~/.seqware/settings but could be something else.
=cut

sub getDefaultFile {
    my $class = shift;
    my $homeDir = File::HomeDir->my_home();
    my $defaultFileName = ".seqware/settings";
    my $file = File::Spec->catfile( $homeDir, $defaultFileName );
    if ( -f $file ) {
        return $file;
    }
    else {
        return;
    }
}

=head2 getAllKnownKeys()

Returns an array of all known keys, in alphabetical order.

=cut

sub getAllKnownKeys {
    my $class = shift;
    my @knownKeys = sort( keys ( %{$_KNOWN_KEYS} ));
    return @knownKeys;
}

=head2 isKnownKey( $key )

Returns true if "$key" is a known key, false otherwise (including false if
undefined 

=cut

sub isKnownKey {
    my $class = shift;
    my $key = shift;
    if ( defined $key && exists $_KNOWN_KEYS->{"$key"} ) {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 isValid( $key, $value )

=cut

sub isValid {
    my $class = shift;
    my $key = shift;
    my $val = shift;

    if (! $class->isKnownKey( $key )) {
        return 0;
    }
    my $errorFNsAR = $_KNOWN_KEYS->{"$key"};
    for my $errorFN (@$errorFNsAR) {
        if (&$errorFN($class, $val)) {
            return 0;
        }
    }
    return 1;
}

=head1 METHODS

=head2 getFiles()

Returns the file read to get settings values. Returned as an array as th

=cut

sub getFiles{
    my $self = shift;
    return $self->{'_cfgGenObj'}->files();
}

=head2 hasKey( $key )

Returns true if $key was found in the settings file, false otherwise. Will die
if check a $key that can not be used as a perl hash key.

=cut

sub hasKey {
    my $self = shift;
    my $key  = shift;

    return defined $key && exists( $self->{'_settings'}->{"$key"} );
}

=head2 get()

Retrieve specified value from the config file. If the key is not present in the
config file, returns undefined.

=cut

sub get {
    my $self = shift;
    my $key = shift;
    if (! defined $key || ! exists $self->{'_settings'}->{$key}) {
        return;
    }
    return $self->{'_settings'}->{$key};
}

=head2 getAll()

Retrieve all key-value results as a hash-reference

=cut

sub getAll {
    my $self = shift;
    my %copy = %{$self->{'_settings'}};

    return \%copy;
}

=head2 getKnown

Return a hash ref of all known settings from the config file.

=cut

sub getKnown {
    my $self = shift;
    my $known = {};
    for my $knownKey (keys (%$_KNOWN_KEYS)) {
        if (exists $self->{'_settings'}->{$knownKey}) {
             $known->{$knownKey} = $self->{'_settings'}->{$knownKey};
        }
    }
    return $known;
}

=head2 getNovel

Return a hash ref of all novel settings from the config file.

=cut

sub getNovel {
    my $self = shift;
    my $novel = {};
    for my $key (keys (%{$self->{'_settings'}})) {
        if (! exists $_KNOWN_KEYS->{$key}) {
             $novel->{$key} = $self->{'_settings'}->{$key};
        }
    }
    return $novel;
}

=head2 getKeys()

Retrieve all keys from the config file, in alphabetical order.

=cut

sub getKeys {
    my $self = shift;
    my @keys = sort( keys( %{$self->{'_settings'}} ));
    return @keys;
}

=head2 getKnownKeys

Retrieve all keys from the config file that are understood/expected, in
alphabetical order. These are the known keys and can be validated.

=cut

sub getKnownKeys {
    my $self = shift;
    my @allConfigKeys = $self->getKeys();
    my @knownKeys = ();
    for my $key (@allConfigKeys) {
        if (Bio::SeqWare::Config->isKnownKey( $key )) {
            push( @knownKeys, $key )
        }
    }
    return @knownKeys;
}

=head2 getNovelKeys

Retrieve all novel keys from the config file that are unknown/unexpected, in
alphabetical order. These are the novel keys and can not be validated. They
are included to allow for extension or shared use of this settings file parser.

=cut

sub getNovelKeys {
    my $self = shift;
    my @allConfigKeys = $self->getKeys();
    my @novelKeys = ();
    for my $key (@allConfigKeys) {
        if (! Bio::SeqWare::Config->isKnownKey( $key )) {
            push( @novelKeys, $key )
        }
    }
    return @novelKeys;
}

=head2 _errorIfUndefined

Takes a value as a parameter. Returns an error message if the tested value
is undefined, otherwise returns an empty string.

=cut


sub _errorIfUndefined {
    my $class = shift;
    my $val = shift;
    my $err = "";
    if (! defined $val) {
        $err .= "Error: undefined value.\n";
    }
    return $err;
}

=head2 _errorIfRef

Takes a value as a parameter. Returns an error message if the tested value
is a reference. Returns an empty string if the value is undefined or a normal
scalar value.

=cut

sub _errorIfRef {
    my $class = shift;
    my $val = shift;
    my $err = "";
    my $refType = ref $val;
    if (defined $val && ref $val) {
        my $refType = ref $val;
        $err = "Error: ref value ($refType).\n";
    }
    return $err;
}

=head2 _errorIfEmptyString

Takes a value as a parameter. Returns an error message if the tested value
is undefined, a reference, or an empty string. Otherwise returns an empty
string.

=cut

sub _errorIfEmptyString {
    my $class = shift;
    my $val = shift;
    my $err = $class->_errorIfUndefined($val);
    if (! $err) {
        $err = $class->_errorIfRef( $val );
    }
    if (! $err) {
        if (length "$val" == 0 ) {
            $err .= "Error: empty string.\n";
        }
    }
    return $err;
}

=head1 AUTHOR

Stuart R. Jefferys, C<srjefferys (at) gmail (dot) com>

=head1 BUGS

Please report any bugs or feature requests to C<bug-p5-bio-seqware-config at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=p5-Bio-Seqware-Config>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 INSTALLATION, CONTRIBUTION, AND SUPPORT

This module is developed and hosted on GitHub, at
L<p5-Bio-SeqWare-Config https://github.com/theobio/p5-Bio-SeqWare-Config>. It
is not currently on CPAN, and I don't have any immediate plans to post it
there unless requested by core SeqWare developers (It is not my place to
set out a module name hierarchy for the project as a whole :)

You can install this module directly from github using

    $ cpanm git://github.com/theobio/p5-Bio-SeqWare-Config.git

or by downloading the module as a zip arckive using your web browser (from
( L<https://github.com/theobio/p5-Bio-SeqWare-Config/archive/master.zip> )
unzipping it, and then executing the normal (C>Module::Build>) incantation:

     perl Build.PL
     ./Build
     ./Build test
     ./Build install

=head1 ACKNOWLEDGEMENTS

This module was developed for use with L<SegWare | http://seqware.github.io>.

=head1 LICENSE AND COPYRIGHT

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

=cut

1; # End of Bio::SeqWare::Config
