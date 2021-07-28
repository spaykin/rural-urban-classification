#### About ----
# This script merges Census population data with urban, rural, suburban ZCTA classification, and calculates population density and summary statistics for each category. 

#### Set up ----
library(tidyverse)
library(tidycensus)

##### Load Census data ----
census_api_key("4c645df575f0b945d20f4fd8d66f679017b08dca", install=TRUE)

# Explore variables
v18 <- load_variables(2018, "acs5", cache = TRUE)

# Get population table for ZCTAs
zcta_pop <- get_acs(geography = "zcta", 
                    variables = "B00001_001",
                    year = 2018)
# Clean data for merge
state <- substr(zcta_pop$GEOID, 1, 2)
ZCTA <- substr(zcta_pop$GEOID, 3, 7)
zcta_pop$zcta <- ZCTA

#### Merge with rurality dataset ----
zcta_pop.sf <- merge(usZ.sf, zcta_pop, by.x = "GEOID10", by.y = "zcta")

#### Rural stats ----
ruralpop <- zcta_pop.sf %>% filter(rurality == "Rural") %>% st_drop_geometry()

# Calculate population density
# Divide land area variable in sq meters by 2,589,988 for sq miles
ruralpop$land_sqmi <- (ruralpop$ALAND10 / 2589988)
ruralpop$density <- ruralpop$estimate / ruralpop$land_sqmi

summary(ruralpop$density)

#### Suburban stats ----
suburbanpop <- zcta_pop.sf %>% filter(rurality == "Suburban") %>% st_drop_geometry()
summary(suburbanpop$estimate)

# Calculate population density
# Divide land area variable in sq meters by 2,589,988 for sq miles
suburbanpop$land_sqmi <- (suburbanpop$ALAND10 / 2589988)
suburbanpop$density <- suburbanpop$estimate / suburbanpop$land_sqmi

summary(suburbanpop$density)

#### Urban stats -----
urbanpop <- zcta_pop.sf %>% filter(rurality == "Urban") %>% st_drop_geometry()
summary(urbanpop$estimate)    

# Calculate population density
# Divide land area variable in sq meters by 2,589,988 for sq miles
urbanpop$land_sqmi <- (urbanpop$ALAND10 / 2589988)
urbanpop$density <- urbanpop$estimate / urbanpop$land_sqmi

summary(urbanpop$density)
