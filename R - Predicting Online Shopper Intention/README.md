---
title: "Final Project: Predicting Online Shopper's Intention"
author: "Bryant Jay"
date: "`r Sys.Date()`"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

### Environment
Set seed and unpack necessary libraries.

```{r environment, message = FALSE, warning = FALSE}
set.seed(999)

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

```{r data_import}
# My GitHub-hosted raw CSV source
url = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/R%20-%20Predicting%20Online%20Shopper%20Intention/source_files/online_shoppers_intention.csv"

osi <- read_csv(url)

```

### First Look

```{r first_look}
osi %>% head()
```

It looks like the first six fields represent page metrics of the online sessions by consumers. There are three categories for website pages: "Administrative", "Informational", and "Product-Related". Each observation of the data records the number of pages the user visited of [page category], and the amount of time they spent in that category of pages [page category]`Related`.

There are three additional numeric metrics. "BounceRates

The remaining fields represent categorical variables

### Duplicates

```{r duplicates}
osi[duplicated(osi), ]
```

There's no ID column which exists to test for an exact duplication of instances. Some rows are duplicated, but closer inspection indicates that they all share near-zero metrics. A possible explanation is that these instances represent users who misclick links or pop-up ads and immediately exit the session. Since this could represnt prospective marketing targets who failed to be converted, these duplicates may not be worth removing from the data.

### Data Consistency

```{r data_consitency}
# All levels of Month are 3-letter months except June which is written in full.
unique(osi$Month)

# Fix 'June' spelling to be consistent
osi$Month[osi$Month == "June"] <- "Jun"

```

### Convert Variables for Graphing

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

### Exploratory Data Analysis (EDA)

#### Violin Plots of Page Metrics
```{r violin_plots}
plot_violin <- function(dframe = osi, y_val, y_lab, fill_color){
  ggplot(dframe, aes(x = as.factor(Revenue), y = .data[[y_val]])) +
    geom_violin(color = fill_color, fill = fill_color, trim= FALSE, alpha = .4, linewidth = .75) +
    scale_y_sqrt() + 
    labs(x = "Revenue") +
    labs(y = y_lab)+
    theme_classic()
}

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

#### Density Plots of Session Metrics

```{r density_plots}
x_vals = c("BounceRates", "ExitRates", "PageValues")

plot_dens <- function(dframe = osi, x_val){
  ggplot(dframe, aes(.data[[x_val]])) +
    geom_density(aes(fill = Revenue), alpha = .4, linewidth = .75) +
    scale_x_sqrt() +
    scale_y_sqrt() +
    labs(y = " ") +
    theme_classic()
}

grid.arrange(grobs = pmap(
    list(x_val = c("BounceRates", "ExitRates", "PageValues")),
    plot_dens),
  nrow = 3, ncol = 1)

```

#### Pair Plot

```{r pair_plot, eval = FALSE}
ggpairs(select(osi, Administrative, Administrative_Duration, Informational,
               Informational_Duration, ProductRelated, ProductRelated_Duration, 
               BounceRates, ExitRates, PageValues))
```

#### Categorical Bar Counts

```{r bar_plot}
plot_bar <- function(dframe = osi, x_val){
  ggplot(dframe, aes(.data[[x_val]], fill = Revenue)) +
    geom_bar(alpha = .4) +
    scale_x_discrete() +
    labs(y = " ") +
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))  
}

grid.arrange(grobs = pmap(
  list(x_val = c("SpecialDay", "Month", "OperatingSystems",
                 "Browser", "Region", "TrafficType",
                 "VisitorType", "Weekend", "Revenue")),
  plot_bar),
  nrow = 3, ncol = 3)
```

#### Conversion Ratios for Categories

```{r stacked_bars}
plot_bar <- function(dframe = osi, x_val){
  ggplot(dframe, aes(.data[[x_val]], fill = Revenue)) +
    geom_bar(position = "fill", alpha = 0.6) +  # Stacked bars with proportions summing to 100%
    scale_x_discrete() +
    labs(y = "Percentage") +  # Y-axis label
    theme_classic() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))  # Rotate x-axis labels
}

grid.arrange(grobs = pmap(
  list(x_val = c("SpecialDay", "Month", "OperatingSystems",
                 "Browser", "Region", "TrafficType",
                 "VisitorType", "Weekend", "Revenue")),
  plot_bar),
  nrow = 3, ncol = 3)
```

### Data Preprocessing

#### Convert Variables for Modeling

```{r vc_modeling}
osi <- osi %>% 
  mutate(SpecialDay = as.integer(SpecialDay),
         OperatingSystems = as.factor(OperatingSystems),
         Browser = as.factor(Browser),
         Region = as.factor(Region),
         TrafficType = as.factor(TrafficType),
         VisitorType = as.factor(VisitorType),
         Weekend = as.integer(Weekend),
         Revenue = as.integer(Revenue))

str(osi)
```

#### Feature Engineering

```{r feature_engineering}
# Holiday Season
osi$HolidaySeason = ifelse(osi$Month %in% c("Sep", "Oct", "Nov", "Dec"),
                           1, 0)
osi$HolidaySeason = factor(osi$HolidaySeason)

# Last Minute Shopper
osi$LastMinShopper = ifelse(osi$VisitorType == "Returning_Visitor" & osi$SpecialDay >= 0.6,
                            1, 0)
osi$LastMinShopper = factor(osi$LastMinShopper)

t.test(osi$Revenue ~ osi$HolidaySeason, alternative = "two.sided")
```

#### One Hot Encoding

```{r one_hot}
osi_copy <- osi
osi_copy$Revenue <- as.factor(osi_copy$Revenue)

osi <- one_hot(as.data.table(osi))
osi$Revenue <- as.factor(osi$Revenue)

str(osi)
```

#### Data Split

```{r train_test}
input_osi <- createDataPartition(y = osi$Revenue, p = 0.8, list = FALSE)

train_osi <- osi[input_osi,]
test_osi <- osi[-input_osi,]

dim(train_osi)
dim(test_osi)

table(train_osi$Revenue) %>% prop.table()
table(test_osi$Revenue) %>% prop.table()
```

#### Center and Scale

```{r center_scale, eval = FALSE}
preproc_osi <- preProcess(train_osi, method = c("center", "scale", "nzv"))
preproc_osi
```

### Model Development

#### Logistic Regression

```{r, eval = FALSE}
logistic_model = train(Revenue ~ ., data = preproc_osi,
                       method = "glm", family = "binomial")

summary(logistic_model)
```

#### Stepwise Regression

```{r, eval = FALSE}
step_model = train(Revenue ~ ProductRelated_Duration + ExitRates + PageValues +
                     Month_Mar + Month_Dec + TrafficType_1 + TrafficType_2 +
                     TrafficType_3 + TrafficType_4 + TrafficType_13, data = train_osi,
                   method = "glmStepAIC", family = "binomial")

summary(step_model)
```

#### Predictions & Model Evaluation

```{r, eval = FALSE}
# Logistic Model Predictions
logistic_predictions = predict(logistic_model, newdata = test_osi)
confusionMatrix(logistic_predictions, test_osi$Revenue)

# Stepwise Model Predictions
step_predictions = predict(step_model, newdata = test_osi)
confusionMatrix(step_predictions, test_osi$Revenue)
```

#### Decision Tree Model

```{r, eval = FALSE}
tree_model = train(y = train_osi$Revenue, x = training_set, method = "rpart")
rpart.plot(tree_model$finalModel)
plot(varImp(tree_model))

tree_predictions = predict(tree_model, newdata = test_osi)
confusionMatrix(tree_predictions, test_osi$Revenue)
```

#### Bagging Model

```{r, eval = FALSE}
bagged_model = train(y = train_osi$Revenue, x = training_set, method = "treebag")
plot(varImp(bagged_model))

bagged_predictions = predict(bagged_model, newdata = test_osi)
confusionMatrix(bagged_predictions, test_osi$Revenue)
```

#### Random Forest Model

```{r, eval = FALSE}
rf_model = train(y = train_osi$Revenue, x = training_set,
                 method = "rf", prox = TRUE, verbose = TRUE)

plot(rf_model)
plot(rf_model$finalModel)
plot(varImp(rf_model))

rf_predictions = predict(rf_model, newdata = test_osi)
confusionMatrix(rf_predictions, test_osi$Revenue)
```

