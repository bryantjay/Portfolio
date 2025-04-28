```python
import os

# Change the working directory
os.chdir("/Users/sbrya/Documents/random_data/one_piece/visualizations")

cwd = os.getcwd()
print(cwd)
```

    c:\Users\sbrya\Documents\random_data\one_piece\visualizations
    

# Exploring Episodes in *One Piece*

Two things before beginning:
- **Spoiler Warning**: I'm not going to extensively cover the synopsis of the One Piece series here, but some insights regarding episode titles and narrative descriptions will inevitably be revealed. So if you're squeamish about spoilers regarding this series, consider this your warning.
- GitHub (where I primarily showcase my data science work) does not offer capabilities to render Plotly graphs for Python and Jupyter Notebooks. For this project, [I recommend viewing a duplicated version I have on Kaggle](https://www.kaggle.com/code/bryantjay/one-piece-plotly-analysis). This will showcase the full dynamic functionalities of each graph, which is a big point of using Plotly for this project.

## Introduction

Eiichiro Oda's *One Piece* is one of the largest media franchises to come out of Japan. The story follows Monkey D. Luffy, a young pirate with rubber-like abilities and a signature straw hat, who sets out on a journey to find the legendary treasure "One Piece" and to become the King of the Pirates. This simple premise has kept fans of the series hooked and eagerly awaiting a conclusion for nearly three decades.

![One Piece Vol. 1 and Vol.61 manga covers](https://b1328696.smushcdn.com/1328696/wp-content/uploads/2020/04/01-61.jpg?lossy=1&strip=1&webp=1)


First published in 1997 as a manga in *Weekly Shonen Jump*, *One Piece* has captivated readers worldwide with its rich storytelling and colorful characters. Toei Animation's anime adaptation began airing in 1999, bringing the epic odyssey to television screens across Japan. Over time, the "One Piece" franchise has evolved into a global sensation. An early English-language dub was handled by 4Kids Entertainment during the mid-00s, but this version faced criticism for heavy censorship and narrative re-writes. Funimation acquired the English localization rights in 2007, and began producing a more faithful English version; this is the version that would go on to air on Toonami, Crunchyroll, and Netflix for most of series's history.

As of 2025, the *One Piece* manga is [the best-selling manga in history](https://en.wikipedia.org/wiki/List_of_best-selling_manga#At_least_100_million_copies_and_above), and has even surpassed the sales of other international comic books series, also making it [the best-selling comic book in history.](https://en.wikipedia.org/wiki/List_of_best-selling_comic_series#Collected_comic_book_volumes) The television show has firmly cemented its influence among other top anime series, such as *Dragon Ball* and *Pokémon*. As the show approaches its final story arcs, it has experienced a renewed surge in popularity. Additionally, the release of *One Piece*'s live-action Netflix adaptation and the announcement of a future remake under Wit Studio (of *Attack on Titan* acclaim) further sparked mainstream interest, introducing the franchise to new audiences and reigniting enthusiasm among existing fans.

This data visualization project intends to explore the *One Piece* anime throughout its production history and various story arcs. It will focus on the anime, but will briefly use some pre-included manga data to generate some insights concerning the anime. We will be using a combination of Jupyter Notebooks and Plotly for Python to create dynamic, information-rich charts. Plotly's interactive capabilities make it great choice for others to easily explore a dataset. This Jupyter notebook uses direct HTML links to copies of the data sources featured on my GitHub page, and only require common package installations like Pandas and BeautifulSoup to run on your own machine. However, for users who lack the ability to use Python and/or the relevant packages, I've included a version on Kaggle that it runnable without any coding knowledge needed whatsoever.

## Importing the Data

This data workflow will primarily be using the Python version of Plotly; we'll be using the `graph_objects` and `express` extensions, and optionally the `io` extension for exporting static images of the plots. We'll also be employing `BeautifulSoup` and a few other common data science packages.

I've established a URL source on [my GitHub page](https://github.com/bryantjay/Portfolio/tree/main/One%20Piece%20Plotly%20Analysis/source_files) to host this data online in raw CSV format, but the data itself originally comes from two sources on Kaggle: [a dataset on One Piece episode ratings](https://www.kaggle.com/datasets/aditya2803/one-piece-anime), and [a dataset on *One Piece* story arc summaries](https://www.kaggle.com/datasets/tarundalal/one-piece-arcs). We will also be scraping updated television release dates and English-translated titles from an [online source](https://listfist.com/list-of-one-piece-anime-episodes); a copy of this scraped data is also hosted on my GitHub, in the event the web page and/or data becomes inaccessible.

We'll start by reading in the episode data as a Pandas DataFrame `df`, which will the be the main dataframe we focus on.


```python
import pandas as pd
import numpy as np
import requests
from bs4 import BeautifulSoup
import plotly.graph_objects as go
import plotly.express as px
import plotly.io as pio
from statsmodels.nonparametric.smoothers_lowess import lowess  # For LOESS trendline later on

# URL path to hosted CSV file
path = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/One%20Piece%20Plotly%20Analysis/source_files/ONE%20PIECE.csv"

# Reading CSV in as a Pandas Dataframe
df = pd.read_csv(path)

# Sample View
print(df.head(10))
```

       Unnamed: 0    rank trend  season  episode  \
    0           0  24,129    18       1        1   
    1           1  29,290    11       1        2   
    2           2  32,043     7       1        3   
    3           3  28,818     8       1        4   
    4           4  37,113     4       1        5   
    5           5  36,209     4       1        6   
    6           6  37,648     4       1        7   
    7           7  38,371     6       1        8   
    8           8  42,249     5       1        9   
    9           9  41,829     4       1       10   
    
                                                    name  start total_votes  \
    0  I'm Luffy! The Man Who Will Become the Pirate ...   1999         647   
    1  The Great Swordsman Appears! Pirate Hunter, Ro...   1999         473   
    2  Morgan vs. Luffy! Who's This Beautiful Young G...   1999         428   
    3       Luffy's Past! The Red-haired Shanks Appears!   1999         449   
    4  Fear, Mysterious Power! Pirate Clown Captain B...   1999         370   
    5  Desperate Situation! Beast Tamer Mohji vs. Luffy!   1999         364   
    6   Sozetsu Ketto! Kengo Zoro VS Kyokugei no Kabaji!   1999         344   
    7  Shousha wa docchi? Akuma no mi no nouryoku tai...   1999         335   
    8                 Seigi no usotsuki? Kyaputen Usoppu   2000         327   
    9  Chijou saikyou no hen na yatsu! Saiminjutsushi...   2000         314   
    
       average_rating  
    0             7.6  
    1             7.8  
    2             7.7  
    3             8.1  
    4             7.5  
    5             7.7  
    6             7.7  
    7             7.7  
    8             7.3  
    9             7.5  
    

The user on Kaggle who uploaded this dataset states that the data came from [this website](https://www.ratingraph.com/tv-shows/one-piece-ratings-17673/) on TV ratings. Fields such as "rank", "trend", and "total_votes" mostly deal with *One Piece* episode metrics on that website relative to other television shows.

We can see that the index has a duplicated "unnamed" id column. Also, while the first six episodes are in English, most of the following episodes are in their original Japanese titles. We want to fix this mixed-language discrepancy, and ideally use English translations.

There's an up-to-date and well-formatted table of episode numbers, English episode titles, and the exact broadcast dates for all *One Piece* episodes at [the following link](https://listfist.com/list-of-one-piece-anime-episodes). The table on this page is easily scrape-able using `requests` and `BeautifulSoup`. The data will be first read in as a series of three Python lists (one list per column).

Between the subtitled translations, the 4Kids dub, and the Funimation dub, there are a number of different possible English translations. I believe this web page relies mostly either on the Funimation dub or a direct translation from the original Japanese; either of these latter versions are good. As a bonus, we also get full broadcast dates instead of only the year-of-release for each episode's *original*  (i.e. Japanese) broadcast.


```python
# URL of target data table
url = "https://listfist.com/list-of-one-piece-anime-episodes"

# Get page info using requests package
r = requests.get(url)

# Save text version of HTTP
http = r.text

# Save as BeautifulSoup object
soup = BeautifulSoup(http)

# Prettify the HTML syntax
pretty_soup = soup.prettify()

# Get page title and convert to title case
title = soup.title
print(title)

# Find all table data entries under specified attribute column labels
td_tags = soup.find_all("td", ["col-1 odd", "col-2 even", "col-3 odd"])

# Initiate variables for loop
i = 0
episodes = []
titles = []
release_dates = []

# Loop over table data entries, and sort into respective lists
for td in td_tags:
    if i%3 == 0:
        episodes.append(td.text)
    elif i%3 == 1:
        titles.append(td.text)
    else:
        release_dates.append(td.text)
    i += 1

# Printer header of the sorted lists of data
for index in range(len(episodes)):
    print(f"Episode {episodes[index]}:  '{titles[index]}'  |  {release_dates[index]}")
    if index == 9:  # Loops breaks at index 9 / episode 10
        break

# Print length of list(s)
print(f"\nLength: {len(episodes)}")
```

    <title>List of One Piece Anime Episodes - ListFist.com</title>
    Episode 1:  'I'm Luffy! The Man Who Will Become the Pirate King!'  |  October 20, 1999
    Episode 2:  'Enter The Great Swordsman! Pirate Hunter Roronoa Zoro!'  |  November 17, 1999
    Episode 3:  'Morgan vs. Luffy! Who's This Mysterious Beautiful Young Girl?'  |  November 24, 1999
    Episode 4:  'Luffy's Past! The Red-Haired Shanks Appears!'  |  December 8, 1999
    Episode 5:  'Fear, Mysterious Power! Pirate Clown Captain Buggy!'  |  December 15, 1999
    Episode 6:  'Desperate Situation! Beast Tamer Mohji vs. Luffy!'  |  December 29, 1999
    Episode 7:  'Grand Duel! Zoro the Swordsman vs. Cabaji the Acrobat!'  |  December 29, 1999
    Episode 8:  'Who Will Win? Showdown Between the True Powers of the Devil Fruit!'  |  December 29, 1999
    Episode 9:  'Honorable Liar? Captain Usopp'  |  January 12, 2000
    Episode 10:  'The World's Strongest Weirdo! Jango the Hypnotist!'  |  January 19, 2000
    
    Length: 1122
    

The data has survived the scraping process, and can now be added to the main dataframe.


```python
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


```python
# Renaming the "unnamed" first column to a proper ID column
df.rename(columns={df.columns[0]: "id"}, inplace=True)

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


# View updated data summaries
print(df.head(10).to_markdown(), "\n")
print(df.info(), "\n")
print(df.describe(include='all').to_markdown())
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
     #   Column          Non-Null Count  Dtype         
    ---  ------          --------------  -----         
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
    dtypes: datetime64[ns](1), float64(2), int64(4), object(3)
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


```python
# URL path to hosted CSV file
path = "https://raw.githubusercontent.com/bryantjay/Portfolio/refs/heads/main/One%20Piece%20Plotly%20Analysis/source_files/OnePieceArcs.csv"

# Reading CSV in as a Pandas Dataframe
arcs = pd.read_csv(path)

# Sample View
print(arcs.head(7))
```

                        Arc  Start onChapter  TotalChapters  TotalPages Manga%  \
    0      Romance Dawn Arc                1              7         178   0.9%   
    1       Orange Town Arc                8             14         273   1.4%   
    2     Syrup Village Arc               22             20         396   2.0%   
    3           Baratie Arc               42             27         514   2.6%   
    4       Arlong Park Arc               69             27         514   2.6%   
    5  Buggy Side Story Arc                0              0           0   0.0%   
    6         Loguetown Arc               96              5         100   0.5%   
    
       Start onEpisode  TotalEpisodes  TotalMinutes(avg 24) Anime%  
    0                1              3                    72   0.3%  
    1                4              5                   120   0.5%  
    2                9             10                   240   1.0%  
    3               19             12                   288   1.2%  
    4               31             15                   360   1.5%  
    5               46              2                    48   0.2%  
    6               48              6                   144   0.6%  
    

Here's what the first few rows of the `arcs` dataset initially looks like:

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

The information on manga content is out of scope, as this analysis will focus on the television series. However, there is one important use for the manga fields "Start onChapter" and/or "TotalChapters". You'll notice that some instances of these field are zero. This occurs when there are anime story arcs that do not appear in the original manga. This kind of content is often known as "filler".

##### Filler Material

From the [One Piece Wiki](https://onepiece.fandom.com/wiki/Canon#Fillers):

"*For the purposes of this Wiki, filler refers to material that is original to the serialized TV anime. It can refer to whole episodes or arcs driven by plots not found in the manga, or to individual scenes inserted into otherwise-canon material.*

"*As filler exists mostly for logistical reasons (e.g. preventing the anime from overtaking the manga), it cannot tangibly affect the canonical storyline. However, because the anime also presents itself as a single, serialized story, most filler tries to reconcile with canon events instead of overwriting them.*"

Filler material in the anime can exist in a number of different formats:
- Manga cover page stories which were expanded upon to create full episodes (e.g. the "Buggy Side Story Arc" and the "Koby and Helmeppo" training arc).
- Single-episode stories completely original to the anime (e.g. the Luffy/Zoro/Sanji one-shots that occur during the post-Ennies Lobby arc).
- Entire (shorter) anime-original story arcs that occur between major canon story arcs (e.g. the "G-8" and "Ice Hunter" arcs).
- Short ~4-episode filler arcs that act as promotional tie-ins to *One Piece* movie releases (e.g. the "Little East Blue" and "Z's Ambition" filler arcs).
- "Recap episodes" that predominantly re-show and re-tell past anime events while contributing little-or-no new canonical material (episodes 279-283 are almost entirely character-focused recaps; this divides parts 1 and 2 of Ennies Lobby).

I want to take a look at the existence of filler arcs and episodes within this show, so let's do this with the creation of a binary categorical column, called "Function". Basically, if the arc exists in the manga, we'll label it "canon". If it does not exist, we'll call it "filler" or non-canon.


```python
# Creating a tag for canon and non-canon arcs, based on whether that arc exists in the manga
arcs['Function'] = np.where(arcs['Start onChapter'] == 0, 'filler', 'canon')
```

##### The "Saga" column
I mentioned earlier that this series is not easily broken down into explicit "seasons", as the show has been undergoing weekly development and release schedules year-round for 25 years up until recently (the animation received a three month break between 2024 and 2025). We were able to break everything down into story arcs, but this grouping is still not perfect. There are around 50 different story arcs in the anime, many of which are only 3-4 episodes long. These co-exist which larger story arcs that can be dozens or even hundreds of episodes (the final length of the Wano arc is just over 200 episodes!). Generally, later story arcs tend to last much, much longer than the earlier ones.

As the series has been going on for so long, breaking down all the episodes into its story arcs doesn't work as well as most other shorter-running series. It's noticeable that the number of arcs builds up over time. However, there are still large narrative chunks of the story that strongly pertain to one another in large groupings. "East Blue" effectively acts as the introduction and prologue to the rest of the series. "Ennies Lobby" is often seen as the second half to "Water Seven". Similar relationships exists between "Impel Down" and "Marineford", along with other arts of the story.

Toei Animation also takes note of this, and has also grouped and marketed cohesive sections of the series into larger collections. Instead of seasonal releases, multiple story arcs and various one-shots have been grouped and marketed as larger box sets, affectionately dubbed ["Eternal Logs"](https://store.toei-anim.co.jp/shop/g/gEYXA-13885-7) in reference to an item from the show. [We'll use these collections as our grouping criteria for tying together related story arcs](https://onepiece.fandom.com/wiki/Home_Video_Releases).

Some collections ("Dressrosa", "Whole Cake Island", and "Wano") are large enough that their Eternal Log sets have been further split into multiple parts. We're going to keep these parts grouped together. I'm also going to alias these larger groupings of story arcs as "sagas" in tradition with the first collection, the "East Blue Saga". There is some disagreement and ambiguity as to which arcs pertain to which sagas, which is I why I'm relying on the Eternal Log releases as a guide (so, although one could argue that "Punk Hazard should be included with Dressrosa", or "Sabaody should be grouped with the rest of the 'Summit War' arcs", I'm not relying on those groupings here). So, to recap:

*one saga = many arcs*

Arcs will be categorized into Sagas according to the following groupings (numbers reference the index of `arcs`):
- East Blue: 0-7
- Alabasta: 8-14
- Skypeia: 15-22
- Water Seven: 23-25
- Thriller Bark: 26-31
- Marineford: 32-35
- Fishman Island: 36-38
- Punk Hazard: 39-40
- Dressrosa: 41-42
- Whole Cake Island: 43-46
- Wano: 47-50


```python
# Define the saga names and corresponding arc ranges
saga_mapping = {
    'East Blue': range(0, 8),
    'Alabasta': range(8, 15),
    'Skypeia': range(15, 23),
    'Water Seven': range(23, 26),
    'Thriller Bark': range(26, 32),
    'Marineford': range(32, 36),
    'Fishman Island': range(36, 39),
    'Punk Hazard': range(39, 41),
    'Dressrosa': range(41, 43),
    'Whole Cake Island': range(43, 47),
    'Wano': range(47, 51)
}

# Function to extract saga mapping keys based on `arcs` dataframe index
def get_saga(index):
    for saga, index_range in saga_mapping.items():
        if index in index_range:
            return saga

# Apply the saga indexes to create new 'Saga' column
arcs['Saga'] = arcs.index.map(get_saga)
```

At this point, we can drop the unnecessary columns in the `arcs` dataframe. We concluded that we don't need any info on manga chapters, since we won't be looking at manga data. The column 'TotalMinutes(avg 24)' also seems to not be very useful.


```python
# Drop unnecessary columns
arcs = arcs.drop(columns=["Start onChapter", "TotalChapters", "TotalPages", "Manga%", "TotalMinutes(avg 24)"])
```

When we end up plotting data related to the story arcs and sagas of episodes, it will be helpful to sort in accordance with the ordinal nature of the story. It would be a good idea to establish that order now, by casting the 'Arc' and 'Saga' columns as ordered categorical datatypes.


```python
# Set the 'Arc' and 'Saga' columns to an ordinal Categorical datatypes for later plotting
arcs['Arc'] = pd.Categorical(arcs['Arc'], categories=arcs['Arc'].unique(), ordered=True)
arcs['Saga'] = pd.Categorical(arcs['Saga'], categories=arcs['Saga'].unique(), ordered=True)
```

Here's our improved Story Arcs dataframe:

|    | Arc                     |   Start onEpisode |   TotalEpisodes | Anime%   | Function   | Saga              |
|---:|:------------------------|------------------:|----------------:|:---------|:-----------|:------------------|
|  0 | Romance Dawn Arc        |                 1 |               3 | 0.3%     | canon      | East Blue         |
|  1 | Orange Town Arc         |                 4 |               5 | 0.5%     | canon      | East Blue         |
|  2 | Syrup Village Arc       |                 9 |              10 | 1.0%     | canon      | East Blue         |
|  3 | Baratie Arc             |                19 |              12 | 1.2%     | canon      | East Blue         |
|  4 | Arlong Park Arc         |                31 |              15 | 1.5%     | canon      | East Blue         |
|  5 | Buggy Side Story Arc    |                46 |               2 | 0.2%     | filler     | East Blue         |
|  6 | Loguetown Arc           |                48 |               6 | 0.6%     | canon      | East Blue         |
|  7 | Warship Island Arc      |                54 |               8 | 0.8%     | filler     | East Blue         |
|  8 | Reverse Mountain Arc    |                62 |               2 | 0.2%     | canon      | Alabasta          |
|  9 | Whiskey Peak Arc        |                64 |               4 | 0.4%     | canon      | Alabasta          |
| 10 | Koby and Helmeppo Arc   |                68 |               2 | 0.2%     | filler     | Alabasta          |
| 11 | Little Garden Arc       |                70 |               8 | 0.8%     | canon      | Alabasta          |
| 12 | Drum Island Arc         |                78 |              14 | 1.4%     | canon      | Alabasta          |
| 13 | Alabasta Arc            |                92 |              39 | 3.8%     | canon      | Alabasta          |
| 14 | Post-Alabasta Arc       |               131 |               5 | 0.5%     | filler     | Alabasta          |
| 15 | Goat Island Arc         |               136 |               3 | 0.3%     | filler     | Skypeia           |
| 16 | Ruluka Island Arc       |               139 |               5 | 0.5%     | filler     | Skypeia           |
| 17 | Jaya Arc                |               144 |               9 | 0.9%     | canon      | Skypeia           |
| 18 | Skypiea Arc             |               153 |              43 | 4.2%     | canon      | Skypeia           |
| 19 | G-8 Arc                 |               196 |              11 | 1.1%     | filler     | Skypeia           |
| 20 | Long Ring Long Land Arc |               207 |              15 | 1.5%     | canon      | Skypeia           |
| 21 | Ocean's Dream Arc       |               220 |               5 | 0.5%     | filler     | Skypeia           |
| 22 | Foxy's Return Arc       |               225 |               2 | 0.2%     | filler     | Skypeia           |
| 23 | Water 7 Arc             |               229 |              35 | 3.4%     | canon      | Water Seven       |
| 24 | Enies Lobby Arc         |               264 |              49 | 4.8%     | canon      | Water Seven       |
| 25 | Post-Enies Lobby Arc    |               313 |              13 | 1.3%     | canon      | Water Seven       |
| 26 | Ice Hunter Arc          |               326 |              11 | 1.1%     | filler     | Thriller Bark     |
| 27 | Thriller Bark Arc       |               337 |              45 | 4.4%     | canon      | Thriller Bark     |
| 28 | Spa Island Arc          |               382 |               3 | 0.3%     | filler     | Thriller Bark     |
| 29 | Sabaody Archipelago Arc |               385 |              21 | 2.0%     | canon      | Thriller Bark     |
| 30 | Special Historical Arc  |               406 |               2 | 0.2%     | filler     | Thriller Bark     |
| 31 | Amazon Lily Arc         |               408 |              14 | 1.4%     | canon      | Thriller Bark     |
| 32 | Impel Down Arc          |               422 |              31 | 3.0%     | canon      | Marineford        |
| 33 | Little East Blue Arc    |               426 |               4 | 0.4%     | filler     | Marineford        |
| 34 | Marineford Arc          |               457 |              33 | 3.2%     | canon      | Marineford        |
| 35 | Post-War Arc            |               490 |              27 | 2.6%     | canon      | Marineford        |
| 36 | Return to Sabaody Arc   |               517 |               6 | 0.6%     | canon      | Fishman Island    |
| 37 | Fishman Island Arc      |               523 |              52 | 5.1%     | canon      | Fishman Island    |
| 38 | Z's Ambition Arc        |               575 |               4 | 0.4%     | filler     | Fishman Island    |
| 39 | Punk Hazard Arc         |               579 |              47 | 4.6%     | canon      | Punk Hazard       |
| 40 | Caesar Retrieval Arc    |               626 |               3 | 0.3%     | filler     | Punk Hazard       |
| 41 | Dressrosa Arc           |               629 |             118 | 11.5%    | canon      | Dressrosa         |
| 42 | Silver Mine Arc         |               747 |               4 | 0.4%     | filler     | Dressrosa         |
| 43 | Zou Arc                 |               751 |              29 | 2.8%     | canon      | Whole Cake Island |
| 44 | Marine Rookie Arc       |               780 |               3 | 0.3%     | filler     | Whole Cake Island |
| 45 | Whole Cake Island Arc   |               783 |              95 | 9.2%     | canon      | Whole Cake Island |
| 46 | Levely Arc              |               878 |              12 | 1.2%     | canon      | Whole Cake Island |
| 47 | Wano Country Arc: Act 1 |               890 |              26 | 2.5%     | canon      | Wano              |
| 48 | Cidre Guild Arc         |               895 |               2 | 0.2%     | filler     | Wano              |
| 49 | Wano Country Arc: Act 2 |               918 |              41 | 4.0%     | canon      | Wano              |
| 50 | Wano Country Arc: Act 3 |               959 |              70 | 6.8%     | canon      | Wano              |

##### Merging `arcs` with original dataframe
The improved dataframe on all the different story arcs looks great! Now we need to incorporate it into the rest of our data. In order to merge the `arcs` dataframe with our original `df` dataframe, we will need to define which episode ranges belong to which arcs. We can do this by marking the first and last episodes of each story arc in the `arcs` data frame, along with a corresponding arc index; then we can create and map a custom function to fill the episode ranges of the `df` dataframe with their respective arc indexes.


```python
# Generate episode ranges based on 'Start onEpisode'
episode_ranges = []
for i in range(len(arcs) - 1):
    start_episode = arcs.loc[i, 'Start onEpisode']
    next_start_episode = arcs.loc[i + 1, 'Start onEpisode']
    episode_ranges.append((start_episode, next_start_episode - 1, i))  # (start, end, arc_id)

# Include the last arc, which ends at the last episode
episode_ranges.append((arcs.loc[len(arcs) - 1, 'Start onEpisode'], float('inf'), len(arcs) - 1))

# Function mapping episodes to arcs
def get_arc(episode):
    for start, end, arc in episode_ranges:
        if start <= episode <= end:
            return arc
    return None  # Return None if episode is out of defined ranges

# Apply the mapping function to episode numbers to add labels
df['arc'] = df['episode'].apply(get_arc)
```

Now the main `df` dataframe can be joined with the story arcs dataframe using the index values in `arcs`.


```python
# Merging the dataframes based on the `df` arc id and `arcs` index
df = pd.merge(df, arcs, left_on='arc', right_index=True, how='left')
```

##### Drop additional unneeded columns
After joining our data there are some more unnecessary columns that can be dropped:
- We won't need the columns defining the episode ranges of arcs anymore.
- The 'Anime%' column was a nice summary to have for the improved  `arcs` table, but it won't be of use any longer.
- The 'rank' and 'trend' fields deal with how the One Piece episodes trend among episodes from other shows on the website this data was collected from, which is outside the scope of this EDA project.
- The 'season' column only contains values equal to 1, which offers no useful insight (again, *One Piece* has no explicit season numbers, which is why we're categorizing based on story arcs).
- The 'id', 'start' and extra 'arc' fields can all be dropped as well, as these fields have been replaced and/or improved upon by the episode number, release date, and categorical arc fields respectively.


```python
# These columns are no longer needed.
df = df.drop(columns=['id', 'rank', 'trend', 'season', 'start', 'arc', 'Start onEpisode', 'TotalEpisodes', 'Anime%'])
```

Here's a look at the first few rows of the new and improved dataframe:
|    |   episode | name                                                          |   total_votes |   average_rating | release_date        | Arc              | Function   | Saga      |
|---:|----------:|:--------------------------------------------------------------|--------------:|-----------------:|:--------------------|:-----------------|:-----------|:----------|
|  0 |         1 | I'm Luffy! The Man Who Will Become the Pirate King!           |           647 |              7.6 | 1999-10-20 00:00:00 | Romance Dawn Arc | canon      | East Blue |
|  1 |         2 | Enter The Great Swordsman! Pirate Hunter Roronoa Zoro!        |           473 |              7.8 | 1999-11-17 00:00:00 | Romance Dawn Arc | canon      | East Blue |
|  2 |         3 | Morgan vs. Luffy! Who's This Mysterious Beautiful Young Girl? |           428 |              7.7 | 1999-11-24 00:00:00 | Romance Dawn Arc | canon      | East Blue |
|  3 |         4 | Luffy's Past! The Red-Haired Shanks Appears!                  |           449 |              8.1 | 1999-12-08 00:00:00 | Orange Town Arc  | canon      | East Blue |
|  4 |         5 | Fear, Mysterious Power! Pirate Clown Captain Buggy!           |           370 |              7.5 | 1999-12-15 00:00:00 | Orange Town Arc  | canon      | East Blue |

#### Additional data cleaning
The data looks pretty good now! I should note here that, while this dataset contains only the first 958 episodes of the anime (about mid-way through Wano), I'm currently writing this during the show's extend hiatus in early 2025 (about 1120 episodes in, during Egghead Island). So it should be noted that this version of the data is approximately ~4 years out of date.

For the most part, categorical labels are accurate to where they should be. An avid fan of the anime might notice some discrepancies, however. Many of the canon and filler episode ranges need to be tweaked a little. This part can be a little subjective. For instance, the first half of episode 61 contains concluding material from the "Warship Island" filler arc, while the latter half contains the Straw Hats entering the Grand Line via Reverse Mountain, an important canon event; I've leaned towards re-labeling this episode as 'canon'.  Further explanations are listed in the comments below.

We also need to correct a couple story arc labeling errors in Impel Down and Wano, that occurred following movie filler arcs. Additionally, there seems to be a data entry error for 'total_votes' in the last instance. This value is around 10 times higher than nearby preceding values, and to my knowledge this is not concerning a popular of well-known episode of the show. This value will be imputed to a more reasonable figure of 280 — about the median of nearby instances.


```python
# Mapping to update the 'Function' column based on the episode numbers
episode_updates = {
    (50, 51): 'filler',    # Usopp and Sanji filler episodes in Loguetown
    61: 'canon',           # Half of this episode is non-canon, but the other half begins the next arc
    (98, 99): 'filler',    # Excluding ep. 100 and the tail-end of 101, episodes 98-102
    (101, 102): 'filler',  #   are almost entirely anime-only story material
    (213, 216): 'filler',  # The LRLL Arc length is doubled in the anime using 3 bonus matches.
    (227, 228): 'canon',   # The 'Foxy Returns' episodes focusing on containing Aokiji are canon
    (279, 283): 'filler',  # The first and second halves of Ennies Lobby is divided by 5 recap episodes.
    (291, 292): 'filler',  # Eps. 291, 292, and 303 are part of the historical specials
    303: 'filler',
    (317, 319): 'filler',  # Eps. 317-319 are mostly anime-only filler content
    (430, 456): 'canon',   # Fixing a labeling issue with some of the Impel Down episodes
    (457, 458): 'filler',  # "Special Retrospective" recap episodes between ID and Marineford
    492: 'filler',
    542: 'filler',  # Episodes 492, 542, and 590 are crossover features with Toriko and Dragon Ball Z
    590: 'filler',
    (897, 906): 'canon',  # Labeling issue with Wano episodes following the Cidre Guild,
    (908, 917): 'canon'   #   with the exception of Ep. 907 (original Romance Dawn one-shot)
}

# Applying the mapped updates to the 'Function' column
for key, value in episode_updates.items():
    if isinstance(key, tuple):
        df.loc[df['episode'].between(key[0], key[1]), 'Function'] = value
    else:
        df.loc[df['episode'] == key, 'Function'] = value


# Update mislabeled episodes in Wano, part 1"
df.loc[896:916, 'Arc'] = "Wano Country Arc: Act 1"
# Update mislabeled episodes in Impel Down Arc"
df.loc[429:455, 'Arc'] = "Impel Down Arc"

# Improperly-labeled 'total_votes' outlier for episode #957
df.total_votes.iloc[956] = 280
print(df.iloc[956])
```

    episode                                              957
    name              Big News! The Warlords Attack Incident
    total_votes                                        280.0
    average_rating                                       9.1
    release_date                         2021-01-10 00:00:00
    Arc                              Wano Country Arc: Act 2
    Function                                           canon
    Saga                                                Wano
    Name: 956, dtype: object
    

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_84248\579411247.py:36: FutureWarning: ChainedAssignmentError: behaviour will change in pandas 3.0!
    You are setting values through chained assignment. Currently this works in certain cases, but when using Copy-on-Write (which will become the default behaviour in pandas 3.0) this will never work to update the original DataFrame or Series, because the intermediate object on which we are setting values will behave as a copy.
    A typical example is when you are setting values in a column of a DataFrame, like:
    
    df["col"][row_indexer] = value
    
    Use `df.loc[row_indexer, "col"] = values` instead, to perform the assignment in a single step and ensure this keeps updating the original `df`.
    
    See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
    
      df.total_votes.iloc[956] = 280
    C:\Users\sbrya\AppData\Local\Temp\ipykernel_84248\579411247.py:36: SettingWithCopyWarning: 
    A value is trying to be set on a copy of a slice from a DataFrame
    
    See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
      df.total_votes.iloc[956] = 280
    

## Visualizations

The data is now in a suitable format for visualizations. We're going to create a series of dynamic, information-rich graphs using Plotly for Python. To avoid information overload, each plot will only visually focus on a few selected fields; supplementary information will be added and explorable using Plotly's "hover info" functionality (similar to Tableau's "tooltips" feature).

Our visuals can be separated into two groups: organized by episode "function" (is it "filler" or "canon"?), and organized by narrative arc/saga.

### Canon episodes vs. Filler episodes.

Before plotting, let's first settle on a consistent color scheme for our 'Function' category values. We'll pull an orange and a blue from Plotly's `Prism` color palette of darker, bolder hues. The blue will be mapped to "canon" episodes, and the orange will be mapped to "filler" episodes.


```python
# Define a color mapping to discern canon and filler episodes
function_color_map = {
    'canon': px.colors.qualitative.Prism[1],  # (blue)
    'filler': px.colors.qualitative.Prism[6]  # (orange)
}
```

#### Ratings and Reviewer Votes Histograms

Let's start with some basic distributions. There are two numeric metrics in this dataset to focus on: average ratings, and total votes from reviewers.

The 'average_rating' field represents the aggregated mean of all user ratings for a particular episode, on the website the data is sourced from. This means that each episode has only one 'average_rating', and each episode's rating is independent from one another (i.e. these aren't filled-in metrics from the `arcs` dataframe). We can use `plotly.express` to create a quick-and-simple, no-frills histogram.


```python
# Average Ratings Histogram
fig = px.histogram(df, 
                   x='average_rating',
                   color='Function',
                   nbins=50,  # single bin per 0.1 decimal range
                   color_discrete_map=function_color_map,
                   category_orders={'Function': ['filler', 'canon']} # Ordering sets orange bars under the more prevalent blue bars
)

# Formatting customizations
fig.update_layout(
    title='Rating Distribution of <i>One Piece</i> Episodes',
    xaxis_title='Average User Rating',
    yaxis_title='Count',
    height=600,
    width=1500,
    legend=dict(
        x=0.9,
        y=0.9
    )
)

# Show the figure
fig.show()
```



Notice that within each 'Function' category, the data closely resembles two normal distributions. The story-driven canon episodes are far more abundant, and (naturally) higher rated than filler episodes. All episodes seem to be received by viewers relatively consistently, as all average episode ratings sit within the range of 5.6 - 9.6 (on a possible 0-10 scale).

Not bad! This kind of consistency in viewer expectations is probably what has kept the series going for so long.

Optionally, we can use `plotly.io` here to export a snapshot of the graph, as an image file type of your choice (this also requires the `kaleido` package to be installed). One issue with this, is that these image exports will not have our additional hover information. If you're looking for direct interactivity, you can easily run this notebook in your own workspace, or (again) [come check out this hosted version I have on Kaggle](https://www.kaggle.com/code/bryantjay/one-piece-plotly-analysis).


```python
# Save figure
fig.write_image("op_ratings_histogram.png")
```

If you are viewing without the ability to render Plotly graphs, heres what the chart looks like:

![Histogram distribution of average rating per episode, grouped by canon and filler episodes](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_histogram.png?raw=true)

![Same histogram, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz11.png?raw=true)

The other numeric field we're looking at is 'total_votes'. This represents the number of votes which contributed to 'average_rating', or to put it another way, the number of reviewers who rated a given episode. We could think of this as a way to measure the level of viewer activity relative to each episode. Here's the distribution:


```python
# Total Votes histogram
fig = px.histogram(df, 
                   x='total_votes',
                   color='Function',
                   nbins=100, # single bin per each group of 10
                   color_discrete_map=function_color_map,
                   category_orders={'Function': ['filler', 'canon']} # Ordering sets orange bars under the more prevalent blue bars
)

# Formatting customizations
fig.update_layout(
    title='Distribution of Reviewer Votes per <i>One Piece</i> Episode',
    xaxis_title='Total Votes',
    yaxis_title='Count',
    height=600,
    width=1500,
    legend=dict(
        x=0.9,
        y=0.9
    )
)

# Show the figure
fig.show()
```



There's a much greater overlap between the the canon and filler episodes for this metric. It also sees much greater rightward skewness in its distribution, with a few canon episodes representing the most out-lying points. It doesn't seem like there is a whole lot of differentiation between 'Function' levels for this metric.


```python
# Save figure
fig.write_image("op_votes_histogram.png")
```

Here's what the plot looks like:

![Histogram distribution of total user votes per episode, grouped by canon and filler episodes](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_votes_histogram.png?raw=true)

![Same histogram, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz12.png?raw=true)

#### Average Ratings Distribution, by Function

We saw earlier that separate normal distribution patterns could be tracked when breaking down the "average_rating" variable into canon and filler groupings. Let's once again look at the distribution of this field, this time using a pair of boxplots -- one for each categorical value of "Function".

From this point forward, we're going to be shifting to Plotly's `graph_objects` (`go`) extension more often, instead of `express`. The `px` extension is great for quick plots when first investigating data, like in the prior histograms. However, it's not quite as customizable, especially with regard to the hover info. I want to present supplementary data about specific episodes when appropriate (including their name, number, arc, saga, etc.). The hover formatting options available with Plotly's `go` extension will enable this data to be presented in a much neater, more-organized format. The `go` extension will also aid in adding further plot features later on.

In this next plot, our tooltips are going to present descriptive statistics about the data when hovering over each boxplot, and will present individual episode details when hovering over each specific outlier data point.


```python
# Initialize figure 
fig = go.Figure()

# Add a boxplot trace for each 'Function' class
for function in df['Function'].unique():
    function_data = df[df['Function'] == function]
    
    fig.add_trace(go.Box(
        x=function_data['Function'],
        y=function_data['average_rating'],
        name=function.title(),
        boxmean='sd',
        marker=dict(
            color=function_color_map.get(function, '#000000'),
        ),
        customdata=function_data[['episode', 'name', 'Arc', 'Function', 'Saga']].values,
        hovertemplate=(               # This hover info applies to outliers only
            '<b>Episode %{customdata[0]} (%{customdata[3]}):<br>'
            '"%{customdata[1]}"</b><br>'
            '   - <i>Average Rating: %{y}<br>'
            '   - <i>Saga: %{customdata[4]}<br>'
            '      - <i>Arc: %{customdata[2]}'
            '<extra></extra>'
        )
    ))

# Formatting customizations
fig.update_layout(
    title='Average Ratings of <i>One Piece</i> Episodes',
    yaxis_title='Average User Rating',
    height=750,
    width=1500,
    legend=dict(
        x=0.9,
        y=0.9
    ),
    xaxis=dict(
        tickvals=[0, 1],
        ticktext=["Canon Episodes", "Filler Episodes"],
    )
)

# Show the figure
fig.show()

```



Here we can more easily see the separation of distributions than in the earlier histogram. Our tooltips also lend some insights about the ratings' means, medians, ranges, and IQRs, as  well as specific details pointing out to us which specific episodes lay outside of the normal distribution. We can see that the highest-rated episode is episode 808 from the "Whole Cake Island" arc, where the Straw Hat crewmates Luffy and Sanji fight each other; it is scored at a 9.6 out of 10! Two episodes tie for the lowest average rating of 5.6: episode 881 and episode 336.


```python
# Save figure
fig.write_image("op_ratings_boxplot_by_func.png")
```

Here's what the plot looks like:

![Two boxplot distributions of episode ratings, grouped by canon and filler episodes](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_boxplot_by_func.png?raw=true)

![Same visual, with descriptive statistics tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz21.png?raw=true)

![Same visual, with outlier tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz22.png?raw=true)

#### Average rating of episodes over time

I really want to take a look at how the average ratings change over time. I also want to see if we can track the change in ratings, relative to whether a given episode is "canon" or "filler" material. To do this, my ideal graph would be a single-line time series chart of the "average_rating" column by "release_date", and colored by "Function".

Unfortunately, under the default color settings of Plotly (and most other plotting libraries) this is not do-able with only a single `px` or `go` object call. The default behavior will be to create multiple separate lines when presented with a categorical datatype. Instead, we will need to figure out which segments of the line chart will show which color. We will organize a series of line segments to be plotted, based on episode ranges that belong to consecutive "Function" categorical values.

First, we'll work with our canon episodes. We filter the dataset for only canon episodes, and then apply a cumulative function to group consecutively occurring episodes (aliased in the format <"C" + integer>). These represent our canon line segments. Then, within each episode range, we'll find and record their respective *indices* (not episode number). Finally, we assign a `1` to the 'color' column for all rows, which will be used to modify the color reference in `px.colors.qualitative.Prism[1]` when we create our line plot.


```python
# Filter out filler episodes
canon_eps = df[df.Function=='canon'].sort_values(by='episode')

# Identify where there is a gap greater than 1 between consecutive episodes
canon_eps['group'] = (canon_eps['episode'].diff() > 1).cumsum()
canon_eps['group'] = 'C' + canon_eps['group'].astype(str)

# Get the highest and lowest episode indices for each group
canon_group = canon_eps.groupby(['group'])['episode'].agg(
    min_ind=lambda x: x.min() - 1,
    max_ind=lambda x: x.max()
).reset_index()

# Establish the color key
canon_group['color'] = 1

# Merge the min and max values back to the `canon_eps` dataframe
canon_eps = pd.merge(canon_eps, canon_group, on='group', how='left')

# Print a glimpse of the dataframe
print(canon_group.head())
```

      group  min_ind  max_ind  color
    0    C0        0       45      1
    1    C1       47       49      1
    2   C10      226      278      1
    3   C11      283      290      1
    4   C12      292      302      1
    

|    | group   |   min_ind |   max_ind |   color |
|---:|:--------|----------:|----------:|--------:|
|  0 | C0      |         0 |        45 |       1 |
|  1 | C1      |        47 |        49 |       1 |
|  2 | C10     |       226 |       278 |       1 |
|  3 | C11     |       283 |       290 |       1 |
|  4 | C12     |       292 |       302 |       1 |


We do this same process again, but this time for the *filler* episodes instead. The value for 'color' here is `6` instead of `1`.


```python
# Filter out canon episodes
filler_eps = df[df.Function=='filler'].sort_values(by='episode')

# Identify where there is a gap greater than 1 between consecutive episodes
filler_eps['group'] = (filler_eps['episode'].diff() > 1).cumsum()
filler_eps['group'] = 'F' + filler_eps['group'].astype(str)


# Get the highest and lowest episode indices for each group
filler_group = filler_eps.groupby('group')['episode'].agg(
    min_ind=lambda x: x.min() - 1,
    max_ind=lambda x: x.max()
).reset_index()

# Establish the color key
filler_group['color'] = 6

# Merge the min and max values back to the `filler_eps` dataframe
filler_eps = pd.merge(filler_eps, filler_group, on='group', how='left')

# Print a glimpse of the dataframe
print(filler_group.head().to_markdown())
```

    |    | group   |   min_ind |   max_ind |   color |
    |---:|:--------|----------:|----------:|--------:|
    |  0 | F0      |        45 |        47 |       6 |
    |  1 | F1      |        49 |        51 |       6 |
    |  2 | F10     |       278 |       283 |       6 |
    |  3 | F11     |       290 |       292 |       6 |
    |  4 | F12     |       302 |       303 |       6 |
    

|    | group   |   min_ind |   max_ind |   color |
|---:|:--------|----------:|----------:|--------:|
|  0 | F0      |        45 |        47 |       6 |
|  1 | F1      |        49 |        51 |       6 |
|  2 | F10     |       278 |       283 |       6 |
|  3 | F11     |       290 |       292 |       6 |
|  4 | F12     |       302 |       303 |       6 |


Finally, we merge our separate groupings of consecutive canon and filler episodes into a single dataframe of line segments, with index ranges and color keys assigned to each segment. You might have already noticed that the group keys are sorted as ["C1", "C10", "C11", "C12", "C2", "C20", etc.] because they are all string objects. This will be corrected in the next step, after the segments are sorted by episode index.


```python
# Concatenate the dataframes of filler and canon episode groupings
segments = pd.concat([canon_group, filler_group], ignore_index=True)

# Sort segments by minimum episode index
segments = segments.sort_values(by='min_ind').reset_index(drop=True)

# Display the resulting DataFrame
print(segments.head().to_markdown())
```

    |    | group   |   min_ind |   max_ind |   color |
    |---:|:--------|----------:|----------:|--------:|
    |  0 | C0      |         0 |        45 |       1 |
    |  1 | F0      |        45 |        47 |       6 |
    |  2 | C1      |        47 |        49 |       1 |
    |  3 | F1      |        49 |        51 |       6 |
    |  4 | C2      |        51 |        53 |       1 |
    

|    | group   |   min_ind |   max_ind |   color |
|---:|:--------|----------:|----------:|--------:|
|  0 | C0      |         0 |        45 |       1 |
|  1 | F0      |        45 |        47 |       6 |
|  2 | C1      |        47 |        49 |       1 |
|  3 | F1      |        49 |        51 |       6 |
|  4 | C2      |        51 |        53 |       1 |


Using the indices and color keys we identified, we can now iterate over the line segments in the `segments` dataframe, and plot each line segment with the associated data found in our main `df` dataframe. We're also going to use the `lowess` function from the `statsmodels` package to calculate and plot a smoothed trend line to indicate the general direction of the time series graph. Finally, I've added some annotations and markings to indicate significant events and ratings milestones within the chart, such as when the time skip occurs.


```python
# Initialize figure
fig = go.Figure()

# Compute LOESS trend line
loess_result = lowess(df['average_rating'], df['release_date'], frac=0.1)

# Extract smoothed values
loess_y = loess_result[:, 1]

# Add the LOESS trend line (previously the rolling average line) with a custom color
fig.add_trace(
    go.Scatter(x=df['release_date'], y=loess_y, mode='lines', line={"color":'grey'}, hoverinfo='skip')
)

# Loop through each row in the segments DataFrame to plot each segment
for _, row in segments.iterrows():
    # Extract segment information
    min_ind = row['min_ind']
    max_ind = row['max_ind']
    color = px.colors.qualitative.Prism[row['color']]  # Use color index from `px.colors.qualitative.Prism`
    
    # Select the data for the current segment
    segment_data = df.iloc[min_ind:max_ind+1]
    
    # Add the segment as a trace to the figure
    fig.add_scatter(
        x=segment_data['release_date'], 
        y=segment_data['average_rating'], 
        mode='lines',
        line=dict(color=color),
        name="",  # Drop trace names (they get in the way)
        hovertemplate=(
            '<b>Episode %{customdata[1]} (%{customdata[4]}):'
            '<br>"%{customdata[0]}"</b><br><br>'
            '   - <i>Release Date</i>: %{x}<br>'
            '   - <i>Average Rating</i>: %{y}<br>'
            '   - <i>Saga</i>: %{customdata[3]}<br>'
            '         - <i>Arc</i>: %{customdata[2]}<br> '
        ),
        customdata=segment_data[['name', 'episode', 'Arc', 'Saga', 'Function']].values
    )

# Mark where the time skip occurs with a vertical line
fig.add_annotation(
    x=df[df['episode'] == 517]['release_date'].iloc[0], 
    y=10, 
    text="<b>TIME SKIP</b>",
    ax=0,
    ay=210,
    font=dict(size=12, color="black"),
    bgcolor="white",
    borderpad=4,
    bordercolor="black",
    arrowcolor="red"
)

# Custom annotation function using episode numbers
def add_annotation(episode, text, above):
    # Get the x and y values for the annotation
    x_value = df[df['episode'] == episode]['release_date'].values[0].astype(str)
    y_value = df[df['episode'] == episode]['average_rating'].values[0]
    
    # Determine the vertical positioning for the annotation based on the 'above' argument
    y_offset = 0.05 if above else -0.05
    
    fig.add_annotation(
        x=x_value,
        y=y_value + y_offset,
        text=text,
        ax=0,
        ay=-40 if above else 40,
        bgcolor="rgba(255, 255, 255, 0.7)",
        borderpad=4,
        bordercolor="black"
    )

# List of annotations (episode, text, and 'above' flag)
annotations = [
    (24, "Zoro confronts Mihawk"),
    (151, "Bellamy fight"),
    (126, "Crocodile defeated"),
    (198, "G-8, Long Ring Long Land,<br>Ocean's Dream", False),
    (278, "\"I want to live!\""),
    (236, "Luffy v. Usopp"),
    (336, "Chopper Man<br>(<b>LOWEST-RATED EPISODE, TIED</b>)", False),
    (405, "Crew separated"),
    (483, "Ace dies"),
    (590, "<i>One Piece</i> x <i>DBZ</i>", False),
    (663, "Sabo returns"),
    (748, "<i>OP: Gold</i> tie-in", False),
    (892, "Wano begins"),
    (808, "Sanji fights Luffy<br>(<b>TOP-RATED EPISODE</b>)", ),
    (881, "Sakazuki Reverie recap<br>(<b>LOWEST-RATED EPISODE, TIED</b>)", False)
]

# Add all annotations
for episode, text, *above in annotations:
    add_annotation(episode, text, above=above[0] if above else True)

# Update the layout with the title and labels
fig.update_layout(
    title='Average Ratings of <i>One Piece</i> Episodes Over Time',
    xaxis_title='Episode Release Date',
    yaxis_title='Average User Rating',
    showlegend=False,
    height=450,
    width=1500,
    yaxis=dict(range=[3.5, 10]),
    xaxis=dict(
        range=[df['release_date'].min(), df['release_date'].max()],
        rangeslider=dict(thickness=0.05)
        )
)

# Show the plot
fig.show()
```



What we've essentially created is a timeline of the *One Piece* anime series that is absolutely packed with information to explore. We can see how overall ratings remain relatively consistent throughout the show's history, fluctuating around an 8 out of 10. There is a steady growth in ratings as the story develops during Ennies Lobby, Marineford, Dressrosa, Whole Cake Island, and Wano. We also see substantial dips in ratings during the Fishman Island and Punk Hazard arcs, as well as most "post-arc" time spans where an abundance of filler content is released (notice the orange segments which follow the conclusions of major story arcs like Alabasta, Skypeia, and Ennies Lobby).

Developing on this point, the distinction in average ratings between filler and non-filler material is more transparent in this visual. One can observe sharp downward spikes at any point in the story where filler material is inserted. Particularly notable is the section of anime episodes 196-226, which is 30 straight episodes of almost exclusively filler content. The only canon material in this stretch is half* of the Long Ring Long Land arc, which itself is sometimes treated as a very filler-ish canon arc (* 3 out of the 6 competitions in this arc are anime-only). There are also numerous points where filler content is inserted throughout the Ennies Lobby arc. As an aside, in my opinion, these light-hearted filler episodes are very jarring when they're dropped in the middle of the more climactic and serious story points during Ennies Lobby; this is likely why there is so much fluctuation in ratings between episodes 278 and 325.

There are many exciting and memorable moments throughout the series, and naturally, they often represent some of the highest peaks in episode ratings. Only some of these climactic moments have been marked by annotations, so it's worth exploring the interactive viewer to see more.

We do start to see increased wave height in the ratings fluctuations occurring towards the tail of the graph, from around episode 800 onwards. I'm curious to know what exactly is the cause of this, as only a small number of these peaks and dips are represented by climax and filler episodes respectively. Many of the later seasons are much longer, and some storyline components that occur during them can sometimes be criticized for "dragging on"; it's possible that these fluctuations could be related to the perceived pacing of the story. Other potential reasons could be the boost in Western interest in the show toward the end of the 2010s, or the increased movement of fan bases towards established social media sites in the 2010s. Changes in mainstream popularity, or fan shifts to [algorithm-driven platforms](https://medium.com/the-guild-association/hacking-the-hive-mind-af0601ca3206) could potentially drive ["hive-minded" tendencies](https://www.reddit.com/r/TheoryOfReddit/comments/1fkatpj/reddits_hive_mind_mentality_how_it_brings_out_the/) within a given community.


```python
# Save figure
fig.write_image("op_ratings_over_time.png")
```

Here's what the plot looks like:

![Ratings Timeline of One Piece series, colored by canon and function episodes](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_over_time.png?raw=true)

![Same visual, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz41.png?raw=true)

#### Total Reviewer Votes per Episode

Continuing from ratings over time, let's now take a look at how the number of user votes change. Instead of release date, I'm going to organize this next chart by episode number. This shows an important quirk in the standardized nature of the series: there is nearly no extensive deviation in Toei Animation's weekly release schedule for the past 25 years. [Only recently did the anime undergo the first extended hiatus in its history](https://gamerant.com/one-piece-why-anime-hiatus-explained/), a break lasting six months in length. Up until now, the series has maintained an impressive production schedule of releasing one episode per week, every week, for as long as it has been undergoing production. If one looks closely at the previous timeline, they might notice a few occurrences of one week being skipped, or another week having a bonus episode release; for the most part the one-episode-per-week tradition is consistent, meaning that the episode numbers have a highly synched relation with release dates.

We're going to again color this next plot based on the presence of canon and filler episodes within the series. Luckily, we can re-use the same line segment dataframe from earlier, and *also* the structure of the Plotly code used in the time series plot. Essentially, we only need to adjust our X and Y references, and any relevant titles and axis labels. The annotations are going to be re-customized for the chart, as their positions will need to shifted slightly. We won't be using a LOESS trend line in this plot, as there isn't really a need for it.


```python
# Initialize figure
fig = go.Figure()

# Loop through each row in the segments DataFrame to plot each segment
for _, row in segments.iterrows():
    # Extract segment information
    min_ind = row['min_ind']
    max_ind = row['max_ind']
    color = px.colors.qualitative.Prism[row['color']]  # Use color index from `px.colors.qualitative.Prism`
    
    # Select the data for the current segment
    segment_data = df.iloc[min_ind:max_ind+1]
    
    # Add the segment as a trace to the figure
    fig.add_scatter(
        x=segment_data['episode'], 
        y=segment_data['total_votes'], 
        mode='lines',
        line=dict(color=color),
        name="",
        hovertemplate=(
            '<b>Episode %{customdata[1]} (%{customdata[4]}):'
            '<br>"%{customdata[0]}"</b><br>'
            '   - %{y} votes<br>'
            '   - <i>Saga</i>: %{customdata[3]}<br>'
            '         - <i>Arc</i>: %{customdata[2]}'
        ),
        customdata=segment_data[['name', 'episode', 'Arc', 'Saga', 'Function']].values
    )


# Mark where the time skip occurs with a vertical line
fig.add_vline(
    x=517,
    line=dict(
        color="red",
        width=1,
    ),
    annotation_text="TIME SKIP",
    annotation_position="top right"
)



# Custom annotation function using episode numbers
def add_annotation(episode, text, y_offset=0.05, ayy=-40):
    # Get the x and y values for the annotation
    x_value = episode
    y_value = df[df['episode'] == episode]['total_votes'].values[0]
    
    fig.add_annotation(
        x=x_value,
        y=y_value + y_offset,
        text=text,
        ax=20,
        ay=ayy,
        bgcolor="rgba(255, 255, 255, 0.7)",
        borderpad=4,
        bordercolor="black"
    )

# List of episode markers
annotations = [
    (24, "Zoro confronts<br>Mihawk", -120),
    (37, "Nami asks<br>for help"),
    (151, "Bellamy fight"),
    (126, "Crocodile<br>defeated", -60),
    (236, "Luffy v. Usopp"),
    (278, "\"I want to live!\"", -80),
    (309, "Ennies Lobby<br>conclusion"),
    (405, "Crew separated"),
    (377, "Zoro faces Kuma", -80),
    (483, "Ace dies"),
    (663, "Sabo returns"),
    (726, "Dressrosa<br>Gear 4 Debut"),
    (892, "Wano begins"),
    (808, "Sanji fights Luffy"),
    (870, "Snake-man vs. Katakuri"),
    (914, "Luffy-Kaido<br>Fight #1", -80)
]

# Add each annotation
for episode, text, *ayy in annotations:
    add_annotation(episode, text, ayy=ayy[0] if ayy else -40)

# Update the layout to add title and labels, with y-axis range from 0 to 800
fig.update_layout(
    title='Reviewer Votes of <i>One Piece</i> Episodes',
    xaxis_title='Episode Number',
    yaxis_title='Total Reviewer Votes',  # Label for y-axis
    showlegend=False,
    hovermode='closest',
    height=450,
    width=1500,
    yaxis=dict(range=[0, 800]),  # Set y-axis range from 0 to 800
    xaxis=dict(
        range=[df['episode'].min(), df['episode'].max()],
        rangeslider=dict(thickness=0.05)
        )
)

# Show the figure
fig.show()

```



This secondary line chart gives a better impression of reviewer activity relative to each part of the story. We mostly only notice spikes in user activity around memorable or climactic moments in the story. We don't see the same dips for filler episodes as we saw in the ratings chart, though it does seem like voter levels of filler gaps may be *marginally* lower than those of surrounding episodes (like a *micro*-decrease).

There is far more user activity towards both ends of the chart. Generally, it does seem that earlier episodes from before around episode ~130 tend to have more voter activity on average; particularly, the earlier the episode gets past this point, the higher the level. I would guess that a lot of this elevated activity is nostalgia and/or early viewers who either stop watching or stop reviewing later episodes. It should be noted that both [4Kids](https://www.animenewsnetwork.com/news/2006-12-06/4kids-cancels-one-piece-production) and [Toonami](https://www.animenewsnetwork.com/news/2008-03-29/cartoon-network-has-no-plans-for-one-piece-return) stopped or halted English localizations of the series between the Alabasta arc and Skypeia arcs, before Funimation later resumed work on their dubs in 2011. (If you were a 2007 American viewer like me, you might remember them climbing this waterfall-thing to enter Skypeia, and never getting to see the rest. Sooo, that's why.)

The tail of the chart also sees more activity, and again, this is likely due to increasing audiences in recent years. We also start to see far more upwards spikes in voter levels towards the end of the chart; this is likely related to the large ratings fluctuations which we observed in the previous charts.


```python
# Save figure
fig.write_image("op_episode_line_graph.png")
```

![Line graph depicting the amount of user votes by episode number](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_episode_line_graph.png?raw=true)

![Same visual, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz31.png?raw=true)

#### Votes vs. Episode Ratings

Let's directly compare our two numeric metrics with a scatterplot. The average rating per episode will by plotted on the x-axis, and the number of reviewer votes it received will be measured along the y-axis. Ratings are rounded to the first decimal place, so the ratings field has a somewhat discrete nature to it. In order to show the trend of the plot, 'total_votes' is going to be grouped by discrete 'average_rating', and the median value of each group will be connected with a single line.


```python
# Defining set of points for median line
median_df = df.groupby('average_rating')['total_votes'].median().reset_index()
```


```python
fig = go.Figure()

# List of categories to iterate through
categories = ['canon', 'filler']

# Loop through the categories to create scatterplot traces
for category in categories:
    fig.add_trace(go.Scatter(
        x=df[df['Function'] == category]['average_rating'],
        y=df[df['Function'] == category]['total_votes'],
        mode='markers',
        marker=dict(
            color=function_color_map[category],
            size=8,
            opacity=0.6
        ),
        hovertemplate=(
            '<b>Episode %{customdata[1]} (%{customdata[4]}):'
            '<br>"%{customdata[0]}"</b><br>'
            '   - <i>Release Date</i>: %{y}<br>'
            '   - <i>Average Rating</i>: %{x}<br>' 
            '   - <i>Saga</i>: %{customdata[3]}<br>' 
            '         - <i>Arc</i>: %{customdata[2]}'
            "<extra></extra>"
        ),
        text=df[df['Function'] == category]['episode'].astype(str),
        name=category.capitalize(),  # 'Canon' or 'Filler'
        customdata=df[df['Function'] == category][['name', 'episode', 'Arc', 'Saga', 'Function']].values
    ))

# Add the median line trace to the figure
fig.add_trace(go.Scatter(
    y=median_df['total_votes'],
    x=median_df['average_rating'],
    line=dict(color='grey'),
    mode='lines',
    name='Median votes per discrete rating',
    hoverinfo='none' 
))

# Layout, Titles, and Formatting
fig.update_layout(
    title='Popularity of Canon and Filler <i>One Piece</i> Episodes',
    xaxis_title='Average User Rating',
    yaxis_title='Number of Reviewer Votes',
    hovermode='closest',
    yaxis=dict(range=[0, 750]),
    height=900,
    width=1500,
    showlegend=True
)

# Legend settings
fig.update_layout(
    legend=dict(
        orientation='h',
        x=0.6,
        y=1.07,
        traceorder="normal",
        bgcolor="rgba(255, 255, 255, 0.7)",
        bordercolor="Black",
        borderwidth=1,
        xanchor="center",
        yanchor="middle"
    )
)

fig.show()

```



For the most part we see that ratings and total votes are largely neutral and independent towards for episodes with low to mid ratings, but do see more of an increasing relationship for instances at the higher end of episode ratings (8 and above). Most episodes seem to float around the median line, which itself has a log-like quality about it. The high-rating, high-vote scatter points seen toward the right side of the chart represent many of the instances in the large upwards spikes that existed in the prior two line charts.

There is a cloud of mid-rated episodes with have a large number of ratings in the center of the plot; these represent the very earliest episodes in the series. There are no episodes which constitute low-ratings and high number of user votes. This is good, as this would be an indicator of massive fan outrage (for comparison, the universally-panned [final season of Game of Thrones](https://www.ratingraph.com/tv-shows/game-of-thrones-ratings-26649/#votes) is a low-rated, high-voter scenario on the same website).The ratings division between filler and canon content is again observable here, as most of the lower-rated episodes constitute filler material.


```python
# Save figure
fig.write_image("op_ratings_votes_by_func.png")
```

![Scatterplot comparing the ratings and number of reviewer votes of individual episodes, colored by 'Function' categorical label](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_func.png?raw=true)

![Same visual, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz51.png?raw=true)

### Data by `Saga` and `Arc` categories.

We've seen how canonical episodes of the *One Piece* anime tend to receive higher ratings than filler episodes by about 1. And while that dichotomy isn't as present for the total number of user ratings per episode, of the episodes that receive an exceptionally high number of user ratings, they are always canonical episodes.

Moving forward, let's analyze these same metrics through the lens of narrative groupings. We'll compare the average ratings and total number of reviewer votes between episodes from different parts of the story.

#### Color map

Before creating any plots, we'll first establish a consistent color scheme for the data. We will primarily group by story saga for this section, and all arcs are subcategories of some saga, so it makes sense to color our data based on this 'Saga' category. I've established the following color assignments for each saga of the story, based on stylistic choices and themes present within each of them:


```python
# Define the color mapping for each saga
saga_color_map = {
    'East Blue': px.colors.qualitative.Prism[1],  # A bold and optimistic blue
    'Alabasta': px.colors.qualitative.Dark24[6],  # Desert gold/brown
    'Skypeia': px.colors.qualitative.Dark24[14],  # Jungle green
    'Water Seven': px.colors.qualitative.Dark24[22],  # A deep and depressing blue/indigo
    'Thriller Bark': px.colors.qualitative.Dark24[17],  # Spooooooky purple
    'Marineford': px.colors.qualitative.Dark24[23],  # An intense red
    'Fishman Island': px.colors.qualitative.Dark24[10],  # Mermaid-inspired turquoise (or maybe teal? idk)
    'Punk Hazard': px.colors.qualitative.Dark24[15],  # Cold steel
    'Dressrosa': px.colors.qualitative.Prism[6],  # Gladiator orange
    'Whole Cake Island': px.colors.qualitative.Dark24[1],  # Frosted pink icing
    'Wano': px.colors.qualitative.Dark24[18]  # Deep Kaido violet
}
```

#### Episode counts

Let's take a look at the total number of episodes within each narrative section. We'll use a basic bar chart for this, plotting bars for each story saga. However, because we have Plotly's interactive capabilities, we can also segment each saga's bar into the various story arcs that make it up, and include further information within the tooltips.


```python
# Group by 'Saga' and 'Arc', and count the number of unique episodes
arc_count = df.groupby(['Saga', 'Arc'])['episode'].nunique().reset_index()

# Sort the rows in narrative order
arc_count = arc_count.sort_values(['Saga', 'Arc'], ascending=[False, True])  # Saga will read up-down, and Arc will read left-right

# Initialize figure
fig = go.Figure()

# Create a separate bar trace for each saga using a `for` loop
for saga in arc_count['Saga'].unique():
    saga_data = arc_count[arc_count['Saga'] == saga]
    
    # Trace info here
    fig.add_trace(go.Bar(
        y=saga_data['Saga'],
        x=saga_data['episode'],
        name=saga,
        orientation='h',
        marker=dict(
            color=saga_color_map[saga]
        ),
        hovertemplate=(  # Hover info for the arc
            '<b>%{customdata[0]}</b><br>'
            '   <i>Total Episodes</i>: %{x}<br>'
            '   <i>Saga</i>: %{y}<br>'
            '<extra></extra>'
        ),
        customdata=saga_data[['Arc']].values,
        showlegend=False,
    ))

# Layout
fig.update_layout(
    title='Number of Episodes by <i>One Piece</i> Story Saga',
    xaxis_title='Total Episodes',
    yaxis_title='Saga',
    barmode='stack',  # Stack the bars of the same saga
    hovermode='closest',
    height=600,
    width=1500,
    yaxis=dict(
        categoryorder='array',
        categoryarray=arc_count['Saga'].unique()
    )
)

# Show figure
fig.show()

```

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_84248\2271274781.py:2: FutureWarning:
    
    The default of observed=False is deprecated and will be changed to True in a future version of pandas. Pass observed=False to retain current behavior or observed=True to adopt the future default and silence this warning.
    
    



What we can pull from this graph is that most *canon* story arcs in the series have between 30 and 50 episodes, especially after the first two seasons. The reasoning for the growth of episode counts per story arc is in-part due to the mangaka, and in-part due to production timelines. Oda has been known to let his imagination run wild when planning the series, resulting in a writing style where later chapters of the manga often use more extensive storytelling formats compared to earlier sections. [One well-known example is where Oda's editors pushed him to condense two separate storylines into a single, condensed arc now known as Punk Hazard](https://www.reddit.com/r/OnePiece/comments/4u03ab/oda_combining_arcs/) (which is why the island is bisected into two hot and cold areas). The growing number of anime episodes per story arc can also be attributed to [shifting chapter-to-episode ratios of the series](https://www.youtube.com/watch?v=prOeb5wnNEk&t=18540s&ab_channel=AxelBeats%21?t=5h8m50s), which has typically been used to maintain the gap in production timelines between the manga and the anime.

Among the longest story sagas are Dressrosa and Whole Cake Island, with the respective *arcs* they represent also making up the largest individual arcs. (* It should be noted that the Wano saga and arc(s) *would* be the longest sections if the data were up to date, but alas 🤷.) On the other hand, Punk Hazard, Fishman Island, and East Blue are the shortest story sagas. The shortest individual arcs are typically around 2 episodes long, and are mostly composed of filler material (except for the Reverse Mountain arc).


```python
# Save figure
fig.write_image("op_saga_episodes_barplot.png")
```

![Bar chart of the number of episodes per each story Saga, with stacked bars further broken down into individual story arcs](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_saga_episodes_barplot.png?raw=true)

![Same visual, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz61.png?raw=true)

#### Average Rating

Let's view the ratings behind each saga of the series. This plotting code will iterate through each distinct value of 'Saga', and add on a boxplot trace of ratings for all the different episodes within that story saga. Like the earlier boxplots, the hover info will show descriptive statistics when hovering over the main box-and-whiskers, while showing specific episode information when hovering over any outliers.


```python
# Calculate the average rating per saga
avg_rating_by_saga = df.groupby('Saga')['average_rating'].mean().reset_index()

# Create the figure for the boxplot
fig = go.Figure()

# Add a boxplot trace for each saga
for saga in avg_rating_by_saga['Saga']:
    saga_data = df[df['Saga'] == saga]  # Filter the DataFrame for the specific saga
    
    fig.add_trace(go.Box(
        x=saga_data['Saga'],  # Saga on x-axis
        y=saga_data['average_rating'],  # Ratings for the y-axis
        name=saga,  # Set the name for the trace (for legend)
        marker=dict(
            color=saga_color_map.get(saga, '#000000'),  # Apply custom colors based on saga
        ),
        boxmean='sd',
        customdata=saga_data[['episode', 'name', 'Arc', 'Function']].values,
        hovertemplate=(  # This hover info applies to outliers only
            '<b>Episode %{customdata[0]} (%{customdata[3]}):<br>'
            '"%{customdata[1]}"</b><br>'
            '   - <i>Average Rating: %{y}<br>'
            '   - <i>Saga: %{x}<br>'
            '      - <i>Arc: %{customdata[2]}'
            '<extra></extra>'
        )
    ))

# Layout
fig.update_layout(
    title='Average Rating Distribution by Saga',  # Title of the plot
    xaxis_title='Saga',  # x-axis title
    yaxis_title='Average User Rating',  # y-axis title
    hovermode='closest',  # Ensure hover shows data for the closest point
    yaxis=dict(range=[4, 10]),  # Set y-axis range (optional)
    height=600,
    width=1500,
    showlegend=False  # Show legend for different sagas
)

# Show the plot
fig.show()
```

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_84248\2317097357.py:2: FutureWarning:
    
    The default of observed=False is deprecated and will be changed to True in a future version of pandas. Pass observed=False to retain current behavior or observed=True to adopt the future default and silence this warning.
    
    



Many of the overall trends present in the earlier "ratings over time" line graph find themselves reiterated here. The show sees a moderate climb in ratings up until the "time skip" between Marineford and Fishman Island, where series ratings then dip begin another moderate climb.

Using the mean and median positions, we can observe the relative skewness of episode ratings within each saga. The East Blue, Alabasta, Skypeia, Marineford, Fishman Island, Punk Hazard, and Dressrosa arcs are all relatively centered. The means and medians of these episodes are nearly equal, meaning there is a reasonable balance between "good" and "bad" episodes. There is some downwards ("negative"/"left") skewing present in the Water Seven, Thriller Bark, and Wano sagas, meaning that a few lower-rated episodes are dragging the overall average ratings below what the typical episode rating is. The opposite is true for the Whole Cake Island saga, where a few higher rated episodes create a slight upwards ("positive"/"right") skew. Longer boxplot whiskers in the Whole Cake Island and Wano sagas highlight the significant fluctuations in episode ratings, as seen in the earlier time series chart. Earlier sagas with shorter whiskers ten to maintain more consistent ratings for each episode.

Outliers above the upper whiskers are "event" episodes, a.k.a. the more climactic canon episodes. Outliers below the lower whiskers are low-performing episodes. Most under-performing outliers are linked to filler content, with portions of the Levely arc possibly constituting an exception (though this could be up for debate, as some of these episodes consist of ample "recap" material). The Water Seven and Thriller Bark sagas show numerous filler outliers causing the downwards skew. In particular, the Water Seven saga is tied with Wano for the highest-rated story saga if going by the *median* of episode ratings, but its overall average rating is dragged down by at least eight low-rated filler episodes.


```python
# Save figure
fig.write_image("op_ratings_boxplot_by_saga.png")
```

![Series of boxplot distributions for episode ratings, grouped by each story saga](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_boxplot_by_saga.png?raw=true)

![Same visual, with descriptive statistics tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz71.png?raw=true)

![Same visual, with outlier tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz72.png?raw=true)

#### Saga bubble chart.

Let's directly compare the ratings of various narrative sections by the average number of reviewer votes each received per episode. We'll start by creating a bubble chart inspired by the earlier "Votes vs. Episode Ratings" scatterplot, but grouped by story saga. The size of each bubble will reference the total number of episodes in that specific saga.


```python
# Group by 'Saga' and aggregate the necessary data 
saga_grouped = df.groupby('Saga').agg(
    total_votes=('total_votes', 'mean'),
    average_rating=('average_rating', 'mean'),
    episode_count=('episode', 'count')
).reset_index()

# Create the figure for the bubble scatter plot
fig = go.Figure()

# Add a bubble scatter trace for each Saga
for _, row in saga_grouped.iterrows():
    # Assign the color based on the Saga
    color = saga_color_map.get(row['Saga'], 'gray')  # Default to 'gray' if Saga is not in the map
    
    # Add the trace for this particular Saga
    fig.add_trace(go.Scatter(
        x=[row['average_rating']],
        y=[round(row['total_votes'])],
        mode='markers',
        marker=dict(
            color=color,
            size=(row['episode_count'] * 0.75)+6,
            opacity=0.6
        ),
        hovertemplate=(
            '<b>' + str(row['Saga']) + ' Saga</b><br>'
            ' - <i>Avg. Rating per Episode</i>: %{customdata}<br>'
            ' - <i>Avg. Votes per Episode</i>: %{y}<br>'
            ' - <i>Total Episodes</i>: ' + str(row['episode_count']) + '<br>'
            '<extra></extra>'
        ),
        text=[str(row['Saga'])],
        name=row['Saga'],
        customdata=[[round(row['average_rating'], 2)]]
    ))

# Layout
fig.update_layout(
    title='Popularity of <i>One Piece</i> Story Sagas',
    xaxis_title='Average User Rating per Episode',
    yaxis_title='Average Votes per Episode',
    hovermode='closest',
    height=600,
    width=1500,
    legend=dict(
        x=0.1,
        y=0.9,
        traceorder="normal",
        bgcolor="rgba(255, 255, 255, 0.7)",
        bordercolor="Black",
        borderwidth=1,
        xanchor="center",
        yanchor="top"
    )
)

# Show the figure
fig.show()

```

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_84248\3940141472.py:2: FutureWarning:
    
    The default of observed=False is deprecated and will be changed to True in a future version of pandas. Pass observed=False to retain current behavior or observed=True to adopt the future default and silence this warning.
    
    



Findings:
- Earlier story sagas like East Blue and Alabasta tend to receive the most reviews/votes per episode.
- Fishman Island and Punk Hazard ratings and reviewer numbers noticeably lower.
- Whole Cake Island has the lowest overall amount of reviewer activity, but still maintains one of the highest overall ratings.
- Water Seven and Marineford nearly completely eclipse each other in episode number, average ratings, and number of votes.

Continuing off the findings of the previous boxplot, we can take note that earlier story sagas like East Blue and Alabasta tend to receive the highest number of reviewer votes per episode (with East Blue by a considerable margin). Like we discussed concerning the line chart of 'total_votes', these early "seasons" might have more reviews because the episodes have been aired for longer, or because there is more individuals desist from viewing the show or reviewing episodes over time.

It can also be noted that the Punk Hazard and Fishman Island sagas arguably have the lowest overall popularity among other parts of the story, as their low ratings and reviewer numbers places them towards the bottom-left quadrant of the graph. Interestingly, the Dressrosa and Whole Cake Island Sagas have a comparably low or lower level of reviewer votes, but both also maintain relatively overall high ratings. All of these sections of the story occur in the "New World" half of *One Piece*, occurring immediately after the time skip, so their low reviewer levels likely connect to the sagas' mid-to-late placements in the greater story structure.

Aside from these more extreme examples, the Skypeia, Thriller Bark, and even Alabasta sit close the center of the plotted data. These parts of the story could be argued to be among the most intermediate levels of popularity. The Water Seven, Marineford, and Wano sagas have similar reviewer levels, but also received higher overall ratings. The two fan favorite sagas Water Seven and Marineford nearly eclipse each other perfectly in terms of ratings, reviewership, and episode count.


```python
# Save figure
fig.write_image("op_ratings_votes_by_saga.png")
```

![Bubble plot comparing the aggregated ratings and number of reviewer votes of different story Sagas, colored by 'Saga' categorical label](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_saga.png?raw=true)

![Same visual, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz81.png?raw=true)

#### Arc bubble chart.

Let's take our above saga bubble chart and go down a level of detail, so that each bubble instead references a separate arc. Bubbles will still maintain the Saga color mapping.


```python
# Group by 'Arc' and aggregate necessary data
arc_grouped = df.groupby('Arc').agg(
    saga=('Saga', 'first'),
    total_votes=('total_votes', 'mean'),
    average_rating=('average_rating', 'mean'),
    episode_count=('episode', 'count')
).reset_index()

# Create the figure for the bubble scatter plot
fig = go.Figure()

# Add a single trace per Saga (one for each color)
for saga_name, saga_color in saga_color_map.items():
    saga_data = arc_grouped[arc_grouped['saga'] == saga_name]
    
    # Add all arcs of the same saga to a single trace
    fig.add_trace(go.Scatter(
        x=saga_data['average_rating'].round(1),
        y=saga_data['total_votes'].round(1),
        mode='markers',
        marker=dict(
            color=saga_color,
            size=(saga_data['episode_count'] * 0.75) + 6,
            opacity=0.6
        ),
        hovertemplate=(
            '<b>%{text}</b><br>'
            '   <i>Part of the ' + saga_name + ' story saga</i><br><br>'
            ' - <i>Avg. Rating per Episode</i>: %{x}<br>'
            ' - <i>Avg. Votes per Episode</i>: %{y}<br>'
            ' - <i>Total Episodes</i>: ' + saga_data['episode_count'].astype(str) + '<br>'
            "<extra></extra>"
        ),
        text=saga_data['Arc'],
        name=saga_name
    ))

# Add the trace to the figure
fig.add_trace(go.Scatter(
    y=median_df['total_votes'],
    x=median_df['average_rating'],
    line=dict(color='grey'),
    mode='lines',
    name='Median Total Votes',
    hoverinfo='none' 
))

# Label formatting
fig.update_layout(
    title='Popularity of <i>One Piece</i> Story Arcs',
    xaxis_title='Average User Rating per Episode',
    yaxis_title='Average Votes per Episode',
    hovermode='closest',
    yaxis=dict(range=[0, 600]),
    height=900,
    width=1500,
    showlegend=True,
    legend=dict(
        title="Saga",
        orientation='v',
        yanchor="top",
        y=0.9,
        xanchor="center",
        x=0.15
    )
)

# Show figure
fig.show()

```

    C:\Users\sbrya\AppData\Local\Temp\ipykernel_84248\3299052700.py:2: FutureWarning:
    
    The default of observed=False is deprecated and will be changed to True in a future version of pandas. Pass observed=False to retain current behavior or observed=True to adopt the future default and silence this warning.
    
    



We can see that major story arcs tend to be represented as larger bubbles towards the right side of the graph; this means that they tend to consist of more episodes, and be higher in overall ratings. The Marineford arc is the single highest-rated story arc, and outperforms overall ratings from the Marineford Saga as a whole. There is a clear ratings divide around the ~7.5 level, where bubbles to the right tend to represent longer-form canonical story arcs, and bubbles to the left tend to represent shorter-form filler arcs. The major exceptions are the Fishman Island and Punk Hazard story arcs, which seem to under perform compared to other large canon arcs. The shorter Levely Arc is the only "canon" arc to have a lower rating than Punk Hazard and Fishman Island (* although, again much of the content in Levely episodes could be considered "recap material").

Most arcs from all parts of the story tend to maintain reviewer levels in the average range of 100-200 votes per episode. The major exception to the collection of various East Blue arcs, most of which far exceed the average number of reviewer votes per episode than arcs from any other part of the story. The first five story arcs of the entire series ("Romance Dawn", "Orange Town", "Syrup Village", "Baratie", and "Arlong Park") each receive hundreds more per-episode reviews on average than any other story arcs. We can also start to see the beginning of some layering here, where earlier story arcs "rest upon" their later counterparts due to decreasing reviewer levels over time; notice the blue and gold bubbles toward the higher voter levels, and a few pink Whole Cake Island bubbles sitting near the bottom.


```python
# Save figure
fig.write_image("op_ratings_votes_by_saga_arc.png")
```

![Bubble plot comparing the aggregated ratings and number of reviewer votes of arcs, colored by 'Saga' categorical label](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_saga_arc.png?raw=true)

![Same visual, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz82.png?raw=true)

#### Episode scatterplot, colored by Saga.

This next plot will again change the level of detail to individual episodes. This is effectively the same plot as the initial "Votes vs. Episode Rating" scatterplot, but with an alternate color scheme; the custom 'Saga' color scheme is applied in place of the orange/blue 'Function' color scheme. This allows for an easier viewing of where individual episodes sit on the plot relative to other episodes from both the same and different narrative sagas.


```python
# Create the figure for the bubble scatter plot
fig = go.Figure()

# Add a single trace per Saga (one for each color)
for saga_name, saga_color in saga_color_map.items():
    saga_data = df[df['Saga'] == saga_name]
    
    # Add all arcs of the same saga to a single trace
    fig.add_trace(go.Scatter(
        x=saga_data['average_rating'].round(1),
        y=saga_data['total_votes'].round(1),
        mode='markers',
        marker=dict(
            color=saga_color
        ),
        hovertemplate=(
            '<b>Episode %{customdata[1]} (%{customdata[4]}):'
            '<br>"%{customdata[0]}"</b><br>'
            '   - <i>Average Rating</i>: %{x}<br>'
            '   - <i>Saga</i>: %{customdata[3]}<br>'
            '         - <i>Arc</i>: %{customdata[2]} '
            "<extra></extra>"
        ),
        text=saga_data['Arc'],
        name=saga_name,
        customdata=saga_data[['name', 'episode', 'Arc', 'Saga', 'Function']].values
    ))

# Add the trace to the figure
fig.add_trace(go.Scatter(
    y=median_df['total_votes'],
    x=median_df['average_rating'],
    line=dict(color='grey'),
    mode='lines',
    name='Median votes per discrete rating',
    hoverinfo='none' 
))

# Label formatting
fig.update_layout(
    title='Popularity of Episodes from Various Story Sagas',
    xaxis_title='Average User Rating',
    yaxis_title='Total Reviewer Votes',
    hovermode='closest',
    xaxis=dict(range=[5.5, 10]),
    yaxis=dict(range=[0, 750]),
    height=900,
    width=1500,
    showlegend=True,
    legend=dict(  # legend settings
        title=None,
        orientation='v',
        yanchor="top",
        y=0.9,
        xanchor="center",
        x=0.15
    )
)

# Show figure
fig.show()

```



Developing on my previous comment, this plot seems to indicate more "layering" between 'total_votes' levels for different parts of the story. Some of this might be the layering order of the Plotly traces, but it does appear that level of "Total Reviewer Votes" for earlier story sagas sit on the higher levels of the plot, while episodes from later story sagas rest toward the bottom, often in the chronological order of the 'Saga' field (with the somewhat exception of Wano). The discernable order of layers appears to be East Blue (blue) on top, followed by Alabasta (gold) and Skypeia (green); Whole Cake Island episodes (pink) tend to sit near the bottom, right below Dressrosa (orange). Episodes from all other *middle* sagas appear largely indiscernible or mixed-together, sitting closer to the median line. One exception is the amount of reviewer vote levels for Wano episodes (dark purple); these appears all over the plot at various places, and seem to be not as clustered together.

There's a lot of interesting episode information to sift through here. Fans of the series are encouraged to explore.


```python
# Save figure
fig.write_image("op_ratings_votes_by_saga_arc_ep.png")
```

![Scatterplot comparing the ratings and number of reviewer votes of individual episodes, colored by 'Saga' categorical label](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/op_ratings_votes_by_saga_arc_ep.png?raw=true)

![Same visual, with tooltip](https://github.com/bryantjay/Portfolio/blob/main/One%20Piece%20Plotly%20Analysis/visualizations/viz83.png?raw=true)

## Conclusions

We learned that overall ratings for the show remain around a fairly consistent 7-8 out of 10 throughout the series, with some specific variation depending on the story arc. The highest rated macro-storylines included Ennies Lobby, Marineford ("Summit War"), Dressrosa, Whole Cake Island, and Wano, many of which also included some of the longest and most extensively-developed individual story arcs; this insight doesn't necessarily mean that "more is better", but it does indicate that proper story development can aid ratings. Some of the lowest-rated storylines included Fishman Island and Punk Hazard. We also observed significant fluctuations in the ratings of the most recent sagas, including Wano and Whole Cake Island.

With regard to episode content, we saw that canon episodes made up most of the data, and often had a higher rating than filler episodes by an average of about 1 grade point. Concerning the recent break occurring during the production of Egghead Island, the gap in ratings between canon and non-canon content may support this move away from filler content in favor of occasional production breaks (as far as critical ratings are concerned). To properly judge this assertion, more recent data on episode ratings following the Egghead hiatus would be needed (when available). We also saw mild-to-substantial ratings bumps for certain climactic moments in the overall narrative.

Regarding reviewer activity, there seemed to be no significant differentiation between canon and filler episodes. Instead, we mostly saw reviewer activity change over time with regard to location in the overall narrative. Reviewer activity was initially very high at the start of the series before slowly declining, plateauing for the majority of the series, and fluctuating upwards again towards more recent material. This means that earlier storylines accumulated marginally more activity than later counterparts (with the exception of Wano); by a significant margin, the most-reviewed storylines were the first two: East Blue and Alabasta. The interaction between episode ratings and their respective viewer activity indicated a relatively stable overall satisfaction with the show, as there were no extreme instances of episodes with low ratings and high reviewer activity, indicating potential viewer displeasure or outrage.

