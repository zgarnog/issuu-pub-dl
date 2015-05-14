#!/usr/bin/perl


# System
use strict;
use warnings;
use feature ':5.10';
use File::Slurp;
use Pod::HTTML;

$| = 1; # autoflush STDOUT

my $prog = $0;
$prog =~ s{.*/}{};
$prog =~ s{.*\\}{};
say '';
say '== '.$prog.' ==';
say '';

my ( $pod_file ) = @ARGV;

if ( ! $pod_file ) {
	say 'USAGE: '.$prog.' [perl_file]';
	say '';
	die( 'nothing to do' );
}

my $md_file = $pod_file;

$md_file =~ s/\.[^\.]+$//;
$md_file .= '.md';

if ( -e $md_file ) {
	say 'WARN - md file exists: '.$md_file;
	print 'press ENTER to continue, CTRL-C to abort > ';
	<STDIN>;
	say '';
}

# IN PROGRESS

 pod2html("pod2html",
                    "--podpath=lib:ext:pod:vms",
                    "--podroot=/usr/src/perl",
                    "--htmlroot=/perl/nmanual",
                    "--libpods=perlfunc:perlguts:perlvar:perlrun:perlop",
                    "--recurse",
                    "--infile=foo.pod",
                    "--outfile=/perl/nmanual/foo.html");



my $pod_content = File::Slurp::read_file( $pod_file );

if ( ! $pod_content ) {
	die( 'ERROR - no content loaded from '.$pod_file ); 
}

say 'OK - read content from pod file: '.$pod_file;


my $pod_md = Pod::Markdown->new;

my $md_string = '';
$pod_md->output_string(\$md_string);

$pod_md->parse_string_document( $pod_content );

if ( ! $md_string ) {
	die( 'ERROR - no markdown parsed from pod_content' );
}


File::Slurp::write_file( $md_file, { buf_ref => \$md_string } );

say 'OK - wrote md to file: '.$md_file;

