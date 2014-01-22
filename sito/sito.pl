#!/usr/bin/perl -w
#program filters contacts within a complex
#complex filename receptor-ligand.pdb
use strict;
use warnings;

use BaseFunct;
use PoseClust;
use ContactScoring;

if ($#ARGV < 0 ) {die "Unspecified run mode [cmap|score|cluster|stat]\n";}
elsif (($ARGV[0] eq "score" ) and ($#ARGV != 3)) {die "Program used with parameters [score] [contacts] [conserv rec] [conserv lig] \n";}
elsif (($ARGV[0] eq "cmap" ) and ($#ARGV != 3)) {die "Program used with parameters [cmap] [contacts] [prot name 1] [prot name 2] \n";}
elsif (($ARGV[0] eq "cluster" ) and ($#ARGV != 1)) {die "Program used with parameters [cluster] [lig pdb] \n";}
elsif (($ARGV[0] eq "stat" ) and ($#ARGV != 1)) {die "Program used with parameters [stat] [list] \n";}

#interface scoring
if($ARGV[0] eq "score"){
	my $name=substr($ARGV[1],0,rindex($ARGV[1],"."));	
	my $results="caprice_scores.txt";

	open(GOUT, ">> $results") or die "Can not open an input file: $!";
	# Open the 3 input files
	my @contact_data = open_file($ARGV[1]);
	my @T_consurf_data = open_file($ARGV[2]);
	my @R_conseq_data = open_file($ARGV[3]);
	my @T_whiscy_data = open_file($ARGV[4]);
	my @R_whiscy_data = open_file($ARGV[5]);

	# Read the contact map
	my %contact_list_1 = read_contact_map_resid(\@contact_data);
	# Read the Target consurf score 
	my %T_consurf_score = read_consurf_score(\@T_consurf_data);
	# Read the Receptor conseq score (sequence based)
	my %R_conseq_score = read_conseq_score(\@R_conseq_data,1);
	# Read the Target whiscy score 
	my %T_whiscy_score = read_whiscy_score(\@T_whiscy_data);
	# Read the Receptor whiscy score 
	my %R_whiscy_score = read_whiscy_score(\@R_whiscy_data);

	#Compute and print conservation interface score
	my @score = conserv_interf_score(\%contact_list_1,\%R_conseq_score,\%T_consurf_score);
	print GOUT "$name\t$score[0]\t$score[1]\n";
}

#clustering
elsif($ARGV[0] eq "cluster"){	
	my $ligpdblist=$ARGV[1]; 
	#extract cloud of points representing aall poses on the list
	my ($cloud) = get_cloud(\$ligpdblist);
	my $cloud_file=$$cloud;
  	my ($calf) = parse_pdb(\$cloud_file);
  	my @calfas = $$calf;
  	my $ofile = $ligpdblist."dist";
  	#calculate distances
  	dist_feed(\@calfas,\$ofile);	
}


elsif($ARGV[0] eq "stat"){
	my $contact_map_list = $ARGV[1];
	#Reads the contact map and calculates interaction statistics
	interaction_map(\$contact_map_list);
}

elsif($ARGV[0] eq "cmap"){
	#my $results=$ARGV[1]."-contact_resid.txt";
	my $results="interface_residues.txt";
	open(GOUT, ">> $results") or die "Can not open an input file: $!";

	my $protn1=$ARGV[2];
	my $protn2=$ARGV[3];
	my @contact_data = open_file($ARGV[1]);
	#Reads the contact map and calculates interaction statistics
	my ($csum1,$csum2) = get_interaction_site(\@contact_data,\$protn1,\$protn2);
	
	foreach my $ele(@{$csum1}){	
		print GOUT "$ele,";
	}
	print GOUT "\n";
	foreach my $ele(@{$csum2}){	
		print GOUT "$ele,";
	}
	print GOUT "\n";
}

else {die "wrong switch\n";}

