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
nei_scc <- merge(NEI,SCC, by="SCC")
nei_scc_df <- tbl_df(nei_scc)
rm("nei_scc")

#Aggregate total Emissions by years
subset_df <- nei_scc_df[nei_scc_df$type=="ON-ROAD" & (nei_scc_df$fips=="24510" |nei_scc_df$fips=="06037") ,]
by_year_fips <- group_by(subset_df, fips, year)
year_fips_emissions <- summarize(by_year_fips, 
                                count= n(), 
                                total=sum(Emissions),
                                average=mean(Emissions),
                                median=median(Emissions)
)
year_fips_emissions$fips[year_fips_emissions$fips=="24510"] <- "Baltimore, MD"
year_fips_emissions$fips[year_fips_emissions$fips=="06037"] <- "Los Angeles, CA"


#Create bar chart and .png file
png('plot6.png')
g <- ggplot(year_fips_emissions, aes(factor(year), total))
g <- g + facet_grid(. ~ fips)
g <- g + geom_bar(stat="identity") + xlab("Year") + ylab(expression('Total PM'[2.5]*' Emission')) +
  ggtitle("Total Emisssions from Motor Vehicles in Baltimore vs Los Angeles")
print(g)
dev.off()
