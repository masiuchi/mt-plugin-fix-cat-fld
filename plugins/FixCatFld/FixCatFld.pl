package MT::Plugin::FixCatFld;
use strict;
use warnings;
use base qw( MT::Plugin );

our $NAME = ( split /::/, __PACKAGE__ )[-1];
our $VERSION = '0.01';

my $plugin = __PACKAGE__->new(
    {   name        => $NAME,
        id          => lc $NAME,
        key         => lc $NAME,
        version     => $VERSION,
        author_name => 'masiuchi',
        author_link => 'https://github.com/masiuchi',
        plugin_link => 'https://github.com/masiuchi/mt-plugin-fix-cat-fld',
        description =>
            "<__trans phrase='Fix a bug when using Firefox 16 or later.'>",
        registry => {
            callbacks => {
                'MT::App::CMS::template_source.header' =>
                    \&_tmpl_src_insert_replace,
                'MT::App::CMS::template_source.preview_strip' =>
                    \&_tmpl_src_insert_replace,
                'MT::App::CMS::template_source.preview_template_strip' =>
                    \&_tmpl_src_insert_replace,
            },
        },
    }
);
MT->add_plugin($plugin);

my $mtml
    = '<script type="text/javascript" src="<$mt:var name="static_uri"$>plugins/FixCatFld/js/common/List.js?v=<mt:var name="mt_version_id" escape="url">"></script>';

sub _tmpl_src_insert_replace {
    my ( $cb, $app, $tmpl_ref ) = @_;
    _insert_mt_core_compact($tmpl_ref);
    _replace_list($tmpl_ref);
}

sub _insert_mt_core_compact {
    my ($tmpl_ref) = @_;

    my $pre
        = quotemeta(
        '<script type="text/javascript" src="<$mt:var name="static_uri"$>js/mt_core_compact.js?v=<mt:var name="mt_version_id" escape="url">"></script>'
        );

    $$tmpl_ref =~ s!($pre)!$1\n$mtml!;
}

sub _replace_list {
    my ($tmpl_ref) = @_;

    my $before
        = quotemeta(
        '<script type="text/javascript" src="<$mt:var name="static_uri"$>js/common/List.js?v=<mt:var name="mt_version_id" escape="url">"></script>'
        );

    $$tmpl_ref =~ s!$before!$mtml!;
}

1;
