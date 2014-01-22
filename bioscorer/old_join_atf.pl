#!/usr/bin/perl
use strict;
use warnings;
use ParsePDB;

# ==============================
#
# Name:    join_atf.pl
# Author:  Rauan Sagit
# Created: Wed Nov 11 23:53:13 CET 2009
#
# ==============================

# User input
open(IN, $ARGV[0]) or die "Could not read file ".$ARGV[0].": $!\n"; # List of PDB files

PDB_LIST:
	while(<IN>) {
		chomp;

		unless (/\.pdb$/) {
			print STDERR "$_ is not a PDB file? ".`date`;
			next;
		}

        # Get rid of all (?) hydrogens!
        my $atom_pdb_file = "atom_$_";
		unless (-e $atom_pdb_file) {
       		my $run_grep = "grep \'^ATOM\' $_ | grep -P -v \'H\\s+\$\' > $atom_pdb_file";
        	`$run_grep`;
		}

		my $pdb = ParsePDB->new (FileName => $atom_pdb_file);
		$pdb->Parse;
		$pdb->RenumberResidues (ResidueStart => 1);
		$pdb->RenumberChains (ChainStart => 'A');
		my @chain_ids = $pdb->IdentifyChainLabels;
		
		Chain_1:
			for (my $i = 0; $i < @chain_ids-1; $i++) {

				my $chain_1_file = $_;
				$chain_1_file =~ s/\.pdb$/\_chain\_$i\.pdb/;

				Chain_2:
					for (my $j = $i+1; $j < @chain_ids; $j++) { # set $j = $i+1, avoid identical cases
				
						my $chain_2_file = $_;
						$chain_2_file =~ s/\.pdb$/\_chain\_$j\.pdb/;
						
						# put the two .atf files into one file, called $chain_1_file.$chain_2_file.join.atf
				
						# There are two .atf files created here, ffs!
						my $atf_file_first  = "$chain_1_file.$chain_2_file.atf";
						my $atf_file_second = "$chain_2_file.$chain_1_file.atf";

						next unless (-e($atf_file_first) and -e($atf_file_second));

						my @f1 = `cat $atf_file_first`;
						chomp @f1;

						my @f2 = `cat $atf_file_second`;
						chomp @f2;

						# Empty cases
						next if (scalar(@f1) == 0 or scalar(@f2) == 0);

						my $join_atf_file = "$chain_1_file.$chain_2_file.join.atf";
						open(OUT, ">$join_atf_file") || die "Could not write to $join_atf_file: $!\n";

						F:
							for (my $i = 0; $i < scalar(@f1); $i++) {
								
								my $T_A = $f1[$i];
								$T_A    =~ s/^T\s*(\d+)\s+.*/$1/;

								my $h_1 = $f1[$i];
								$h_1    =~ s/^T\s*\d+\s+(.*)/$1/;
								my @hit_1 = split(/\s+/, $h_1);

								my $T_B = $f2[$i];
								$T_B    =~ s/^T\s*(\d+)\s+.*/$1/;

								my $h_2 = $f2[$i];
								$h_2    =~ s/^T\s*\d+\s+(.*)/$1/;
								my @hit_2 = split(/\s+/, $h_2);

								printf OUT ("T%3d", ($i+1));

								HIT:
									for (my $j = 0; $j < scalar(@hit_1); $j++) {

										my $H = $hit_1[$j] + $hit_2[$j];
										printf OUT ("%11d", $H);

									} # HIT

								print OUT "\n";

							} # F

						close(OUT);

					} # Chain_2

		} # Chain_1

	} # PDB_LIST

close(IN);

exit;
