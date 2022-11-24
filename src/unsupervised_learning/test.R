setwd("C:\\work\\internship\\COMP4710-Group-11\\src\\unsupervised_learning")
library("klaR")

kenya <- read.csv("../../KenyaData.csv", colClasses = "factor")
malawi <- read.csv("../../MalawiData.csv" , colClasses = "factor")


##apply k-mode or k-prototype clustering on the data
dim(kenya)
names(kenya)


#remove the first column in kenya dataset
kenya <- kenya[,-1]
kenya <- kenya[,-5]

## go with kenya data first
result <- kmodes(kenya, 5, iter.max = 200, weighted = FALSE)
print(result)

## optimize the number of clusters based on the Elbow method
## the metric is within-clusters differance 
wss <- sapply(1:20, function(k){
                    sum(kmodes(kenya, k, iter.max = 100, weighted = FALSE)$withindiff)
                                })

plot(1:20, wss, type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares" )

## but now it seem there are too many clusters optimized, because even with #clusters = 20,
## the trend of decreasing of withindiff is still there

## try with another method, but not good
#require(VarSelLCM)
#out <- VarSelCluster(kenya, 1:10, vbleSelec = FALSE)
#summary(out)
#VarSelShiny(out)




## maybe we can use only the symptom for clustering, then try to see the relations with 
## age/gender/... features





## how to make this unsupervised model "predictable"? so, for a new instance, we are
## going to assign it to a cluster we have built, and report the most prominent symptom for this cluster?
## i.e. the representative feature of this cluster?









