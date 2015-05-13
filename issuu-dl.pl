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


use version; our $VERSION = qv('1.3.0');



$| = 1; # autoflush STDOUT

say '';
say '----------------------------';
say 'Issuu Publication Downloader (issuu-dl.pl v'.$VERSION.')';
say '----------------------------';
say '';
 


my $debug;
my $url;
my $document_id;
my $sleep;
my $in_start_page;
my $urls_list_file;
my $help;
GetOptions( 
	'debug'		=> \$debug,
	'url=s'		=> \$url,
	'list=s'  	=> \$urls_list_file,
	'id=s'		=> \$document_id,
	'sleep=i' 	=> \$sleep,
	'start=i' 	=> \$in_start_page,
	'help'		=> \$help,
) or die( 'ERROR - invalid options received' );


if ( $help ) {
	Pod::Usage::pod2usage( ' ' ); # prints SYNOPSIS and exits
}

my $wget_bin = './wget.exe'; # windows wget
my $wget_is_win = 1;

my $dl_dir = File::Spec->catpath( '', $FindBin::Bin, 'downloads' );


my $lc_os = lc( $^O );


my $os = 'linux_maybe';
if ( $lc_os =~ /mswin/ ) {
	$os = 'windows';
} elsif ( $lc_os =~ /cygwin/ ) {
	$os = 'cygwin';
}

if ( $debug ) {
	say 'os '.$os.' ( lc_os: '.$lc_os.' )';
}

if ( $os ne 'windows' ) {
	# look for linux/cygwin wget
	my @output = qx( which wget 2>&1 );
	my $exit_value = $? >> 8;
	if ( $exit_value == 0 and @output and $output[0] ) {
		chomp @output;
		$wget_bin = $output[0];
		$wget_is_win = 0;
		if ( $debug ) {
			say 'found '.$os.' wget: '.$wget_bin;
		}
	} elsif ( $os ne 'cygwin' ) {
		die( 'ERROR - failed to find wget in path' );
	}
} elsif ( $debug ) {
	say 'using '.$os.' wget: '.$wget_bin;
}



if ( ! $sleep ) {
	$sleep = 0;
}





if ( ! $sleep ) {
	say 'Enter seconds to sleep after each page (0)';
	print '> ';
	$sleep = <STDIN>;
	chomp $sleep;
	$sleep =~ s/^\s+//;
	$sleep =~ s/\s+$//;

	if ( ! $sleep ) {
		$sleep = 0;
	} elsif ( $sleep !~ /^\d+$/ ) {
		die( 'ERROR - sleep should be an integer (digits only), got: '.$sleep );
	}
}	

if ( $urls_list_file ) {

	if ( $debug ) {
		say 'DEBUG - list file: '.$urls_list_file;
	}

	my @urls_list = File::Slurp::read_file( $urls_list_file ); # croaks on failure

	if ( ! @urls_list ) {
		die( 'WARN - urls file "'.$urls_list_file.'" is empty; nothing to do' );
	}

	chomp @urls_list;
	say 'Loaded file with '.scalar( @urls_list ).' lines';
	my $count = 0;
	URL: foreach my $url ( @urls_list ) {
		$count++;

		# trim whitespace
		$url =~ s/^\s+//;
		$url =~ s/\s+$//;

		my $prefix = '['.$count.'] ';
		if ( ! $url ) {
			say $prefix.'WARN - skipping blank URL line';
			next URL;
		}

		if ( $url !~ m{https?://} ) {
			say $prefix.'WARN - URL may be invalid: '.$url.' ';
		}

		eval {
			my ( $title, $document_id, $total_pages ) = _get_doc_data_by_url( $url );

			_get_document( $title, $document_id, $total_pages, { auto => 1 }, );
		};
		my $e = $@;
		if ( $e ) {
			chomp $e;
			say $prefix.'ERROR - failed to process url: '.$url;
			say $prefix.'ERROR - '.$e;
		}
	}


} else {

	if ( $debug ) {
		say 'DEBUG - no list file';
	}

	if ( ! $url and ! @ARGV ) {
		say 'Enter issuu document URL (blank to skip): ';
		print '> ';
		$url = <STDIN> || '';
		chomp $url;
		if ( $url ) {
			$url =~ s/^\s+//; # trim leading whitespace
			$url =~ s/\s+$//; # trim trailing whitespace
		} else {
			say 'No URL received.';
		}
	}


	my ( $title, $document_id, $total_pages );

	if ( $url ) {
		( $title, $document_id, $total_pages ) = _get_doc_data_by_url( $url );
	}

	if ( ! $title || ! $document_id || ! $total_pages ) {
		( $title, $total_pages, $document_id ) = @ARGV;
	}

	_get_document( $title, $document_id, $total_pages );

}


######## SUBROUTINES


sub _get_doc_data_by_url {
	my $url = shift;
	
	my ( $title, $document_id, $total_pages );
	
	if ( $debug ) {
		say 'URL: '.( $url || 'undef' );
	}
	if ( $url ) {
		if ( $url !~ m{https?://} ) {
			say 'WARN - URL may be invalid';
		}
	
		my $temp_file = 'temp-'.time().'.html';
	
		my $cmd = $wget_bin.' -nv -q --output-document="'.$temp_file.'" '.
				' "'.$url.'" ';
	
		if ( $wget_is_win and $os eq 'cygwin' ) {
			$cmd = $wget_bin.' -nv -q --output-document="'._path_cyg_to_win( $temp_file ).'" '.
				' "'.$url.'" ';
		}
	
		my @output = qx( $cmd );
		my $exit_value = $? >> 8;
		if ( $exit_value > 0 ) {
			say 'ERROR - command failed: [ '.$cmd.' ] :'.$!;
			say '==== output: ====';
			say 'OUT - '.$_ for @output;
			say '=================';
			Carp::croak( 'command failed' );
		}
	
		my $content = File::Slurp::read_file( $temp_file ); # croaks on failure
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
	
	return ( $title, $document_id, $total_pages );
}




sub _get_document {
	my $title = shift;
	my $document_id = shift;
	my $total_pages = shift;
	my $o_ref = shift;


	if ( $debug ) {
		say 'DEBUG - _get_document( "'.$title.'", "'.$document_id.'", '.$total_pages.' );';
	}

	
	my %o = ();
	if ( ref $o_ref eq 'HASH' ) {
		%o = %$o_ref;
	}


	if ( ! $title || ! $document_id || ! $total_pages ) {
		say '';
		die( 'ERROR - Missing one of : title, document_id, total_pgaes' );
	}
	if ( $total_pages !~ /^\d+$/ ) {
		say '';
		die( 'ERROR - total_pages should be an integer' );
	}



	my $dest = File::Spec->catpath( '', $dl_dir, $title );
	$dest =~ s{\.pdf$}{}i;
	
	
	my $start_page = $in_start_page;
	if ( ! $start_page ) {
		$start_page = 1;
	}
	
	my $descr = '"'.$title.'" ('.$total_pages.' pages)';
	if ( -d $dest ) {
		my @page_files = glob( File::Spec->catfile( $dest, '*.jpg' ) );
		my $highest_number = undef;
		if ( @page_files ) {
			PAGE_FILE: foreach my $page_file ( reverse sort @page_files ) {
				if ( -f $page_file ) {
					if ( -s $page_file > 0 ) {
						my ( $number ) = $page_file =~ m{([1-9]\d*)\.jpg$};
						if ( $number ) {
							if ( ! defined $highest_number ) {
								$highest_number = $number;
							}
							$start_page = $number + 1;
							last PAGE_FILE;
						} elsif ( $debug ) {
							say 'DEBUG - no number found in: '.$page_file;
						}
					} elsif ( $debug ) {
						say 'DEBUG - zero size file: '.$page_file;
					}
				}
			}
		} elsif ( $debug ) {
			say 'found no page files under: '.$dest;
		}
		say '';
		if ( defined $highest_number && $highest_number >= $total_pages ) {
			say 'WARN - directory exists with all pages; aborting download/pdf';
			say 'WARN - "'.$dest.'"';
			return;
		}
		if ( $start_page > 1 ) {
			say 'WARN - directory exists; will resume at page '.$start_page.' under';
			say 'WARN - "'.$dest.'"';
		} else {
			say 'WARN - directory exists; could overwrite files under';
			say 'WARN - "'.$dest.'"';
		}
		if ( ! $o{auto} ) {
			print 'Press any key to continue > ';
			<STDIN>;
		}
	}


	if ( $start_page >= $total_pages ) {
		if ( $debug ) {
			say 'DEBUG - start page '.$start_page.' >= '.$total_pages.' (total)';
		}
		say 'no pages left to download; not downloading or creating pdf';
		say '  for '.$dest;
		return 0;
	}


	if ( ! -e $dest ) {
		File::Path::mkpath( $dest );
	}



	say '';
	say 'Downloading '.$descr;
	say '  - starting on page '.$start_page;
	if ( $sleep > 0 ) {
		say '  - sleeping '.$sleep.' seconds after each page';
	}
	say 'Please wait...';
	say '';
	
	
	my $start_time = time();
	PAGE: foreach my $cur_page ( $start_page .. $total_pages ) {
	
		my $page_padded = sprintf( '%0.3d', $cur_page );
	
	
		my $short_img_file = 'file_'.$page_padded.'.jpg';
		my $img_file = File::Spec->catpath( '', $dest, $short_img_file );
	
		my $size = ( -s $img_file ) || 0;
		if ( $size > 0 ) {
			say 'SKIP: file exists > 0 b: '.$short_img_file.' '.$size.' b';
			next PAGE;
		}
		
		my $cmd = $wget_bin.' -nv -q --output-document="'.$img_file.'" '.
			' "http://image.issuu.com/'.$document_id.'/jpg/page_'.$cur_page.'.jpg"';
	
		if ( $wget_is_win and $os eq 'cygwin' ) {
			$cmd = $wget_bin.' -nv -q --output-document="'._path_cyg_to_win( $img_file ).'" '.
				' "http://image.issuu.com/'.$document_id.'/jpg/page_'.$cur_page.'.jpg"';
		}
	
	
		my @output = qx( $cmd );
		my $exit_value = $? >> 8;
		if ( $exit_value > 0 ) {
			say 'ERROR - command failed: [ '.$cmd.' ]: '.$!;
			say '==== output: ====';
			say 'OUT - '.$_ for @output;
			say '=================';
			Carp::croak( 'command failed' );
	
			Carp::croak( 'command failed' );
		}
		
		if ( $cur_page % 10 == 0 ) {
			say 'downloaded '.$page_padded.' / '.$total_pages.' pages (elapsed '.( time() - $start_time ).' seconds)';
		}
		if ( $sleep > 0 ) {
			sleep( $sleep );
		}
	}
		
	say '';
	say 'Done; downloaded '.$total_pages.' pages (elapsed '.( time() - $start_time ).' seconds)';
	say '';
	
	
	my $cmd = 'perl '.$FindBin::Bin.'/jpg-to-pdf.pl "'.$dest.'"';
	
	my $CMD_OUT = undef;
	if ( ! ( open $CMD_OUT, '-|', $cmd.' 2>&1 ' ) ) {
		say 'INFO - command: '.$cmd;
		Carp::croak( 'failed to run command: '.$! );
	}
	
	while ( my $line = <$CMD_OUT> ) {
		chomp $line;
		say '('.$$.') '.$line;
	}
	
}

sub _path_cyg_to_win {
	my $path = shift || '';
	$path =~ s{/cygdrive/(\w+)/}{$1:\\};
	$path =~ s{/}{\\}g;
	return $path;
}


1;

__END__

=head1 NAME

issuu-dl.pl

=head1 VERSION

1.3.0

=head1 SYNOPSIS

  by prompts: (prompts for URL or other options)
    issuu-dl.pl

  by URL:
    issuu-dl.pl --url=[string] [options]

  by document id:
    issuu-dl.pl [title] [total_pages] [document_id] [options]

  example: 
    issuu-dl.pl "The Document Title" aaabbccccaoeuaeou-23434242 201

  The title will be used to create a directory under ./downloads
    example:
      "./downloads/The Document Title"

  options:
    --debug            print extra debug output
    --sleep=[integer]  (default: 0) sleep for seconds after downloading 
                       each page, to decrease the load on the network

=head1 CHANGES

Issuu Publication Downloader v1.0
  by eqagunn

 2015-04-20 zgarnog
   - now uses leading zeros on numbers less than 100

 2015-05-11 zgarnog
   - converted to perl script
   - can now pass URL and will get details needed from 
     URL automatically

 2015-05-12 zgarnog
   - now calls other perl script to convert jpg to pdf,
   - now asks for URL interactively if not received
     via option.

=cut



# vim: set paste ts=4
