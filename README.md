# COMP4710-Group-11
## folder structure
./README.txt (this file)

./src
      /supervised_learning (codes and intermediate files of classifier)

      /unsupervised_learning (codes and intermediate files of clustering analysis )

      KenyaData.csv

      MalawiData.csv

      Table_and_Figures_clustering_classifier.xlsx (excel file that sums over the clustering and classifier analysis)

## Preparation for running the program:
The source data file should be in the ./src folder as indicated above.

install R > 4.2


inpstall the following packages:

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

## How to run the program:

### run clustering analysis:
From cmd, enter in ./src/unsupervised_learning/, and run:

Rscript ./clustering.R

### run classifier:
From cmd, enter in ./src/supervised_learning/, and run:

Rscript ./long_covid_classifier.R

The outputs are in the corresponding folders.



