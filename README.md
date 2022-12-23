# COMP4710-Group-11

## Folder structure
```
./README.md (this file)

./src

      /ar_mining
	  
      /supervised_learning (codes and intermediate files of classifier)

      /unsupervised_learning (codes and intermediate files of clustering analysis )

      KenyaData.csv

      MalawiData.csv

      Table_and_Figures_clustering_classifier.xlsx (excel file that sums over the clustering and classifier analysis)
```

# Association Rule Mining and Demographic Analysis

### Input
This program works explicitly with cut-down/formatted versions of [this census](https://www.census.gov/programs-surveys/household-pulse-survey/datasets.html) from the US Census Bureau, called _US_Week49_COVID.csv_  and _US_WEEK46_COVID.csv_ in the current directory.
The modifications were done to clean up the data and remove irrelevant data. 
### Output
This program will generate six .csv files:
* _US_Week49_COVID-output.csv_,
  * Which includes all associative rules mined that have "Long Covid: Yes" or "Long Covid: No" as the consequents, sorted in confidence ascending.
* _US_Week49_COVID-LC.csv_
  * Which includes only the associative rules that have "Long Covid: Yes" as the consequent, sorted in confidence ascending.
* _US_Week49_COVID-NoLC.csv_
  * Which includes only the associative rules that have "Long Covid: No" as the consequent, sorted in confidence ascending.
* _US_WEEK46_COVID-output.csv_
   * Which includes all associative rules mined that have "Long Covid: Yes" or "Long Covid: No" as the consequents, sorted in confidence ascending.
* _US_WEEK46_COVID-LC.csv_
  * Which includes only the associative rules that have "Long Covid: Yes" as the consequent, sorted in confidence ascending.
* _US_WEEK46_COVID-NoLC.csv_
  * Which includes only the associative rules that have "Long Covid: No" as the consequent, sorted in confidence ascending.

The *LC* and *NoLC* versions of the file are for use with the Associative Rule bar graphs. The choice to label the x-axis of the bar graphs with an index for lookup, instead of the association rule, was done because some association rules were deemed too long to show up in the graph.

The program will also generate many graphs, showing a break-down of the demographics of the dataset for use in the analysis section of the project.

### Execution
To run the program, simply ensure that the file *src/ar_mining/main.py* is in the same directory as the datasets, *US_Week49_COVID.csv* and *US_WEEK46_COVID.csv*, and then run *main.py* in the directory with python.

        python3 main.py
		
### Implementation
This program was implemented using the following libraries:
* mlextend
  * For the apriori frequent pattern mining, and the associative rule mining.
* mathplotlib
  * For creating and rendering the graphs.
* pandas
  * For dataframe manipulation, operations, and output to *.csv* files.
* numpy
  * For extra math operations.
* math
  * For more extra math operations.

# Clustering and Classifier
## Preparation for running the program:
The source data file should be in the ./src folder as indicated above.

install R > 4.2


install the following packages:

 * library(DAAG)

 * library(rpart)

 * library(rpart.plot)

 * library(caret)

 * library(tree)

 * library(foreign)

 * library(tidyverse)

 * library(mlr)

 * library(gridExtra)

 * library(party)

 * library(partykit)

 * library(MLmetrics)

 * library(ggrepel)

 * library(ggplot2)

 * library(randomForest)

 * library(ROCR)

 * library(Boruta)

## How to run the program:

### Run clustering analysis:
From cmd, enter in ./src/unsupervised_learning/, and run:

Rscript ./clustering.R

### Run classifier:
From cmd, enter in ./src/supervised_learning/, and run:

Rscript ./long_covid_classifier.R

The outputs are in the corresponding folders.
