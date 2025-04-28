# Marketing Attribution with SQL

CoolTShirts sells shirts of all kinds, as long as they are T-shaped and cool. Recently, CTS started a few marketing campaigns to increase website visits and purchases. Using touch attribution, they’d like to map their customers’ journey: from initial visit to purchase. They can use that information to optimize their marketing campaigns. 

## Question 1

How many campaigns and sources does CoolTShirts use? Which source is used for each campaign?

Use three queries:
- one for the number of distinct campaigns,
- one for the number of distinct sources,
- one to find how they are related.


```SQL
SELECT COUNT(DISTINCT utm_campaign) AS num_campaigns
FROM page_visits;
```

| num_campaigns |
|:----------------------------:|
|              8              |


```SQL
SELECT COUNT(DISTINCT utm_source) AS num_sources
FROM page_visits;
```

| num_sources  |
|:---------------------------:|
|              6              |


```SQL
SELECT DISTINCT utm_campaign, utm_source
FROM page_visits;
```

|     utm_campaign                          |     utm_source     |
|:----------------------------------------:|:------------------:|
| getting-to-know-cool-tshirts             | nytimes            |
| weekly-newsletter                        | email              |
| ten-crazy-cool-tshirts-facts             | buzzfeed           |
| retargetting-campaign                    | email              |
| retargetting-ad                          | facebook           |
| interview-with-cool-tshirts-founder      | medium             |
| paid-search                              | google             |
| cool-tshirts-search                      | google             |

## Question 2

What pages are on the CoolTShirts website?

Find the distinct values of the `page_name` column.


```SQL
SELECT DISTINCT page_name
FROM page_visits;
```

|        page_name         |
|:------------------------:|
| 1 - landing_page         |
| 2 - shopping_cart        |
| 3 - checkout             |
| 4 - purchase             |

## Question 3

How many first touches is each campaign responsible for?

You’ll need to use a first-touch query. Group by campaign and count the number of first touches for each.


```SQL
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
  SELECT ft.user_id,
         ft.first_touch_at,
         pv.utm_source,
         pv.utm_campaign
  FROM first_touch ft
  JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source,
       ft_attr.utm_campaign,
       COUNT(*) AS num_first_touches
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;
```

| utm_source |           utm_campaign            | num_first_touches |
|:----------:|:---------------------------------:|:-----------------:|
|  medium    | interview-with-cool-tshirts-founder |        622        |
|  nytimes   |   getting-to-know-cool-tshirts    |        612        |
|  buzzfeed  | ten-crazy-cool-tshirts-facts      |        576        |
|  google    |     cool-tshirts-search           |        169        |

## Question 4

How many last touches is each campaign responsible for?

Starting with the last-touch query from the lesson, group by campaign and count the number of last touches for each.


```SQL
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source,
       lt_attr.utm_campaign,
       COUNT(*) AS num_last_touches
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;
```

| utm_source |           utm_campaign            | num_last_touches |
|:----------:|:---------------------------------:|:----------------:|
|   email    |        weekly-newsletter          |        447       |
|  facebook  |          retargetting-ad          |        443       |
|   email    |       retargetting-campaign       |        245       |
|  nytimes   |   getting-to-know-cool-tshirts    |        232       |
|  buzzfeed  | ten-crazy-cool-tshirts-facts      |        190       |
|  medium    | interview-with-cool-tshirts-founder |        184       |
|  google    |            paid-search            |        178       |
|  google    |     cool-tshirts-search           |        60        |

## Question 5

How many visitors make a purchase?

Count the distinct users who visited the page named `4 - purchase`.


```SQL
SELECT COUNT(*) AS num_last_touch_purchases
FROM page_visits
WHERE page_name == '4 - purchase';
```

|    num_last_touch_purchases    |
|:------------------------------:|
|               361              |

## Question 6

How many last touches on the *purchase page* is each campaign responsible for?

This query will look similar to your last-touch query, but with an additional `WHERE` clause.


```SQL
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.page_name,
         pv.utm_source,
         pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
  WHERE pv.page_name == '4 - purchase'
)
SELECT lt_attr.utm_campaign,
       lt_attr.utm_source,
       COUNT(*) AS num_last_touch_purchases
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;
```

|            utm_campaign            | utm_source | num_last_touch_purchases |
|:---------------------------------:|:----------:|:------------------------:|
|     weekly-newsletter             |   email    |            114           |
|     retargetting-ad               |  facebook  |            112           |
|     retargetting-campaign         |   email    |             53           |
|     paid-search                   |   google   |             52           |
|     getting-to-know-cool-tshirts  |  nytimes   |              9           |
|     ten-crazy-cool-tshirts-facts  |  buzzfeed  |              9           |
|     interview-with-cool-tshirts-founder | medium |              7           |
|     cool-tshirts-search           |   google   |              2           |

## Final Question

**"*CoolTShirts can re-invest in 5 campaigns. Given your findings in the project, which should they pick and why?*"**

If we are only focusing on the results of last-touch attribution, the simple answer is to invest in the following campaigns:

- Weekly newsletter email
- Facebook retartgetting ad
- Email retargetting campaign
- Google paid search results
- **EITHER** the New York Times article ***OR*** the Buzzfeed article

However, I would also argue there is some nuance in establishing a market presence through many of the first-touch campaigns, namely the NYT, Buzzfeed, and Medium articles. You'll notice that many last-touch heavy hitters fail to initially grab the attention of new users, as people are typically less inclined to click on paid ads for new products they've not heard of. I think entirely focusing on last-touch attributon in this way could hinder sales instead of boosting them. Perhaps a good balance would be to focus on the three media campaigns in partnership with large publications (Medium, Buzzfeed, NYT), and delegate the remaining two campaign slots on the weekly newsletter email and the Facebook retargetting ad (which are large contributers to last-touch purchases)
