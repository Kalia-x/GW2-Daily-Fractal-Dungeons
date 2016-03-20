
options(stringsAsFactors=FALSE)
options(warn = -1)
library(jsonlite)
# stops character classes from being turned into factors. Mutes warnings, loads library jsonlite

if ("fractal_data.csv" %in% list.files() == FALSE) {
    frame <- data.frame(levelNumber=as.integer(), levelName=as.character(), Date=as.character())
    write.csv(frame, "fractal_data.csv", row.names=FALSE)
}
# if there is no output .csv file in wd, (aka first time script is run) create an empty csv

if ("fractalnames.txt" %in% list.files() == FALSE) {
    download.file("http://pastebin.com/raw/4dKwNHU7", "fractalnames.txt")
}
# if no fractal names txt file already in wd, download the cached copy of it from online

frame <- read.csv("fractal_data.csv")
# read in the output csv file to R environment object

if(as.character(Sys.Date()) %in% frame$Date) {
    stop("You have already run this script today.")
}
# if today's date can be already found in existing data frame, stop the script

dailies <- fromJSON("https://api.guildwars2.com/v2/achievements/categories/88")
fracDay <- dailies[[6]]
x <- fracDay[1]
y <- fracDay[5]
# downloads from the GW2 api the ids for daily achievements. They are in the 1st & 5th positions

site <- paste0("https://api.guildwars2.com/v2/achievements?ids=", x, ",", y)
dayNames <- fromJSON(site)
# uses the extracted ids to reference against the api, to extract the names of the achievements

levelNumber <- dayNames$name
levelNumber <- as.integer(gsub("[^0-9]", "", levelNumber))
levelNumber <- levelNumber[order(levelNumber)]
# formats the name of the achievs to extract only the number

if(exists("fracNames")==FALSE) {
    fracNames <- read.table("fractalnames.txt")
    fracNames$V1 <- gsub(":", "", fracNames$V1)
    fracNames <- fracNames[, 1:2]
}
# reads in the fractal names reference table, if doesn't already exist as an object in environment

levelName <- fracNames[fracNames$V1 %in% levelNumber, "V2"]
Date <- as.character(c(Sys.Date(), Sys.Date()))
temp <- data.frame(levelNumber=levelNumber, levelName=levelName, Date=Date)
# extracts the fractal name by comparing the fractal number to names list
# creates a data frame with variables: fractal number/fractal name/today's date

frame <- rbind(frame, temp)
write.csv(frame, "fractal_data.csv", row.names=FALSE)
# adds the temporary data frame to the larger one, saves it in the working directory
