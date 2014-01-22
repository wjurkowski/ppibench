package capri_assessment;

require Exporter;
use strict;
use warnings;
use vars qw(@ISA @EXPORT $VERSION);
our @ISA = qw(Exporter);
our @EXPORT = qw(get_L_rms get_I_rms parse_contacts make_brugel);
$VERSION=1.0;

use StrAnal;


sub get_L_rms{
	my ($f1,$f2)=@_;

	#read in two files
	open WILD,"<$$f1"or die "can not open $$f1:$!";
	my @native=<WILD>;
	chomp @native;
	my @temp1=grep{/^ATOM.*?/} @native;

	my ($n1,$n2,$one,$two,$r1,$r2,$l1,$l2)=split_pdb(\@temp1);
	my $num1=$$n1;
	my $num2=$$n2;

	my $rec1=$$r1;
	my $rec2=$$r2;
	my $lig1=$$l1;
	my $lig2=$$l2;

	open(OPT, ">prm-L_RMS") or die "Can not open an input file: $!";
	print OPT "&basics\n";
	print OPT "filetp=1,minres=2,stranal=1,num_mol=2\n";
	print OPT "/\n";
	print OPT "&geomet\n";
	print OPT "bbaln=1,capri=1,recs=$rec1,rece=$rec2,ligs=$lig1,lige=$lig2\n";
	print OPT "/\n";
	print OPT "&inpout\n";
	print OPT "pdbsave=0,outpdb=0\n";
	print OPT "/\n";
	close (OPT);
	my @args=("pr_alchem", "prm-L_RMS", $$f1, $$f2);
	my $wyn=`pr_alchem prm-L_RMS $$f1 $$f2`;
	chomp $wyn;
	if ($? == -1) {
	print "failed to execute: $!\n";
	}
	elsif ($? & 127) {
	printf "child died with signal %d, %s coredump\n",
	($? & 127),  ($? & 128) ? 'with' : 'without';
	}
	my @vyn=split(/\s+/,$wyn);
	return $vyn[2];
}

sub make_brugel{
#correct_c - predicted native contacts
#native_c - native contacts
#not_correct - predicted non native contacts
#predicted_c - all contacts predicted
my ($mol1,$mol2,$contacts,$L_rms,$I_rms)=@_;

#print "$$mol1 $$mol2\n";
my $native_c=$$contacts[0];
my $predicted_c=$$contacts[1];
my $correct_c=$$contacts[2];
my $not_correct_c=$$contacts[3];

my $fnat=$correct_c/$native_c;
my $fnonnat=$not_correct_c/$predicted_c;

if($fnat>=0.5 and ($$L_rms<=1.0 or $$I_rms<=1.0)){
printf "%s\t%s\t%s\t%5.2f\t%7.3f\t%7.3f\n",$$mol1,$$mol2,"H",$fnat,$$L_rms,$$I_rms;
}
elsif(($fnat<0.5 and $fnat>=0.3) and ($$L_rms<=5.0 or $$I_rms<=2.0)){
printf "%s\t%s\t%s\t%5.2f\t%f7.3f\t%7.3f\n",$$mol1,$$mol2,"M",$fnat,$$L_rms,$$I_rms;
}
elsif($fnat>=0.5 and $$L_rms>1.0 and $$I_rms>1.0){
printf "%s\t%s\t%s\t%5.2f\t%7.3f\t%7.3f\n",$$mol1,$$mol2,"M",$fnat,$$L_rms,$$I_rms;
}
elsif(($fnat<0.3 and $fnat>=0.1) and ($$L_rms <=10.0 or $$I_rms<=4.0)){
printf "%s\t%s\t%s\t%5.2f\t%7.3f\t%7.3f\n",$$mol1,$$mol2,"A",$fnat,$$L_rms,$$I_rms;
}
elsif($fnat>=0.3 and $$L_rms>5.0 and $$I_rms>2.0){
printf "%s\t%s\t%s\t%5.2f\t%7.3f\t%7.3f\n",$$mol1,$$mol2,"A",$fnat,$$L_rms,$$I_rms;
}
elsif($fnat<0.1 or ($$L_rms>10.0 and $$I_rms<=4.0)){
printf "%s\t%s\t%s\t%5.2f\t%7.3f\t%7.3f\n",$$mol1,$$mol2,"I",$fnat,$$L_rms,$$I_rms;
}
}

sub parse_contacts {
my ($file1, $file2)=@_;
my %pary1=(), 
my %pary2=();
my $native_c=0;
my $predicted_c=0;
my $not_correct_c=0;
my $correct_c=0;

foreach my $line(@{$file1}){
	$line=~s/\(//g;
	$line=~s/\)//g;
	my @czasteczki=split(":",$line);
	 my @kontakty=split(";",$czasteczki[1]);
	  my @feat1=split(",",$czasteczki[0]);
	  foreach my $i(@kontakty){
		my @feat2=split(",",$i);
		my $pair=$feat1[0]."-".$feat2[0];
		if(exists $pary1{$pair}) {
                        my $cnt=$pary1{$pair}+1;
                        $pary1{$pair}=$cnt;}
		else{
			my $cnt=1;
			$pary1{$pair}=$cnt;}
	  }
}
$native_c=keys(%pary1);

foreach my $line(@{$file2}){
	$line=~s/\(//g;
	$line=~s/\)//g;
	my @czasteczki=split(":",$line);
	 my @kontakty=split(";",$czasteczki[1]);
	  my @feat1=split(",",$czasteczki[0]);
	  foreach my $i(@kontakty){
		my @feat2=split(",",$i);
		my $pair=$feat1[0]."-".$feat2[0];
		if(exists $pary2{$pair}) {
                        my $cnt=$pary2{$pair}+1;
                        $pary2{$pair}=$cnt;}
                else{
                        my $cnt=1;
                        $pary2{$pair}=$cnt;}
	  }
}

while (my ($key, $value) = each(%pary1)) {
	if (exists $pary2{$key}) {
	$correct_c++;
	$predicted_c++;
	}
	else {
	#print "$key, $value, $pary2{$key}\n";
	$predicted_c++;
	$not_correct_c++;
	}
}

my @results=($native_c,$predicted_c,$correct_c,$not_correct_c);
return @results;
}

sub get_I_rms{
	my ($native_file,$predict_file)= @_;

	#read in two files
	open NATIVE,"<$$native_file"or die "can not open $$native_file:$!";
	my @native=<NATIVE>;
	chomp @native;
	my @temp1=grep{/^ATOM.*?/} @native;
	open PREDICT,"<$$predict_file"or die "can not open $$predict_file:$!";
	my @predict=<PREDICT>;
	chomp @predict;
	my @temp2=grep{/^ATOM.*?/} @predict;

	my ($n1,$n2,$one,$two)=split_pdb(\@temp1);
	my $num1=$$n1;
	my $num2=$$n2;
	my @nat_one=@{$one};
	my @nat_two=@{$two};
	my @bla=get_interface(\@nat_one,\@nat_two,\$num1,\$num2);
	
	#do the calculation
	open ONE,">I_rmsd_1" or die"can not create I_rmsd_1:$!";
	for(my $i=0;$i<@bla;$i++){
		for(my $j=0;$j<@temp1;$j++){
		if($bla[$i] eq ($j+1)) {print ONE "$temp1[$j]\n";}
		}
	}
	close ONE;
	
	open TWO,">I_rmsd_2" or die"can not create I_rmsd_1:$!";
	for(my $i=0;$i<@bla;$i++){
		for(my $j=0;$j<@temp2;$j++){
		if($bla[$i] eq ($j+1)) {print TWO "$temp2[$j]\n";}
		}
	}
	close TWO;
	
	open(OPT, ">prm-RMSD") or die "Can not open an input file: $!";
	print OPT "&basics\n";
	print OPT "filetp=1,minres=2,stranal=1,num_mol=2\n";
	print OPT "/\n";
	print OPT "&geomet\n";
	print OPT "AAoverlay=0,bbaln=1,overlay=1,fit=0\n";
	print OPT "/\n";
	print OPT "&inpout\n";
	print OPT "pdbsave=0,outpdb=1\n";
	print OPT "/\n";
	close (OPT);

	my $temp=`pr_alchem prm-RMSD I_rmsd_1 I_rmsd_2`;
	#`rm prm-RMSD I_rmsd_1 I_rmsd_2`;
	my @final=split(/\t/,$temp);
	return $final[3];
}


sub get_interface{#calculate the distance and find the lines
		my($first,$second,$num1,$num2)=@_;
		my $distance;
		my @result_first;
		my @result_second;		
		for(my $i=0;$i<$$num1;$i++){
			for(my $j=0;$j<$$num2;$j++){
				my $x1=$$first[$i][3];
				my $y1=$$first[$i][4];
				my $z1=$$first[$i][5];
				my $x2=$$second[$j][3];
				my $y2=$$second[$j][4];
				my $z2=$$second[$j][5];
				#print "$$first[$i][2]	$$first[$i][3]	$$first[$i][4]	$$second[$j][2]	$$second[$j][3]	$$second[$j][4]\n";
				#die;
				$distance=dist(\$x1,\$y1,\$z1,\$x2,\$y2,\$z2);
				#print "$$first[$i][2]	$$first[$i][3]	$$first[$i][4]	$$second[$j][2]	$$second[$j][3]	$$second[$j][4]\n";
				if($distance <= 10){
					my $temp="$$first[$i][6]";
					push @result_first,$temp;
					my $temp2="$$second[$j][6]";
					push @result_second,$temp2;
				}
			}
		}
		my %hash=();
		my @result1 = grep{$hash{$_}++ <1} @result_first;
		my %hash2=();
		my @result2 = grep{$hash2{$_}++ <1} @result_second;
		my @interface=(@result1,@result2);
		return @interface;
}

