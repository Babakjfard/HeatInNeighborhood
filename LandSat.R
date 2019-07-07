# This is to get LanSat 8 data for the desired time period and to calculate
library(raster)
library(RStoolbox)

# set a temporary data folder for large graphical objects
rasterOptions(tmpdir = "/Users/babak.jfard/R/Graphics")

metaData <- readMeta("./LC81790272016197LGN00/LC81790272016197LGN00_MTL.txt")
