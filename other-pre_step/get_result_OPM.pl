#!usr/bin/perl -w
use strict;
use warnings;


my @directorys;

chdir "$ARGV[0]" or die "can not chdir to $ARGV[0]: $!";

#read in the folder names
@directorys=`ls`;
chop @directorys;

for (my $i=0;$i<scalar(@directorys);$i++){  
	chdir "$directorys[$i]"or die "can change dir to $directorys[$i] ";
	my @result_filenames=`ls`;
		foreach $_(@result_filenames){
			chop;
		}

	open (OUT,">final_$directorys[$i]") or die "Can't open :$!";
	foreach $_(@result_filenames){
				open (TEMP,"$_") or die "Can't open :$!";
				my @result_protein=<TEMP>;
				close TEMP;
				if($result_protein[0]){
				print OUT "$result_protein[0]";
					}
	}

	`mv final_$directorys[$i] ../`;
	chdir "../"or die "can change dir to ../ ";
}
