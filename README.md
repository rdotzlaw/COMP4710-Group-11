# COMP4710-Group-11

## TODO
- Decide how assocation rules and random forest are connected
  - Association rules for analysis part of paper, then random forest for prediction?
  - Decide on order of implementation: data mining then prediciton? or vise versa
- Choose algorithm to mine data
- What are the main areas of work, and how will we divide the work among the group
  - Compile all datasets into CSV/spreadsheet for use in project and submiting
    - is this even necessary?
  - Implement data mining algorithm
  - Implement random forest algorithm
  - Perform analysis on dataset, association rules, and results of prediction algorithm
  - Write report (10 page minimum using [IEEE template 2-column](https://www.ieee.org/conferences/publishing/templates.html))
  - Presentation (video or live powerpoint)

### Step1: Data cleansing (now we have two datasets for use)
- data format (csv)
- data header (screen those useful for our research)
- data type (keep those numeric and categorical features, descriptive columns may not be useful)
- deal with missing values(which algorithm to use?)
- other types of data transformation for convenience in comparison among different population groups: for example, grouping the ages into intervals; grouping occupations as healthcare workers, school workers; 

### Step2: What Association Rule we can discover
- examine the number and percentage of post-COVID cases for different feature-combinations, for example (age, gender).
- examine differences in frequency of symptoms/medical-features for different (age, gender) combinations (comparing to general population distribution).
- discover common characteristics among post-COVID cases belonging to a certain (age, gender) combination, and compares it with those for other combinations.
- temporal trend for post-COVID symptoms.
- frequent pattern mining for co-occurring symptoms: acorss all dataset and different (age, gender) combinations. (many symptoms have NULL values)
- contrast the frequent pattern among the different (age, gender) combinations and global statistics. i.e. which age group/gender tend to have more symptom of cough?
- different (age, gender) groups may vary in population, therefore we need take percentages into account (not just absolute frequencies).

### Step3: A predictive model.
- what does the model predict? (which variable we are going to use for prediction -- whether the case recover from long-COVID symptoms? It seems there is no such variable in the datasets)
- the two datasets have different features, if we use both dataset for the model, we need to pick those common features between the two datsets, and shuffle the instances.

## Step4: Clustering.
- if a predictive model is infeasible, we may do some unsupervised learning such as K-mean clustering instead/in addition.

![General Flowchart](flow.PNG)

## Data sources
- [Harvard Long Covid Dataset](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/N5I10C%0b)
- [Another Long Covid Dataset](https://data.humdata.org/dataset/long-covidresearchagenda)
- [UK Omnicron Variant Long Covid Dataset](https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/conditionsanddiseases/datasets/selfreportedlongcovidafterinfectionwiththeomicronvariantintheuk%0b) (Apparently this dataset no longer exists)
- [Demographic Suceptability Dataset](https://data.cdc.gov/NCHS/Post-COVID-Conditions/gsea-w83j%0b)
## Research
- [Long Covid Symptoms Research](https://www.ejinme.com/article/S0953-6205(21)00208-9/fulltext)
- [Comprehensive Overview of Post Covid Condition](https://www.cadth.ca/sites/default/files/hs-eh/EH0096%20Long%20COVID%20v.7.0-Final.pdf )
- [Explaining Random Forest Using Association Rules]( https://publikationen.bibliothek.kit.edu/1000117720/62928283)
- [Random Forests](https://www.researchgate.net/publication/323553514_A_Practical_Introduction_to_Random_Forest_for_Genetic_Association_Studies_in_Ecology_and_Evolution )
- [Prevalence of Post-Covid-19 Symptoms with Hospitalizations/No Hospitalizations](https://www.ejinme.com/article/S0953-6205(21)00208-9/fulltext)


