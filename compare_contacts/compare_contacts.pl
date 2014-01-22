#!/usr/bin/perl -w
#parametry programu:[reference file] [predictions list]
#Program compares predicted and reference residues.
#each line contains tab separated columns: 
#	1 - target PDB ID 
#	2 - tab separated expected bs residues  
#use strict;
#use warnings;

if ($#ARGV != 1) {die "Program runs with parameters!\
	[reference file] [contact map list]\n";}

open(INPUT1, "< $ARGV[0]") or die "Can not open input file: $!";
open(INPUT2, "< $ARGV[1]") or die "Can not open input file: $!";

my @cmlist=<INPUT2>;
my @reflist=<INPUT1>;
close (INPUT1);
close (INPUT2);
chomp @cmlist;
chomp @reflist;

my (@refcm,@predcm,@refname,@predname);

	my $pn=0;
foreach my $line (@reflist) { #reads expected bs residues
	$pn++; #counts protein number
	my $i=0;
	while ($line =~/(\s+\d+)/g) {
		$i++;
		my $nowy=$1;
		$nowy=~ s/\s+//g;	
		$refcm[$pn][$i]=$nowy;	#reference (expected) residue numbers
 	}
	@tab=split(/\t/,$line);
	$refname[$pn]=$tab[0];	#pdb id and chain id 	
}

	$pn=0;
foreach my $line (@cmlist) { #reads predicted bs residues
	$pn++; #counts protein number
	my $i=0;
	while ($line =~/(\s+\d+)/g) {
		$i++;
		my $nowy=$1;
		$nowy=~ s/\s+//g;	
		$predcm[$pn][$i]=$nowy;	#predicted residue numbers
 	}
	@tab=split(/\t/,$line);
	$predname[$pn]=$tab[0];	#pdb id and chain id 	
}


#compares reference (expected) bs residues with predictions
open(OUTPUT, ">scored-$ARGV[1]") or die "Can not open output file: $!";	
for my $k (1..$#refcm){	#iterate reference targets list
 for my $m (1..$#predcm){ #iterate predicted targets list
  $tname = substr($predname[$m],index($predname[$m],"-")+1);
#print "$tname rrrr\n";
  if($tname eq $refname[$k]){ #if predicted is found on the list of reference targets	
 	my (@unique_hits,%refres,%predres);
	my $hit=0;
	my $chit=0;
RESZTA: for my $l(1..$#{$refcm[$k]}){ #iterate reference residues
		my $klucz=$refcm[$k][$l];#makes a hash of expected residues
		if(exists $refres{$klucz}) {$refres{$klucz}++;}
		else {$refres{$klucz}=1;}
		for my $n(1..$#{$predcm[$m]}){	#iterate predicted residues
		  my $klucz=$predcm[$m][$n];#makes hash of predicted residues
		  if(exists $predres{$klucz}) {$predres{$klucz}++;}
		  else {$predres{$klucz}=1;}
		  if($refcm[$k][$l]==$predcm[$m][$n]){
	  		$chit++;	#count all hits		
	  	  }	
		}

	 	for my $n(1..$#{$predcm[$m]}){	#counts if for given solution is at least one match of reference residue
	  		if($refcm[$k][$l]==$predcm[$m][$n]){
				$hit++;	#count of unique predicted bs residues
				push(@unique_hits,$predcm[$m][$n]);
				next RESZTA;
	  		} 
	 	}
  	}
	my $pgb = keys %predres; #all unique (good and bad) predictions 
	my $rgb = keys %refres; #all unique (good and bad) reference residues
	my $TP=$hit;	#number of correctly matched unique residues
	my $FP=$pgb-$hit;	#remaining predicted (nmatched)	
	my $FN=$rgb-$hit;	#number of not predicted (number of expected - number predicted)
	@unique_hits=sort {$a <=> $b} @unique_hits;
	printf OUTPUT "$refname[$k]\t$predname[$m]\t$TP\t$FP\t$FN\t";
	foreach my $res(@unique_hits){
		printf OUTPUT "$res,";
	}
	printf OUTPUT "\n";
  }
 }
}
close (OUTPUT);


