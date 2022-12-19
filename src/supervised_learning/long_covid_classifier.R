library(DAAG)
library(party)
library(rpart)
library(rpart.plot)
library(mlbench)
library(caret)
library(pROC)
library(tree)


library(foreign)
library(tidyverse)
library(caret)
library(mlr)
library(gridExtra)
library(rattle)
library(rpart.plot)


setwd("C:\\work\\internship\\COMP4710-Group-11\\src\\supervised_learning")

us <- read.csv("../../US_Week49_COVID.csv")
dim(us)
us <- us[us$HAD.COVID==1,]
names(us)

for(i in (2:15)){
  #print(class(us[,i]))
  print(names(us)[i])
  print( table(us[,i]) )
}

## treat oral and treat mono has too many NAs; we do not use them for now
## current symptoms and impact are in the future, we can not predict on it
us <- us[,c(1,2,3,4,6,7,8,12, 14)]

for(i in (2:8)){
  #print(class(us[,i]))
  print(names(us)[i])
  print( table(us[,i]) )
}

## check the number of positive cases and negative cases
table(us$LONG.COVID)

## delete all those data containing NA values
nas = union( which(us$SYMPTOM.SEVERITY == "N/A"), union( which(us$NUMBER.DOSES == "N/A"), which(us$BOOSTER == "N/A") ) )
nas <- which(us$SYMPTOM.SEVERITY == "N/A")
#us_nas <- us[nas,]

us_pure <- us[-nas,]
us_pure$NUMBER.DOSES[which(us_pure$NUMBER.DOSES == "N/A")] <- "0"
us_pure$BOOSTER[which(us_pure$BOOSTER == "N/A")] <- "0"


## unbalanced data, we first choose 30% from the non-NA data as the test dataset
positive <- which(us_pure$LONG.COVID == 1)
negative <- which(us_pure$LONG.COVID == 0)

set.seed("2022120901")
test_pos_ind <- sample(positive, floor(length(positive) * 0.3) )

## 1630 test negative cases
#test_pos_ind <- setdiff(test_pos_ind, nas)
##then choose 1630 pure negative cases

set.seed("2022120902")
test_neg_ind <- sample(negative, length(test_pos_ind))
test_ind <- union(test_pos_ind, test_neg_ind)

## get those training data:
train_pos_ind <- setdiff(positive, test_pos_ind)
train_neg_ind <- setdiff(negative, test_neg_ind)
set.seed("2022120902")
train_neg_ind <- sample(train_neg_ind, length(train_pos_ind))
train_ind <- union(train_pos_ind, train_neg_ind)

## all the other cases besides the training set
all_other_ind <- setdiff( c(1:nrow(us_pure)), train_ind )



## preprocess the us_pure data:
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

#vaccinated is not useful
#unvacc <- us[us$VACCINATED == 0,]


train <- df[train_ind,]
test <- df[test_ind,]
intersect(train_ind, test_ind)
others <- df[-train_ind,]


## descriptive analysis and feature selection using ??
age <- ggplot(data=train, aes(x=LONG_COVID,y=AGE,fill=LONG_COVID))+geom_boxplot(alpha=0.8)+
  #scale_fill_manual(values=myfillcolors)+
  coord_flip()

race <- ggplot(data=train, aes(x=LONG_COVID, fill=RACE ))+geom_bar(position="fill",alpha=0.8,color="black")+
    #+scale_fill_manual(values=myfillcolors)+
    coord_flip()

gender <- ggplot(data=train, aes(x=LONG_COVID, fill=BIRTH_GENDER ))+geom_bar(position="fill",alpha=0.8,color="black")+
  #+scale_fill_manual(values=myfillcolors)+
  coord_flip()

vaccinated <- ggplot(data=train, aes(x=LONG_COVID, fill=VACCINATED ))+geom_bar(position="fill",alpha=0.8,color="black")+
  #+scale_fill_manual(values=myfillcolors)+
  coord_flip()

train$NUMBER_DOSES <- as.factor(as.character(train$NUMBER_DOSES))
doses <- ggplot(data=train, aes(x=LONG_COVID, fill=NUMBER_DOSES ))+geom_bar(position="fill",alpha=0.8,color="black")+
  #+scale_fill_manual(values=myfillcolors)+
  coord_flip()

booster <- ggplot(data=train, aes(x=LONG_COVID, fill=BOOSTER ))+geom_bar(position="fill",alpha=0.8,color="black")+
  #+scale_fill_manual(values=myfillcolors)+
  coord_flip()

symp_severity <- ggplot(data=train, aes(x=LONG_COVID, fill=SYMPTOM_SEVERITY ))+geom_bar(position="fill",alpha=0.8,color="black")+
  #+scale_fill_manual(values=myfillcolors)+
  coord_flip()

grid.arrange(age, race, gender, vaccinated, doses, booster, symp_severity, ncol=2)
#ggsave("./descriptive_analysis.png",device="png", width = 5, height=5)
train$NUMBER_DOSES <- as.numeric(as.character(train$NUMBER_DOSES))



# apply botura to select features
library(Boruta)
set.seed("2022120905")
result <- Boruta(LONG_COVID ~., data=train)
print(result)
plot(result, pars = list(boxwex = 0.8, staplewex = 0.5, outwex = 0.5) )

att_stat <- as.data.frame( attStats(result) )
for(i in 1:5){
  att_stat[,i] <- round(att_stat[,i], 3)
}
write.csv(att_stat,"feature_selection.csv", quote = FALSE)



#some features are not useful by the boruta result: vaccinated
train <- train[,-4]
test <- test[,-4]
others <- others[,-4]


##manually tune the parameter of the decision tree: it is not good!!
learner$par.set
task=makeClassifTask(id="LONG_COVID",data=train, target="LONG_COVID", positive = "yes")
tasktest=makeClassifTask(id="LONG_COVID",data=test, target="LONG_COVID", positive = "yes")
learner = makeLearner("classif.rpart", predict.type = "prob")

ps=makeParamSet(makeDiscreteParam("maxdepth",values = c(1,2,3,4,5,6,7)),makeNumericParam("cp",lower=0.01,upper=0.1))

ctrlgrid = makeTuneControlGrid()

rdesc = makeResampleDesc("RepCV",reps = 10,folds=10)

set.seed(123)
res=tuneParams(learner, task=task,resampling=rdesc,par.set=ps,control=ctrlgrid,measures = list(mmce,bac))

mmce$minimize
res$x

# grid tuning result
resdf=generateHyperParsEffectData(res)

resdata=resdf$data%>%as_tibble()

resdata%>%ggplot(aes(x=cp,y=maxdepth))+geom_point(aes(size=mmce.test.mean,fill=mmce.test.mean),alpha=0.6,shape=21)+geom_vline(xintercept=res$x$cp,color="red",size=0.7)+geom_hline(yintercept=res$x$maxdepth,color="red",size=0.7)+scale_fill_gradient(high="purple",low="#ff0033")

resdata%>%ggplot(aes(x=cp,y=maxdepth))+geom_point(aes(size=bac.test.mean,fill=bac.test.mean),alpha=0.6,shape=21)+geom_vline(xintercept=res$x$cp,color="blue",size=0.7)+geom_hline(yintercept=res$x$maxdepth,color="blue",size=0.7)+scale_fill_gradient(low="purple",high="#ff0033")

# train using the optimized parameters
learner2=setHyperPars(learner,par.vals = res$x)

cartmlr=mlr::train(learner2,task)
predmlr=predict(cartmlr,tasktest)

mets=list(auc,bac,tpr,tnr,mmce,ber,fpr,fnr)

performance(predmlr, measures =mets)

## tuning result is not good

##another tuning method
library(caret)
library(MLmetrics)
Control=trainControl(method= "repeatedcv",number=10,repeats=10,classProbs=TRUE,summaryFunction =multiClassSummary)
cart1=caret::train(LONG_COVID~.,data=train,method="rpart",trControl=Control,tuneLength=10)


library(partykit)
library(party)

fancyRpartPlot(cart1$finalModel,palettes="RdPu")
##cp = 0.0031


cart2=caret::train(LONG_COVID~.,data=train,method = "rpart2",trControl=Control,tuneLength=10)
cart2
fancyRpartPlot(cart2$finalModel,palettes="RdPu")

pred1<-predict(cart1,others,type="prob")%>%cbind(others,.)
pred1$Predicted=predict(cart1,others)
confusionMatrix(pred1$Predicted,reference=pred1$LONG_COVID,positive ="yes",mode="everything")

pred2<-predict(cart2,others,type="prob")%>%cbind(others,.)
pred2$Predicted=predict(cart2,others)
confusionMatrix(pred2$Predicted,reference=pred2$LONG_COVID,positive ="yes",mode="everything")
## maxdepth = 3

cp_path <- round( cart1$results[,c(1,3)], 3 )
maxdepth_path <- cart2$results[,c(1,3)]

library(ggrepel)

cp_pic <- ggplot(data=cp_path, aes(x=cp, y=AUC)) +
  geom_line() #+
  #geom_label_repel(aes(label = cp), nudge_x = 0.35, size = 4)

mdep_pic <- ggplot(data=maxdepth_path, aes(x=maxdepth, y=AUC)) +
  geom_path()
grid.arrange(cp_pic, mdep_pic, pic_tree, pic_rf, ncol=2)



for(i in 2:7){
  print(table(train[,c(i,8)]))
}


library("ggplot2")
## exploratory analysis for each feature on the training data set:
for(i in c(2,3,5,6,7) ){
  tab1 <- as.data.frame( table(train[,c(i,8)]) )
  label = names(tab1)[1]
  
  ggplot(data=tab1, aes(x=tab1[,1], y=Freq, fill=LONG_COVID, ) ) +
    geom_bar(position="dodge",stat="identity") +
    coord_flip() + 
    #ggtitle( paste("","symptoms percentage") ) + 
    #theme_bw() +   
    #scale_x_discrete(
    #  limits=unique(df2$symptom), 
    #  labels=unique(df2$symptom)
    #)  + 
    #scale_fill_discrete(
    #  name=label,
    # labels= names(df2)[c(1,2)]
    #) +  
    theme(
      #legend.position=c(.83,.3),
      axis.title.y=element_blank(), 
      text=element_text(family="serif",size=15),
      plot.title=element_text(face="bold",hjust=0.5)
    )
  
  ggsave(paste(label, "_table.png", sep="") )
}

rm_ind <- which(names(train) %in% c("VACCINATED", "NUMBER_DOSES"))
train <- train[, -rm_ind ] #remove 
test <- test[, -rm_ind ] #remove 

## build a decision tree on the training dataset
library("randomForest")
library("pROC")

tuneRF(train[,c(1:6)], train[,7], mtryStart = 2, ntreeTry = 1000, stepFactor = 1.5, improve = 0.01,
       trace = TRUE, plot=TRUE, doBest = FALSE)


set.seed("2022120903")
model <- randomForest(LONG_COVID ~., data=train, ntree = 2000, mtry=2, importance=TRUE) #, proximity=TRUE)
pred <- predict(model, others, type = "prob")
model
roc_r <- roc(others$LONG_COVID, pred[,1])
roc_r$auc
importance <- round(model$importance, 3)
write.csv(importance,"RF_importance.csv", quote = FALSE)



## using the decision tree:
library("rpart")
tree <- rpart(formula = LONG_COVID ~., data=train, parms=list(split=c("information", "gini")),
              minsplit=2, minbucket=1, cp=0.0031, xval=10, maxdepth=3 )
#plotcp(tree)
rpart.plot(tree)


p <- predict(tree, train, type = 'class')
confusionMatrix(p, train$LONG_COVID)

## auc




p1 <- predict(tree, others, type = 'prob')
p1 <- p1[,2]
p1 <- pred1[,9]
p1 <- pred2[,9]

r <- multiclass.roc(others$LONG_COVID, p1, percent = TRUE)
roc <- r[['rocs']]
r1 <- roc[[1]]
plot.roc(r1,
         print.auc=TRUE,
         auc.polygon=TRUE,
         grid=c(0.1, 0.2),
         grid.col=c("green", "red"),
         max.auc.polygon=TRUE,
         auc.polygon.col="lightblue",
         print.thres=TRUE,
         main= 'ROC Curve')

# now we have a better result for the decision tree: auc = 70.4

## plot the AUC
library(ROCR)
df_label <- as.character(others$LONG_COVID)
df_label[df_label=='yes'] <- 0
df_label[df_label=='no'] <- 1
ppp <- prediction(pred[,1], df_label)

#pred

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

roc.data <- data.frame(fpr=unlist(perff@x.values), tpr=unlist(perff@y.values) ) #,model="TREE")
auc_text <- paste("AUC = ",auc,"\n95%CI ",CI_left,"-",CI_right, "\nData Point\n",n1,"cases/",n2,"controls", sep="")
auc_label <- c(rep(NA, floor(0.64*nrow(roc.data))-1), auc_text, rep(NA, nrow(roc.data)-floor(0.64*nrow(roc.data))))

pic_rf <-  ggplot(data=roc.data, aes(x=fpr, ymin=0, ymax=tpr))+
  geom_ribbon(alpha=0.05) +
  geom_line(aes(y=tpr)) +
  #ggtitle(paste0("ROC Curve \n AUC=", auc)) +
  theme(plot.title = element_text(hjust=0.5),
        panel.background=element_rect(fill="white",color="black",linetype="dashed",size=1) )+
  labs(x="False positive rate", y="True positive rate") +
geom_text(label=auc_label, y=0.35, hjust=0)

print(pic_rf)
grid.arrange(pic_tree, pic_rf, ncol=2)

ggsave("./auc_curve_decision_tree.pdf",device="png", width = 5, height=5)


##other metrics such as F1-score, accurary, ...
p11 <- predict(tree, others, type='class')
confusionMatrix(p11, others$LONG_COVID, mode="everything")

p_rf <- predict(model, others, type='class')
confusionMatrix(p_rf, others$LONG_COVID, mode="everything")


## remove the two features results in more non-NA data:
## since the specificity is good, we can include more negative cases in the test set to calculate the AUC, so that ...



# try GLM, or engineer the AGE feature into subgroups.
# report comparison with the three models






