### STA 250 - HW 2
### Eliot Paisley - 11/13/13
############################


### Problem 1: Bag of Little Bootstraps
######################################

# credit to Michael Bissell for help with this code. 

### preliminaries
#################

# load packages
library(BH)
library(bigmemory.sri)
library(bigmemory)
library(biganalytics)


# set number of subsamples (s), and bootstrap samples (r)
s = 5           
r = 50          

### setup for Gauss

args = commandArgs(TRUE)

cat("Command-line arguments:\n")
print(args)

sim_start <- 1000

if (length(args)==0){
  sim_num <- sim_start + 1
  set.seed(121231)
} else {
  
  sim_num <- sim_start + as.numeric(args[1])
  
  job.num = as.numeric(args[1])
  
  # get the s_index  
  s_index = job.num %% s
  if (s_index == 0){
    s_index = s
  }
  
  # get the r_index   
  r_index = ceiling(job.num / s)
  if (r_index == 0){
    r_index = r
  }
  
  # first seed needs tp be a function s_index to ensure that subsample is the same for each value of the s_index
  sim_seed <- (762*(s_index) + 121231)
  set.seed(sim_seed)
}


### simulation
##############


# attach data with big.matrix
data.full = attach.big.matrix("/home/pdbaines/data/blb_lin_reg_data.desc")

# remaining setup 
# sample b points from n without replacement

n = nrow(data.full)     
d = dim(data.full)[2]-1 
gamma = 0.7
b = ceiling(n^gamma)    

# extract the same subset for each b
row.indices = sample(1:n, size=b, replace=FALSE)
X.sub.sample = data.full[row.indices,1:d]
Y.sub.sample = data.full[row.indices,d+1]

outfile = paste0("dump/","BLB_sample_indices_",sprintf("%02d",s_index),"_",sprintf("%02d",r_index),".txt")
write.table(x=cbind(sim_seed,row.indices),file=outfile, sep=",", col.names=TRUE, row.names=FALSE)

# reset simulation seed
sim_seed <- (877*(s_index) + 323232 + r_index)
set.seed(sim_seed)

# bootstrap dataset
data.weights = rmultinom(1, size = n, rep(1/b, b))

# fit linear regression and extract coefficients
model = lm(Y.sub.sample ~ 0 + X.sub.sample, weights=data.weights)
beta.hat = model$coefficients

# output file
outfile = paste0("output/","coef_",sprintf("%02d",s_index),"_",sprintf("%02d",r_index),".txt")

# save estimates to file
write.table(x=beta.hat,file=outfile, sep=",", col.names=TRUE, row.names=FALSE)

q("no")


### index plot
##############
blb_post_data = read.table("~/GitHub/Stuff/HW2/BLB/final/blb_lin_reg_data_s5_r50_SE.txt", header=T, quote="\"")

pdf("index_plot.pdf")
plot(as.matrix(blb_post_data),ylab = expression(paste("SE(", hat(beta),")")),main = "Index Plot of the SE's ")
dev.off()

############################################################################################
############################################################################################
############################################################################################
############################################################################################



############################
### Q2 --- MAPREDUCE CODE
############################

##### mapper.py #####

#!/usr/bin/env python

import sys

for line in sys.stdin:
  
  # remove leading and trailing whitespace
  line = line.strip()
# split x and y values apart
line = line.split()

# x and y were split as a list of two elements.
# need to convert to floats and designate which element is x and which is y.
x = map(float,line)[0]
y = map(float,line)[1]

# create upper and lower bounds for each bin, separated by 0.1

if x-round(x,1) < 0.0:
  x_hi = round(x,1)
x_lo = round(round(x,1) - 0.1,1)
else:
  x_lo = round(x,1)
x_hi = round(round(x,1) + 0.1,1)

if y-round(y,1) < 0.0:
  y_hi = round(y,1)
y_lo = round(round(y,1) - 0.1,1)
else:
  y_lo = round(y,1)
y_hi = round(round(y,1) + 0.1,1)


print '%s;%s;%s;%s;%s' % (x_lo,x_hi,y_lo,y_hi,1)

###########################################################3

##### reducer.py #####

#!/usr/bin/env python

import sys

current_word = None
current_count = 0
word = None

for line in sys.stdin:
  line = line.strip()
# split from the right, taking the right-most element to be the count (value)
line = line.rsplit(';',1)
word = line[0]
count = line[1]
try:
  count = int(count)
except ValueError:
  continue
if current_word == word:
  current_count += count
else:
  if current_word:
  # write result to STDOUT
  print '%s\t%s' % (current_word, current_count)
current_count = count
current_word = word
if current_word == word:
  print '%s\t%s' % (current_word, current_count)

############################
### Q2 --- MAPREDUCE RESULTS
############################
setwd("~/GitHub/Stuff/HW2/Streaming/")

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


############################################################################################
############################################################################################
############################################################################################
############################################################################################


#######################
### Q3 --- HIVE CODE
#######################

## credit to Teresa Filshtein for helping develop this code
## first, create new folders for the process and give permissions
$ hadoop fs -mkdir /tmp
$ hadoop fs -mkdir /user/hive/warehouse
$ hadoop fs -chmod g+w /tmp
$ hadoop fs -chmod g+w /user/hive/warehouse 

## load data From the bucket

$ hadoop fs -mkdir input
$ hadoop distcp s3://sta250bucket/groups.txt input

## once in Hive, we start by creating a new table (arbitrarily named 'sonic')

hive> CREATE TABLE sonic(group INT, value DOUBLE)	
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

## load data from hadoop to Hive 
hive> LOAD DATA INPATH '/user/hadoop/input/groups.txt' OVERWRITE INTO TABLE sonic;

## compute means and variances, and put results in the HDFS directory 'finalsummary'
hive> INSERT OVERWRITE DIRECTORY '/user/hadoop/output/finalsummary/'
> SELECT group, avg(value), variance(value) FROM sonic
> GROUP by group;

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
