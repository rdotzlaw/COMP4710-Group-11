### Two classifiers for the US Census Long Covid-19 data

library(DAAG)
library(rpart)
library(rpart.plot)
library(caret)
library(tree)
library(foreign)
library(tidyverse)
library(mlr)
library(gridExtra)
library(party)
library(partykit)
library(MLmetrics)
library(ggrepel)
library(ggplot2)
library(randomForest)
library(ROCR)
library(Boruta)

##set the working folder where this code residues, and put the source file 
## data in the folder one level up

#setwd("C:\\work\\internship\\COMP4710-Group-11\\src\\supervised_learning")
us <- read.csv("../US_Week49_COVID.csv")
us <- us[us$HAD.COVID==1,]

## treat oral and treat mono has too many NAs; we do not use them for now
## current symptoms and impact are in the future, we can not predict on it
us <- us[,c(1,2,3,4,6,7,8,12, 14)]

## check the number of positive cases and negative cases
table(us$LONG.COVID)

## delete all those data containing NA values
nas <- which(us$SYMPTOM.SEVERITY == "N/A")
us_pure <- us[-nas,]

#those NAs are people who are not vaccinated
us_pure$NUMBER.DOSES[which(us_pure$NUMBER.DOSES == "N/A")] <- "0"
us_pure$BOOSTER[which(us_pure$BOOSTER == "N/A")] <- "0"

## unbalanced data, we first choose 30% from the non-NA data as the test dataset
positive <- which(us_pure$LONG.COVID == 1)
negative <- which(us_pure$LONG.COVID == 0)
set.seed("2022120901")
test_pos_ind <- sample(positive, floor(length(positive) * 0.3) )
set.seed("2022120902")
test_neg_ind <- sample(negative, length(test_pos_ind))
test_ind <- union(test_pos_ind, test_neg_ind)

## get those training data:
train_pos_ind <- setdiff(positive, test_pos_ind)
train_neg_ind <- setdiff(negative, test_neg_ind)
set.seed("2022120902")
train_neg_ind <- sample(train_neg_ind, length(train_pos_ind))
train_ind <- union(train_pos_ind, train_neg_ind)

## all the other cases besides the training set are test set
all_other_ind <- setdiff( c(1:nrow(us_pure)), train_ind )

## preprocess the us_pure data, convert to factor type, change the categorical representation
for(i in 3:ncol(us_pure)){
  if(names(us_pure)[i] != "NUMBER.DOSES"){
    us_pure[,i] <- as.factor(us_pure[,i])
  }
}

df <- us_pure[,-1]
for(i in 1:ncol(df)){
  names(df)[i] <- sub("\\.", "_", names(df)[i])
}
df$LONG_COVID%<>%as.factor()%>%recode_factor(.,`0` = "no", `1` = "yes")
df$BOOSTER%<>%as.factor()%>%recode_factor(., `0` = "zero", `1` = "one")
df$VACCINATED%<>%as.factor()%>%recode_factor(.,`0` = "no", `1` = "yes")
df$NUMBER_DOSES <- as.numeric(df$NUMBER_DOSES)

# split the train and test dataset
train <- df[train_ind,]
test <- df[test_ind,]
intersect(train_ind, test_ind)
others <- df[-train_ind,]

## descriptive analysis, and arrange the pics in one pic
age <- ggplot(data=train, aes(x=LONG_COVID,y=AGE,fill=LONG_COVID))+geom_boxplot(alpha=0.8)+
  coord_flip()

race <- ggplot(data=train, aes(x=LONG_COVID, fill=RACE ))+geom_bar(position="fill",alpha=0.8,color="black")+
    coord_flip()

gender <- ggplot(data=train, aes(x=LONG_COVID, fill=BIRTH_GENDER ))+geom_bar(position="fill",alpha=0.8,color="black")+
  coord_flip()

vaccinated <- ggplot(data=train, aes(x=LONG_COVID, fill=VACCINATED ))+geom_bar(position="fill",alpha=0.8,color="black")+
  coord_flip()

train$NUMBER_DOSES <- as.factor(as.character(train$NUMBER_DOSES))
doses <- ggplot(data=train, aes(x=LONG_COVID, fill=NUMBER_DOSES ))+geom_bar(position="fill",alpha=0.8,color="black")+
  coord_flip()

booster <- ggplot(data=train, aes(x=LONG_COVID, fill=BOOSTER ))+geom_bar(position="fill",alpha=0.8,color="black")+
  coord_flip()

symp_severity <- ggplot(data=train, aes(x=LONG_COVID, fill=SYMPTOM_SEVERITY ))+geom_bar(position="fill",alpha=0.8,color="black")+
  coord_flip()

png(file="./descriptive_analysis.png", width=600, height=800)
grid.arrange(age, race, gender, vaccinated, doses, booster, symp_severity, ncol=2)
dev.off()
train$NUMBER_DOSES <- as.numeric(as.character(train$NUMBER_DOSES))

# apply botura to select features
set.seed("2022120905")
result <- Boruta(LONG_COVID ~., data=train)
png(file="./Boruta_feature_selection.png", width=700, height=400)
plot(result, pars = list(boxwex = 0.8, staplewex = 0.5, outwex = 0.5) )
dev.off()

# store the optimization result
att_stat <- as.data.frame( attStats(result) )
for(i in 1:5){
  att_stat[,i] <- round(att_stat[,i], 3)
}
write.csv(att_stat,"feature_selection.csv", quote = FALSE)


#some features are not useful by the boruta result: vaccinated
train <- train[,-4]
test <- test[,-4]
others <- others[,-4]

## 1. Classifier 1: Decision Tree
## first we tune the parameters cp and maxdepth
contr <- trainControl(method= "repeatedcv",number=10, repeats=10, classProbs=TRUE, summaryFunction = multiClassSummary)
cart1=caret::train(LONG_COVID~.,data=train,method="rpart",trControl=contr,tuneLength=10)
## optimal cp = 0.003

cart2=caret::train(LONG_COVID~.,data=train,method = "rpart2", trControl=contr, tuneLength=10)
## optimal maxdepth = 3

# plot the tuning process
cp_path <- round( cart1$results[,c(1,3)], 3 )
maxdepth_path <- cart2$results[,c(1,3)]
cp_pic <- ggplot(data=cp_path, aes(x=cp, y=AUC)) +
  geom_line()
mdep_pic <- ggplot(data=maxdepth_path, aes(x=maxdepth, y=AUC)) +
  geom_path()

## train the decision tree:
tree <- rpart(formula = LONG_COVID ~., data=train, parms=list(split=c("information", "gini")),
              minsplit=2, minbucket=1, cp=0.003, xval=10, maxdepth=3 )
#plot the tree
png(file="./decision_tree.png")
rpart.plot(tree)
dev.off()

## Classifier 2: Random Forest
## First we tune the parameter mtry for the model
tuneRF(train[,c(1:6)], train[,7], mtryStart = 2, ntreeTry = 1000, stepFactor = 1.5, improve = 0.01,
       trace = TRUE, plot=TRUE, doBest = FALSE)

## with the optimized mtry=2, we train the model
set.seed("2022120903")
model <- randomForest(LONG_COVID ~., data=train, ntree = 2000, mtry=2, importance=TRUE) #, proximity=TRUE)
# output the feature importance rank
importance <- round(model$importance, 3)
write.csv(importance,"RF_importance.csv", quote = FALSE)


## Next, we calculate and plot the AUC for the two classifiers
p_tree <- predict(tree, others, type = 'prob')
p_rf <- predict(model, others, type = "prob")


## function that plot the AUC and return the pic
plot_auc <- function(pred){
  df_label <- as.character(others$LONG_COVID)
  df_label[df_label=='yes'] <- 0
  df_label[df_label=='no'] <- 1
  ppp <- prediction(pred[,1], df_label)
  
  perff <- ROCR::performance(ppp, measure = 'tpr', x.measure = 'fpr')
  auc <- ROCR::performance(ppp, measure = "auc")
  auc <- round(auc@y.values[[1]], 3)
  
  #compute the 95% CI of AUC
  q1 <- auc/(2-auc)
  q2 <- 2*auc^2/(1+auc)
  n1 <- length(df_label[df_label == 1])
  n2 <- length(df_label[df_label == 0])
  auc_se <- sqrt((auc*(1-auc) + (n1-1)*(q1-auc^2) + (n2-1)*(q2-auc^2))/(n1*n2))
  CI_left <- round(auc - 1.96*auc_se, 3)
  CI_right <- round(auc + 1.96*auc_se, 3)
  
  # get the texts description for the plot
  roc.data <- data.frame(fpr=unlist(perff@x.values), tpr=unlist(perff@y.values) ) #,model="TREE")
  auc_text <- paste("AUC = ",auc,"\n95%CI ",CI_left,"-",CI_right, "\nData Point\n",n1,"cases/",n2,"controls", sep="")
  auc_label <- c(rep(NA, floor(0.64*nrow(roc.data))-1), auc_text, rep(NA, nrow(roc.data)-floor(0.64*nrow(roc.data))))
  
  pic <-  ggplot(data=roc.data, aes(x=fpr, ymin=0, ymax=tpr))+
    geom_ribbon(alpha=0.05) +
    geom_line(aes(y=tpr)) +
    theme(plot.title = element_text(hjust=0.5),
          panel.background=element_rect(fill="white",color="black",linetype="dashed",size=1) )+
    labs(x="False positive rate", y="True positive rate") +
    geom_text(label=auc_label, y=0.35, hjust=0)
  
  return(pic)
}

pic_tree <- plot_auc(p_tree)
pic_rf <- plot_auc(p_rf)
png("para_tuning_AUC.png")
grid.arrange(cp_pic, mdep_pic, pic_tree, pic_rf, ncol=2)
dev.off()
#grid.arrange(pic_tree, pic_rf, ncol=2)


##other metrics such as F1-score, accuracy, ...
p_tree2 <- predict(tree, others, type='class')
confusionMatrix(p_tree2, others$LONG_COVID, mode="everything")

p_rf2 <- predict(model, others, type='class')
confusionMatrix(p_rf2, others$LONG_COVID, mode="everything")
#just record the metrics from the stdout
# EOF
