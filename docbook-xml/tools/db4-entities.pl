#!/usr/bin/perl -- # -*- Perl -*-

# This script attempts to replace external parsed entities with
# XInclude elements.

use strict;
use English;

my $usage = "$0 input.xml\n";

my $file = shift @ARGV || die $usage;
die $usage unless -f $file;

my %epe = ();

open (F, $file);
read (F, $_, -s $file);
close (F);

if (/^<\?xml\s.*?\?>\s*/) {
    print $MATCH;
    $_ = $POSTMATCH;
}

my $body = "";

if (/^<!DOCTYPE\s[^\[\>]+\[/s) {
    print $MATCH;
    $_ = $POSTMATCH;
    if (/^(.*?)\]/s) {
	print $MATCH;
	$body = $POSTMATCH;
	$_ = $1;

	while (/^\s*(<.*?>)/s) {
	    my $decl = $1;
	    $_ = $POSTMATCH;

	    if ($decl =~ /<!ENTITY\s+(\S+)\s+PUBLIC\s+([\"\']).*?\2\s+([\"\'])(.*?)\3/s) {
		$epe{$1} = $4;
	    } elsif ($decl =~ /<!ENTITY\s+(\S+)\s+SYSTEM\s+([\"\'])(.*?)\2/s) {
		$epe{$1} = $3;
	    }
	}
    } else {
	print $_;
	exit 0;
    }
}

while ($body =~ /^(.*?)&(\S+?);/s) {
    print $1;

    if (exists $epe{$2}) {
	print "<xi:include xmlns:xi='http://www.w3.org/2001/XInclude' href='";
	print $epe{$2};
	print "'/>";
    } else {
	print "&$2;";
    }

    $body = $POSTMATCH;
}

print $body;
