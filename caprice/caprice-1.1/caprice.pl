#!/usr/bin/perl -w
#program compares contacts of two complexes
#contacts read in from two files: (1)source_ligand.out and (2)query_ligand.out
#RMSD calculated by pr_alchem source_complex.pdb query_complex.pdb
#pdb contains receptor+ligand separated with TER
#complex filename receptor-ligand.pdb
use strict;
use warnings;

use capri_assessment;
use StrAnal;

if ($#ARGV != 4) {die "Program used with parameters [cmap 1] [cmap 2] [pdb 1] [pdb 2] [rms]\n";}

  my ($correct_c,$native_c,$not_correct_c,$predicted_c);

  my $n1=substr($ARGV[0],0,rindex($ARGV[0],"."));
  my $n2=substr($ARGV[1],0,rindex($ARGV[1],"."));
  my $contf1=$ARGV[0];
  my $contf2=$ARGV[1];
  my $pdb1=$ARGV[2];
  my $pdb2=$ARGV[3];
  chomp $pdb1;
  chomp $pdb2;
  my $rmst=$ARGV[4];
  my $results="mqa_$n1.$n2.out";
  open(GOUT, ">> $results") or die "Can not open an input file: $!";

  open(INP1, "< $contf1") or die "Can not open an input file: $!";
  my @contacts1=<INP1>;
  close (INP1);
  chomp @contacts1;

  open(INP2, "< $contf2") or die "Can not open an input file: $!";
  my @contacts2=<INP2>;
  close (INP2);
  chomp @contacts2;

  my ($L_rms);
  if($rmst eq "lrms") {
	$L_rms=get_L_rms(\$pdb1,\$pdb2);}
  elsif ($rmst eq "rms") {
	$L_rms=get_rms(\$pdb1,\$pdb2);}
  my $I_rms=get_I_rms(\$pdb1,\$pdb2);
  my @contacts=parse_contacts(\@contacts1,\@contacts2);
  make_brugel(\$pdb1,\$pdb2,\@contacts,\$L_rms,\$I_rms);

