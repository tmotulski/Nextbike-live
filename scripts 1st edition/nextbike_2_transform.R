# Analyze nextbike data
# Taras Motulski, 20017-01-08 
# Part 2 - Transform data

library(splitstackshape)
#setwd("d:/projects/carsharing/datasets/nextbike")

init_df = read.csv("init_df.csv")
base_unique_df <- unique(init_df)
base_unique_df <- na.omit(base_unique_df)

#split & transform datatype
full_df <- data.frame()
full_df <- cbind(base_unique_df, datetime = base_unique_df$filename)
#full_df$datetime <- as.character(strptime(substr(full_df$filename, 4, 22), "%Y-%m-%dT%H_%M_%S", tz="Europe/Berlin"))
full_df <- cSplit(full_df, "bike_numbers", ",", "long")
write.table(full_df, "full_df.csv", col.names=TRUE, sep=",")

full_df2$datetime <- as.character(strptime(substr(full_df2$filename, 4, 22), "%Y-%m-%dT%H_%M_%S", tz="Europe/Berlin"))
full_df$datetime <- as.POSIXct(full_df$datetime)

#sort df by bike & datetime
full_df <- full_df[order(full_df$city, full_df$bike_number, full_df$datetime),]
write.table(full_df, "full_df_sort.csv", col.names=TRUE, sep=",")
save(full_df, file="full_df.RData")


full_df1 <- full_df[1:13000000,]
full_df2 <- full_df[13000001:nrow(full_df),]

write.table(full_df1, "full_df1.csv", col.names=TRUE, sep=",")
write.table(full_df2, "full_df2.csv", col.names=TRUE, sep=",")
