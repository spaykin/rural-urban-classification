# Rural, Suburban, Urban Classification for Small-Area Analyses

## About
This repository includes the data, methods and code used in developing the classification scheme for Census tracts and zip codes as rural, urban, or suburban, based on USDA RUCA Codes. 

For more information, please read our [Research Brief](https://docs.google.com/document/d/1wwNT77aKOz-v-l6sYpEuEqoAvrXFDqdZq4VYwXJnUMA/edit#heading=h.mbjsiz6n6jlo) [draft].

| Census Tracts | Zip Codes |
|:------------------ | :------------- |
![image](https://user-images.githubusercontent.com/49726781/132532713-db437f9f-bcb1-49a4-9665-9fed8a85a0bd.png) | ![image](https://user-images.githubusercontent.com/49726781/132532759-81d64a81-4ac6-423b-a9b9-6e2e3f93a061.png) |


## Folder structure

**data_final**:
* RuralSubUrban_T.csv: Census tract rural/suburban/urban classification data
* RuralSubUrban_Z.csv: Zip code rural/suburban/urban classification data

| Variable | Description |
|:------------------ | :------------- |
| tractFIPS | Unique 11-digit FIPS code for Census tracts |
| zip_code | Unique 5-digit zip code |
|rurality| Assigned rurality (Urban, Suburban, Rural) based on classification
| RUCA1 | Original primary RUCA Code | 
| RUCA2 | Original full (secondary) RUCA Code |

* RuralSubUrban_C.csv: County percent rurality data  

This dataset reports the percentage of Census tract in each county classified as rural, suburban, or urban. 

| Variable | Description |
|:------------------ | :------------- |
| GEOID | Unique 5-digit FIPS code for counties |
| UrbP | Percentage of tracts classified as urban |
| SubrbP | Percentage of tracts classified as suburban |
| RuralP | Percentage of tracts classified as rural |

**data_raw**:
* geometryFiles: Includes county, zip, and Census tract shapefiles from the [Census Bureau TIGER/Line files](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html) (2018). Also includes the [HUD-USPS tract-zip crosswalk](https://www.huduser.gov/portal/datasets/usps_crosswalk.html) (2020) 
* RUCA2010 csv files: RUCA Code data from [USDA ERS](https://www.ers.usda.gov/data-products/rural-urban-commuting-area-codes.aspx) (tract) and [University of Washington](https://depts.washington.edu/uwruca/ruca-approx.php) (zip). 

**code**: 
* rsu_maps.r: Script that prepares data and generates maps for tracts and ZCTAs by their rural/suburban/urban classification. 
* zcta_pop.r: Script that merges tract population data with urban, rural, suburban ZCTA classification, and calculates population density and summary statistics for each category.
* Script that generates Census tract- and ZCTA-level rural/suburban/urban classification, based on the USDA & University of Washington RUCA codes. Also generates county-level percent rurality metrics.


## Acknowledgements

Susan Paykin (co), Moksha Menghaney (co), Marynia Kolak, and Qinyun Lin (2021). Research Brief: Rural, Suburban, Urban Classification for Small-Area Analysis. Healthy Regions & Policies Lab, Center for Spatial Data Science, University of Chicago. 

The authors gratefully acknowledge the contributions of Luc Anselin, PhD and Julia Koschinsky, PhD of the Center for Spatial Data Science, University of Chicago.

*This research was supported in part by the Robert Wood Johnson Foundation (RWJF). It was also supported by the National Institute on Drug Abuse, National Institutes of Health, through the NIH HEAL Initiative under award number UG3DA123456. The contents of this publication are solely the responsibility of the authors and do not necessarily represent the official views of the NIH, the Initiative, or the participating sites.*
