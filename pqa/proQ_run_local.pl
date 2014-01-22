#!usr/bin/perl -w

use strict;
use warnings;
my $date;
my @predicted_filenames;
my @file1;
my @file2;
my @directorys;
my @names;
my @result;


#program starting time
	chomp($date = `date`);
	print "program for $ARGV[0] started at time $date\n";


	`mkdir $ARGV[0]\_ProQ`;
#to the working directory
	chdir "$ARGV[0]"or die "can not change dir to $ARGV[0]:$!";
#read in the file names
	@directorys=`ls`;
	chop @directorys;

for (my $i=0;$i<scalar(@directorys);$i++){
	if($directorys[$i]=~/DP\_(.+?)-(.+)/){
		$names[$i][0]=$1;#Receptor name
		$names[$i][1]=$2;#ligand name
	}
}

#foreach single run of the pairs
for (my $j=0;$j<scalar(@directorys);$j++){
		chdir"$directorys[$j]"or die "can not change to $directorys[$j] : $!";
		#get the file names
			open (NAME,"file_name") or die "Can't open :$!";	
			@predicted_filenames=<NAME>;
			close NAME;
			chop @predicted_filenames;
		#get the two file together

			#file2
			open (ONE,"pdb$names[$j][0]\_m.pdb") or die "Can't open :$!";
			@file1=<ONE>;
			close ONE;
			
		for(my $i=0;$i<scalar(@predicted_filenames);$i++){
			#file1
			print "$predicted_filenames[$i]\n";
			open (TWO,"$predicted_filenames[$i]") or die "Can't open :$!";
			@file2=<TWO>;
			close TWO;

			#output
			open (COM,">../../$ARGV[0]\_ProQ/$names[$j][0]\-$predicted_filenames[$i]") or die "Can't open :$!";
			print COM @file1;
			print COM @file2;
			
			#ProQ work 
			chdir"../../$ARGV[0]\_ProQ/"or die "can not change to $ARGV[0]\_ProQ : $!";
			$result[$i]=`ProQ -model $names[$j][0]\-$predicted_filenames[$i] -ss ../alpha-seq-fasta_pairs/$names[$j][0]-$names[$j][1].fasta.horiz -output short`;
			`rm $names[$j][0]\-$predicted_filenames[$i]`;
			chdir"../$ARGV[0]/$directorys[$j]";
		}
		#work for others
			open (RESULT,">../../$ARGV[0]\_ProQ/$names[$j][0]-$names[$j][1]") or die "Can't open :$!";
				for(my $i=0;$i<scalar(@predicted_filenames);$i++){
					print RESULT "$predicted_filenames[$i]	$result[$i]\n";
				}
			close RESULT;
			chdir"../"or die "can not change to ../ : $!";
}

#program ending time
	chomp($date = `date`);
	print "program for $ARGV[0] ended at time $date\n";

