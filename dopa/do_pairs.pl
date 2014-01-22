#!/usr/bin/perl
use strict;
if ($#ARGV != 1) {die "Program requires command line parameters\
	[list1] [list2]\n";}

open(LISTA1, $ARGV[0]) if $ARGV[0];
open(LISTA2, $ARGV[1]) if $ARGV[1];
my $fpairs=$ARGV[0]."-".$ARGV[1];
open(PARY,"> $fpairs") or die "Can not write an output file: $!";

my @list1 = <LISTA1>;
my @list2 = <LISTA2>;
chomp @list1;
chomp @list2;

my ($nazwa1,$nazwa2);

foreach $nazwa1(@list1){
	foreach $nazwa2(@list2){
		my $tpara=$nazwa1."\t".$nazwa2;
		print PARY "$tpara\n";
	}
}


