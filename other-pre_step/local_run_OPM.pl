#!usr/bin/perl -w

use strict;
use warnings;

my @directorys;
my $date;
my @names;
##########################
#program starting time   #
##########################
chomp($date = `date`);
print "program for $ARGV[0] started at time $date\n";


#change the working directory
	`mkdir $ARGV[0]\_result`;
	chdir "$ARGV[0]" or die "can not chdir to $ARGV[0]: $!";

#read in the folder names
@directorys=`ls`;
chop @directorys;

for (my $i=0;$i<scalar(@directorys);$i++){
	if($directorys[$i]=~/DP\_(.+?)-(.+)/){
		$names[$i][0]=$1;#Receptor name
		$names[$i][1]=$2;#ligand name
	}

#change to a directory
	chdir "$directorys[$i]" or die "can not chdir to $directorys[$i]: $!";

#get the file names
	open (NAME,"file_name") or die "Can't open :$!";	
	my @predicted_filenames=<NAME>;
	close NAME;
	chop @predicted_filenames;
#do the work
	`cp pdb$names[$i][1]\.pdb pdb$names[$i][1]\.pdb\.out ../../caprice6/`; #the crystal structure  HERE
	`mkdir ../../$ARGV[0]\_result/result\_$directorys[$i]`;
	chdir "../../caprice6/" or die "can not chdir to ../../caprice6: $!";
	foreach $_(@predicted_filenames){
		`cp ../$ARGV[0]/$directorys[$i]/$_ ../$ARGV[0]/$directorys[$i]/$_\.out ./`;
		`perl caprice6.pl brugel  $_\.out pdb$names[$i][1]\.pdb\.out`;
		`mv mqa* ../$ARGV[0]\_result/result\_$directorys[$i]`;
		`rm $_ $_\.out`;
	}
	chdir "../$ARGV[0]" or die "can not chdir to ../: $!";
}

##########################
#program ending time   #
##########################
chomp($date = `date`);
print "program for $ARGV[0] ended at time $date\n";

