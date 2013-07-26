package Bio::SeqWare::Config;

use 5.010;
use strict;
use warnings;
use Carp;
use File::Spec;
use Config::General;
use File::HomeDir;

=head1 NAME

Bio::SeqWare::Config - The SeqWare settings file object

=head1 VERSION

Version 0.000001

=cut

our $VERSION = '0.000001';
our $DEFAULT_FILE_NAME = ".seqware/settings";
our $KNOWN_KEYS = {
    'dbUser' => \&_dbUserErr,
    'dbPassword' => \&_dbPasswordErr,
};

=head1 SYNOPSIS

Accesses SeqWare settings from a config file as key-value.

    use Bio::SeqWare::Config;

    # Load the default SeqWare settings file
    my $cfgObj = Bio::SeqWare::Config->new();

    # Load the specified file as a SeqWare settings file.
    my $cfgObj = Bio::SeqWare::Config->new( "path/to/file.cfg" );

    # Get the default filename (~/.seqware/settings).
    my $file = Bio::SeqWare::Config->getDefaultFile();

    # Retrieve file names
    my @files = $cfgObj->getFiles();

    # Working with all keys.
    my $allConfigHR = $cfgObj->getAll();
    my @allKeys     = $cfgObj->getKeys();
    my $isFoundKey  = $cfgObj->hasKey( "keyToLookFor" );

    my $val         = $cfgObj->get( "key" );

    # Working with novel keys. These can not be validated.
    my $novelConfigHR = $cfgObj->getNovel();
    my @novleKeys     = $cfgObj->getNovelKeys();
    my $isFoundNovel  = $cfgObj->hasNovelKey( "keyToLookFor" );

    # Working with known keys. These can be validated.
    my $knownConfigHR = $cfgObj->getKnown();
    my @knownKeys     = $cfgObj->getKnownKeys();
    my $isFoundKnown  = $cfgObj->hasKnownKey( "keyToLookFor" );

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

This class uses Config::General to do the file parsing.

=cut

=head1 CLASS METHODS

=head2 new()
=head2 new( $filename )
=head2 new( $configGeneralOptionsHR )

Create a new Bio::SeqWare::Config object from a settings/config file. If no
$filename is specified, it will use the default filename returned by
Bio::SeqWare::Config->getDefaultFile().

It is also possible to specify the file name to look for (as well as a bunch
of configuration parameters) to use when parsing the config file. Normally
this should not be needed. Configuration parameters match Config:General, as
that is used behind the scene to parse the config file. NOTE: If any config
parameters are needed, the file to parse will have to be explicitly specified.

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
    elsif (ref $fileOrOptions == "HASH") {
        $self->{'_cfgGenObj'} = new Config::General( $fileOrOptions );
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
    my $file = File::Spec->catfile( $homeDir, $DEFAULT_FILE_NAME );
    if ( -e $file ) {
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
    return sort( keys ( %{$Bio::SeqWare::Config::KNOWN_KEYS} ));
}

=head1 METHODS

=head2 $obj->getFile()

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

    return exists $self->{$key};
}

=head2 getSettings()

=cut

sub getSettings {
    my $cfgHR = {};

    return $cfgHR;
}

=head2 getKnownSettings

=cut

sub getKnownSettings {
    my $cfgHR = {};

    return $cfgHR;
}

=head2 getRawSettings

=cut

sub getNovelSettings {
    my $cfgHR = {};

    return $cfgHR;
}

=head2 getKeys()

=cut

sub getKeys {
    my @keys = ();

    return @keys;
}

=head2 getKnownKeys

=cut

sub getKnownKeys {
    my @keys = ();

    return @keys;
}

=head2 getRawKeys

=cut

sub getNovelKeys {
    my @keys = ();

    return @keys;
}

sub _dbUserErr {
     my $val = shift;
     my $err;
     if (! defined) {
         $err = "dbUser must be defined.\n";
     }
     elsif ( length($val) < 1 ) {
         $err = "dbUser may not be blank. \n";
     }
     return $err;
}

=head2 _errorIfUndefined

Takes a value as a parameter. Returns an error message if the tested value
is undefined, otherwise returns an empty string.

=cut


sub _errorIfUndefined {
    my $val = shift;
    print "DEBUG Received \"$val\"\n";
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
    my $val = shift;
    my $err = _errorIfUndefined($val);
    if (! $err) {
        $err = _errorIfRef( $val );
    }
    if (! $err) {
        if (length "$val" == 0 ) {
            $err .= "Error: empty string.\n";
        }
    }
    return $err;
}

=head1 AUTHOR

Stuart R. Jefferys, C<< <srjefferys at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-p5-bio-seqware-config at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=p5-Bio-Seqware-Config>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bio::SeqWare::Config


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=p5-Bio-Seqware-Config>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/p5-Bio-Seqware-Config>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/p5-Bio-Seqware-Config>

=item * Search CPAN

L<http://search.cpan.org/dist/p5-Bio-Seqware-Config/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Stuart R. Jefferys.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


=cut

1; # End of Bio::SeqWare::Config
