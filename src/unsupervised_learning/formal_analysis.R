setwd("C:\\work\\internship\\COMP4710-Group-11\\src\\unsupervised_learning")
library("klaR")
# we will apply this same analysis on the other datasets


kenya <- read.csv("../../KenyaData.csv", colClasses = "factor")
##apply k-mode or k-prototype clustering on the data
dim(kenya)
names(kenya)


#remove the first column in kenya dataset #remove the living-with feature
kenya <- kenya[,-c(1,6)]
symptoms <- kenya[,-c(1,2,3,4)]

# count frequencies for all the symptoms
# curse of dimension: remove those for which the frequency is <= 31; use a subset of features 

freqs <- vector(mode = "numeric")
omit_vec <- vector(mode="numeric")
omit2 <- vector(mode="numeric")
omit3 <- vector(mode="numeric")

for(i in 5:ncol(kenya)){
  summ <- sum(as.numeric(as.character(kenya[,i])))
  #print( summ )
  freqs <- append(freqs, summ )
  if( summ == 0 ){
    omit_vec <- append(omit_vec, i)
  }
  
  if(summ <= 31){ ##threshold: %5
    omit2 <- append(omit2, i)
  }
  if(summ < 200){
    omit3 <- append(omit3, i)
  }
}
omit_vec
omit2
omit3

## remove those features that have 0 cases (or more cases is proper like <= 5% of the all cases)
kenya1 <- kenya[,-omit_vec]
kenya2 <- kenya[,-omit2]
kenya3 <- kenya[,-omit3] ##only fatigue and headache

## and check relations with the age/gender: are the clusters generally fit the subgroups?
## if so, what are the representative feature vector[ave, ave, ave3], a bunch of freq averages of each cluster/subgroup?
## make combination of age/gender, make vector of [freq1, freq2, ...], then do the spectrum analysis cosine/
## there are 2 * 3 = 6 combinations of age/gender
dff <- kenya1
dff$age_gender <- paste(dff$Age, dff$Gender, sep="_")

## count those sub types
table(dff$age_gender)
subtypes <- unique(dff$age_gender)

all_sigs <- matrix(NA, nrow=0, ncol=38)
for(i in 1:length(subtypes)){
  tmp <- dff[dff$age_gender == subtypes[i],]
  tmp_freqs <- vector(mode="numeric")
  for(j in 5:42){
    tmp_freqs <- append(tmp_freqs, mean(as.numeric(as.character(tmp[,j]))))
  }
  all_sigs <- rbind(all_sigs, tmp_freqs)
}
colnames(all_sigs) <- names(kenya1)[5:42]
row.names(all_sigs) <- subtypes

## instead we make two bar charts: gender ; age(50)
age_df <- kenya1[,-c(1,2,4)]
age_df$age_50 <- 0
for(i in 1:nrow(kenya1)){
  if(as.character(kenya1$Age[i])==">50"){
    age_df$age_50[i] = 1
  }
}
age_df <- age_df[,c(40, c(2:39))]
age_df$age_50[age_df$age_50==0] <- "<=50"
age_df$age_50[age_df$age_50 != "<=50"] <- ">50"

gender_df <- kenya1[,-c(1,3,4)]

library("ggplot2")
library("reshape")
library("scales")

bar_plot <- function(df, label, num1, num2){
  #df <- gender_df
  unames <- unique(as.character(df[,1]))
  df2 <- matrix(0, nrow=2, ncol=38)
  for(i in 1:nrow(df)){
    for(j in 2:ncol(df)){
      value <- as.numeric(as.character(df[i,j]))
      if(df[i,1] == unames[2]){
        df2[2,j-1] = df2[2,j-1] + value
      }else{
        df2[1,j-1] = df2[1,j-1] + value
        
      }
    }
  }
  #xx <- table(as.character(df[,1]))
  df2[1,] <- df2[1,]/num1
  df2[2,] <- df2[2,]/num2
  df2 <- t(df2)
  df2 <- cbind(df2, c(1:38))
  df2[,3] <- abs( df2[,1] - df2[,2] )
  row.names(df2) <- names(df)[2:39]
  colnames(df2) <- c(unames, "diff")
  df2 <- df2[order(df2[,3], decreasing = FALSE),]
  df2 <- as.data.frame(df2)
  df2$symptom <- row.names(df2)
  df3 <- reshape(df2, direction = "long", varying = list(1:2),
                idvar = names(df2)[4], timevar = label,
                times=names(df2)[c(1,2)], v.names = "percentage" )
  
  df3$symptom <- factor(df3$symptom, levels = unique(df3$symptom))
  
  ggplot(data=df3, aes(x=symptom, y=percentage, fill=factor(df3[,3]), )) +
    geom_bar(position="dodge",stat="identity") +
    coord_flip() + 
    ggtitle( paste("","symptoms percentage") ) + 
    theme_bw() +   
    scale_x_discrete(
      limits=unique(df2$symptom), 
      labels=unique(df2$symptom)
    )  + 
    scale_fill_discrete(
      name=label,
      labels= names(df2)[c(1,2)]
    ) +  
    theme(
      legend.position=c(.83,.3),
      axis.title.y=element_blank(), 
      text=element_text(family="serif",size=15),
      plot.title=element_text(face="bold",hjust=0.5)
    )
  
}

bar_plot(age_df, "age", 602, 75) #<=50 and >50
bar_plot(gender_df, "gender", 352, 325) #male and female


#cosine similarity between two vectors
cosine_sim <- function(vec1, vec2){
  dot_prod <- sum(vec1 * vec2)
  norm1 <- sqrt(sum(vec1^2))
  norm2 <- sqrt(sum(vec2^2))
  return(dot_prod / (norm1 * norm2))
}


## heatmap, cosine-similarity matrix for the 6 subtypes
sim_matr <- matrix(0, nrow = 6, ncol = 6)
for(i in 1:6){
  vec1 <- t(all_sigs[i,])
  for(j in 1:6){
    vec2 <- t(all_sigs[j,])
    sim <- cosine_sim(vec1, vec2)
    sim_matr[i,j] = sim
  }
}

row.names(sim_matr) <- subtypes
colnames(sim_matr) <- subtypes
heatmap(sim_matr, keep.dendro = FALSE, Rowv=NA, Colv = NA, margin=c(10,10))
write.csv(as.data.frame(sim_matr),"6_age_gender_subgroup.csv", quote = FALSE)


## significant different between < 50 and > 50 groups; present with a table
## gender: no significant differences 


## prediction, given a new instance of age/gender, give the probability vector that he/she will develop some symptoms: use the vector??
## compute the similarity 

## group signature similarity matrix; given some .. states, the probability of developing
## the group-related signature symptoms is:



## use a subset of features to optimize the number of groups:
#first kenya2: freq > 5%
set.seed("2022112602")
wss <- sapply(1:15, function(k){
  sum(kmodes(kenya2[,-c(1:4)], k, iter.max = 100, weighted = TRUE)$withindiff)
})

plot(1:15, wss, type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares" )

## optimal: 7 clusters

## PLAN of next-step-work:
# now it seems ten clusters are good (a good kink point)
#weighted: whether the features is weighted by its frequency
result <- kmodes(kenya2[,-c(1:4)], 7, iter.max = 100, weighted = TRUE) #or true??
print(result)

# report cluster size; cluster modes; and maybe within-cluster distance
write.csv(as.data.frame(result$modes),"7clusters_modes.csv", quote = FALSE)
result$cluster


## checking the overlapping:
subtypes2 <- unique(as.character(dff$Age))
clus_matr <- matrix(0, nrow=7, ncol=3)
#result$cluster
for(i in 1:nrow(kenya2)){
  cluster <- result$cluster[i]
  col <- which(subtypes2 == dff$Age[i])
  clus_matr[cluster,col] = clus_matr[cluster,col] + 1
}
colnames(clus_matr) <- subtypes2
write.csv(as.data.frame(clus_matr),"7clusters_age_group.csv", quote = FALSE)


## use use fewer clusters, visualize?
result <- kmodes(kenya3[-c(1:4)], 2, iter.max = 200, weighted = TRUE) #or true??
print(result)
result$cluster



#no obvious overlapping, because the freqs are not high for every sub group

## EVEN no overlapping with age divisions: try to modify to data with 2 age groups and 
## then classify. With less features!
## subgroup signature: vector of percentages
##now we try to group 2 clusters and compare with < 50 > 50 age groups: no overlapping found


## also validate this result by using PAM clustering

## instead we choose a kink point to avoid to many clusters: we choose k=7
## does the intrinsic group overlap with the clustering algorithm result? NO


## how to make this unsupervised model "predictable"? so, for a new instance, we are
## going to assign it to a cluster we have built, and report the most prominent symptom for this cluster?
## i.e. the representative feature of this cluster?



# for each age/gender group, see the frequencies map for all the symptoms


##For employed/Living with feature, see the freq map for all the symptoms



## based on a new instance's age, gender, ..., report what are the most likely symptoms that will be developed.


## the most different feature between gender/age groups ; feature ranking for diff


## statistical difference test between the two countries
