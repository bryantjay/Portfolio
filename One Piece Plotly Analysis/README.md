# Exploring Episodes in *One Piece*

## Introduction

Eiichiro Oda's *One Piece* is one of the most iconic and successful media franchises to come out of Japan. The story follows Monkey D. Luffy, a young pirate with rubber abilities, who sets out on a journey to find the legendary treasure "One Piece" and to become the King of the Pirates. This simple premise has kept fans of the series hooked and eagerly awaiting a conclusion for nearly three decades.

![One Piece Vol. 1 and Vol.61 manga covers](https://b1328696.smushcdn.com/1328696/wp-content/uploads/2020/04/01-61.jpg?lossy=1&strip=1&webp=1)

First published as a manga in *Weekly Shonen Jump* in 1997, it has captivated readers worldwide with its rich storytelling and colorful characters. Toei Animation's anime adaptation began airing in 1999, bringing the epic odyssey to television screens across Japan. Over time, "One Piece" has become a global sensation. An early English dub was handled by 4Kids Entertainment during the mid-00s, but this version faced criticism for heavy censorship and narrative re-writes. Funimation acquired the English localization rights in 2007, and began producing a more faithful English version; this is the version that would go on to air on Toonami, Crunchyroll, and Netflix for most of series's history.

Today, the *One Piece* manga is [the best-selling manga in history](https://en.wikipedia.org/wiki/List_of_best-selling_manga#At_least_100_million_copies_and_above), and has even surpassed the sales of U.S.comic books series, also making it [the best-selling comic in history.](https://en.wikipedia.org/wiki/List_of_best-selling_comic_series#Collected_comic_book_volumes) The television show has firmly established itself among other top anime series, such as *Dragon Ball* and *Pokémon*. As the show approaches its final story arcs, it has experienced a renewed surge in popularity in recent years. Additionally, the release of *One Piece*'s live-action Netflix adaptation and the announcement of a future remake under Wit Studio (of *Attack on Titan* acclaim) further sparked mainstream interest, introducing the franchise to new audiences and reigniting enthusiasm among existing fans.

This data visualization project intends to explore the *One Piece* anime throughout its production history and various story arcs. It will focus on the anime, but will briefly use some pre-included manga data to generate some insights concerning the anime. We will be using a combination of Jupyter Notebooks and Plotly for Python to create dynamic, information-rich charts that could occupy an interested party for some amount of time. Plotly's interactive capabilities make it great choice for others to easily explore a dataset. This Jupyter notebook uses direct HTML links to copies of the data sources featured on my GitHub page, and only require common package installations like Pandas and BeautifulSoup to run on your own machine. However, for users who lack the ability to use Python and/or the relevant packages, I've included a version on Kaggle that it runnable without any coding knowledge needed whatsoever.


## Importing the Data

This data workflow will primarily be using the Python version of Plotly; we'll be using the `graph_objects` and `express` extensions, and optionally the `io` extension for exporting static images of the plots. We'll also be employing `BeautifulSoup` and a few other common data science packages.

I've established a URL source on [my GitHub page](https://github.com/bryantjay/Portfolio/tree/main/One%20Piece%20Plotly%20Analysis/source_files) to host this data online in raw CSV format, but the data itself originally comes from two sources on Kaggle: [a dataset on One Piece episode ratings](https://www.kaggle.com/datasets/aditya2803/one-piece-anime), and [a dataset on *One Piece* story arc summaries](https://www.kaggle.com/datasets/tarundalal/one-piece-arcs). We will also be scraping updated television release dates and English-translated titles from an [online source](https://listfist.com/list-of-one-piece-anime-episodes); a copy of this scraped data is also hosted on my GitHub, in the event the web page and/or data becomes inaccessible.

We'll start by reading in the episode data as a Pandas DataFrame `df`, which will the be the main dataframe we focus on.

```
import pandas as pd
import numpy as np
import requests
from bs4 import BeautifulSoup
import plotly.graph_objects as go
import plotly.express as px
import plotly.io as pio
from statsmodels.nonparametric.smoothers_lowess import lowess  # For LOESS

# Download latest version
path = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/One%20Piece%20Plotly%20Analysis/source_files/ONE%20PIECE.csv"

df = pd.read_csv(path)

print(df.head(10))
```
|    |   Unnamed: 0 | rank   |   trend |   season |   episode | name                                                     |   start |   total_votes |   average_rating |
|---:|-------------:|:-------|--------:|---------:|----------:|:---------------------------------------------------------|--------:|--------------:|-----------------:|
|  0 |            0 | 24,129 |      18 |        1 |         1 | I'm Luffy! The Man Who Will Become the Pirate King!      |    1999 |           647 |              7.6 |
|  1 |            1 | 29,290 |      11 |        1 |         2 | The Great Swordsman Appears! Pirate Hunter, Roronoa Zoro |    1999 |           473 |              7.8 |
|  2 |            2 | 32,043 |       7 |        1 |         3 | Morgan vs. Luffy! Who's This Beautiful Young Girl?       |    1999 |           428 |              7.7 |
|  3 |            3 | 28,818 |       8 |        1 |         4 | Luffy's Past! The Red-haired Shanks Appears!             |    1999 |           449 |              8.1 |
|  4 |            4 | 37,113 |       4 |        1 |         5 | Fear, Mysterious Power! Pirate Clown Captain Buggy!      |    1999 |           370 |              7.5 |
|  5 |            5 | 36,209 |       4 |        1 |         6 | Desperate Situation! Beast Tamer Mohji vs. Luffy!        |    1999 |           364 |              7.7 |
|  6 |            6 | 37,648 |       4 |        1 |         7 | Sozetsu Ketto! Kengo Zoro VS Kyokugei no Kabaji!         |    1999 |           344 |              7.7 |
|  7 |            7 | 38,371 |       6 |        1 |         8 | Shousha wa docchi? Akuma no mi no nouryoku taiketsu!     |    1999 |           335 |              7.7 |
|  8 |            8 | 42,249 |       5 |        1 |         9 | Seigi no usotsuki? Kyaputen Usoppu                       |    2000 |           327 |              7.3 |
|  9 |            9 | 41,829 |       4 |        1 |        10 | Chijou saikyou no hen na yatsu! Saiminjutsushi Jango     |    2000 |           314 |              7.5 |

The user on Kaggle who uploaded this dataset states that the data came from [this website](https://www.ratingraph.com/tv-shows/one-piece-ratings-17673/) on TV ratings. Fields such as "rank", "trend", and "total_votes" mostly deal with *One Piece* episode metrics on that website relative to other television shows.

We can see that the index has a duplicated "unnamed" id column. Also, while the first six episodes are in English, most of the following episodes are in their original Japanese titles. We want to fix this mixed-language discrepancy, and ideally use English translations.

There's an up-to-date and well-formatted table of episode numbers, English episode titles, and the exact broadcast dates for all *One Piece* episodes at [the following link](https://listfist.com/list-of-one-piece-anime-episodes). The table on this page is easily scrape-able using `requests` and `BeautifulSoup`. The data will be first read in as a series of three Python lists (one list per column).

Between the subtitled translations, the 4Kids dub, and the Funimation dub, there are a number of different possible English translations. I believe this web page relies mostly either on the Funimation dub or a direct translation from the original Japanese; either of these latter versions are good. As a bonus, we also get full broadcast dates instead of only the year-of-release for each episode's *original*  (i.e. Japanese) broadcast.

```
url = "https://listfist.com/list-of-one-piece-anime-episodes"

r = requests.get(url)

http = r.text

soup = BeautifulSoup(http)

pretty_soup = soup.prettify()
title = soup.title

print(title)
td_tags = soup.find_all("td", ["col-1 odd", "col-2 even", "col-3 odd"])

i = 0

episodes = []
titles = []
release_dates = []

for td in td_tags:
    if i%3 == 0:
        episodes.append(td.text)
    elif i%3 == 1:
        titles.append(td.text)
    else:
        release_dates.append(td.text)
    i += 1

for index in range(len(episodes)):
    print(f"Episode {episodes[index]}:  '{titles[index]}'  |  {release_dates[index]}")
    if index == 10:
        break

print(f"\nLength: {len(episodes)}")
```

`<title>List of One Piece Anime Episodes - ListFist.com</title>`

`Episode 1:  'I'm Luffy! The Man Who Will Become the Pirate King!'  |  October 20, 1999`

`Episode 2:  'Enter The Great Swordsman! Pirate Hunter Roronoa Zoro!'  |  November 17, 1999`

`Episode 3:  'Morgan vs. Luffy! Who's This Mysterious Beautiful Young Girl?'  |  November 24, 1999`

`Episode 4:  'Luffy's Past! The Red-Haired Shanks Appears!'  |  December 8, 1999`

`Episode 5:  'Fear, Mysterious Power! Pirate Clown Captain Buggy!'  |  December 15, 1999`

`Episode 6:  'Desperate Situation! Beast Tamer Mohji vs. Luffy!'  |  December 29, 1999`

`Episode 7:  'Grand Duel! Zoro the Swordsman vs. Cabaji the Acrobat!'  |  December 29, 1999`

`Episode 8:  'Who Will Win? Showdown Between the True Powers of the Devil Fruit!'  |  December 29, 1999`

`Episode 9:  'Honorable Liar? Captain Usopp'  |  January 12, 2000`

`Episode 10:  'The World's Strongest Weirdo! Jango the Hypnotist!'  |  January 19, 2000`

`Episode 11:  'Revealing the Conspiracy! The Pirate Caretaker, Captain Kuro!'  |  January 26, 2000`


`Length: 1122`


The data has survived the scraping process, and can now be added to the main dataframe.

```
df.rename(columns={df.columns[0]: "id"}, inplace=True)

# Creating a temporary DataFrame from the scraped lists
episodes_df = pd.DataFrame({
    'episode': pd.to_numeric(episodes),
    'title': titles,
    'release_date': release_dates
})

# Integrating the scraped data using a merge
df = pd.merge(df, episodes_df, left_on='episode', right_on='episode', how='left')
```

With the proper episode names added in, we can drop the old column of mixed-language episode titles. As a precaution, a string `strip()` method will be applied to trim any potential whitespace. The original title case formatting will be preserved.

At this point, some other data inconsistencies can be cleaned, and data attributes can be properly viewed using the `info()` and `describe()` methods. The 'total_votes' column needs to be cleaned of commas and coerced to a numeric datatype. The 'release_date' column also needs to be converted to a datetime datatype; before this can be done, an erroneous period at row position 863 needs to be corrected.

```
# Overwriting old episode names with the new ones
df['name'] = df['title']
df.drop('title', axis=1, inplace=True)

# Trim any/all whitespace from episode titles
df['name'] = df['name'].str.strip()

# Clean and convert 'total_votes' column to numeric
df['total_votes'] = df['total_votes'].str.replace(',', '', regex=False).astype(float)

# Date format at position 863 contains a period
df['release_date'] = df['release_date'].str.replace('.', ',')

# Parse datetimes from strings
df['release_date'] = pd.to_datetime(df['release_date'], format='%B %d, %Y')



print(df.head(10), "\n")
print(df.info(), "\n")
print(df.describe(include='all'))
```
|    |   id | rank   |   trend |   season |   episode | name                                                               |   start |   total_votes |   average_rating | release_date        |
|---:|-----:|:-------|--------:|---------:|----------:|:-------------------------------------------------------------------|--------:|--------------:|-----------------:|:--------------------|
|  0 |    0 | 24,129 |      18 |        1 |         1 | I'm Luffy! The Man Who Will Become the Pirate King!                |    1999 |           647 |              7.6 | 1999-10-20 00:00:00 |
|  1 |    1 | 29,290 |      11 |        1 |         2 | Enter The Great Swordsman! Pirate Hunter Roronoa Zoro!             |    1999 |           473 |              7.8 | 1999-11-17 00:00:00 |
|  2 |    2 | 32,043 |       7 |        1 |         3 | Morgan vs. Luffy! Who's This Mysterious Beautiful Young Girl?      |    1999 |           428 |              7.7 | 1999-11-24 00:00:00 |
|  3 |    3 | 28,818 |       8 |        1 |         4 | Luffy's Past! The Red-Haired Shanks Appears!                       |    1999 |           449 |              8.1 | 1999-12-08 00:00:00 |
|  4 |    4 | 37,113 |       4 |        1 |         5 | Fear, Mysterious Power! Pirate Clown Captain Buggy!                |    1999 |           370 |              7.5 | 1999-12-15 00:00:00 |
|  5 |    5 | 36,209 |       4 |        1 |         6 | Desperate Situation! Beast Tamer Mohji vs. Luffy!                  |    1999 |           364 |              7.7 | 1999-12-29 00:00:00 |
|  6 |    6 | 37,648 |       4 |        1 |         7 | Grand Duel! Zoro the Swordsman vs. Cabaji the Acrobat!             |    1999 |           344 |              7.7 | 1999-12-29 00:00:00 |
|  7 |    7 | 38,371 |       6 |        1 |         8 | Who Will Win? Showdown Between the True Powers of the Devil Fruit! |    1999 |           335 |              7.7 | 1999-12-29 00:00:00 |
|  8 |    8 | 42,249 |       5 |        1 |         9 | Honorable Liar? Captain Usopp                                      |    2000 |           327 |              7.3 | 2000-01-12 00:00:00 |
|  9 |    9 | 41,829 |       4 |        1 |        10 | The World's Strongest Weirdo! Jango the Hypnotist!                 |    2000 |           314 |              7.5 | 2000-01-19 00:00:00 |

<class 'pandas.core.frame.DataFrame'>

RangeIndex: 958 entries, 0 to 957

Data columns (total 10 columns):

 \#   Column          Non-Null Count  Dtype         
\---  \------          \--------------  \-----         
 0   id              958 non-null    int64         
 1   rank            958 non-null    object        
 2   trend           958 non-null    object        
 3   season          958 non-null    int64         
 4   episode         958 non-null    int64         
 5   name            958 non-null    object        
 6   start           958 non-null    int64         
 7   total_votes     958 non-null    float64       
 8   average_rating  958 non-null    float64       
 9   release_date    958 non-null    datetime64[ns]
 
dtypes: datetime64[ns]\(1), float64(2), int64(4), object(3)

memory usage: 75.0+ KB

None

|        |      id | rank   | trend   |   season |   episode | name                                                |   start |   total_votes |   average_rating | release_date                  |
|:-------|--------:|:-------|:--------|---------:|----------:|:----------------------------------------------------|--------:|--------------:|-----------------:|:------------------------------|
| count  | 958     | 958    | 958     |      958 |   958     | 958                                                 |  958    |       958     |        958       | 958                           |
| unique | nan     | 958    | 34      |      nan |   nan     | 958                                                 |  nan    |       nan     |        nan       | nan                           |
| top    | nan     | 24,129 | -       |      nan |   nan     | I'm Luffy! The Man Who Will Become the Pirate King! |  nan    |       nan     |        nan       | nan                           |
| freq   | nan     | 1      | 374     |      nan |   nan     | 1                                                   |  nan    |       nan     |        nan       | nan                           |
| mean   | 478.5   | nan    | nan     |        1 |   479.5   | nan                                                 | 2010.23 |       152.928 |          7.79656 | 2010-09-26 08:14:31.816283904 |
| min    |   0     | nan    | nan     |        1 |     1     | nan                                                 | 1999    |        70     |          5.6     | 1999-10-20 00:00:00           |
| 25%    | 239.25  | nan    | nan     |        1 |   240.25  | nan                                                 | 2005    |       117     |          7.5     | 2005-08-08 18:00:00           |
| 50%    | 478.5   | nan    | nan     |        1 |   479.5   | nan                                                 | 2010    |       132     |          7.8     | 2010-12-15 12:00:00           |
| 75%    | 717.75  | nan    | nan     |        1 |   718.75  | nan                                                 | 2015    |       157.75  |          8.2     | 2015-11-20 06:00:00           |
| max    | 957     | nan    | nan     |        1 |   958     | nan                                                 | 2021    |      2862     |          9.6     | 2021-01-17 00:00:00           |
| std    | 276.695 | nan    | nan     |        0 |   276.695 | nan                                                 |    6.05 |       108.653 |          0.58967 | nan                           |


### Import data on story arcs

All episode numbers are correct, but each episode of the series is listed as being part of "Season 1". This is technically true as there are no explicit "seasons", but it also does not offer interesting insights. *One Piece* (along with many other anime series) is often broken down in terms of story "arcs" rather than explicit "seasons". We'll categorize episodes based on their story arcs as well.

Again, I'm hosting a copy of this dataset on GitHub, but it originally comes from [here](https://www.kaggle.com/datasets/tarundalal/one-piece-arcs).

```
path = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/One%20Piece%20Plotly%20Analysis/source_files/OnePieceArcs.csv"

arcs = pd.read_csv(path)

print(arcs.head(7))
```

Here's what the first few rows of the dataset initially looks like:

|    | Arc                  |   Start onChapter |   TotalChapters |   TotalPages | Manga%   |   Start onEpisode |   TotalEpisodes |   TotalMinutes(avg 24) | Anime%   |
|---:|:---------------------|------------------:|----------------:|-------------:|:---------|------------------:|----------------:|-----------------------:|:---------|
|  0 | Romance Dawn Arc     |                 1 |               7 |          178 | 0.9%     |                 1 |               3 |                     72 | 0.3%     |
|  1 | Orange Town Arc      |                 8 |              14 |          273 | 1.4%     |                 4 |               5 |                    120 | 0.5%     |
|  2 | Syrup Village Arc    |                22 |              20 |          396 | 2.0%     |                 9 |              10 |                    240 | 1.0%     |
|  3 | Baratie Arc          |                42 |              27 |          514 | 2.6%     |                19 |              12 |                    288 | 1.2%     |
|  4 | Arlong Park Arc      |                69 |              27 |          514 | 2.6%     |                31 |              15 |                    360 | 1.5%     |
|  5 | Buggy Side Story Arc |                 0 |               0 |            0 | 0.0%     |                46 |               2 |                     48 | 0.2%     |
|  6 | Loguetown Arc        |                96 |               5 |          100 | 0.5%     |                48 |               6 |                    144 | 0.6%     |

You can seen this information focuses on the prevalence of story arcs within both the manga (print) and anime (television) formats. You might notice that the values in the "TotalMinutes" field are just multiplication products of "TotalEpisodes" by 24.

The information on manga content is out of scope, as this analysis will focus on the television series. However, there is one important use-case for the manga fields "Start onChapter" and "TotalChapters". You'll notice that some instances of the columns are zero. This occurs when there are story arcs of the television show that do not appear in the manga. These arcs are known as "filler" material.

##### Filler Material

From the [One Piece Wiki](https://onepiece.fandom.com/wiki/Canon#Fillers):

"*For the purposes of this Wiki, filler refers to material that is original to the serialized TV anime. It can refer to whole episodes or arcs driven by plots not found in the manga, or to individual scenes inserted into otherwise-canon material.*

"*As filler exists mostly for logistical reasons (e.g. preventing the anime from overtaking the manga), it cannot tangibly affect the canonical storyline. However, because the anime also presents itself as a single, serialized story, most filler tries to reconcile with canon events instead of overwriting them.*"

Filler material in the anime can exist in a number of different formats:
- Manga cover page stories which were expanded upon to create full episodes (e.g. the "Buggy Side Story Arc" and the "Koby and Helmeppo" training arc).
- Single-episode stories completely original to the anime, and which may or may not occur between canon arc events (e.g. Luffy/Zoro/Sanji one-shots that occur during the post-Ennies Lobby arc).
- Entire (shorter) anime-original story arcs that occur between major canon story arcs (e.g. the "G-8" and "Ice Hunter" arcs).
- Short ~4-episode filler arcs that act as tie-ins to *One Piece* movie releases (e.g. the "Little East Blue" and "Z's Ambition" filler arcs).
- "Recap episodes" that predominantly re-show and re-tell past anime events while contributing little-or-no new, canon material (episodes 279-283 are almost entirely character-focused recaps; this divides parts 1 and 2 of Ennies Lobby).

I want to take a look at the existence of filler arcs and episodes within this show, so let's do this with the creation of a binary categorical column, called "Function". Basically, if the arc exists in the manga, we'll label it "canon". If it does not exist, we'll call it "filler" or non-canon.

```
# Creating a tag for canon and non-canon arcs, based on whether that arc exists in the manga
arcs['Function'] = np.where(arcs['Start onChapter'] == 0, 'filler', 'canon')
```



----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------


https://www.kaggle.com/code/bryantjay/one-piece-plotly-analysis

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_boxplot_by_func.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_histogram.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_votes_histogram.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_over_time.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_episode_line_graph.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_func.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_saga_episodes_barplot.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_boxplot_by_saga.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_saga.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_saga_arc.png?raw=true)

![alt](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_saga_arc_ep.png?raw=true)
