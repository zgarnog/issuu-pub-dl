
use strict;
use warnings;

package IssuuPubDL;

use version; our $VERSION = qv('1.0.0');



sub path_to_cyg {
	my $path = shift || '';
	$path =~ s{(\w+):\\}{/cygdrive/$1/};
	$path =~ s{\\}{/}g;
	return $path;
}


sub path_to_win {
	my $path = shift || '';
	$path =~ s{/cygdrive/(\w+)/}{$1:\\};
	$path =~ s{/}{\\}g;
	return $path;
}

1;


__END__

=head1 NAME

IssuuPubDL

=head1 DESCRiPTION

methods used by issuu-pub-dl programs

=head1 VERSION

0.1.0

=head1 INTERFACE

=head2 path_to_cyg( $path )

returns: $cyg_path

=head2 path_to_win( $path )

returns: $win_path

=head1 CHANGES

  - 2015-05-28 zgarnog
    - created

=cut

