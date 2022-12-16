# Association Rule Mining

## Libraries
 * math
 * mlxtend.frequent_patterns (apriori and association_rules)
 * numpy
 * matplotlib.pyplot (for making graphs)
 * pandas (for data structures used w/ mlxtend)

## Process

Read in data from csv into a dataframe (array-like)

Make graphs for analysis
 * Count up occurances in a column -> normalize to percentage -> form graph
 
Find frequent items
 * Create column: 'AGE RANGE', which is actually multiple columns turning the numeric ages into a range (ie '<=36', >36 & <=54', etc.)
 * Use the columns: 
	['AGE RANGE', 'SYMPTOM SEVERITY', 'RACE', 'BIRTH GENDER', 'CURRENT GENDER', 'VACCINATED', 'LONG COVID',
    'IMPACTED', 'BOOSTER', 'NUMBER DOSES', 'TREAT ORAL', 'TREAT MONO', 'CURRENT SYMPTOMS']
 * Get Dummies
	* Splits categorical data into multiple columns
	* So the column w/ data: ['M', 'F'] becomes [[1,0], [0,1]]
 * Use mlxtend.frequent_patterns.apriori to get frequent item sets

Association Rules
 * Use mlxtend.frequent_patterns.association_rules to mine the frequent itemsets for ARs w/ a min confidence of 0.3
 * Filter the ARs for ones that have 'LONG_COVID_1' (implies long covid) or 'LONG_COVID_0' (implies NOT long covid)
 * Sort filtered ARs by confidence ascending
 * Output to separated CSVs: implies long covid, implies NOT long covid and combined
 
Disclaimers(?)
 * Use constants of column names in code, so will only work for CSVs that have the exact same formatting
 * minsup is determined by some formula I found online: math.exp(-0.4 * (len(df.index)) - 0.2) + 0.1
  * Basically minimum of 0.1, plus (1/e^x) where 'x' gets bigger the more rows you have