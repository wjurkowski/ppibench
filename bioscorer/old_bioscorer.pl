#!/usr/bin/perl
use strict;
use warnings;

# ==============================
#
# Name:    bioscorer.pl
# Author:  Rauan Sagit
# Created: Wed Nov 18 12:39:58 CET 2009
#
# ==============================

# Use a collection of native .atf files as the background
# distribution and calculate the scores for the query .atf
# files

# T  1          0          0          0          0          0          0          0          0          0          0          0          0          0

# Global variables
my $E             = 0;
my @Native_Matrix = ();
my $Total         = 0;
my $V             = 0;
my $V_Square      = 0;

# User input
my $Native_Atf_File = $ARGV[0];
my $Query_Atf_Dir   = $ARGV[1];
my $Base            = $ARGV[2];

my $dateM = `echo \"[\$(date +"%F %H:%M:%S")]\"`;
chomp $dateM;

print STDERR "$dateM: $0 $Native_Atf_File $Query_Atf_Dir\n";

my @Query_Atf_List = `ls $Query_Atf_Dir/$Base*.join.atf`;
chomp @Query_Atf_List;

# Fill the native matrix
my @nat = `cat $Native_Atf_File`;
chomp @nat;

Triangles:
	foreach (@nat) {
		my $t_type = $_;
		$t_type =~ s/^T\s*(\d+)\s+.*/$1/;

		my $a_line = $_;
		$a_line =~ s/^T\s*\d+\s+(.*)/$1/;
		my @atoms = split(/\s+/, $a_line);

		Atoms:
			for (my $j = 0; $j < @atoms; $j++) {
				my $a_type = $j+1;
				$Native_Matrix[$t_type][$a_type] = $atoms[$j];
			} # Atoms

	} # Triangles

# E(I) = sum(i=1:455)sum(j=1:13) p(i,j)*ln(p(i,j))

# VAR(I) = sum(i=1:455)sum(j=1:13) p(i,j)*ln^2(p(i,j)) - (sum(i=1:455)sum(j=1:13) p(i,j)*ln(p(i,j)))^2

# I = sum(n=1:m) ln(p(n))

# Contact_Score(I) = (I - m * E(I)) / sqrt( m^2 * VAR(I) )

# Calculate the total number of contacts

T_Type:
	for (my $i = 1; $i <= 455; $i++) {
		A_Type:
			for (my $j = 1; $j <= 13; $j++) {
				$Total += $Native_Matrix[$i][$j];
			}
	}

# Calculate E(I) and V(I)

T_Type:
	for (my $i = 1; $i <= 455; $i++) {

		A_Type:
			for (my $j = 1; $j <= 13; $j++) {

				my $p = $Native_Matrix[$i][$j] / $Total;

				# Skip if $p is zero
				next if ($p == 0);

				# log() is ln() in Perl

				$E += $p * log($p);

				$V_Square += $p * log($p) * log($p);

			} # A_Type

	} # T_Type

$V = $V_Square - $E * $E;

# Calculate I and M

Query_List:
	foreach (@Query_Atf_List) {
		chomp;

		# Local variables
		my $Contact_Score;
		my $I = 0;
		my $M = 0;

		my @atf = `cat $_`;
		chomp @atf;

		# Skip failed .atf files
		next if ($atf[0] =~ /^FAIL/);

		Atf_File:
			for (my $i = 0; $i < @atf; $i++) {
			
				my $t_type = $atf[$i];
				$t_type =~ s/^T\s*(\d+)\s+.*/$1/;

				my $a_line = $atf[$i];
				$a_line =~ s/^T\s*\d+\s+(.*)/$1/;
				my @atoms = split(/\s+/, $a_line);

				Atoms:
					for (my $j = 0; $j < @atoms; $j++) {
						my $a_type = $j+1;

						# It is about this particular contact type, between $t_type and a_type
						# What should be added to I is the number of times this particular
						# contact is observed Multiplied by the score for this contact type

						# Observe that sometimes $p is zero, while $atoms[$j] is not zero...
						# We might be interested in catching these cases in the future, but
						# for now we will simply ignore them :D

						my $p = $Native_Matrix[$t_type][$a_type] / $Total;

						# Skip if $p is zero
						next if ($p == 0);

						$I += $atoms[$j] * log($p);

						$M += $atoms[$j];

					} # Atoms
			} # Atf_File

		my $date = `echo \"[\$(date +"%F %H:%M:%S")]\"`;
		chomp $date;

		# Skip if the number of contacts, $M, is zero
		if ($M == 0) {
			print STDERR "$date: $_ has 0 contacts\n";
			next;
		}

		# Calculate Contact_Score(I)
		# $Contact_Score = ($I - $M * $E) / sqrt($M * $M * $V);
		# standardized_atomic = (score_atomic - num_matches * E_A) / ( sqrt(num_matches) * sqrt(V_A) );
		$Contact_Score = ($I - $M * $E) / sqrt($M * $V);

		my $q_item = $_;
		$q_item =~ s/^.*\/(.*)/$1/; # get rid of dir before

		# Print the result
		print "$q_item $M $Contact_Score\n";

	} # Query_List

exit;
