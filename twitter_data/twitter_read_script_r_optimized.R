setwd("C:/Users/sbrya/Documents/random_data/twitter_data (3)")


library(tidyverse)
library(lubridate)

# Function to read and standardize CSV data for each month
read_twitter_month <- function(month, year, user) {
  month_str <- sprintf("%02d", month)  # Ensure two-digit month
  start_date <- sprintf("%04d%02d01", year, month)
  end_date <- sprintf("%04d%02d01", year, month + 1)
  file_name <- sprintf("tweet_activity_metrics_%s_%s_%s_en.csv", user, start_date, end_date)
  
  read_csv(file_name, 
           col_select = c(1:14, 21:22),  # Select specific columns
           col_names = c("tweet_id", "url", "text", "datetime", 
                         # Naming columns explicitly for consistency
                         "impressions", "engagements", "engagement_rate",
                         "retweets", "replies", "likes", "user_profile_clicks",
                         "url_clicks", "hashtag_clicks", "details_expanded",
                         "media_views", "media_engagements", rep("", 6)),  # Empty strings for unnamed columns
           skip = 1)  # Skip the first row which often contains metadata or headers
}

# Initial Data Load
twitter_data <- read_csv("daily_twitter_data.csv")  # Historical aggregated data
tweet_data <- read_csv("tweet_data.csv", col_select = c(1:4, 7:18))  # Detailed tweet data

user <- "ScattrBrainJane"  # User's Twitter handle

# Data Collection: Loop through months to compile new data
months <- 1:8  # January to August
tweet_data_new <- map_df(months, ~read_twitter_month(.x, 2023, user)) %>%
  bind_rows(tweet_data) %>%  # Combine with existing tweet data
  arrange(datetime)  # Sort by date and time

# Data Processing: Clean and enrich the data
tweet_data_new <- tweet_data_new %>%
  mutate(id = sprintf("%05d", 1:n())) %>%  # Assign a unique 5-digit ID
  select(id, everything(), -tweet_id, -url) %>%  # Reorder columns, drop original ID and URL
  rename(detail_expands = details_expanded) %>%  # Correct column name
  mutate(other_engagements = engagements - (likes + retweets + replies + 
                                              user_profile_clicks + url_clicks + hashtag_clicks + detail_expands + media_engagements))  # Calculate unaccounted engagements

# Date Range Definition for Clarity
date_start <- as.Date("2022-11-04")

# Summarize Daily Data
daily_twitter_pre_nov2022 <- twitter_data %>% 
  mutate(date = mdy(date)) %>% 
  filter(date < date_start)  # Data before November 4, 2022

daily_twitter_post_nov2022 <- tweet_data_new %>%
  mutate(date = date(datetime)) %>%
  filter(date >= date_start) %>%
  group_by(date) %>%
  summarize(
    num_tweets = n(),  # Count of tweets per day
    across(c(impressions:media_engagements), sum),  # Summarize all numeric columns
    engagement_rate = mean(engagement_rate)  # Average engagement rate
  )

# Combine daily data from both periods
daily_twitter_new <- bind_rows(daily_twitter_pre_nov2022, daily_twitter_post_nov2022) %>%
  mutate(other_engagements = engagements - (likes + retweets + replies + 
                                              user_profile_clicks + url_clicks + hashtag_clicks + detail_expands + media_engagements))

# Transform data for analysis
daily_twitter_long <- daily_twitter_new %>%
  select(-engagements) %>%  # Drop total engagements as we're breaking it down
  pivot_longer(cols = c(retweets:other_engagements, -media_views), 
               names_to = "Type", values_to = "Engagements")

# Similar transformation for individual tweet data
tweet_data_long <- tweet_data_new %>%
  select(-engagements, -text) %>%  # Remove unnecessary columns for this view
  pivot_longer(cols = c(retweets:other_engagements, -media_views), 
               names_to = "Type", values_to = "Engagements")

# Contextual data for tweets
tweet_context <- tweet_data_new %>% select(id, text, datetime)

# Output CSV files for further analysis or visualization
write_csv(daily_twitter_long, "daily_twitter_long.csv")
write_csv(tweet_data_long, "tweet_data_long.csv")
write_csv(tweet_context, "tweet_context.csv")
