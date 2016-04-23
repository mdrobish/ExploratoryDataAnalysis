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
coal_match <- grepl("coal", nei_scc_df$Short.Name, ignore.case=TRUE)
nei_scc_coal_df <- nei_scc_df[coal_match,]
by_year_coal <- group_by(nei_scc_coal_df, year)
year_coal_emissions <- summarize(by_year_coal, 
                            count= n(), 
                            total=sum(Emissions),
                            average=mean(Emissions),
                            median=median(Emissions)
)

#Create bar chart and .png file
png('plot4.png')
g <- ggplot(year_coal_emissions, aes(factor(year), total/10^5))
g <- g + geom_bar(stat="identity") + xlab("Year") + ylab(expression('Total PM'[2.5]*' Emission (10^5)')) +
  ggtitle("Total Emisssions from Coal Sources")
print(g)
dev.off()
