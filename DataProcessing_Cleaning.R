source("00_requirements.R")
uncleanData <- read_tsv("participants.tsv")


cleanData <- uncleanData[,!names(uncleanData) %in% c("HbA1c", "sex", "bodyweight")]
names(cleanData)[names(cleanData) == "fasting insulin"] <- "Fasting Insulin"
names(cleanData)[names(cleanData) == "age"] <- "Age"
names(cleanData)[names(cleanData) == "participant_id"] <- "Participant_ID"

print(cleanData)