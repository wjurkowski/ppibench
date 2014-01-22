package PoseClust;

#Takes center CA atom of each pose and finds clusters in da cloud 
#
require Exporter;
use vars qw(@ISA @EXPORT $VERSION);
our @ISA = qw(Exporter);
our @EXPORT = qw(get_cloud parse_ca dist_feed cluster);
$VERSION=1.0;
use strict;
use warnings;

use StrAnal;

#parse  poses and generates a cloud
sub get_cloud{
	my ($list) = @_;
	my (@clouds);
	my @files=open_file($list);
	my $pattern=" CA  CYS    68 ";
	#my $pattern=$$patt;
	my $cloud_file;	

	foreach  my $line(@files){
		my $numb = "\t".substr($line, index($line,".",2)+1);
		my @center = fgrep {$pattern} glob  $line;
		push(@center,$numb);
		push(@clouds,@center);
	}

	open (CLD, ">$cloud_file") or die "Can not open an output file: $!";
	print CLD "@clouds\n";
	close (CLD);
	return(\$cloud_file);
}

#parses CA atoms
sub parse_ca{
        my ($temp1)=@_;
        my (@native_one,@native_two,@predict_one,@predict_two,$num,@calfas);
        my $count=0;
        my $len=scalar(@{$temp1});
        for(my $i=0;$i<$len;$i++){
                if($$temp1[$i]=~/^ATOM.*?/){
                 $count++;
		 my @dane=split($$temp1[$i],"\t");
		 $calfas[$i][0]=substr($$temp1[$i],32,6);#X	
		 $calfas[$i][1]=substr($$temp1[$i],40,6);#Y	
		 $calfas[$i][2]=substr($$temp1[$i],48,6);#Z	
		 $calfas[$i][3]=$dane[1];
                }
        }
	return(\@calfas);
}

#feed the data to dist calculations
sub dist_feed{
	my ($calfas,$ofile) = @_;	
	my $len=scalar(@{$calfas});
	my $outf=$$ofile;
	open (DMTX, ">$outf") or die "Can not open an output file: $!";
	for(my $i=0;$i<$len;$i++){
		my $x1=$$calfas[$i][0];
		my $y1=$$calfas[$i][1];
		my $z1=$$calfas[$i][2];
		my $n1=$$calfas[$i][3];
		for(my $k=$i+1;$k<$len;$k++){
			my $x2=$$calfas[$k][0];
			my $y2=$$calfas[$k][1];
			my $z2=$$calfas[$k][2];
			my $n2=$$calfas[$k][3];
		my $distm = dist(\$x1,\$y1,\$z1,\$x2,\$y2,\$z2);
		print DMTX "$n1\t$n2\t$distm\n";
		}
	}
} 

# clustering with R script
sub cluster{
	my ($distm) = @_;
	my $distmtx=$$distm;
	`./cluster_kmeans.R $distmtx`;
}

