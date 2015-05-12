#!/usr/bin/perl

=head1 NAME

page-to-pdf.pl

=head2 AUTHOR

zgarnog <zgarnog@yandex.com>

=head2 DEPENDENCIES

requires Image Magick

=head2 CHANGES

  - 2015-04-20
     - created

=cut




use strict;
use warnings;
use feature ':5.10';

use Cwd;

my $wd = Cwd::getcwd();

my $convert_program = 'convert';

my $glob_string = $wd.'/*.jpg';
my @jpg_files = glob( $glob_string );

my $prog_name = $0;
$prog_name =~ s{.*\/}{};
say '';
say '['.$prog_name.']';
say '';
say 'This program will convert '.scalar( @jpg_files ).' jpg files to pdf';
say 'from: ['.$glob_string.']';
say 'using ImageMagick '.$convert_program;
say '';
print 'press CTRL-C to abort or Enter to continue > ';
<STDIN>;

my $count = 0;
foreach my $jpg_file ( @jpg_files ) {
	chomp $jpg_file;
	$count++;
	my $prefix = '['.$count.'] ';
	my $pdf_file = $jpg_file;
	if ( $pdf_file =~ s/\.jpg$/.pdf/i ) {
		my $cmd = $convert_program.' "'.$jpg_file.'" "'.$pdf_file.'"';
		my @output = qx( $cmd );
		my $exit_val = $? >> 8;
		if ( $exit_val ) {
			say $prefix.'ERROR - command falied with exit value ['.$exit_val.']';
			say $prefix.'output:';
			chomp @output;
			say $prefix.'OUT - '.$_ for @output;
			print $prefix.'press CTRL-C to abort or Enter to continue > ';
			<STDIN>;
		} else {
			say $prefix.'created pdf: ['.$pdf_file.']';
		}
	} else {
		say $prefix.'ERROR - failed to replace suffix on file ['.$jpg_file.']';
		print $prefix.'press CTRL-C to abort or Enter to continue > ';
		<STDIN>;
	}
}


# vim: ts=4


