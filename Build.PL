use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Bio::SeqWare::Config',
    license             => 'gpl',
    dist_author         => q{Stuart R. Jefferys <srjefferys@gmail.com>},
    dist_version_from   => 'lib/Bio/SeqWare/Config.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'perl' => 5.006,
    },
    add_to_cleanup      => [ 'p5-Bio-Seqware-Config-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
