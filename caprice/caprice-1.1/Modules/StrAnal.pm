package StrAnal;

require Exporter;
use strict;
use warnings;
use vars qw(@ISA @EXPORT $VERSION);
our @ISA = qw(Exporter);
our @EXPORT = qw(get_rms dist split_pdb);
$VERSION=1.0;

sub get_rms{
	my ($f1,$f2)=@_;
	open(OPT, ">prm-RMSD") or die "Can not open an input file: $!";
	print OPT "&basics\n";
	print OPT "filetp=1,minres=5,stranal=1,num_mol=2\n";
	print OPT "/\n";
	print OPT "&geomet\n";
	print OPT "AAoverlay=0,bbaln=1,overlay=1,fit=0\n";
	print OPT "/\n";
	print OPT "&inpout\n";
	print OPT "pdbsave=0,outpdb=1\n";
	print OPT "/\n";
	close (OPT);
	my @args=("pr_alchem", "prm-RMSD", $$f1, $$f2);
	my $wyn=`pr_alchem prm-RMSD $$f1 $$f2`;
	chomp $wyn;
#print "$wyn\n";
	if ($? == -1) {
        	print "failed to execute: $!\n";
	}
	elsif ($? & 127) {
        	printf "child died with signal %d, %s coredump\n",
        	($? & 127),  ($? & 128) ? 'with' : 'without';
	}
	my @vyn=split(/\s+/,$wyn);
	return $vyn[3];
}

sub dist{
	my($x1,$y1,$z1,$x2,$y2,$z2)=@_;
        my $square=($$x1-$$x2)**2+($$y1-$$y2)**2+($$z1-$$z2)**2;
        my $result=sqrt($square);
        return $result;
}

sub split_pdb{#store the files as 2D matrix	
	my ($temp1)=@_;
	my (@native_one,@native_two,@predict_one,@predict_two,$num);
	my $count=0;
	my $miss=0;
	my $chain="RANDOM";
	my $len=scalar(@{$temp1});
	for(my $i=0;$i<$len;$i++){
		if($$temp1[$i]=~/^ATOM.*?/){
			$count++;
			if($count == 1){#mark a chain ID
				$chain=substr($$temp1[$i],21,1);
			}
			if($chain eq substr($$temp1[$i],21,1)){#chain one
				$native_one[$i-$miss][0]=substr($$temp1[$i],7,4);#atom number
				$native_one[$i-$miss][1]=substr($$temp1[$i],21,1);#Chain ID
				$native_one[$i-$miss][2]=substr($$temp1[$i],23,4);#residue number
				$native_one[$i-$miss][3]=substr($$temp1[$i],32,6);#X
				$native_one[$i-$miss][4]=substr($$temp1[$i],40,6);#Y
				$native_one[$i-$miss][5]=substr($$temp1[$i],48,6);#Z
				$native_one[$i-$miss][6]=$i+1;#line number
			}
			if($chain ne substr($$temp1[$i],21,1)){#chain two
				$num=scalar(@native_one);
				$native_two[$i-$num-$miss][0]=substr($$temp1[$i],7,4);#atom number
				$native_two[$i-$num-$miss][1]=substr($$temp1[$i],21,1);#Chain ID
				$native_two[$i-$num-$miss][2]=substr($$temp1[$i],23,4);#residue number
				$native_two[$i-$num-$miss][3]=substr($$temp1[$i],32,6);#X
				$native_two[$i-$num-$miss][4]=substr($$temp1[$i],40,6);#Y
				$native_two[$i-$num-$miss][5]=substr($$temp1[$i],48,6);#Z
				$native_two[$i-$num-$miss][6]=$i+1;#line number
			}
		}
		else{
			$miss++;		
		}	
	}

	#get the line numbers for calculation
	my $num1=scalar(@native_one);
	my $num2=scalar(@native_two);

	my $resid1=$native_one[0]->[2];
	my $resid2=$native_one[$num1-1]->[2];
	my $lresid1=$native_two[0]->[2];
	my $lresid2=$native_two[$num2-1]->[2];
	
	my $r1=1;
	my $r2=$resid2-$resid1+1;
	my $l1=$r2+1;
	my $l2=$l1+$lresid2-$lresid1;

	return (\$num1,\$num2,\@native_one,\@native_two,\$r1,\$r2,\$l1,\$l2);
}
