##########################################################################################################
# Coursera Getting and Cleaning Data Course Project
# runAnalysis.r File Description:
# This script will perform the following steps on the UCI HAR Dataset downloaded from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
##########################################################################################################
# Clean up workspace
rm(list=ls())
# 1. Merge the training and the test sets to create one data set.
#set working directory to the location where the UCI HAR Dataset was unzipped

setwd("D://Documents//Course3project");


# Download of data
zfile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
outDir<-"D://Documents//Course3project//data"

download.file(zfile,"./data/data.zip")
unzip("./data/data.zip",exdir=outDir)

# Read in the data from files
features     = read.table("./data/UCI HAR Dataset/features.txt",header=FALSE); #imports features.txt
activitylabels = read.table('./data/UCI HAR Dataset/activity_labels.txt',header=FALSE); #imports activity_labels.txt
subjecttrain = read.table('./data/UCI HAR Dataset/train/subject_train.txt',header=FALSE); #imports subject_train.txt
xtrain       = read.table('./data/UCI HAR Dataset/train/x_train.txt',header=FALSE); #imports x_train.txt
ytrain       = read.table('./data/UCI HAR Dataset/train/y_train.txt',header=FALSE); #imports y_train.txt

# Read in the test data
subjecttest = read.table('./data/UCI HAR Dataset/test/subject_test.txt',header=FALSE); #imports subject_test.txt
xtest       = read.table('./data/UCI HAR Dataset/test/x_test.txt',header=FALSE); #imports x_test.txt
ytest       = read.table('./data/UCI HAR Dataset/test/y_test.txt',header=FALSE); #imports y_test.txt

xdataset <- rbind(xtrain, xtest)
ydataset <- rbind(ytrain, ytest)
subjectdataset <- rbind(subjecttrain, subjecttest)

# 2. Extract only the measurements on the mean and standard deviation for each measurement.
# xData subset based on the logical vector to keep only desired columns, i.e. mean() and std().

xdataset_mean_std <- xdataset[, grep("-(mean|std)\\(\\)", features[,2])]
names(xdataset_mean_std) <- features[grep("-(mean|std)\\(\\)", features[, 2]), 2] 

# 3. Use descriptive activity names to name the activities in the data set.

ydataset[, 1] <- activitylabels[ydataset[, 1], 2]
names(ydataset) <- "Activity"

# 4. Appropriately label the data set with descriptive activity names.
names(subjectdataset) <- "Subject"

# Merge to 1 dataset
singledataset <- cbind(xdataset_mean_std, ydataset, subjectdataset)

# Define names
names(singledataset) <- make.names(names(singledataset))
names(singledataset) <- gsub('Acc',"Acceleration",names(singledataset))
names(singledataset) <- gsub('GyroJerk',"AngularAcceleration",names(singledataset))
names(singledataset) <- gsub('Gyro',"AngularSpeed",names(singledataset))
names(singledataset) <- gsub('Mag',"Magnitude",names(singledataset))
names(singledataset) <- gsub('^t',"TimeDomain.",names(singledataset))
names(singledataset) <- gsub('^f',"FrequencyDomain.",names(singledataset))
names(singledataset) <- gsub('\\.mean',".Mean",names(singledataset))
names(singledataset) <- gsub('\\.std',".StandardDeviation",names(singledataset))
names(singledataset) <- gsub('Freq\\.',"Frequency.",names(singledataset))
names(singledataset) <- gsub('Freq$',"Frequency",names(singledataset))

# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

data2<-aggregate(. ~Subject + Activity, singledataset, mean)
data2<-data2[order(data2$Subject,data2$Activity),]
write.table(data2, file = "tidydata.txt",row.name=FALSE)
