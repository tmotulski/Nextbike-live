# Analyze nextbike data
# Taras Motulski, 20017-01-08 
# Part 1 - Load xml-files into dataframe

library(xml2)
library(dplyr)
require(plyr)
require(dostats)

setwd("d:/projects/carsharing/datasets/nextbike-mvgrad/")
file.remove("init_df.csv")

files <- list.files(pattern = ".xml")

  #init df
  init_df <- data.frame(
    num = numeric(0),
    filename = character(0),
    city = character(0),
    point_name = character(0),
    latitude = numeric(0),
    longitude = numeric(0),
    bike_numbers = character(0)
  ) 
  
  write.table(init_df, "init_df.csv", col.names=TRUE, sep=",")

#Load every xml file in folder in loop
for (fileCount in seq_along(files)) {
  
  filename <- files[fileCount]
  
  #print progress
  print(paste(fileCount," -- ",filename))

  data <- read_xml(filename)

  init_df <- data.frame(
    filename = character(0),
    city = character(0),
    point_name = character(0),
    latitude = numeric(0),
    longitude = numeric(0),
    bike_numbers = character(0)
  ) 
  
  # City locations
  tmp_city_df <- data %>% xml_find_all(".//country/city")
  totalCityCount <- length(xml_attr(tmp_city_df, "name"))
  
  for (cityCount in 1:totalCityCount) {  
    # Point locations
    city_df <- data %>% xml_find_all(paste(".//country/city[",cityCount,"]"))
    city = xml_attr(city_df, "name")
    place <- xml_children(city_df)
    
    init_df <- rbind(init_df,data.frame(
      filename = filename,
      city = city,
      name = iconv(xml_attr(place, "name"), from = "UTF-8", to = "latin1"),
      latitude=xml_attr(place, "lat"),
      longitude=xml_attr(place, "lng"),
      bike_numbers = xml_attr(place, "bike_numbers")
      ))    
    
    }

  write.table(init_df, "init_df.csv", col.names=FALSE, sep=",", append=TRUE)
}