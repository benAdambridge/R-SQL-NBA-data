# SQL-to-Power-BI-NBA-data-
Using the datasets provided by https://www.kaggle.com/datasets/szymonjwiak/nba-traditional/data?select=traditional.csv, I manipulate and analyse data in SQL, and load into Power BI to create a dashboard.

Szymon Jozwiak scraped data on all NBA (professional USA basketball) games from 1996-2023. We use his datasets, which are 1. the team's boxscore (how many points, assists, game was won etc.) 2. player boxscore (each individual players points scored, assists etc. within that game).

First, I uploaded the datasets into R, removed some of the columns that I was not interested in analysing, and exported the datasets as csvs. (whole project I would usually do in R as can create graphs etc. in R. But, I am learning SQL and wanted to still incorporate R, but see what I could do in SQL).

Secondly, imported into PostgreSQL, creating a database with tables inserted to upload the data into. I ran queries to clean the data, and create views of the data, and subsequent data insight, that we are most interested in. 

Thirdly, creating a connection from SQL to Power BI, to create a dashboard of our data (graphs etc.). 
