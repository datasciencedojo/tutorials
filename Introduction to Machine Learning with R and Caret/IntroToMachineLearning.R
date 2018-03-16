#=======================================================================================
#
# File:        IntroToMachineLearning.R
# Author:      Dave Langer
# Description: This code illustrates the usage of the caret package for the An 
#              Introduction to Machine Learning with R and Caret" Meetup dated 
#              06/07/2017. More details on the Meetup are available at:
#
#                 https://www.meetup.com/data-science-dojo/events/239730653/
#
# NOTE - This file is provided "As-Is" and no warranty regardings its contents are
#        offered nor implied. USE AT YOUR OWN RISK!
#
#=======================================================================================

#install.packages(c("e1071", "caret", "doSNOW", "ipred", "xgboost"))
library(caret)
library(doSNOW)



#=================================================================
# Load Data
#=================================================================

train <- read.csv("train.csv", stringsAsFactors = FALSE)
View(train)




#=================================================================
# Data Wrangling
#=================================================================

# Replace missing embarked values with mode.
table(train$Embarked)
train$Embarked[train$Embarked == ""] <- "S"


# Add a feature for tracking missing ages.
summary(train$Age)
train$MissingAge <- ifelse(is.na(train$Age),
                           "Y", "N")


# Add a feature for family size.
train$FamilySize <- 1 + train$SibSp + train$Parch


# Set up factors.
train$Survived <- as.factor(train$Survived)
train$Pclass <- as.factor(train$Pclass)
train$Sex <- as.factor(train$Sex)
train$Embarked <- as.factor(train$Embarked)
train$MissingAge <- as.factor(train$MissingAge)


# Subset data to features we wish to keep/use.
features <- c("Survived", "Pclass", "Sex", "Age", "SibSp",
              "Parch", "Fare", "Embarked", "MissingAge",
              "FamilySize")
train <- train[, features]
str(train)




#=================================================================
# Impute Missing Ages
#=================================================================

# Caret supports a number of mechanism for imputing (i.e., 
# predicting) missing values. Leverage bagged decision trees
# to impute missing values for the Age feature.

# First, transform all feature to dummy variables.
dummy.vars <- dummyVars(~ ., data = train[, -1])
train.dummy <- predict(dummy.vars, train[, -1])
View(train.dummy)

# Now, impute!
pre.process <- preProcess(train.dummy, method = "bagImpute")
imputed.data <- predict(pre.process, train.dummy)
View(imputed.data)

train$Age <- imputed.data[, 6]
View(train)



#=================================================================
# Split Data
#=================================================================

# Use caret to create a 70/30% split of the training data,
# keeping the proportions of the Survived class label the
# same across splits.
set.seed(54321)
indexes <- createDataPartition(train$Survived,
                               times = 1,
                               p = 0.7,
                               list = FALSE)
titanic.train <- train[indexes,]
titanic.test <- train[-indexes,]


# Examine the proportions of the Survived class lable across
# the datasets.
prop.table(table(train$Survived))
prop.table(table(titanic.train$Survived))
prop.table(table(titanic.test$Survived))




#=================================================================
# Train Model
#=================================================================

# Set up caret to perform 10-fold cross validation repeated 3 
# times and to use a grid search for optimal model hyperparamter
# values.
train.control <- trainControl(method = "repeatedcv",
                              number = 10,
                              repeats = 3,
                              search = "grid")


# Leverage a grid search of hyperparameters for xgboost. See 
# the following presentation for more information:
# https://www.slideshare.net/odsc/owen-zhangopen-sourcetoolsanddscompetitions1
tune.grid <- expand.grid(eta = c(0.05, 0.075, 0.1),
                         nrounds = c(50, 75, 100),
                         max_depth = 6:8,
                         min_child_weight = c(2.0, 2.25, 2.5),
                         colsample_bytree = c(0.3, 0.4, 0.5),
                         gamma = 0,
                         subsample = 1)
View(tune.grid)


# Use the doSNOW package to enable caret to train in parallel.
# While there are many package options in this space, doSNOW
# has the advantage of working on both Windows and Mac OS X.
#
# Create a socket cluster using 10 processes. 
#
# NOTE - Tune this number based on the number of cores/threads 
# available on your machine!!!
#
cl <- makeCluster(10, type = "SOCK")

# Register cluster so that caret will know to train in parallel.
registerDoSNOW(cl)

# Train the xgboost model using 10-fold CV repeated 3 times 
# and a hyperparameter grid search to train the optimal model.
caret.cv <- train(Survived ~ ., 
                  data = titanic.train,
                  method = "xgbTree",
                  tuneGrid = tune.grid,
                  trControl = train.control)
stopCluster(cl)


# Examine caret's processing results
caret.cv


# Make predictions on the test set using a xgboost model 
# trained on all 625 rows of the training set using the 
# found optimal hyperparameter values.
preds <- predict(caret.cv, titanic.test)


# Use caret's confusionMatrix() function to estimate the 
# effectiveness of this model on unseen, new data.
confusionMatrix(preds, titanic.test$Survived)
