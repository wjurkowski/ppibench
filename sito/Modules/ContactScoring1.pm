package ContactScoring;

# Calculate the conservation score of the interface between two proteins.
#
# Inputs files :	C_map output files (contact list)
#					Conservation Score of the two proteins

require Exporter;
use vars qw(@ISA @EXPORT $VERSION);
our @ISA = qw(Exporter);
our @EXPORT = qw(read_contact_map_resid interaction_map read_contact_map read_consurf_score read_conseq_score conserv_interf_score);
$VERSION=1.0;
use strict;
use warnings;

use BaseFunct;

# Read the Contact_map file
# and return an hash of contacts
sub read_contact_map_resid {
	my ($data)=@_;
	my %contact_list = ();
	
	foreach my $line(@{$data}){
		$line=~s/\(//g;
		$line=~s/\)//g;
		# Split the line, for Receptor and Target residue
		my @contact = split (":", $line);
		my @L_residue = split (",", $contact[0]);
		my @R_residue_list = split (";", $contact[1]);
		
		# Add the contact in %contact_list
		foreach my $i(@R_residue_list){
			my @R_residue = split (",", $i);
			
			# Check if the Receptor residue exist. It's adding the contact if it doesn't.
			unless (exists $contact_list{$L_residue[0]}) { 
				push ( @{$contact_list{$L_residue[0]}}, $R_residue[0]); 
			}
			# Otherwise it's checking if the receptor residue exist, and add it if it doesn't
			else {
				unless ( grep( /^$R_residue[0]$/ , @{$contact_list{$L_residue[0]}} )) { 
					push ( @{$contact_list{$L_residue[0]}} , $R_residue[0]);
				}
			}
		}
	}
	return %contact_list;
}

sub interaction_map{
my ($lista)=@_;
my ($L_attype, $R_attype, %R_stat, %L_stat, %R_AAstat, %L_AAstat);
my $statf = "contacts_stat.out";
open (ISTAT, ">$statf") or die "Can not open an output file: $!";
my @files = open_file ($$lista);
print ISTAT "Hydrophobic\tPolar ss\tPolar bb-ss\tPolar bb\tH-bonds\n";
foreach my $file(@files){
	my @data = open_file ($file);
	my $L_HB='';
	my $R_HB='';
	my $ssPolar=0;
	my $bbPolar=0;
	my $bbssPolar=0;
	my $HBond=0;
	my $Hydrophobic=0;
	foreach my $line(@data){
                $line=~s/\(//g;
                $line=~s/\)//g;
                # Split the line, for Receptor and Target residue
                my @contact = split (":", $line);
                my @L_residue = split (",", $contact[0]);
                my @R_residue_list = split (";", $contact[1]);
		#parse atom types
		my $L_resid=$L_residue[1].$L_residue[0];	
		if($L_residue[3]=~/C/){$L_attype="C";}
		if($L_residue[3]=~/O./){
			$L_attype="O";
			if(($L_residue[1] eq "SER") or ($L_residue[1] eq "THR") or ($L_residue[1] eq "TYR")){$L_HB = "Oda";}
			elsif(($L_residue[1] eq "GLU") or ($L_residue[1] eq "ASP")){$L_HB = "Oda";}
			elsif(($L_residue[1] eq "GLN") or ($L_residue[1] eq "ASN")){$L_HB = "Oa";}
		}
		if($L_residue[3] eq "O"){
			$L_attype = "bbO";
			$L_HB="Oa";
		}
		if($L_residue[3]=~/N./){
			$L_attype="N";
			if(($L_residue[1] eq "ARG")or ($L_residue[1] eq "LYS")){$L_HB = "Nda";}
			elsif(($L_residue[1] eq "ASN")or ($L_residue[1] eq "GLN")){$L_HB = "Na";}
			elsif(($L_residue[1] eq "TRP")){$L_HB = "Nd";}
			elsif($L_residue[1] eq "HIS"){
				if($L_residue[3]=~/ND/){$L_HB = "Na";}
				elsif($L_residue[3]=~/NE/){$L_HB="Nd";}
			}	
		}
		if($L_residue[3] eq "N"){
			$L_attype="bbN";
			$L_HB="Nd";
		}
		if($L_residue[3]=~/S./){
			$L_attype="S";
			if($L_residue[1] eq "CYS"){$L_HB="da";}
		}
		
		#count interactions by types		
		foreach my $i(@R_residue_list){
			my @R_residue = split (",", $i);
			my $R_resid=$R_residue[1].$R_residue[0];	
			if($R_residue[3]=~/C/){$R_attype="C";}
			if($R_residue[3]=~/O./){
				$R_attype="O";
				if(($R_residue[1] eq "SER") or ($R_residue[1] eq "THR") or ($R_residue[1] eq "TYR")){$R_HB="Oda";}
				elsif(($R_residue[1] eq "GLU") or ($R_residue[1] eq "ASP")){$R_HB="Oda";}
				elsif(($R_residue[1] eq "GLN") or ($R_residue[1] eq "ASN")){$R_HB="Oa";}
			}
			if($R_residue[3] eq "O"){
				$R_attype="bbO";
				$R_HB="Oa";
			}
			if($R_residue[3]=~/N./){
				$R_attype="N";
				if(($R_residue[1] eq "ARG")or ($R_residue[1] eq "LYS")){$R_HB="Nda";}
				elsif(($R_residue[1] eq "ASN")or ($R_residue[1] eq "GLN")){$R_HB="Na";}
				elsif(($R_residue[1] eq "TRP")){$R_HB="Nd";}
				elsif($R_residue[1] eq "HIS"){
					if($R_residue[3]=~/ND/){$R_HB="Na";}
					elsif($R_residue[3]=~/NE/){$R_HB="Nd";}
				}	
			}
			if($R_residue[3] eq "N"){
				$R_attype="bbN";
				$R_HB="Nd";
			}
			if($R_residue[3]=~/S./){
				$R_attype="S";
				if($R_residue[1] eq "CYS"){$R_HB="da";}
			}

		      #AA counts and stat	
			#if(exists $AAstat{$L_residue[1]}{$R_residue[1]}){
			#	my $sum = $AAstat{$L_residue[1]}{$R_residue[1]}; 
			#	$AAstat{$L_residue[1]}{$R_residue[1]} = $sum + 1;
			#}
			#else{
			#$AAstat{$L_residue[1]}{$R_residue[1]} = 1;
			#}

			#general AA type
			if(exists $R_stat{$R_residue[1]}){
				 $R_stat{$R_residue[1]}++;
			}
			else{
				$R_stat{$R_residue[1]} = 1;
			}	
			if(exists $L_stat{$L_residue[1]}){
				 $L_stat{$L_residue[1]}++;
			}
			else{
				$L_stat{$L_residue[1]} = 1;
			}	
			#specific AA
			if(exists $R_AAstat{$R_resid}){
				$R_AAstat{$R_resid}++;
			}
			else{
				$R_AAstat{$R_resid} = 1;
			}
			if(exists $L_AAstat{$L_resid}){
				$L_AAstat{$L_resid}++;
			}
			else{
				$L_AAstat{$L_resid} = 1;
			}
			
			#interaction type count		 
			if($L_attype eq "C"){#hydrophobic
				if($R_attype eq "C"){$Hydrophobic++;}
			}
			if(($L_attype eq "N") or ($L_attype eq "O")){#polar
				if(($R_attype eq "N") or ($R_attype eq "O")){$ssPolar++;}
				if(($R_attype eq "bbN") or ($R_attype eq "bbO")){$bbssPolar++;}
			}
			if(($L_attype eq "bbN") or ($L_attype eq "bbO")){#polar bb
				if(($R_attype eq "N") or ($R_attype eq "O")) {$bbssPolar++;}
				elsif(($R_attype eq "bbN") or ($R_attype eq "bbO")) {$bbPolar++;}
			}

		      #HBonding
			if(($L_HB eq "Oa") or ($L_HB eq "Oad") or ($L_HB eq "Na") or ($L_HB eq "Nad")){
				if(($R_HB eq "Od") or ($R_HB eq "Oad") or ($R_HB eq "Nad") or ($R_HB eq "Nd")){$HBond++;}
			}
		}
	}
	print ISTAT "$Hydrophobic\t\t$ssPolar\t\t$bbssPolar\t\t$bbPolar\t\t$HBond\n";
}
print ISTAT "Contacts: receptor AA types\n";
while (my ($key, $value) = each(%R_stat)) {
	print ISTAT "$key:\t$value\n"
}
print ISTAT "\n";
print ISTAT "Contacts: ligand AA types\n";
while (my ($key, $value) = each(%L_stat)) {
	print ISTAT "$key:\t$value\n"
}
print ISTAT "\n";
print ISTAT "Contacts: receptor AA\n";
while (my ($key, $value) = each(%R_AAstat)) {
	print ISTAT "$key:\t$value\n"
}
print ISTAT "\n";
print ISTAT "Contacts: ligand AA\n";
while (my ($key, $value) = each(%L_AAstat)) {
	print ISTAT "$key:\t$value\n"
}
print ISTAT "\n";

}


sub read_consurf_score {
	# Use as input the consurf results http://consurf.tau.ac.il/
	# Add a gap to the residue number if specified
	my ($data)=$_[0];
	my ($gap)=0;
	if ($_[1]) {
		($gap)=$_[1];
	}
	my %score_list = ();
	foreach my $line(@{$data}){
		my @score = split (' ', $line);
		
		# Check if the first Value is an integer, if yes then store the conservation score
		if ($score[0]){
			if( ($score[0] =~ /^-?\d+$/) and ($score[2] ne "-" ) ) { 
				# Check the Residue number on the third column of the input file
				my $res_number = substr((split(":",$score[2]))[0],3);
				# Check if there is any character in the residue number, if yes remove the last character of the string
				if (  $res_number =~ /\D/ ) {
					chop $res_number;
				}
				$res_number = $res_number + $gap;

				# put the score value in the hashes
				$score_list{$res_number}=$score[3];
				#print "$res_number:$score[3] ";
				#$score_list{$score[0]}
			}
		}
	}
	return %score_list;
}

sub read_conseq_score {
	# Use as input the conseq results http://conseq.tau.ac.il/
	my ($data)=$_[0];
	my ($gap)=0;
	if ($_[1]) {
		($gap)=$_[1];
	}

	my %score_list = ();
	foreach my $line(@{$data}){
		my @score = split (' ', $line);
		
		# Check if the first Value is an integer, if yes then store the conservation score
		if ($score[0]){
			if( ($score[0] =~ /^-?\d+$/) and ($score[2] ne "-" ) ) { 
				# Check the Residue number on the third column of the input file
				my $res_number = $score[0] + $gap;
				# put the score value in the hashes
				$score_list{$res_number}=$score[2];
				#print "$res_number:$score[2]!\n";
			}
		}
	}
	return %score_list;
}


sub read_whiscy_score {
	# Use as input the conseq results http://nmr.chem.uu.nl/Software/whiscy/index.html
	my ($data)=$_[0];
	my ($gap)=0;
	if ($_[1]) {
		($gap)=$_[1];
	}

	my %score_list = ();
	foreach my $line(@{$data}){
		my @score = split (' ', $line);
		
		# Check the Residue number in the second column of the input file
		my $res_number = substr($score[1],1) + $gap;
		# put the score value in the hashes
		$score_list{$res_number}=$score[0];
		#print "$res_number:$score[2]!\n";
	}
	return %score_list;
}


sub conserv_interf_score {

	my(%contact_list) = %{$_[0]};
	my(%R_cons_score) = %{$_[1]};
	my(%T_cons_score) = %{$_[2]};
	
	my $R_score = 0;
	my $T_score = 0;
	my $Inter_score = 0; 

	for my $R_residue ( keys %contact_list) {
		#print "\n		$R_residue:$R_cons_score{$R_residue} \n";
		$R_score = $R_score + $R_cons_score{$R_residue};
		for my $T_residue (@{$contact_list{$R_residue}}) {
			#print "$T_residue : $T_cons_score{$T_residue} ";
			$T_score = $T_score + $T_cons_score{$T_residue};
		}
	}
	#print "R_score =  $R_score T_score =  $T_score \n";
	my @score=($R_score,$T_score);
	return @score;
}

