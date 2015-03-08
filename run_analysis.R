## run_analysis.R

## Move into the subdirectory containing all the files supplied from source
## setwd("data-for-r/")

## The various files supplied are read into Data Frames 
subject_train<-read.table("subject_train.txt")
subject_test<-read.table("subject_test.txt")
xtrain<-read.table("x_train.txt")
xtest<-read.table("x_test.txt")
ytrain<-read.table("y_train.txt")
ytest<-read.table("y_test.txt")
features<-read.table("features.txt")
activities<-read.table("activity_labels.txt")

## Libraries required for reformatting
library(dplyr)
library(tidyr)

## Load into tables, add a poptype variable containing 'test' or 'train', and rename the variables appropriately.
## Subset the mean and std variable only and convert activity codes into descriptions.

## Read into table (subjects)
## rename the column to 'subject' since this is what the file holds
## add a poptype of 'test'
tsubtst<-tbl_df(subject_test)
tsubtst<-rename(tsubtst,subject=V1)
tsubtst<-mutate(tsubtst,poptype="test")

## Read into table (subjects)
## rename the column to 'subject' since this is what the file holds
## add a poptype of 'train'
tsubtrn<-tbl_df(subject_train)
tsubtrn<-rename(tsubtrn,subject=V1)
tsubtrn<-mutate(tsubtrn,poptype="train")

## Read into table (test activities)
## Rename column to acivitycode (number representing the activity)
tytst<-tbl_df(ytest)
tytst<-rename(tytst,activitycode=V1)

## Read into table (training activities)
## Rename column to acivitycode (number representing the activity)
tytrn<-tbl_df(ytrain)
tytrn<-rename(tytrn,activitycode=V1)

## Use grep to find features that contain mean() string
## create a vector of the column numbers that hold these for mean().
meanfeat<-grep("mean()",features$V2)
## Use grep to find features that contain std() string
## create a vector of the column numbers that hold these for std().
stdfeat<-grep("std()",features$V2)
## Join and sort these into a vector
feat<-sort(c(meanfeat,stdfeat))

## Now read the features into a table
## Select only the column identified in feat - mean() and std()
txtst<-tbl_df(xtest)
txtst<-select(txtst,feat)
## Name these columns using the contents of features (second variable contains names) - but clean the Feature names first
features$V2<-gsub("[()]","",features$V2)
features$V2<-gsub("-","",features$V2)
features$V2<-gsub(",","",features$V2)
names(txtst)<-features$V2[feat]

## As above for the training set
txtrn<-tbl_df(xtrain)
txtrn<-select(txtrn,feat)
names(txtrn)<-features$V2[feat]

## Create a data table 'tact' based on activities description file which has an activitycode 
##  and an activity (containing the description)
tact<-rename(activities,activitycode=V1,activity=V2)

## Now rowbind the training and test datasets 
## and column bind the subjects, features and activities together
result<-cbind(rbind(tsubtrn,tsubtst),rbind(txtrn,txtst),rbind(tytrn,tytst))
## Now join on the activity descriptions 
result<-left_join(result,tact,by="activitycode")
## Now drop the activity code in favour of the description we joined on.

result<-select(result,-activitycode)


## Finally perform a means on all the feature variables for each activity and subject - this is stored in 'analysis'

analysis<-summarise_each(group_by(result,activity,subject),"mean",3:82)

## Output this result to output.txt for upload to Coursera and github.

write.table(analysis,"output.txt",row.names=FALSE)
