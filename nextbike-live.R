# Analyze nextbike data
# Taras Motulski, 20017-01-08 
# Part 1 - Load xml-files into dataframe

library(xml2)
library(dplyr)
require(plyr)
require(dtplyr)
require(dostats)
library(splitstackshape)

setwd("c:/Projects/Carsharing/nextbike-live/transform")
file.remove("init_df.csv")

files <- list.files(pattern = ".xml")

#init df
init_df <- data.frame(
  #num = numeric(0),
  datetime = character(0),
  country = character(0),
  country_company = character(0),
  city = character(0),
  name = character(0),
  latitude=numeric(0),
  longitude=numeric(0),
  bike_number = character(0) 
) 

write.table(init_df, "init_df.csv", col.names=TRUE, row.names = FALSE, sep=",")

#Load every xml file in folder in loop
for (fileCount in seq_along(files)) {
  
  filename <- files[fileCount]
  
  #print progress
  print(paste(fileCount," -- ",filename))
  
  data <- read_xml(filename)

  # City locations
  tmp_all_places2 <- data %>% xml_find_all(".//place[@bike_numbers != '']")
  
  init_df <- data.frame(
    #num = NA,
    datetime = as.character(strptime(filename, "%Y-%m-%dT%H_%M_%S")),
    country = xml_attr(tmp_all_places2, "country"),
    country_company = xml_attr(tmp_all_places2, "country_company"),
    city = xml_attr(tmp_all_places2, "city"),
    name = xml_attr(tmp_all_places2, "place"),
    latitude=xml_attr(tmp_all_places2, "lat"),
    longitude=xml_attr(tmp_all_places2, "lng"),
    bike_number = xml_attr(tmp_all_places2, "bike_numbers")
  )  
  
  #split & transform datatype
  init_df <- cSplit(init_df, "bike_number", ",", "long")
  
  write.table(init_df, "init_df.csv", col.names=FALSE, row.names = FALSE, sep=",", append=TRUE)
  
}

##############################################3
# Group and analyze
##############################################

full_df <- read.csv("init_df.csv",header=TRUE,row.names=NULL)
full_df[is.na(full_df$name)] <- 'Unknown place'
full_df$datetime <- as.POSIXct(full_df$datetime)

#full_df <- unique(full_df)
#full_df <- na.omit(full_df)
#full_df <- full_df[1:100000,]

full_group_df <- data.frame(
  country = full_df$country, 
  country_company = full_df$country_company, 
  city = full_df$city, 
  bike_number = full_df$bike_number)

full_group_df <- unique(full_group_df)

bikeGroupCount <- nrow(full_group_df)

full_interval <- data.frame()
full_route <- data.frame()

for (ii in 1:bikeGroupCount) {
  
  print(paste("Bike #", ii, " of ", bikeGroupCount))
  
  bike_data <- data.frame()
  bike_data <- full_df[(full_df$country == full_group_df$country[ii] &
                          full_df$country_company == full_group_df$country_company[ii] &
                          full_df$city == full_group_df$city[ii] &
                          full_df$bike_number == full_group_df$bike_number[ii]),]
  bike_data <- bike_data[order(bike_data$datetime),]
  
  bike_interval <- data.frame()
  
  bikeRCount <- nrow(bike_data)
  
  #loop bikes
  for (i in 1:bikeRCount) {
    
    if (i == 1) {
      #first row
      bike_interval <- data.frame(
        start_datetime = bike_data$datetime[i],
        end_datetime = as.POSIXct(NA),
        country = bike_data$country[i],
        country_company = bike_data$country_company[i],
        city = bike_data$city[i],
        name = bike_data$name[i],
        latitude = bike_data$latitude[i],
        longitude = bike_data$longitude[i],
        bike_number = bike_data$bike_number[i],
        activity = "Parking" )
      
    } 
    
    if (i == bikeRCount) {
      #last row to close interval
      bike_interval[nrow(bike_interval),2] <- bike_data$datetime[i]
      
    } else  {
      
      #most cases
      
      #different places
      if (bike_data$latitude[i] != bike_data$latitude[i+1] & 
          bike_data$longitude[i] != bike_data$longitude[i+1]) {
        
        #close current period of parking        
        bike_interval[nrow(bike_interval), 2] <- bike_data$datetime[i]
        
        #add record about bike`s relocation
        bike_interval <- rbind(bike_interval, data.frame(
          start_datetime = bike_data$datetime[i],
          end_datetime = bike_data$datetime[i+1],
          country = bike_data$country[i],
          country_company = bike_data$country_company[i],
          city = bike_data$city[i],
          name = paste(bike_data$name[i]," -> ",bike_data$name[i+1]),
          latitude = bike_data$latitude[i],
          longitude = bike_data$longitude[i],
          bike_number = bike_data$bike_number[i],
          activity = "Moving" ))
        
        #add record about new parking location
        bike_interval <- rbind(bike_interval, data.frame(
          start_datetime = bike_data$datetime[i+1],
          end_datetime = as.POSIXct(NA),
          country = bike_data$country[i],
          country_company = bike_data$country_company[i],
          city = bike_data$city[i+1],
          name = bike_data$name[i+1],
          latitude = bike_data$latitude[i+1],
          longitude = bike_data$longitude[i+1],
          bike_number = bike_data$bike_number[i+1],
          activity = "Parking" ))
        
      } else {
        
        #same place
        #close current`s bike period
        bike_interval[nrow(bike_interval), 2] <- bike_data$datetime[i]
        
      }  
    }
  }
  
  # bike_route <- data.frame()
  # if (nrow(bike_interval) > 1) {
  #   for (i3 in 1:(nrow(bike_interval)-1)) {
  #     
  #         bike_route <- rbind (bike_route, data.frame(
  #           city = bike_interval$city[i3],
  #           bike_number = bike_interval$bike_number[i3],
  #           start_time = bike_interval$end_datetime[i3],
  #           end_time = bike_interval$start_datetime[i3+1],
  #           route = paste(bike_interval$name[i3]," -> ",bike_interval$name[i3+1]),
  #           activity = "Moving"))  
  #   }
  # }
  
  full_interval <- rbind (full_interval, bike_interval)
  
}

full_interval <- cbind(full_interval, period_min = difftime(full_interval$end_datetime, full_interval$start_datetime,units="mins"))
full_route <- full_interval[full_interval$activity == 'Moving',]

write.csv(full_interval, file = "full_interval.csv")


# test_bike_number = 8592
# test_df <- full_df[full_df$bike_number == test_bike_number,]
# test_interval <- bike_interval[bike_interval$bike_number == test_bike_number,]
# test_route <- bike_route[bike_route$bike_number == test_bike_number,]

##############################################3
# Calculate possible income
##############################################

total_df <- data.frame()
total_df <- full_route[full_route$period_min <= 24*60,]

total_df <- cbind(total_df, trip_cost = 0)
total_df$trip_cost <- ifelse(total_df$period_min<=30, 1, 9) # 30 min = 1 euro, 24h = 9 euro

total_income_sum <- sum(total_df$trip_cost, na.rm = TRUE)
total_bike_count <- length(unique(full_route$bike_number))
total_start_date <- range(full_route$start_datetime,na.rm=TRUE)
total_end_date <- range(full_route$end_datetime,na.rm=TRUE)
mean(full_route$period_min)
total_income_by_bike <- total_income_sum / total_bike_count

summary(total_df)
