#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2009 -- leonerd@leonerd.org.uk

package Convert::Color::HSL;

use strict;
use warnings;
use base qw( Convert::Color::HueBased );

__PACKAGE__->register_color_space( 'hsl' );

use Carp;

our $VERSION = '0.08';

=head1 NAME

C<Convert::Color::HSL> - a color value represented as hue/saturation/lightness

=head1 SYNOPSIS

Directly:

 use Convert::Color::HSL;

 my $red = Convert::Color::HSL->new( 0, 1, 0.5 );

 # Can also parse strings
 my $pink = Convert::Color::HSL->new( '0,1,0.8' );

Via L<Convert::Color>:

 use Convert::Color;

 my $cyan = Convert::Color->new( 'hsl:300,1,0.5' );

=head1 DESCRIPTION

Objects in this class represent a color in HSL space, as a set of three
floating-point values. Hue is stored as a value in degrees, in the range
0 to 360 (exclusive). Saturation and lightness are in the range 0 to 1.

=cut

=head1 CONSTRUCTOR

=cut

=head2 $color = Convert::Color::HSL->new( $hue, $saturation, $lightness )

Returns a new object to represent the set of values given. The hue should be
in the range 0 to 360 (exclusive), and saturation and lightness should be
between 0 and 1. Values outside of these ranges will be clamped.

=head2 $color = Convert::Color::HSL->new( $string )

Parses C<$string> for values, and construct a new object similar to the above
three-argument form. The string should be in the form

 hue,saturation,lightnes

containing the three floating-point values in decimal notation.

=cut

sub new
{
   my $class = shift;

   my ( $h, $s, $l );

   if( @_ == 1 ) {
      local $_ = $_[0];
      if( m/^(\d+(?:\.\d+)?),(\d+(?:\.\d+)?),(\d+(?:\.\d+)?)$/ ) {
         ( $h, $s, $l ) = ( $1, $2, $3 );
      }
      else {
         croak "Unrecognised HSL string spec '$_'";
      }
   }
   elsif( @_ == 3 ) {
      ( $h, $s, $l ) = @_;
   }
   else {
      croak "usage: Convert::Color::HSL->new( SPEC ) or ->new( H, S, L )";
   }

   # Clamp
   map { $_ < 0 and $_ = 0; $_ > 1 and $_ = 1 } ( $s, $l );

   # Fit to range [0,360)
   $h += 360 while $h < 0;
   $h -= 360 while $h >= 360;

   return bless [ $h, $s, $l ], $class;
}

=head1 METHODS

=cut

=head2 $h = $color->hue

=head2 $s = $color->saturation

=head2 $v = $color->lightness

Accessors for the three components of the color.

=cut

# Simple accessors
sub hue        { shift->[0] }
sub saturation { shift->[1] }
sub lightness  { shift->[2] }

=head2 ( $hue, $saturation, $lightness ) = $color->hsl

Returns the individual hue, saturation and lightness components of the color
value.

=cut

sub hsl
{
   my $self = shift;
   return @$self;
}

# Conversions
sub rgb
{
   my $self = shift;

   # See also
   #  http://en.wikipedia.org/wiki/HSV_color_space

   my ( $h, $s, $l ) = $self->hsl;

   my $q = $l < 0.5 ? $l * ( 1 + $s )
                    : $l + $s - ( $l * $s );

   my $p = 2 * $l - $q;

   # Modify the algorithm slightly, so we scale this up by 6
   my $hk = $h / 60;

   my $tr = $hk + 2;
   my $tg = $hk;
   my $tb = $hk - 2;

   map {
      $_ += 6 while $_ < 0;
      $_ -= 6 while $_ > 6;
   } ( $tr, $tg, $tb );

   return map {
      $_ < 1 ? $p + ( ( $q - $p ) * $_ ) :
      $_ < 3 ? $q :
      $_ < 4 ? $p + ( ( $q - $p ) * ( 4 - $_ ) ) :
                 $p
   } ( $tr, $tg, $tb );
}

sub new_rgb
{
   my $class = shift;
   my ( $r, $g, $b ) = @_;

   my ( $hue, $min, $max ) = $class->_hue_min_max( $r, $g, $b );

   my $l = ( $max + $min ) / 2;

   my $s = $min == $max ? 0 :
           $l <= 1/2    ? ( $max - $min ) / ( 2 * $l ) :
                          ( $max - $min ) / ( 2 - 2 * $l );

   return $class->new( $hue, $s, $l );
}

=head1 SEE ALSO

=over 4

=item *

L<Convert::Color> - color space conversions

=item *

L<Convert::Color::RGB> - a color value represented as red/green/blue

=back

=head1 AUTHOR

Paul Evans <leonerd@leonerd.org.uk>

=cut

0x55AA;
