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
