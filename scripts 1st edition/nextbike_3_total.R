# Analyze nextbike data
# Taras Motulski, 20017-01-08 
# Part 3 - Create routes

#setwd("d:/projects/carsharing/datasets/nextbike-mvgrad")
#full_df = read.csv("full_df.csv")

bike_interval <- data.frame()

bike_interval <- data.frame(
  start_datetime = full_df$datetime[1],
  end_datetime = full_df$datetime[1],
  city = full_df$city[1],
  name = full_df$point_name[1],
  latitude = full_df$latitude[1],
  longitude = full_df$longitude[1],
  bike_number = full_df$bike_numbers[1])

bike_interval[bike_interval$end_datetime == full_df$datetime[1],2] <- NA

for (i in 1:(nrow(full_df)-1)) {

  print(i)
  #separate bikes
  if (full_df$bike_numbers[i] == full_df$bike_numbers[i+1]) {
    
    #debug
    #test_df <- rbind(test_df, data.frame(full_df$bike_number[i], full_df$bike_number[i+1], result = "pass"))
    #print(full_df$bike_number[i])
  
    if (full_df$latitude[i] != full_df$latitude[i+1] && 
      full_df$longitude[i] != full_df$longitude[i+1]) {
    
      bike_interval[is.na(bike_interval$end_datetime),2] <- as.POSIXct(full_df$datetime[i])
      
      bike_interval <- rbind(bike_interval, data.frame(
        start_datetime = full_df$datetime[i+1],
        end_datetime = NA,
        city = full_df$city[i+1],
        name = full_df$point_name[i+1],
        latitude = full_df$latitude[i+1],
        longitude = full_df$longitude[i+1],
        bike_number = full_df$bike_numbers[i+1]))
      }
  
  } else {

      #close current`s bike period
      bike_interval[is.na(bike_interval$end_datetime),2] <- as.POSIXct(full_df$datetime[i])
      
      #create new record for new bike
      bike_interval <- rbind(bike_interval, data.frame(
        start_datetime = full_df$datetime[i+1],
        end_datetime = NA,
        city = full_df$city[i+1],
        name = full_df$point_name[i+1],
        latitude = full_df$latitude[i+1],
        longitude = full_df$longitude[i+1],
        bike_number = full_df$bike_numbers[i+1]))

      }  
}

bike_interval <- cbind(bike_interval, period_min = difftime(bike_interval$end_datetime, bike_interval$start_datetime,units="mins"))
write.csv(bike_interval, file = "bike_interval.csv")


#calculate routes
#
bike_route <- data.frame(
  city = character(0),
  bike_number = character(0),
  period = character(0),
  start_time = character(0),
  end_time = character(0),
  activity = character(0),
  trip_time_min = numeric(0))

for (i in 1:(nrow(bike_interval)-1)) {
  
  if (bike_interval$bike_number[i] == bike_interval$bike_number[i+1]) {
    
    print(i)
    
    bike_route <- rbind(bike_route, data.frame(
      city = bike_interval$city[i],
      bike_number = bike_interval$bike_number[i],
      start_time = bike_interval$end_datetime[i],
      end_time = bike_interval$start_datetime[i+1],
      route = paste(bike_interval$name[i]," -> ",bike_interval$name[i+1]),
      activity = "Moving",
      trip_time_min = difftime(bike_interval$start_datetime[i+1], bike_interval$end_datetime[i],units="mins")))  
  } 
  
  else {
    bike_route <- rbind(bike_route, data.frame(
      city = bike_interval$city[i],
      bike_number = bike_interval$bike_number[i+1],
      start_time = bike_interval$end_datetime[i],
      end_time = bike_interval$start_datetime[i+1],
      route = paste("Parking at -> ",bike_interval$name[i+1]),
      activity = "Staying",
      trip_time_min = difftime(bike_interval$end_datetime[i+1], bike_interval$start_datetime[i+1],units="mins")))  
    
  }
}

write.csv(bike_route, file = "bike_route.csv")

#Calculate possible income
total_df <- data.frame()
total_df <- bike_route[bike_route$trip_time_min <= 24*60,]

total_df <- cbind(total_df, trip_cost = 0)
total_df$trip_cost <- ifelse(total_df$trip_time_min<=30, 1, 9) # 30 min = 1 euro, 24h = 9 euro

total_income_sum <- sum(total_df$trip_cost)
total_bike_count <- length(unique(bike_route$bike_number))
total_start_date <- range(bike_route$start_time,na.rm=TRUE)
total_end_date <- range(bike_route$end_time,na.rm=TRUE)
total_meam_min <- mean(bike_route$trip_time_min)
total_income_by_bike <- total_income_sum / total_bike_count

summary(total_df)

