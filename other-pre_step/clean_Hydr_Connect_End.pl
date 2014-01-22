#!usr/bin/perl -w

use strict;
use warnings;

#read the names of the files

my @filenames=`ls`;
foreach $_(@filenames){
	chop;
}

#get rid of the contacts
foreach my $name(@filenames){
	open(STRUCT,$name) or die "Can't open '$name' : $!";
	my @file = <STRUCT>; 
	close STRUCT;
	foreach my $line(@file){
					#ATOM   2653  H   ALA B 177      18.755  -8.862  41.615  1.00  0.00           H  
		if($line =~/^ATOM\s{1,6}\d{1,5}  H/){
			$line="";
		}
		if($line =~/^CON/){
			$line="";
		}
		if($line =~/^END/){
			$line="";
		}
	}
	
	open(RESULT,">$name") or die "Can't create '$name' : $!";
	select RESULT;
	foreach $_(@file){
		print;
	}
	close RESULT;
}






#print "$filenames[0]	$filenames[1]\n";
