#!/usr/bin/perl
use strict;
use warnings;

# ==============================
#
# Name:    gen_nat_atf.pl
# Author:  Rauan Sagit
# Created: Wed Nov 18 12:39:58 CET 2009
#
# ==============================

# T  1          0          0          0          0          0          0          0          0          0          0          0          0          0

# Global variables
my @Native_Matrix = ();

# User input
my $Atf_Dir = $ARGV[0];

my $dateM = `echo \"[\$(date +"%F %H:%M:%S")]\"`;
chomp $dateM;

print STDERR "$dateM: $0 $Atf_Dir\n";

my @Atf_List = `ls $Atf_Dir/*.join.atf`;
chomp @Atf_List;

# Initiate the native matrix
T_Type:
	for (my $i = 1; $i <= 969; $i++) {

		A_Type:
			for (my $j = 1; $j <= 17; $j++) {

				$Native_Matrix[$i][$j] = 0;

			} # A_TYPE

	} # T_TYPE

# Fill in the native matrix

my $native_count = 0;

Native_Files:
	foreach (@Atf_List) {
		chomp;

		my @atf = `cat $_`;
		chomp @atf;

		# Skip failed .atf files
		next if ($atf[0] =~ /^FAIL/);

		$native_count++;

		Atf_File:
			for (my $i = 0; $i < @atf; $i++) {

				# T443         10         11         17 <--- Look out for these cases

				my $t_type = $atf[$i];
				$t_type =~ s/^T\s*(\d+)\s+.*/$1/;

				my $a_line = $atf[$i];
				$a_line =~ s/^T\s*\d+\s+(.*)/$1/;
				my @atoms = split(/\s+/, $a_line);

				Atoms:
					for (my $j = 0; $j < @atoms; $j++) {
						my $a_type = $j+1;

						$Native_Matrix[$t_type][$a_type] += $atoms[$j];
					} # Atoms
			} # Atf_File

		if ($native_count % 100 == 0) {
			my $date = `echo \"[\$(date +"%F %H:%M:%S")]\"`;
			chomp $date;
			print STDERR "\t\t$date: finished loading $native_count\n";
		}

	} # Native_Files

# The output matrix, print to STDOUT
	TRIANGLE:
		for (my $i=1; $i<=969; $i++) {
			printf ("T%3d", $i);
			ATOM:
				for (my $j=1; $j<=17; $j++) {
	    			printf "%11d", $Native_Matrix[$i][$j];
				}
			print "\n";
		}

exit;
