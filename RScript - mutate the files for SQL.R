
## set your working directory (where you want R to get your files from)
setwd("C:/")

## Team box score data

team_box_score<-read.csv("team_traditional.csv")

str(team_box_score)

team_box_score_v2 = subset(team_box_score, select = c(gameid, date, type,teamid,team,home,away,PTS,FGM,FGA,win,season)) # reducing dataset to these selected 12 columns

write.csv(team_box_score_v2,file='C:/Users/benbr/OneDrive/Documents/Github/NBA-box_score-dataset/team_traditional_v2.csv',row.names = FALSE) # exporting cleaned data as csv


box_score<-read.csv("traditional.csv")

str(box_score)

box_score_v2 = subset(box_score, select = c(gameid, date, type,playerid,player,team,home,away,MIN,PTS,FGM,FGA,win,season, AST, TOV)) # reducing dataset to these selected 16 columns


write.csv(box_score_v2,file='C:/Users/benbr/OneDrive/Documents/Github/NBA-box_score-dataset/traditional_v2.csv', row.names = FALSE) # exporting cleaned data as csv
