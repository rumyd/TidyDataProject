# This script is to practise fundamentals of tidying data using R script

# STEP 1 --> Download entire data from url
run_analysis <- function(){
if(!file.exists('./TidyDataAssign')){dir.create("./TidyDataAssign")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./TidyDataAssign/getdata-projectfiles-UCI HAR Dataset.zip")
unzip("./TidyDataAssign/getdata-projectfiles-UCI HAR Dataset.zip")

#STEP 2 --> Create dataset for Labels to be used later for train and test dataset

# Pull in the text for "features" to be used later as labels for column names
# in the test and train data frames.No need to further refine the description 
features <- read.csv("./TidyDataAssign/UCI HAR Dataset/features.txt", sep = " ", header = FALSE, colClasses = c("NULL", "character"), col.names = c
                     ("NULL", "Feature"))

# features.txt has a lot of duplicates, which cannot be used asis for column 
# names for test and train. Hence using make.unique() function to make the 
#values in features data frame uniique for later use in column headings
features$Feature <- make.unique(features$Feature)

# STEP 3 --> Download train files and tidy up with labels and relevant columns

# read train file and assign column names (alternatively can also 
# use names(train_raw) <- features[, 1] to assign df col names)
train_raw <- read.table("./TidyDataAssign/UCI HAR Dataset/train/X_train.txt", header = FALSE, 
                        colClasses = "numeric", col.names = features[, 1])


#Store column names in character vector, to be filtered in the test and train 
# data frames to only include mean and standard deviation
filtered_names <- grep("mean|std", names(train_raw), ignore.case = TRUE, 
                       value = TRUE) 

#filter the columns to only include columns for mean and Std. deviation and 
# add new column Group to identify "train" group
train_filter <- train_raw %>% select(one_of(filtered_names)) %>% 
    mutate(Group = "Train")

# Remove raw train file to conserve memory
rm("train_raw")

# STEP 4 --> Repeat the steps done for train file to download and prepare
# dataset for test file

# Read test file and assign column names (alternatively can also use 
# names(test_raw) <- features[, 1] to assign df col names)
test_raw <- read.table("./TidyDataAssign/UCI HAR Dataset/test/X_test.txt", header = FALSE, 
                       colClasses = "numeric", col.names = features[, 1])

# Filter the columns to only include columns for mean and Std. deviation (ignore
# case) and add new column Group to identify "test" group
test_filter <- test_raw %>% select(one_of(filtered_names)) %>% 
    mutate(Group = "Test")

# Remove raw test file to conserve memory
rm("test_raw")

# STEP 5 -> Merge train and test data
train_test <- bind_rows(train_filter, test_filter)

# Remove individual files for train and test
rm("train_filter", "test_filter")

# STEP 6 -> Download, prepare and merge "subject" data for train and test scenarios

# Work on individual files for subject ID in train and test and merge them

subject_train <- read.table("./TidyDataAssign/UCI HAR Dataset/train/subject_train.txt", 
                            header = FALSE, colClasses = "character", 
                            col.names = "subject_ID")

subject_test <- read.table("./TidyDataAssign/UCI HAR Dataset/test/subject_test.txt", 
                           header = FALSE, colClasses = "character", 
                           col.names = "subject_ID")

subject <- bind_rows(subject_train, subject_test)

# STEP 7 -> Download, prepare and merge "Activity" data for train and test 
# scenarios including labels for different activity types

# work on individual files for activity ID in train and test and merge them
activity_train <- read.table("./TidyDataAssign/UCI HAR Dataset/train/y_train.txt", 
                             header = FALSE, colClasses = "character", 
                             col.names = "Activity_ID")

activity_test <- read.table("./TidyDataAssign/UCI HAR Dataset/test/y_test.txt", 
                            header = FALSE, colClasses = "character", 
                            col.names = "Activity_ID")

activity <- bind_rows(activity_train, activity_test)

# Read activity label table for describig activity type
activity_label <- read.csv("./TidyDataAssign/UCI HAR Dataset/activity_labels.txt", sep = " ", header = FALSE, colClasses = "character", col.names = 
                               c("Activity_ID", "ActivityName"))

# Use inner_join() function from dplyr (or alternatively merge() ) to bring 
# labels to activity data frame
activity <- inner_join(activity, activity_label, by = "Activity_ID")

# Remove activity ID column using select()
activity <- select(activity, ActivityName)

# Step 8 -> Merge all in one file
data_merged <- bind_cols(subject, activity, train_test)

# clean up objects no longer in use
rm("features", "train_test", "subject", "activity", "subject_train", "subject_test", "activity_train", "activity_test")

# Final STEP 9 -> create another tidy data set with mean of variables
# grouped by Activity and Subject

# Remove the character variable which distinguished between test and train data
d1 <- select(data_merged, -Group) 

# group the dataset by Activity, Subject and derive mean for each variable for
# this grouping
data_grouped_mean <- d1 %>% group_by(ActivityName, subject_ID) %>%
    summarise_each(funs(mean))
head(data_grouped_mean)
}