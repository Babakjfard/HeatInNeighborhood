5#****************** Calculating Land Surface Temperature ****************************
library(raster)
setwd("C:\\Brookline_DATA\\Satellite\\TZRU34jwWEEK262007\\conus.week26.2007.lon-71.193528to-71.08964.lat42.293135to42.355284.doy178to178.v1.5")

input <- raster("NDVI_TOA.TIF")
#NDVI <- input/10000

#calculate emissivity
NDVI <- input
NDVI[NDVI>5000]<-20000
NDVI[NDVI<2000]<-10000

NDVI <- NDVI/10000
pv <- ((NDVI-0.2)/0.3)^2 
emssivity <- (.004*pv+.986)
emssivity[emssivity>1.1] <- .99
emssivity[emssivity>1] <- .97

#now, having emissivity, we get at-sensor brightness temperature from Band61_TOA_BT.TIF
TB <- raster("Band61_TOA_BT.TIF")
# now calculating LST from (weng et.al.2005)
lambda <- 11.5e-6
ro <- 1.438e-2
TB <- TB/100 # It is in celcious with a scale factor of 100
LST <- (TB/(1+(lambda*TB/ro)*log(emssivity)))
writeRaster(LST, filename = "LST_rev.TIF", format="GTiff")

#=========================\
# Calculating ambient air temperature, based on kloog et al.(2014) and
# the work for the city of cambridge, MA
library(raster)
setwd("C:\\Brookline_DATA\\R")
elevation <- raster("DEM_final.tif")
LST <- raster("LST_final.tif")
NDVI <- raster("NDVI_final.tif")
perc.urban <- raster("percent_Urban1.tif")

#now calculating ambient temperature for each 30x30 pixel 
zarib.LST <- 0.38
zarib.imperv <- -0.00124972102607794
zarib.Elev <- -0.000961258057526494
zarib.NDVI <- -1.333087855/10000
intercept <- 14.8171859697681
temp.ambient <- (LST*zarib.LST)+(elevation*zarib.Elev)+(perc.urban*zarib.imperv)+(NDVI*zarib.NDVI)+intercept
writeRaster(temp.ambient, filename = "temp_ambient.TIF", format="GTiff")

# now creating vectors from treecanopy and ambinet temperature to do regression analysis
tree.canopy <- raster("TreeCanopy_final.tif")
land.cover <- raster("landCover_final.tif")
#then we put tree canopy and amb.temp into two vectors eliminating NA values, and ready for doing the regression :)
locations <- which((land.cover[]==31)|(land.cover[]==41)|(land.cover[]==42)|(land.cover[]==43)|(land.cover[]==71))
#land.cover[locations]<- 100
#writeRaster(land.cover, filename = "canopy_potential.tif", format="GTiff")
canopy.increase <- tree.canopy
canopy.increase[locations] <- 100
canopy.increase <- (canopy.increase-tree.canopy)
writeRaster(canopy.increase, filename = "canopy_increase.tif", format="GTiff")
temp.decrease <- (-0.0301*canopy.increase)
writeRaster(temp.decrease, filename = "temp_decrease.tif", format="GTiff")
#temp.ambient <- raster("temp_ambient.TIF")
#canopy <- (26.958- temp.ambient)/0.0301
#canopy[canopy<0]<- 0
#canopy[canopy>100] <- 93
#writeRaster(canopy, filename = "canopy_calculated.tif", format="GTiff")
#canopy.improved <- canopy
#canopy.improved[which(land.cover[]==100)]<- 100
#writeRaster(canopy.improved, filename = "canopy_increased.tif", format="GTiff")

temp.new <- (-0.0301*canopy)
temp.anomaly <- temp.new-temp.ambient
temp.anomaly[temp.anomaly[]>0] <- 0
writeRaster(temp.anomaly, filename = "temp_anomaly.tif", format="GTiff")

#===================================================
###new problem to solve. find potential places to put 100% tree canopy from land cover, then make their value in 
# treecanopy as 100
canopy.improved <- raster("canopy_improved.tif")
temp <- (-0.0301*canopy.improved+26.958)
writeRaster(temp, filename = "temp_improved.tif", format="GTiff")
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++Below this line, are some sample codes to practice working with
##===============================================================
#  
library(raster)
rr <- raster(nrows=30, ncols=30, xmn=0, ymn=0,ymx=10)
rr #file description
rr[] <- runif(ncell(rr)) #generate a set of random values
rr[]
plot(rr)
#rdr <- raster("drelief.tif",native=T)
setwd("C:\\Brookline_DATA\\Maps")
rd <- writeRaster(rr, "rdrelief.tif",format="GTiff")
setwd("C:\\Brookline_DATA\\Satellite\\TZRU34jwWEEK262007\\conus.week26.2007.lon-71.193528to-71.08964.lat42.293135to42.355284.doy178to178.v1.5")
NDVI <- raster("NDVI_TOA.TIF")
plot(NDVI, asp=1)
image(NDVI, asp=1)
colFromCell(NDVI, 214)
#################**************############## This can be a useful one
cellFromRowCol(NDVI,20,20)/10000
(xy <- xyFromCell(NDVI,cell = 1234)) #these are real image coordinates
(cells <- cellFromCol(NDVI, colnr = 34))
(cell <- cellFromRowCol(NDVI, rownr = 1, colnr = 128))
getValues(NDVI, 25)

#good to create a new layer before changing the values in the raster connected to a file
NDVI2 <- NDVI #Creating a second image
plot(NDVI2, asp=1)
N3 <-  (NDVI2 - 1000 + (NDVI2/1000)^2)
plot(N3, asp=1)
freq(N3)
hist(N3)

# This is also a good function
N4 <- aggregate(N3, fact=9)
par(mfcol=c(2,1))
plot(N3,maiin="original")
plot(N4, main="aggregate 3 times on original value")

par(mfcol=c(2,1))
hist(N3)
hist(N4)

# aggregation, but determine the max value in aggregation area
plot(N3, main="original")
N4 <- aggregate(N3, fact=9, fun=max)
plot(N4, main="aggregate 9x o max")  #??????#####

# reclassification is what I am looking for 
r <- raster(ncols=36, nrows=18)
r[]<-runif(ncell(r))
getValues(r)
m <- c(0, .25, 1, .25, .5, 2, .5, 1, 3)
#create the reclass criteria
rclmat <- matrix(m, ncol=3, byrow = TRUE)
rc <- reclassify(r, rclmat)


####----sample of working with a raster -----####
r <- raster(ncol=10, nrow=10)
m <- raster(ncol=10, nrow=10)
r[] <- runif(ncell(r))*10
m[] <- runif(ncell(r))


