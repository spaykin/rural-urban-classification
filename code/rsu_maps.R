#### About ----

# This code prepares data for mapping Census tracts and ZCTAs by their RUCA code classification. 

#### Set up ----

library(tmap)
library(sf)
library(tidyverse)

setwd("~/git/rural-urban-classification")

# # Help function to move geometries 
# place_geometry = function(geometry, bb, scale_x, scale_y,
#                           scale_size = 1) {
#   output_geometry = (geometry - st_centroid(geometry)) * scale_size +
#     st_sfc(st_point(c(
#       bb$xmin + scale_x * (bb$xmax - bb$xmin),
#       bb$ymin + scale_y * (bb$ymax - bb$ymin)
#     )))
#   return(output_geometry)
# }

#### Projections and CRS -----

# Set CRS, lower 48 - EPSG 102003 USA_Contiguous_Albers_Equal_Area_Conic
crs <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
# Alaska, EPSG:3338 https://epsg.io/3338
crs_alaska = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs "
# Hawaii, ESRI:102007 https://epsg.io/102007
crs_hawaii = "+proj=aea +lat_1=8 +lat_2=18 +lat_0=13 +lon_0=-157 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

#### Load geometries -----

# ZCTA geometry files
zips.sf <- st_read("data_raw/geometryFiles/tl_2018_zcta/zctas2018.shp") %>%
  st_transform(crs)
# Tract geometry files
tracts.sf <- st_read("data_raw/geometryFiles/tl_2018_tract/") %>%
  st_transform(crs)
# States geometry files
states.sf <- st_read("data_raw/geometryFiles/tl_2018_state/") %>%
  st_transform(crs)

# Broken down state geometries
states48.sf <- states.sf %>%
  filter(!STATEFP %in% c("02", "15"))
# Alaska map
alaska.sf <- states.sf %>% filter(STATEFP == "02") %>% st_transform(crs_alaska)
# Hawaii map
hawaii.sf <- states.sf %>% filter(STATEFP == "15") %>% st_transform(crs_hawaii)


#### Tract Map ----

# Load data
rucaT <- read.csv("data_final/UrbanSubRural_T.csv")
rucaT$tractFIPS <- sprintf("%011s", as.character(rucaT$tractFIPS))

# Merge with geometry
rucaT.sf <- merge(tracts.sf, rucaT, by.x = "GEOID", by.y = "tractFIPS")
rucaT.sf <- st_transform(rucaT.sf, crs)
str(rucaT.sf)

# Alaska tracts
alaskaT.sf <- rucaT.sf %>% filter(STATEFP == "02") %>%
  st_transform(crs_alaska)

# Hawaii tracts
hawaiiT.sf <- rucaT.sf %>% filter(STATEFP == "15") %>%
  st_transform(crs_hawaii)

# Continental US tracts
usT.sf <- rucaT.sf %>% filter(!STATEFP %in% c("02", "15")) %>%
  st_transform(crs)

# Tract Map

# Create color scheme option
# rural, suburban, urban
rural.cols <- c("#c7eae5", "#5ab4ac", "#01665e")

tract_map <-
  tm_shape(usT.sf2) +
  tm_fill(col = "rurality", palette = rural.cols, colorNA = "#c7eae5",
          title = "Classification", showNA = FALSE) +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, main.title = "Census Tracts by Rural, Suburban, Urban Classification")

alaskaT_map <-
  tm_shape(alaskaT.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(alaska.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)
alaskaT_map

hawaiiT_map <-
  tm_shape(hawaiiT.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(hawaii.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)
hawaiiT_map

# Save final maps
tmap_save(tract_map, "figs/tract_map.png")
tmap_save(alaskaT_map, "figs/alaskaT_map.png")
tmap_save(hawaiiT_map, "figs/hawaiiT_map.png")

# Troubleshoot - identify missing SD tract?
# SD has 222 census tracts
sd <- tracts.sf %>% filter(STATEFP == "46") #222
sd_r <- rucaT %>% filter(str_detect(tractFIPS, "^46")) #222
sd_r2 <- rucaT.sf %>% filter(str_detect(GEOID, "^46")) #219
sd_r3 <- usT.sf %>% filter(str_detect(GEOID, "^46")) #219

# What is in orig rucaT, but missing from the sf merge
missing <- data.frame(rucaT$tractFIPS[!(rucaT$tractFIPS %in% rucaT.sf$GEOID)])
missingList <- rucaT$tractFIPS[!(rucaT$tractFIPS %in% rucaT.sf$GEOID)]
missingSD <- missing %>% filter(str_detect(rucaT.tractFIPS...rucaT.tractFIPS..in..rucaT.sf.GEOID.., "^46"))
# 3 observations from WY - 46113940500, 46113940800, 46113940900
# When do the sf merge, want to keep all variables in y
rucaT.sf2 <- merge(tracts.sf, rucaT, by.x = "GEOID", by.y = "tractFIPS", all = TRUE)
usT.sf2 <- rucaT.sf2 %>% filter(!STATEFP %in% c("02", "15")) %>%
  st_transform(crs)

# Update dataset to include all GEOIDs, coded as rural
rucaT.sf_all <- rucaT.sf2
rucaT.sf_all$rurality <- ifelse(rucaT.sf2$GEOID %in% missingList, "Rural", rucaT.sf2$rurality)
# Check 
missingAll <- rucaT$tractFIPS[!(rucaT$tractFIPS %in% rucaT.sf_all$GEOID)]

# Alaska tracts
alaskaT.sf <- rucaT.sf_all %>% filter(STATEFP == "02") %>%
  st_transform(crs_alaska)

# Hawaii tracts
hawaiiT.sf <- rucaT.sf_all %>% filter(STATEFP == "15") %>%
  st_transform(crs_hawaii)

# Continental US tracts
usT.sf_all <- rucaT.sf_all %>% filter(!STATEFP %in% c("02", "15")) %>%
  st_transform(crs)

alaskaT_map <-
  tm_shape(alaskaT.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(alaska.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)
alaskaT_map

hawaiiT_map <-
  tm_shape(hawaiiT.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(hawaii.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)
hawaiiT_map

tract_map_all <-
  tm_shape(usT.sf_all) +
  tm_fill(col = "rurality", palette = rural.cols, colorNA = "black",
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, main.title = "Census Tracts by Rural, Suburban, Urban Classification")

tmap_save(tract_map_all, "figs/tract_map.png")
                       


tract_map2 <-
  tm_shape(usT.sf2) +
  tm_fill(col = "rurality", palette = rural.cols, colorNA = "black",
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, main.title = "Census Tracts by Rural, Suburban, Urban Classification")
tmap_save(tract_map_missing, "figs/tract_map_missing.png")

#### ZCTA Map ----

# Load data
rucaZ <- read.csv("data_final/UrbanSubRural_Z.csv")
rucaZ$ZIP_CODE <- sprintf("%05s", as.character(rucaZ$ZIP_CODE))

# Merge with geometry
rucaZ.sf <- merge(zips.sf, rucaZ, by.x = "ZCTA5CE10", by.y = "ZIP_CODE")
rucaZ.sf <- st_transform(rucaZ.sf, crs)

# Alaksa zip codes
alaskaZ.sf <- rucaZ.sf %>% filter(STATE == "AK") %>% 
  st_transform(crs_alaska) 
# %>%
#   mutate(geometry = place_geometry(geometry, st_bbox(rucaZ.sf), 0.6, 1.35)) %>% 
#   st_set_crs(crs)

# Hawaii zip codes
hawaiiZ.sf <- rucaZ.sf %>% filter(STATE == "HI") %>% 
  st_transform(crs_hawaii) 
# %>%
#   mutate(geometry = place_geometry(geometry, st_bbox(rucaZ.sf), 0.2, 0.1)) %>% 
#   st_set_crs(crs)

# Continental US zip codes
usZ.sf <- rucaZ.sf %>% filter(!STATE %in% c("AK", "HI")) %>%
  st_transform(crs)

# # Combine data
# us_albers_alt <- rbind(usZ.sf, alaskaZ.sf, hawaiiZ.sf)

# ZCTA Map

# Create color scheme option
# rural, suburban, urban
rural.cols <- c("#c7eae5", "#5ab4ac", "#01665e")

ZCTA_map <-
  tm_shape(usZ.sf) +
  tm_fill(col = "rurality", palette = rural.cols,
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, main.title = "ZCTAs by Rural, Suburban, Urban Classification")

alaskaZ_map <-
  tm_shape(alaskaZ.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(alaska.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)
alaskaZ_map

hawaiiZ_map <-
  tm_shape(hawaiiZ.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(hawaii.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)
hawaiiZ_map

tmap_save(ZCTA_map, "figs/ZCTA_map.png")
tmap_save(alaskaZ_map, "figs/alaskaZCTA_map.png")
tmap_save(hawaiiZ_map, "figs/hawaiiZCTA_map.png")

rucaT.sf %>% filter(!rurality %in% c("Rural", "Suburban", "Urban"))

which(is.na(usZ.sf$rurality))
