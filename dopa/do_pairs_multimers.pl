#!/usr/bin/perl
use strict;
if ($#ARGV != 1) {die "Program requires command line parameters\
	[list1] [list2]\n";}
#two list of pdb names (pdbid_chainid)
#creates list of chains with the same pdbid
#list is unique with the same to chains paired only once

open(LISTA1, $ARGV[0]) if $ARGV[0];
open(LISTA2, $ARGV[1]) if $ARGV[1];
my $fpairs=$ARGV[0]."-".$ARGV[1];
open(PARY,"> $fpairs") or die "Can not write an output file: $!";

my @list1 = <LISTA1>;
my @list2 = <LISTA2>;
chomp @list1;
chomp @list2;

my ($nazwa1,$nazwa2,$para,@pairs,@pdbpairs,%is_blue);

foreach $nazwa1(@list1){
	foreach $nazwa2(@list2){
		my $pdb1=substr($nazwa1,0,4);
		my $pdb2=substr($nazwa2,0,4);	
		my $kod1=substr($nazwa1,0,6);
		my $kod2=substr($nazwa2,0,6);
		if($pdb1 eq $pdb2){
			my $tpara1=$kod1."\t".$kod2;
			my $tpara2=$kod2."\t".$kod1;
			undef %is_blue;
	    		for (@pairs){$is_blue{$_} = 1;}
				unless ($is_blue{$tpara2}){
				$para=$tpara1;#codes only
				my $fpara=$nazwa1."\t".$nazwa2;
				if($nazwa1 ne $nazwa2){
					push(@pairs,$para);
					push(@pdbpairs,$fpara);	
				}
			}
		}		 
	}
}

foreach $para(@pdbpairs){
print PARY "$para\n";
}
