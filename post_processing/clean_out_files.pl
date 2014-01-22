#!usr/bin/perl -w
use strict;
use warnings;

my @directorys;
my @names;
my @temp;
#read in the file names
	@directorys=`ls -d place*`;
	chop @directorys;

	for (my $j=0;$j<scalar(@directorys);$j++){
		chdir "./$directorys[$j]"or die "can not change dir to ./$directorys[$j]  $! ";
		`rm -r alpha-seq-fasta_pairs nohup.out`;
		@temp=`ls -d run*`;	
		chop @temp;
		#each run
		chdir "$temp[0]" or die;
		@names=`ls`;
		chop @names;
		for (my $i=0;$i<scalar(@names);$i++){
			chdir "$names[$i]"or die "can not change dir to $names[$i]  $! ";
			`rm *out`;
			chdir "../";
		}
		chdir "../";
		chdir "../";
	}
