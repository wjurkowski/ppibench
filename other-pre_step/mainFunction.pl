#!usr/bin/perl -w
use strict;
use warnings;

my @directorys;
my @names;
my @temp_names;

chdir "../decoy/alfa-trans-done-pairs/" or die "can not change dir to ../decoy/alfa-trans-done-pairs/ "; 

#read in the file names
@directorys=`ls`;
chop @directorys;

for (my $i=0;$i<scalar(@directorys);$i++){
	if($directorys[$i]=~/DP\_(.+?)-(.+)/){
		$names[$i][0]=$1;#Receptor name
		$names[$i][1]=$2;#ligand name
	}
}

#print "$names[1][0]	$names[1][1]\n";

#find the crystal structure

#generate the decoy and the contact maps
for (my $j=0;$j<scalar(@directorys);$j++){
	if($names[$j][0] eq $names[$j][1]){next;}
	if($names[$j][0] ne $names[$j][1]){
		chdir "./$directorys[$j]"or die "can not change dir to ./$directorys[$j]  $! "; 
		#find the crystal structure and create the crystal structure
		`cp ../../../crystal/trans-alfa/pdb$names[$j][0]\.pdb  ../../../crystal/trans-alfa/pdb$names[$j][1]\.pdb  ./`;
		#clean the hydrogen and connects in the file
		foreach my $a(@temp_names){
			if($a=~/^pdb*/){
				`perl ../../../function/clean_Hydr_Connect_End.pl`;
			}
		} 
		@temp_names=`ls`;
		chop @temp_names;
		#create the decoys
		foreach my $a(@temp_names){
			if($a=~/zdock.*?\.pdb\.out$/){
				`create.pl $a`;
			}
		} 
	}
	

	`cmapper pdb$names[$j][0]\.pdb 40 5 pdb$names[$j][1]\.pdb`;
	
	#`cmapper pdb$names[$j][1]\_m\.pdb 40 5 pdb$names[$j][0]\_m\.pdb`;
	#join the crystal stucture as one single file
	####################################################################	
	#open (CRYS,"pdb$names[$j][0]\.pdb") or die "Can't open :$!";
	#my @crystal_1=<CRYS>;
	#close CRYS;
	#open (CRYST,"pdb$names[$j][1]\.pdb") or die "Can't open :$!";
	#my @crystal_2=<CRYST>;
	#close CRYST;
	#open (OUT,">pdb$names[$j][1]\.pdb")or die "Can't open :$!";
	#		select OUT;
	#		foreach my $b(@crystal_1){
	#			print $b;
	#		}
	#		print "\n";
	#		foreach my $a(@crystal_2){
	#			print $a;
	#		}
	#close OUT;
	######################################################################## PLEASE Do not delete it

	#calculate the cmapper for the decoys and do the caprice
	my @decoys=`ls pdb$names[$j][1]_m\.pdb\.*`;
	chop @decoys;
	#select STDOUT;
	#print "$decoys[1]\n";
	#die;
	foreach my $a(@decoys){
		`cmapper pdb$names[$j][0]\_m\.pdb 40 5 $a`;
		#join the two part of decoys together
		#open (DECO,"pdb$names[$j][0]\_m\.pdb") or die "Can't open :$!";
		#my @decoy_1=<DECO>;
		#close DECO;
		#open (DECOY,"$a") or die "Can't open :$!";
		#my @decoy_2=<DECOY>;
		#close DECOY;
		#open (OUTT,">$a")or die "Can't open :$!";
		#	select OUTT;
		#	foreach my $b(@decoy_1){
		#		print $b;
		#	}
		#	print "\n";
		#	foreach my $a(@decoy_2){
		#		print $a;
		#	}
		#close OUTT;
		############################################################################ PLEASE DO NOT DELETE IT	
	
		`caprice6.pl brugel  $a\.out pdb$names[$j][1]\.pdb.out`;
		`rm -r $a\.out`;
	}
	#remove files and results
	#open (OUT,">pdb$names[$j][1]\.pdb")or die "Can't open :$!";
	#	select OUT;
	#	foreach my $b(@crystal_2){
	#			print $b;
	#		}
	#close OUT;
	################################################################################## PLEASE DO NOT DELETE IT
	`mkdir ../../Result/Result\_$names[$j][0]_$names[$j][1]`;
	`mv mqa* ../../Result/Result\_$names[$j][0]_$names[$j][1]`;
	`rm -r pdb$names[$j][1]_m\.pdb\.* pdb$names[$j][1]\.pdb pdb$names[$j][0]\.pdb`;
	chdir "../"or die "can not change dir to ../  $! "; 
}

























