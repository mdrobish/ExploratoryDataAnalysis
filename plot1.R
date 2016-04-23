library(dplyr)
library(tidyr)
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
by_year <- group_by(nei_df, year)
year_emissions <- summarize(by_year, 
                            count= n(), 
                            total=sum(Emissions),
                            average=mean(Emissions),
                            median=median(Emissions)
)

#Create bar chart and .png file
png('plot1.png')
with(year_emissions, barplot(height=total, names.arg=year, xlab="Year", ylab=expression('Total PM'[2.5]*' Emission'), main=expression('Total PM'[2.5]*' emissions at Year')))
dev.off()
