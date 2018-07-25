getwd()
setwd('...')

install.packages("sqldf")
install.packages('ggplot2')
library('sqldf')
library('ggplot2')

Cup.Russia.Matches <- read.csv("Cup.Russia.Matches.csv")
Cup.Russia.Teams <- read.csv("Cup.Russia.Teams.csv")
WorldCupMatches <- read.csv("WorldCupMatches.csv")
WorldCupPlayers <- read.csv("WorldCupPlayers.csv")
WorldCups<- read.csv("WorldCups.csv")

WorldCupMatches <- na.omit(WorldCupMatches)

temp <- Filter(function(x) is(x, "data.frame"), mget(ls()))
lapply(temp, colnames)


#--------------EDA------------------#

#Que 1. How many times Home team won? (use WorldCups file)

colnames(WorldCups)
homeWinner_count <- sqldf("Select count(*) as # from WorldCups where Country = Winner")
homeWinner<-sqldf("Select winner as HomeWinners from WorldCups where Country = Winner")

MatchesPlayed <- sqldf("Select Player_Name, count(*) as 'Matches_played' from WorldCupPlayers Group By Player_Name order by Matches_played DESC")


colnames(WorldCupMatches) <- gsub("\\.", "_", colnames(WorldCupMatches))
FinalMatchScores <- sqldf("Select a.Year, a.Home_Team_Name as Team1, a.Home_Team_Goals as Team1_Goals, a.Away_Team_Name as Team2,
                          a.Away_Team_Goals as Team2_Goals, b.winner 
                          from WorldCupMatches a Left Join WorldCups b
                          on a.Year=b.year where Stage='Final' order by a.Year")

FinalMatchScores<- unique(FinalMatchScores)


FinalMatchScores<- transform(FinalMatchScores, 
                              Team1 = ifelse(Team1==Winner, Team1, Team2),
                              Team2 = ifelse(Team2==Winner, Team1, Team2),
                             Team1_Goals = ifelse(Team1==Winner, Team1_Goals, Team2_Goals),
                             Team2_Goals = ifelse(Team2==Winner, Team1_Goals, Team2_Goals))


FinalMatchScores_plot <- FinalMatchScores[c('Team1_Goals','Team2_Goals')]
FinalMatchScores_plot <- as.data.frame(t(FinalMatchScores_plot))
colnames(FinalMatchScores_plot)<- FinalMatchScores$Year
rownames(FinalMatchScores_plot)<- c('Winner','Runnerup')
barplot(FinalMatchScores_plot, col=colors()[c(99,10)], border="white", width = c(1000, 1000), beside=T, legend=rownames(FinalMatchScores_plot), xlab="Year", ylab = "# of Goals")


#write.csv(FinalMatchScores,'../FinalMatchScores.csv')

