# Final Project: Predicting Online Shopper's Intention
#### Bryant Jay
#### Summer 2022

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Problem

Inveon tracks visitor sessions and provides consultancy based on their analysis of a business' website. The firm would like to know what features belong to customers who result in a sale for their clients. We are interested in finding out how much time these people spend on the site, when they browse and buy, where they're located, and what technologies they use to explore a company's online store. We want to see the common themes/characteristic of those household, look at the factors that affect income level the most, and put resources into areas that can help increase their income level.

What are the strongest predictors of shopper intent for online visitors to a business' website? How can we use this information to target which aspect of our website fulfills conversion in a customer's journey?

## Environment

Set seed and unpack necessary libraries.

```{r environment, message=FALSE, warning=FALSE}
# Set a random seed to ensure reproducibility
set.seed(999)

# Required packages
library(GGally)
library(gridExtra)
library(caret)
library(data.table)
library(mltools)
library(rpart)
library(rpart.plot)
library(randomForest)
library(tidyverse)
```

### Data Import

The dataset for this analysis was initially obtained as the ["Online Shopper Purchasing Intent Dataset"](https://archive.ics.uci.edu/dataset/468/online+shoppers+purchasing+intention+dataset) from the [UCI machine learning repository](https://archive.ics.uci.edu/).

The data was jointly collected and donated in 2018 by Inveon and the Department of Computer Engineering, in the College of Engineering and Natural Sciences, at Bahcesehir University. The dataset was formed so that each session would belong to a different user in a 1-year period to avoid any tendency to a specific campaign, special day, user profile, or period.

For reproducibility and cleaner code, I'm going to read the data in CSV format from a file source I'm hosting on my GitHub page for this project:

```{r data_import}
# My GitHub-hosted raw CSV source
url = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/R%20-%20Predicting%20Online%20Shopper%20Intention/source_files/online_shoppers_intention.csv"

# Data read directly from raw CSV file
osi <- read_csv(url)
```

Our download message indicates some basic metadata: - 12330 instances - 18 columns, including: - 2 character fields - 2 binary data fields - 14 numeric fields

### First Look

Now that the data is imported into R, we can have a closer look.

```{r first_look}
osi %>% head()
```

The first six fields represent page metrics of the online sessions by consumers. There are three categories for website pages: "Administrative", "Informational", and "Product-Related". Each observation of the data records the number of pages the user visited of [page category], and the amount of time they spent in that category of pages [page category]`Related`. The former grouping are integer values, while the latter are continuous values of some standard time unit (I believe in seconds, but it is not clarified).

-   "Administrative": Number of administrative pages visited during visitor's session.

-   "Administrative_Duration": Total time visitor spent in administrative pages.

-   "Informational": Number of informational pages visited during visitor's session.

-   "Informational_Duration": Total time visitor spent in informational pages.

-   "ProductRelated": Number of product-related pages visited during visitor's session.

-   "ProductRelated_Duration": Total time visitor spent in product-related pages.

There are three additional numeric metrics.

-   "BounceRates": The percentage of visitors who enter the site from that page and then leave ("bounce") without triggering any other requests to the analytics server during that session. A continuous ratio.

-   "ExitRates": calculated as for all pageviews to the page, the percentage that were in the last session. A continuous ratio.

-   "PageValues": the average value for a web page that a user visited before completing an e-commerce transaction. Like, the above page counts, this is an integer count.

The remaining fields represent categorical variables.

-   "SpecialDay": Proximity of start of session to a busier holiday or occasion. (0 if furthest away from any special day, 1 if on a specific special day or holiday.) These values are represented as numbers, but seem to indicate discrete groupings like that of a questionnaire survey response.

-   "Month": Month session was initiated.

-   "OperatingSystems": Unspecified OS used by visitor.

-   "Browser": Unspecified internet browser used by visitor.

-   "Region": Unspecified region the visitor started session in.

-   "TrafficType": Type of internet traffic. Without labels, I'm not clear on what this could represent more specifically.

-   "VisitorType": Returning, New, or Other.

-   "Weekend": (T/F) Did session take place on the weekend?

Finally, the outcome variable we are predicting is "Revenue", a binary feature representing whether or not the website visitor's session resulted in a purchase.

### Missing Values

```{r missing_values}
osi %>% 
  is.na() %>% 
  sum() %>% 
  print()
```

### Duplicates

There are no missing values in the data set, but there are some rows with duplicate data. Here's a look:

```{r duplicates}
# Displays all instances of duplicated rows
osi[duplicated(osi), ]
```

There's no ID column which exists to test for an exact duplication of instances. Some rows are duplicated, but closer inspection indicates that they all share near-zero metrics. These instances probably represent users who instantly bounced from the website upon entering a session.

Since this could represent prospective marketing targets who failed to be converted, we'll keep these duplicates in as valid data.

### Data Consistency

The month column only contains 10 possible values, as there are no data instances occurring in January or April. All months are given in their abbreviated 3-letter formats, with the exception of June. We'll quickly correct this for consistency.

```{r data_consitency}
# All levels of Month are 3-letter months except June.
unique(osi$Month)

# Fix 'June' spelling to be consistent
osi$Month[osi$Month == "June"] <- "Jun"

```

### Convert Variables for Graphing

After checking for any potentially disruptive data issues, the columns can be converted to their appropriate data types in preparation for graphing. This involves converting the page counts to integer types, and the categorical fields to discrete factor data types. The "Month" field will also receive an explicit ordering.

```{r vc_graphing}
osi <- osi %>%
  mutate(Administrative = as.integer(Administrative),
         Informational = as.integer(Informational),
         ProductRelated = as.integer(ProductRelated),
         Month = factor(Month, levels = c("Feb", "Mar", "May", "Jun", "Jul",
                                          "Aug", "Sep", "Oct", "Nov", "Dec")),
         SpecialDay = factor(SpecialDay),
         OperatingSystems = factor(OperatingSystems),
         Browser = factor(Browser),
         Region = factor(Region),
         TrafficType = factor(TrafficType),
         VisitorType = factor(VisitorType))

osi %>% summary()
osi %>% glimpse()
```

## Exploratory Data Analysis (EDA)

I want to take an explicit look at how each variable will affect the outcome variable, so I'm going to integrate "Revenue" into all visuals.

### Violin Plots of Page Metrics

First, we'll compare all the different page metrics to one another using a series of violin plots. We can create a custom violin plotting function based on `ggplot`'s violin geom, map it across each of the first six variables, and tied everything together into a single visual. These data fields are all very skewed, so a square-root y-axis scale will help to maximize the insights given by the majority of user data.

```{r violin_plots}
# Custom violin plotting function
plot_violin <- function(dframe = osi, y_val, y_lab, fill_color){
  ggplot(dframe, aes(x = as.factor(Revenue), y = .data[[y_val]])) +
    geom_violin(color = fill_color, fill = fill_color, trim= FALSE, alpha = .4, linewidth = .75) +
    scale_y_sqrt() + 
    labs(x = "Revenue") +
    labs(y = y_lab)+
    theme_classic()
}

# Arrange the subplots into single figure
grid.arrange(grobs = pmap(list(y_val = c("Administrative", "Administrative_Duration",
                                         "Informational", "Informational_Duration",
                                         "ProductRelated", "ProductRelated_Duration"), 
                               y_lab = c("Num. Pages Admn.", "Seconds Spent in Admn.",
                                         "Num. Pages Info.", "Seconds Spent in Info.",
                                         "Num. Pages Prod.", "Seconds Spent in Prod."),
                               fill_color = c("darkblue", "darkblue",
                                              "darkgreen", "darkgreen",
                                              "darkred", "darkred")
                              ),
                          plot_violin),
             nrow = 3, ncol = 2)
```

The details of this are easy to gloss over, but it can be noticed that the sessions resulting in a purchase (i.e. `Revenue == TRUE`) typically include a slightly higher page counts and page durations.

Product-Related pages and times spent of those pages appear the most differentiated predictor on purchase intention, as the entire median of the data appears to be elevated in instances of a purchase.

### Density Plots of Session Metrics

Similar to the prior visual, we'll view the distributions of the session metrics ("BounceRates", "ExitRates", and "PageValues") using a series of density plots.

```{r density_plots}
# Listing the columns to be plotted
x_vals = c("BounceRates", "ExitRates", "PageValues")

# Custom density plotting function
plot_dens <- function(dframe = osi, x_val){
  ggplot(dframe, aes(.data[[x_val]])) +
    geom_density(aes(fill = Revenue), alpha = .4, linewidth = .75) +
    scale_x_sqrt() +
    scale_y_sqrt() +
    labs(y = " ") +
    theme_classic()
}

# Arrange the subplots into single figure
grid.arrange(grobs = pmap(
    list(x_val = c("BounceRates", "ExitRates", "PageValues")),
    plot_dens),
  nrow = 3, ncol = 1)

```

There's a ton of overlap between the Revenue classes for bounce rates and exit rates, with the bulk of converted sessions seeming to have marginally lower rates in both instances.

Page Values between converted and non-converted visitors seems more differentiated. Page values for many non-converted visitors sits at or close to zero, while those of coverted visitors is higher.

### Pair Plot

Before moving on to categoricals, let's first analyze any correlation between our numeric features using a pair plot. This will aid in our feature pruning later on.

```{r pair_plot, eval = FALSE}
# Pair plot of numeric features
ggpairs(select(osi, Administrative, Administrative_Duration, Informational,
               Informational_Duration, ProductRelated, ProductRelated_Duration,
               BounceRates, ExitRates, PageValues))
```

For the most part, the many variable combinations don't seem to be too heavily correlated. There is, of course, some medium-to-strong correlations between the respective page counts and page durations of the first six fields (0.600, 0.619, and 0.861). The bounce rates and exit rates fields also seem to be heavily correlated. We should avoid doubling up on the correlated features when training our final models, in order to avoid overfitting.

### Categorical Bar Counts

Let's take a look at categorical features now. We have 8 of them, in addition to the outcome variable "Revenue". First, we'll apply a function for a classic bar plot across each category in order to get a feel for the counts of each categorical value. Since a 3x3 grid would be an optimal way to arrange this, lets explore a bar plot of the "Revenue" variable, too.

```{r bar_plot}
# Custom bar plot function
plot_bar <- function(dframe = osi, x_val){
  ggplot(dframe, aes(.data[[x_val]], fill = Revenue)) +
    geom_bar(alpha = .4) +
    scale_x_discrete() +
    labs(y = " ") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "none")  
}

# Arrange the subplots into single figure
grid.arrange(grobs = pmap(
  list(x_val = c("SpecialDay", "Month", "OperatingSystems",
                 "Browser", "Region", "TrafficType",
                 "VisitorType", "Weekend", "Revenue")),
  plot_bar),
  nrow = 3, ncol = 3)
```

This presents a rough impression of what kinds of details pertain to a variety of users across many different sessions. This will be one of the first times that we notice a major data constraint of this dataset: there is not a whole lot of context. Most of the categorical values are replaced by integer representations, and not accompanying key is given to interpret what these integer codes might represent. For the most part, we will have to infer without specific context, which will hinder our ability to engineer useful features later on.

The majority of sessions do not occur near any sort of special holiday; this skewed distribution may indicate that the sensitivity of this feature only measures the temporal distance within a week or so of all holidays, and that most days of the year are "0".

There are instances of sessions from every month except January and April, with a must larger chunk of session instances occurring in March, May, November, and December. This seems to indicate some seasonality in site activity, like that of a Spirit Halloween. Because the business is Turkish, it could be that activity in the months of May and March may spike due to proximity to Ramadan or Eid, with additional spikes in November and December due to the seasonality of Western holiday markets (perhaps the company deals in exports, too). It's hard to say definitively without further context.

Most users seem to use Operating Systems "1", "2", and "3", and Browsers "1" and "2". Users by region is more evenly distributed, but still have higher clusters in Regions "1" and "3". It is not clear whether these regions represent global regions, national states/provinces, or even markets within a city.

"Traffic Type" as variable is not clear on its definition. This maay represent avenues by which a user reached or were referenced to the website (i.e. ad-click, search engine, direct URL, etc.). There are many possible values, but most sessions pertain to Traffic Types "1", "2", "3", "4", and "13".

There are many more returning visitors to the site than new visitors. "Other" visitor type might represent some type of site administrator. The ratio of weekend-to-weekday seems to be relatively close to 2:5, so the day data is likely distributed evenly across each day of the week. Most visitor sessions do not result in a purchase.

### Conversion Ratios for Categories

Let's also take a look at the relative distribution of `TRUE` and `FALSE` Revenue values within each individual categorical value, using a set of bar ratios. This can help to feel for which specific user attributes may indicate a higher likelihood to make a purchase.

```{r stacked_bars}
# Custom (stacked) bar plot function
plot_stack <- function(dframe = osi, x_val){
  ggplot(dframe, aes(.data[[x_val]], fill = Revenue)) +
    geom_bar(position = "fill", alpha = 0.6) +  # Stacked bars with proportions summing to 100%
    scale_x_discrete() +
    labs(y = "Percentage") +  # Y-axis label
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1),
          legend.position = "none")  # Rotate x-axis labels
}

# Arrange the subplots into single figure
grid.arrange(grobs = pmap(
  list(x_val = c("SpecialDay", "Month", "OperatingSystems",
                 "Browser", "Region", "TrafficType",
                 "VisitorType", "Weekend", "Revenue")),
  plot_stack),
  nrow = 3, ncol = 3)
```

We can see a fairly consistent distribution of purchases-to-nonpurchases across values within most given categories. There are some short spikes in these ratios in variables such as "Browser" and "TrafficType", but these pertain to low-count category values; as such, these spike trends are pretty difficult to rely on. One exception is the month category value of November, which is a common session attribute and also has a higher chance of a purchase relative to other months.

## Data Preprocessing

Now that we've viewed our data, we can ready it in preparation of modeling.

### Convert Variables for Modeling

The "Special" day field already has an ordered/numeric quality about it, so let's convert it back to a numeric data type. We'll also swap the `True`/`False` values in the "Weekend" column to 1's and 0's.

```{r vc_modeling}
osi <- osi %>% 
  mutate(SpecialDay = as.double(SpecialDay),
         Weekend = as.integer(Weekend))

# Optional sampling
# osi <- osi %>% sample_frac(0.1)

str(osi)
```

### Feature Engineering

Lack of extensive context for features; most categories contain unspecified values, represented by integers (1, 2, 3, 4, etc...). Given the limited information, I'll create some sample features that may or may not represent a given type of purchasing scenario. (\* I don't really intend for these to be effective, this just to fill an project assignment requirement within the contextual constraints of the data.)

Holiday Season: Representing the more active annual period in Western markets, from September to December.

Last Minute Shopper: Indicates a returning visitor who's session is closer in proximity to a "special day" or holiday.

```{r feature_engineering}
# Holiday Season
osi$HolidaySeason = ifelse(osi$Month %in% c("Sep", "Oct", "Nov", "Dec"),
                           1, 0)

# Last Minute Shopper
osi$LastMinShopper = ifelse(osi$VisitorType == "Returning_Visitor" & osi$SpecialDay >= 0.6,
                            1, 0)
# Two-sided t-test of new "Holiday Season" feature
t.test(osi$Revenue ~ osi$HolidaySeason, alternative = "two.sided")
```

### One Hot Encoding

Since we need all our features to be in numeric format, we of course need to one-hot encode our factor variables into many numeric features. The many unique values within the "Browser" and "TrafficType" columns is going to lead to a whole lotta feature variables to look at, which will be *SO FUN*.

```{r one_hot}
# Copy of data frame
osi_copy <- osi
osi_copy$Revenue <- as.factor(osi_copy$Revenue)

# Applying one-hot encoding to categorical variables
osi <- one_hot(as.data.table(osi))
osi$Revenue <- as.factor(osi$Revenue)

str(osi)
```

### Data Split

The data is split into train and test sets prior to pre-processing.

```{r train_test}
# Setting an partition object to split the data on
input_osi <- createDataPartition(y = osi$Revenue, p = 0.8, list = FALSE)

# Separating the data into train and test sets
train_osi <- osi[input_osi,]
test_osi <- osi[-input_osi,]

# Check the lengths of each
dim(train_osi)
dim(test_osi)

# 
table(train_osi$Revenue) %>% prop.table()
table(test_osi$Revenue) %>% prop.table()
```

### Center and Scale

We will center and scale our data, and remove any feature variables that have a near-zero variance.

```{r center_scale}
# Center and scale the data, and remove features with near-zero values
preproc_steps <- preProcess(train_osi, method = c("center", "scale", "nzv"))

# Apply the pre-processing to the training data to get the scaled version
train_proc <- predict(preproc_steps, newdata = train_osi)
test_proc <- predict(preproc_steps, newdata = test_osi)

# Now, train_proc is the scaled data that can be used in model training
train_proc %>% head()
test_proc %>% head()
```

## Model Development

Finally, we can start modeling. I'm going to explore modeling methods using logistic regression, step-wise logistic regression, basic decision trees, and ensemble tree methods using bagging and random forests.

For this first part, we just want to do some basic modeling of all available features, and probe for the most effective features. Because, we're using all features, we will not be employing a random forest model in this section. That means right now we'll focus on: - logistic regression - step-wise regression - basic decision trees - bagged decision trees

\* *With particular focus on the step-wise model.*

### Logistic Regression

Logistic regression is the common go-to method for these sort of binary classification problems. It's simple, easy to understand, and works well for a wide assortment of scenarios. Logistic regression predicts probabilities between 0 and 1; these probabilities are then used to classify the outcome of an observation into one of two categories. A threshold is estanblished, and the observation is classified into one of the categories depending on whether its above or below that threshold.

```{r logistic_model_full, warning=FALSE}
# Building a logistic model using all (remaining) features
logistic_model_full = train(Revenue ~ ., data = train_proc, method = "glm", family = "binomial")

# Summary of the logistic regression model
summary(logistic_model_full)
```

The model summary gives us some initial insight into which feature variables are most useful in generating reliable predictions.

*Potential importance*: ExitRates, PageValues, Month_Mar, Month_May, Month_Nov, Month_Dec, TrafficType_3, TrafficType_13

*Lesser importance*: ProductRelated, ProductRelated_Duration, Region_2, TrafficType_1, Weekend

```{r log_model_eval}
# Logistic Model Predictions
logistic_predictions_full = predict(logistic_model_full, newdata = test_proc)

# Summary of the logistic tree model
logistic_cm_full <- confusionMatrix(logistic_predictions_full, test_proc$Revenue)
print(logistic_cm_full)
```

From the confusion matrix, we can take away a baseline for all of our metrics. While accuracy should not be relied on as the sole factor when grading a model, it's good to look at what sort of accuracy expectations we're dealing with here. As mentioned, the logistic model is one of the simplest models employed for classification tasks, so our 89.13% accuracy metric here is a good frame of reference for grading future, more complex models.

As an additional reference, we can also compare a scenario where a rudimentary model just guesses `FALSE` predictions for all outcomes. This accuracy figure would simply be calculated as the percentage original of the "Revenue" column that contains `FALSE` values, amounting to an 84.53% accuracy rating.

The logistic model is a nearly 5% improvement over this figure, which is good, as it means the model is at least better than the "Christmas Tree on the SAT" type of response.

### Stepwise Regression

Step-wise models are generally less effective at finalized modeling, but are a terrific method by which to check which features are the most effective. They work by applying logistic models to different formula combinations of features in a "step-by-step" method, and then selecting the most optimal. Think of it like apply the previous model in a loop. Because of its relatively standard use in probing for effective features, I'm going to rely especially on this model for final decisions when pruning unnecessary features variables.

The full summary output for the stepwise model is too extensive to show here, as it includes all feature combinations in the one-hot encoded dataset.

```{r step_model_full, eval=FALSE, warning=FALSE, message=FALSE}
# Building a step-wise model using all (remaining) features
step_model_full = train(Revenue ~ ., data = train_proc,
                   method = "glmStepAIC", family = "binomial")

# Summary of the stepwise regression model
summary(step_model_full)

# Stepwise Model Predictions
step_predictions_full = predict(step_model_full, newdata = test_proc)

# Converting the format of predicted binary values
step_predictions_logical_full <- factor(ifelse(step_predictions_full == "FALSE", FALSE, TRUE), levels = c(FALSE, TRUE))

# Summary of the step-wise regression model
step_cm_full <- confusionMatrix(step_predictions_logical_full, test_osi$Revenue)
```

Our stepwise model summary shows us a grouping of significant features similar to that of the base logistic regression model. However, ProductRelated metrics are deemed "more important", and additional attention is given to instances where the visitor's Operating System and/or Browser are of category "2".

*Potential importance*: ProductRelated, ProductRelated_Duration, ExitRates, PageValues, Month_Mar, Month_May, Month_Nov, Month_Dec, OperatingSystems_2, TrafficType_3, TrafficType_13

*Lesser importance*: Browser_2, Region_2, TrafficType_1, Weekend

### Decision Tree Model

In preparation for all of our tree-based methods, we need to separate the outcome variable from the training set (otherwise, the models will erroneously treat it as feature with 100% accuracy).

```{r tree_prep}
# Drop the "Revenue" column from train_proc
train_rev = train_proc %>% select(Revenue)
train_features <- train_proc %>% select(-Revenue)
```

A decision tree is a simple and powerful method used for classification tasks. It splits the data into subsets based on feature values, creating a tree-like structure where each internal node represents a decision based on a feature, and each leaf node represents a class label. To make a prediction, the model follows the decisions from the root to a leaf, assigning the class that corresponds to that leaf.

The `rpart` package offers useful functions for interpreting decision tree results.

```{r rpart_tree}
# Building a decision tree model using all (remaining) features
tree_model_full = train(y = train_rev$Revenue, x = train_features, method = "rpart")

# Plot of decision tree structure
rpart.plot(tree_model_full$finalModel)

# Plot of feature importance
plot(varImp(tree_model_full))

# Testing on new data
tree_predictions_full = predict(tree_model_full, newdata = test_proc)

# Summary of the decision tree model
rpart_cm_full <- confusionMatrix(tree_predictions_full, test_osi$Revenue)
```

*Potential importance*: PageValues, ProductRelated_Duration, ProductRelated, ExitRates, VisitorType_Returning_Visitor, LastMinShopper

### Bagged Model

A "bagged" (bootstrap-aggregated) decision tree is an ensemble tree method. It works by creating multiple decision trees, each trained on a different random subset of the data. The predictions from all the trees contribute "votes" to make the final classification decision. Bagging helps reduce the model's variance, making it less likely to overfit the training data in scenarios with many potential predictors (such as this one).

```{r bagged_model_full}
# Building a bagged d-tree model using all (remaining) features
bagged_model_full = train(y = train_osi$Revenue, x = train_features, method = "treebag")

# Plot of feature importance
plot(varImp(bagged_model_full))

# Testing on new data
bagged_predictions_full = predict(bagged_model_full, newdata = test_proc)

# Summary of the bagged decision tree model
bagged_cm_full <- confusionMatrix(bagged_predictions_full, test_osi$Revenue)
```

*Potential importance*: PageValues, ProductRelated_Duration, ProductRelated, ExitRates, Administrative_Duration, BounceRates, Administrative, Informational_Duration, Informational

## Feature Selection and Pruning

We take our model training summaries on feature significance from each of the four models, and compare them using a heatmap:

![Feature Importance](https://github.com/bryantjay/Portfolio/blob/main/R%20-%20Predicting%20Online%20Shopper%20Intention/source_files/feature_importance.png?raw=true)

Generally, all models agree upon "PageValues" being a very significant predictor. "ExitRates" and both product-related page metrics are also treated with some importance by all models. The bagged tree model weighs slightly more importance toward the various numeric columns of our dataset, while the decision tree model claims that returning visitors and last-minute shoppers are also mild indicator of whether a transaction will occur.

However, I elect to predominantly rely on the stepwise model results, as (again) this type of model is pretty conventional in probing for features due to its systematic nature of trying each feature combination. This doesn't mean it's our final model; it's just a good model for this particular use.

One important thing is that "ProductRelated" and "ProductRelated_Duration" are highlighted as important features in every model we tried. However, remember that pair plot from earlier?

We know that these two features are very strongly correlated, so we should prune one of them. I'll opt to exclude the duration feature, as the page count variant seems to carry sightly lower p-values / slightly higher importance levels in most models.

```{r feature_selection}
# Drop the "Revenue" column from train_proc
training_set <- train_proc %>% select(
  ProductRelated, ExitRates, PageValues,
  Month_Mar, Month_May, Month_Nov, Month_Dec, OperatingSystems_2,
  Browser_2, Region_2, TrafficType_1, TrafficType_3, TrafficType_13,
  Weekend, Revenue
  )

# Separating "Revenue" outcome for tree-based models
train_rev <- training_set %>% select(Revenue)
train_features <- training_set %>% select(-Revenue)
```

## Improved Models

Now we can train each of our models again using our optimized set of predictors. Luckily, this will go much faster this time around for our first four models, since we are utilizing a smaller grouping of variable combinations.

We're also going to add in a random forest model as our fifth model.

### Logistic Regression

```{r logistic_model_pruned, warning=FALSE}
# Now that the data is preprocessed, use the processed data in the model training
logistic_model = train(Revenue ~ ., data = training_set, method = "glm", family = "binomial")

# Logistic Model Predictions
logistic_predictions = predict(logistic_model, newdata = test_proc)

# Summary of the logistic tree model
logistic_cm <- confusionMatrix(logistic_predictions, test_proc$Revenue)
logistic_cm
```

### Stepwise Regression

```{r step_model_pruned, eval=FALSE, warning=FALSE, message=FALSE}
# Building a step-wise model using selected features
step_model = train(Revenue ~ ., data = training_set,
                   method = "glmStepAIC", family = "binomial")

# Stepwise Model Predictions
step_predictions = predict(step_model, newdata = test_proc)

# Converting the format of predicted binary values
step_predictions_logical <- factor(ifelse(step_predictions == "FALSE", FALSE, TRUE), levels = c(FALSE, TRUE))

# Summary of the step-wise regression model
step_cm <- confusionMatrix(step_predictions_logical, test_proc$Revenue)
step_cm
```

### Decision Tree Model

```{r rpart_tree_pruned}
# Building a bagged d-tree model using selected features
tree_model = train(y = train_rev$Revenue, x = train_features, method = "rpart")
rpart.plot(tree_model$finalModel)
plot(varImp(tree_model))

# Predicting on new data
tree_predictions = predict(tree_model, newdata = test_proc)

# Summary of the decision tree model
rpart_cm <- confusionMatrix(tree_predictions, test_osi$Revenue)
rpart_cm
```

### Bagged Model

```{r bagged_model_pruned}
# Building a bagged d-tree model using selected features
bagged_model = train(y = train_rev$Revenue, x = train_features, method = "treebag")
plot(varImp(bagged_model))

# Predicting on new data
bagged_predictions = predict(bagged_model, newdata = test_proc)

# Summary of the bagged decision tree model
bagged_cm <- confusionMatrix(bagged_predictions, test_osi$Revenue)
bagged_cm
```

### Random Forest Model

A random forest is an ensemble learning method used for classification that combines many decision trees to improve accuracy and reduce overfitting. Each decision tree is trained on a random subset of the data, and each considers only a random subset of features when making splits. After all trees make their predictions, the final classification is determined by majority voting from all the trees, much like the bagged method. However, it also takes much long to run than any of the previous methods, so go turn on a movie or something if your replicating this.

```{r random_forest}
# Building a random forest model using selected features
rf_model = train(y = train_rev$Revenue, x = train_features,
                 method = "rf", prox = TRUE, verbose = TRUE)

plot(rf_model)
plot(rf_model$finalModel)
plot(varImp(rf_model))

# Predicting on new data
rf_predictions = predict(rf_model, newdata = test_proc)

# Summary of the random forest model
rf_cm <- confusionMatrix(rf_predictions, test_osi$Revenue)
rf_cm
```

## Model Performance

We've now preprocessed our data, probed for useful predictors, and trained and tested all of our models. It's time to compare the results of each model and generate a conclusion about which would be best to implement in a final decision.

We're going to use five common classification metrics to grade our performance:

### Accuracy

Accuracy is as simple as it gets. Overall, what percentage of outcomes did each model predict correctly?

Accuracy is important to consider, but it can often be misleading. 80% seems good enough, right? I mean, that's basically a B-minus; that's a lazy college student's dream! However...

In this scenario, if we were to guess "FALSE" for all outcomes, we would be correct 84.5% of the time (because FALSE outcomes make up 84% of the data). Anything worse than a 84.5% accuracy level would be garbage-level performance.

```{r accuracy_matrix}
# Calculate percentage of 'FALSE' values in the 'Revenue' factor column
false_percentage <- mean(osi$Revenue == "FALSE")

# Creating the Accuracy Matrix
accuracy_matrix <- data.frame(
  Model = c("Oops, all FALSE!", "Logistic", "Stepwise", "Decision Tree", "Bagged", "Random Forest"),
  Full_Model = c(
    false_percentage,
    logistic_cm_full$overall['Accuracy'],
    0.8933063, # step_cm_full$overall['Accuracy']
    rpart_cm_full$overall['Accuracy'],
    bagged_cm_full$overall['Accuracy'],
    NA
    ),
  Pruned_Model = c(
    false_percentage,
    logistic_cm$overall['Accuracy'], 
    0.8916836, # step_cm$overall['Accuracy']
    rpart_cm$overall['Accuracy'],
    bagged_cm$overall['Accuracy'],
    rf_cm$overall['Accuracy']
    )
)

# Viewing the results
print(accuracy_matrix)
```

Luckily, all of our models performed better than the "all-FALSE" method, so we know they're doing something right. Some models slightly improved after pruning predictors, and some worsened. Noticeably, our logistic and stepwise models now have the same accuracy statistic, because they both concluded on the same final model formula; this will carry on over the following metrics as well. The only model to show strong(-ish) improvements after pruning was the bagged tree model, and the new random forest model outperformed all others.

### Specificity

Specificity measures a model's success rate identifying the actual negative instances. For reference, an "all-FALSE" model would be graded as 1.0 here. It is calculated as ***Specificity = TN / (TN + FP)***, where TN is true negatives and FP is false positives.

```{r specificity_matrix}
# Creating the Specificity Matrix
specificity_matrix <- data.frame(
  Model = c("Oops, all FALSE!", "Logistic", "Stepwise", "Decision Tree", "Bagged", "Random Forest"),
  Full_Model = c(
    1.0,
    logistic_cm_full$byClass['Specificity'],
    0.4199475, # step_cm_full$byClass['Specificity']
    rpart_cm_full$byClass['Specificity'],
    bagged_cm_full$byClass['Specificity'],
    NA
    ),
  Pruned_Model = c(
    1.0,
    logistic_cm$byClass['Specificity'],
    0.4146982, # step_cm$byClass['Specificity']
    rpart_cm$byClass['Specificity'],
    bagged_cm$byClass['Specificity'],
    rf_cm$byClass['Specificity']
    )
)

# Viewing the results
print(specificity_matrix)
```

Specificity is a good metric to consider alongside others, but it is not the "best" metric by itself For reference, an "all-FALSE" model would be graded as 1.0 here. This is simply the success ratio at identifying actual negative outcomes, regardless of accuracy or precision. A lot of times, what this means in the context of a FALSE-heavy set of outcomes, is that the model is taking fewer risks in identifying potential TRUE values.

In this case, slight declines were observed in the specificity of both the Logistic and Stepwise pruned models relative to their full-model counterparts. The Decision Tree's specificity remained unchanged. Bagged specificity showed improvement between full and pruned models. Random Forest specificity came in at a level between that of the Decision Tree and Bagged pruned models.

### Sensitivity

Sensitivity (or "Recall") measures a model's success rate identifying the actual positive instances.

***Sensitivity = TP / (TP + FN)***

```{r sensitivity_matrix}
# Creating the Sensitivity Matrix
sensitivity_matrix <- data.frame(
  Model = c("Oops, all FALSE!", "Logistic", "Stepwise", "Decision Tree", "Bagged", "Random Forest"),
  Full_Model = c(
    0.0,
    logistic_cm_full$byClass['Sensitivity'],
    0.9798464, # step_cm_full$byClass['Sensitivity']
    rpart_cm_full$byClass['Sensitivity'],
    bagged_cm_full$byClass['Sensitivity'],
    NA
    ),
  Pruned_Model = c(
    0.0,
    logistic_cm$byClass['Sensitivity'],
    0.9788868, # step_cm$byClass['Sensitivity']
    rpart_cm$byClass['Sensitivity'],
    bagged_cm$byClass['Sensitivity'],
    rf_cm$byClass['Sensitivity']
    )
)

# Viewing the results
print(sensitivity_matrix)
```

Sensitivity is the opposite to specificity, and like specificity, sensitivity should not be considered in isolation. For reference, an "all-FALSE" model would be graded as a big, fat zero here; no TRUE outcomes were correctly predicted. If we thought about specificity as an indicator for a model's ability to take risk, sensitivity can sometimes indicate whether the model is taking *too much* risk.

We see a slight sensitivity deterioration in all revised models, except the Logistic model. These pruned models seem to be worsening in their ability to pick out TRUE instances. Random Forest sensitivity outperforms that of every other model, with the two other tree-based models underperforming relative to the regression models. When we consider the higher accuracy, higher specificity, and higher sensitivity of the Random Forest model together, it's starting to become clear that this model is somewhat outperforming the other variants.

### Precision Calculation

Precision measures the accuracy of all positive predictions.

***Precision = TP(TP + FP)***

```{r}
# Creating the Precision Matrix
precision_matrix <- data.frame(
  Model = c("Logistic", "Stepwise", "Decision Tree", "Bagged", "Random Forest"),
  Full_Model = c(
    logistic_cm_full$byClass['Precision'],
    0.902342, # step_cm_full$byClass['Precision']
    rpart_cm_full$byClass['Precision'],
    bagged_cm_full$byClass['Precision'],
    NA
  ),
  Pruned_Model = c(
    logistic_cm$byClass['Precision'],
    0.9014582, # step_cm$byClass['Precision']
    rpart_cm$byClass['Precision'],
    bagged_cm$byClass['Precision'],
    rf_cm$byClass['Precision']
  )
)

# Viewing the results
print(precision_matrix)
```

There is a slight decline in precision between the full and pruned states of all models (not including the Random Forest model, of course, which had no full counterpart). It should be noted that this decline is very minimal, and also isn't *necessarily* a negative.

If a model decides to take more risks and make more TRUE predictions, precision can be lowered as a result, even if accuracy is increased. The Random Forest model is less precise than the bagged model, but is also more accurate in all of its predictions. Meanwhile the precision of the Bagged model decreased, while its specificity metric increased, indicating it began defaulting to FALSE predictions more often

### F1 Score Calculation

F1 Score is a metric that combines both Precision and Recall (Sensitivity) into a single number using the harmonic mean:

*F1 = (2 x Precision x Recall)/(Precision + Recall)*

```{r}
# Creating the F1 Score Matrix
f1_score_matrix <- data.frame(
  Model = c("Logistic", "Stepwise", "Decision Tree", "Bagged", "Random Forest"),
  Full_Model = c(
    logistic_cm_full$byClass['F1'],
    0.9394985, # step_cm_full$byClass['F1']
    rpart_cm_full$byClass['F1'],
    bagged_cm_full$byClass['F1'],
    NA
  ),
  Pruned_Model = c(
    logistic_cm$byClass['F1'],
    0.9385783, # step_cm$byClass['F1']
    rpart_cm$byClass['F1'],
    bagged_cm$byClass['F1'],
    rf_cm$byClass['F1']
  )
)

# Viewing the results
print(f1_score_matrix)

```

The F1 scores are relatively consistent across all models: usually between 93.5% and 94.5% There is a slight improvement in Logistic model performance, while all other revised models face declines. These decreases are only marginal in the Stepwise and Decision Tree models, but more significant in the Bagged tree model. The Random Forest F1 score outperforms other models.

## Conclusions

When all the above classification metrics are taken together in whole, it's pretty safe to conclude that the Random Forest model is probably the best model for us to use in the future for predicting upon new data. It's accuracy level is higher than that of all other models, and its precision and F1 scores also sit on the mid-to-higher ends of each metric for all models.

The Bagged model seems to have some good prediction metrics at first, but after taking a closer look, this seems to be due to it taking fewer risks in making TRUE predictions (much like the all-FALSE scenario). Both regression models are less accurate than all of the tree models, but both of them also take somewhat greater risk in making TRUE predictions. The basic Decision Tree model actually seems to perform pretty well, maintaining good accuracy, precision, and F1 scores, while still keeping its sensitivity metric close to that of the Random Forest model and the two regression models; I think this model may be a good second alternative to the Random Forest model.

One drawback with the Random Forest model is it's black-box nature, of course. As a less interpretable model it can be hard to discern why certain prediction-making decisions are made. Luckily, this is a low-stakes online marketing scenario, predominantly used for projecting budgets or trying to find prospective market clusters. These aren't decisions which could drastically influence or affect people's lives, like a loan-approval scenario or a scenario identifying life-threatening diseases. A less-interpretable method is usually suitable here. If a more transparent method were needed for some reason, the basic Decision Tree model that we created is very easy to interpret; this could be provided as a potential alternative.

