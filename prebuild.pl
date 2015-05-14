#!/usr/bin/perl


# System
use strict;
use warnings;
use feature ':5.10';
use FindBin;
use File::Spec;
use Text::Wrap;
$Text::Wrap::columns = 78;
$Text::Wrap::huge = 'wrap';

$| = 1; # autoflush STDOUT

my $wd = $FindBin::Bin;

my $md2html_bin  = File::Spec->catfile( $wd, 'bin', 'md2html.pl' );
my $pod2md_bin 	 = File::Spec->catfile( $wd, 'bin', 'pod2md.pl' );
my $pod2html_bin = File::Spec->catfile( $wd, 'bin', 'pod2html.pl' );

my @commands = (
	$md2html_bin.' '.File::Spec->catfile( $wd, 'README.md' ),

#	$pod2md_bin.' '.File::Spec->catfile( $wd, 'issuu-dl.pl' ),
#	$pod2md_bin.' '.File::Spec->catfile( $wd, 'jpg-to-pdf.pl' ),

	$pod2html_bin.' '.File::Spec->catfile( $wd, 'issuu-dl.pl' ),
	$pod2html_bin.' '.File::Spec->catfile( $wd, 'jpg-to-pdf.pl' ),
);

my $count = 0;
foreach my $cmd ( @commands ) {
	$count++;
	my $prefix = '['.$count.'] ';
	say $prefix.'==============';
	say Text::Wrap::wrap( $prefix.'running: ', $prefix.'  ', $cmd );

	say $prefix.'--------------';
	my $CMD_OUT = undef;
	if ( ! ( open $CMD_OUT, '-|', $cmd.' 2>&1 ' ) ) {
		Carp::croak( $prefix.'failed to run command: '.$! );
	}
	
	while ( my $line = <$CMD_OUT> ) {
		chomp $line;
		say $prefix.$line;
	}
	say $prefix.'==============';

	my $exit_value = $? >> 8;
	if ( $exit_value > 0 ) {
		say $prefix.'ERROR - command failed: '.$exit_value;
	}
}

=head1 NAME 

prebuild.pl

=head1 DESCRIPTION

pre-build documentation before release

=cut


