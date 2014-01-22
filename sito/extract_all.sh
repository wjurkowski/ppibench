mkdir all_clusters_pdb
cut -d " " -f2-3 clusters >clust.tmp
while read F ; do
numer=${F%" "*}
nazwa=${F#*" "}
nowa="$numer-$nazwa"
cp models/$nazwa all_clusters_pdb/$nowa
done < clust.tmp
rm -f clust.tmp
