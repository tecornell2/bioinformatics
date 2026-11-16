#install.packages("devtools")
#install_github("dipetkov/reemsplots2")

#install.packages("rworldmap")

library("terra")
library("raster")
library("devtools")
library("sf")
library("devtools")
library("reemsplots2")
library("ggplot2")
library("rworldmap")    # Add a geographic map
library("broom")        # Required for the map
library("RColorBrewer") # Change the color scheme

mcmcpath <- "C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Analyses/EEMS/output/run4/nDemes500_mcmcpath"
plots <- make_eems_plots(mcmcpath, longlat = TRUE, add_demes = TRUE)
#> Joining, by = "id"
#> Generate effective migration surface (posterior mean of m rates). See plots$mrates01 and plots$mrates02.
#> Generate effective diversity surface (posterior mean of q rates). See plots$qrates01 and plots$qrates02.
#> Generate average dissimilarities within and between demes. See plots$rdist01, plots$rdist02 and plots$rdist03.
#> Generate posterior probability trace. See plots$pilog01.

names(plots)

# change color scheme
#plots <- make_eems_plots(mcmcpath, longlat = TRUE,
#                       eems_colors = brewer.pal(11, "RdBu"))
plots$mrates01
plots$qrates02
plots$rdist01
plots$rdist03
plots$pilogl01


# 2. Extract the specific plot you want to edit
plot1 <- plots$mrates01
plot1

# load in map (shapefile)
shape.data <- sf::st_read("C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Maps/QGIS/land_bounds_layers/USA-shp/s_18mr25.shp")

# clip the shape file to the EEMS bounds

bbox <- st_bbox(c(
  xmin = -89.03913,
  xmax = -79.02857,
  ymin = 23.44937,
  ymax = 34.78893
), crs = st_crs(shape.data))

clip_box <- st_as_sfc(bbox)

sf::sf_use_s2(FALSE)

shape.clip <- st_intersection(shape.data, clip_box)

sf::sf_use_s2(TRUE)

# 3. Apply ggplot2 functions to edit labels, themes, and titles

final_plot1 <- plot1 +
  geom_sf(data = shape.clip,
          fill = NA,
          color = "black",
          linewidth = 0.3,
          inherit.aes = FALSE) 
  #xlab("Longitude") +
  #ylab("Latitude") + themebw()

final_plot1 

# Export .tiff to create map in QGIS
setwd("C:/Users/tecor/Box/Taryn/01_MOLE_SKINK/Analyses/EEMS/output")
#ggsave(
#  "reems_nDemes300.tiff",
#  plot = plot1,
#  device = "tiff",
#  width = 8,
#  height = 6,
#  units = "in",
#  dpi = 300
#)

