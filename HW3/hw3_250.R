### STA 250 - HW 3
### Eliot Paisley
### 11/27/13
##################

setwd("C:/Users/EliotP/Google Drive/sta 250 - f13/") #laptop
library(xtable)

### bisection method.
### arguments are:
### function to find roots of, initial lower and upper bounds, tolarance, and max. number of iterations

bisect= function(func, lower, upper, tol=1e-07, niter = 1000, ...) { 
        l = lower
        u = upper
        func_low = func(lower, ...) 
        func_high = func(upper, ...) 
        f_eval = 2 
        
        if (func_low * func_high > 0) stop 
        change = upper - lower 
        
        while (abs(change) > tol) { 
          x_new = (lower + upper) / 2 
          f_new = func(x_new, ...) 
          if (abs(f_new) <= tol) break 
          if (func_low * f_new < 0) upper = x_new 
          if (func_high * f_new < 0) lower = x_new 
          change = upper - lower 
          f_eval = f_eval + 1 
        } # end while loop
        list(x = x_new, value = f_new, fevals=f_eval, l =l,u = u ) 
} # end bisect function

### Newton Raphson method/
### arguments are:
### first derivative, second derivative, initial guess, tolerance, and max. number of iterations

newton = function(D, DD, initial, tol=1e-6, niter=20){
          int = initial # inital guess to report at end
          theta = initial # initial theta
          out = matrix(NA, nrow=niter+1,ncol=4) #create matrix for the output
          val = D(initial) # goal is to arrive at val = 0
          out[1,] = c(initial,val,niter,int)
          
          i = 1
          continue = T
          while (continue) {
            i = i+1
            theta.old = theta
            theta = theta - D(theta)/DD(theta) ## NR update
            
            val = D(theta)
            out[i,] = c(theta,val,i,int)
            continue = (abs(theta-theta.old) > tol) &&
              (i <= niter)
          }
          if (i > niter) { 
            warning("Maximum number of iterations reached")
            return(out)
          }
          out = out[!is.na(out[,1]),]
          out
} # end NR function


### classic linkage problem
### approximate likelihood

like = function(x){ (2+x)^125*(1-x)^38*x^34}
# take log to simplify
# max will still occur at same point
log_like = function(x){ 125*log(2+x) + 38*log(1-x) + 34*log(x)}
# take first derivative
log_like_D = function(x){ 125/(2+x)- 38/(1-x) + 34/x}
# take second derivative
log_like_DD = function(x){ -125/(2+x)^2- 38/(1-x)^2 - 34/x^2}

# max visually found somewhere near 0.6, local max around -0.5

png("like.png")
par(mfrow=c(2,1))
plot(like,xlim=c(0,1),ylab="Likelihood",xlab=expression(paste(lambda)),main="Classic Linkage Problem")
plot(like,xlim=c(-1,0),ylab="Likelihood",xlab=expression(paste(lambda)),main="Classic Linkage Problem")
dev.off()

# roots visually identified somewhere in (-1, 0) and (0,1)  
png("loglikeD.png")
plot(log_like_D, xlim = c(-3,3),ylab="Log-Likelihood",xlab=expression(paste(lambda)),main="Classic Linkage Problem (first derivative)")
abline(h=0,col="RED")
dev.off()


# set very small offset to avoid infinities
epsilon = 0.0001

###### search for roots using bisection
#######################################

# first interval, results in root at x = -0.5506794
one = bisect(log_like_D, -2+epsilon,0-epsilon)
# first interval, results in root at x = 0.6268215
two = bisect(log_like_D, 0 +epsilon, 1-epsilon)

png("bisect.png")
plot(like,xlim=c(-1,1),ylab="Likelihood",xlab=expression(paste(lambda)),main="Classic Linkage Problem (w/ Bisection Roots)")
points(x = one$x, y = like(one$x), lwd =5, col="RED", pch =4 )
points(x = two$x, y = like(two$x), lwd =5, col="RED", pch =4 )
dev.off()
t = t(as.table(unlist(one),digits=3))
tt = t(as.table(unlist(two),digits=3))
colnames(t) = c("Root", "Value","Iterations","Int. Low", "Int. Upp")       
colnames(tt) = c("Root", "Value","Iterations","Int. Low", "Int. Upp")       
print(xtable(rbind(t,tt)),include.rownames=FALSE)

##### search for roots using Newton-Raphson
###########################################

newt1 = newton(log_like_D, log_like_DD,initial= -0.55,niter=500,tol=1e-7)
newt2 = newton(log_like_D, log_like_DD,initial=  0.40,niter=500,tol=1e-7)
newt3 = newton(log_like_D, log_like_DD,initial=  0.60,niter=500,tol=1e-7)

colnames(newt1) = c("Root", "Value", "Iteration", "Initial")
ttt = rbind(t(as.table(newt1[nrow(newt1),])),t(as.table(newt2[nrow(newt2),])),t(as.table(newt3[nrow(newt3),])))
print(xtable(ttt),include.rownames=FALSE)

png("newton.png")
plot(like,xlim=c(-1,1),ylab="Likelihood",xlab=expression(paste(lambda)),main="Classic Linkage Problem (w/ NR Root)")
points(x = newt3[nrow(newt3),1], y = like(newt3[nrow(newt3),1]), lwd =5, col="RED", pch =4 )
dev.off()
