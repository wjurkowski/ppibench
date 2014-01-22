#!usr/bin/perl -w
use strict;
use warnings;

my @directorys;
my @names;
my @temp_names;
my @new_names;
my $work_directory=$ARGV[0];
my $date;

#program starting time
	chomp($date = `date`);
	print "program for $work_directory started at time $date\n";

#made dir for store
	system "mkdir $work_directory\_bioscorer";
#program started
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

#start to work
		for (my $j=0;$j<scalar(@directorys);$j++){
		chdir "./$directorys[$j]"or die "can not change dir to ./$directorys[$j]  $! "; 
		#get the file names
			open (NAME,"file_name") or die "Can't open :$!";	
			@temp_names=<NAME>;
			close NAME;
			chop @temp_names;
		#rename and join the files
			for(my $i=0;$i<scalar(@temp_names);$i++){
				if($temp_names[$i]=~/(.*?)(\.pdb)(\.\d{1,5})/){
					system "cat pdb$names[$j][0]\.pdb $temp_names[$i] > $1$3$2";
					system "rm $temp_names[$i]";
					$new_names[$i]=$1.$3.$2;
					
				}

			}
		#restore the name file
			system "rm file_name";
			open (NAME,">file_name") or die "Can't open :$!";	
			for(my $i=0;$i<scalar(@new_names);$i++){
				print NAME "$new_names[$i]\n";
			}
			close NAME;
		#do the double_wrapper.pl
			system "cp /afs/pdc.kth.se/home/s/sagit/Public/bioscorer_package/atom_triangle_freq.pl ./";
			system "cp /afs/pdc.kth.se/home/s/sagit/Public/bioscorer_package/triominoes ./";
			system "cp /afs/pdc.kth.se/home/s/sagit/Public/bioscorer_package/divide.pl ./";
			system "cp /afs/pdc.kth.se/home/s/sagit/Public/bioscorer_package/atom_types.dat ./";
			
			system "double_wrapper.pl file_name .log";
			system "join_atf.pl file_name";
			system "bioscorer.pl /afs/pdc.kth.se/home/s/sagit/Public/bioscorer_package/native.2009.atf . p >>$names[$j][0]\-$names[$j][1]\.score";
		#copy results and chdir
		system "cp $names[$j][0]\-$names[$j][1]\.score ../../$work_directory\_bioscorer";
		system "rm *atom *cross atom_p* *chain_0.pdb *chain_1.pdb *.atf";
		chdir "../"or die "can not change dir to ../: $! "; 
		}

#program ending time
	chomp($date = `date`);
	print "program for $work_directory ended at time $date\n";




