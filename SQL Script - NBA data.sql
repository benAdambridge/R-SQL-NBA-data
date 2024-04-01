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

UPDATE teamboxscore
SET team_name = 'NOH'
WHERE team_name = 'NOK';

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

UPDATE boxscore
SET team = 'NOH'
WHERE team = 'NOK';
-- 1c. add in my own dataset where it matches teams' abbreviation to their actual team name

select distinct(team_name)
from teamboxscore
order by team_name ASC;
-- i then copied the output into notepad, and will refer to it when creating the 'actualteamnames' table

-- Create a table which will allow us to use the full team name rather than the abbreviation (the abbreviation was all that was provided)

DROP TABLE IF EXISTS actualteamnames;

CREATE TABLE actualteamnames (team_name varchar,
							 real_team_name varchar,
							 championships numeric);

select * from actualteamnames

INSERT INTO actualteamnames (team_name, real_team_name, championships)
VALUES ('ATL', 'Atlanta Hawks', '0'),
('BKN', 'Brooklyn Nets', '0'),
('BOS', 'Boston Celtics', '1'),
('CHA','Charlotte Bobcats','0'),
('CHH', 'Charlotte Hornets', '0'),
('CHI', 'Chicago Bulls', '2'),
('CLE', 'Cleveland Cavaliers', '1'),
('DAL', 'Dallas Mavericks', '1'),
('DEN', 'Denver Nuggets', '1'),
('DET', 'Detroit Pistons','1'),
('GSW', 'Golden State Warriors','4'),
('HOU', 'Houston Rockets','0'),
('IND', 'Indiana Pacers','0'),
('LAC', 'Los Angeles Clippers','0'),
('LAL', 'Los Angeles Lakers','6'),
('MEM', 'Memphis Grizzilies','0'),
('MIA', 'Miami Heat','3'),
('MIL', 'Milwaukee Bucks','1'),
('MIN', 'Minnesota Timberwolves','0'),
('NJN', 'New Jersey Nets','0'),
('NOH', 'New Orleans Pelicans','0'),
('NOP', 'New Orleans Pelicans','0'),
('NYK', 'New York Knicks','0'),
('OKC', 'Oklahoma City Thunder','0'),
('ORL', 'Orlando Magic','0'),
('PHI', 'Philadelphia 76ers','0'),
('PHX', 'Phoenix Suns','0'),
('POR', 'Portland Trail Blazers','0'),
('SAC', 'Sacramento Kings','0'),
('SAS', 'San Antonio Spurs','5'),
('SEA', 'Seattle Sonics','0'),
('TOR', 'Toronto Raptors','1'),
('UTA', 'Utah Jazz','0'),
('VAN', 'Vancouver Grizzlies','0'),
('WAS', 'Washington Wizards','0');

select * from actualteamnames

--2. We want to join our two datasets, so that we can find some interesting insight -- 

-- summing total points of both teams in a game, and grouping by the individual games, then filtering to see playoff games --

CREATE VIEW teamboxscore_totalpoints AS
SELECT gameid,date_game,home_team, away_team, sum(points_game) points_total_game -- we are summing in a view here as we are not using live data
FROM teamboxscore
WHERE type_game = 'playoff'
GROUP BY gameid, date_game,home_team, away_team
ORDER BY gameid DESC

-- double check view has saved properly --
select * 
from teamboxscore_totalpoints

-- joining our bespoke view onto the player table, we want to find the % of points scored by a player of the total game points (playoffs only) 
CREATE VIEW player_points_perc_of_game AS   
SELECT tb_tp.gameid, tb_tp.date_game, extract(year from tb_tp.date_game) year_game, b.player_name,b.team, 
b.points_game2 player_points, tb_tp.points_total_game total_game_points, 
cast(round(sum(b.points_game2/tb_tp.points_total_game),2) as numeric) "player_points_perc_of_game", -- the cast makes sure this sum becomes numeric, which can then be rounded
tb_tp.home_team, tb_tp.away_team
FROM teamboxscore_totalpoints tb_tp
RIGHT JOIN boxscore b ON b.gameid = tb_tp.gameid -- right join only brings over all the players games (as our boxscore table is bigger) --
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

select atn.real_team_name, count (gameid) occurence_above_twenty_perc
from player_points_perc_of_game pp
inner join actualteamnames atn ON atn.team_name = pp.team -- inner join gets rid of rows where it cant find a match
where player_points_perc_of_game > 0.20
group by atn.real_team_name
order by occurence_above_twenty_perc DESC
limit (10);


-- 3. playoff wins and correlation to championships won from 1996-2023 --

select atn.real_team_name, count(tbs.gameid) as playoff_wins, atn.championships
from actualteamnames atn
left join teamboxscore tbs on tbs.team_name = atn.team_name 
where tbs.type_game = 'playoff' AND atn.championships >0
group by atn.real_team_name, atn.championships
order by playoff_wins desc

-- Sub query version --
SELECT atn.real_team_name AS team_name, tbs.playoff_wins, atn.championships
FROM actualteamnames atn, (SELECT team_name, count(*) as playoff_wins
	from teamboxscore
	where type_game = 'playoff'
	group by team_name) 
tbs where atn.team_name = tbs.team_name
and atn.championships >0
order by tbs.playoff_wins desc;
		
		-- the Miami Heat are seemingly most successful in terms of playoff wins, but the Spurs and Lakers in fewer games
		-- have won more championships - the ultimate prize.

-- 4. teams who have never reached playoffs

SELECT atn.real_team_name
FROM actualteamnames atn
LEFT JOIN teamboxscore tbs ON atn.team_name = tbs.team_name
AND tbs.type_game = 'playoff'
WHERE tbs.team_name IS NULL;


	-- subquery version
SELECT real_team_name
FROM actualteamnames atn
WHERE NOT EXISTS (
    SELECT 1 -- select 1 says please only look for specified criteria as below, rather than searching whole table data with a *
    FROM teamboxscore tbs
    WHERE tbs.team_name = atn.team_name -- so where team names match
    AND tbs.type_game = 'playoff'
);


		

-- 5. playoff wins amongst teams who have not won a championship from 1996-2023 --

SELECT atn.real_team_name AS team_name, tbs.playoff_wins, atn.championships
FROM actualteamnames atn, (SELECT team_name, count(*) as playoff_wins
	from teamboxscore
	where type_game = 'playoff'
	group by team_name) 
tbs where atn.team_name = tbs.team_name
and atn.championships =0;

	-- but what if we want to reference this table, to then look at these teams' regular season success



