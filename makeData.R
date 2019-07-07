# This is the main file to be run to creat the main required data
# Ambient Temperature (data from AoT of Chicago, one year data for 100 data points) --> Use API
# Percent Impreviousness --> from NLCD (I am sure that there is a large bitmap file, but also check if there is an api)
# Land Cover Type : from NLCD (same as above)
# Traffic in that containing tile (probably should check OpenStreetMap
# distance to nearest highway
# distance to closest industrial area
# daily average wind speed (from nearest station. AccuWeather for tht (lon, lat)?)
# average impreviousness in 8 surrounding tiles
# local population density (data from?)
# Land use type --> Data from OpenStreetMaps
# NDVI (calculate from Landsat data)

                                   
library(sp) #spatial data wrangling & analysis
library(rgdal) #spatial data wrangling
library(rgeos) #spatial data wrangling & analytics
library(tidyverse) # data wrangling
library(tidycensus)
library(tidyverse)


# ================= 1) getting node locations and constructing datasets
source("GetStationData.R")

nodes.spt <- SpatialPointsDataFrame(Stations[,c('lon','lat')],Stations) 
proj4string(nodes.spt) <- CRS("+init=epsg:4326")
save(nodes.spt, Stations, file = "nodes.rda")   #Saves an sf object of nodes with a dataframe of them
save(temp.daily, file = "response_values_2017.rda") #Saves an array of daily temperature in eah node

# ================= 2) 
# Now getting ACS-2015, 5-year estimate Census Data for total population 
acs_key <- Sys.getenv("CENSUS_API_KEY")
# Metadata for variables is here: https://api.census.gov/data/2016/acs/acs5/variables.html (Census Data API: Variables in /data/2016/acs/acs5/variables) or you may use load_variables() function of tidyCensus package.
# and the extracted variables: 

# B01003_001E : Total, TOTAL POPULATION
chicago <- get_acs(state = "IL", county = "Cook", geography = "tract", variables = "B01003_001E", geometry = TRUE) 
# st_transform(., '+proj=longlat +ellps=GRS80 +no_defs')
st_crs(chicago) <- 4326
save(chicago, file = "ACS_population.rda")

# !!!Now first run the first notebook. GettingData.Rmd
# !!!!!!!!!!First round: I will choose the first 90 population values and create a vector out of it
data.pop <- new_chicago$estimate[1:90]

# ================== 3)
# Calculating Land Surface Temperature from LandSat 8 Data
# source(raster_Works)
# First round : I will get a row from month of january from temp.daily
data.LST <- temp.daily[1,5,]/10 # this is the 3rd of January from all 90 stations

# ================= 4) Daytime Population
# Here is a source showing the exact variables to use in tidycensus
# to get the data (https://www.census.gov/topics/employment/commuting/guidance/calculations/acs-tables.html)
# First round: I will get it from another part of ACS
data.day_pop <- new_chicago$estimate[200:289]

# ================= 5) Percent Impreviousness
# I have the raster file for the US in 30m resolution.
# Clip the new_chivcago out of it and then the values in each node location
data.imprev <- runif(dim(Stations)[1], min = .1, max = .95)

# ================= 6) Land Cover Type
# I have the raster file from NLCD in 30m resolution
# The same operations as with percent impreviousness

data.LC <- as.factor(as.character(sample(12, replace = TRUE, size = dim(Stations)[1])))


# ========= 7) Land Use type extractd just for showing to the user it is not to be
# part of the predictive model


# Now creating the sample dataset
Heat_in_Neighborhood <- cbind((temp.daily[1,3,]/10), Stations[,c('lat', 'lon')], data.pop, data.LST,
                 data.day_pop, data.imprev, data.LC)
colnames(Heat_in_Neighborhood) <- c('amb_temp', 'lat', 'lon', 'population', 'LST', 'Day_population',
                       'imprev', "Land_Cover" )
save(Heat_in_Neighborhood, file = "model_dataset.rda")
