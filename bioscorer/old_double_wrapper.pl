#!/usr/bin/perl
use strict;
use warnings;
use ParsePDB;

# ==============================
#
# Name:    double_wrapper.pl
# Author:  Rauan Sagit
# Created: Wed Nov 11 23:53:13 CET 2009
#
# ==============================

#use Inline 'C' => <<'DIST_CALC';
#
#int dist(float x1, float y1, float z1, float x2, float y2, float z2, float T) {
#	float Tc = T*T;
#	float D  = (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) + (z1 - z2)*(z1 - z2);
#
#	if (D<=Tc) {
#		return 1;
#	}
#	else {
#		return 0;
#	}
#}
#DIST_CALC

# Global constants
my $PROBE = "1.5";
my $T_C   = "8"; # Minimum distance (Angstroms) between at least one pair of atoms of a pair of chains

# User input
open(IN, $ARGV[0]) or die "Could not read file ".$ARGV[0].": $!\n"; # List of PDB files
my $Log = $ARGV[1]; # Log file

if (-e $Log) {
	unlink($Log);
}

`touch $Log`;

PDB_LIST:
	while(<IN>) {
		chomp;

		unless (/\.pdb$/) {
			print STDERR "$_ is not a PDB file? ".`date`;
			next;
		}

		`echo "[\$(date +"%F %H:%M:%S")] $0: $_" >> $Log`;
		
		# Get rid of all (?) hydrogens!
		my $atom_pdb_file = "atom_$_";
		my $run_grep = "grep \'^ATOM\' $_ | grep -P -v \'H\\s+\$\' > $atom_pdb_file";
		`$run_grep`;

		my $pdb = ParsePDB->new (FileName => $atom_pdb_file);
		$pdb->Parse;
		$pdb->RenumberResidues (ResidueStart => 1);
		$pdb->RenumberChains (ChainStart => 'A');
		my @chain_ids = $pdb->IdentifyChainLabels;
		
		Chain_1:
			for (my $i = 0; $i < @chain_ids-1; $i++) {

				my $chain_1_file = $_;
				$chain_1_file =~ s/\.pdb$/\_chain\_$i\.pdb/;

				my @atoms_1 = $pdb->Get(ChainLabel => $chain_ids[$i]);
				chomp @atoms_1;

				open(OUT_1, ">$chain_1_file") or die "Could not write to $chain_1_file: $!\n";

				Atoms_1:
						foreach my $a(@atoms_1) {
							print OUT_1 "$a\n";
						}
				close(OUT_1);

				Chain_2:
					for (my $j = $i+1; $j < @chain_ids; $j++) { # set $j = $i+1, avoid identical cases
				
						my $chain_2_file = $_;
						$chain_2_file =~ s/\.pdb$/\_chain\_$j\.pdb/;
						
						my @atoms_2 = $pdb->Get(ChainLabel => $chain_ids[$j]);
						chomp @atoms_2;

						open(OUT, ">$chain_2_file") or die "Could not write to $chain_2_file: $!\n";

						Atoms_2:
							foreach my $a(@atoms_2) {
								print OUT "$a\n";
							}

						close(OUT);

						# There are two .atf files created here, ffs!
						my $atf_file_first  = "$chain_1_file.$chain_2_file.atf";
						my $atf_file_second = "$chain_2_file.$chain_1_file.atf";

						# Skip already calculated cases
						next if ( -e($atf_file_first) and -e($atf_file_second) );

						# Find out if the two chains are in contact
						my $bool_contact = 0;
						
						my @coor_1 = ();
						my @coor_2 = ();

						Atoms_1:
							for (my $k = 0; $k < @atoms_1; $k++) {
								my $a_1 = $atoms_1[$k];

								$a_1 =~ s/^.{30}\s*//;

								# Argument "-17.761-117.250" isn't numeric
								$a_1 =~ s/(\d)\-/$1 \-/g;

								my ($x1, $y1, $z1, @other1) = split(/\s+/, $a_1);
								
								$coor_1[$k][0] = $x1;
								$coor_1[$k][1] = $y1;
								$coor_1[$k][2] = $z1;
							} # Atoms_1

						Atoms_2:
							for (my $l = 0; $l < @atoms_2; $l++) {
								my $a_2 = $atoms_2[$l];
								$a_2 =~ s/^.{30}\s*//;

								# Argument "-17.761-117.250" isn't numeric
								$a_2 =~ s/(\d)\-/$1 \-/g;

								my ($x2, $y2, $z2, @other2) = split(/\s+/, $a_2);
							
								$coor_2[$l][0] = $x2;
								$coor_2[$l][1] = $y2;
								$coor_2[$l][2] = $z2;
							} # Atoms_2

						Atoms_1:
							for (my $k = 0; $k < @atoms_1; $k++) {
								Atoms_2:
									for (my $l = 0; $l < @atoms_2; $l++) {

										my $dist = ($coor_1[$k][0] - $coor_2[$l][0])*($coor_1[$k][0] - $coor_2[$l][0]) + ($coor_1[$k][1] - $coor_2[$l][1])*($coor_1[$k][1] - $coor_2[$l][1]) + ($coor_1[$k][2] - $coor_2[$l][2])*($coor_1[$k][2] - $coor_2[$l][0]);

										# my $test = dist($coor_1[$k][0], $coor_1[$k][1], $coor_1[$k][2], $coor_2[$l][0], $coor_2[$l][1], $coor_2[$l][2], $T_C);
										# if ($test == 1) {

										if ($dist <= $T_C*$T_C) {
											$bool_contact = 1;
											last Atoms_1;
										}

									} # Atoms_2
							} # Atoms_1

						unless ($bool_contact) {
							`echo "\t\tZero contacts: $chain_1_file $chain_2_file" >> $Log`;
							next Chain_2;
						}

						# Do the triangulation, create .atom and .cross files, (1)
						unless (-e "$chain_1_file.atom") {
							my $run_triominoes_1 = "./triominoes $chain_1_file $PROBE 2>>$Log";
							`$run_triominoes_1 2> /dev/null`;
						}

						# Do the triangulation, create .atom and .cross files, (2)
						unless (-e "$chain_2_file.atom") {
							my $run_triominoes_2 = "./triominoes $chain_2_file $PROBE 2>>$Log";
							`$run_triominoes_2 2> /dev/null`;
						}

						# Remark: both .atf files concern the same interface, so it could be stupid
						#         to store one interface in two .atf files.

						# Create the T+A matrix atom(1) vs cross(2)
						unless( -e($atf_file_first) ) {
							my $run_atf_first = "./atom_triangle_freq.pl $chain_1_file.atom $chain_2_file.cross > $atf_file_first 2>>$Log";
							`$run_atf_first`;
						}

						# Create the T+A matrix atom(2) vs cross(1)
						unless( -e($atf_file_second) ) {
							my $run_atf_second = "./atom_triangle_freq.pl $chain_2_file.atom $chain_1_file.cross > $atf_file_second 2>>$Log";
							`$run_atf_second`;
						}

					} # Chain_2

		} # Chain_1

	} # PDB_LIST

close(IN);

exit;
