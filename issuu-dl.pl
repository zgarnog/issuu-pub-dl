#!/usr/bin/perl
BEGIN {
	use FindBin;
}


# System
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
$Data::Dumper::Purity = 1;
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;
use File::Path;
use File::Spec;
use File::Slurp;
use Pod::Usage;
use Getopt::Long;
use Text::Wrap;


# lib/
use lib $FindBin::Bin.'/lib/';
use JSON;



my $debug;
my $url;
my $document_id;
GetOptions( 
	'debug'	=> \$debug,
	'url=s'	=> \$url,
	'id=s'	=> \$document_id,
);



my $wget = './wget.exe';

my $title = '';
my $total_pages = '';

if ( $debug ) {
	say 'URL: '.( $url || 'undef' );
}
if ( $url ) {
	if ( $url !~ m{https?://} ) {
		say 'WARN - URL may be invalid';
	}

	my $temp_file = 'temp-'.time().'.html';

	my $cmd = $wget.' -nv -q --output-document="'.$temp_file.'" '.
		' "'.$url.'" ';

	my @output = qx( $cmd );
	my $exit_value = $? >> 8;
	if ( $exit_value > 0 ) {
		say 'ERROR - command failed: |'.$cmd.'| :'.$!;
		say 'OUT - '.$_ for @output;
		Carp::croak( 'command failed' );
	}

	my $content = File::Slurp::read_file( $temp_file );
	unlink $temp_file;
	
	
	if ( $debug ) {
		say 'got content ('.length( $content ).' chars) from URL';
	}

	my ( $extra, $json ) = split /window.issuuDataCache\s+=\s+/s, $content;

	if ( $json ) {
		( $json, $extra )  = split m{</script>}s, $json;
	} elsif ( $debug ) {
		say '1st split returned no $json';
	}

	if ( $json ) {
		my $ref;
		eval {
			$ref = JSON::from_json( $json );
		};
		my $e = $@;
		if ( $e ) {
			chomp $e;
			Carp::croak( 'Failed to decode issuuDataCache JSON: '.$e );
		}


		if ( ref $ref->{apiCache} eq 'HASH' ) {
			my %cache = %{ $ref->{apiCache} };
			KEY: foreach my $k ( sort keys %cache ) {
				if ( ref $cache{ $k } eq 'HASH' ) {
					if ( ref $cache{ $k }{document} eq 'HASH' ) {
						my %document = %{ $cache{ $k }{document} };
						if ( $debug ) {
							say 'found document under $ref->{apiCache}{'.$k.'}{document}';
							say '===========';
							print Data::Dumper::Dumper( \%document );
							say '===========';
						}
						$title 		 = $document{orgDocName} || '';
						$document_id = $document{documentId} || '';
						$total_pages = $document{pageCount} || '';
						last KEY;
					}
				}
			}
		}

		if ( $debug ) {
			say 'loaded title: '.( $title || 'undef' );
			say 'loaded document_id: '.( $document_id || 'undef' );
			say 'loaded total_pages: '.( $total_pages || 'undef' );
		}

		
	} elsif ( $debug ) {
		say '2nd split returned no $json';
	}

}

if ( ! $title || ! $document_id || ! $total_pages ) {
	( $title, $total_pages, $document_id ) = @ARGV;
}


if ( ! $title || ! $document_id || ! $total_pages ) {
	Pod::Usage::pod2usage( ' ' ); # prints SYNOPSIS and exits
}
if ( $total_pages !~ /^\d+$/ ) {
	say '';
	say 'ERROR - total_pages should be an integer';
	Pod::Usage::pod2usage( ' ' ); # prints SYNOPSIS and exits
}





my $dest = File::Spec->catpath( '', 'downloads', $title );

my $descr = '"'.$title.'" ('.$total_pages.' pages)';
say '';
say 'Will Download '.$descr.'.';
say '';
say "WARNING - will overwrite files under \"$dest\'";
print 'Press any key to continue > ';
<STDIN>;


if ( ! -e $dest ) {
	File::Path::mkpath( $dest );
}



say '';
say 'Downloading '.$descr.'. Please wait...';


foreach my $cur_page ( 1 .. $total_pages ) {

	my $page_padded = sprintf( '%0.3d', $cur_page );

	if ( $cur_page % 10 == 0 ) {
	  say 'on page '.$page_padded.' / '.$total_pages;
	}

	my $img_file = File::Spec->catpath( '', $dest, 'file_'.$page_padded.'.jpg' );
	
	my $cmd = $wget.' -nv -q --output-document="'.$img_file.'" '.
		' "http://image.issuu.com/'.$document_id.'/jpg/page_'.$cur_page.'.jpg"';

	my @output = qx( $cmd );
	my $exit_value = $? >> 8;
	if ( $exit_value > 0 ) {
		say 'ERROR - command failed: |'.$cmd.'|: '.$!;
		say 'OUT - '.$_ for @output;
		Carp::croak( 'command failed' );
	}
	
}

	
say '';
say 'Done; downloaded '.$total_pages.' pages';

say '';
say 'Press any key to exit...';
<STDIN>;


1;

__END__

=head1 SYNOPSIS

  by URL:
    issuudl-mod2.pl --url=[string] [options]

  by document id:
    issuudl-mod2.pl [title] [total_pages] [document_id] [options]

  example: 
    issuudl-mod2.pl "The Document Title" aaabbccccaoeuaeou-23434242 201

  The title will be used to create a directory under ./downloads
    example:
      "./downloads/The Document Title"

  options:
    --debug print extra debug output

=head1 CHANGES

Issuu Publication Downloader v1.0
  by eqagunn

== mod2 == ( by zgarnog <zgarnog@yandex.com> )

 2015-04-20
   - now uses leading zeros on numbers less than 100

 2015-05-11
   - converted to perl script
   - can now pass URL and will get details needed from 
     URL automatically

=cut



# vim: set paste ts=4
