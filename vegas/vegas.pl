#!/usr/bin/perl -w
use strict;
use warnings;
use File::Copy;

if ($#ARGV < 0) {die "Program requires command line parameters [run mode: -cluster| -visual| -filter | -submit] [options] \n";}
if ($ARGV[0] eq "-cluster" and $#ARGV<3) {die "Program requires command line parameters [-cluster] [multipdb] [pdb]\n";}
elsif ($ARGV[0] eq "-visual" and $#ARGV<2) {die "Program requires command line parameters [-visual] [program] [list]\n";}
elsif ($ARGV[0] eq "-filter" and $#ARGV<5) {die "Program requires command line parameters [-filter] [rankes] [top#] [inp dir] [out dir]\n";}
elsif ($ARGV[0] eq "-submit" and $#ARGV<4) {die "Program requires command line parameters [-submit] [head] [receptor] [list]\n";}


if($ARGV[0] eq "-cluster"){
  my $traj=$ARGV[1];
  my $topol=$ARGV[2];
  my $g_clust_cutoff="0.5";
  my $clust_m="gromos";
  my $min_str="3";
  my $write_cutoff="1.0";
  gmx_cluster(\$traj,\$topol,\$g_clust_cutoff,\$clust_m,\$min_str,\$write_cutoff);
}

if($ARGV[0] eq "-visual"){
  if($ARGV[1] eq "pymol"){
    print "to run type: pymol file.pml\n"; 	
    my @files=open_file(\$ARGV[2]); 
    load_to_pymol(\@files,\$ARGV[2]);
  }
  elsif($ARGV[1] eq "vmd"){
    my @files=open_file(\$ARGV[2]); 
    load_to_vmd(\@files,\$ARGV[2]);
  }
}

#sort score files and filters the defined top models, usage: -filter [score file] [number of top models to include] 
if($ARGV[0] eq "-filter"){
  my $dir1=$ARGV[3];
  my $dir2=$ARGV[4];
  my $top=$ARGV[2];
  sort_scores(\$ARGV[1]);
  my $sorted=$ARGV[1].".sort";
  copy_selected(\$sorted,\$top,\$dir1,\$dir2);
}

#prepares final pdb submission, models present in working dir
if($ARGV[0] eq "-submit"){
  my $head=$ARGV[1];
  my $rec=$ARGV[2];
  my $list=$ARGV[3];
  prepare_submission(\$head,\$rec,\$list);
}

#FUNCTIONS
#prepares final pdb submission 
sub prepare_submission{
  my ($head,$rec,$list)=@_;
  my $headf=$$head;
  my $lista=$$list;
  my $recep=$$rec;
  my @header=open_file(\$headf);
  my @receptor=open_file(\$recep);
  my @topsel=open_file(\$lista);
  open(WYN, ">31-Eloffson.pdb");
  foreach my $line(@header){ 
    print WYN "$line\n";  
  }
  foreach my $i (0..$#topsel){
    my $model=$topsel[$i];
    my $model2=$model.".2";
    my $mn=$i+1;
    `more $model | grep -v COMPND | grep -v CONECT | grep -v MASTER | grep -v ' H ' | grep -v BABEL | sed s/END/TER/ | egrep -v '^ ' > $model2 `;    
    my @complex=open_file(\$model2);
    print WYN "MODEL     $mn \n";
    foreach my $line(@receptor){print WYN "$line\n";}
    foreach my $line(@complex){print WYN "$line\n";}
    print WYN "ENDMDL\n";
  }
  print WYN "END\n";
  close (WYN);
}

# open a file with the file name as input
sub open_file{
  my ($file_name)=@_;
  open(INP1, "< $$file_name") or die "Can not open an input file: $!";
  my @file1=<INP1>;
  close (INP1);
  chomp @file1;
  return @file1;
}                                              

#copy files on the list from directory 
sub copy_selected{
  my ($file,$top,$dir1,$dir2)=@_;
  my ($pdb,$pdb2);
  my $list=$$file;
  my $path1=$$dir1;
  my $path2=$$dir2."-top".$$top;
  mkdir "$path2" unless (-d $path2); 
  my @files=open_file(\$list);
  for my $i (0..$$top){
    my $lin=$files[$i];
    my @data=split(/\s+/,$lin); 
    if($data[0]=~/\//){
      $pdb=substr($data[0],index($data[0],"/")+1);
      $pdb2=$i."-".$pdb;
      #print "$pdb\n";
    }
    copy("$path1/$pdb","$path2/$pdb2")
  }
}

#sort scores produced by caprice.pl
sub sort_scores{
  my ($file)=@_;
  my $scoref=$$file;
  my $out=$scoref.".sort";
  `sort -rn -k2,2 $scoref >$out`;
}

#prepare vmd session
sub load_to_vmd{
  my ($files,$listf)=@_;
  my @list=@{$files};
  my $new=$$listf.".tcl";
  open (VMD, ">$new");
  print VMD "mol new $list[0] type pdb\n";
  for my $i (0..$#list){ 
    print VMD "mol addfile $list[$i] type pdb\n";
  }
}

#prepare pymol session
sub load_to_pymol{
  my ($files,$listf)=@_;
  my $new=$$listf.".pml";
  open (PYMOL, ">$new");
  print PYMOL "run /usr/local/lib/pymol/load_models.py\n";
  foreach my $model(@{$files}){
    print PYMOL "load_models $model, sel_models\n"; 
    print PYMOL "load $model\n"; 
  }
}

#prepare multipdb file
sub get_multipdb{
  #wher to do that? in original folders or on copy?
  #set paths etc.
  `more capri18-lig_m.pdb.* | grep -v CONECT | grep -v MASTER | grep -v ' H ' | grep -v BABEL | sed 's/END/ENDMDL/g' > multi_pdb_111.pdb`;
}

#run g_cluster
sub gmx_cluster{
  my ($traj,$topol,$g_clust_cutoff,$clust_m,$min_str,$write_cutoff)=@_;
  my $trajectory=$$traj;
  my $topology=$$topol;
  my $cutoff=$$g_clust_cutoff;
  my $method=$$clust_m;
  my $mins=$$min_str;
  my $wcutoff=$$write_cutoff;
  `g_cluster -f $trajectory -s $topology -cutoff $cutoff -method $method -minstruct $mins -rmsmin $wcutoff`;
}

