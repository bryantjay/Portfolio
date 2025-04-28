# Calculating Churn Using SQL

### Intro to the Data

Four months into launching Codeflix, management asks you to look into subscription churn rates. It’s early on in the business and people are excited to know how the company is doing. The marketing department is particularly interested in how the churn compares between two segments of users. They provide you with a dataset containing subscription data for users who were acquired through two distinct channels. The dataset provided to you contains one SQL table, `subscriptions`. Within the table, there are 4 columns:

- `id` - the subscription id
- `subscription_start` - the start date of the subscription
- `subscription_end` - the end date of the subscription
- `segment` - this identifies which segment the subscription owner belongs to

Codeflix requires a minimum subscription length of 31 days, so a user can never start and end their subscription in the same month. Take a look at the first 25 rows of data in the `subscriptions` table. How many different segments do you see?


```python
SELECT *
FROM subscriptions
LIMIT 25;
```

| id  | subscription_start | subscription_end | segment |
|:---:|:------------------:|:----------------:|:-------:|
|  1  |    2016-12-01     |   2017-02-01     |    87   |
|  2  |    2016-12-01     |   2017-01-24     |    87   |
|  3  |    2016-12-01     |   2017-03-07     |    87   |
|  4  |    2016-12-01     |   2017-02-12     |    87   |
|  5  |    2016-12-01     |   2017-03-09     |    87   |
|  6  |    2016-12-01     |   2017-01-19     |    87   |
|  7  |    2016-12-01     |   2017-02-03     |    87   |
|  8  |    2016-12-01     |   2017-03-02     |    87   |
|  9  |    2016-12-01     |   2017-02-17     |    87   |
| 10  |    2016-12-01     |   2017-01-01     |    87   |
| 11  |    2016-12-01     |   2017-01-17     |    87   |
| 12  |    2016-12-01     |   2017-02-07     |    87   |
| 13  |    2016-12-01     |       NULL       |    30   |
| 14  |    2016-12-01     |   2017-03-07     |    30   |
| 15  |    2016-12-01     |   2017-02-22     |    30   |
| 16  |    2016-12-01     |       NULL       |    30   |
| 17  |    2016-12-01     |       NULL       |    30   |
| 18  |    2016-12-02     |   2017-01-29     |    87   |
| 19  |    2016-12-02     |   2017-01-13     |    87   |
| 20  |    2016-12-02     |   2017-01-15     |    87   |
| 21  |    2016-12-02     |   2017-01-15     |    87   |
| 22  |    2016-12-02     |   2017-01-24     |    87   |
| 23  |    2016-12-02     |   2017-01-14     |    87   |
| 24  |    2016-12-02     |   2017-01-18     |    87   |
| 25  |    2016-12-02     |   2017-02-24     |    87   |

There seem to only be two distinct categorical values for `segment`, 87 and 30. We can verify this using an aggregation query:


```python
SELECT COUNT(DISTINCT segment) AS 'Number of Segments'
FROM subscriptions;
```

| Number of Segments |
|:------------------------:|
|            2             |

Determine the range of months of data provided. Which months will you be able to calculate churn for?


```python
SELECT
  MIN(subscription_start),
  MAX(subscription_start),
  MIN(subscription_end),
  MAX(subscription_end)
FROM subscriptions;
```

| MIN(subscription_start) | MAX(subscription_start) | MIN(subscription_end) | MAX(subscription_end) |
|:------------------------:|:------------------------:|:----------------------:|:----------------------:|
|       2016-12-01        |       2017-03-30        |        2017-01-01      |        2017-03-31      |

The data stretches December 2016 to March 2017, but we can only calculate churn rates for January, February and March. There is no need to calcualte churn for the month of December, since there is little preceding data, and no cancellations yet (`MIN(subscription_end)` is in Janurary); it would technically be zero.

### Form a Table of Month Bookmarks
You’ll be calculating the churn rate for both segments (87 and 30) over the first 3 months of 2017. To get started, create a temporary table of months.


```python
WITH months AS (
  SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
  UNION
  SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
  UNION
  SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day
)
SELECT *
FROM months;
```

| first_day   | last_day    |
|:-----------:|:-----------:|
| 2017-01-01  | 2017-01-31  |
| 2017-02-01  | 2017-02-28  |
| 2017-03-01  | 2017-03-31  |

### Combine the Tables

Create a temporary table, cross_join, from the `CROSS JOIN` subscriptions and your months.


```python
WITH months AS (
  SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
  UNION
  SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
  UNION
  SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
)
SELECT *
FROM cross_join
LIMIT 30;
```

|  id  | subscription_start | subscription_end | segment |  first_day  |  last_day   |
|:----:|:------------------:|:----------------:|:-------:|:-----------:|:-----------:|
|  1   |    2016-12-01      |    2017-02-01    |   87    | 2017-01-01  | 2017-01-31  |
|  1   |    2016-12-01      |    2017-02-01    |   87    | 2017-02-01  | 2017-02-28  |
|  1   |    2016-12-01      |    2017-02-01    |   87    | 2017-03-01  | 2017-03-31  |
|  2   |    2016-12-01      |    2017-01-24    |   87    | 2017-01-01  | 2017-01-31  |
|  2   |    2016-12-01      |    2017-01-24    |   87    | 2017-02-01  | 2017-02-28  |
|  2   |    2016-12-01      |    2017-01-24    |   87    | 2017-03-01  | 2017-03-31  |
|  3   |    2016-12-01      |    2017-03-07    |   87    | 2017-01-01  | 2017-01-31  |
|  3   |    2016-12-01      |    2017-03-07    |   87    | 2017-02-01  | 2017-02-28  |
|  3   |    2016-12-01      |    2017-03-07    |   87    | 2017-03-01  | 2017-03-31  |
|  4   |    2016-12-01      |    2017-02-12    |   87    | 2017-01-01  | 2017-01-31  |
|  4   |    2016-12-01      |    2017-02-12    |   87    | 2017-02-01  | 2017-02-28  |
|  4   |    2016-12-01      |    2017-02-12    |   87    | 2017-03-01  | 2017-03-31  |
|  5   |    2016-12-01      |    2017-03-09    |   87    | 2017-01-01  | 2017-01-31  |
|  5   |    2016-12-01      |    2017-03-09    |   87    | 2017-02-01  | 2017-02-28  |
|  5   |    2016-12-01      |    2017-03-09    |   87    | 2017-03-01  | 2017-03-31  |
|  6   |    2016-12-01      |    2017-01-19    |   87    | 2017-01-01  | 2017-01-31  |
|  6   |    2016-12-01      |    2017-01-19    |   87    | 2017-02-01  | 2017-02-28  |
|  6   |    2016-12-01      |    2017-01-19    |   87    | 2017-03-01  | 2017-03-31  |
|  7   |    2016-12-01      |    2017-02-03    |   87    | 2017-01-01  | 2017-01-31  |
|  7   |    2016-12-01      |    2017-02-03    |   87    | 2017-02-01  | 2017-02-28  |
|  7   |    2016-12-01      |    2017-02-03    |   87    | 2017-03-01  | 2017-03-31  |
|  8   |    2016-12-01      |    2017-03-02    |   87    | 2017-01-01  | 2017-01-31  |
|  8   |    2016-12-01      |    2017-03-02    |   87    | 2017-02-01  | 2017-02-28  |
|  8   |    2016-12-01      |    2017-03-02    |   87    | 2017-03-01  | 2017-03-31  |
|  9   |    2016-12-01      |    2017-02-17    |   87    | 2017-01-01  | 2017-01-31  |
|  9   |    2016-12-01      |    2017-02-17    |   87    | 2017-02-01  | 2017-02-28  |
|  9   |    2016-12-01      |    2017-02-17    |   87    | 2017-03-01  | 2017-03-31  |
| 10   |    2016-12-01      |    2017-01-01    |   87    | 2017-01-01  | 2017-01-31  |
| 10   |    2016-12-01      |    2017-01-01    |   87    | 2017-02-01  | 2017-02-28  |
| 10   |    2016-12-01      |    2017-01-01    |   87    | 2017-03-01  | 2017-03-31  |
| 11   |    2016-12-01      |    2017-01-17    |   87    | 2017-01-01  | 2017-01-31  |
| 11   |    2016-12-01      |    2017-01-17    |   87    | 2017-02-01  | 2017-02-28  |
| 11   |    2016-12-01      |    2017-01-17    |   87    | 2017-03-01  | 2017-03-31  |
| 12   |    2016-12-01      |    2017-02-07    |   87    | 2017-01-01  | 2017-01-31  |
| 12   |    2016-12-01      |    2017-02-07    |   87    | 2017-02-01  | 2017-02-28  |
| 12   |    2016-12-01      |    2017-02-07    |   87    | 2017-03-01  | 2017-03-31  |
| 13   |    2016-12-01      |      NULL        |   30    | 2017-01-01  | 2017-01-31  |
| 13   |    2016-12-01      |      NULL        |   30    | 2017-02-01  | 2017-02-28  |
| 13   |    2016-12-01      |      NULL        |   30    | 2017-03-01  | 2017-03-31  |
| 14   |    2016-12-01      |    2017-03-07    |   30    | 2017-01-01  | 2017-01-31  |
| 14   |    2016-12-01      |    2017-03-07    |   30    | 2017-02-01  | 2017-02-28  |
| 14   |    2016-12-01      |    2017-03-07    |   30    | 2017-03-01  | 2017-03-31  |
| 15   |    2016-12-01      |    2017-02-22    |   30    | 2017-01-01  | 2017-01-31  |
| 15   |    2016-12-01      |    2017-02-22    |   30    | 2017-02-01  | 2017-02-28  |
| 15   |    2016-12-01      |    2017-02-22    |   30    | 2017-03-01  | 2017-03-31  |
| 16   |    2016-12-01      |      NULL        |   30    | 2017-01-01  | 2017-01-31  |
| 16   |    2016-12-01      |      NULL        |   30    | 2017-02-01  | 2017-02-28  |
| 16   |    2016-12-01      |      NULL        |   30    | 2017-03-01  | 2017-03-31  |
| 17   |    2016-12-01      |      NULL        |   30    | 2017-01-01  | 2017-01-31  |
| 17   |    2016-12-01      |      NULL        |   30    | 2017-02-01  | 2017-02-28  |


### Mark Active/Cancelled Statuses

Create a temporary table, `status`, from the `cross_join` table you created. This table should contain:

- `id` selected from `cross_join`
- `month` as an alias of `first_day`
- `is_active_87` and `is_active_30` columns to mark users from segment 87/30 who existed prior to the beginning of the month. This is `1` if true and `0` otherwise.
- `is_canceled_87` and `is_canceled_30` columns to mark users from segment 87/30 who canceled their subscription during the month. This is `1` if true and `0` otherwise.


```python
WITH months AS (
  SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
  UNION
  SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
  UNION
  SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day
), cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
), status AS (
  SELECT
    id,
    first_day AS month,
    CASE
      WHEN (subscription_start < first_day)
        AND (
          (subscription_end >= first_day)
          OR (subscription_end IS NULL)
        ) AND (
          segment == 87
        ) THEN 1
        ELSE 0
      END AS is_active_87,
    CASE
      WHEN (subscription_start < first_day)
        AND (
          (subscription_end >= first_day)
          OR (subscription_end IS NULL)
        ) AND (
          segment == 30
        ) THEN 1
        ELSE 0
      END AS is_active_30,
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
        AND segment == 87
        THEN 1
      ELSE 0
      END as is_canceled_87,
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
        AND segment == 30
        THEN 1
      ELSE 0
      END as is_canceled_30
  FROM cross_join
)
SELECT *
FROM status
LIMIT 50;
```

| id  |    month    | is_active_87 | is_active_30 | is_canceled_87 | is_canceled_30 |
|:---:|:-----------:|:------------:|:------------:|:--------------:|:--------------:|
|  1  | 2017-01-01  |      1       |      0       |       0        |       0        |
|  1  | 2017-02-01  |      1       |      0       |       1        |       0        |
|  1  | 2017-03-01  |      0       |      0       |       0        |       0        |
|  2  | 2017-01-01  |      1       |      0       |       1        |       0        |
|  2  | 2017-02-01  |      0       |      0       |       0        |       0        |
|  2  | 2017-03-01  |      0       |      0       |       0        |       0        |
|  3  | 2017-01-01  |      1       |      0       |       0        |       0        |
|  3  | 2017-02-01  |      1       |      0       |       0        |       0        |
|  3  | 2017-03-01  |      1       |      0       |       1        |       0        |
|  4  | 2017-01-01  |      1       |      0       |       0        |       0        |
|  4  | 2017-02-01  |      1       |      0       |       1        |       0        |
|  4  | 2017-03-01  |      0       |      0       |       0        |       0        |
|  5  | 2017-01-01  |      1       |      0       |       0        |       0        |
|  5  | 2017-02-01  |      1       |      0       |       0        |       0        |
|  5  | 2017-03-01  |      1       |      0       |       1        |       0        |
|  6  | 2017-01-01  |      1       |      0       |       1        |       0        |
|  6  | 2017-02-01  |      0       |      0       |       0        |       0        |
|  6  | 2017-03-01  |      0       |      0       |       0        |       0        |
|  7  | 2017-01-01  |      1       |      0       |       0        |       0        |
|  7  | 2017-02-01  |      1       |      0       |       1        |       0        |
|  7  | 2017-03-01  |      0       |      0       |       0        |       0        |
|  8  | 2017-01-01  |      1       |      0       |       0        |       0        |
|  8  | 2017-02-01  |      1       |      0       |       0        |       0        |
|  8  | 2017-03-01  |      1       |      0       |       1        |       0        |
|  9  | 2017-01-01  |      1       |      0       |       0        |       0        |
|  9  | 2017-02-01  |      1       |      0       |       1        |       0        |
|  9  | 2017-03-01  |      0       |      0       |       0        |       0        |
| 10  | 2017-01-01  |      1       |      0       |       1        |       0        |
| 10  | 2017-02-01  |      0       |      0       |       0        |       0        |
| 10  | 2017-03-01  |      0       |      0       |       0        |       0        |
| 11  | 2017-01-01  |      1       |      0       |       1        |       0        |
| 11  | 2017-02-01  |      0       |      0       |       0        |       0        |
| 11  | 2017-03-01  |      0       |      0       |       0        |       0        |
| 12  | 2017-01-01  |      1       |      0       |       0        |       0        |
| 12  | 2017-02-01  |      1       |      0       |       1        |       0        |
| 12  | 2017-03-01  |      0       |      0       |       0        |       0        |
| 13  | 2017-01-01  |      0       |      1       |       0        |       0        |
| 13  | 2017-02-01  |      0       |      1       |       0        |       0        |
| 13  | 2017-03-01  |      0       |      1       |       0        |       0        |
| 14  | 2017-01-01  |      0       |      1       |       0        |       0        |
| 14  | 2017-02-01  |      0       |      1       |       0        |       0        |
| 14  | 2017-03-01  |      0       |      1       |       0        |       1        |
| 15  | 2017-01-01  |      0       |      1       |       0        |       0        |
| 15  | 2017-02-01  |      0       |      1       |       0        |       1        |
| 15  | 2017-03-01  |      0       |      0       |       0        |       0        |
| 16  | 2017-01-01  |      0       |      1       |       0        |       0        |
| 16  | 2017-02-01  |      0       |      1       |       0        |       0        |
| 16  | 2017-03-01  |      0       |      1       |       0        |       0        |
| 17  | 2017-01-01  |      0       |      1       |       0        |       0        |
| 17  | 2017-02-01  |      0       |      1       |       0        |       0        |

### Aggregate

Create a `status_aggregate` temporary table that is a `SUM` of the active and canceled subscriptions for each segment, for each month.

The resulting columns should be:

- `sum_active_87`
- `sum_active_30`
- `sum_canceled_87`
- `sum_canceled_30`


```python
WITH months AS (
  SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
  UNION
  SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
  UNION
  SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day
), cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
), status AS (
  SELECT
    id,
    first_day AS month,
    CASE
      WHEN (subscription_start < first_day)
        AND (
          (subscription_end >= first_day)
          OR (subscription_end IS NULL)
        ) AND (
          segment == 87
        ) THEN 1
        ELSE 0
      END AS is_active_87,
    CASE
      WHEN (subscription_start < first_day)
        AND (
          (subscription_end >= first_day)
          OR (subscription_end IS NULL)
        ) AND (
          segment == 30
        ) THEN 1
        ELSE 0
      END AS is_active_30,
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
        AND segment == 87
        THEN 1
      ELSE 0
      END as is_canceled_87,
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
        AND segment == 30
        THEN 1
      ELSE 0
      END as is_canceled_30
  FROM cross_join
), status_aggregate AS (
  SELECT
    month,
    SUM(is_active_87) AS sum_active_87,
    SUM(is_active_30) AS sum_active_30,
    SUM(is_canceled_87) AS sum_canceled_87,
    SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month
)

SELECT *
FROM status_aggregate;
```

|    month    | sum_active_87 | sum_active_30 | sum_canceled_87 | sum_canceled_30 |
|:-----------:|:-------------:|:-------------:|:----------------:|:----------------:|
| 2017-01-01  |      279      |      291      |        70        |        22        |
| 2017-02-01  |      467      |      518      |       148        |        38        |
| 2017-03-01  |      541      |      718      |       258        |        84        |

### Calculate Churn

Now we can officially calculate the churn rates for the two segments over the three month period. We'll convert the rates to percentage format, rounded to the first decimal place. Which segment has a lower churn rate?


```python
WITH months AS (
  SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
  UNION
  SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
  UNION
  SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day
), cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
), status AS (
  SELECT
    id,
    first_day AS month,
    CASE
      WHEN (subscription_start < first_day)
        AND (
          (subscription_end >= first_day)
          OR (subscription_end IS NULL)
        ) AND (
          segment == 87
        ) THEN 1
        ELSE 0
      END AS is_active_87,
    CASE
      WHEN (subscription_start < first_day)
        AND (
          (subscription_end >= first_day)
          OR (subscription_end IS NULL)
        ) AND (
          segment == 30
        ) THEN 1
        ELSE 0
      END AS is_active_30,
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
        AND segment == 87
        THEN 1
      ELSE 0
      END as is_canceled_87,
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
        AND segment == 30
        THEN 1
      ELSE 0
      END as is_canceled_30
  FROM cross_join
), status_aggregate AS (
  SELECT
    month,
    SUM(is_active_87) AS sum_active_87,
    SUM(is_active_30) AS sum_active_30,
    SUM(is_canceled_87) AS sum_canceled_87,
    SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month
)

SELECT
  month,
  ROUND((sum_canceled_87 * 100.0 / sum_active_87), 1) || "%" AS churn_rate_87,
  ROUND((sum_canceled_30 * 100.0 / sum_active_30), 1) || "%" AS churn_rate_30
FROM status_aggregate;
```

|    month    | churn_rate_87 | churn_rate_30 |
|:-----------:|:-------------:|:-------------:|
| 2017-01-01  |     25.1%     |     7.6%      |
| 2017-02-01  |     31.7%     |     7.3%      |
| 2017-03-01  |     47.7%     |    11.7%      |

We can see that the churn rate for Segment 30 was consistently *far* lower than that of Segment 87. Additionally, the churn rate for Segment 87 rose at an alarmingly rate between January and March 2017. The marketing team should follow up with users in Segment 87, and investigate what caused so many subscribers to cancel!

### DRY Version

**"*How would you modify this code to support a large number of segments?*"**

So, the initial version of this project demands that the churn rates for separate segments are calculated using separate `CASE` statements.

This is fine if the data needs to be directly exported in this wide format, but is not really feasible if there are many potential distinct values for `segment`. If so, each `CASE` statement and the subsequent `87`/`30`-suffixed variables will need to be copy and pasted many, many times. As this isn't really a scalable process in most cases, it would just be better to use a `GROUP BY` statement, and then export the resulting data in long-format if a `PIVOT` function is not available in the given SQL dialect. Here's an example of what this would look like:


```python
WITH months AS (
  SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
  UNION
  SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
  UNION
  SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day
), cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
), status AS (
  SELECT
    id,
    first_day AS month,
    segment,
    CASE
      WHEN (subscription_start < first_day)
        AND (
          (subscription_end >= first_day)
          OR (subscription_end IS NULL)
        ) THEN 1
        ELSE 0
      END AS is_active,
    CASE
      WHEN (subscription_end BETWEEN first_day AND last_day) 
        THEN 1
      ELSE 0
      END as is_canceled
  FROM cross_join
), status_aggregate AS (
  SELECT
    month,
    segment,
    SUM(is_active) AS sum_active,
    SUM(is_canceled) AS sum_canceled
  FROM status
  GROUP BY month, segment
)
SELECT
  month,
  segment,
  ROUND((sum_canceled * 100.0 / sum_active), 1) || "%" AS churn_rate
FROM status_aggregate;
```

|    month    | segment | churn_rate |
|:-----------:|:-------:|:----------:|
| 2017-01-01  |    30   |    7.6%    |
| 2017-01-01  |    87   |   25.1%    |
| 2017-02-01  |    30   |    7.3%    |
| 2017-02-01  |    87   |   31.7%    |
| 2017-03-01  |    30   |   11.7%    |
| 2017-03-01  |    87   |   47.7%    |

You may notice that this isn't as easily comparable in its current format. The earlier table of churn rates looks "nicer". However, since these churn calculations often consist of condensed aggregations of data, in most instances the data is small enough to be quickly imported and manipulated in Python, R, Excel, or another pivot-capable tool of your choice.
