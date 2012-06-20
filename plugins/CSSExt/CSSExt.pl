package MT::Plugin::CSSExt;
use strict;
use warnings;
use base 'MT::Plugin';

our $NAME = ( split /::/, __PACKAGE__ )[-1];
our $VERSION = '0.01';

my $plugin = __PACKAGE__->new(
    {   name        => $NAME,
        id          => lc $NAME,
        key         => lc $NAME,
        version     => $VERSION,
        author_link => 'https://github.com/masiuchi',
        plugin_link => 'https://github.com/masiuchi/mt-plugin-change-css-ext',
        description =>
            'Translate less/sass/scss to css automatically when rebuilding css template.',
        settings => MT::PluginSettings->new(
            [ [ 'css_mode', { Default => 1, Scope => 'system' } ], ]
        ),
        system_config_template => 'system_config.tmpl',
    }
);
MT->add_plugin($plugin);

sub init_registry {
    my ($p) = @_;
    my $pkg = '$' . $NAME . '::' . $NAME;
    $p->registry(
        { callbacks => { build_page => $pkg . '::Callbacks::build_page', }, }
    );
}

1;
__END__
