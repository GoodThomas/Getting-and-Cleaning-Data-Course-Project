# 1. Merges the training and the test sets to create one data set.

if(!file.exists("./data")){dir.create("./data")}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "./data/Dataset.zip", method = "curl")
library(zip)
unzip("./data/Dataset.zip", exdir = "./data/")
library(data.table)
library(dplyr)

features <- fread("./data/UCI HAR Dataset/features.txt")

data_train <- fread("./data/UCI HAR Dataset/train/X_train.txt")
subject_train <- fread("./data/UCI HAR Dataset/train/subject_train.txt")
labels_train <- fread("./data/UCI HAR Dataset/train/y_train.txt")
data_train <- mutate(data_train, subject = subject_train$V1)
data_train <- mutate(data_train, labels = labels_train$V1)

data_test <- fread("./data/UCI HAR Dataset/test/X_test.txt")
subject_test <- fread("./data/UCI HAR Dataset/test/subject_test.txt")
labels_test <- fread("./data/UCI HAR Dataset/test/y_test.txt")
data_test <- mutate(data_test, subject = subject_test$V1)
data_test <- mutate(data_test, labels = labels_test$V1)

merged_data <- bind_rows(data_train, data_test)
names(merged_data) <- c(features$V2, "subject", "labels")

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

mean_std_data <- merged_data[, grep("[Mm]ean|std", names(merged_data), value = TRUE)]

# 3. Uses descriptive activity names to name the activities in the data set

colnames(merged_data)[563] <- 'activity'
activity_labels <- fread("./data/UCI HAR Dataset/activity_labels.txt")
merged_data$activity <- activity_labels$V2[merged_data$activity]

# 4. Appropriately labels the data set with descriptive variable names.

names(merged_data) <- tolower(names(merged_data))
names(merged_data) <- gsub("_|,", "-", names(merged_data))

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

average_data <- melt(merged_data, id=c("subject", "activity")) %>% dcast(subject + activity ~ variable, mean)
write.table(average_data, file = "./data/UCI HAR Dataset/tidy data.txt", row.name=FALSE)