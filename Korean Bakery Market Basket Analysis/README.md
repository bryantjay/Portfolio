# Market Basket Analysis

## Introduction to MBA

### If This, Then That
Market Basket Analysis delves into the rules of  *association* between the different items in a given customer's basket. For example, if a grocery store shopper buys bread, then they could be more likely to buy butter, or vice versa. The Market Basket Analysis allows us to determine the likelihood that the selection of one product, the **antecedent** $X$, leads to the selection of another item the **consequent** $Y$:

$X \rightarrow Y$

Going forward, take this set of twelve grocery story transactions as a simplified example:

| Transaction | Items                                 |
|-------------|---------------------------------------|
| 1           | milk, egg, bread, butter              |
| 2           | milk, butter, egg, ketchup, butter    |
| 3           | bread, butter, ketchup                |
| 4           | milk, bread, butter                   |
| 5           | bread, butter, cookies                |
| 6           | milk, bread, butter, cookies          |
| 7           | milk, cookies                         |
| 8           | milk, bread, butter                   |
| 9           | bread, butter, egg, cookies           |
| 10          | milk, butter, bread                   |
| 11          | milk, bread                           |
| 12          | milk, bread, cookies, ketchup         |

## Metrics

### Frequency
**Frequency** refers to the count of transactions which include a given item or itemset. The frequency of any item $X$ is portrayed as the following:

$Frequency(X)$

In our simple transaction example, we have a total of 6 unique items with the following frequencies:

|    | item    |   frequency |
|---:|:--------|------------:|
|  0 | milk    |           9 |
|  1 | egg     |           3 |
|  2 | bread   |          10 |
|  3 | butter  |          10 |
|  4 | ketchup |           3 |
|  5 | cookies |           5 |

### Support
**Support** is essentially the previous count metric, defined as a percentage of all transactions:

$Support(X) = \frac{Frequency(X)}{N}$

Or more simply, the support of any item $X$ is the number of transactions with that item ($Frequency(X)$) divided by the total number of transactions $N$.

|    | item    |   frequency |   support |
|---:|:--------|------------:|----------:|
|  0 | milk    |           9 |      0.75 |
|  1 | egg     |           3 |      0.25 |
|  2 | bread   |          10 |      0.83 |
|  3 | butter  |          10 |      0.83 |
|  4 | ketchup |           3 |      0.25 |
|  5 | cookies |           5 |      0.42 |

Support can be a tricky metric to benchmark, as stores with different product lines will have different standards for what qualifies as "high" support. It often comes down to familiarity with the data and the environment it's being applied in.

Let's say you run a balloon store, and carry three types of balloons: yellow, green, and blue. One day, you record 8 different transactions, each selling one item. You tally up the end-of-day sales as **3** yellow balloons, **1** green balloon, and **4** blue balloons. You support for blue balloons on this day is **50%**. On another day, you begin carrying red balloons, attracting new prospective customers. Your daily sales are exactly the same as before, with the addition of **2** red balloons. Despite your total balloon sales being 1.25 times greater, your support for blue balloons has now dropped to **40%**. This is because *support is relative*.

Essentially, the greater the number of different products sold, the lower the support any typical item would be expected to have (assuming a consistent distribution of sales). With a more diverse selection of products, expect to have lower support for each product. On the other hand, if you only sell a single product, the support for that product will be 100%.

Support can also be applied to combinations of itemsets within the same transaction(s). For itemsets containing only 2 items $X$ and $Y$, support can be written as:

$Support(X \& Y) = \frac{Frequency(X\&Y)}{N}$

Where $Frequency(X\&Y)$ are the count of transactions having *both* products $X$ and $Y$, and where $N$ is the total number of transactions. Note that the support between two items of the same itemset remains the same, regardless of whether one is an antecedent or consequent; i.e. $Support(X \rightarrow Y) = Support(Y \rightarrow X)$

| Itemset                |   Support |
|:-----------------------|----------:|
| ('bread', 'butter')    |      0.67 |
| ('bread', 'milk')      |      0.58 |
| ('butter', 'milk')     |      0.58 |
| ('butter', 'egg')      |      0.33 |
| ('bread', 'cookies')   |      0.33 |
| ('butter', 'ketchup')  |      0.25 |
| ('butter', 'cookies')  |      0.25 |
| ('cookies', 'milk')    |      0.25 |
| ('bread', 'egg')       |      0.17 |
| ('egg', 'milk')        |      0.17 |
| ('ketchup', 'milk')    |      0.17 |
| ('bread', 'ketchup')   |      0.17 |
| ('butter', 'butter')   |      0.08 |
| ('egg', 'ketchup')     |      0.08 |
| ('cookies', 'egg')     |      0.08 |
| ('cookies', 'ketchup') |      0.08 |

### Confidence
**Confidence** measures how often a consequent item is bought, given that an antecedent item has been purchased. $Confidence(X \rightarrow Y)$ is the probability that Item $Y$ will be purchased, given the purchase of Item $X$.

$Confidence(X \rightarrow Y) = \frac{Support(X \& Y)}{Support(X)}$

Confidence is a strong rule to follow, but it is also heavily favorable towards consequent items with high support values. To put it another way, confidence is typically higher for rules where the predicted item(s) is common, regardless of whether or not a strong association exists. This is when context from other metrics becomes helpful.

Here is what the Confidence looks like for various rules in our earlier set of transactions:

| Antecedents   | Consequents   |   Confidence |\|| Antecedents   | Consequents   |   Confidence |
|:--------------|:--------------|----------:|---|:--------------|:--------------|----------:|
| Egg           | Butter        |  1        |\|| Bread         | Cookies       |  0.4      |
| Butter        | Bread         |  0.888889 |\|| Egg           | Ketchup       |  0.333333 |
| Bread         | Butter        |  0.8      |\|| Butter        | Cookies       |  0.333333 |
| Cookies       | Bread         |  0.8      |\|| Ketchup       | Egg           |  0.333333 |
| Milk          | Bread         |  0.777778 |\|| Butter        | Egg           |  0.333333 |
| Bread         | Milk          |  0.7      |\|| Ketchup       | Cookies       |  0.333333 |
| Ketchup       | Butter        |  0.666667 |\|| Egg           | Cookies       |  0.333333 |
| Ketchup       | Bread         |  0.666667 |\|| Milk          | Cookies       |  0.333333 |
| Egg           | Bread         |  0.666667 |\|| Milk          | Ketchup       |  0.222222 |
| Egg           | Milk          |  0.666667 |\|| Milk          | Egg           |  0.222222 |
| Ketchup       | Milk          |  0.666667 |\|| Butter        | Ketchup       |  0.222222 |
| Milk          | Butter        |  0.666667 |\|| Bread         | Ketchup       |  0.2      |
| Butter        | Milk          |  0.666667 |\|| Bread         | Egg           |  0.2      |
| Cookies       | Butter        |  0.6      |\|| Cookies       | Egg           |  0.2      |
| Cookies       | Milk          |  0.6      |\|| Cookies       | Ketchup       |  0.2      |

You'll notice that this table is much longer than the prior support table. That is because. Confidence is a "directional" metric, meaning that order matters. In terms of probability, confidence operates off of *permutations* of antecedent-consequent pairings, instead of *combinations* alone. This means that the number of different antecedent-consequent selections will often be exponentially higher than the amount of itemset combinations calculated in a support table. In a scenario with 6 items and itemsets of length 2, the number of possible combinations is 15, and the number of possible permutations is 30. For itemsets of length 3, the number of antecedent-consequent pairings can be *over* 20 combinations and 120 permutations (* "over", because we're effectively performing combination formulas on top of other combination/permutation formulas; "{bread, milk} -> {butter}" is a different rule from "{bread} -> {milk, butter}").

As baskets incorporate more and more products, the ways to build various antecedent-consequent rule combinations will skyrocket to a point that is nonviable. We'll discuss how to deal with this later on.

### Lift
**Lift** measures the strength of the association between $X$ and $Y$, compared to when the two items or itemsets are independent. It is calculated as the ratio of the observed support to the expected support if the items were selected independently. In simpler terms, it tells us how much more or less likely two associated items are to be bought together than by chance.

$Lift(X \& Y) = \frac{Support(X \& Y)}{Support(X) \times Support(Y)}$

\*OR\*

$Lift(X \& Y) = \frac{Observed~Support}{Expected~Support}$

The support values in this formula can also be thought of in terms of probability: $P(X)$, $P(Y)$, and  $P(X∩Y)$. The value of lift relative to 1 indicates the degree of association or disassociation( * "disassociation" meaning that purchasing one indicates the other *won't* be purchased).
- **Lift > 1**: The items are positively associated, meaning the occurrence of one item increases the likelihood of the other item being purchased.
- **Lift = 1**: The items are independent, meaning there's no association between them.
- **Lift < 1**: The items are negatively associated, meaning the occurrence of one item decreases the likelihood of the other item being purchased.

Lift is not directional, so it does not matter which items in a set represent the antecedent(s) or consequent(s). Like support, the lift values of the rules "𝑋 -> 𝑌" and "𝑌 -> 𝑋" are equivalent.

| Antecedents           | Consequents           |   Lift   |\|| Antecedents           | Consequents           |   Lift   |
|:----------------------|:----------------------|:---------|---|:----------------------|:----------------------|:---------|
| Egg                   | Ketchup               |  1.33333 |\|| Milk                  | Ketchup               |  0.88889 |
| Egg                   | Butter                |  1.33333 |\|| Butter                | Milk                  |  0.88889 |
| Butter                | Egg                   |  1.33333 |\|| Milk                  | Butter                |  0.88889 |
| Ketchup               | Egg                   |  1.33333 |\|| Ketchup               | Cookies               |  0.8     |
| Butter                | Bread                 |  1.06667 |\|| Bread                 | Egg                   |  0.8     |
| Bread                 | Butter                |  1.06667 |\|| Ketchup               | Bread                 |  0.8     |
| Bread                 | Cookies               |  0.96    |\|| Bread                 | Ketchup               |  0.8     |
| Cookies               | Bread                 |  0.96    |\|| Egg                   | Bread                 |  0.8     |
| Bread                 | Milk                  |  0.93333 |\|| Cookies               | Milk                  |  0.8     |
| Milk                  | Bread                 |  0.93333 |\|| Egg                   | Cookies               |  0.8     |
| Ketchup               | Butter                |  0.88889 |\|| Cookies               | Egg                   |  0.8     |
| Butter                | Ketchup               |  0.88889 |\|| Milk                  | Cookies               |  0.8     |
| Milk                  | Egg                   |  0.88889 |\|| Cookies               | Ketchup               |  0.8     |
| Egg                   | Milk                  |  0.88889 |\|| Butter                | Cookies               |  0.8     |
| Ketchup               | Milk                  |  0.88889 |\|| Cookies               | Butter                |  0.8     |


### Leverage
**Leverage** is similar to lift but focuses on the *difference* between the observed and expected support, instead of the ratio between them.

$Leverage(X \& Y) = {Support(X \& Y)} - {Support(X) \times Support(Y)}$

\*OR\*

$Leverage(X \& Y) = {Observed~Support}-{Expected~Support}$

The value of leverage relative to 0 indicates the degree of association or disassociation.

- **Leverage > 0** (*Positive*): The items appear together more frequently than expected by chance, indicating a positive association.
- **Leverage = 0** (*Neutral*): The items are independent, meaning there is no difference between the observed and expected co-occurrence of the items.
- **Leverage < 0** (*Negative*): The items appear together less frequently than expected, indicating a negative association.

Like lift, leverage is non-directional. Leverage is somewhat more influenced by the support of the itemset than lift, but this relationship is not as strong as the one between confidence and consequent support.

| Antecedents           | Consequents           |   Leverage  |\|| Antecedents           | Consequents           |   Leverage  |
|:----------------------|:----------------------|------------:|---|:----------------------|:----------------------|------------:|
| Butter                | Egg                   |  0.0625     |\|| Egg                   | Milk                  | -0.0208333  |
| Egg                   | Butter                |  0.0625     |\|| Milk                  | Ketchup               | -0.0208333  |
| Butter                | Bread                 |  0.0416667  |\|| Ketchup               | Milk                  | -0.0208333  |
| Bread                 | Butter                |  0.0416667  |\|| Milk                  | Bread                 | -0.0416667  |
| Egg                   | Ketchup               |  0.0208333  |\|| Bread                 | Milk                  | -0.0416667  |
| Ketchup               | Egg                   |  0.0208333  |\|| Bread                 | Ketchup               | -0.0416667  |
| Bread                 | Cookies               | -0.0138889  |\|| Ketchup               | Bread                 | -0.0416667  |
| Cookies               | Bread                 | -0.0138889  |\|| Bread                 | Egg                   | -0.0416667  |
| Butter                | Ketchup               | -0.0208333  |\|| Egg                   | Bread                 | -0.0416667  |
| Ketchup               | Butter                | -0.0208333  |\|| Butter                | Cookies               | -0.0625     |
| Egg                   | Cookies               | -0.0208333  |\|| Milk                  | Cookies               | -0.0625     |
| Cookies               | Egg                   | -0.0208333  |\|| Cookies               | Butter                | -0.0625     |
| Cookies               | Ketchup               | -0.0208333  |\|| Milk                  | Butter                | -0.0625     |
| Ketchup               | Cookies               | -0.0208333  |\|| Butter                | Milk                  | -0.0625     |
| Milk                  | Egg                   | -0.0208333  |\|| Cookies               | Milk                  | -0.0625     |

### Conviction

**Conviction** compares the expected and actual frequency of $X$ occurring without $Y$. It shows how likely $X$ happening means that $Y$ won’t happen. A high conviction value means $X$ and $Y$ are closely linked, and that the first event rarely happens without the second event. The formula for conviction is sort of like an inverted version of the lift formula:

$Conviction(X \rightarrow Y) = \frac{Support(X) \times Support(\bar{Y})}{Support(X \& \bar{Y})}$

Where the $\bar{Y}$ in $Support(\bar{Y})$ and ${Support(X \& \bar{Y})}$ refers to an occurrence of item 𝑌 **not** appearing in a transaction.

- **Conviction > 1**: The rule is stronger, meaning the consequent is more likely to appear when the antecedent occurs. The higher the conviction, the stronger the rule.
- **Conviction = 1**: The rule is not informative—there is no improvement in predicting the consequent given the antecedent.
- **Conviction < 1**: The rule is less reliable, meaning the antecedent has little influence on the occurrence of the consequent.

| Antecedents           | Consequents           |   Conviction |\|| Antecedents           | Consequents           |   Conviction  |
|:----------------------|:----------------------|-------------:|---|:----------------------|:----------------------|------------:|
| Egg                   | Butter                |   inf        |\|| Ketchup               | Cookies               |     0.875    |
| Butter                | Bread                 |     1.5      |\|| Milk                  | Cookies               |     0.875    |
| Bread                 | Butter                |     1.25     |\|| Butter                | Cookies               |     0.875    |
| Egg                   | Ketchup               |     1.125    |\|| Bread                 | Milk                  |     0.833333 |
| Ketchup               | Egg                   |     1.125    |\|| Cookies               | Bread                 |     0.833333 |
| Butter                | Egg                   |     1.125    |\|| Ketchup               | Butter                |     0.75     |
| Bread                 | Cookies               |     0.972222 |\|| Egg                   | Milk                  |     0.75     |
| Milk                  | Ketchup               |     0.964286 |\|| Ketchup               | Milk                  |     0.75     |
| Butter                | Ketchup               |     0.964286 |\|| Milk                  | Bread                 |     0.75     |
| Milk                  | Egg                   |     0.964286 |\|| Milk                  | Butter                |     0.75     |
| Cookies               | Egg                   |     0.9375   |\|| Butter                | Milk                  |     0.75     |
| Bread                 | Egg                   |     0.9375   |\|| Cookies               | Butter                |     0.625    |
| Bread                 | Ketchup               |     0.9375   |\|| Cookies               | Milk                  |     0.625    |
| Cookies               | Ketchup               |     0.9375   |\|| Ketchup               | Bread                 |     0.5      |
| Egg                   | Cookies               |     0.875    |\|| Egg                   | Bread                 |     0.5      |

### Zhang's Metric
**Zhang's Metric** measures the association or disassociation between two items in transaction data. The metric is set on a scale from -1 to 1, like leverage. Positive values mean the items are more likely to be associated, negative values mean they’re more likely to be disassociated, and values close to zero suggest no significant connection.

$Zhang(X \rightarrow Y) = \frac{{Confidence(X \rightarrow Y)}  -  {Confidence(\bar{X} \rightarrow Y)}}{Max[{Confidence(X \rightarrow Y)}  ,  {Confidence(\bar{X} \rightarrow Y)}]}$

| Antecedents           | Consequents           |   Zhangs Metric |\|| Antecedents           | Consequents           |   Zhangs Metric  |
|:----------------------|:----------------------|----------------:|---|:----------------------|:----------------------|------------:|
| Butter                | Egg                   |       1         |\|| Ketchup               | Cookies               |      -0.25      |
| Bread                 | Butter                |       0.375     |\|| Bread                 | Milk                  |      -0.3       |
| Egg                   | Butter                |       0.333333  |\|| Cookies               | Butter                |      -0.3       |
| Egg                   | Ketchup               |       0.333333  |\|| Cookies               | Milk                  |      -0.3       |
| Ketchup               | Egg                   |       0.333333  |\|| Cookies               | Egg                   |      -0.3       |
| Butter                | Bread                 |       0.25      |\|| Cookies               | Ketchup               |      -0.3       |
| Cookies               | Bread                 |      -0.0666667 |\|| Milk                  | Butter                |      -0.333333  |
| Ketchup               | Milk                  |      -0.142857  |\|| Butter                | Milk                  |      -0.333333  |
| Egg                   | Milk                  |      -0.142857  |\|| Butter                | Ketchup               |      -0.333333  |
| Ketchup               | Butter                |      -0.142857  |\|| Milk                  | Egg                   |      -0.333333  |
| Bread                 | Cookies               |      -0.2       |\|| Milk                  | Ketchup               |      -0.333333  |
| Milk                  | Bread                 |      -0.222222  |\|| Milk                  | Cookies               |      -0.5       |
| Egg                   | Cookies               |      -0.25      |\|| Butter                | Cookies               |      -0.5       |
| Egg                   | Bread                 |      -0.25      |\|| Bread                 | Ketchup               |      -0.6       |
| Ketchup               | Bread                 |      -0.25      |\|| Bread                 | Egg                   |      -0.6       |


# -------------------------------------------------------------------------

![bakery stock image](https://media.triple.guide/triple-cms/c_limit,f_auto,h_2048,w_2048/06a8b0e4-7f4c-45bb-b8fb-7818a345a295.jpeg)

# Bakery Sales Data

This dataset covers transactions from a Korean bakery, and [comes from Kaggle](https://www.kaggle.com/datasets/hosubjeong/bakery-sales/data). From the user:

> ### About Dataset
>
>
> #### Context
>
> I worked part-time at a small bakery in Korea.
>
> Our bakery started the delivery service in July 2019.
>
> Our store delivers to customers through a platform called Bea Min.
>
> I collected this data and analyzed it to share it with my coworkers.
>
>
> #### Content
>
> It's a basket data.
>
> There are 27 columns.
> - datetime : order time
> - day of week: day of the week. our bakery usually closes Tues day.
> - total: Total Amount.
> - place: customer's place
> - angbutter: It's a pain's name. Pretzel filled with red beans and gourmet butter. you can check this link. https://www.10000recipe.com/recipe/6927002
> - plain bread: plain bread.
> - jam: peach jam.
> - americano: americano
> - croissant: croissnat.
> - caffe latte: caffe laffe.
> - tiramisu croissant: Croissants filled with tiramisu cream and fruit.
> - cacao deep: Croissant covered in Valrhona chocolate
> - pain au chocolate: Pain au chocolate.
> - almond croissant: Croissant filled with almond cream.
> - croque monsieur:
> - mad garlic:
> - milk tea: Mariage Frères milk tea.
> - gateau chocolat: piece of chocolate cake.
> - pandoro: pandoro: Italian pain.
> - cheese cake: Cheese cake.
> - lemon ade: Lemon ade
> - orange pound: Orange pound cake.
> - wiener: sausage bread.
> - vanila latte: Brewed with Madagascar vanilla bean.
> - berry ade: berry ade.
> - tiramisu: tiramisu cake.
> - merinque cookies: cookies."

I've uploaded [a copy of the CSV data on my GitHub page](https://github.com/bryantjay/Portfolio/blob/main/Korean%20Bakery%20Market%20Basket%20Analysis/source_files/Bakery%20Sales.csv), and will source my data workflow from there.

### Read-in

First step is to read in the data and make sure it's present. We'll use `pandas` for this. We'll later be using the `matplotlib`, `seaborn`, and `mlxtend` packages as well.


```python
# Import necessary packages
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from mlxtend.frequent_patterns import apriori, association_rules

# Create URL path assignment to CSV data
path = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/Korean%20Bakery%20Market%20Basket%20Analysis/source_files/Bakery%20Sales.csv"

# Load the dataset
bakery_data = pd.read_csv(path)

# Check the first few rows of the dataset
print(bakery_data.head().to_markdown())
```

    |    | datetime         | day of week   |   total |   place |   angbutter |   plain bread |   jam |   americano |   croissant |   caffe latte |   tiramisu croissant |   cacao deep |   pain au chocolat |   almond croissant |   croque monsieur |   mad garlic |   milk tea |   gateau chocolat |   pandoro |   cheese cake |   lemon ade |   orange pound |   wiener |   vanila latte |   berry ade |   tiramisu |   merinque cookies |
    |---:|:-----------------|:--------------|--------:|--------:|------------:|--------------:|------:|------------:|------------:|--------------:|---------------------:|-------------:|-------------------:|-------------------:|------------------:|-------------:|-----------:|------------------:|----------:|--------------:|------------:|---------------:|---------:|---------------:|------------:|-----------:|-------------------:|
    |  0 | 2019-07-11 15:35 | Thur          |   23800 |     nan |           1 |           nan |   nan |           1 |         nan |           nan |                    3 |          nan |                nan |                nan |               nan |          nan |        nan |               nan |       nan |           nan |         nan |            nan |      nan |              1 |         nan |        nan |                nan |
    |  1 | 2019-07-11 16:10 | Thur          |   15800 |     nan |           1 |           nan |   nan |         nan |         nan |           nan |                    1 |          nan |                nan |                nan |               nan |          nan |        nan |               nan |       nan |           nan |         nan |              1 |      nan |            nan |         nan |        nan |                nan |
    |  2 | 2019-07-12 11:49 | Fri           |   58000 |     nan |         nan |           nan |   nan |         nan |         nan |           nan |                   14 |          nan |                nan |                nan |               nan |          nan |        nan |               nan |       nan |           nan |         nan |            nan |      nan |            nan |         nan |        nan |                nan |
    |  3 | 2019-07-13 13:19 | Sat           |   14800 |     nan |           1 |             1 |   nan |         nan |         nan |           nan |                  nan |          nan |                nan |                nan |               nan |          nan |        nan |               nan |       nan |           nan |         nan |            nan |      nan |              1 |         nan |        nan |                nan |
    |  4 | 2019-07-13 13:22 | Sat           |   15600 |     nan |           2 |           nan |   nan |         nan |         nan |           nan |                    1 |          nan |                nan |                nan |               nan |          nan |        nan |               nan |       nan |           nan |         nan |            nan |      nan |            nan |         nan |        nan |                nan |
    

Given the dataset owner's initial description, we already know that the dataset is in a wide format. Each row of the data represents a single transaction. It is not yet encoded, however. Instead each product column represents a quantity of an item sold. There are also additional fields detailing the time and delivery place for a transaction.

### Data Exploration

We'll take a look at the dataset and column attributes with calls to the `info()` and `describe()` methods.


```python
print(bakery_data.info())
print(bakery_data.describe(include='all').to_markdown())
```

    <class 'pandas.core.frame.DataFrame'>
    RangeIndex: 2654 entries, 0 to 2653
    Data columns (total 27 columns):
     #   Column              Non-Null Count  Dtype  
    ---  ------              --------------  -----  
     0   datetime            2421 non-null   object 
     1   day of week         2420 non-null   object 
     2   total               2420 non-null   float64
     3   place               2166 non-null   object 
     4   angbutter           1973 non-null   float64
     5   plain bread         857 non-null    float64
     6   jam                 220 non-null    float64
     7   americano           412 non-null    float64
     8   croissant           747 non-null    float64
     9   caffe latte         193 non-null    float64
     10  tiramisu croissant  779 non-null    float64
     11  cacao deep          323 non-null    float64
     12  pain au chocolat    587 non-null    float64
     13  almond croissant    202 non-null    float64
     14  croque monsieur     0 non-null      float64
     15  mad garlic          0 non-null      float64
     16  milk tea            137 non-null    float64
     17  gateau chocolat     196 non-null    float64
     18  pandoro             343 non-null    float64
     19  cheese cake         90 non-null     float64
     20  lemon ade           35 non-null     float64
     21  orange pound        519 non-null    float64
     22  wiener              355 non-null    float64
     23  vanila latte        209 non-null    float64
     24  berry ade           54 non-null     float64
     25  tiramisu            7 non-null      float64
     26  merinque cookies    47 non-null     float64
    dtypes: float64(24), object(3)
    memory usage: 560.0+ KB
    None
    |        | datetime         | day of week   |         total | place   |   angbutter |   plain bread |        jam |   americano |   croissant |   caffe latte |   tiramisu croissant |   cacao deep |   pain au chocolat |   almond croissant |   croque monsieur |   mad garlic |   milk tea |   gateau chocolat |    pandoro |   cheese cake |   lemon ade |   orange pound |     wiener |   vanila latte |   berry ade |   tiramisu |   merinque cookies |
    |:-------|:-----------------|:--------------|--------------:|:--------|------------:|--------------:|-----------:|------------:|------------:|--------------:|---------------------:|-------------:|-------------------:|-------------------:|------------------:|-------------:|-----------:|------------------:|-----------:|--------------:|------------:|---------------:|-----------:|---------------:|------------:|-----------:|-------------------:|
    | count  | 2421             | 2420          |  2420         | 2166    |  1973       |    857        | 220        |  412        |   747       |    193        |            779       |   323        |         587        |         202        |                 0 |            0 | 137        |        196        | 343        |     90        |   35        |     519        | 355        |     209        |   54        |          7 |           47       |
    | unique | 2361             | 7             |   nan         | 19      |   nan       |    nan        | nan        |  nan        |   nan       |    nan        |            nan       |   nan        |         nan        |         nan        |               nan |          nan | nan        |        nan        | nan        |    nan        |  nan        |     nan        | nan        |     nan        |  nan        |        nan |          nan       |
    | top    | 2019-11-09 11:36 | Sun           |   nan         | 동면    |   nan       |    nan        | nan        |  nan        |   nan       |    nan        |            nan       |   nan        |         nan        |         nan        |               nan |          nan | nan        |        nan        | nan        |    nan        |  nan        |     nan        | nan        |     nan        |  nan        |        nan |          nan       |
    | freq   | 9                | 554           |   nan         | 416     |   nan       |    nan        | nan        |  nan        |   nan       |    nan        |            nan       |   nan        |         nan        |         nan        |               nan |          nan | nan        |        nan        | nan        |    nan        |  nan        |     nan        | nan        |     nan        |  nan        |        nan |          nan       |
    | mean   | nan              | nan           | 21172.5       | nan     |     1.63659 |      1.19953  |   1.13182  |    1.24515  |     1.40428 |      1.10881  |              1.21309 |     1.12693  |           1.2368   |           1.16337  |               nan |          nan |   1.16788  |          1.07143  |   1.14869  |      1.02222  |    1.08571  |       1.09056  |   1.34085  |       1.15311  |    1.01852  |          1 |            1.04255 |
    | std    | nan              | nan           | 26997.3       | nan     |     1.11564 |      0.510268 |   0.433617 |    0.527216 |     1.0277  |      0.373016 |              0.79735 |     0.393249 |           0.601598 |           0.476351 |               nan |          nan |   0.576109 |          0.258199 |   0.499757 |      0.148231 |    0.373491 |       0.306757 |   0.614692 |       0.523948 |    0.136083 |          0 |            0.20403 |
    | min    | nan              | nan           | 12800         | nan     |     1       |      1        |   1        |    1        |     1       |      1        |              1       |     1        |           1        |           1        |               nan |          nan |   1        |          1        |   1        |      1        |    1        |       1        |   1        |       1        |    1        |          1 |            1       |
    | 25%    | nan              | nan           | 15800         | nan     |     1       |      1        |   1        |    1        |     1       |      1        |              1       |     1        |           1        |           1        |               nan |          nan |   1        |          1        |   1        |      1        |    1        |       1        |   1        |       1        |    1        |          1 |            1       |
    | 50%    | nan              | nan           | 18500         | nan     |     1       |      1        |   1        |    1        |     1       |      1        |              1       |     1        |           1        |           1        |               nan |          nan |   1        |          1        |   1        |      1        |    1        |       1        |   1        |       1        |    1        |          1 |            1       |
    | 75%    | nan              | nan           | 23000         | nan     |     2       |      1        |   1        |    1        |     2       |      1        |              1       |     1        |           1        |           1        |               nan |          nan |   1        |          1        |   1        |      1        |    1        |       1        |   2        |       1        |    1        |          1 |            1       |
    | max    | nan              | nan           |     1.293e+06 | nan     |    11       |      5        |   5        |    5        |    16       |      3        |             14       |     4        |           6        |           5        |               nan |          nan |   6        |          2        |   5        |      2        |    3        |       4        |   6        |       4        |    2        |          1 |            2       |
    

The outputs inform us about the number of transactions each bakery item is included in, which is helpful. The 'Non-Null Count' of the `info()` call effectively already summarizes this count of transactions for each product field. If a transation includes a sale of a product, the quantity sold for that product is recorded as an integer; otherwise, it will be a null value. We can see top-performing products include the plain bread, the croissant, and the angbutter bread (a Korean signature pastry). The angbutter pastry accounts for the most sales of any single product. Additionally, we can also observe that items like the croque monsieur, the "mad garlic", and the tiramisu are pretty weak sellers by comparison. In fact, the items "croque monsieur" and the "mad garlic" do not feature any sales in this dataset at all!

#### Simultaneous Transactions

We can see that the basket data has already been set to a wide format, where each bakery item has been encoded in a numeric fashion (though, not one-hot encoded). Each row covers a separate transaction, and can include multiple items.

There are instances of multiple transactions occurring at the same time and place, so let's check this out by sorting the datetime value counts.


```python
# Some instances of simultaneous transactions at the same locations
print(bakery_data[['datetime', 'place']].value_counts().sort_values(ascending=False), "\n\n")

# These seem to represent distinct transactions, and not duplicates.
print(bakery_data[(bakery_data.datetime == "2019-10-03 14:50") & (bakery_data.place == "후평 2동")])
```

    datetime          place
    2019-10-03 14:50  후평 2동    2
    2019-10-21 11:27  강남동      2
    2020-04-02 13:12  석사동      2
    2020-03-01 11:06  동면       2
    2020-02-02 11:05  동면       2
                              ..
    2020-05-01 15:03  동면       1
    2020-05-01 15:19  동면       1
    2020-05-02 11:37  동면       1
    2020-05-02 11:39  후평 1동    1
    2020-05-02 14:45  효자 1동    1
    Name: count, Length: 2158, dtype: int64 
    
    
                 datetime day of week    total  place  angbutter  plain bread  \
    684  2019-10-03 14:50        Thur  21800.0  후평 2동        1.0          1.0   
    685  2019-10-03 14:50        Thur  15400.0  후평 2동        2.0          NaN   
    
         jam  americano  croissant  caffe latte  ...  gateau chocolat  pandoro  \
    684  NaN        NaN        1.0          NaN  ...              NaN      NaN   
    685  NaN        NaN        NaN          NaN  ...              1.0      NaN   
    
         cheese cake  lemon ade  orange pound  wiener  vanila latte  berry ade  \
    684          NaN        NaN           NaN     NaN           NaN        NaN   
    685          NaN        NaN           NaN     NaN           NaN        NaN   
    
         tiramisu  merinque cookies  
    684       NaN               NaN  
    685       NaN               NaN  
    
    [2 rows x 27 columns]
    

It seems that the simultaneous transactions are valid data observations, as they represent non-duplicated orders.

#### Datetime Coersion

The 'datetime' field was initially parsed into the dataframe as a column of strings, so it should be coerced to a correct datatype for some bried exploratory analysis. We'll take a look at the earliest and latest dates, as well.


```python
# Make sure the 'datetime' column is in the correct datetime format
bakery_data['datetime'] = pd.to_datetime(bakery_data['datetime'])

# Find the minimum and maximum datetime values
min_datetime = bakery_data['datetime'].min()
max_datetime = bakery_data['datetime'].max()

# Print the results
print(f"Minimum datetime: {min_datetime}")
print(f"Maximum datetime: {max_datetime}")
```

    Minimum datetime: 2019-07-11 15:35:00
    Maximum datetime: 2020-06-18 14:52:00
    

#### Delivery Locations

The data uploader states the bakery they work at delivers to customers through a platform called "Bea Min". The data column 'place' references the rough delivery location of a customer. These locations appear to be general regions instead of specific addresses. There are 19 different regions in total. Here's a closer look at how they're dstributed:


```python
print(bakery_data.place.value_counts().sort_values(ascending=False))

print(bakery_data.place.unique())
```

    place
    동면       416
    후평 2동    254
    후평 3동    249
    후평 1동    196
    석사동      169
    퇴계동      146
    효자 2동    143
    소양동      132
    신사우동      91
    효자 3동     80
    교동        65
    강남동       52
    효자 1동     50
    조운동       37
    동내면       31
    근화동       29
    약사명동      23
    교동         2
    신동면        1
    Name: count, dtype: int64
    [nan '효자 3동' '후평 1동' '후평 2동' '석사동' '소양동' '퇴계동' '동면' '후평 3동' '신사우동' '강남동'
     '효자 1동' '조운동' '교동' '효자 2동' '약사명동' '근화동' '동내면' '교동 ' '신동면']
    

Most of the place names are written in Hangul(Korean) script, which is not a writing style I'm personally familiar with. To make this a little easier, let's first transliterate each delivery location names to Roman script. I achieved the mapping by running the origial Hangul script through Google Translate, but I can't verify it due to lack of knowledge. I'll take Google's word for it.

I would like to note that there are two distinct place categories with the spelling "교동" ("Gyo-dong"), with the second version only having two transaction entries. Upon closer insection, this is due to the presence of some trailing whitespace for the second variant of the place location; despite my lack of Korean knowledge, this seems to be a data-entry error, and will be corrected. There is another entry "신동면" ("Sindong-myeon") which might be a typo of "동면" ("Dongmyeon"), but I do not have the expertise to reasonably confirm this; this spelling will stay as is.


```python
# Translation dictionary
place_translation = {
    '효자 3동': 'Hyoja 3-dong',
    '후평 1동': 'Hupyeong 1-dong',
    '후평 2동': 'Hupyeong 2-dong',
    '석사동': 'Seoksadong',
    '소양동': 'Soyangdong',
    '퇴계동': 'Toegye-dong',
    '동면': 'Dongmyeon',
    '후평 3동': 'Hupyeong 3-dong',
    '신사우동': 'Sinsa-u-dong',
    '강남동': 'Gangnam-dong',
    '효자 1동': 'Hyoja 1-dong',
    '조운동': 'Jo-un-dong',
    '교동': 'Gyo-dong',
    '효자 2동': 'Hyoja 2-dong',
    '약사명동': 'Yaksamyeong-dong',
    '근화동': 'Geunhwa-dong',
    '동내면': 'Dongnae-myeon',
    '교동 ': 'Gyo-dong',
    '신동면': 'Sindong-myeon'
}

# Replace values in the 'place' column of your DataFrame
bakery_data['place'] = bakery_data['place'].map(place_translation).fillna(bakery_data['place'])

```

Now that we've transliterated our place names, let's view the above set of transaction counts per store in the form of a bar graph. I'll use the FiveThirtyEight-inspired Matplot style.


```python
plt.style.use('fivethirtyeight')

# Count the number of transactions for each place and sort in descending order
place_counts = bakery_data['place'].value_counts().sort_values(ascending=True)

# Create the bar chart with switched axes
plt.figure(figsize=(10, 6))
place_counts.plot(kind='barh', color='skyblue')  # 'barh' for horizontal bars

# Add labels and title
plt.title('Transaction Counts by Place', fontsize=14)
plt.ylabel('Place', fontsize=12)
plt.xlabel('Number of Transactions', fontsize=12)

# Add faint grid lines along the x-axis (horizontal grid lines)
plt.grid(axis='x', linestyle='--', alpha=0.75)
# Dropping gridlines from the place axis
plt.grid(axis='y', linestyle='--', alpha=0)

# Show the plot
plt.tight_layout()
plt.show()

```


    
![png](output_39_0.png)
    


This is an interesting look at which areas the bakery sees the most customer demand coming from (in the form of their delivery operations, anyways).

#### Product Sales

As this is a market basket analysis, I'm mostly concerned with the success of each of the various items sold in the bakery. I'm going to use another bar graph, but this time plotting both the total quantities of each item sold and the total number of transactions each item appears in. We'll use this plot format once again in a little bit, so I'll also save it as a custom function.

Since we know from the earlier `decribe()` call that there are no 'croque monsieur' or 'mad garlic' sales, these two columns can be dropped.


```python
# Drop empty product columns 'croque monsieur' and 'mad garlic'
bakery_data = bakery_data.drop(columns=['croque monsieur', 'mad garlic'])

# List of product columns (replace these with actual product column names from your data)
product_columns = ['angbutter', 'plain bread', 'jam', 'americano', 'croissant', 
                   'caffe latte', 'tiramisu croissant', 'cacao deep', 'pain au chocolat', 
                   'almond croissant', 'milk tea', 'gateau chocolat', 'pandoro',
                   'cheese cake', 'lemon ade', 'orange pound', 'wiener',
                   'vanila latte', 'berry ade', 'tiramisu',  'merinque cookies']

def sales_plot(df, p_cols):
    # 1. Calculate the total quantities of each product across all transactions
    total_quantities = df[p_cols].sum()

    # 2. Calculate the number of transactions each product appears in (i.e., count non-zero entries)
    transaction_counts = (df[p_cols] > 0).sum()

    # 3. Combine both metrics into one DataFrame for easy plotting
    metrics_df = pd.DataFrame({
        'Product': p_cols,
        'Total Quantity': total_quantities,
        'Transaction Count': transaction_counts
    })

    # 4. Sort by Total Quantity (ascending order)
    metrics_df = metrics_df.sort_values(by='Total Quantity', ascending=True)

    # 5. Set up a position range for the bars
    x = range(len(metrics_df))

    # 7. Create a figure and axis object
    fig, ax = plt.subplots(figsize=(15, 10))

    # 8. Plot Total Quantity (larger bar width)
    ax.barh(x, metrics_df['Total Quantity'], 0.8, color='seagreen', label='Total Quantity')

    # 9. Plot Transaction Count (smaller bar width, overlayed on top of Total Quantity)
    ax.barh(x, metrics_df['Transaction Count'], 0.3, color='mintcream', label='Transaction Count')

    # 10. Set labels and title
    ax.set_yticks(x)
    ax.set_yticklabels(metrics_df['Product'])
    ax.set_xlabel('Count', fontsize=12)
    ax.set_title('Total Quantity vs Transaction Count for Each Product', fontsize=14)

    # Move the legend to the upper left corner
    ax.legend(facecolor='darkgray', edgecolor='black', loc=(0.7, 0.1))


    # Dropping gridlines from the product axis
    plt.grid(axis='y', linestyle='--', alpha=0)

    # Show plot
    plt.tight_layout()
    plt.show()

sales_plot(bakery_data, product_columns)
```


    
![png](output_41_0.png)
    


The angbutter pastry is by far the highest-selling single item, and often even sells in multiples per transaction. It must be pretty good!

Lets view the share of total sales each different product has between delivery locations.


```python
# 1. Group the data by 'place' and sum the quantities for each product
product_place_data = bakery_data.groupby('place')[product_columns].sum()

# 2. Normalize each row by dividing by the row total to get the percentage of total sales per store
product_place_data_percentage = product_place_data.div(product_place_data.sum(axis=1), axis=0) * 100

# 3. Create the heatmap
plt.figure(figsize=(16, 10))  # Increase the figure dimensions

# Create custom annotations with percentage suffix
annot = product_place_data_percentage.round(2).applymap(lambda x: f"{x:.1f}%")

# Create the heatmap
sns.heatmap(product_place_data_percentage, annot=annot, cmap="YlGnBu", linewidths=0.5, annot_kws={'size': 10}, fmt='', cbar=False)

# 4. Set labels and title
plt.xlabel('Places', fontsize=12)
plt.ylabel('Products', fontsize=12)
plt.title('Product Sales Shares by Delivery Location', fontsize=14)

# 5. Show the plot
plt.tight_layout()
plt.show()
```

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_3036\3436993705.py:11: FutureWarning:
    
    DataFrame.applymap has been deprecated. Use DataFrame.map instead.
    
    


    
![png](output_43_1.png)
    


We can see that the angbutter pastries continue to dominate sales across every store location, often followed by plain bread and different croissant products. The share of sales between products seems to stay relatively consistent between delivery places.

Fair warning: Don't be fooled by exceptional pandoro and weiner sales from the "Sindong-myeon" location! Remember that there is only a single transaction for this 'place' entry.

Let's generate another heatmap, this time comparing the different products against themselves. We're going to be plotting the count of transactions each product is featured in, which is will be a more suitable metric for our market basket analysis. Again, I'm going to save this plot structure as a custom function to re-use later.


```python
def plot_heatmap(data, product_columns):
    
    # Create a binary matrix indicating if a product was purchased
    product_binary_data = data[product_columns].gt(0).astype(int)

    # Create co-occurrence matrix
    co_occurrence_matrix = product_binary_data.T.dot(product_binary_data)

    # Sort rows and columns alphabetically
    sorted_matrix = co_occurrence_matrix.sort_index(axis=0, ascending=False).sort_index(axis=1)

    # Plot the heatmap
    plt.figure(figsize=(16, 10))
    sns.heatmap(sorted_matrix, annot=True, annot_kws={'size': 10}, fmt="d", cmap="YlGnBu", linewidths=0.5, cbar=False)

    # Set labels and title
    plt.xlabel('Products', fontsize=12)
    plt.ylabel('Products', fontsize=12)
    plt.title('Heatmap of Transaction Counts for Products by Product (Alphabetical Order)', fontsize=14)

    # Display
    plt.tight_layout()
    plt.show()

plot_heatmap(bakery_data, product_columns)
```


    
![png](output_45_0.png)
    


Of course, angbutter is a top-seller! However, in this circumstance, it really only obfuscates potential insights that we might have drawn from other product interactions. Let's retry this same plot, this time withholding "angbutter" from our product columns.


```python
# List of product columns (without 'angbutter')
sans_angbutter = ['plain bread', 'jam', 'americano', 'croissant', 
                   'caffe latte', 'tiramisu croissant', 'cacao deep', 'pain au chocolat', 
                   'almond croissant', 'milk tea', 'gateau chocolat', 'pandoro', 
                   'cheese cake', 'lemon ade', 'orange pound', 'wiener', 'vanila latte',
                   'berry ade', 'tiramisu', 'merinque cookies']

plot_heatmap(bakery_data, sans_angbutter)
```


    
![png](output_47_0.png)
    


We can see some common interactions between typically high-sales items like the plain croissant, tiramisu croissant, plain bread, pain au chocolat, and the orange pound cake.

#### Sales by Weekday

Let's look at how sales are distributed across a typical week. This isn't crucial for performing a market basket analysis, but it does add some context for explaining potential associations or making recommendations to clients.


```python
# Sum the total sales by day of the week
bakery_data['total_sales'] = bakery_data[product_columns].sum(axis=1)
sales_by_weekday = bakery_data.groupby('day of week')['total_sales'].sum()

# Reorder the days of the week for correct order in the plot
ordered_weekdays = ['Mon', 'Tues', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun']
sales_by_weekday = sales_by_weekday[ordered_weekdays]

# Plot the bar chart
plt.figure(figsize=(10, 6))
sns.barplot(x=sales_by_weekday.index, y=sales_by_weekday.values, palette="Blues_d")

# Add labels and title
plt.title('Total Sales by Weekday', fontsize=14)
plt.xlabel('Day of Week', fontsize=12)
plt.ylabel('Total Sales (Quantity)', fontsize=12)

# Display the plot
plt.tight_layout()
plt.show()

```

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_3036\676401419.py:11: FutureWarning:
    
    
    
    Passing `palette` without assigning `hue` is deprecated and will be removed in v0.14.0. Assign the `x` variable to `hue` and set `legend=False` for the same effect.
    
    
    


    
![png](output_50_1.png)
    


Across the data set, there are a total of around 1500-2500 sales that occur on any given day of the week, except Tuesday. The weekends tend to see more sales than the rest of the week, with the most number of sales occurring on Sundays by a significant margin. Perhaps people have more time to spend at the local bakery outside of the workweek. It's noticeable that there are minimal transactions that occur on Tuesday, but *not* zero. It's likely that the bakery is not generally open for business on Tuesdays. Here's a closer look at the few transactions which *do* occur on a Tuesday:


```python
# Filter rows where the 'datetime' is on a Tuesday
tuesday_sales = bakery_data[bakery_data['day of week'] == 'Tues']

# Drop columns where all values are NaN
tuesday_sales = tuesday_sales.dropna(axis=1, how='all')

# Display the rows for Tuesday with cleaned columns
print(tuesday_sales.to_markdown())
```

    |      | datetime            | day of week   |   total | place           |   angbutter |   americano |   tiramisu croissant |   gateau chocolat |   cheese cake |   wiener |   merinque cookies |   total_sales |
    |-----:|:--------------------|:--------------|--------:|:----------------|------------:|------------:|---------------------:|------------------:|--------------:|---------:|-------------------:|--------------:|
    | 1277 | 2019-12-24 11:13:00 | Tues          |   15300 | Dongmyeon       |           1 |           1 |                    1 |               nan |           nan |      nan |                nan |             3 |
    | 1278 | 2019-12-24 11:17:00 | Tues          |   21400 | Jo-un-dong      |           3 |         nan |                  nan |               nan |           nan |        2 |                nan |             5 |
    | 1279 | 2019-12-24 13:14:00 | Tues          |   19300 | Hupyeong 1-dong |         nan |         nan |                    1 |                 1 |             1 |      nan |                  1 |             4 |
    

These Tuesday sales all happened on Christmas Eve! Maybe the transaction was part of some kind of employee Christmas party? Aside from this instance, it's pretty safe to say that the bakery is generally closed for business on Tuesdays.

#### Sales Over Time

After viewing how sales are distributed across all days of the week, it would also be good to take a look at the distribution of sales over time. We already know our earliest and latests dates in the data: July of 2019 and June of 2020. Let's see exactly how sales change within that time span.


```python
# Create a copy of the original df, "bakery_ts"
bakery_ts = bakery_data.copy()

# Set 'datetime' as the index
bakery_ts.set_index('datetime', inplace=True)

# Sum the total sales for all products
bakery_ts['total_sales'] = bakery_ts[product_columns].sum(axis=1)

# Resample/change the total product sales to weekly level-of-detail
weekly_sales = bakery_ts['total_sales'].resample('W').sum()

# Count the number of transactions (rows) per week
weekly_transactions = bakery_ts.resample('W').size()

# Initialize plot figure
plt.figure(figsize=(12, 6))

# Plot total item sales line
plt.plot(weekly_sales.index, weekly_sales.values, label='Items Sold', color='seagreen')

# Plot transaction count line
plt.plot(weekly_transactions.index, weekly_transactions.values, label='Number of Transactions', color='rosybrown')

# Add labels and title
plt.title('Weekly Sales', fontsize=14)
plt.xlabel('Week Of...', fontsize=12)
plt.ylabel('Weekly Total', fontsize=12)

# Position and format legend
plt.legend(facecolor='darkgray', edgecolor='black', loc=(0.75, 0.85))

# Display the plot
plt.tight_layout()
plt.show()
```


    
![png](output_54_0.png)
    


There is a tail at the end of this line graph seemingly caused by a data entry error. Here's a closer look:


```python
# Review all entries after the start of May 2020
print(bakery_ts[bakery_ts.index > "2020-05-01"][['day of week', 'total_sales']])

# This observation contains no item sales, and is out of the date range
print(bakery_data[bakery_data['datetime']=='2020-06-18 14:52:00'])
```

                        day of week  total_sales
    datetime                                    
    2020-05-01 11:09:00         Fri          7.0
    2020-05-01 11:10:00         Fri          4.0
    2020-05-01 11:32:00         Fri          3.0
    2020-05-01 11:47:00         Fri          4.0
    2020-05-01 12:00:00         Fri          7.0
    2020-05-01 12:10:00         Fri          4.0
    2020-05-01 13:05:00         Fri          6.0
    2020-05-01 13:55:00         Fri          5.0
    2020-05-01 15:03:00         Fri          3.0
    2020-05-01 15:19:00         Fri          3.0
    2020-05-02 11:37:00         Sat          4.0
    2020-05-02 11:39:00         Sat          4.0
    2020-05-02 12:15:00         Sat          3.0
    2020-05-02 13:45:00         Sat          3.0
    2020-05-02 14:45:00         Sat          5.0
    2020-06-18 14:52:00         NaN          0.0
                    datetime day of week  total place  angbutter  plain bread  \
    2653 2020-06-18 14:52:00         NaN    NaN   NaN        NaN          NaN   
    
          jam  americano  croissant  caffe latte  ...  pandoro  cheese cake  \
    2653  NaN        NaN        NaN          NaN  ...      NaN          NaN   
    
          lemon ade  orange pound  wiener  vanila latte  berry ade  tiramisu  \
    2653        NaN           NaN     NaN           NaN        NaN       NaN   
    
          merinque cookies  total_sales  
    2653               NaN          0.0  
    
    [1 rows x 26 columns]
    

This observation occurs in June of 2020, well after the rest of the observations were recorded. It also does not record the sales of any items, despite representing a transaction occurrence. The main body of transaction data seems to conclude at the start of May. Might as well remove this empty row of June data.


```python
# Drop the lone row occurring in June
bakery_data = bakery_data[bakery_data['datetime'].dt.month != 6]
```

## Full Basket Analysis

Since this dataset is relatvely small and features a limited selection of products, we can start off by taking a look at market basket metrics across all individual items. First, the product columns need to be converted from the current sales quantity format to an updated one-hot encoded format.


```python
# List of product column headers
item_columns = ['angbutter', 'plain bread', 'jam', 'americano', 'croissant', 'caffe latte', 
                'tiramisu croissant', 'cacao deep', 'pain au chocolat', 'almond croissant', 
                'milk tea', 'gateau chocolat', 'pandoro', 'cheese cake', 'lemon ade',
                'orange pound', 'wiener', 'vanila latte', 'berry ade', 'tiramisu', 'merinque cookies']

# Convert quantities to one-hot encoded values
basket = bakery_data[item_columns].applymap(lambda x: 1 if x > 0 else 0)
```

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_3036\2581600618.py:8: FutureWarning:
    
    DataFrame.applymap has been deprecated. Use DataFrame.map instead.
    
    

#### Apriori
With the product columns encoded as binary values, the Apriori algorithm can be applied to the bakery data to filter out rules which are not frequent. The algorithm works by pruning the family branches of subset itemsets that have low support, under the reasoning that these subsets will also have equally-or-lower support. The following diagram better illustrates how branches are pruned:

![Node Diagram of the Apriori Algorithm with Low-Support Branches Pruned](https://github.com/bryantjay/Portfolio/blob/main/Korean%20Bakery%20Market%20Basket%20Analysis/source_files/apriori_diagram.png?raw=true)

(* Note: this specific image is sourced from [here](https://www.kaggle.com/code/akhilram7/affinity-analysis-of-market-basket), though numerous variants of the same general diagram exist elsewhere. I'm not sure of the exact origins for the Apriori pruning diagram.)

We can utilize `mlxtend`'s `apriori` function to create a list of frequent itemsets. The parameter `min_support` support defines the support threshold by which to prune itemsets. As this dataset contains one product (the "angbutter" pastry) that dominates product sales, I'm going to keep the support threshold relatively low at 5%, so that some of the more subtle and interesting rules can be observed.


```python
# Apply the Apriori algorithm to find frequent itemsets with a minimum support of 0.05 (5%)
frequent_itemsets = apriori(basket, min_support=0.05, use_colnames=True)

print(frequent_itemsets.head())
```

        support       itemsets
    0  0.743686    (angbutter)
    1  0.323031  (plain bread)
    2  0.082925          (jam)
    3  0.155296    (americano)
    4  0.281568    (croissant)
    

    c:\Users\sbrya\anaconda3\Lib\site-packages\mlxtend\frequent_patterns\fpcommon.py:161: DeprecationWarning:
    
    DataFrames with non-bool types result in worse computationalperformance and their support might be discontinued in the future.Please use a DataFrame with bool type
    
    

#### Association Rules

With our data pruned of infrequent itemsets, we can generate our rules of association. This is done through `mlxtend`'s `association_rules` function. This function also contains a threshold parameter which can filter our association rules by any result metric of the association rules function. In this case, I'm still exploring how the itemsets interact, so like in the `apriori` function, I'll keep this threshold set to 5% support for now. I won't be discussing the representativity, Jaccard, certainty, or Kulczynski metrics in this project; these will be dropped from the output.


```python
# Generate association rules
rules = association_rules(frequent_itemsets, metric="support", min_threshold=0.05, num_itemsets=4000)

# Extra metrics to be dropped
rules = rules.drop(columns=['representativity', 'jaccard', 'certainty', 'kulczynski'])

# Show the first 5 association rules
print(rules.head())
```

         antecedents    consequents  antecedent support  consequent support  \
    0    (angbutter)  (plain bread)            0.743686            0.323031   
    1  (plain bread)    (angbutter)            0.323031            0.743686   
    2          (jam)    (angbutter)            0.082925            0.743686   
    3    (angbutter)          (jam)            0.743686            0.082925   
    4    (americano)    (angbutter)            0.155296            0.743686   
    
        support  confidence      lift  leverage  conviction  zhangs_metric  
    0  0.244252    0.328434  1.016727  0.004018    1.008046       0.064186  
    1  0.244252    0.756126  1.016727  0.004018    1.051008       0.024302  
    2  0.055786    0.672727  0.904585 -0.005884    0.783180      -0.103153  
    3  0.055786    0.075013  0.904585 -0.005884    0.991446      -0.291547  
    4  0.122880    0.791262  1.063973  0.007388    1.227921       0.071180  
    

We have a successful output. Let's iterate over the columns and view each metric sorted high-to-low.


```python
# Metrics to iterate over
cols = ['support', 'confidence', 'lift', 'leverage', 'conviction', 'zhangs_metric']

# Iterate over each metric by which to sort assoc. rules high-to-low
for col in cols:
    print(col, "\n---\n", \
        rules[['antecedents', 'consequents', col]].sort_values(col, ascending=False), '\n')
```

    support 
    ---
                  antecedents                    consequents   support
    0            (angbutter)                  (plain bread)  0.244252
    1          (plain bread)                    (angbutter)  0.244252
    10  (tiramisu croissant)                    (angbutter)  0.226536
    11           (angbutter)           (tiramisu croissant)  0.226536
    6            (angbutter)                    (croissant)  0.210328
    ..                   ...                            ...       ...
    63         (plain bread)  (pain au chocolat, angbutter)  0.053524
    41           (croissant)                 (orange pound)  0.053147
    40        (orange pound)                    (croissant)  0.053147
    8          (caffe latte)                    (angbutter)  0.052394
    9            (angbutter)                  (caffe latte)  0.052394
    
    [70 rows x 3 columns] 
    
    confidence 
    ---
                  antecedents                      consequents  confidence
    26                 (jam)                    (plain bread)    0.872727
    4            (americano)                      (angbutter)    0.791262
    21        (orange pound)                      (angbutter)    0.782274
    10  (tiramisu croissant)                      (angbutter)    0.771502
    18             (pandoro)                      (angbutter)    0.769679
    ..                   ...                              ...         ...
    25           (angbutter)                   (vanila latte)    0.077547
    3            (angbutter)                            (jam)    0.075013
    17           (angbutter)                (gateau chocolat)    0.074506
    62           (angbutter)  (pain au chocolat, plain bread)    0.071972
    9            (angbutter)                    (caffe latte)    0.070451
    
    [70 rows x 3 columns] 
    
    lift 
    ---
                             antecedents                      consequents      lift
    26                            (jam)                    (plain bread)  2.701687
    27                    (plain bread)                            (jam)  2.701687
    39                      (croissant)               (pain au chocolat)  1.403675
    38               (pain au chocolat)                      (croissant)  1.403675
    67               (pain au chocolat)           (angbutter, croissant)  1.320239
    ..                              ...                              ...       ...
    2                             (jam)                      (angbutter)  0.904585
    52  (tiramisu croissant, angbutter)                    (plain bread)  0.891103
    57                    (plain bread)  (tiramisu croissant, angbutter)  0.891103
    37                      (croissant)             (tiramisu croissant)  0.852552
    36             (tiramisu croissant)                      (croissant)  0.852552
    
    [70 rows x 3 columns] 
    
    leverage 
    ---
                             antecedents                      consequents  leverage
    26                            (jam)                    (plain bread)  0.045584
    27                    (plain bread)                            (jam)  0.045584
    39                      (croissant)               (pain au chocolat)  0.025149
    38               (pain au chocolat)                      (croissant)  0.025149
    67               (pain au chocolat)           (angbutter, croissant)  0.014903
    ..                              ...                              ...       ...
    54         (angbutter, plain bread)             (tiramisu croissant) -0.006510
    57                    (plain bread)  (tiramisu croissant, angbutter) -0.007969
    52  (tiramisu croissant, angbutter)                    (plain bread) -0.007969
    37                      (croissant)             (tiramisu croissant) -0.012191
    36             (tiramisu croissant)                      (croissant) -0.012191
    
    [70 rows x 3 columns] 
    
    conviction 
    ---
                               antecedents    consequents  conviction
    26                              (jam)  (plain bread)    5.319046
    4                         (americano)    (angbutter)    1.227921
    38                 (pain au chocolat)    (croissant)    1.187942
    27                      (plain bread)          (jam)    1.181855
    21                     (orange pound)    (angbutter)    1.177228
    ..                                ...            ...         ...
    48           (plain bread, croissant)    (angbutter)    0.870201
    53  (tiramisu croissant, plain bread)    (angbutter)    0.863742
    65      (pain au chocolat, croissant)    (angbutter)    0.861808
    59    (pain au chocolat, plain bread)    (angbutter)    0.799545
    2                               (jam)    (angbutter)    0.783180
    
    [70 rows x 3 columns] 
    
    zhangs_metric 
    ---
                  antecedents                      consequents  zhangs_metric
    27         (plain bread)                            (jam)       0.930412
    26                 (jam)                    (plain bread)       0.686815
    39           (croissant)               (pain au chocolat)       0.400294
    38    (pain au chocolat)                      (croissant)       0.369294
    69           (croissant)    (pain au chocolat, angbutter)       0.333976
    ..                   ...                              ...            ...
    68           (angbutter)    (pain au chocolat, croissant)      -0.185820
    37           (croissant)             (tiramisu croissant)      -0.194024
    36  (tiramisu croissant)                      (croissant)      -0.196685
    62           (angbutter)  (pain au chocolat, plain bread)      -0.269542
    3            (angbutter)                            (jam)      -0.291547
    
    [70 rows x 3 columns] 
    
    

Some quick observations:
- The products "plain bread" and "jam" seem to have an interesting relationship that stands out from any other item, in terms of confidence, lift, leverage, conviction, and Zhang's metric.
- Higher confidence values tend to have "angbutter" as the consequent itemset, while lower confidence values have that same item as an antecedent.
- There seems to be a lot of multi-item purchases between popular products like angbutter, croissants, and pains au chocolat.

#### Association Plots

Let's plot each metric to get a feel for how they are distributed across all the rules.


```python
for col in cols:
    plt.figure(figsize=(10, 6))
    sns.histplot(rules[col], bins=30, kde=True)
    plt.title('Distribution of Support in Association Rules')
    plt.xlabel(col.title())
    plt.ylabel('Frequency')
    plt.show()
```


    
![png](output_69_0.png)
    



    
![png](output_69_1.png)
    



    
![png](output_69_2.png)
    



    
![png](output_69_3.png)
    



    
![png](output_69_4.png)
    



    
![png](output_69_5.png)
    


The "lift" and "conviction" distributions are a bit difficult to view due to the presence of an outlier on each graph. Here's a more easily-discernable version for each:


```python
# Filter rules for lift and conviction
sans_toast_lift = rules[rules['lift'] < 2.5]
sans_toast_conviction = rules[rules['conviction'] < 5]

# Function to plot the distribution
def plot_distribution(data, ax, column, title):
    sns.histplot(data[column], bins=30, kde=True, ax=ax)
    ax.set_title(title)
    ax.set_xlabel(column.title())
    ax.set_ylabel('Frequency')

# Create subplots: 1 row, 2 columns
fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Plot Lift distribution
plot_distribution(sans_toast_lift, axes[0], 'lift', 'Distribution of Lift in Association Rules')

# Plot Conviction distribution
plot_distribution(sans_toast_conviction, axes[1], 'conviction', 'Distribution of Conviction in Association Rules')

# Adjust layout
plt.tight_layout()

# Show the plots
plt.show()

```


    
![png](output_71_0.png)
    


We can see that the support metric is not uniform, meaning there are a small number of high-support rules which are outweighing the larger number of low-support ("less frequent") rules. These high support rules are all between popular items like "angbutter", "plain bread", and "croissant". The confidence metric is bimodal. Confidence heavily favors rules with high-support consequents, and disfavors rules with high-support antecedent; this bimodal pattern could be portraying that dynamic. All other metrics seem to be normally distributed, although they are also skewed towards some high outliers (especially lift and conviction). These outliers all seem to specifically reference the association between "plain bread" and "jam".

## Aggregated Items

In my experience, when I visit a bakery, cafe, or coffeeshop, I tend to vary my drink orders depending on what I'm feeling at any given moment. Coffee or tea? Iced or hot? Espresso shot or decaf? The decisions can vary pretty wildly, but ultimately I'll usually decide on some type of drink and (sometimes) a food item. Some customers might not order food, and others might order a whole range of food and drink items. This is a good scenario for some aggregation.

**Aggregation** in Market Basket Analysis is the process of grouping items together based on some criteria(s). If you're selling t-shirts, perhaps you could group shirts by color or by size. Ultimately, it may not be a specific brand which matters to a given shopper, but any substitutable product that can sufficiently fill a need. We've skipped any initial aggregations thus far, as the data is small enough and it's always good to first view the basket at the smallest level of detail. However, sometimes aggregation may need to be employed before any significant basket metrics can be pulled from the data, like if the dataset is too large.

In the case of this basket data, I've noticed a few broad characteristics by which we can categorize different products. First, there's a small selection of croissants, including regular, almond, pain au chocolat, cacao deep, and tiramisu. There's also an assortment of cakes and cake-like pastries: 'gateau chocolat', 'pandoro', 'cheese cake', 'orange pound' cake, and the 'tiramisu' pastry (distinct from the tiramisu croissant). I also noticed two categories of drinks: a selection of coffee-drinks and a selection of less-caffeinated options. I opted to include "milk tea" with the fruitier "refresher" options, since I usually think of tea as being a bit lighter than coffee caffeine-wise, and it often comes flavored wth fruit; others may disagree with this take.


```python
bakery_agg = bakery_data.copy()

bakery_agg = bakery_agg.drop(columns='total_sales')


# Dictionary of columns to categorize and aggregate
categories = {
    'coffees': ['americano', 'vanila latte', 'caffe latte'],
    'cakes': ['gateau chocolat', 'pandoro', 'cheese cake', 'orange pound', 'tiramisu'],
    'croissants': ['croissant', 'tiramisu croissant', 'pain au chocolat', 'almond croissant', 'cacao deep'],
    'refreshments': ['lemon ade', 'berry ade', 'milk tea']
}

# Loop through each category to aggregate the fields and drop the original columns
for category, columns in categories.items():
    bakery_agg[category] = bakery_agg[columns].sum(axis=1)
    bakery_agg = bakery_agg.drop(columns=columns)


print(bakery_agg.head().to_markdown())
```

    |    | datetime            | day of week   |   total |   place |   angbutter |   plain bread |   jam |   wiener |   merinque cookies |   coffees |   cakes |   croissants |   refreshments |
    |---:|:--------------------|:--------------|--------:|--------:|------------:|--------------:|------:|---------:|-------------------:|----------:|--------:|-------------:|---------------:|
    |  0 | 2019-07-11 15:35:00 | Thur          |   23800 |     nan |           1 |           nan |   nan |      nan |                nan |         2 |       0 |            3 |              0 |
    |  1 | 2019-07-11 16:10:00 | Thur          |   15800 |     nan |           1 |           nan |   nan |      nan |                nan |         0 |       1 |            1 |              0 |
    |  2 | 2019-07-12 11:49:00 | Fri           |   58000 |     nan |         nan |           nan |   nan |      nan |                nan |         0 |       0 |           14 |              0 |
    |  3 | 2019-07-13 13:19:00 | Sat           |   14800 |     nan |           1 |             1 |   nan |      nan |                nan |         1 |       0 |            0 |              0 |
    |  4 | 2019-07-13 13:22:00 | Sat           |   15600 |     nan |           2 |           nan |   nan |      nan |                nan |         0 |       0 |            1 |              0 |
    

Here's the sales and transaction counts for the revised basket:


```python
# List of revised product columns
product_columns = ['angbutter', 'plain bread', 'jam', 'wiener', 'merinque cookies', 'coffees', 'cakes', 'croissants', 'refreshments']

# Custom sales plotting func from earlier
sales_plot(bakery_agg, product_columns)
```


    
![png](output_76_0.png)
    


When grouped together, the croissants actually manage to overtake the angbutter pastry in overall sales (although, not in the total number of transactions). We also see that grouping the various cake- and coffee-based food items totals their sales up to the level of the moderately successful "plain bread" product.

Let's view a revised association heatmap:


```python
# Custom heatmap plotting func from earlier
plot_heatmap(bakery_agg, product_columns)
```


    
![png](output_78_0.png)
    


We can note that there's a lot of overlap between all angbutter, cake, coffee, croissant, and plain bread items, as these make up the most common products. It appears that many customers enjoy coffee with their croissants and angbutter pastries, as combination with on of these items make up around two-thirds of all coffee transactions. Similarly prevalent relationships seem to exist with the angbutter and croissant items with respect to plain bread and cake items. In fact, due to the commonality of angbutter and croissant items across transactions, it generally appears that either one of these items may be more than 50%-60% likely to be purchased along with the purchase of just about any other given item category. This is just a characteristic of top-selling items.

A more interesting pattern lines within our jam sales. Jam makes an appearance in 220 transactions — just over 8% of the data. Of those 220 transactions, we see plain bread make an appearance in a whopping 192 of them (87%); this is the *confidence* score for the rule "jam -> plain bread", and its significantly greater than the scores of either the angbutter or croissant categories, despite those items making up a much larger portion of transactions.

However, we don't need to calculate confidence values by hand, since we already know we can generate a wide range of rule metrics using our `mlxtend` workflow:


```python
# Convert quantities to one-hot encoded values
basket = bakery_agg[product_columns].map(lambda x: 1 if x > 0 else 0)

# Apply the Apriori algorithm to find frequent itemsets with a minimum support of 5%
frequent_itemsets = apriori(basket, min_support=0.05, use_colnames=True)

# Generate association rules
rules = association_rules(frequent_itemsets, metric="support", min_threshold=0.05, num_itemsets=4000)

# Extra metrics to be dropped
rules = rules.drop(columns=['representativity', 'jaccard', 'certainty', 'kulczynski'])

# Metrics to iterate over
cols = ['support', 'confidence', 'lift', 'leverage', 'conviction', 'zhangs_metric']

# Iterate over each metric by which to sort assoc. rules high-to-low
for col in cols:
    print(col, "\n---\n", \
        rules[['antecedents', 'consequents', col]].sort_values(col, ascending=False), '\n')
```

    support 
    ---
                       antecedents     consequents   support
    11               (croissants)     (angbutter)  0.524312
    10                (angbutter)    (croissants)  0.524312
    9                 (angbutter)         (cakes)  0.285337
    8                     (cakes)     (angbutter)  0.285337
    31               (croissants)         (cakes)  0.258952
    ..                        ...             ...       ...
    78      (croissants, coffees)   (plain bread)  0.053901
    77     (plain bread, coffees)    (croissants)  0.053901
    76  (plain bread, croissants)       (coffees)  0.053901
    32               (croissants)  (refreshments)  0.052017
    33             (refreshments)    (croissants)  0.052017
    
    [88 rows x 3 columns] 
    
    confidence 
    ---
            antecedents             consequents  confidence
    14           (jam)           (plain bread)    0.872727
    13  (refreshments)             (angbutter)    0.792627
    11    (croissants)             (angbutter)    0.777529
    8          (cakes)             (angbutter)    0.770876
    7        (coffees)             (angbutter)    0.769018
    ..             ...                     ...         ...
    37     (angbutter)  (plain bread, coffees)    0.082108
    62     (angbutter)        (cakes, coffees)    0.080081
    80    (croissants)  (plain bread, coffees)    0.079933
    32    (croissants)          (refreshments)    0.077138
    3      (angbutter)                   (jam)    0.075013
    
    [88 rows x 3 columns] 
    
    lift 
    ---
                  antecedents           consequents      lift
    15         (plain bread)                 (jam)  2.701687
    14                 (jam)         (plain bread)  2.701687
    25          (croissants)              (wiener)  1.090283
    24              (wiener)          (croissants)  1.090283
    21          (croissants)         (plain bread)  1.065925
    ..                   ...                   ...       ...
    45         (plain bread)    (cakes, angbutter)  0.850597
    60  (angbutter, coffees)               (cakes)  0.767729
    61               (cakes)  (angbutter, coffees)  0.767729
    58    (cakes, angbutter)             (coffees)  0.765879
    63             (coffees)    (cakes, angbutter)  0.765879
    
    [88 rows x 3 columns] 
    
    leverage 
    ---
                  antecedents           consequents  leverage
    15         (plain bread)                 (jam)  0.045584
    14                 (jam)         (plain bread)  0.045584
    11          (croissants)           (angbutter)  0.022821
    10           (angbutter)          (croissants)  0.022821
    21          (croissants)         (plain bread)  0.014360
    ..                   ...                   ...       ...
    26               (cakes)             (coffees) -0.014179
    61               (cakes)  (angbutter, coffees) -0.018018
    60  (angbutter, coffees)               (cakes) -0.018018
    63             (coffees)    (cakes, angbutter) -0.018205
    58    (cakes, angbutter)             (coffees) -0.018205
    
    [88 rows x 3 columns] 
    
    conviction 
    ---
                    antecedents    consequents  conviction
    14                   (jam)  (plain bread)    5.319046
    13          (refreshments)    (angbutter)    1.236001
    24                (wiener)   (croissants)    1.229920
    15           (plain bread)          (jam)    1.181855
    20           (plain bread)   (croissants)    1.158085
    ..                     ...            ...         ...
    36  (plain bread, coffees)    (angbutter)    0.858093
    77  (plain bread, coffees)   (croissants)    0.854881
    59        (cakes, coffees)    (angbutter)    0.818780
    41    (cakes, plain bread)    (angbutter)    0.817506
    2                    (jam)    (angbutter)    0.783180
    
    [88 rows x 3 columns] 
    
    zhangs_metric 
    ---
                  antecedents           consequents  zhangs_metric
    15         (plain bread)                 (jam)       0.930412
    14                 (jam)         (plain bread)       0.686815
    25          (croissants)              (wiener)       0.254266
    12           (angbutter)        (refreshments)       0.240894
    21          (croissants)         (plain bread)       0.189911
    ..                   ...                   ...            ...
    60  (angbutter, coffees)               (cakes)      -0.276808
    3            (angbutter)                 (jam)      -0.291547
    63             (coffees)    (cakes, angbutter)      -0.295876
    58    (cakes, angbutter)             (coffees)      -0.299592
    61               (cakes)  (angbutter, coffees)      -0.324479
    
    [88 rows x 3 columns] 
    
    

    c:\Users\sbrya\anaconda3\Lib\site-packages\mlxtend\frequent_patterns\fpcommon.py:161: DeprecationWarning:
    
    DataFrames with non-bool types result in worse computationalperformance and their support might be discontinued in the future.Please use a DataFrame with bool type
    
    

We'll go through each of the metrics to a closer degree, but first I want to bring attention to some of the relationships between various market basket metrics. Similar to how confusion matrix metrics work in tandem to paint a complete picture of model performance, MBA metrics also provide fuller context to various rules by placing importance on different attributes. There can be some interesting interactions between the MBA metrics because of this. Here's a pairplot of rules comparing how different market basket metrics correlate, with the extreme rules for bread and jam removed for visual clarity:


```python
# Filter out extreme "plain bread" + "jam" rules
sans_toast = rules[rules['lift'] < 2.5]
sans_toast = sans_toast[sans_toast['conviction'] < 5]

# Create a pairplot matrix for the specified metrics, including A & C supports
g = sns.pairplot(sans_toast[cols])

# Add borders to each subplot (axes) in the pairplot
for ax in g.axes.flatten():
    for _, spine in ax.spines.items():
        spine.set_visible(True)  # Ensure spines are visible
        spine.set_linewidth(1.5)  # Set border line width
        spine.set_edgecolor('black')  # Set border color

# Show the plot
plt.tight_layout()
plt.show()
```


    
![png](output_83_0.png)
    


Considering our most basic MBA metrics first, we only see a weak-to-mid positive correlation for the interaction of Support and Confidence. As support is used as a foundation for essentially every other more-complex metric, it tends to feature similar weak positive correlations elsewhere, each with some type of upward-sloping ceiling. Similarly, the confidence metric sees extremely weak or even non-existent correlations with other metrics.

There is some type of observable interaction existing between Lift, Leverage, Conviction, and Zhang's Metric. In the pairplot subplot for each of these, we generally see an "X"-like shape due to the centered and scaled nature of each metric around a central choke point (either 0 or 1). Comparing these subplots, the more linear and less dispersed a plot between two metrics is, the more aligned with each other those metrics are.

The relationship between conviction and Zhang's metric is an example of two metrics that tend to differ on which values they consider to be extreme, resulting in a subplot with two legs spaced far apart. Rules with extreme (either *high* or *low*) conviction will have a less-extreme ZM, and rules with extreme ZM's will have less extreme conviction. Conviction in general tends to have relatively dispersed relations with lift and leverage as well, but to a lesser degree than with Zhang's metric.

The relationships between lift, leverage, and Zhang's metric are much tighter, indicating a closer agreement on significant rules between these metrics. Of particular interest is the relationship between lift and leverage, whose respective pairplot is almost linear. This makes sense, as the two metrics are extremely similar in nature. Both directly compare the observed and expected support for the occurrence of a given rule, but one via a ratio formula and the other via a difference formula. We should expected these two metrics to present similar conclusions for "important" rules.

#### Highest Confidence

As a reminder, confidence is highly related to and influenced by the *consequent's* individual support metric. We expect rules featuring high-support consequents to also have high confidence levels, regardless of rule reliability. To illustrate what I'm saying, here's the scatterplot of 'consequent support' vs 'confidence' for this basket data:


```python
# Create a scatter plot using Seaborn
plt.figure(figsize=(8, 6))
sns.scatterplot(x='consequent support', y='confidence', data=rules, color='b', edgecolor='k', s=100, alpha=0.7)

# Annotation parameters
annotations = [
    {"text": "Jam → Plain Bread", "xy": (0.33, 0.872727), "xytext": (0.4, 0.872727)},
    {"text": "Plain Bread → Jam", "xy": (0.09, 0.24), "xytext": (0.08, 0.5)},
]

# Annotation function, reiterated
for ann in annotations:
    plt.annotate(ann["text"],
                 xy=ann["xy"], xytext=ann["xytext"],
                 ha='left', va='center',
                 arrowprops=dict(arrowstyle="->", color='red', lw=1.5))

# Set the title and labels
plt.title("Scatter plot of Consequent Support vs Confidence")
plt.xlabel("Consequent Support")
plt.ylabel("Confidence")
plt.grid(True)

# Show the plot
plt.show()
```


    
![png](output_86_0.png)
    


Assuming that two itemsets are completely independent, the confidence is simply the probability of picking the consequent (i.e. the consequent support); this is why the line of best fit for the relationship between confidence and consequent support is essentially "y = x". These values are nearly the same in most other circumstances; the relationship between confidence and consequent support is *extremely* correlated. The further a rule lies outside of this line of correlation, the less independent the itemsets in the rule are.

This might be the best evidence for how much the association between plain bread and jam really stands out relative to all other rules in the dataset.


```python
# Filter rules with high confidence
high_confidence_rules = rules[rules['confidence'] > 0.5].sort_values('confidence', ascending=False)

# Show the filtered high-quality rules
print(high_confidence_rules.to_markdown())
```

    |    | antecedents                              | consequents                            |   antecedent support |   consequent support |   support |   confidence |     lift |     leverage |   conviction |   zhangs_metric |
    |---:|:-----------------------------------------|:---------------------------------------|---------------------:|---------------------:|----------:|-------------:|---------:|-------------:|-------------:|----------------:|
    | 14 | frozenset({'jam'})                       | frozenset({'plain bread'})             |            0.082925  |             0.323031 | 0.0723709 |     0.872727 | 2.70169  |  0.0455836   |     5.31905  |      0.686815   |
    | 13 | frozenset({'refreshments'})              | frozenset({'angbutter'})               |            0.0817942 |             0.743686 | 0.0648323 |     0.792627 | 1.06581  |  0.00400304  |     1.236    |      0.0672447  |
    | 11 | frozenset({'croissants'})                | frozenset({'angbutter'})               |            0.674331  |             0.743686 | 0.524312  |     0.777529 | 1.04551  |  0.0228214   |     1.15212  |      0.133652   |
    |  8 | frozenset({'cakes'})                     | frozenset({'angbutter'})               |            0.370147  |             0.743686 | 0.285337  |     0.770876 | 1.03656  |  0.0100641   |     1.11867  |      0.0559984  |
    |  7 | frozenset({'coffees'})                   | frozenset({'angbutter'})               |            0.272522  |             0.743686 | 0.209574  |     0.769018 | 1.03406  |  0.00690341  |     1.10967  |      0.0452799  |
    |  1 | frozenset({'plain bread'})               | frozenset({'angbutter'})               |            0.323031  |             0.743686 | 0.244252  |     0.756126 | 1.01673  |  0.00401838  |     1.05101  |      0.0243021  |
    |  4 | frozenset({'wiener'})                    | frozenset({'angbutter'})               |            0.133811  |             0.743686 | 0.100641  |     0.752113 | 1.01133  |  0.00112753  |     1.03399  |      0.0129342  |
    | 24 | frozenset({'wiener'})                    | frozenset({'croissants'})              |            0.133811  |             0.674331 | 0.0983792 |     0.735211 | 1.09028  |  0.00814644  |     1.22992  |      0.0955987  |
    | 20 | frozenset({'plain bread'})               | frozenset({'croissants'})              |            0.323031  |             0.674331 | 0.23219   |     0.718786 | 1.06593  |  0.0143605   |     1.15808  |      0.0913601  |
    | 66 | frozenset({'croissants', 'coffees'})     | frozenset({'angbutter'})               |            0.18432   |             0.743686 | 0.132303  |     0.717791 | 0.96518  | -0.00477295  |     0.908242 |     -0.0423547  |
    | 71 | frozenset({'cakes', 'croissants'})       | frozenset({'angbutter'})               |            0.258952  |             0.743686 | 0.185074  |     0.714702 | 0.961026 | -0.00750567  |     0.898405 |     -0.0518871  |
    | 47 | frozenset({'plain bread', 'croissants'}) | frozenset({'angbutter'})               |            0.23219   |             0.743686 | 0.165096  |     0.711039 | 0.956101 | -0.00758041  |     0.887018 |     -0.0564258  |
    | 53 | frozenset({'wiener', 'croissants'})      | frozenset({'angbutter'})               |            0.0983792 |             0.743686 | 0.0697324 |     0.708812 | 0.953106 | -0.00343089  |     0.880235 |     -0.0517456  |
    | 10 | frozenset({'angbutter'})                 | frozenset({'croissants'})              |            0.743686  |             0.674331 | 0.524312  |     0.705018 | 1.04551  |  0.0228214   |     1.10403  |      0.169816   |
    | 36 | frozenset({'plain bread', 'coffees'})    | frozenset({'angbutter'})               |            0.0870712 |             0.743686 | 0.0610629 |     0.701299 | 0.943003 | -0.00369075  |     0.858093 |     -0.0620953  |
    | 22 | frozenset({'jam'})                       | frozenset({'croissants'})              |            0.082925  |             0.674331 | 0.0580475 |     0.7      | 1.03807  |  0.00212861  |     1.08556  |      0.0399859  |
    | 30 | frozenset({'cakes'})                     | frozenset({'croissants'})              |            0.370147  |             0.674331 | 0.258952  |     0.699593 | 1.03746  |  0.00935055  |     1.08409  |      0.0573295  |
    | 52 | frozenset({'wiener', 'angbutter'})       | frozenset({'croissants'})              |            0.100641  |             0.674331 | 0.0697324 |     0.692884 | 1.02751  |  0.00186718  |     1.06041  |      0.0297728  |
    | 59 | frozenset({'cakes', 'coffees'})          | frozenset({'angbutter'})               |            0.0866943 |             0.743686 | 0.0595552 |     0.686957 | 0.923718 | -0.00491816  |     0.81878  |     -0.0829225  |
    | 41 | frozenset({'cakes', 'plain bread'})      | frozenset({'angbutter'})               |            0.11421   |             0.743686 | 0.0784018 |     0.686469 | 0.923062 | -0.00653486  |     0.817506 |     -0.0860049  |
    | 29 | frozenset({'coffees'})                   | frozenset({'croissants'})              |            0.272522  |             0.674331 | 0.18432   |     0.676349 | 1.00299  |  0.00054984  |     1.00623  |      0.00410058 |
    | 48 | frozenset({'angbutter', 'plain bread'})  | frozenset({'croissants'})              |            0.244252  |             0.674331 | 0.165096  |     0.675926 | 1.00237  |  0.000389577 |     1.00492  |      0.00312233 |
    |  2 | frozenset({'jam'})                       | frozenset({'angbutter'})               |            0.082925  |             0.743686 | 0.0557859 |     0.672727 | 0.904585 | -0.00588428  |     0.78318  |     -0.103153   |
    | 82 | frozenset({'cakes', 'plain bread'})      | frozenset({'croissants'})              |            0.11421   |             0.674331 | 0.0765172 |     0.669967 | 0.993528 | -0.000498408 |     0.986777 |     -0.00729985 |
    | 70 | frozenset({'cakes', 'angbutter'})        | frozenset({'croissants'})              |            0.285337  |             0.674331 | 0.185074  |     0.648613 | 0.961861 | -0.00733831  |     0.92681  |     -0.0525654  |
    | 33 | frozenset({'refreshments'})              | frozenset({'croissants'})              |            0.0817942 |             0.674331 | 0.0520166 |     0.635945 | 0.943075 | -0.00313977  |     0.894559 |     -0.061683   |
    | 65 | frozenset({'angbutter', 'coffees'})      | frozenset({'croissants'})              |            0.209574  |             0.674331 | 0.132303  |     0.631295 | 0.93618  | -0.00901923  |     0.883278 |     -0.0793981  |
    | 77 | frozenset({'plain bread', 'coffees'})    | frozenset({'croissants'})              |            0.0870712 |             0.674331 | 0.0539012 |     0.619048 | 0.918018 | -0.00481359  |     0.854881 |     -0.0891049  |
    | 55 | frozenset({'wiener'})                    | frozenset({'angbutter', 'croissants'}) |            0.133811  |             0.524312 | 0.0697324 |     0.521127 | 0.993925 | -0.000426233 |     0.993348 |     -0.00700722 |
    | 51 | frozenset({'plain bread'})               | frozenset({'angbutter', 'croissants'}) |            0.323031  |             0.524312 | 0.165096  |     0.511085 | 0.974773 | -0.0042727   |     0.972946 |     -0.0368216  |
    

Filtering by high confidence alone generates a selection of good and bad rules. As such, it's better to filter by an additional metric. We could filter by lift or conviction levels greater than 1, or by leverage levels or Zhang's metrics greater than 0. We'll filter by lift values here.


```python
# Filter rules with high confidence
high_confidence_rules_filtered = rules[(rules['confidence'] > 0.5) & (rules['lift'] > 1.0)].sort_values('confidence', ascending=False)

# Show the filtered high-quality rules
print(high_confidence_rules_filtered.to_markdown())
```

    |    | antecedents                             | consequents                |   antecedent support |   consequent support |   support |   confidence |    lift |    leverage |   conviction |   zhangs_metric |
    |---:|:----------------------------------------|:---------------------------|---------------------:|---------------------:|----------:|-------------:|--------:|------------:|-------------:|----------------:|
    | 14 | frozenset({'jam'})                      | frozenset({'plain bread'}) |            0.082925  |             0.323031 | 0.0723709 |     0.872727 | 2.70169 | 0.0455836   |      5.31905 |      0.686815   |
    | 13 | frozenset({'refreshments'})             | frozenset({'angbutter'})   |            0.0817942 |             0.743686 | 0.0648323 |     0.792627 | 1.06581 | 0.00400304  |      1.236   |      0.0672447  |
    | 11 | frozenset({'croissants'})               | frozenset({'angbutter'})   |            0.674331  |             0.743686 | 0.524312  |     0.777529 | 1.04551 | 0.0228214   |      1.15212 |      0.133652   |
    |  8 | frozenset({'cakes'})                    | frozenset({'angbutter'})   |            0.370147  |             0.743686 | 0.285337  |     0.770876 | 1.03656 | 0.0100641   |      1.11867 |      0.0559984  |
    |  7 | frozenset({'coffees'})                  | frozenset({'angbutter'})   |            0.272522  |             0.743686 | 0.209574  |     0.769018 | 1.03406 | 0.00690341  |      1.10967 |      0.0452799  |
    |  1 | frozenset({'plain bread'})              | frozenset({'angbutter'})   |            0.323031  |             0.743686 | 0.244252  |     0.756126 | 1.01673 | 0.00401838  |      1.05101 |      0.0243021  |
    |  4 | frozenset({'wiener'})                   | frozenset({'angbutter'})   |            0.133811  |             0.743686 | 0.100641  |     0.752113 | 1.01133 | 0.00112753  |      1.03399 |      0.0129342  |
    | 24 | frozenset({'wiener'})                   | frozenset({'croissants'})  |            0.133811  |             0.674331 | 0.0983792 |     0.735211 | 1.09028 | 0.00814644  |      1.22992 |      0.0955987  |
    | 20 | frozenset({'plain bread'})              | frozenset({'croissants'})  |            0.323031  |             0.674331 | 0.23219   |     0.718786 | 1.06593 | 0.0143605   |      1.15808 |      0.0913601  |
    | 10 | frozenset({'angbutter'})                | frozenset({'croissants'})  |            0.743686  |             0.674331 | 0.524312  |     0.705018 | 1.04551 | 0.0228214   |      1.10403 |      0.169816   |
    | 22 | frozenset({'jam'})                      | frozenset({'croissants'})  |            0.082925  |             0.674331 | 0.0580475 |     0.7      | 1.03807 | 0.00212861  |      1.08556 |      0.0399859  |
    | 30 | frozenset({'cakes'})                    | frozenset({'croissants'})  |            0.370147  |             0.674331 | 0.258952  |     0.699593 | 1.03746 | 0.00935055  |      1.08409 |      0.0573295  |
    | 52 | frozenset({'wiener', 'angbutter'})      | frozenset({'croissants'})  |            0.100641  |             0.674331 | 0.0697324 |     0.692884 | 1.02751 | 0.00186718  |      1.06041 |      0.0297728  |
    | 29 | frozenset({'coffees'})                  | frozenset({'croissants'})  |            0.272522  |             0.674331 | 0.18432   |     0.676349 | 1.00299 | 0.00054984  |      1.00623 |      0.00410058 |
    | 48 | frozenset({'angbutter', 'plain bread'}) | frozenset({'croissants'})  |            0.244252  |             0.674331 | 0.165096  |     0.675926 | 1.00237 | 0.000389577 |      1.00492 |      0.00312233 |
    

Because of the close relationship of confidence and consequent support for independent itemsets, we see that angbutter and croissants appear as consequents among many instances of high confidence basket combinations; it's because these items are the most commonly purchased items. We see that a lot of customers tend to purchase around 2 food items from some of the more common food categories, including both angbutter pastries and croissants. Of the people who buy any drink items, it also tends to be fairly common to purchase an angbutter item to accompany it; this pattern does not seem to be as common with other food item combinations, but this may be due to the overshadowing nature of the angbutter item.

The only really strong rule that stands out in this group is "jam -> plain bread", which has high measures in all other metrics. From a confidence standpoint, it makes a lot of sense that if someone purchases a packet of jam, they are almost certain to purchase some accompanying (likely bread-like) food to eat it with.

I'd also like to foreshadow future findings, and highlight the item combination of wieners with croissants.There are two variants of this combination within this result set, but we will see the base "wiener -> croissant" rule again going forth. This rule sees relatively high figures in both lift and conviction, and marginally high figures in all other non-support metrics.

#### Highest Lift

Lift is a good metric to rate the association of items in a rule regardless of which direction the rule is oriented. This means that the rules "X -> Y" and "Y -> X" will have the same lift metric, and antecedent/consequent assignments are not as important. It's the grouping of two items as a whole being considered.

A reminder that lift measures the strength of association between items using the ratio of a rule's Observed Support to its Expected Support. Rules with lift over 1 occur more often than would be expected by independent probability.


```python
# Filter rules with high lift
high_lift_rules = rules[rules['lift'] > 1.03].sort_values('lift', ascending=False)

# Show the filtered high-quality rules
print(high_lift_rules.to_markdown())
```

    |    | antecedents                 | consequents                 |   antecedent support |   consequent support |   support |   confidence |    lift |   leverage |   conviction |   zhangs_metric |
    |---:|:----------------------------|:----------------------------|---------------------:|---------------------:|----------:|-------------:|--------:|-----------:|-------------:|----------------:|
    | 15 | frozenset({'plain bread'})  | frozenset({'jam'})          |            0.323031  |            0.082925  | 0.0723709 |    0.224037  | 2.70169 | 0.0455836  |      1.18185 |       0.930412  |
    | 14 | frozenset({'jam'})          | frozenset({'plain bread'})  |            0.082925  |            0.323031  | 0.0723709 |    0.872727  | 2.70169 | 0.0455836  |      5.31905 |       0.686815  |
    | 25 | frozenset({'croissants'})   | frozenset({'wiener'})       |            0.674331  |            0.133811  | 0.0983792 |    0.145892  | 1.09028 | 0.00814644 |      1.01414 |       0.254266  |
    | 24 | frozenset({'wiener'})       | frozenset({'croissants'})   |            0.133811  |            0.674331  | 0.0983792 |    0.735211  | 1.09028 | 0.00814644 |      1.22992 |       0.0955987 |
    | 20 | frozenset({'plain bread'})  | frozenset({'croissants'})   |            0.323031  |            0.674331  | 0.23219   |    0.718786  | 1.06593 | 0.0143605  |      1.15808 |       0.0913601 |
    | 21 | frozenset({'croissants'})   | frozenset({'plain bread'})  |            0.674331  |            0.323031  | 0.23219   |    0.344326  | 1.06593 | 0.0143605  |      1.03248 |       0.189911  |
    | 12 | frozenset({'angbutter'})    | frozenset({'refreshments'}) |            0.743686  |            0.0817942 | 0.0648323 |    0.0871769 | 1.06581 | 0.00400304 |      1.0059  |       0.240894  |
    | 13 | frozenset({'refreshments'}) | frozenset({'angbutter'})    |            0.0817942 |            0.743686  | 0.0648323 |    0.792627  | 1.06581 | 0.00400304 |      1.236   |       0.0672447 |
    | 10 | frozenset({'angbutter'})    | frozenset({'croissants'})   |            0.743686  |            0.674331  | 0.524312  |    0.705018  | 1.04551 | 0.0228214  |      1.10403 |       0.169816  |
    | 11 | frozenset({'croissants'})   | frozenset({'angbutter'})    |            0.674331  |            0.743686  | 0.524312  |    0.777529  | 1.04551 | 0.0228214  |      1.15212 |       0.133652  |
    | 23 | frozenset({'croissants'})   | frozenset({'jam'})          |            0.674331  |            0.082925  | 0.0580475 |    0.0860816 | 1.03807 | 0.00212861 |      1.00345 |       0.112599  |
    | 22 | frozenset({'jam'})          | frozenset({'croissants'})   |            0.082925  |            0.674331  | 0.0580475 |    0.7       | 1.03807 | 0.00212861 |      1.08556 |       0.0399859 |
    | 30 | frozenset({'cakes'})        | frozenset({'croissants'})   |            0.370147  |            0.674331  | 0.258952  |    0.699593  | 1.03746 | 0.00935055 |      1.08409 |       0.0573295 |
    | 31 | frozenset({'croissants'})   | frozenset({'cakes'})        |            0.674331  |            0.370147  | 0.258952  |    0.384013  | 1.03746 | 0.00935055 |      1.02251 |       0.110877  |
    |  9 | frozenset({'angbutter'})    | frozenset({'cakes'})        |            0.743686  |            0.370147  | 0.285337  |    0.38368   | 1.03656 | 0.0100641  |      1.02196 |       0.137608  |
    |  8 | frozenset({'cakes'})        | frozenset({'angbutter'})    |            0.370147  |            0.743686  | 0.285337  |    0.770876  | 1.03656 | 0.0100641  |      1.11867 |       0.0559984 |
    |  6 | frozenset({'angbutter'})    | frozenset({'coffees'})      |            0.743686  |            0.272522  | 0.209574  |    0.281804  | 1.03406 | 0.00690341 |      1.01293 |       0.128515  |
    |  7 | frozenset({'coffees'})      | frozenset({'angbutter'})    |            0.272522  |            0.743686  | 0.209574  |    0.769018  | 1.03406 | 0.00690341 |      1.10967 |       0.0452799 |
    

We see that transactions featuring "plain bread + jam" occur *much* more frequently than would expected from an independent pairing.

Additional pairings featured include:
  - "croissants + weiner".
  - "plain bread + croissants"
  - "refreshments + angbutter"
  - "cakes + croissants"
  - "croissants + angbutter"
  - "cakes + angbutter"
  - "coffees + angbutter"
  - "wiener + croissants"
  - "jam + croissants"

#### Highest Leverage

Remember that leverage is similar to lift in that both compare the Observed and Expected Support of a rule occurring in a transaction. However, leverage does so by performing difference calculation, as opposed to the ratio calculated by lift. Rules with a positive leverage statistic occur more often than expected. Lke lift, the item-pair reciprocals are given the same leverage metric regardless of direction.


```python
# Filter rules with high leverage
high_leverage_rules = rules[rules['leverage'] > 0.01].sort_values('leverage', ascending=False)

# Show the filtered high-quality rules
print(high_leverage_rules.to_markdown())
```

    |    | antecedents                | consequents                |   antecedent support |   consequent support |   support |   confidence |    lift |   leverage |   conviction |   zhangs_metric |
    |---:|:---------------------------|:---------------------------|---------------------:|---------------------:|----------:|-------------:|--------:|-----------:|-------------:|----------------:|
    | 14 | frozenset({'jam'})         | frozenset({'plain bread'}) |             0.082925 |             0.323031 | 0.0723709 |     0.872727 | 2.70169 |  0.0455836 |      5.31905 |       0.686815  |
    | 15 | frozenset({'plain bread'}) | frozenset({'jam'})         |             0.323031 |             0.082925 | 0.0723709 |     0.224037 | 2.70169 |  0.0455836 |      1.18185 |       0.930412  |
    | 10 | frozenset({'angbutter'})   | frozenset({'croissants'})  |             0.743686 |             0.674331 | 0.524312  |     0.705018 | 1.04551 |  0.0228214 |      1.10403 |       0.169816  |
    | 11 | frozenset({'croissants'})  | frozenset({'angbutter'})   |             0.674331 |             0.743686 | 0.524312  |     0.777529 | 1.04551 |  0.0228214 |      1.15212 |       0.133652  |
    | 20 | frozenset({'plain bread'}) | frozenset({'croissants'})  |             0.323031 |             0.674331 | 0.23219   |     0.718786 | 1.06593 |  0.0143605 |      1.15808 |       0.0913601 |
    | 21 | frozenset({'croissants'})  | frozenset({'plain bread'}) |             0.674331 |             0.323031 | 0.23219   |     0.344326 | 1.06593 |  0.0143605 |      1.03248 |       0.189911  |
    |  8 | frozenset({'cakes'})       | frozenset({'angbutter'})   |             0.370147 |             0.743686 | 0.285337  |     0.770876 | 1.03656 |  0.0100641 |      1.11867 |       0.0559984 |
    |  9 | frozenset({'angbutter'})   | frozenset({'cakes'})       |             0.743686 |             0.370147 | 0.285337  |     0.38368  | 1.03656 |  0.0100641 |      1.02196 |       0.137608  |
    

We see many of the same rules indicated here as we did with our high-lift values:
- "plain bread" and "jam" rule variants sit at top of list
- different variants of rules containing high-support items, like "angbutter", "croissants", and "cakes"

#### Highest Conviction

Reviewing our earlier formula definitions, we know that conviction analyzes the likelihood that a consequent will NOT occur in the wake of an antecedent occurring. From the dispersal patterns in the earlier pairplot, we also saw a significant amount of *disagreement* that the conviction metric has with regard to other MBA metrics, such as lift, leverage, and Zhang's Metric. Because of this, conviction seems to be a great contrast for rule findings present in other metrics.


```python
# Filter rules with high conviction
high_conviction_rules = rules[rules['conviction'] > 1.1].sort_values('conviction', ascending=False)

# Show the filtered high-quality rules
print(high_conviction_rules.to_markdown())
```

    |    | antecedents                 | consequents                |   antecedent support |   consequent support |   support |   confidence |    lift |   leverage |   conviction |   zhangs_metric |
    |---:|:----------------------------|:---------------------------|---------------------:|---------------------:|----------:|-------------:|--------:|-----------:|-------------:|----------------:|
    | 14 | frozenset({'jam'})          | frozenset({'plain bread'}) |            0.082925  |             0.323031 | 0.0723709 |     0.872727 | 2.70169 | 0.0455836  |      5.31905 |       0.686815  |
    | 13 | frozenset({'refreshments'}) | frozenset({'angbutter'})   |            0.0817942 |             0.743686 | 0.0648323 |     0.792627 | 1.06581 | 0.00400304 |      1.236   |       0.0672447 |
    | 24 | frozenset({'wiener'})       | frozenset({'croissants'})  |            0.133811  |             0.674331 | 0.0983792 |     0.735211 | 1.09028 | 0.00814644 |      1.22992 |       0.0955987 |
    | 15 | frozenset({'plain bread'})  | frozenset({'jam'})         |            0.323031  |             0.082925 | 0.0723709 |     0.224037 | 2.70169 | 0.0455836  |      1.18185 |       0.930412  |
    | 20 | frozenset({'plain bread'})  | frozenset({'croissants'})  |            0.323031  |             0.674331 | 0.23219   |     0.718786 | 1.06593 | 0.0143605  |      1.15808 |       0.0913601 |
    | 11 | frozenset({'croissants'})   | frozenset({'angbutter'})   |            0.674331  |             0.743686 | 0.524312  |     0.777529 | 1.04551 | 0.0228214  |      1.15212 |       0.133652  |
    |  8 | frozenset({'cakes'})        | frozenset({'angbutter'})   |            0.370147  |             0.743686 | 0.285337  |     0.770876 | 1.03656 | 0.0100641  |      1.11867 |       0.0559984 |
    |  7 | frozenset({'coffees'})      | frozenset({'angbutter'})   |            0.272522  |             0.743686 | 0.209574  |     0.769018 | 1.03406 | 0.00690341 |      1.10967 |       0.0452799 |
    | 10 | frozenset({'angbutter'})    | frozenset({'croissants'})  |            0.743686  |             0.674331 | 0.524312  |     0.705018 | 1.04551 | 0.0228214  |      1.10403 |       0.169816  |
    

We see that conviction prioritizes a few more interesting and insightful rules, ahead of rules for high-support itemsets:
- Both "jam + plain bread" rules carry high conviction levels, but the "jam -> plain bread" rule has a far higher conviction than any other rule. It does seem like this is a fairly certain rule to expect.
- The "wiener -> croissants" rule has a high conviction level, but its reciprocal is far lower at around 1.01 (and is not featured in this result accordingly).
- The same pattern exists for the rules "refreshments -> angbutter" and "coffees -> angbutter" rules, where there reciprocal conviction levels are far lower, but still greater than 1.
- The reciprocals of the "plain bread -> croissants", "croissants -> angbutter", and "cakes -> angbutter" are lower than the included conviction levels here, but not as low as that of the two prior rules.

#### Highest Zhang Metrics

The above Zhang's metric plot seems to mostly adhere to a normal distribution, with two notable outliers at around 0.7 and 0.9. Since Zhang's metric can only sit between values of -1 and 1, a 0.9 and 0.7 metric would both be very significant. We'll filter by Zhang's metric figures over 0.1 so that we can see the outliers in addition to rules on the upper tail of the Zhang's metric bell curve.


```python
# Filter rules with high zhangs_metric
high_zm_rules = rules[rules['zhangs_metric'] > 0.1].sort_values('zhangs_metric', ascending=False)

# Show the filtered high-quality rules
print(high_zm_rules.to_markdown())
```

    |    | antecedents                | consequents                 |   antecedent support |   consequent support |   support |   confidence |    lift |   leverage |   conviction |   zhangs_metric |
    |---:|:---------------------------|:----------------------------|---------------------:|---------------------:|----------:|-------------:|--------:|-----------:|-------------:|----------------:|
    | 15 | frozenset({'plain bread'}) | frozenset({'jam'})          |             0.323031 |            0.082925  | 0.0723709 |    0.224037  | 2.70169 | 0.0455836  |      1.18185 |        0.930412 |
    | 14 | frozenset({'jam'})         | frozenset({'plain bread'})  |             0.082925 |            0.323031  | 0.0723709 |    0.872727  | 2.70169 | 0.0455836  |      5.31905 |        0.686815 |
    | 25 | frozenset({'croissants'})  | frozenset({'wiener'})       |             0.674331 |            0.133811  | 0.0983792 |    0.145892  | 1.09028 | 0.00814644 |      1.01414 |        0.254266 |
    | 12 | frozenset({'angbutter'})   | frozenset({'refreshments'}) |             0.743686 |            0.0817942 | 0.0648323 |    0.0871769 | 1.06581 | 0.00400304 |      1.0059  |        0.240894 |
    | 21 | frozenset({'croissants'})  | frozenset({'plain bread'})  |             0.674331 |            0.323031  | 0.23219   |    0.344326  | 1.06593 | 0.0143605  |      1.03248 |        0.189911 |
    | 10 | frozenset({'angbutter'})   | frozenset({'croissants'})   |             0.743686 |            0.674331  | 0.524312  |    0.705018  | 1.04551 | 0.0228214  |      1.10403 |        0.169816 |
    |  9 | frozenset({'angbutter'})   | frozenset({'cakes'})        |             0.743686 |            0.370147  | 0.285337  |    0.38368   | 1.03656 | 0.0100641  |      1.02196 |        0.137608 |
    | 11 | frozenset({'croissants'})  | frozenset({'angbutter'})    |             0.674331 |            0.743686  | 0.524312  |    0.777529  | 1.04551 | 0.0228214  |      1.15212 |        0.133652 |
    |  6 | frozenset({'angbutter'})   | frozenset({'coffees'})      |             0.743686 |            0.272522  | 0.209574  |    0.281804  | 1.03406 | 0.00690341 |      1.01293 |        0.128515 |
    | 23 | frozenset({'croissants'})  | frozenset({'jam'})          |             0.674331 |            0.082925  | 0.0580475 |    0.0860816 | 1.03807 | 0.00212861 |      1.00345 |        0.112599 |
    | 31 | frozenset({'croissants'})  | frozenset({'cakes'})        |             0.674331 |            0.370147  | 0.258952  |    0.384013  | 1.03746 | 0.00935055 |      1.02251 |        0.110877 |
    

Findings:
- The Zhang's metric seems to give extra focus to the recriprocals of rules that typically have lower figures in all other metrics than their counterparts.
  - This enables us to take a closer look at the other side of some of the more interesting rules observed in prior metrics, that were otherwised excluded due to lower support and confidence values.
- We can see that both our Zhang's metric outliers are rule variants of the "jam + plain bread" item pair.
  - It's likely safe to say at this point that these two items are highly associated within the bakery.
- Both "wiener + croissants" rules have high Zhang metrics, with the "croissants -> wiener" rule sitting at a pretty high 0.27.
- The "angbutter -> refreshments" rule sits just below this at 0.24, which is still pretty high for this set of rules.

## Conclusions

### Bread with Jam

Perhaps the most-supported rule that we can take away from our set of rules is the association between "plain bread" and "jam". Bread/toast with jam is a pretty intuitive item combination, so it's not difficult to see why these two items together see high levels across all association metrics in at least one direction. The confidence and conviction levels are particularly high for the rule "if jam, then plain bread", as it's pretty logical that if a person buys a jam, they will often seek an item to spread it on; in most instances, this item is bread or toast. It's not as sure of a rule in the opposite direction, as only some people who buy bread will also buy jam. This could be for a number of reasons, but it wouldn't hurt to raise a recommendation for upselling jam items to all bread buyers. This could potentially inform customers to the availability of jam as a complementary item, and there's reason to believe this could boost the sales of jam, and potentially even both items together as a combo.

### Item Bundles/Combos

A number of less notable, supported rules exist between combinations of popular items, such as the angbutter bread, plain bread, one of the many different croissants, or cake products. In these instances, it may be beneficial to organize a number of different campaigns to drive sales across product categories, including BOGO bundling, item combos, and cross-promotion. Noting that angbutter is a top-selling item, and that angbutter purchases often coincide with different drink purchases (both "refreshments" and "coffees"), creating a food-and-drink combo for angbutter buyers might be a terrific idea to drive sales in either category. Additionally, given that the bakery is not open on Tuesdays, a creative and sustainability-driven marketing campaign could involve silent BOGO bundling (think: "buy one, get an extra item free 'accidentally'"); this could have the dual benefit of minimizing waste from supply spoilage during weekly closures, and could also act as item sampling for potential customers who would otherwise not try some item at a cost.

### Pig in a Blanket?

Aside from jam-associated rules, rules between high-support items, and rules between angbutter and drink items, the other noteworthy rule category observed is between the items "croissants" and "weiner". Here, the "weiner" item refers to a type of sausage bread (as stated by the uploader), but the specific qualities are not clear. However, it would be smart to further investigate the reason of association for these items. I like to think that maybe each "weiner" item has an excess in sausage, and that customers are using the excess to make little pigs in a blanket; I should note that this is pure head-canon. Whatever, the reason for association, it could lead to the creation of a revolutionary new top-selling item, or an improved version of an old favorite.
