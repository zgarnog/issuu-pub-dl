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
use Pod::HTML;

$| = 1; # autoflush STDOUT

my $prog = $0;
$prog =~ s{.*/}{};
$prog =~ s{.*\\}{};
say '';
say '== '.$prog.' ==';
say '';

my ( $in_file ) = @ARGV;

if ( ! $in_file ) {
	say 'USAGE: '.$prog.' [perl_file]';
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


my $cmd = join( ' ', ( 
	"pod2html",
#	"--podpath=lib:ext:pod:vms",
#	"--podroot=/usr/src/perl",
#	"--htmlroot=/perl/nmanual",
#	"--libpods=perlfunc:perlguts:perlvar:perlrun:perlop",
#	"--recurse",
	"--infile=".$in_file,
	"--outfile=".$out_file,
) );

print qx( $cmd );
my $exit_val = $? >> 8;
if ( $exit_val == 0 ) {
	say 'OK - wrote to file: '.$out_file;
} else {
	say 'ERROR - failed to write to file: '.$out_file;
}


