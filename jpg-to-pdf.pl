#!/usr/bin/perl
BEGIN {
	use FindBin;
}


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
use YAML;

# lib/
use lib $FindBin::Bin.'/lib/';
use IssuuPubDL 1.0.0;



#my $convert_opts = ' -density 600 '; # optional

my $config_file = File::Spec->catfile( $FindBin::Bin, 'config.yaml' );

my %config = ();
if ( ! -e $config_file ) {
	die( 'config file not found; please run issuu-dl.pl to create one' );
} 

my $ref = YAML::LoadFile( $config_file ) or die( 'failed to load YAML config file: '.$config_file );
%config = %$ref;


my $lc_os = lc( $^O );

my $os = 'linux_maybe';
if ( $lc_os =~ /mswin/ ) {
	$os = 'windows';
} elsif ( $lc_os =~ /cygwin/ ) {
	$os = 'cygwin';
}




my $output_file;
my $density;
my $convert_limit_memory;
my $convert_limit_map;
my $debug;
GetOptions(
	'output=s'	=> \$output_file,
	'density=i'	=> \$density,
	'convert-limit-memory=s'	=> \$convert_limit_memory,
	'convert-limit-map=s'		=> \$convert_limit_map,
	'debug'	=> \$debug,
) or die( 'invalid options' );

my ( $wd ) = @ARGV;
$wd ||= '';

if ( $debug ) {
	say 'os '.$os.' ( lc_os: '.$lc_os.' )';
}



# BEGIN - verify config


my %pl_config = ();
if ( defined $config{jpg_to_pdf} ) {
	if ( ref $config{jpg_to_pdf} ne 'HASH' ) {
		die( 'config{jpg_to_pdf} should be undef or an HASH ref' );
	}
	%pl_config = %{ $config{jpg_to_pdf} };

	if ( $pl_config{convert_limit_memory} !~ /^\d+\w*$/ ) {
		die( 'config{jpg_to_pdf}{convert_limit_memory} invalid format' );
	}
	if ( $pl_config{convert_limit_map} !~ /^\d+\w*$/ ) {
		die( 'config{jpg_to_pdf}{convert_limit_map} invalid format' );
	}
}

if ( ! $convert_limit_memory and defined $pl_config{convert_limit_memory} ) {
	$convert_limit_memory = $pl_config{convert_limit_memory};
}
if ( ! $convert_limit_map and defined $pl_config{convert_limit_map} ) {
	$convert_limit_map = $pl_config{convert_limit_map};
}

	
# END - verify config






my $convert_program = 'convert.exe';
my $convert_opts = ' ';
if ( $density ) {
	$convert_opts .= ' -density '.$density.' ';
}
if ( $convert_limit_memory ) {
	$convert_opts .= ' -limit memory '.$convert_limit_memory.' ';
}
if ( $convert_limit_map ) {
	$convert_opts .= ' -limit map '.$convert_limit_map.' ';
}

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

	if ( ! %dir_by_count ) {
		die( 'ERROR - no dirs with .jpg files found under '.$dl_dir ); 
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

my $search_dir = $wd;
if ( $search_dir =~ /\s/ ) {
	$search_dir = '"'.$search_dir.'"';
}

my $jpg_files_glob = File::Spec->catpath( '', $search_dir, '*.jpg' );
my @files = glob( $jpg_files_glob );
say 'found ['.scalar( @files ).'] jpg files';
if ( ! @files ) {
	die( 'no .jpg files found under '.$search_dir );
}
if ( $debug ) {
	say '  '.$_ for @files;
}
if ( $os eq 'cygwin' ) {
	# will be running windows convert.exe, so need windows paths
#	$jpg_files_glob = IssuuPubDL::path_to_win( $jpg_files_glob );
	foreach my $i ( 0 .. scalar @files - 1 ) {
		$files[ $i ] = IssuuPubDL::path_to_win( $files[ $i ] );
	}
	$output_file 	= IssuuPubDL::path_to_win( $output_file );
}

my $cmd_start = join( ' ', (
	$convert_program,
	$convert_opts,
) );

my $cmd_end = '"'.$output_file.'"';

my $cmd = join( ' ', (
	$cmd_start,
	'"'.join( '" "', @files ).'"',
	$cmd_end,
) );

my $cmd_descr = join( ' ', (
	$cmd_start,
	IssuuPubDL::path_to_win( $jpg_files_glob ),
	$cmd_end,
) );

say 'running cmd like: '.$cmd_descr;
if ( $debug ) {
	say 'actual cmd'.$cmd;
}
my @output = qx( $cmd );
my $exit_val = $? >> 8;
if ( $exit_val ) {
	my $msg = 'command falied with exit value ['.$exit_val.']';
	say 'ERROR - '.$msg;
	say 'output:';
	chomp @output;
	say 'OUT - '.$_ for @output;
	die( $msg.' (path may be too long)' );
} else {
	if ( ! -f $output_file ) {
		say 'command OK but PDF not found: '.$output_file;
	} else {
		my $bytes = -s $output_file;
		my $mb = sprintf( '%0.2f', $bytes / ( 1024 * 1024 ) );
		say 'created pdf "'.$output_file.'" ('.$mb.' Mb) in '.( time() - $start_time ).' seconds';
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

  jpg-to-pdf.pl [directory] [options]

  options:
    --output=[filename.pdf]
    --density=[integer]
    --convert-limit-memory=[string]
    --convert-limit-map=[string]
    --debug    print debug output

=head1 AUTHOR

zgarnog <zgarnog@yandex.com>

=head1 DEPENDENCIES

  Perl v5.14.2

  ImageMagick 6.7.6-3 

=head1 CHANGES

  - 2015-04-20
     - created

  - 2015-04-28 zgarnog
    - added config file
      - has options to limit memory used 
        by ImageMagick convert.exe (ram and swap)
    - fix for paths to convert.exe under cygwin

=cut


# vim: ts=4


