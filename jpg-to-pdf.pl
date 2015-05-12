#!/usr/bin/perl


$| = 1; # autoflush STDOUT


# system
use strict;
use warnings;
use feature ':5.10';
use Cwd;
use Getopt::Long;
use Pod::Usage;
use File::Spec;


my $wd;
my $output_file;
GetOptions(
	'dir=s'	=> \$wd,
	'output=s'	=> \$output_file,
);

$wd ||= '';
chomp $wd;

my $wd_from_option = 1;
if ( ! $wd ) {
	$wd_from_option = 0;
	$wd = Cwd::getcwd();
}

if ( $output_file ) {
	if ( $output_file !~ /\.pdf/i ) {
		say 'ERROR - output file must have .pdf extension';
		Pod::Usage::pod2usage( ' ' ); # prints SYNOPSIS and exits
	}
} else {
	$output_file = $wd;
	$output_file =~ s{/$}{};
	$output_file =~ s{\\$}{};
	$output_file .= '.pdf';
}

my $convert_program = 'convert';

# remove any quotes
$wd =~ s/^"//;
$wd =~ s/"$//;

my $glob_string = File::Spec->catpath( '', '"'.$wd.'"', '*.jpg' );
my @files = glob( $glob_string );
if ( ! @files ) {
	say 'ERROR - No *.jpg files found: '.$glob_string;
	Pod::Usage::pod2usage( ' ' ); # prints SYNOPSIS and exits
}

my $cmd = $convert_program.' '.$glob_string.' "'.$output_file.'"';
say 'running: '.$cmd;
my @output = qx( $cmd );
my $exit_val = $? >> 8;
if ( $exit_val ) {
	say 'ERROR - command falied with exit value ['.$exit_val.']';
	say 'output:';
	chomp @output;
	say 'OUT - '.$_ for @output;
	die( 'command failed' );
} else {
	say 'created pdf: ['.$output_file.']';
}


__END__

=head1 NAME

jpg-to-pdf.pl

=head1 SYNOPSIS

  jpg-to-pdf.pl --dir=[directory]

  jpg-to-pdf.pl --dir=[directory] --output=[filename.pdf]

=head1 AUTHOR

zgarnog <zgarnog@yandex.com>

=head1 DEPENDENCIES

  Perl v5.14.2

  ImageMagick 6.7.6-3 

=head1 CHANGES

  - 2015-04-20
     - created

=cut


# vim: ts=4


