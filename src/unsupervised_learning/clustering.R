# symptoms-prevalence analysis and clustering for the Kenya and Malawi datasets


library("ggplot2")
library("reshape")
library("scales")
library("klaR")

setwd("C:\\work\\internship\\COMP4710-Group-11\\src\\unsupervised_learning")

# read in the datasets
kenya <- read.csv("../../KenyaData.csv", colClasses = "factor")
malawi <- read.csv("../../MalawiData.csv", colClasses = "factor")

# since kenya dataset contains 6 more features, which we need to delete
kenya <- kenya[,-c(42:49)]
##combine the data
kenya <- rbind(kenya, malawi)
# re-encode the variable "employed"
kenya$Employed%<>%as.factor()%>%recode_factor(.,`0` = "no", `1`="yes")

# the symptom features 
symptoms <- kenya[,-c(1,2,3,4,5,6)]

# count frequencies for all the symptoms
# omit some infrequent features for the similarity and clustering analysis
freqs <- vector(mode = "numeric")
omit_vec <- vector(mode="numeric") ## remove the 0-occurence features
omit2 <- vector(mode="numeric") ## remove the <5% infrequent features

for(i in 7:ncol(kenya)){
  summ <- sum(as.numeric(as.character(kenya[,i])))
  freqs <- append(freqs, summ )
  if( summ == 0 ){
    omit_vec <- append(omit_vec, i)
  }
  if(summ <= 67){ ##threshold: %5
    omit2 <- append(omit2, i)
  }
}

## remove those features that have 0 cases (or more cases is proper like <= 5% of the all cases)
kenya1 <- kenya[,-omit_vec]
kenya2 <- kenya[,-omit2]

# plot for the frequencies of the symptoms
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
    labels=df_frq$symptoms
  )  + 
  theme(
    axis.title.y=element_blank(), 
    text=element_text(family="serif",size=13),
    plot.title=element_text(face="bold",hjust=0.5)
  )
ggsave("./all_freqs.png",device="png", width = 11, height=8)

## function that plot the frequency for a demographic subgroup and return the significantly different feature list
bar_plot <- function(df, label){
  unames <- unique(as.character(df[,1]))
  nums <- vector(mode="numeric")
  for(i in 1:length(unames)){
    nums <- append(nums, length(which(df[,1]==unames[i])))
  }
  
  #calculate the frequencies for each of the subgroup type
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
  
  #convert to percentages
  for(i in 1:nrow(df2)){
    df2[i,] <- df2[i,]/nums[i]
  }
  df2 <- t(df2)
  df2 <- cbind(df2, chi_res)
  df2 <- df2[order(df2[,ncol(df2)], decreasing = TRUE),]
  df2 <- as.data.frame(df2)
  df2$symptom <- row.names(df2)
  df2 <- df2[df2$chi_res <= 0.05,]
  
  # reshape the data to the long-format
  df3 <- reshape(df2, direction = "long", varying = list(1:length(nums) ),
                idvar = names(df2)[ncol(df2)], timevar = label,
                times=names(df2)[ c(1:length(nums)) ], v.names = "percentage" )
  
  df3$symptom <- factor(df3$symptom, levels = unique(df3$symptom))
  
  #plot the frequencies for each type
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

# calculate the chi-square statistics for a demographic group
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
## for each of the subtypes, compute the chi square with p=0.05, and plot
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

## get the plot
age_res <- bar_plot(age_df, "age") #<=50 and >50
gender_res <- bar_plot(gender_df, "gender") #male and female
country_res <- bar_plot(country_df, "country")
live_tp_res <- bar_plot(live_tp_df, "living_type")
employ_res <- bar_plot(employ_df, "employed")
live_with_res <- bar_plot(live_with_df, "living_with")
grid.arrange(age_res[[1]], gender_res[[1]], country_res[[1]],  employ_res[[1]], live_with_res[[1]],live_tp_res[[1]], ncol=2)


## there are 2 * 3 = 6 combinations of age/gender
## Next, we compute the similarities among the age/gender subgroups in terms of cosine similarities
## this analysis is only performed on the frequent symptoms (>= 5% occurrance)
dff <- kenya2
dff$age_gender <- paste(dff$Age, dff$Gender, sep="_")
## count those sub types
subtypes <- unique(dff$age_gender)

#for each of the age-gender group, we get the frequency vector for the symptoms
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

#cosine similarity between two age-gender group
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


## Next, we do K-mode clustering
## use a subset of features to optimize the number of groups: freq > 5%

# First, we use total-within-clusters-sum-of-square as the metric to optimize the number of clusters
set.seed("2022112602")
wss <- sapply(1:15, function(k){
  sum(kmodes(kenya2[,-c(1:6)], k, iter.max = 100, weighted = TRUE)$withindiff)
})

plot(1:15, wss, type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares" )

## optimal: 11 clusters: a good kink (elbow) point

# K-mode clustering
result <- kmodes(kenya2[,-c(1:6)], 11, iter.max = 100, weighted = TRUE)

# report cluster size; cluster modes; and maybe within-cluster distance
write.csv(as.data.frame(result$modes),"7clusters_modes.csv", quote = FALSE)

## checking the overlapping of the clustering result with the age-gender subgroups
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

## EOF
