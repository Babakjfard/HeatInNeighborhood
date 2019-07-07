library(raster)
library(RStoolbox)

# set a temporary data directory for large graphical objects
# rasterOptions(tmpdir = "/Users/babak.jfard/R/LandSat_Data")
# 
# metadata.file <- '../LandSat_Data/LC080230312017010201T2-SC20181110015922/LC08_L1GT_023031_20170102_20170218_01_T2_MTL.txt'
# 
# metaData <- readMeta(metadata.file)
# lsat8 <- stackMeta(metadata.file)
# Because it gives error, for now I will just get band 6 .tiff file
# and assume that it is the Land Surface temperature!!
# ===============================================================
# First attempt, I will try to create a raster stack of all band 6 for 
# the available 5 dates!
path <- '/Users/babak.jfard/R/LandSat_Data/Band6/'
#setwd(path)
band6_files <- paste0(path, list.files(path))

landsat <- raster(band6_files[1])
