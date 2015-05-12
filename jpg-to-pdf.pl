#!/usr/bin/perl


$| = 1; # autoflush STDOUT


# system
use strict;
use warnings;
use feature ':5.10';
use Cwd;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use File::Spec;


my $convert_program = 'convert';
my $convert_opts = ' -density 300';
#my $convert_opts = ' -density 600 '; # optional



my ( $wd ) = @ARGV;
$wd ||= '';
my $output_file;
GetOptions(
	'output=s'	=> \$output_file,
);

$wd ||= '';
chomp $wd;

if ( ! $wd ) {
	my $dl_dir = File::Spec->catpath( '', $FindBin::Bin, 'downloads' );
	my $glob_str = File::Spec->catpath( '', ''.$dl_dir.'', '*' );
	my @found_dirs = glob( $glob_str );
	if ( ! @found_dirs ) {
		say 'no dirs found to select from';
		say '(glob string: '.$glob_str.')';
		die( 'no dir to work on; exiting' );
	}
	say 'Enter the number of a directory to combine ';
	say 'into a single PDF file: ';

	my %dir_by_count = ();
	my $count = 0;
	my $bin_length = length $FindBin::Bin;
	foreach my $dir ( @found_dirs ) {
		if ( -d $dir ) {
			my @jpg_files = glob( File::Spec->catpath( '', $dir, '*.jpg' ) );
			if ( @jpg_files ) {
				$count++;
				$dir_by_count{ $count } = $dir;
				my $show_dir = substr $dir, $bin_length + 1;
				say ' '.$count.' ) '.$show_dir;
			}
		}
	}
	print '> ';
	my $selected_count = <STDIN> || '';
	chomp $selected_count;
	$selected_count =~ s/^\s+//;;
	$selected_count =~ s/\s+$//;;

	$wd = $dir_by_count{ $selected_count } || '';
	if ( ! $wd ) {
		say 'ERROR - no dir with number '.$selected_count;
	}
	chomp $wd;
}


if ( ! $wd ) {
	say 'ERROR - missing directory to work on';
	Pod::Usage::pod2usage( ' ' ); # prints SYNOPSIS and exits
}
if ( ! -d $wd ) {
	say 'ERROR - directory not found: '.$wd;
	Pod::Usage::pod2usage( ' ' ); # prints SYNOPSIS and exits
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


# remove any quotes
$wd =~ s/^"//;
$wd =~ s/"$//;


my $start_time = time();

my $cmd = join( ' ', (
	$convert_program,
	$convert_opts,
	File::Spec->catpath( '', '"'.$wd.'"', '*.jpg' ),
	'"'.$output_file.'"',
) );

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
	if ( ! -f $output_file ) {
		say 'command OK but PDF not found: '.$output_file;
	} else {
		say 'created pdf "'.$output_file.'" in '.( time() - $start_time ).' seconds';
	}
}



__END__

=head1 NAME

jpg-to-pdf.pl

=head1 SYNOPSIS

  This program will read all *.jpg files from the
  given directory and create a single pdf file, 
  by using ImageMagick.

  jpg-to-pdf.pl # prompts for directory

  jpg-to-pdf.pl [directory]

  jpg-to-pdf.pl [directory] --output=[filename.pdf]

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


