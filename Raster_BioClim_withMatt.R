library(raster)
library(geodata)
library(terra)
library(ggplot2)
library(USAboundaries)
library(dplyr)
library(sf)

### --------------------------------
### Load in the sample location data
### --------------------------------

points_df <- read.csv("~/Library/CloudStorage/Box-Box/Taryn/01_MOLE_SKINK/Maps/QGIS/data/AllSamples_Cornell_25_20260225.csv",
                      header=T)

### --------------------------------
### Read in the bioclim data for current climates
### --------------------------------

current_climate <- worldclim_global(var = 'bio', res = 2.5, path = './Downloads')

### --------------------------------
### Set the p.egregius geographic bounds and crop climate rasters
### --------------------------------

bounds <- extent(-88, -80, 24.5, 33)

current_climate <- crop(current_climate, bounds)

### --------------------------------
### convert to single raster stack (list of rasters)
### --------------------------------

current_climate_stack <- stack(current_climate)

### --------------------------------
### First plot Bio1 - mean annual temperature
### --------------------------------

plot(current_climate_stack[[1]], 
     main = "Bio1 - Mean Annual Temp °C")

current_climate_stack[[1]] # Get the max and min values from the raster information

### --------------------------------
### Next curious about Bio4 - temperature seasonality
### --------------------------------

plot(current_climate_stack[[4]], 
     main = "Bio4 - Temperature Seasonality")

current_climate_stack[[4]] # Get the max and min values from the raster information

### --------------------------------
### Ok, just wanted to get a look at those two close up first. Now lets plot all 19 variables
### --------------------------------

plot(current_climate_stack[[1:16]])
plot(current_climate_stack[[17:19]])

### --------------------------------
### OK, now lets plot the subspecies locations on each bioclim variable
### --------------------------------

for (rast_ in 1:19) {
  
  plot(current_climate_stack[[rast_]])
  points(x = points_df$longitude,
         y = points_df$latitude,
         pch = points_df$subspecies)
  
}

### Lets make a ggplot that shows the state boundaries and sample locations on a bioclimate variable of our choice

### Load in US states shapefile

states_sf <- USAboundaries::us_states(resolution = "high") %>%
  st_transform(4326) %>%
  dplyr::filter(!state_abbr %in% c("AK", "HI", "PR", "GU", "VI", "MP", "AS"))

# Mask species range with statefile for plotting

states_vect <- terra::vect(states_sf) # Convert both sf files to terra vectors
plot(states_sf$geometry)

### Make ggplot with state boundaries and subspecies plotted

ggplot() +
  
  geom_sf(
    data = states_sf,
    fill = "papayawhip",
    color = "black",
    linewidth = 0.5
  ) +
  
  geom_tile(
    data = current_climate_stack[[1]],
    aes(x=longitude, 
        y=latitude)
  )

### --------------------------------
### Export Bioclim rasters as geoTIFF for QGIS
### --------------------------------

setwd("~/Library/CloudStorage/Box-Box/Taryn/01_MOLE_SKINK/Maps/QGIS/data/BioClim_rasters/")

for (i in 1:19) {
  name <- names(current_climate_stack[[i]])
  writeRaster(current_climate_stack[[i]], filename=paste0(name, ".tiff"))
}

