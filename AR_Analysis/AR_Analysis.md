# Analysis of Association Rules and Related Graphs
The following analysis was performed on the US_WEEK46_COVID.csv dataset. Each individual record in this dataset corresponds to a Covid-19 patient. 
Graphs relating to Covid-19 demographicand patient information, Long Covid-19 demographic and patient information, and association rules will be
interpreted and discussed. It must be noted that Covid-19 testing and treatment are not always 
accessible and could impact demographic results, as described [here](https://www.cadth.ca/sites/default/files/hs-eh/EH0096%20Long%20COVID%20v.7.0-Final.pdf).

## Covid-19 Graph Analysis
#### Distribution of Covid-19 Patient Ages
![Covid Ages](AR_Analysis/Age.png)   
The majority of Covid-19 patients in this dataset are in the 30-60 age range, as seen in the above graph. Individuals with Covid-19 younger than 30 and older than 
80 have the smallest percentages. 

#### Ratio of Covid-19 Patients Gender Assigned at Birth
![Covid Birth Gender](AR_Analysis/Birth_Gender.png)        
According to the dataset analyzed, 55.89% of individuals were assigned female at birth, while 44.11% were assigned male at birth.
There is a higher percentage of individuals assigned female at birth who have Covid-19 in this dataset.  

#### Ratio of Covid-19 Patients Gender Identity
![Covid Current Gender](AR_Analysis/Current_Gender.png)   
As seen in the graph, 55.08% of patients currently identify as female. 43.46% of Covid-19 patients currently identify as male. 0.47% of patients currently identify
as transgender while 1.0% of patients identify as a different gender identity. There is still a higher percentage of female-identifying Covid-19 patients than 
male-identifying. 

#### Ratio of Covid-19 Patient Ethnicity
![Covid Ethnicity](AR_Analysis/Ethnicity.png)     
In this dataset, patients identified their ethnicity based on 5 categories: white, hispanic, black, asian, and mixed. 76.45% of the Covid-19 patients
are white. 9.52% of the patients are hispanic. 5.77%  of the patients are black. 3.95% of the patients in this dataset are asian. 4.3% of patients are mixed. 
This graph shows that patients who are white make up the majority of the Covid-19 patients included in this dataset. 

#### Severity of Covid-19 Symptoms
![Covid Symptoms Severe](AR_Analysis/Severity.png)   
The majority of Covid-19 patients reported mild or moderate symptoms, 41.61% and 41.77% respectively. Severe symptoms, like hospitalization, were reported by 11.46%
of Covid-19 patients in this dataset. Only 5.16% of Covid-19 patients in this dataset reported experincing no symptoms (considered asymptomatic).  

#### Vaccination Status Among Covid-19 Patients
![Covid Vaccination](AR_Analysis/Vax_Rate.png)   
Among the Covid-19 patients in this dataset, 85.67% are vaccinated (have recieved at least 1 vaccine) while 14.33% are unvaccinated.   

## Long Covid-19 Graph Analysis
#### Ratio of Covid-19 Patients with Long Covid-19
![Covid into Long Covid](AR_Analysis/Has_LC.png)   
72.44% of Covid-19 patients in this dataset reported not experiencing Long Covid-19, while 27.56% reported experiencing it. 

#### Distribution of Long Covid-19 Patient Ages
![Long Covid Ages](AR_Analysis/LC_Age.png)   
Similarly to the ages of Covid-19 patients, the majority of individuals with Long Covid-19 are in the 30-60 age range. Again, individuals younger than 30 and older
than 80 have the smallest percentages.

#### Ratio of Long Covid-19 Patients Gender Assigned at Birth
![Long Covid Birth Gender](AR_Analysis/LC_Birth_Gender.png)   
Individuals assigned female at birth made up the majority of patients experiencing Long Covid-19 (67.43%). 32.57% of individuals assigned male at birth reported 
experiencing Long Covid-19. This could indicate that individuals assigned female at birth are more likely to develop Long Covid-19, but note that the dataset used 
contains a majority of individuals assigned female at birth. 

#### Ratio of Long Covid-19 Patients by Ethnicity
![Long Covid Ethnicity](AR_Analysis/LC_Ethnicity.png)   
Of the individuals reporting to have experienced Long Covid-19, 73.82% are white, 11.32% are hispanic, 6.64% are black, 5.73% are mixed, and 2.49% are asian. 
This could indicate that white individuals are more likely to experience Long Covid-19, however recall that 76.45% of the Covid-19 patients in this dataset are white
and that demographic information can be skewed by inaccessible testing and treatement. 

#### Ratio of Long Covid-19 Patients by Symptom Severity
![Long Covid_SymptomSevere](AR_Analysis/LC_Symptom.png)   
The majority of individuals that reported having Long Covid-19 have moderate or severe symptoms, 49.46% and 25.45% respectively. 23.47% of individuals reported 
experiencing mild symptoms and 1.62% of individuals experiencing Long Covid-19 reported having no symptoms. Individuals reporting to have experienced Long Covid-19
with no symptoms could either be asymptomatic and testing positive for the required* amount of time to recieve a Long Covid-19 diagnosis, or part of the margin of error.   
*the required amount of time symptoms persist after initial diagnosis is debated among health organizations.
#### Ratio of Long Covid-19 Patients by Vaccination 
![Long Covid Vaccination](AR_Analysis/LC_Vax.png)   
The majority of Long Covid-19 patients (84.6%) are vaccinated while 15.4% are unvaccinated. This could indicate that Long Covid-19 is more likely to develop
as a result of a breakthrough infection (infection of vaccinated individuals), though this would need further research.

## Association Rules
#### Confidence of Association Rules with 'Long Covid Occuring' as the Concequent
![Long Covid Occuring in Concequent](AR_Analysis/AR_LC.png)   
An association rule with 'Long Covid Occuring' as the concequent is of the form: X->Long_Covid-Occuring. Approximately 33 interesting association rules were found that had 'Long
Covid Occuring' as the concequent. As indicated in the graph, the mined association rules are sorted by ascending confidence. The confidence of the association rules ranges from approximately 
0.3 to approximately 0.8.
![Long Covid Not Occurring in Concequent](AR_Analysis/AR_NoLC.png)   
Comparing the graphs with 'Long Covid Occuring' as the concequent and 'Long Covid Not Occuring' as the concequent, there are more association rules that have 'Long Covid
Not Occuring' as the concequent. Since 72.44% of Covid-19 patients in this dataset reported not experiencing Long Covid-19, it makes sense that more rules would be found with 'Long Covid not Occuring' as the concequent.
Over 400 rules were found with confidence ranging from approximately 0.6 to greater than 0.8. Again, the association rules found were sorted in ascending order by confidence.

**association rule table***
