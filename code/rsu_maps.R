#### About ----

# This code prepares data and generates maps for Census tracts and ZCTAs by their RUCA code classification. 

#### Set up ----

library(tmap)
library(sf)
library(tidyverse)

setwd("~/git/rural-urban-classification")

#### Projections -----

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


#### Tract Maps ----

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

# Color scheme
# rural, suburban, urban
rural.cols <- c("#c7eae5", "#5ab4ac", "#01665e")

# Map & show missing tracts
tract_map2 <-
  tm_shape(usT.sf2) +
  tm_fill(col = "rurality", palette = rural.cols, colorNA = "black",
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, main.title = "Census Tracts by Rural, Suburban, Urban Classification")
tmap_save(tract_map_missing, "figs/tract_map_missing.png")

# Redo sf merge, but keep all variables in rucaT 
rucaT.sf2 <- merge(tracts.sf, rucaT, by.x = "GEOID", by.y = "tractFIPS", all = TRUE)
usT.sf2 <- rucaT.sf2 %>% filter(!STATEFP %in% c("02", "15")) %>%
  st_transform(crs)

# Update dataset to include all GEOIDs
rucaT.sf_all <- rucaT.sf2
rucaT.sf_all$rurality <- ifelse(is.na(rucaT.sf2$rurality), "Rural", rucaT.sf2$rurality)

# New tract datasets - use these

# Alaska tracts
alaskaT.sf <- rucaT.sf_all %>% filter(STATEFP == "02") %>%
  st_transform(crs_alaska)

# Hawaii tracts
hawaiiT.sf <- rucaT.sf_all %>% filter(STATEFP == "15") %>%
  st_transform(crs_hawaii)

# Continental US tracts
usT.sf_all <- rucaT.sf_all %>% filter(!STATEFP %in% c("02", "15")) %>%
  st_transform(crs)

# Map
alaskaT_map <-
  tm_shape(alaskaT.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(alaska.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)

hawaiiT_map <-
  tm_shape(hawaiiT.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(hawaii.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, 
            legend.title.size = 1.5,
            legend.text.size = 1)

# US Tract Map
tract_map_notitle <-
  tm_shape(usT.sf_all) +
  tm_fill(col = "rurality", palette = rural.cols, colorNA = "#c7eae5", showNA = FALSE,
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE,
            legend.title.size = 1.5,
            legend.text.size = 1)
tmap_save(tract_map_notitle, "figs/tract_map_notitle.png")

# No legend
tract_map_all_nolegend <-
  tm_shape(usT.sf_all) +
  tm_fill(col = "rurality", palette = rural.cols, colorNA = "#c7eae5", showNA = FALSE,
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)

tmap_save(tract_map_all_nolegend, "figs/tract_map_nolegend.png")


#### Disaggregated Tract Maps - Urban, Rural, Suburban -----

# Color scheme
# rural, suburban, urban
rural.cols <- c("#c7eae5", "#5ab4ac", "#01665e")

# Rural map
rural <- usT.sf_all %>% filter(rurality == "Rural")

rural_map <- 
  tm_shape(rural) +
  tm_fill(col = "rurality", palette = "#c7eae5",
        title = "") +
  tm_shape(usT.sf_all) + tm_borders(alpha = 0.3, lwd = 0.1) +
  tm_shape(states48.sf) +
  tm_borders(alpha = 1, lwd = 0.6) +
  tm_layout(frame = FALSE,
            legend.show = FALSE)

tmap_save(rural_map, "figs/rural_map.png")

# Suburban map
suburban <- usT.sf_all %>% filter(rurality == "Suburban") 

suburban_map <- 
  tm_shape(suburban) +
  tm_fill(col = "rurality", palette = "#5ab4ac",
          title = "") +
  tm_shape(usT.sf_all) + tm_borders(alpha = 0.3, lwd = 0.1) +
  tm_shape(states48.sf) +
  tm_borders(alpha = 1, lwd = 0.6) +
  tm_layout(frame = FALSE,
            legend.show = FALSE)

tmap_save(suburban_map, "figs/suburban_map.png")

# Urban map
urban <- usT.sf_all %>% filter(rurality == "Urban")

urban_map <- 
tm_shape(urban) +
  tm_fill(col = "rurality", palette = "#01665e",
          title = "") +
  tm_shape(usT.sf_all) + tm_borders(alpha = 0.3, lwd = 0.1) +
  tm_shape(states48.sf) +
  tm_borders(alpha = 1, lwd = 0.6) +
  tm_layout(frame = FALSE,
            legend.show = FALSE)

tmap_save(urban_map, "figs/urban_map.png")


#### ZCTA Maps ----

# Load data
rucaZ <- read.csv("data_final/RuralSubUrban_Z.csv")
rucaZ$ZIP_CODE <- sprintf("%05s", as.character(rucaZ$ZIP_CODE))

# Merge with geometry
rucaZ.sf <- merge(zips.sf, rucaZ, by.x = "ZCTA5CE10", by.y = "ZIP_CODE")
rucaZ.sf <- st_transform(rucaZ.sf, crs)

# Alaksa zip codes
alaskaZ.sf <- rucaZ.sf %>% filter(STATE == "AK") %>% 
  st_transform(crs_alaska) 

# Hawaii zip codes
hawaiiZ.sf <- rucaZ.sf %>% filter(STATE == "HI") %>% 
  st_transform(crs_hawaii) 

# Continental US zip codes
usZ.sf <- rucaZ.sf %>% filter(!STATE %in% c("AK", "HI")) %>%
  st_transform(crs)

# ZCTA Map

# Color scheme
# rural, suburban, urban
rural.cols <- c("#c7eae5", "#5ab4ac", "#01665e")

ZCTA_map <-
  tm_shape(usZ.sf) +
  tm_fill(col = "rurality", palette = rural.cols,
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, main.title = "ZCTAs by Rural, Suburban, Urban Classification")
tmap_save(ZCTA_map, "figs/zcta_map.png")

ZCTA_map_notitle <- 
  tm_shape(usZ.sf) +
  tm_fill(col = "rurality", palette = rural.cols,
          title = "Classification") +
  tm_shape(states48.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE,
            legend.title.size = 1.5,
            legend.text.size = 1)
tmap_save(ZCTA_map_notitle, "figs/zcta_map_notitle.png")

alaskaZ_map <-
  tm_shape(alaskaZ.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(alaska.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)

hawaiiZ_map <-
  tm_shape(hawaiiZ.sf) +
  tm_fill(col = "rurality", palette = rural.cols) +
  tm_shape(hawaii.sf) +
  tm_borders(alpha = 0.7, lwd = 0.5) +
  tm_layout(frame = FALSE, legend.show = FALSE)

#### Disaggregated ZCTA Maps - Urban, Rural, Suburban -----

# Color scheme
# rural, suburban, urban
#rural.cols <- c("#c7eae5", "#5ab4ac", "#01665e")

# Rural map
ruralZ <- usZ.sf %>% filter(rurality == "Rural")

ruralZ_map <- 
  tm_shape(ruralZ) +
  tm_fill(col = "rurality", palette = "#c7eae5",
          title = "") +
  tm_shape(usZ.sf) + tm_borders(alpha = 0.3, lwd = 0.1) +
  tm_shape(states48.sf) +
  tm_borders(alpha = 1, lwd = 0.6) +
  tm_layout(frame = FALSE,
            legend.show = FALSE)

tmap_save(ruralZ_map, "figs/ruralZ_map.png")

# Suburban map
suburbanZ <- usZ.sf %>% filter(rurality == "Suburban") 

suburbanZ_map <- 
  tm_shape(suburbanZ) +
  tm_fill(col = "rurality", palette = "#5ab4ac",
          title = "") +
  tm_shape(usZ.sf) + tm_borders(alpha = 0.3, lwd = 0.1) +
  tm_shape(states48.sf) +
  tm_borders(alpha = 1, lwd = 0.6) +
  tm_layout(frame = FALSE,
            legend.show = FALSE)

tmap_save(suburbanZ_map, "figs/suburbanZ_map.png")

# Urban map
urbanZ <- usZ.sf %>% filter(rurality == "Urban")

urbanZ_map <- 
  tm_shape(urbanZ) +
  tm_fill(col = "rurality", palette = "#01665e",
          title = "") +
  tm_shape(usZ.sf) + tm_borders(alpha = 0.3, lwd = 0.1) +
  tm_shape(states48.sf) +
  tm_borders(alpha = 1, lwd = 0.6) +
  tm_layout(frame = FALSE,
            legend.show = FALSE)

tmap_save(urbanZ_map, "figs/urbanZ_map.png")
