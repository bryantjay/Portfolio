# Usage Funnels with Warby Parker
Warby Parker is a transformative lifestyle brand with a lofty objective: to offer designer eyewear at a revolutionary price while leading the way for socially conscious businesses. Founded in 2010 and named after two characters in an early Jack Kerouac journal, Warby Parker believes in creative thinking, smart design, and doing good in the world. For every pair of eyeglasses and sunglasses sold, a pair is distributed to someone in need.

In this project, you will analyze different Warby Parker marketing funnels in order to calculate conversion rates.

Let’s get started!

## Survey Quiz Funnel

### Stage 1

To help users find their perfect frame, Warby Parker has a "Style Quiz" that has the following questions:

1. “What are you looking for?”
2. “What’s your fit?”
3. “Which shapes do you like?”
4. “Which colors do you like?”
5. “When was your last eye exam?”


The users’ responses are stored in a table called `survey`.

Select all columns from the first 10 rows. What columns does the table have?


```SQL
SELECT *
FROM survey
LIMIT 10;
```

|        question        |              user_id              |        response        |
|:---------------------:|:---------------------------------:|:----------------------:|
| 1. What are you looking for? | 005e7f99-d48c-4fce-b605-10506c85aaf7 | Women's Styles |
| 2. What's your fit? | 005e7f99-d48c-4fce-b605-10506c85aaf7 | Medium |
| 3. Which shapes do you like? | 00a556ed-f13e-4c67-8704-27e3573684cd | Round |
| 4. Which colors do you like? | 00a556ed-f13e-4c67-8704-27e3573684cd | Two-Tone |
| 1. What are you looking for? | 00a556ed-f13e-4c67-8704-27e3573684cd | I'm not sure. Let's skip it. |
| 2. What's your fit? | 00a556ed-f13e-4c67-8704-27e3573684cd | Narrow |
| 5. When was your last eye exam? | 00a556ed-f13e-4c67-8704-27e3573684cd | <1 Year |
| 3. Which shapes do you like? | 00bf9d63-0999-43a3-9e5b-9c372e6890d2 | Square |
| 5. When was your last eye exam? | 00bf9d63-0999-43a3-9e5b-9c372e6890d2 | <1 Year |
| 2. What's your fit? | 00bf9d63-0999-43a3-9e5b-9c372e6890d2 | Medium |


The `survey` table has the following columns:

- `question`
- `user_id`
- `response`

### Stage 2

Users will “give up” at different points in the survey. Let’s analyze how many users move from Question 1 to Question 2, etc. Create a quiz funnel using the `GROUP BY` command. *What is the number of responses for each question?*


```SQL
SELECT
  question,
  COUNT(DISTINCT user_id) AS 'num_answered'
FROM survey
GROUP BY 1;
```

|        question        | num_answered |
|:---------------------:|:------------:|
| 1. What are you looking for? |     500      |
| 2. What's your fit? |     475      |
| 3. Which shapes do you like? |     380      |
| 4. Which colors do you like? |     361      |
| 5. When was your last eye exam? |     270      |

### Stage 3

Calculate the percentage of users who answer each question. Which question(s) of the quiz have a lower completion rates? What do you think is the reason?


```SQL
SELECT
  question,
  num_answered,
  prev_num_answered,
  ROUND(num_answered * 100.0 / prev_num_answered, 2) AS 'pct_answered'
FROM (
  SELECT
    question,
    COUNT(DISTINCT user_id) AS num_answered,
    COALESCE(
      LAG(COUNT(DISTINCT user_id)) OVER (ORDER BY question),
      500
    ) AS prev_num_answered
  FROM survey
  GROUP BY question
);
```

|        question        | num_answered | prev_num_answered | pct_answered |
|:---------------------:|:------------:|:-----------------:|:------------:|
| 1. What are you looking for? |     500      |        500         |    100.0     |
| 2. What's your fit? |     475      |        500         |     95.0     |
| 3. Which shapes do you like? |     380      |        475         |     80.0     |
| 4. Which colors do you like? |     361      |        380         |     95.0     |
| 5. When was your last eye exam? |     270      |        361         |    74.79     |

We see somewhat lower answer rates for questions 3 and 5. Survey respondents may have dropped off from either question to uncertainty or lack of interest. It's also possible that some folks declined to answer question 5 specifically due to the question's somewhat intrusive nature.

## Home Try-On Funnel

### Stage 4

Warby Parker’s purchase funnel is:

**Take the Style Quiz → Home Try-On → Purchase the Perfect Pair of Glasses**

During the "Home Try-On" stage, we will be conducting an A/B Test:

- 50% of the users will get **3** pairs to try on
- 50% of the users will get **5** pairs to try on

*Let’s find out whether or not users who get more pairs to try on at home will be more likely to make a purchase.* The data will be distributed across three tables:

- `quiz`
- `home_try_on`
- `purchase`

Examine the first five rows of each table. What are the column names?


```SQL
SELECT *
FROM quiz
LIMIT 5;
```

|            user_id            |     style      |   fit   |    shape    |   color   |
|:----------------------------:|:--------------:|:-------:|:-----------:|:---------:|
| 4e8118dc-bb3d-49bf-85fc-cca8d83232ac | Women's Styles | Medium | Rectangular | Tortoise |
| 291f1cca-e507-48be-b063-002b14906468 | Women's Styles | Narrow |    Round    |   Black  |
| 75122300-0736-4087-b6d8-c0c5373a1a04 | Women's Styles |  Wide  | Rectangular | Two-Tone |
| 75bc6ebd-40cd-4e1d-a301-27ddd93b12e2 | Women's Styles | Narrow |   Square    | Two-Tone |
| ce965c4d-7a2b-4db6-9847-601747fa7812 | Women's Styles |  Wide  | Rectangular |   Black  |

`quiz` table has the following columns:

- `user_id`
- `style`
- `fit`
- `shape`
- `color`


```SQL
SELECT *
FROM home_try_on
LIMIT 5;
```

|            user_id            | number_of_pairs |        address         |
|:----------------------------:|:----------------:|:----------------------:|
| d8addd87-3217-4429-9a01-d56d68111da7 |     5 pairs     |    145 New York 9a    |
| f52b07c8-abe4-4f4a-9d39-ba9fc9a184cc |     5 pairs     |   383 Madison Ave     |
| 8ba0d2d5-1a31-403e-9fa5-79540f8477f9 |     5 pairs     |     287 Pell St       |
| 4e71850e-8bbf-4e6b-accc-49a7bb46c586 |     3 pairs     | 347 Madison Square N  |
| 3bc8f97f-2336-4dab-bd86-e391609dab97 |     5 pairs     |   182 Cornelia St     |

`home_try_on` table has the following columns:

- `user_id`
- `number_of_pairs`
- `address`


```SQL
SELECT *
FROM purchase
LIMIT 5;
```

|            user_id            | product_id |     style      |   model_name   |       color        | price |
|:----------------------------:|:----------:|:--------------:|:--------------:|:------------------:|:-----:|
| 00a9dd17-36c8-430c-9d76-df49d4197dcf |     8      | Women's Styles |     Lucy      |     Jet Black      |  150  |
| 00e15fe0-c86f-4818-9c63-3422211baa97 |     7      | Women's Styles |     Lucy      | Elderflower Crystal|  150  |
| 017506f7-aba1-4b9d-8b7b-f4426e71b8ca |     4      |  Men's Styles  |     Dawes     |     Jet Black      |  150  |
| 0176bfb3-9c51-4b1c-b593-87edab3c54cb |    10      | Women's Styles | Eugene Narrow | Rosewood Tortoise  |   95  |
| 01fdf106-f73c-4d3f-a036-2f3e2ab1ce06 |     8      | Women's Styles |     Lucy      |     Jet Black      |  150  |

`purchase` table has the following columns:

- `user_id`
- `product_id`
- `style`
- `model_name`
- `color`
- `price`

### Stage 5

We’d like to create a new table with the following layout:

|  user_id  | is_home_try_on | number_of_pairs | is_purchase |
|:---------:|:--------------:|:----------------:|:-----------:|
| 4e8118dc  |      1      |        3 pairs         |    0    |
| 291f1cca  |      1      |        5 pairs         |    0    |
| 75122300  |     0      |      NULL        |    0    |

Each row will represent a single user from the `browse` table:

- If the user has any entries in `home_try_on`, then `is_home_try_on` will be `True`.
- `number_of_pairs` comes from `home_try_on` table
- If the user has any entries in `purchase`, then `is_purchase` will be `True`.


```SQL
SELECT
   DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz AS q
LEFT JOIN home_try_on AS h
  USING(user_id)
LEFT JOIN purchase AS p
  USING(user_id)
LIMIT 10;
```

|            user_id            | is_home_try_on | number_of_pairs | is_purchase |
|:----------------------------:|:--------------:|:----------------:|:-----------:|
| 4e8118dc-bb3d-49bf-85fc-cca8d83232ac |       1        |     3 pairs      |      0      |
| 291f1cca-e507-48be-b063-002b14906468 |       1        |     3 pairs      |      1      |
| 75122300-0736-4087-b6d8-c0c5373a1a04 |       0        |       NULL       |      0      |
| 75bc6ebd-40cd-4e1d-a301-27ddd93b12e2 |       1        |     5 pairs      |      0      |
| ce965c4d-7a2b-4db6-9847-601747fa7812 |       1        |     3 pairs      |      1      |
| 28867d12-27a6-4e6a-a5fb-8bb5440117ae |       1        |     5 pairs      |      1      |
| 5a7a7e13-fbcf-46e4-9093-79799649d6c5 |       0        |       NULL       |      0      |
| 0143cb8b-bb81-4916-9750-ce956c9f9bd9 |       0        |       NULL       |      0      |
| a4ccc1b3-cbb6-449c-b7a5-03af42c97433 |       1        |     5 pairs      |      0      |
| b1dded76-cd60-4222-82cb-f6d464104298 |       1        |     3 pairs      |      0      |

### Stage 6

Once we have the data in this format, we can analyze it in several ways. What are some actionable insights for Warby Parker?

#### Number of Pairs (Tried On)


```SQL
WITH hto AS (
  SELECT
    DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    h.number_of_pairs,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS q
  LEFT JOIN home_try_on AS h
    USING(user_id)
  LEFT JOIN purchase AS p
    USING(user_id)
)
SELECT
  DISTINCT number_of_pairs,
  COUNT(user_id) AS 'total_users',
  SUM(is_home_try_on) AS 'total_tries',
  SUM(is_purchase) AS 'total_sales',
  ROUND(SUM(is_purchase) * 100.0 / SUM(is_home_try_on)) || '%' AS 'sales_conversion'
FROM hto
GROUP BY 1
ORDER BY 1;
```

| number_of_pairs | total_users | total_tries | total_sales | sales_conversion |
|:----------------:|:-----------:|:-----------:|:-----------:|:----------------:|
| NULL              |      250      |      0      |      0   |       NULL       |
| 3 pairs          |     379     |     379     |     201     |      53.0%       |
| 5 pairs          |     371     |     371     |     294     |      79.0%       |

All users who did not try on glasses are considered `NULL` for this category. We see that trying on the two additional pairs of glasses leads to an additional 26% likelihood of purchase.

#### Style


```SQL
WITH hto AS (
  SELECT
    DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    q.style,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS q
  LEFT JOIN home_try_on AS h
    USING(user_id)
  LEFT JOIN purchase AS p
    USING(user_id)
)
SELECT
  DISTINCT style,
  COUNT(user_id) AS 'total_users',
  SUM(is_home_try_on) AS 'total_tries',
  ROUND(SUM(is_home_try_on) * 100.0 / COUNT(user_id)) || '%' AS 'try_conversion',
  SUM(is_purchase) AS 'total_sales',
  ROUND(SUM(is_purchase) * 100.0 / SUM(is_home_try_on)) || '%' AS 'sales_conversion'
FROM hto
GROUP BY 1
ORDER BY 1;
```

|        style         | total_users | total_tries | try_conversion | total_sales | sales_conversion |
|:--------------------:|:-----------:|:-----------:|:--------------:|:-----------:|:----------------:|
| I'm not sure. Let's skip it. |     99      |      69     |     70.0%      |      0      |      0.0%        |
| Men's Styles         |     432     |     320     |     74.0%      |     243     |     76.0%        |
| Women's Styles       |     469     |     361     |     77.0%      |     252     |     70.0%        |

Shoppers of Men's Styles are slightly less likely to try on, but more likely to make a purchase upon trying than shoppers of Women's Styles. Users who do not select a gendered style are seemingly guaranteed to not make a purchase. This might indicate uncertain or uncommitted window shoppers (who do not have any intention to purchase), although it could potentially indicate an uncaptured market regarding more gender-neutral styles. The exact reason for this gap in sales conversion should certainly be investigated further.

#### Fit


```SQL
WITH hto AS (
  SELECT
    DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    q.fit,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS q
  LEFT JOIN home_try_on AS h
    USING(user_id)
  LEFT JOIN purchase AS p
    USING(user_id)
)
SELECT
  DISTINCT fit,
  COUNT(user_id) AS 'total_users',
  SUM(is_home_try_on) AS 'total_tries',
  ROUND(SUM(is_home_try_on) * 100.0 / COUNT(user_id)) || '%' AS 'try_conversion',
  SUM(is_purchase) AS 'total_sales',
  ROUND(SUM(is_purchase) * 100.0 / SUM(is_home_try_on)) || '%' AS 'sales_conversion'
FROM hto
GROUP BY 1
ORDER BY 1;
```

|          fit          | total_users | total_tries | try_conversion | total_sales | sales_conversion |
|:---------------------:|:-----------:|:-----------:|:--------------:|:-----------:|:----------------:|
| I'm not sure. Let's skip it. |     89      |      64     |     72.0%      |     45      |     70.0%        |
| Medium                |     305     |     234     |     77.0%      |    152      |     65.0%        |
| Narrow                |     408     |     302     |     74.0%      |    193      |     64.0%        |
| Wide                  |     198     |     150     |     76.0%      |    105      |     70.0%        |

Shoppers interested in Wide fits seem to be among the most likely subset to try on and purchase glasses. Shoppers of Medium and Narrow fits are more likely to try on pairs of glasses, but then less likely to make a purchase. Perhaps Wide fits are more comfortable for a niche group of shoppers.

#### Shape


```SQL
WITH hto AS (
  SELECT
    DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    q.shape,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS q
  LEFT JOIN home_try_on AS h
    USING(user_id)
  LEFT JOIN purchase AS p
    USING(user_id)
)
SELECT
  DISTINCT shape,
  COUNT(user_id) AS 'total_users',
  SUM(is_home_try_on) AS 'total_tries',
  ROUND(SUM(is_home_try_on) * 100.0 / COUNT(user_id)) || '%' AS 'try_conversion',
  SUM(is_purchase) AS 'total_sales',
  ROUND(SUM(is_purchase) * 100.0 / SUM(is_home_try_on)) || '%' AS 'sales_conversion'
FROM hto
GROUP BY 1
ORDER BY 1;
```

|       shape       | total_users | total_tries | try_conversion | total_sales | sales_conversion |
|:-----------------:|:-----------:|:-----------:|:--------------:|:-----------:|:----------------:|
| No Preference     |     97      |      71     |     73.0%      |     53      |     75.0%        |
| Rectangular       |    397      |     288     |     73.0%      |    189      |     66.0%        |
| Round             |    180      |     140     |     78.0%      |     95      |     68.0%        |
| Square            |    326      |     251     |     77.0%      |    158      |     63.0%        |

Most users demonstrate an interest in Rectangular and Square shapes, but these groups are also less likely to try on a pair of glasses and to make a final purchase. Like Wide-fit glasses, Round glasses capture a smaller market, but are more likely to lead to both a try-on and purchase. Although shoppers with no stated preference are relatively scarce and less likely to try on a pair, they are a bit more likely to make a final purchase after a try-on.

#### Color


```SQL
WITH hto AS (
  SELECT
    DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    q.color,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS q
  LEFT JOIN home_try_on AS h
    USING(user_id)
  LEFT JOIN purchase AS p
    USING(user_id)
)
SELECT
  DISTINCT color,
  COUNT(user_id) AS 'total_users',
  SUM(is_home_try_on) AS 'total_tries',
  ROUND(SUM(is_home_try_on) * 100.0 / COUNT(user_id)) || '%' AS 'try_conversion',
  SUM(is_purchase) AS 'total_sales',
  ROUND(SUM(is_purchase) * 100.0 / SUM(is_home_try_on)) || '%' AS 'sales_conversion'
FROM hto
GROUP BY 1
ORDER BY 1;
```

|      color      | total_users | total_tries | try_conversion | total_sales | sales_conversion |
|:---------------:|:-----------:|:-----------:|:--------------:|:-----------:|:----------------:|
| Black           |     280     |     220     |     79.0%      |     150     |     68.0%        |
| Crystal         |     210     |     165     |     79.0%      |     104     |     63.0%        |
| Neutral         |     114     |      79     |     69.0%      |      48     |     61.0%        |
| Tortoise        |     292     |     213     |     73.0%      |     144     |     68.0%        |
| Two-Tone        |     104     |      73     |     70.0%      |      49     |     67.0%        |

Black glasses represent a classic staple. People interested in this color represent a large chunk of all shoppers, and also have high conversion rates to the "try-on" and "sales" stages. Tortoise-style glasses also make up a substantial portion of shoppers; while these interested shoppers are less likely to try on, those who do try on are still somewhat more likely to go through with a purchase. Many shoppers decide to try on Crystal-colored glasses, but a relatively smaller share go on to make a purchase. Glasses of both Neutral and Two-Tone colors are comparatively weak sellers.
