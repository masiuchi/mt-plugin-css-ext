#  You may distribute under the terms of either the GNU General Public License
#  or the Artistic License (the same terms as Perl itself)
#
#  (C) Paul Evans, 2009 -- leonerd@leonerd.org.uk

package Convert::Color::HSV;

use strict;
use warnings;
use base qw( Convert::Color::HueBased );

__PACKAGE__->register_color_space( 'hsv' );

use Carp;

our $VERSION = '0.08';

=head1 NAME

C<Convert::Color::HSV> - a color value represented as hue/saturation/value

=head1 SYNOPSIS

Directly:

 use Convert::Color::HSV;

 my $red = Convert::Color::HSV->new( 0, 1, 1 );

 # Can also parse strings
 my $pink = Convert::Color::HSV->new( '0,0.7,1' );

Via L<Convert::Color>:

 use Convert::Color;

 my $cyan = Convert::Color->new( 'hsv:300,1,1' );

=head1 DESCRIPTION

Objects in this class represent a color in HSV space, as a set of three
floating-point values. Hue is stored as a value in degrees, in the range
0 to 360 (exclusive). Saturation and value are in the range 0 to 1.

=cut

=head1 CONSTRUCTOR

=cut

=head2 $color = Convert::Color::HSV->new( $hue, $saturation, $value )

Returns a new object to represent the set of values given. The hue should be
in the range 0 to 360 (exclusive), and saturation and value should be between
0 and 1. Values outside of these ranges will be clamped.

=head2 $color = Convert::Color::HSV->new( $string )

Parses C<$string> for values, and construct a new object similar to the above
three-argument form. The string should be in the form

 hue,saturation,value

containing the three floating-point values in decimal notation.

=cut

sub new
{
   my $class = shift;

   my ( $h, $s, $v );

   if( @_ == 1 ) {
      local $_ = $_[0];
      if( m/^(\d+(?:\.\d+)?),(\d+(?:\.\d+)?),(\d+(?:\.\d+)?)$/ ) {
         ( $h, $s, $v ) = ( $1, $2, $3 );
      }
      else {
         croak "Unrecognised HSV string spec '$_'";
      }
   }
   elsif( @_ == 3 ) {
      ( $h, $s, $v ) = @_;
   }
   else {
      croak "usage: Convert::Color::HSV->new( SPEC ) or ->new( H, S, V )";
   }

   # Clamp
   map { $_ < 0 and $_ = 0; $_ > 1 and $_ = 1 } ( $s, $v );

   # Fit to range [0,360)
   $h += 360 while $h < 0;
   $h -= 360 while $h >= 360;

   return bless [ $h, $s, $v ], $class;
}

=head1 METHODS

=cut

=head2 $h = $color->hue

=head2 $s = $color->saturation

=head2 $v = $color->value

Accessors for the three components of the color.

=cut

# Simple accessors
sub hue        { shift->[0] }
sub saturation { shift->[1] }
sub value      { shift->[2] }

=head2 ( $hue, $saturation, $value ) = $color->hsv

Returns the individual hue, saturation and value components of the color
value.

=cut

sub hsv
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

   my ( $h, $s, $v ) = $self->hsv;

   my $hi = int( $h / 60 );

   my $f = $h / 60 - $hi;

   my $p = $v * ( 1 - $s );
   my $q = $v * ( 1 - $f * $s );
   my $t = $v * ( 1 - ( 1 - $f ) * $s );

   my ( $r, $g, $b );

   if( $hi == 0 ) {
      ( $r, $g, $b ) = ( $v, $t, $p );
   }
   elsif( $hi == 1 ) {
      ( $r, $g, $b ) = ( $q, $v, $p );
   }
   elsif( $hi == 2 ) {
      ( $r, $g, $b ) = ( $p, $v, $t );
   }
   elsif( $hi == 3 ) {
      ( $r, $g, $b ) = ( $p, $q, $v );
   }
   elsif( $hi == 4 ) {
      ( $r, $g, $b ) = ( $t, $p, $v );
   }
   elsif( $hi == 5 ) {
      ( $r, $g, $b ) = ( $v, $p, $q );
   }

   return ( $r, $g, $b );
}

sub new_rgb
{
   my $class = shift;
   my ( $r, $g, $b ) = @_;

   my ( $hue, $min, $max ) = $class->_hue_min_max( $r, $g, $b );

   return $class->new(
      $hue,
      $max == 0 ? 0 : 1 - ( $min / $max ),
      $max
   );
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
