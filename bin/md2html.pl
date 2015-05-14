#!/usr/bin/perl
BEGIN { 
	use FindBin;
	use File::Spec;
	use lib File::Spec->catfile( 
		$FindBin::Bin,
		File::Spec->updir(),
		'lib'
		);
}


# System
use strict;
use warnings;
use feature ':5.10';
use File::Slurp;
use Text::Markdown;

$| = 1; # autoflush STDOUT

my $prog = $0;
$prog =~ s{.*/}{};
$prog =~ s{.*\\}{};
say '';
say '== '.$prog.' ==';
say '';

my ( $in_file ) = @ARGV;

if ( ! $in_file ) {
	say 'USAGE: '.$prog.' [md_file]';
	say '';
	die( 'nothing to do' );
}

my $out_file = $in_file;

$out_file =~ s/\.[^\.]+$//;
$out_file .= '.html';

if ( -e $out_file ) {
	say 'WARN - out file exists: '.$out_file;
	print 'press ENTER to continue, CTRL-C to abort > ';
	<STDIN>;
	say '';
}

my $in_content = File::Slurp::read_file( $in_file );

if ( ! $in_content ) {
	die( 'ERROR - no content loaded from '.$in_file ); 
}

say 'OK - read content from pod file: '.$in_file;

my $md = Text::Markdown->new;
my $out_content = $md->markdown($in_content);

if ( ! $out_content ) {
	die( 'ERROR - failed to parse input' );
}


File::Slurp::write_file( $out_file, { buf_ref => \$out_content } );

say 'OK - wrote to file: '.$out_file;

# vim: ts=4;paste;syntax on

