library(dplyr)
library(ggplot2)
#Pacakge plyr has group_by, which conflict with dplyr.  So, remove it.
if("package:plyr" %in% search()) {
  detach(package:plyr)
}

## Download and unzip the dataset:
filename <- "EmissionsData.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(fileURL, filename)
}  
if (!file.exists("summarySCC_PM25.rds")) { 
  unzip(filename, exdir=getwd()) 
}
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")
nei_df <- tbl_df(NEI)
rm("NEI")


#Aggregate total Emissions by years
baltimore_df <- filter(nei_df, fips == "24510")

by_type_year <- group_by(baltimore_df, type, year)
year_emissions <- summarize(by_type_year, 
                            count= n(), 
                            total=sum(Emissions),
                            average=mean(Emissions),
                            median=median(Emissions)
)

#Create bar chart and .png file
png('plot3.png')
g <- ggplot(year_emissions, aes(year, total, color=type))
g <- g + geom_line() + xlab("Year") + ylab(expression('Total PM'[2.5]*' Emission')) +
    ggtitle("Total Emisssions in Baltimore City")
print(g)
dev.off()
