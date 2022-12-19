setwd("C:\\work\\internship\\COMP4710-Group-11\\src\\unsupervised_learning")
library("klaR")
# we will apply this same analysis on the other datasets


kenya <- read.csv("../../KenyaData.csv", colClasses = "factor")
malawi <- read.csv("../../MalawiData.csv", colClasses = "factor")

##apply k-mode or k-prototype clustering on the data
dim(kenya)
names(kenya)
dim(malawi)
names(malawi)

print(setdiff(names(kenya), names(malawi)))
print(setdiff( names(malawi), names(kenya) ))

kenya <- kenya[,-c(42:49)]
##combine the data
kenya <- rbind(kenya, malawi)
#kenya$Age%<>%as.factor()%>%recode_factor(.,`>50` = "more_than_50")
kenya$Employed%<>%as.factor()%>%recode_factor(.,`0` = "no", `1`="yes")

#remove the first column in kenya dataset #remove the living-with feature
#kenya <- kenya[,-c(1,6)]
symptoms <- kenya[,-c(1,2,3,4,5,6)]

# count frequencies for all the symptoms
# curse of dimension: remove those for which the frequency is <= 31; use a subset of features 

freqs <- vector(mode = "numeric")
omit_vec <- vector(mode="numeric")
omit2 <- vector(mode="numeric")
omit3 <- vector(mode="numeric")

for(i in 7:ncol(kenya)){
  summ <- sum(as.numeric(as.character(kenya[,i])))
  #print( summ )
  freqs <- append(freqs, summ )
  if( summ == 0 ){
    omit_vec <- append(omit_vec, i)
  }
  
  if(summ <= 67){ ##threshold: %5
    omit2 <- append(omit2, i)
  }
  if(summ < 200){
    omit3 <- append(omit3, i)
  }
}
omit_vec
omit2
omit3

#barplot(freqs/nrow(kenya))
freqs <- freqs / nrow(kenya)
df_frq <- data.frame(symptoms=names(kenya)[7:41], frequency=freqs)
df_frq <- df_frq[order(df_frq$frequency, decreasing = FALSE),]
df_frq$symptoms <- factor(df_frq$symptoms, levels = df_frq$symptoms)

ggplot(data=df_frq, aes(x=symptoms, y=frequency )) +
  geom_bar(position="dodge",stat="identity", fill="#cc0033") +
  geom_text(aes(label= round(df_frq$frequency, 3), hjust=-0.2), size = 3) +
  coord_flip() + 
  ggtitle( paste("","symptoms occurrence") ) + 
  theme_bw() +   
  scale_x_discrete(
    #limits=unique(df2$symptom), 
    labels=df_frq$symptoms
  )  + 
  theme(
    #legend.position=c(.83,.3),
    axis.title.y=element_blank(), 
    text=element_text(family="serif",size=13),
    plot.title=element_text(face="bold",hjust=0.5)
  )
ggsave("./all_freqs.png",device="png", width = 11, height=8)


## remove those features that have 0 cases (or more cases is proper like <= 5% of the all cases)
kenya1 <- kenya[,-omit_vec]
kenya2 <- kenya[,-omit2]
kenya3 <- kenya[,-omit3] ##only fatigue and headache

## and check relations with the age/gender: are the clusters generally fit the subgroups?
## if so, what are the representative feature vector[ave, ave, ave3], a bunch of freq averages of each cluster/subgroup?
## make combination of age/gender, make vector of [freq1, freq2, ...], then do the spectrum analysis cosine/
## there are 2 * 3 = 6 combinations of age/gender


library("ggplot2")
library("reshape")
library("scales")

bar_plot <- function(df, label){
  #df <- age_df
  unames <- unique(as.character(df[,1]))
  nums <- vector(mode="numeric")
  for(i in 1:length(unames)){
    nums <- append(nums, length(which(df[,1]==unames[i])))
  }
  
  df2 <- matrix(0, nrow=length(unames), ncol=ncol(df)-1)
  for(i in 1:nrow(df)){
    for(j in 2:ncol(df)){
      value <- as.numeric(as.character(df[i,j]))
      index <- which(unames == as.character(df[i,1]) )
      df2[index, j-1] = df2[index, j-1] + value
    }
  }
  
  row.names(df2) <- unames 
  colnames(df2) <- names(df)[2:ncol(df)]
  
  #compute the chi-square statistics
  chi_res <- chi_test(df2, nums)
  
  #xx <- table(as.character(df[,1]))
  for(i in 1:nrow(df2)){
    df2[i,] <- df2[i,]/nums[i]
  }
  df2 <- t(df2)
  df2 <- cbind(df2, chi_res)
  #df2 <- cbind(df2, c(1:32))
  #df2[,3] <- abs( df2[,1] - df2[,2] )

  df2 <- df2[order(df2[,ncol(df2)], decreasing = TRUE),]
  df2 <- as.data.frame(df2)
  df2$symptom <- row.names(df2)
  df2 <- df2[df2$chi_res <= 0.05,]
  
  df3 <- reshape(df2, direction = "long", varying = list(1:length(nums) ),
                idvar = names(df2)[ncol(df2)], timevar = label,
                times=names(df2)[ c(1:length(nums)) ], v.names = "percentage" )
  
  df3$symptom <- factor(df3$symptom, levels = unique(df3$symptom))
  
  pic <- ggplot(data=df3, aes(x=symptom, y=percentage, fill=factor(df3[,3]), )) +
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
      labels= names(df2)[c(1:length(nums))]
    ) +  
    theme(
      #legend.position=c(.83,.3),
      axis.title.y=element_blank(), 
      text=element_text(family="serif",size=15),
      plot.title=element_text(face="bold",hjust=0.5)
    )
  df2 <- df2[order(df2[,ncol(df2)-1], decreasing = FALSE),]
  write.csv(df2, paste(label,"significant_features_chisqrt.csv", sep="_"), quote = FALSE)
  
  return(list(pic, df2))
}


chi_test <- function(df2, nums){
  pvalues <- vector(mode="numeric")
  for(i in 1:ncol(df2)){
    tab <- data.frame()
    tab <-  cbind(df2[,i], nums-df2[,i])
    names(tab) <- c("has_symp", "not_have")
    xsq <- chisq.test(tab)
    pvalues <- append(pvalues, xsq$p.value)
  }
  return(pvalues)
}

## instead we make two bar charts: gender ; age(50); country, social stage
## for each of the subtypes, compute the chi square and p=0.05?, and plot, make table of the statistics
age_df <- kenya1[,-c(1,2,3,5,6)]
age_df$age_50 <- 0
for(i in 1:nrow(kenya1)){
  if(as.character(kenya1$Age[i])==">50"){
    age_df$age_50[i] = 1
  }
}
age_df <- age_df[,c(34, c(2:33))]
age_df$age_50[age_df$age_50==0] <- "<=50"
age_df$age_50[age_df$age_50 != "<=50"] <- ">50"

gender_df <- kenya1[,-c(1,2,4,5,6)]
country_df <- kenya1[,-c(2,3,4,5,6)]
live_tp_df <- kenya1[,-c(1,3,4,5,6)]
employ_df <- kenya1[,-c(1,2,3,4,6)]
live_with_df <- kenya1[!is.na(kenya1$Living.With), -c(1,2,3,4,5,9)]

age_res <- bar_plot(age_df, "age") #<=50 and >50
#print(age_res[[1]])
gender_res <- bar_plot(gender_df, "gender") #male and female
country_res <- bar_plot(country_df, "country")
live_tp_res <- bar_plot(live_tp_df, "living_type")
employ_res <- bar_plot(employ_df, "employed")
live_with_res <- bar_plot(live_with_df, "living_with")
grid.arrange(age_res[[1]], gender_res[[1]], country_res[[1]],  employ_res[[1]], live_with_res[[1]],live_tp_res[[1]], ncol=2)

## similarity among the subgroups
dff <- kenya2
dff$age_gender <- paste(dff$Age, dff$Gender, sep="_")

## count those sub types
table(dff$age_gender)
subtypes <- unique(dff$age_gender)

all_sigs <- matrix(NA, nrow=0, ncol=15)
for(i in 1:length(subtypes)){
  tmp <- dff[dff$age_gender == subtypes[i],]
  tmp_freqs <- vector(mode="numeric")
  for(j in 7:21){
    tmp_freqs <- append(tmp_freqs, mean(as.numeric(as.character(tmp[,j]))))
  }
  all_sigs <- rbind(all_sigs, tmp_freqs)
}
colnames(all_sigs) <- names(kenya2)[7:21]
row.names(all_sigs) <- subtypes
all_sigs <- round(all_sigs, 3)
write.csv(as.data.frame(all_sigs),"occurrence_percentages.csv", quote = FALSE)


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
write.csv(round(as.data.frame(sim_matr),3),"6_age_gender_subgroup.csv", quote = FALSE)


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
  sum(kmodes(kenya2[,-c(1:6)], k, iter.max = 100, weighted = TRUE)$withindiff)
})

plot(1:15, wss, type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares" )

## optimal: 7 clusters; 11 clusters

## PLAN of next-step-work:
# now it seems ten clusters are good (a good kink point)
#weighted: whether the features is weighted by its frequency
result <- kmodes(kenya2[,-c(1:6)], 11, iter.max = 100, weighted = TRUE) #
print(result)

# report cluster size; cluster modes; and maybe within-cluster distance
write.csv(as.data.frame(result$modes),"7clusters_modes.csv", quote = FALSE)
result$cluster


## checking the overlapping:
subtypes2 <- unique(as.character(dff$Age))
clus_matr <- matrix(0, nrow=11, ncol=3)
#result$cluster
for(i in 1:nrow(kenya2)){
  cluster <- result$cluster[i]
  col <- which(subtypes2 == dff$Age[i])
  clus_matr[cluster,col] = clus_matr[cluster,col] + 1
}
colnames(clus_matr) <- subtypes2
write.csv(as.data.frame(clus_matr),"7clusters_age_group.csv", quote = FALSE)


## use use fewer clusters, visualize?
result <- kmodes(kenya3[-c(1:6)], 2, iter.max = 200, weighted = TRUE) #or true??
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



## then analyze the malawi dataset






