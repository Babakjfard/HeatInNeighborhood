# This is to extract daily temperature data from each station in Chicago in AoT file
# and have a .csv file of TempAmb(nodeID, date, temperature) of average daily temperature in each node
# OPTION 1) The final data source I will work on is AoT. Because of the huge size of > 150GB I am 
# replacing it at this time with some other data sources to create the model
library(dplyr)

edit_later <- function(a,b){
# I used 'wc -l data.csv' and the file has 1800453173 lines of data data.csv
# A sample one day file has 6312676 lines!!
# Therefore it contains approximately 285 days of data.

start.date <- read.csv(file = "../AoT_Chicago.complete.2018-11-04/data.csv.gz", 
                       nrow=1, stringsAsFactors = FALSE)[ ,c("timestamp")]
start.date <- as.Date(strsplit(unlist(start.date), split = " ")[[1]][1])

# OPTION 2) 
# Using package weatherData I will get data from the personal stations through
# Chicago in Wunderground network. more detatils here (http://ram-n.github.io/weatherData/)
devtools::install_github("Ram-N/weatherData")
library(weatherData)
# Finding stations codes in Chicago, IL using this method (http://ram-n.github.io/weatherData/example_PWS.html)
# Could find 11 stations in Chicago, and these are the codes:
stations <- getStationCode("Chicago")
wu_stations <- c("KILCHICA123", "KILMELRO2", "KILROSEM2", "KILFRANK19", "KILCHICA109",
                 "KILCHICA511", "KILCHICA635", "KILCHICA448", "KILPARKR11", "KILPARKR10",
                 "KILPARKR12")
getDetailedWeather(wu_stations[1], "2018-08-01", station_type="id",
                   opt_custom_columns=T,
                   custom_columns = c(3,4))
dfw_wx <- getWeatherForYear(station_id = wu_stations[2], year = 2017)
ttt <- getWeatherForDate(station_id = wu_stations[1], start_date = "2017-08-12")
# ^^^ This one is not even trustworthy!! the data are very incomplete

# OPTION 3) Using rnoaa to extract data
# Now even checking rnoaa package!!
# using package countyweather and rnoaa
devtools::install_github("leighseverson/countyweather")
library(countyweather)
}

# I have extracted daily data for 60 years through GHCN-D and have done imputation and
# stored them, I will be using 100 of the data from nearby stations and attach them to
# the stations in AoT for now!!
create.stations <- function(meta.stations, AoT.stations){
  load(meta.stations)
  nodes <- read.csv(AoT.stations)
  daily.mega$STATE <- trimws(daily.mega$STATE)
  Sta.to.Nodes <- daily.mega %>% filter(STATE=="IL" | STATE=="WI")
  Sta.to.Nodes <- Sta.to.Nodes[1:dim(nodes)[1],] 
  nodes <- nodes %>% mutate(ID = Sta.to.Nodes$ID)
  return(nodes)
}

# Now Get the daily data for a 

Stations <- create.stations("../daily-stations.rda", "../AoT_Chicago.complete.2018-11-04/nodes.csv")
load("../daily-temp-imputed.rda")
tt <- which(stations.10p.miss %in% Stations$ID)
temp.daily <- TmaxS[709:720,,tt]

# I still need 91-77=14 more stations for their data. I will chose randomly 14 of them here 
# and copy!!
temp <- temp.daily[,, sample.int(77,14)]
temp.daily <- abind::abind(temp.daily, temp)
# Done for now, I have one year (2015) daily temperature values for 91 nodes 
# throughout Chicago!
rm(temp, stations.10p.miss, TmaxS, TminS, tt)
