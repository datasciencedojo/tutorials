Copyright 2017 Data Science Dojo
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
setwd("C:/Users/Arham/Desktop/Data Visualization with ggplot2")
install.packages("ggplot2")
install.packages("dplyr")
library(dplyr)
library(ggplot2)

# Load Titanic data for analysis. Open in spreadsheet view.
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


# Load H1B data for analysis. Open in spreadsheet view.
h1b <- read.csv("H-1B_FY2018.csv", stringsAsFactors = FALSE, encoding = 'UTF-8')
View(h1b)


# Set up factors.
h1b$EMPLOYER_NAME <- as.factor(h1b$EMPLOYER_NAME)
h1b$EMPLOYER_CITY <- as.factor(h1b$EMPLOYER_CITY)
h1b$EMPLOYER_STATE <- as.factor(h1b$EMPLOYER_STATE)
h1b$SOC_NAME <- as.factor(h1b$SOC_NAME)
h1b$WORKSITE_CITY <- as.factor(h1b$WORKSITE_CITY)
h1b$WORKSITE_STATE <- as.factor(h1b$WORKSITE_STATE)
h1b$CASE_STATUS <- as.factor(h1b$CASE_STATUS)
h1b$PW_WAGE_LEVEL<- as.factor(h1b$PW_WAGE_LEVEL)
h1b$JOB_TITLE<- as.factor(h1b$JOB_TITLE)

h1b$PREVAILING_WAGE <- as.numeric(h1b$PREVAILING_WAGE)
h1b$PREVAILING_WAGE[is.na(h1b$PREVAILING_WAGE)] <- round(mean(h1b$PREVAILING_WAGE, na.rm = TRUE))
head(h1b)

#We can use color to look at two aspects (i.e., dimensions)
# of the data simentiously

ggplot(h1b, aes(x = EMPLOYER_STATE, fill = CASE_STATUS)) + 
  theme_bw() +
  geom_bar() + 
  labs(y = "No. of Applications", x = "Employer State",  
       title = "Distribution by Employer State")

# Subsetting the data to keep only "CERTIFIED" H1B cases
certified_h1b <- h1b %>%
  filter(CASE_STATUS == "CERTIFIED")

#Function to return the top N employers that have the most H1B workers
top_N_employers <- function(num_emp) {
  certified_h1b %>%
    group_by(EMPLOYER_NAME) %>%
    summarise(num_apps = n()) %>%
    arrange(desc(num_apps)) %>%
    slice(1:num_emp)
}

# Bar plot to show the top 10 employers who filed the most h1b visa applications
ggplot(top_N_employers(10), 
       aes(x = reorder(EMPLOYER_NAME, num_apps), y = num_apps)) +
  geom_bar(stat = "identity", alpha = 0.9, fill = "green", width = 0.7) +
  coord_flip() +
  scale_y_continuous(limits = c(0, 11000), breaks = seq(0, 11000)) +
  geom_text(aes(label = num_apps), hjust = -0.2, size = 2) +
  ggtitle("Top 10 Employers with most applications") +
  theme_bw() +
  labs(x = "Employer Name", y = "No. of Applications")



# Function to return top N occupations that have the most H1B applicants
top_N_SOC <- function(num) {
  certified_h1b %>%
    filter(!is.na(certified_h1b$SOC_NAME)) %>%
    group_by(SOC_NAME) %>%
    summarise(num_apps = n()) %>%
    arrange(desc(num_apps)) %>%
    slice(1:num)
}

# Bar plot to show the top 10 H1B occupations 
ggplot(top_N_SOC(10), 
       aes(x = reorder(SOC_NAME, num_apps), y = num_apps)) +
  geom_bar(stat = "identity", alpha = 0.9, fill = "blue", width = 0.7) +
  coord_flip() +
  scale_y_continuous() +
  geom_text(aes(label = num_apps), hjust = -0.2, size = 2) +
  ggtitle("Top 10 occupations with most H1B petitions") +
  theme(plot.title = element_text(size = rel(1)),
        axis.text.y = element_text(size = rel(0.8))) +
  labs(x = "SOC Name", y = "No. of Applications") 

