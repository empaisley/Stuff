# create a matrix of 10 rows x 2 columns
m <- matrix(c(1:10, 11:20), nrow = 10, ncol = 2)
# mean of the rows
apply(m, 1, mean)
# mean of the columns
apply(m, 2, mean)
# divide all values by 2
apply(m, 1:2, function(x) x/2)
apply(m, c(1,2), function(x) x/2)


attach(iris)
head(iris)

# get the mean of the first 4 variables, by species
# won't work, why? by(iris[, 1:2], Species, mean)
?by
by(iris[ , 1:2], Species, mean)

# create a list with 2 elements
l = list(a = 1:10, b = 11:20)
# the mean of the values in each element
lapply(l, mean)
r = cbind(lapply(l, mean)$a, lapply(l, mean)$b)
rr = sapply(l,mean)

class(r)
class(rr)