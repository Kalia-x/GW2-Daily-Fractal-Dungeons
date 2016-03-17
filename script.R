
options(stringsAsFactors=FALSE)
options(warn = -1)
library(jsonlite)

if ("fractal_data.csv" %in% list.files() == FALSE) {
    frame <- data.frame(levelNumber=as.character(), levelName=as.character(), Date=as.character())
    write.csv(frame, "fractal_data.csv")
}
if ("fractalnames.txt" %in% list.files() == FALSE) {
    download.file("http://pastebin.com/raw/4dKwNHU7", "fractalnames.txt")
}

frame <- read.csv("fractal_data.csv")

dailies <- fromJSON("https://api.guildwars2.com/v2/achievements/categories/88")
fracDay <- dailies[[6]]
x <- fracDay[1]
y <- fracDay[5]

site <- paste0("https://api.guildwars2.com/v2/achievements?ids=", x, ",", y)
dayNames <- fromJSON(site)

levelNumber <- dayNames$name
levelNumber <- gsub("[^0-9]", "", levelNumber)
levelNumber <- levelNumber[order(levelNumber, decreasing=TRUE)]

if(exists("fracNames")==FALSE) {
    fracNames <- read.table("fractalnames.txt")
    fracNames$V1 <- gsub(":", "", fracNames$V1)
    fracNames <- fracNames[, 1:2]
}

levelName <- fracNames[fracNames$V1 %in% levelNumber, "V2"]
Date <- as.character(c(Sys.Date(), Sys.Date()))
temp <- data.frame(levelNumber=levelNumber, levelName=levelName, Date=Date)

if(temp$Date[1] %in% frame$Date) {
    stop("You have already run this script today.")
}

frame <- rbind(frame, temp)
write.csv(frame, "fractal_data.csv")
