sort -r -n -k5 $1 >$1-sorted
cut -d " " -f3 $1-sorted>files_tmp
mkdir clusters_pdb
while read i ; do cp models/$i clusters_pdb/ ;done <files_tmp
rm -f files_tmp
