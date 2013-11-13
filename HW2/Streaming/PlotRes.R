setwd("~/GitHub/Stuff/HW2/Streaming/")

############################
### Q2 --- MAPREDUCE RESULTS
############################

data = read.table('mapper_results.txt', header=FALSE,sep=";")

library(stringr)
b = do.call(rbind, str_split(data[,4],'\t'))

res = cbind(data[,1:3],as.numeric(b[,1]),as.numeric(b[,2]) )

# Make 2D Histogram:

x <- apply(res[,1:2],1,mean)
y <- apply(res[,3:4],1,mean)
z <- res[,5]

colvec <- terrain.colors(max(res[,5])+1)
mf <- 4
px <- 480*mf
png("hist2d.png",width=px,height=px)
plot(range(x),range(y),type="n",
     main="Bivariate Histogram: STA 250 HW2",
     xlab="x",ylab="y",
     cex.main=mf,cex.lab=mf,cex.axis=mf)
for (i in 1:nrow(res)){
  polygon(x=c(res[i,1],res[i,2],res[i,2],res[i,1]),
          y=c(res[i,3],res[i,3],res[i,4],res[i,4]),
          col=colvec[res[i,5]])
  if (i%%10000==0){
    cat(paste0("Finished row ",i,"\n"))
  }
}
dev.off()

#######################
### Q3 --- HIVE RESULTS
#######################

hive_data = read.table('hive_results.txt', header=FALSE,sep="\001")

x11()
pdf("hive_plot.pdf") 
plot(hive_data[,2], hive_data[,3], main="Result from HIVE", 
     xlab = "Within-Group Means", 
     ylab = "Within-Group Variances",
     col=rgb(100,0,0,50,maxColorValue=255), pch=16)
dev.off()

