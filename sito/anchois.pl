#!/usr/bin/perl -w

use strict;
use warnings;
#use lib './Modules';

use StrAnal;

if ($#ARGV != 1) {die "Program used with parameters [model list] [clustering threshold] \n";}

my (@kluski,@uncle);
my @pdbs=open_file($ARGV[0]);
my $thres=$ARGV[1];
my $clustn=0;
open(OUT, ">clusters_members.txt") or die "Can not open an output file: $!";

while($#pdbs >= 0){
	my $pdb1=$pdbs[0];		
	splice @pdbs, 0, 1;
	for(my $j=0;$j<$#pdbs;$j++){
		my $pdb2=$pdbs[$j];
		my $L_rms=get_rms(\$pdb1,\$pdb2);
		#print "$i $j $pdb1 $pdb2 $L_rms $thres\n";
		if($L_rms < $thres){
		#print "$j $pdb2\n";
			push(@kluski,$pdb2);
			splice @pdbs, $j, 1;
			$j=$j-1;
		}
	}
	if($#kluski >= 0){
		$clustn++;
		my $s=$#kluski + 2;
		print "cluster $clustn $pdb1 size: $s\n";
		print OUT "cluster $pdb1\n";
		foreach my $element(@kluski){print OUT "$element\n";}
	}
	else{
		push(@uncle,$pdb1);		
	}
	undef(@kluski);
}
print OUT "unclustered:\n";
foreach my $k(@uncle){print OUT "$k\n";}


# open a file with the file name as input
sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}

