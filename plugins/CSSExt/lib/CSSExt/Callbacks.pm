package CSSExt::Callbacks;
use strict;
use warnings;

use CSS::LESSp;
use Text::Sass;

my $name = ( split /::/, __PACKAGE__ )[0];
my $plugin = MT->component($name);

my $oSass;

sub build_page {
    my ( $cb, %opts ) = @_;

    my $tmpl = $opts{template};
    if ( $tmpl && $tmpl->can('identifier') ) {

        if ( $tmpl->identifier eq 'styles' ) {

            my $html = $opts{content};
            if ( $$html && $$html !~ m/import[\t ]+url\(/ ) {

                my $css_mode
                    = $plugin->get_config_value( 'css_mode', 'system' );

                if ( $css_mode == 1 ) {
                    my @css = CSS::LESSp->parse($$html);
                    $$html = join '', @css;

                }
                elsif ( $css_mode == 2 ) {
                    $oSass ||= Text::Sass->new();
                    $$html = $oSass->sass2css($$html);

                }
                elsif ( $css_mode == 3 ) {
                    $oSass ||= Text::Sass->new();
                    $$html = $oSass->scss2css($$html);

                }
            }
        }
    }
}

1;
__END__
