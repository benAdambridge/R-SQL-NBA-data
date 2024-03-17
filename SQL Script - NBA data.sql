-- I will be using data from https://www.kaggle.com/datasets/szymonjwiak/nba-traditional/data?select=traditional.csv --
-- the data scraped all nba (basketball) box scores (games played, points scored etc.) from 1996 to 2023, for players and teams --
-- the csv is made up of two tables (team box score and player box score)
-- team box score: Each game from 1996 to 2023, with team level data on those games (points scored for team etc.)
-- player box score: Each game from 1996 to 2023, with player level data on those games (points scored for player, assists etc.)

-- Importing the csvs into postgresql

-- 1. create tables and input data for Team Box Score

DROP TABLE IF EXISTS teamboxscore;

CREATE TABLE teamboxscore (gameid varchar, -- gameid is what we can Join the two datasets (team and player) by
							date_game date,
						  type_game varchar,
						  team_id varchar,
						  team_name varchar,
						  home_team varchar,
						  away_team varchar,-- numeric because this column has decimal point
						  points_game numeric,
						  field_goals_made_game numeric,
						  field_goals_attempted numeric,
						  result_game BOOLEAN,-- setting as binary(as can only win/lose in basketball)
						  season_year smallint ); -- small int saves byte space


-- load in the data into the created table (in this case a csv (Excel))
copy teamboxscore from 'C:\team_traditional_v2.csv' delimiter ',' csv header;

-- make sure to refresh your server at this point, so it uploads your new table	--	  
SELECT *
from teamboxscore;



-- 1a. Create and load for Player Box score

DROP TABLE IF EXISTS boxscore;


CREATE TABLE boxscore (gameid varchar, -- gameid is what we can Join the two datasets (team and player) by
							date_game date,
						  type_game varchar,
						  player_id varchar,
						  player_name varchar,
					      team varchar,
						  home_team varchar,
						  away_team varchar,
						  minutes_game numeric,
					      points_game2 numeric,
						  field_goals_made_game numeric,
						  field_goals_attempted_game numeric,
						  result_game BOOLEAN,-- setting as binary(as can only win/lose in basketball)
						  season_year smallint,-- small int saves byte space,
					      assists numeric,
					      turnovers numeric);
					  

-- (gameid,date,type,playerid,player,team,home,away,MIN,PTS,FGM,FGA,win,season,AST,TOV)
-- load in the data into the created table (in this case a csv (Excel))
copy boxscore  from 'C:\traditional_v2.csv' delimiter ',' csv header;

-- make sure to refresh your server at this point, so it uploads your new table	--	  
SELECT *
from boxscore;

-- 1c. add in my own dataset where it matches teams' abbreviation to their actual team name

select distinct(team_name)
from teamboxscore
order by team_name ASC;
-- i then copied the output into notepad, and will refer to it when creating the 'actualteamnames' table

-- Create a table which will allow us to use the full team name rather than the abbreviation (the abbreviation was all that was provided)

DROP TABLE IF EXISTS actualteamnames;

CREATE TABLE actualteamnames (team_name varchar,
							 real_team_name varchar);

select * from actualteamnames

INSERT INTO actualteamnames (team_name, real_team_name)
VALUES ('ATL', 'Atlanta Hawks'),
('BKN', 'Brooklyn Nets'),
('BOS', 'Boston Celtics'),
('CHA','Charlotte Bobcats'),
('CHH', 'Charlotte Hornets'),
('CHI', 'Chicago Bulls'),
('CLE', 'Cleveland Cavaliers'),
('DAL', 'Dallas Mavericks'),
('DEN', 'Denver Nuggets'),
('DET', 'Detroit Pistons'),
('GSW', 'Golden State Warriors'),
('HOU', 'Houston Rockets'),
('IND', 'Indiana Pacers'),
('LAC', 'Los Angeles Clippers'),
('LAL', 'Los Angeles Lakers'),
('MEM', 'Memphis Grizzilies'),
('MIA', 'Miami Heat'),
('MIL', 'Milwaukee Bucks'),
('MIN', 'Minnesota Timberwolves'),
('NJN', 'New Jersey Nets'),
('NOH', 'New Orleans Pelicans'),
('NOK', 'New Orleans Pelicans'),
('NOP', 'New Orleans Pelicans'),
('NYK', 'New York Knicks'),
('OKC', 'Oklahoma City Thunder'),
('ORL', 'Orlando Magic'),
('PHI', 'Philadelphia 76ers'),
('PHX', 'Phoenix Suns'),
('POR', 'Portland Trail Blazers'),
('SAC', 'Sacramento Kings'),
('SAS', 'San Antonio Spurs'),
('SEA', 'Seattle Sonics'),
('TOR', 'Toronto Raptors'),
('UTA', 'Utah Jazz'),
('VAN', 'Vancouver Grizzlies'),
('WAS', 'Washington Wizards');


--2. We want to join our two datasets, so that we can find some interesting insight

-- summing total points of both teams in a game, and grouping by the individual games, then filtering to see playoff games

CREATE VIEW teamboxscore_totalpoints AS
SELECT gameid,date_game,home_team, away_team, sum(points_game) points_total_game -- we are summing in a view here as we are not using live data
FROM teamboxscore
WHERE type_game = 'playoff'
GROUP BY gameid, date_game,home_team, away_team
ORDER BY gameid DESC

-- double check view has saved properly
select * 
from teamboxscore_totalpoints

-- joining our bespoke view onto the player table - we want to find the % of points scored by a player of the total game points (playoffs only)
CREATE VIEW player_points_perc_of_game AS   -- extract() is getting the year from date column 
SELECT tb_tp.gameid, tb_tp.date_game, extract(year from tb_tp.date_game) year_game, b.player_name,b.team, 
b.points_game2 player_points, tb_tp.points_total_game total_game_points, 
cast(round(sum(b.points_game2/tb_tp.points_total_game),2) as numeric) "player_points_perc_of_game", -- the cast makes sure this sum becomes numeric, which can then be rounded
tb_tp.home_team, tb_tp.away_team
FROM teamboxscore_totalpoints tb_tp
RIGHT JOIN boxscore b ON b.gameid = tb_tp.gameid -- right join only brings over all the player's games (as our boxscore table is bigger)
GROUP BY tb_tp.gameid, tb_tp.date_game, b.player_name,b.team, 
b.points_game2, tb_tp.points_total_game,tb_tp.home_team, tb_tp.away_team -- group by as we have an aggregation
ORDER BY  "player_points_perc_of_game" DESC;

-- running queries off our bespoke view:

-- 1.
select * from player_points_perc_of_game;
-- top 10 players for percentage of total game point scorers (in the playoffs (1997-now))
select player_name, count(*) "Occurence of playoff scoring over 20% of the games total points"
from player_points_perc_of_game
where player_points_perc_of_game > 0.20 -- only include those who have scored 20% of total game points
group by player_name
order by "Occurence of playoff scoring over 20% of the games total points" DESC
limit (10);


-- 2.

-- top 10 teams for percentage of total players who were a games top point scorer (in the playoffs (1997-now))
-- using our abbreviation -> real team name created table from earlier, we can see the actual real name rather than abbreviation

select atn.real_team_name, count (distinct gameid) occurence_above_twenty_perc -- was pulling through duplicates on the join
from player_points_perc_of_game pp
inner join actualteamnames atn ON atn.team_name = pp.team -- inner join gets rid of rows where it cant find a match
where player_points_perc_of_game > 0.20
group by atn.real_team_name
order by occurence_above_twenty_perc DESC
limit (10);







