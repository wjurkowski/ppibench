#!/usr/bin/perl
use strict;
use warnings;

# ==============================
#
# Name:    divide.pl
# Author:  Rauan Sagit
# Created: Fri Nov 13 15:13:56 CET 2009
#
# ==============================

my $file = $ARGV[0]; # Data set
my $num  = $ARGV[1]; # Number of sub sets

my @F = `cat $file`;
chomp @F;

my $frac = int(@F / $num);

CUT:
	for (my $i = 0; $i < $num; $i++) {

		my $start = $i*$frac;

		my $stop  = ($i+1) * $frac;

		if ( ($stop+$frac) > @F) {
			$stop = @F;
		}

		my $group_file = "$file.$i.list";

		open(OUT, ">$group_file") or die "Could not write to $group_file: $!\n";

		FILL:
			for (my $j = $start; $j < $stop; $j++) {
				print OUT $F[$j]."\n";
			} # FILL

		close(OUT);

	} # CUT

exit;
