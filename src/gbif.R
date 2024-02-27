#gbif.R
#query species occurrence data from GBIF
#clean up the data
#save it as a csv file
#create a map to display the species occurrence points

#list of packages
packages<-c("tidyverse", "rgbif", "usethis", "CoordinateCleaner", "leaflet", "mapview")

#install packages not yet installed
installed_packages<-packages %in% rownames(installed.packages())
if(any(installed_packages==FALSE)){
  install.packages(packages[!installed_packages])
}

#packages loading, with library function
invisible(lapply(packages, library, character.only=TRUE))

usethis::edit_r_environ()

spiderBackbone<-name_backbone(name="Habronattus americanus")
speciesKey<-spiderBackbone$usageKey

occ_download(pred("taxonKey", speciesKey), format="SIMPLE_CSV")

View(spiderBackbone)

d <- occ_download_get('0012232-240202131308920', path="data/") %>%
  occ_download_import()

View(d)
write_csv(d, "data/rawData.csv")

#cleaning

fData<-d %>%
  filter(!is.na(decimalLatitude), !is.na(decimalLongitude))

fData<-fData %>%
  filter(countryCode %in% c("US", "CA", "MX"))

fData<-fData %>%
  filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN"))

fData<-fData %>%
  cc_sea(lon="decimalLongitude", lat="decimalLatitude")

fData<-fData %>%
  distinct(decimalLongitude, decimalLatitude, speciesKey, datasetKey, .keep_all=TRUE)

#to do it on one step
#cleanData<-d %>%
 # filter(!is.na(decimalLatitude), !is.na(decimalLongitude))
#filter(countryCode %in% c("US", "CA", "MX"))
#filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN"))
#cc_sea(lon="decimalLongitude", lat="decimalLatitude")
#distinct(decimalLongitude, decimalLatitude, speciesKey, datasetKey, .keep_all=TRUE)

write.csv(fData, "data/cleanedData.csv")


