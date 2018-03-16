#=========================================================================================
#
# File:        titanic.R
# Author:      Dave Langer
# Description: This code illustrates R coding used in the "Introduction to R Programming 
#              for Excel Users" Meetup dated 05/03/2017. More details on 
#              the Meetup are available at:
#
#                 https://www.meetup.com/data-science-dojo/events/239049571/
#
#              The code in this file leverages data from Kaggle's "Titanic: Machine 
#              Learning from Disaster" introductory competition:
#
#                 https://www.kaggle.com/c/titanic
#
# NOTE - This file is provided "As-Is" and no warranty regardings its contents are
#        offered nor implied. USE AT YOUR OWN RISK!
#
#=========================================================================================


# Load up Titanic data into a R data frame (i.e., R's version of an Excel table)
titanic <- read.csv("titanic.csv", header = TRUE)


# Add a new feature to the data frame for SurvivedLabel
titanic$SurvivedLabel <- ifelse(titanic$Survived == 1, 
                                "Survived",
                                "Died")


# Add a new feature (i.e., column) to the data frame for FamilySize
titanic$FamilySize <- 1 + titanic$SibSp + titanic$Parch
View(titanic)


# Look at the data types (i.e., R's version of Excel data formatting for cells)
str(titanic)


# Apply a row filter to the Titanic data frame - return only males
males <- titanic[titanic$Sex == "male",]


# Create summary statistics for male fares
summary(males$Fare)
var(males$Fare)
sd(males$Fare)
sum(males$Fare)
length(males$Fare)


# Ranges work just like in Excel - pick the first 5 rows of data.
first.five <- titanic[1:5,]


# View the first five columns of the first five rows.
View(first.five[, 1:5])


# Use an R package (i.e., the Excel equivalent of an Add-in) to
# create powerful visualizations easy.
#install.packages("ggplot2")
library(ggplot2)
ggplot(titanic, aes(x = FamilySize, fill = SurvivedLabel)) +
  theme_bw() +
  facet_wrap(Sex ~ Pclass) +
  geom_histogram(binwidth = 1)


# Use an R package (i.e., the Excel equivalent of an Add-in) to 
# make building data pivots easy.
#install.packages("dplyr")
library(dplyr)
pivot <- titanic %>%
  group_by(Pclass, Sex, SurvivedLabel) %>%
  summarize(AvgFamilySize = mean(FamilySize),
            PassengerCount = n()) %>%
  arrange(Pclass, Sex, SurvivedLabel)
View(pivot)



