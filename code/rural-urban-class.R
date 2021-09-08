#### About ----- 

# This script generates Census tract- and ZCTA-level rural/suburban/urban classification, based on the USDA & University of Washington RUCA Codes. 
# It also generates county-level percent rurality metrics.
# Based on original script developed by Moksha Menghaney for the Opioid Environment Policy Scan, October 2020. 

### Set up ----
library(xlsx)
library(openxlsx)
library(tidyverse)

setwd("~/git/rural-urban-classification")

#geometryFilesLoc <- './opioid-policy-scan/data_final/geometryFiles/'
#rawDataFilesLoc <- './opioid-policy-scan/data_raw/'
#outputFilesLoc <- './opioid-policy-scan/data_final/'

# Classifications finalized
urban <- c(1.0, 1.1)
suburban <- c(2.0, 2.1, 4.0, 4.1)
# everything else rural

### Census tracts ----

rucaTract <- openxlsx::read.xlsx(paste0('data_raw/RUCA2010revisedTract.xlsx'), 
                                 sheet = 1, startRow = 2, colNames = TRUE)

colnames(rucaTract) <- c('countyFIPS','State','County','tractFIPS','RUCA1',
                         'RUCA2','Pop_2010','Area_2010','PopDen_2010')

rucaTract$rurality <- ifelse(rucaTract$RUCA2 %in% urban, "Urban",
                             ifelse(rucaTract$RUCA2 %in% suburban, "Suburban", "Rural"))

rucaTract$rurality <- factor(rucaTract$rurality , levels= c('Urban','Suburban','Rural'))

write.csv(rucaTract %>% 
            select(tractFIPS, RUCA1, RUCA2, rurality) %>%
            mutate(RUCA1 = as.character(RUCA1),
                   RUCA2 = as.character(RUCA2)),
          paste0("data_final/UrbanSubRural_T.csv"), row.names = FALSE)

#### ZCTAs ----

rucaZipcode <- openxlsx::read.xlsx(paste0('data_raw/RUCA2010zipcode.xlsx'), 
                         sheet = 2, colNames = TRUE)

rucaZipcode$rurality <- ifelse(rucaZipcode$RUCA2 %in% urban, "Urban",
                               ifelse(rucaZipcode$RUCA2 %in% suburban, "Suburban", "Rural"))

rucaZipcode$rurality <- factor(rucaZipcode$rurality , levels= c('Urban','Suburban','Rural'))

rucaZipcode <- rucaZipcode %>% 
  mutate(RUCA1 = as.character(RUCA1),
         RUCA2 = as.character(RUCA2))

# Save final dataset
write.csv(rucaZipcode,paste0("data_final/UrbanSubRural_Z.csv"),
          row.names = FALSE)

### Counties - Percentage of Tracts ----

# Calculate percentage of Census tracts in county as rural, urban, suburban
rucaCountyRurality <- rucaTract %>% 
  select(countyFIPS, rurality) %>% 
  count(countyFIPS, rurality) %>% 
  group_by(countyFIPS) %>%
  mutate(pct = n / sum(n))

rucaCountyRurality <- pivot_wider(rucaCountyRurality,id_cols = 'countyFIPS', 
                                  names_from = 'rurality',
                                  values_from = 'pct', values_fill = 0) %>% 
  mutate(check = round(sum(Urban+Suburban+Rural),2))


# Check data, clean up
rucaCountyRurality[which(rucaCountyRurality$check !=1),]

rucaCountyRurality <- data.frame(rucaCountyRurality %>% 
                                   mutate(Urban = round(Urban,2),
                                          Suburban = round(Suburban,2),
                                          Rural = round(Rural,2)) %>%
                                   rename(GEOID = countyFIPS,
                                          UrbP = Urban,
                                          SubrbP = Suburban,
                                          RuralP = Rural))

# Save final dataset - percentage of tracts in county classified as R, S, U
write.csv(rucaCountyRurality %>% select(-check), 
          paste0("data_final/UrbanRuralSuburban_C.csv"), 
          row.names = FALSE)
