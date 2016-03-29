#!/usr/bin/perl -wT
#****************************************************************************************
use strict;
use warnings;
use CGI qw{ :standard };
use CGI::Carp qw ( fatalsToBrowser );

my $query = new CGI;
my $sessid = $query->param("sessid");
	$sessid =~  m/^([a-zA-Z0-9\._]+)$/ or die "Tainted $sessid";
my $pingfile = "$1.log";
MAIN:
{
print "Content-type: text/html\n\n";
my $Plantilla = "$sessid:0:12";
if (-r "$pingfile")
	{
	open (PLANTILLA, "$pingfile") or die "$pingfile not readable";
		my @Plantilla = <PLANTILLA>;
	close (PLANTILLA);
	print $Plantilla[0];
	}
else
	{
	print $Plantilla;
	}
exit 0;
}
