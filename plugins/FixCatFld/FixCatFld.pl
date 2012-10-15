package MT::Plugin::FixCatFld;
use strict;
use warnings;
use base qw( MT::Plugin );

our $NAME = ( split /::/, __PACKAGE__ )[-1];
our $VERSION = '0.03';

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
    }
);
MT->add_plugin($plugin);

sub init_registry {
    my ($p) = @_;
    $p->registry(
        {   callbacks => {
                'MT::App::CMS::template_source.header' =>
                    \&_tmpl_src_insert_replace,
                'MT::App::CMS::template_source.preview_strip' =>
                    \&_tmpl_src_insert_replace,
                'MT::App::CMS::template_source.preview_template_strip' =>
                    \&_tmpl_src_insert_replace,
            },
        }
    );
}

sub _tmpl_src_insert_replace {
    my ( $cb, $app, $tmpl_ref ) = @_;
    _create_modified_js($app)
        or return;
    _insert_mt_core_compact($tmpl_ref);
    _replace_list($tmpl_ref);
}

my $mtml
    = '<script type="text/javascript" src="<$mt:var name="static_uri"$>support/fix_cat_fld/List.js?v=<mt:var name="mt_version_id" escape="url">"></script>';

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

my ( $fmgr, $support_directory_path, $dir_path, $file_path, $orig_path );

sub _create_modified_js {
    my ($app) = @_;

    require MT::FileMgr;
    $fmgr ||= MT::FileMgr->new('Local');
    return unless $fmgr;

    require File::Spec;
    $support_directory_path ||=
        $MT::VERSION < 5
        ? File::Spec->catdir( $app->static_file_path, 'support' )
        : $app->support_directory_path;
    $dir_path
        ||= File::Spec->catdir( $support_directory_path, 'fix_cat_fld' );
    $file_path ||= File::Spec->catfile( $dir_path, 'List.js' );
    $orig_path
        ||= File::Spec->catdir( $app->static_file_path, qw( js common ),
        'List.js' );

    if ( $fmgr->exists($file_path) ) {
        return 1;
    }

    unless ( $fmgr->exists($dir_path) ) {
        $fmgr->mkpath($dir_path)
            or return;
    }

    my $data = $fmgr->get_data($orig_path)
        or return;

    $data =~ s!\.itemId!\.itmId!g;

    $fmgr->put_data( $data, $file_path )
        or return;

    1;
}

1;
