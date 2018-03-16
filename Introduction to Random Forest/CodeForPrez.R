#Set working directory

setwd("C:\\Users\\user4\\Documents\\Mithun")



# Create new image and Save it

save.image("./randomforest4.Rdata")

# Install packages( if necessary, install using 'Packages' tab)
install.packages("randomForest")
install.packages("caret")
install.packages("rpart")

# clear all the variables
#rm(list=ls())

train=read.csv("./data//train.csv")
test=read.csv("./data//test.csv")
head(test)
# Add "Survived" column to test, to help combine with train data
test$Survived=NA

# Combine train and test
combi=rbind(train,test)

# Convert names to character
combi$Name<-as.character(combi$Name)

# Split 'Name' to isolate a person's title using strsplit
strsplit(combi$Name[1],split='[,.]')

# test of how strsplit works
strsplit(combi$Name[1],split='[,.]')[[1]]
strsplit(combi$Name[1],split='[,.]')[[1]][2]

# apply function to dataset
# This will isolate title for all rows

combi$Title <- sapply(combi$Name, FUN=function(x){strsplit(x,split='[,.]')[[1]][2]})

# remove empty spaces from the 'Title' field
combi$Title=gsub(' ','',combi$Title)

# Review contents of 'Title' field
table(combi$Title)

# Reduce 'Title' contenst into fewer categories
combi$Title[combi$Title %in% c('Mme', 'Mlle')] <- 'Mlle'
combi$Title[combi$Title %in% c('Capt', 'Don', 'Major', 'Sir')] <- 'Sir'
combi$Title[combi$Title %in% c('Dona', 'Lady', 'the Countess', 'Jonkheer')] <- 'Lady'

# Change Title to a factor
combi$Title <- factor(combi$Title)

# Combine sibling and parent/child variables into FamilySize variable
combi$FamilySize <- combi$SibSp + combi$Parch + 1

# Identifying families by combining last name and family size
# # identify surname
combi$Surname <- sapply(combi$Name, FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
# # combine with family size
combi$FamilyID <- paste(as.character(combi$FamilySize), combi$Surname, sep="")
# Categorize family size less than 2 as small
combi$FamilyID[combi$FamilySize <= 2] <- 'Small'
# Review results
table(combi$FamilyID)
# Further consolidate results( some families may have different last names)
famIDs <- data.frame(table(combi$FamilyID))
famIDs <- famIDs[famIDs$Freq <= 2,]
combi$FamilyID[combi$FamilyID %in% famIDs$Var1] <- 'Small'
combi$FamilyID <- factor(combi$FamilyID)

# Splitting this new dataset back into train and test datasets
train <- combi[1:891,]
test <- combi[892:1309,]

# PRESENTATION START
# PRESENTATION START

# The "Age" variable has a few missing values
# To use the randomForest package in R, there should be no missing values
# A quick way of dealing with missing values is to replace them with either the mean or the median of the non-missing values for the variable
# In this example, we are replacing the missing values with a prediction, using decision trees.
library(rpart)
Agefit <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + FamilySize,data=combi[!is.na(combi$Age),], method="anova")
combi$Age[is.na(combi$Age)] <- predict(Agefit, combi[is.na(combi$Age),])

# Check for other missing variables
## 'Embarked' has two blank variables
## They are identified using the "which" command
which(combi$Embarked == '')
## rows 62 and 830 have the blank values for Embarked
## they are replaced with the mode of all the values for Embarked, which is 'S'
combi$Embarked[c(62,830)] = "S"

## convert 'Embarked' to a factor
combi$Embarked <- factor(combi$Embarked)


##'Fare' has one NA value
which(is.na(combi$Fare))
#Replace with median
combi$Fare[1044] <- median(combi$Fare, na.rm=TRUE)

## All missing values are taken care of now

# Random Forests in R can only digest factors with up to 32 levels
# If any factor variable has more than 32 levels, the levels need to be redefined to be <= 32 or the variable needs to be converted into a continuous one
# This example will redefine the levels
str(combi$FamilyID)


##increase the definition of Small from 2 to 3
combi$FamilyID2 <- combi$FamilyID
combi$FamilyID2 <- as.character(combi$FamilyID2)
combi$FamilyID2[combi$FamilySize <= 3] <- 'Small'
combi$FamilyID2 <- factor(combi$FamilyID2)

# split the dataset into training and test
train <- combi[1:891,]
test <- combi[892:1309,]


# installing the package
#install.packages('randomForest')
library(randomForest)


#  to ensure reproducible results, use the set.seed function
# this will give you the same results everytime you run the code
# the number inside is not important

set.seed(415)
fit <- randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked + Title + FamilySize +FamilyID2, data=train, importance=TRUE, ntree=2000)
## 'importance=TRUE' allows us to inspect variable importance
##  ntree enables specifying how many trees we want to grow

### ALSO LOOK AT NODESIZE AND SAMPSIZE TO SIMPPLIFY TREE, IN ORDER TO REDUCE COMPLEXITY


# Look at what variables are important
varImpPlot(fit)
## define accuracy and gini

### MeanDecreaseAccuracy : Tells us how much the accuracy decreases without the variable on the Y-axis.
### 'Title' causes the most decrease and is therefore the most predictive in nature

### MeanDecreseGini: Measure how pure terminal nodes are. 
### Again the plot tests results after removing each variable, for decrease in Gini value.
### Variable with the highest value has the highest predictive power

### "Title" variable is top for both measures



# Performance Evaluation

## Confusion Matrix
## The 'fit' object contains several components

names(fit)

## to review the confusion matrix

fit[5]
fit$confusion

##  Confidence Interval forAccuracy
set.seed(121)
library(caret)
confusionMatrix(fit$predicted,train$Survived)

## Area under the curve
###roc(train$Survived,as.integer(fit$predicted),plot = TRUE,smooth=TRUE)


# Tuning the Model




# creating a new data.frame to contain just the predictors necessary and not all the columns
# in the original training dataset
train1=data.frame(Pclass = train$Pclass,Survived =train$Survived, Sex=train$Sex,Age=train$Age,SibSp=train$SibSp,Parch=train$Parch,
                  Fare =train$Fare, Embarked=train$Embarked,Title=train$Title,FamilySize=train$FamilySize,FamilyID2=train$FamilyID2)


# tune to get best value of mtry
set.seed(121)
tunefit=train(as.factor(Survived)~ ., data=train1,method="rf",metric="Accuracy",tuneGrid=data.frame(mtry=c(2,3,4)))
tunefit


# Prediction
prediction=predict(tunefit, newdata=test)
head(prediction)

save.image("./randomforest4.Rdata")

