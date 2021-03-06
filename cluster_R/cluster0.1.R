#! /usr/bin/Rscript

# 2 Argument
# 1 : Rmsd input
# 2 : Cluster Output


args <- commandArgs(TRUE)
args


rmsd_in <- read.table(args [1])
#rmsd_in <- read.table("rmsd_example.txt")


matrix_size <- length(levels(factor(c(as.character(rmsd_in[,1]),as.character(rmsd_in[,2])))))

name_structure <- c(1:matrix_size)
names(name_structure) <- levels(factor(c(as.character(rmsd_in[,1]),as.character(rmsd_in[,2]))))

rmsd <- matrix(0,matrix_size,matrix_size)

for (i in 1:nrow(rmsd_in) ) {
	rmsd [  name_structure[[as.character(rmsd_in[i,1])]] ,name_structure[[as.character(rmsd_in[i,2])]] ]<- rmsd_in[i,3]
	rmsd [  name_structure[[as.character(rmsd_in[i,2])]] ,name_structure[[as.character(rmsd_in[i,1])]] ]<- rmsd_in[i,3]
}

library(cluster)

rownames(rmsd) <- names(name_structure)
cluster = agnes(rmsd, diss=T)
levels = cutree(cluster, k= args[3] )
#levels2 <- cutree(cluster, k = c(2,4))
levels2 <- cutree(cluster, k = 1:6)
#table(levels2[,"2"], levels2[,"4"])

names(levels) <- names(name_structure)
#for (i in 1:args[3] ) {
#for (i in 1:6 ) {
#	sum = 0
#	clust_list <- levels [levels == i]
#	for (j in 1:length (clust_list)) {
#		for (k in j:length (clust_list)) {
#			sum = sum + rmsd [[ name_structure [[names(clust_list[j])]], name_structure[[names(clust_list[k])]]]]
#		}	
#	}
#}


#rownames(levels) <- names(name_structure)

write.table(levels2, file=args [2], quote=F)

