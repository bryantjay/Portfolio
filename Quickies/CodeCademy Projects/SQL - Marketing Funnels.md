# Funnel Analysis Using SQL

## What is a Funnel?

In the world of marketing analysis, “funnel” is a word you will hear time and time again.

A funnel is a marketing model which illustrates the theoretical customer journey towards the purchase of a product or service. Oftentimes, we want to track how many users complete a series of steps and know which steps have the most number of users giving up.

Some examples include:
- Answering each part of a 5 question survey on customer satisfaction
- Clicking “Continue” on each step of a set of 5 onboarding modals
- Browsing a selection of products → Viewing a shopping cart → Making a purchase

Generally, we want to know the total number of users in each step of the funnel, as well as the percent of users who complete each step.

Throughout this lesson, we will be working with data from a fictional company called Mattresses and More. Using SQL, you can dive into complex funnels and event flow analysis to gain insights into their users’ behavior.

### Build a Funnel From a Single Table

Mattresses and More users were asked to answer a five-question survey:

1. “How likely are you to recommend Mattresses and More to a friend?”
2. “Which Mattresses and More location do you shop at?”
3. “How old are you?”
4. “What is your gender?”
5. “What is your annual household income?”

However, not every user finished the survey!

We want to build a funnel to analyze if certain questions prompted users to stop working on the survey.

We will be using a table called survey_responses with the following columns:

- `question_text` - the survey question
- `user_id` - the user identifier
- `response` - the user answer

Start by getting a feel for the survey_responses table. Select all columns for the first 10 records from `survey_responses`.


```SQL
SELECT *
FROM survey_responses
LIMIT 10;
```

| question_text                                                      | user_id                               | response           |
|:--------------------------------------------------------------------:|:----------------------------------------:|:--------------------:|
| 2. Which Mattresses and More location do you shop at?              | 013bd7a1-a2ba-43c1-b980-591d368175da   | Fruitville         |
| 3. How old are you?                                                | 013bd7a1-a2ba-43c1-b980-591d368175da   | 45-55              |
| 1. How likely are you to recommend Mattresses and More to a friend?| 013bd7a1-a2ba-43c1-b980-591d368175da   | 9.0                |
| 5. What is your annual household income?                           | 013bd7a1-a2ba-43c1-b980-591d368175da   | 80,000 - 100,000   |
| 4. What is your gender?                                            | 013bd7a1-a2ba-43c1-b980-591d368175da   | female             |
| 5. What is your annual household income?                           | 0314edb3-92cb-4951-b90a-0cbb1b6f7ca5   | 80,000 - 100,000   |
| 4. What is your gender?                                            | 0314edb3-92cb-4951-b90a-0cbb1b6f7ca5   | female             |
| 2. Which Mattresses and More location do you shop at?              | 0314edb3-92cb-4951-b90a-0cbb1b6f7ca5   | Fruitville         |
| 3. How old are you?                                                | 0314edb3-92cb-4951-b90a-0cbb1b6f7ca5   | 35-45              |
| 1. How likely are you to recommend Mattresses and More to a friend?| 0314edb3-92cb-4951-b90a-0cbb1b6f7ca5   | 8.0                |

Now, let’s build our first basic funnel!

Count the number of distinct `user_id` who answered each `question_text`. You can do this by using a simple `GROUP BY` command.

*What is the number of responses for each question?*


```SQL
SELECT question_text,
  COUNT(DISTINCT user_id) AS 'num_answered'
FROM survey_responses
GROUP BY question_text;
```

|              question_text                                               | num_answered |
|:------------------------------------------------------------------------:|:------------------------:|
| 1. How likely are you to recommend Mattresses and More to a friend?     |           500           |
| 2. Which Mattresses and More location do you shop at?                   |           475           |
| 3. How old are you?                                                     |           380           |
| 4. What is your gender?                                                 |           361           |
| 5. What is your annual household income?                                |           270           |

We could use SQL to calculate the percent change between each question, but it’s just as easy to analyze these manually with a calculator or in a spreadsheet program like Microsoft Excel or Google Sheets.

If we divide the number of people completing each step by the number of people completing the previous step:

| Question | Percent Completed this Question |
|:--------:|:-------------------------------:|
|    1     |              100%              |
|    2     |              95%               |
|    3     |              82%               |
|    4     |              95%               |
|    5     |              74%               |

We see that Questions 2 and 4 have high completion rates, but Questions 3 and 5 have lower rates.

This suggests that age and household income are more sensitive questions that people might be reluctant to answer!

### Compare Funnels For A/B Tests

Mattresses and More has an onboarding workflow for new users of their website. It uses modal pop-ups to welcome users and show them important features of the site like:

1. Welcome to Mattresses and More!
2. Browse our bedding selection
3. Select items to add to your cart
4. View your cart by clicking on the icon
5. Press ‘Buy Now!’ when you’re ready to checkout

The Product team at Mattresses and More has created a new design for the pop-ups that they believe will lead more users to complete the workflow.

They’ve set up an A/B test where:

- 50% of users view the original `control` version of the pop-ups
- 50% of users view the new `variant` version of the pop-ups

Eventually, we’ll want to answer the question: "*How is the funnel different between the two groups?*"

We will be using a table called `onboarding_modals` with the following columns:

- `user_id` - the user identifier
- `modal_text` - the modal step
- `user_action` - the user response (Close Modal or Continue)
- `ab_group` - the version (control or variant)

Start by getting a feel for the `onboarding_modals` table. Select all columns for the first 10 records from `onboarding_modals`.


```SQL
SELECT *
FROM onboarding_modals
LIMIT 10;
```

|            user_id            |                modal_text                                   |  user_action  | ab_group |
|:----------------------------:|:------------------------------------------------------------:|:-------------:|:--------:|
| 0015585f-51d0-4654-83fc-acce6544b0cf | 1 - Welcome to Mattresses and More!                       | Close Modal   | control  |
| 0028b8b4-abb3-4711-9ea2-0d1ecb975358 | 1 - Welcome to Mattresses and More!                       | Close Modal   | control  |
| 0029802c-22a1-4d22-9a59-244341551ec9 | 1 - Welcome to Mattresses and More!                       | Continue      | variant  |
| 0029802c-22a1-4d22-9a59-244341551ec9 | 2 - Browse our bedding selection                          | Continue      | variant  |
| 0029802c-22a1-4d22-9a59-244341551ec9 | 3 - Select items to add to your cart                      | Continue      | variant  |
| 0029802c-22a1-4d22-9a59-244341551ec9 | 4 - View your cart by clicking on the icon                | Continue      | variant  |
| 0029802c-22a1-4d22-9a59-244341551ec9 | 5 - Press 'Buy Now!' when you're ready to checkout        | Continue      | variant  |
| 0042ec6f-e343-4486-a009-ecaea4ff31b2 | 1 - Welcome to Mattresses and More!                       | Continue      | variant  |
| 0042ec6f-e343-4486-a009-ecaea4ff31b2 | 2 - Browse our bedding selection                          | Close Modal   | variant  |
| 0121762e-7d4e-46b0-94d8-7bc56a5cb88b | 1 - Welcome to Mattresses and More!                       | Close Modal   | control  |

Now, using `GROUP BY`, count the number of distinct `user_id`‘s for each value of `modal_text`. This will tell us the number of users completing each step of the funnel.

This time, sort `modal_text` so that your funnel is in order.


```SQL
SELECT modal_text,
  COUNT(DISTINCT user_id) AS 'counts'
FROM onboarding_modals
GROUP BY 1
ORDER BY 1;
```

|              modal_text                                       | counts |
|:-------------------------------------------------------------:|:------:|
| 1 - Welcome to Mattresses and More!                           | 1000   |
| 2 - Browse our bedding selection                              |  695   |
| 3 - Select items to add to your cart                          |  575   |
| 4 - View your cart by clicking on the icon                    |  447   |
| 5 - Press 'Buy Now!' when you're ready to checkout            |  379   |

The previous query combined both the control and variant groups.

We can use a `CASE` statement within our `COUNT()` aggregate so that we only count `user_id`s whose `ab_group` is equal to ‘control’. Alias this as 'control_clicks'. Repeat the `CASE` statement to add an additional column that counts the number of clicks from the variant group and alias it as ‘variant_clicks’.


```SQL
SELECT modal_text,
  COUNT(DISTINCT CASE
    WHEN ab_group = 'control' THEN user_id
    END) AS 'control_clicks',
  COUNT(DISTINCT CASE
    WHEN ab_group = 'variant' THEN user_id
    END) AS 'variant_clicks'
FROM onboarding_modals
GROUP BY 1
ORDER BY 1;
```

|              modal_text                                       | control_clicks | variant_clicks |
|:-------------------------------------------------------------:|:--------------:|:--------------:|
| 1 - Welcome to Mattresses and More!                           |      500       |      500       |
| 2 - Browse our bedding selection                              |      301       |      394       |
| 3 - Select items to add to your cart                          |      239       |      336       |
| 4 - View your cart by clicking on the icon                    |      183       |      264       |
| 5 - Press 'Buy Now!' when you're ready to checkout            |      152       |      227       |

Incredible! After some quick math:

| Modal | Control Percent | Variant Percent |
|:-----:|:---------------:|:---------------:|
|   1   |      100%       |      100%       |
|   2   |       60%       |       79%       |
|   3   |       80%       |       85%       |
|   4   |       80%       |       80%       |
|   5   |       85%       |       85%       |

During Modal 2, `variant` has a 79% completion rate compared to `control`‘s 60%. During Modal 3, `variant` has a 85% completion rate compared to `control`‘s 80%. All other steps have the same level of completion.

This result tells us that the `variant` has greater completion!

### Build a Funnel from Multiple Tables

*Scenario*: Mattresses and More sells bedding essentials from their e-commerce store. Their purchase funnel is:

1. The user browses products and adds them to their cart.
2. The user proceeds to the checkout page.
3. The user enters credit card information and makes a purchase.

Three steps! Simple and easy.

As a sales analyst, you want to examine data from the shopping days before Christmas. As Christmas approaches, you suspect that customers become more likely to purchase items in their cart (i.e., they move from window shopping to buying presents).

The data for Mattresses and More is spread across several tables:

- `browse` - each row in this table represents an item that a user has added to his shopping cart
- `checkout` - each row in this table represents an item in a cart that has been checked out
- `purchase` - each row in this table represents an item that has been purchased

Let’s examine each table. Note that each user has multiple rows representing the different items that she has placed in her cart.


```SQL
SELECT *
FROM browse
LIMIT 5;
```

|               user_id                |  browse_date  | item_id |
|:-----------------------------------:|:-------------:|:-------:|
| 336f9fdc-aaeb-48a1-a773-e3a935442d45 |  2017-12-20   |    3    |
| 336f9fdc-aaeb-48a1-a773-e3a935442d45 |  2017-12-20   |   22    |
| 336f9fdc-aaeb-48a1-a773-e3a935442d45 |  2017-12-20   |   25    |
| 336f9fdc-aaeb-48a1-a773-e3a935442d45 |  2017-12-20   |   24    |
| 4596bb1a-7aa9-4ac9-9896-022d871cdcde |  2017-12-20   |    0    |


```SQL
SELECT *
FROM checkout
LIMIT 5;
```

|               user_id                | checkout_date | item_id |
|:-----------------------------------:|:-------------:|:-------:|
| 2fdb3958-ffc9-4b84-a49d-5f9f40e9469e |  2017-12-20   |   26    |
| 2fdb3958-ffc9-4b84-a49d-5f9f40e9469e |  2017-12-20   |   24    |
| 3a3e5fe6-39a7-4068-8009-3b9f649cb1aa |  2017-12-20   |    7    |
| 3a3e5fe6-39a7-4068-8009-3b9f649cb1aa |  2017-12-20   |    6    |
| 3a3e5fe6-39a7-4068-8009-3b9f649cb1aa |  2017-12-20   |   12    |


```SQL
SELECT *
FROM purchase
LIMIT 5;
```

|               user_id                | purchase_date | item_id |
|:-----------------------------------:|:-------------:|:-------:|
| 2fdb3958-ffc9-4b84-a49d-5f9f40e9469e |  2017-12-20   |   26    |
| 2fdb3958-ffc9-4b84-a49d-5f9f40e9469e |  2017-12-20   |   24    |
| 3a3e5fe6-39a7-4068-8009-3b9f649cb1aa |  2017-12-20   |    7    |
| 3a3e5fe6-39a7-4068-8009-3b9f649cb1aa |  2017-12-20   |    6    |
| 3a3e5fe6-39a7-4068-8009-3b9f649cb1aa |  2017-12-20   |   12    |

We want to combine the information from the three tables (`browse`, `checkout`, `purchase`) into one table with the following structure:

| browser_date |     user_id     | is_checkout | is_purchase |
|:------------:|:---------------:|:-----------:|:-----------:|
| 2017-12-20   | 6a7617321513    |    1     |    0    |
| 2017-12-20   | 022d871cdcde    |    0    |    0    |
|     …        |       …         |      …      |      …      |

Each row will represent a single user:

- If the user has any entries in `checkout`, then `is_checkout` will be 1 (True).
- If the user has any entries in `purchase`, then `is_purchase` will be 1 (True).
- If we use an `INNER JOIN` to create this table, we’ll lose information from any customer who does not have a row in the `checkout` or `purchase` table.

Therefore, we’ll need to use a series of `LEFT JOIN` commands.

Select these fours columns:
- `DISTINCT b.browse_date`
- `b.user_id`
- `c.user_id IS NOT NULL AS 'is_checkout'`
- `p.user_id IS NOT NULL AS 'is_purchase'`

...from the `LEFT JOIN`s of:

- `browse` (aliased as `b`)
- `checkout` (aliased as `c`)
- `purchase` (aliased as `p`)

Be sure to use this order to make sure that we get all of the rows. `LIMIT` your results to the first 20 so that it loads quickly.


```SQL
SELECT
  DISTINCT b.browse_date,
  b.user_id,
  c.user_id IS NOT NULL AS 'is_checkout',
  p.user_id IS NOT NULL AS 'is_purchase'
FROM browse AS 'b'
LEFT JOIN checkout AS 'c'
  ON c.user_id = b.user_id
LEFT JOIN purchase AS 'p'
  ON p.user_id = c.user_id
LIMIT 20;
```

|  browse_date  |              user_id               | is_checkout | is_purchase |
|:-------------:|:----------------------------------:|:-----------:|:-----------:|
|  2017-12-20   | 336f9fdc-aaeb-48a1-a773-e3a935442d45 |      0      |      0      |
|  2017-12-20   | 4596bb1a-7aa9-4ac9-9896-022d871cdcde |      0      |      0      |
|  2017-12-20   | 2fdb3958-ffc9-4b84-a49d-5f9f40e9469e |      1      |      1      |
|  2017-12-20   | fc394c75-36f1-4df1-8665-23c32a43591b |      0      |      0      |
|  2017-12-20   | 263e59f2-479b-4736-872c-302ad082b20f |      0      |      0      |
|  2017-12-20   | 58ff3291-84bf-4fc7-96cc-0bc1477adea9 |      0      |      0      |
|  2017-12-20   | d582b899-cace-43dc-84f3-a1df0c30e90c |      0      |      0      |
|  2017-12-20   | 3215212f-7a6f-4d95-937a-ee0ce911db04 |      0      |      0      |
|  2017-12-20   | d0768167-da9c-4209-b3e6-5c6fc446bece |      0      |      0      |
|  2017-12-20   | 182fcdb3-babd-4ade-ae6d-c3d6f30ffcde |      0      |      0      |
|  2017-12-20   | 97b8378f-8b66-4f54-9269-0e27c84ab311 |      0      |      0      |
|  2017-12-20   | fb65f3ad-ed9e-4a70-8fa4-ebd609fe7383 |      0      |      0      |
|  2017-12-20   | 3a3e5fe6-39a7-4068-8009-3b9f649cb1aa |      1      |      1      |
|  2017-12-20   | b1bf3547-0c44-4371-907f-31bc75b9c593 |      1      |      1      |
|  2017-12-20   | 313624e5-5331-4a05-ad3a-96786c3162a9 |      1      |      1      |
|  2017-12-20   | e2ca4439-a294-4f04-bace-dff782021560 |      0      |      0      |
|  2017-12-20   | 2e976863-8aaf-4d6c-8ed9-c25504d72bb1 |      0      |      0      |
|  2017-12-20   | b8073de8-84db-4576-8840-40805497e3b8 |      0      |      0      |
|  2017-12-20   | bb246075-ce55-44df-aedd-32a15be914a6 |      1      |      0      |
|  2017-12-20   | 98e28ac7-83ae-4570-bdc8-c5f2a95820a3 |      0      |      0      |

We’ve created a new table that combined all of our data. Once we have the data in this format, we can analyze it in several ways.

Let’s put the whole thing in a `WITH` statement so that we can continue on building our query. We will give the temporary table the name `funnels`. Let’s query from this `funnels` table and calculate overall conversion rates.

1. First, add a column that counts the total number of rows in `funnels`. Alias this column as ‘num_browse’. This is the number of users in the “browse” step of the funnel.
2. Second, add another column that sums the `is_checkout` in `funnels`. Alias this column as ‘num_checkout’. This is the number of users in the “checkout” step of the funnel.
3. Third, add another column that sums the `is_purchase` column in `funnels`. Alias this column as ‘num_purchase’. This is the number of users in the “purchase” step of the funnel.
4. Finally, let’s do add some more calculations to make the results more in depth. Let’s add these two columns:
    - Percentage of users from browse to checkout
    - Percentage of users from checkout to purchase


```SQL
-- Define 'funnels' CTE.-- Define 'funnels' CTE.
WITH funnels AS (
  SELECT DISTINCT b.browse_date,
     b.user_id,
     c.user_id IS NOT NULL AS 'is_checkout',
     p.user_id IS NOT NULL AS 'is_purchase'
  FROM browse AS 'b'
  LEFT JOIN checkout AS 'c'
    ON c.user_id = b.user_id
  LEFT JOIN purchase AS 'p'
    ON p.user_id = c.user_id)
-- Query here.
SELECT
  COUNT(*) AS 'num_browse',
  SUM(is_checkout) AS 'num_checkout',
  SUM(is_purchase) AS 'num_purchase',
  ROUND(100.0 * SUM(is_checkout) / COUNT(user_id), 1) || "%" AS 'pct_browse_to_checkout',
  ROUND(100.0 * SUM(is_purchase) / SUM(is_checkout), 1) || "%" AS 'pct_checkout_to_purchase'
FROM funnels;
```

| num_browse | num_checkout | num_purchase | pct_browse_to_checkout | pct_checkout_to_purchase |
|:----------:|:------------:|:------------:|:-----------------------:|:-------------------------:|
|    775     |     183      |     163      |         23.6%           |          89.1%            |

The management team suspects that conversion from checkout to purchase changes as the `browse_date` gets closer to Christmas Day. We can make a few edits to this code to calculate the funnel for each `browse_date` using `GROUP BY`.

Edit the code so that the first column in the result is `browse_date`. Then, use `GROUP BY` so that we calculate `num_browse`, `num_checkout`, and `num_purchase` for each `browse_date`. Also be sure to `ORDER BY` `browse_date`.


```SQL
-- Define 'funnels' CTE.
WITH funnels AS (
  SELECT DISTINCT b.browse_date,
     b.user_id,
     c.user_id IS NOT NULL AS 'is_checkout',
     p.user_id IS NOT NULL AS 'is_purchase'
  FROM browse AS 'b'
  LEFT JOIN checkout AS 'c'
    ON c.user_id = b.user_id
  LEFT JOIN purchase AS 'p'
    ON p.user_id = c.user_id)
-- Main query.
SELECT browse_date,
   COUNT(*) AS 'num_browse',
   SUM(is_checkout) AS 'num_checkout',
   SUM(is_purchase) AS 'num_purchase',
   ROUND(1.0 * SUM(is_checkout) / COUNT(user_id), 2) AS 'browse_to_checkout',
   ROUND(1.0 * SUM(is_purchase) / SUM(is_checkout), 2) AS 'checkout_to_purchase'
FROM funnels
GROUP BY 1
ORDER BY 1;
```

| browse_date | num_browse | num_checkout | num_purchase | browse_to_checkout | checkout_to_purchase |
|:-----------:|:----------:|:------------:|:------------:|:------------------:|:--------------------:|
| 2017-12-20  |    100     |      20      |      16      |        0.20        |         0.80         |
| 2017-12-21  |    150     |      33      |      28      |        0.22        |         0.85         |
| 2017-12-22  |    250     |      62      |      55      |        0.25        |         0.89         |
| 2017-12-23  |    275     |      68      |      64      |        0.25        |         0.94         |

Oh wow, look at the steady increase in sales (increasing `checkout_to_purchase` percentage) as we inch closer to Christmas Eve! Conversion from checkout to purchase increases from **80%** on 12/20 to **94%** on 12/23!

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
