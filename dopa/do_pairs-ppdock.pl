#!/usr/bin/perl
#take list and prepare nonredundant set of pairs for all-vs-all docking
use strict;
if ($#ARGV != 0) {die "Program requires command line parameters\
	[list1] \n";}

open(LISTA1, $ARGV[0]) if $ARGV[0];
my $fpairs=$ARGV[0]."-pairs";
open(PARY,"> $fpairs") or die "Can not write an output file: $!";

my @list = <LISTA1>;
chomp @list;
my $wiel= $#list;
my ($i,$k,$nazwa1,$nazwa2);

for ($i = 0; $i <= $wiel; $i++) {
	$nazwa1=$list[$i];
	for ($k = $i+1; $k <= $wiel; $k++){
		$nazwa2=$list[$k];
		my $tpara=$nazwa1."	".$nazwa2;
		print PARY "$tpara\n";		
	}
}

