# Notes for the Presentation
## Project Overview
- Analyzing Covid-19 data and Long-Covid-19 data 
- Mining interesting associations occurring in individuals diagnosed with Covid-19 that would imply the development of Long-Covid, using the Apriori Algorithm
- Building and training a model using K-Means Clustering to predict the possibility of developing Long-Covid-19
- Validating our model, optimizing the number of clusters, and testing model accuracy.
- Using the discovered rules to further analyze the accuracy of our model 
## Picked this topic because
- The Covid-19 pandemic is still ongoing.
- Long-Covid-19 is an active area of research
- Identifying relationships/patterns  between Covid-19 symptoms and Long-Covid development could contribute to better understanding the illness and effective treatments
## Current Research
### Data Mining and Model Generation
- Apriori performs a level-by-level search where the current k-itemsets explore the next (k+1) itemsets [4].
- An association rule of the form X→Y (where X and Y are itemsets in a transactional database) indicates that if X is present in the transaction then it is likely that Y is also in the transaction[5].
- Confidence (X→Y)  = sup(X and Y) / sup(X)[5]. Basically, of all the transactions containing X, how many also contain Y [5]. Whereas support(X→Y) is the amount of transactions containing both X and Y[5].
- Syntactic constraints are restrictions on which items can appear in the antecedent, consequent, or both[7].
- Only the combinations of items from the mined frequent items are generated, and further syntactic constraints are applied to identify interesting rules[7].
- A larger minsup results in greater pruning efficiency and a decrease in frequent itemsets[7]. 
- Clustering attempts to categorize data into a finite amount of clusters[6]. 
- A model representation generated must be generalizable or the model cannot be used to predict patterns on unknown data[6].
- Changing assumptions changes the model; it is important to keep assumptions consistent throughout the experiment[6]. 
### Covid-19 and Long Covid-19
- The definition of Long-Covid 19 (or Post Covid-19 Condition) is currently under debate. WHO defines post-covid 19 condition as any symptoms (new or ongoing) occuring after the 4 week infection period [1]. The Canadian Journal of Health Technologies proposes the following 2 subtypes of post-covid conditions: ongoing symptomatic covid 19 and post-covid 19 syndrome [1]:
  1. Ongoing symptomatic covid categorizes any symptoms occurring 4-12 after the initial infection [1]
  2. Post covid 19 syndrome categorizes any symptoms occurring 12 weeks after the initial infection or any symptoms occurring 3 months after the initial infection[1]
- Since post-covid 19 symptoms can occur in multiple organ systems, it is possible that other syndromes occur concurrently with post-covid 19 conditions [1]. This would include post-viral chronic fatigue syndrome, PICS, PTSD and the worsening of a pre-existing condition [1].
- Covid-19 can impact a variety of organ systems which results in a wide variety of possible symptoms[1].
- Singular or combinations of symptoms could be indicative of post-covid 19 conditions[1].
- It is thought that 83% of those confirmed to have covid might experience at least 1 symptom 4-12 weeks after their initial infection[1]. 
- 47% of individuals with confirmed covid cases could experience 1 or more symptoms 12 weeks after their initial infection[1].
- It is hard to tell if symptoms persisting 4-12 weeks after infection are caused by post-covid condition or by the development of a long-term health condition, as studies have found that those who had covid 19 were much more likely to develop a range of health conditions[1].
- In 2021, post-covid 19 condition was diagnosed based on a previous diagnosis of covid-19 and the current presentation of covid-19 symptoms[1].
- NICE and the Mayo Clinic diagnose post-covid conditions based on a suspected case of covid-19, as community testing is region specific[1].
- The prevalence of post-covid 19 conditions could range from 5-80%, although inconsistencies in study methodology, definitions, and testing make this range  unlikely[1].
- Multiple studies conducted on individuals with confirmed covid cases indicate that the prevalence of post-covid condition decreases overtime[1]. 
- Individuals that were hospitalized seem to have a higher prevalence of developing post-covid condition comparatively[1]. 
- Several retrospective and cross-sectional studies have investigated the risk factors for post-covid conditions, finding that severity of illness, gender, age, comorbidities, specific symptoms, amount of symptoms, ethnicity and socioeconomic factors, and vaccination status could all be significant risk factors [1].
- Severity of Illness: Those who were hospitalized could have a higher risk of developing post-covid condition and could have a higher risk for a more severe version of post-covid condition[1].
- Gender: Females could have a higher risk of developing post-covid conditions[1].
- Age: Older people may also have a higher risk[1].
- Comorbidities: Higher risk if individual has asthma, an autoimmune disease or is obese[1]. Neurological disabilities including anxiety and depression, could also indicate a higher risk[1].
- Type of Symptom: Experiencing fatigue, shortness of breath, headache, voice hoarseness and muscle aches during the initial infection could indicate  a higher risk[1].
- Amount of Symptoms: Greater amount of symptoms during initial infection could indicate greater risk[1].
- Ethnicity & Socioeconomic Factors: could be indicative, but would need to consider the accessibility to testing and proper healthcare received during initial infection[1].
- Vaccination: research ongoing. Risk factors and disease profile of post-vaccination SARS-CoV-2 infection in UK users of the COVID Symptom Study app: a prospective, community-based, nested, case-control study states that fully vaccinated individuals have a lower risk of developing symptoms after a breakthrough infection[1].
- A post-condition was observed in other coronaviruses, like SARS and MERS [3]. Symptoms from SARS and MERS persisted up to four years after the initial infection, and complications resulting from infection were still observed over seven years after illness[3]. 
- According to the research collected, it is estimated that at least 10% of individuals affected with covid-19 develop long covid, which globally translates to approximately 5 million people[3].
## Progress
- In the process of mining interesting rules using the Apriori Algorithm
- [this is where we would put graphs and information about the rules we’ve found]
- In the process of creating and validating our model, generated by K-Means Clustering
- [this is where we would put graphs and information about the cluster/prediction]
## Problems
- Some of the datasets we had found were removed:  The [CDC data](https://data.cdc.gov/NCHS/Post-COVID-Conditions/gsea-w83j) was removed, so we can no longer use it to examine if certain demographics are more susceptible to Long Covid. The [UK Gov data](https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/conditionsanddiseases/datasets/selfreportedlongcovidafterinfectionwiththeomicronvariantintheuk%0b) was also removed, which means we cant use it to examine connections between Covid variants and Long Covid diagnosis.
- It was difficult to find datasets containing both Covid-19 and Long-Covid-19 data, likely because this is an active area of research.
- Our initial attempt mining rules and model creation didn't work as intended since we only had Long-Covid data
- We were going to initially use the Random Forest Algorithm to create our model, but since that is a supervised method and our data is uncertain/unsupervised, this approach didn’t work and we switched to K-Means Clustering.
## Still to Come
- Model validation using 10-fold Cross Validation to optimize hyperparameters (specifically the number of clusters - K)
- Predictive analysis on test data using the model generated by K-Means Clustering
- Analysis of model accuracy when predicting Long-Covid using the test dataset
## Current Resources
### Datasets
- Covid-19 and Long-Covid data: [Household Pulse Survey Public Use File](https://www.census.gov/programs-surveys/household-pulse-survey/datasets.html)
- Long-Covid 19 Data from Kenya and Malawi: [Kenya, Malawi, Long Covid-19 effects survey dataset - Humanitarian Data Exchange](https://data.humdata.org/dataset/long-covidresearchagenda)

### Research Links
[1] [Comprehensive Overview of Post-Covid 19 Condition (Long Covid)](https://www.cadth.ca/sites/default/files/hs-eh/EH0096%20Long%20COVID%20v.7.0-Final.pdf)
[2] [Vaccination Status and Covid 19](https://www.thelancet.com/journals/laninf/article/PIIS1473-3099(21)00460-6/fulltext)
[3] [Comprehensive Research Summary of Post-Covid 19 Condition](https://www.tandfonline.com/doi/pdf/10.1080/23744235.2021.1924397?needAccess=true)
[4] [An Overview of Association Rule Mining Algorithms](https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=d4058d9f3f66c53ddea776c974fbd740afd994b4)
[5] [Algorithms for Association Rule Mining](https://dl.acm.org/doi/pdf/10.1145/360402.360421)
[6] [Data Mining and Model Generation](https://ojs.aaai.org/index.php/aimagazine/article/view/1230)
[7] [Association Rule Mining in Large Databases](https://dl.acm.org/doi/abs/10.1145/170035.170072)
