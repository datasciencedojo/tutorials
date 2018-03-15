#
# Copyright 2017 Data Science Dojo
#    
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 


#
# This R source code file corresponds to the Data Science Dojo webinar 
# titled "An Introduction to Data Visualization with R and ggplot2" 
#

#install.packages("ggplot2")
library(ggplot2)


# Load Titanic titanicing data for analysis. Open in spreadsheet view.
titanic <- read.csv("titanic.csv", stringsAsFactors = FALSE)
View(titanic)


# Set up factors.
titanic$Pclass <- as.factor(titanic$Pclass)
titanic$Survived <- as.factor(titanic$Survived)
titanic$Sex <- as.factor(titanic$Sex)
titanic$Embarked <- as.factor(titanic$Embarked)


#
# We'll start our visual analysis of the data focusing on questions
# related to survival rates. Specifically, these questions will use
# the factor (i.e., categorical) variables in the data. Factor data
# is very common in the business context and ggplot2 offers many
# powerful features for visualizing factor data.
#


#
# First question - What was the survival rate? 
#
# As Survived is a factor (i.e., categorical) variable, a bar chart 
# is a great visualization to use.
#
ggplot(titanic, aes(x = Survived)) + 
  geom_bar()

# If you really want percentages.
prop.table(table(titanic$Survived))

# Add some customization for labels and theme.
ggplot(titanic, aes(x = Survived)) + 
  theme_bw() +
  geom_bar() +
  labs(y = "Passenger Count",
       title = "Titanic Survival Rates")


#
# Second question - What was the survival rate by gender? 
#
# We can use color to look at two aspects (i.e., dimensions)
# of the data simultaneously.
#
ggplot(titanic, aes(x = Sex, fill = Survived)) + 
  theme_bw() +
  geom_bar() +
  labs(y = "Passenger Count",
       title = "Titanic Survival Rates by Sex")


#
# Third question - What was the survival rate by class of ticket? 
#
ggplot(titanic, aes(x = Pclass, fill = Survived)) + 
  theme_bw() +
  geom_bar() +
  labs(y = "Passenger Count",
       title = "Titanic Survival Rates by Pclass")


#
# Fourth question - What was the survival rate by class of ticket
#                   and gender?
#
# We can leverage facets to further segment the data and enable
# "visual drill-down" into the data.
#
ggplot(titanic, aes(x = Sex, fill = Survived)) + 
  theme_bw() +
  facet_wrap(~ Pclass) +
  geom_bar() +
  labs(y = "Passenger Count",
       title = "Titanic Survival Rates by Pclass and Sex")




#
# Next, we'll move on to visualizing continuous (i.e., numeric)
# data using ggplot2. We'll explore visualizations of single 
# numeric variables (i.e., columns) and also illustrate how
# ggplot2 enables visual drill-down on numeric data.
#


#
# Fifth Question - What is the distribution of passenger ages?
#
# The histogram is a staple of visualizing numeric data as it very 
# powerfully communicates the distrubtion of a variable (i.e., column).
#
ggplot(titanic, aes(x = Age)) +
  theme_bw() +
  geom_histogram(binwidth = 5) +
  labs(y = "Passenger Count",
       x = "Age (binwidth = 5)",
       title = "Titanic Age Distribtion")


#
# Sixth Question - What are the survival rates by age?
#
ggplot(titanic, aes(x = Age, fill = Survived)) +
  theme_bw() +
  geom_histogram(binwidth = 5) +
  labs(y = "Passenger Count",
       x = "Age (binwidth = 5)",
       title = "Titanic Survival Rates by Age")

# Another great visualization for this question is the box-and-whisker 
# plot.
ggplot(titanic, aes(x = Survived, y = Age)) +
  theme_bw() +
  geom_boxplot() +
  labs(y = "Age",
       x = "Survived",
       title = "Titanic Survival Rates by Age")


#
# Seventh Question - What is the survival rates by age when segmented
#                    by gender and class of ticket?
#
# A related visualization to the histogram is a density plot. Think of
# a density plot as a smoothed version of the histogram. Using ggplot2
# we can use facets to allow for visual drill-down via density plots.
#
ggplot(titanic, aes(x = Age, fill = Survived)) +
  theme_bw() +
  facet_wrap(Sex ~ Pclass) +
  geom_density(alpha = 0.5) +
  labs(y = "Age",
       x = "Survived",
       title = "Titanic Survival Rates by Age, Pclass and Sex")

# If you prefer histograms, no problem!
ggplot(titanic, aes(x = Age, fill = Survived)) +
  theme_bw() +
  facet_wrap(Sex ~ Pclass) +
  geom_histogram(binwidth = 5) +
  labs(y = "Age",
       x = "Survived",
       title = "Titanic Survival Rates by Age, Pclass and Sex")

