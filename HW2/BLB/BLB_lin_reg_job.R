### STA 250 - HW 2 - Problem 1. Bag of Little Bootstraps
### Eliot Paisley - 11/13/13
########################################################

### preliminaries
#################

# load packages
library(BH)
library(bigmemory.sri)
library(bigmemory)
library(biganalytics)

# set paths
#datapath = "/home/pdbaines/data/"
#outpath = "output/"

# set number of subsamples (s), and bootstrap samples (r)
s = 5           
r = 50          

### setup for Gauss

args = commandArgs(TRUE)

cat("Command-line arguments:\n")
print(args)

### sim_start <- 1000
#####################

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

# Some checks that go into the .out file
cat(paste("\nAnalyzing dataset number ",sim_num,"...\n\n",sep=""))
cat(paste("\nRunning s_index ",s_index," r_index ",r_index," seed ",sim_seed," job.num ",job.num,"...\n\n",sep=""))


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

# Check the weights
#outfile = paste0("dump/","BLB_bootstrap_weights_",sprintf("%02d",s_index),"_",sprintf("%02d",r_index),".txt")
#write.table(x=data.weights,file=outfile, sep=",", col.names=TRUE, row.names=FALSE)

# fit linear regression and extract coefficients
model = lm(Y.sub.sample ~ 0 + X.sub.sample, weights=data.weights)
beta.hat = model$coefficients

# output file
outfile = paste0("output/","coef_",sprintf("%02d",s_index),"_",sprintf("%02d",r_index),".txt")

# save estimates to file
write.table(x=beta.hat,file=outfile, sep=",", col.names=TRUE, row.names=FALSE)

cat("done. :)\n")

q("no")
