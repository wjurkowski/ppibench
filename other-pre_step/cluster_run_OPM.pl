#!usr/bin/perl -w
use strict;
use warnings;

my @directorys;
my @names;
my @temp_names;
my $work_directory=$ARGV[0];
my $date;

#program starting time
chomp($date = `date`);
print "program for $work_directory started at time $date\n";

#program start


chdir "$work_directory" or die "can not change dir to $work_directory "; 

#read in the file names
@directorys=`ls`;
chop @directorys;

for (my $i=0;$i<scalar(@directorys);$i++){
	if($directorys[$i]=~/DP\_(.+?)-(.+)/){
		$names[$i][0]=$1;#Receptor name
		$names[$i][1]=$2;#ligand name
	}
}

#find the crystal structure

#generate the decoy and the contact maps
for (my $j=0;$j<scalar(@directorys);$j++){

		chdir "./$directorys[$j]"or die "can not change dir to ./$directorys[$j]  $! "; 
		#find the crystal structure and create the crystal structure
		`cp ../../../crystal/trans-alfa/pdb$names[$j][0]\.pdb  ../../../crystal/trans-alfa/pdb$names[$j][1]\.pdb  ./`;
		#clean the hydrogen and connects in the file
		@temp_names=`ls`;
		chop @temp_names;
		foreach my $a(@temp_names){
			if($a=~/^pdb*/){
				`perl ../../clean_Hydr_Connect_End.pl`;
			}
		} 

		#create the decoys
		foreach my $a(@temp_names){
			if($a=~/zdock.*?\.pdb\.out$/){
				`perl ../../create.pl $a`;
			}
		} 
	
	#for the crystal
	`../../contacts-1.1/cmapper pdb$names[$j][0]\.pdb 40 5 pdb$names[$j][1]\.pdb`;
	#for the decoys
	my @decoys=`ls pdb$names[$j][1]_m\.pdb\.*`;
	open (FILENAME,">file_name") or die "Can't open :$!";
	foreach $_(@decoys){
		chop;
		print FILENAME "$_\n";
	}
	close FILENAME;	
	
	foreach my $a(@decoys){
		`../../contacts-1.1/cmapper pdb$names[$j][0]\_m\.pdb 40 5 $a`;
	}
	#for the next directory
	chdir "../"or die "can not change dir to ../  $! "; 
}

#program ending time
chomp($date = `date`);
print "program for $work_directory ended at time $date\n";























