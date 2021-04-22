getwd()

#install lubridate and tidyverse packages 
install.packages("lubridate")
install.packages("tidyverse")

#import dataset
library(tidyverse)
Storm_data_1997 <- read_csv("Downloads/StormEvents_details-ftp_v1.0_d1997_c20190920.csv")

#limit the dataframe to selected variables of interest and create new dataset 
myvars <- c("BEGIN_DATE_TIME", "END_DATE_TIME", "EPISODE_ID", "EVENT_ID", "STATE", "STATE_FIPS",
            "CZ_NAME", "CZ_TYPE", "CZ_FIPS", "EVENT_TYPE", "SOURCE", "BEGIN_LAT", "BEGIN_LON", 
            "END_LAT", "END_LON")
storm_1997 <- Storm_data_1997[myvars]
head(storm_1997)

#convert BEGIN_DATE_TIME AND END_DATE_TIME class 
library(lubridate)
storm_1997 <- mutate(storm_1997, BEGIN_DATE_TIME = dmy_hms(BEGIN_DATE_TIME), 
       END_DATE_TIME = dmy_hms(END_DATE_TIME))

#change state and county names to title case 
storm_1997$STATE <- str_to_title(storm_1997$STATE)
storm_1997$CZ_NAME <- str_to_title(storm_1997$CZ_NAME)

#limit dataset to events listed by county FIPS
storm_1997 <- filter(storm_1997, CZ_TYPE=='C')

#remove CZ_TYPE column 
storm_1997 <- storm_1997 %>% select(-CZ_TYPE)

#Pad state and county FIPS columns with a 0 at the beginning 
storm_1997$STATE_FIPS <- str_pad(storm_1997$STATE_FIPS, width=3, side = "left", pad = "0")
storm_1997$CZ_FIPS <- str_pad(storm_1997$CZ_FIPS, width=3, side = "left", pad = "0")

#unite state and county FIPS columns 
storm_1997 <- unite(storm_1997, FIPS, "STATE_FIPS", "CZ_FIPS", sep = "_", remove = TRUE)

#remame all column names to lowercase 
storm_1997 <- rename_all(storm_1997, tolower)

#create dataframe with state name, area, and region 
data("state")
state_data <- data.frame(table(storm_1997$state))
state_data <-rename(state_data, c("state"="Var1"))

#merge two dataframes 
us_state_info <- data.frame(state=state.name, region=state.region, area=state.area)
merged <- merge(x=state_data, y=us_state_info,by.x="state", by.y="state")

#create plot 
library(ggplot2)
storm_plot <- ggplot(merged, aes(x = area, y = Freq)) +
              geom_point(aes(color = region)) +
              labs(x = "Land area (square miles)", 
                   y = "Number of storm events in 1997", 
                   title = "Storm Events in U.S. by Land Area for 1997")
storm_plot

