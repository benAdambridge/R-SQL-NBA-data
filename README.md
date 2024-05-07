# SQL and R analysis of NBA data #
Using the datasets provided by https://www.kaggle.com/datasets/szymonjwiak/nba-traditional/data?select=traditional.csv, I manipulate and analyse data in SQL and R.

Szymon Jozwiak scraped data on all NBA (professional USA basketball) games from 1996-2023. We use his datasets, which are 1. the team's boxscore (how many points, assists, game was won etc.) 2. player boxscore (each individual players points scored, assists etc. within that game).

First, I uploaded the datasets into R, removed some of the columns that I was not interested in analysing, and exported the datasets as csvs. (whole project I would usually do in R as can create graphs etc. in R. But, I am learning SQL and wanted to see what data insight I could produce using SQL).

Secondly, imported into PostgreSQL, creating a database with tables inserted to upload the data into. I ran queries to clean the data, and create views, subqueries and CTEs of the data, providing interesting data insight.

Creating visualizations, such as the following:

![In a single picture](https://raw.githubusercontent.com/benAdambridge/R-SQL-NBA-data/main/Occurence%20of%20playoff%20scoring%20over%2020percent%20of%20games%20total%20points.png)

