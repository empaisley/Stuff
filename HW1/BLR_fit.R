#############################################

### for preliminary analysis on a single data set
#data = read.csv("C:/Users/EliotP/Google Drive/sta 250 - f13/HW1-Paisley/blr_data_1100.csv")
#beta =  as.matrix(read.csv("C:/Users/EliotP/Google Drive/sta 250 - f13/HW1-Paisley/blr_pars_1100.csv"))
###

### setup for processing 200 data sets
args = commandArgs(TRUE)

#######################
sim_start <- 1000
length.datasets <- 200
#######################

if (length(args)==0){
  sinkit <- FALSE
  jobid <- sim_start + 1
  set.seed(4242424)
} else {
  # Sink output to file?
  sinkit <- TRUE
  # Decide on the job number, usually start at 1000:
  jobid <- sim_start + as.numeric(args[1])
  # Set a different random seed for every job number!!!
  set.seed(762*jobid + 1330931)
  

data_path = "/home/paisley/Stuff/HW1/BayesLogit/data"
data = read.csv(paste0(data_path,"blr_data_",jobid, ".csv")
pars = read.csv(paste0(data_path,"blr_pars_",jobid, ".csv")
                
output_path = "/home/paisley/Stuff/HW1/BayesLogit/results"  
                
                
                
              
### libraries to be used                
library(MASS)
###
                
###posterior distribution (up to proportionality) 
post = function(beta, y, x, m, mu, Sigma){
    return(-0.5*t(beta-mu)%*%solve(Sigma)%*%(beta-mu) + t(y)%*%(x%*%beta) - t(m)%*%log(1+exp(x%*%beta)))
}

### data --- will change with each dataset
                y = as.matrix(data[,1])
                x = as.matrix(data[,3:4])
                m = as.matrix(data[,2])
###
                
### arbitraty starting values --- for all datasets
Sigma.0 = diag(2)
mu = c(1,1)
beta.0=c(0,0)

### our big function
                
"bayes.logreg" <- function(m,y,x,beta.0,Sigma.0,v=1,
                           niter=10000,burnin=5000,
                           print.every=1000,retune=100,
                           verbose=TRUE){
  
  n.accept.vec = matrix(0,niter+burnin,1) #int. acceptance vector
  v_tune = 1.5 # set tuning parameter for the variance of the proposal dist.
  beta_curr = beta.0 #
  Sigma = Sigma.0 # set first sigma to be identity (prev. defined )
  beta_samp = matrix(NA, niter+burnin, 2)#int. matrix of beta values 
  
  
  #Metropolis-Hastings burnin
  for(i in 1:burnin){
    beta_star = as.matrix(mvrnorm(1,beta_curr, v*Sigma)) #proposal beta
    alpha = min(1, post(m=m,y=y,x=x,mu=mu,Sigma=Sigma.0,beta=beta_star) 
                - post(m=m,y=y,x=x,mu=mu,Sigma=Sigma.0,beta=beta_curr)) 
  #  post(m=m,y=y,x=x,mu=mu,Sigma=Sigma.0,beta=beta_curr)
  #  post(m=m,y=y,x=x,mu=mu,Sigma=Sigma.0,beta=beta_star)
   
    U = log(runif(1))
      
    if (alpha>U) {
      beta_curr = beta_star 
      n.accept.vec[i] = 1
    }
    
    beta_samp[i,] = beta_curr
    
    if(!(i%%retune)){
      if(verbose){cat(paste("Proposal Variance:",v,"\n"))}
      pct1 = sum(n.accept.vec[(i-retune+1):i]) / retune
      if(verbose){cat(paste("Accpt Pct:",pct1,"\n"))}
      if (pct1 > 0.7) {v = v_tune*v}
        else{
            #if(verbose){cat(paste("Proposal Variance:", Sigma,"\n"))}
            if(pct1 < 0.3){v = v/v_tune}  
        }
    }

    } # end MH burnin
  
  
  #Metropolis-Hastings niter
  for(i in ((burnin+1):(niter+burnin))){
    if(!(i %% print.every)){cat(paste("Algorithm is", 100*(i)/(niter+burnin), "percent complete \n"))}
    beta_star = as.matrix(mvrnorm(1,beta_curr, v*Sigma)) #proposal beta
    
    alpha = min(1, post(m=m,y=y,x=x,mu=mu,Sigma=Sigma.0,beta=beta_star) 
                - post(m=m,y=y,x=x,mu=mu,Sigma=Sigma.0,beta=beta_curr))  
    U = log(runif(1))
    
    if (alpha >= U) {
      beta_curr = beta_star 
      n.accept.vec[i]=1
    }
    
    beta_samp[i,] = beta_curr
    
    
  } #end MH niter
  
  #par(mfrow=c(2,2))
  #plot(beta_samp[,1],beta_samp[,2],type="l")
  #plot(beta_samp[,1],type="l")                          
  #plot(beta_samp[,2],type="l")                          
  
  #return(cbind(n.accept.vec[1:burnin],beta_samp[1:burnin,], beta_star_vec[1:burnin,]))
  return(beta_samp)
  
  
  } # end function bayes.logreg

#run bayes.logreg, specifying data (m,y,x), in
a =bayes.logreg(m=m, y=y, x=x, beta.0=beta, Sigma.0 = Sigma.0, niter=10000, burnin=5000,v=1,retune=100)
                
probs = (1:99)/100
percentile_table = cbind(quantile(a[,1], probs), quantile(a[,2],probs))
write.csv(percentile_table,paste0(out_path,"Bayes_Logit_Percentiles_",jobib,".csv"),row.names=F, col.names=F)
                
q("no")                
                
