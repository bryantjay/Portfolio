# Data sources.

The dataset for this analysis was initially obtained as the ["Online Shopper Purchasing Intent Dataset"](https://archive.ics.uci.edu/dataset/468/online+shoppers+purchasing+intention+dataset) from the [UCI machine learning repository](https://archive.ics.uci.edu/).

The data was jointly collected and donated in 2018 by Inveon and the Department of Computer Engineering, in the College of Engineering and Natural Sciences, at Bahcesehir University. The dataset was formed so that each session would belong to a different user in a 1-year period to avoid any tendency to a specific campaign, special day, user profile, or period.

For reproducibility and cleaner code, I'm going to read the data in CSV format from a file source I'm hosting on my GitHub page for this project:

```{r data_import}
# My GitHub-hosted raw CSV source
url = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/R%20-%20Predicting%20Online%20Shopper%20Intention/source_files/online_shoppers_intention.csv"

# Data read directly from raw CSV file
osi <- read_csv(url)
```
