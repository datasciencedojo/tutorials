################################################################################
## This code is property of Data Science Dojo
## Copyright (C) 2017~2018
##
## Objective: Manipulate and visualize data using R
## Please install "dplyr" package: install.packages("dplyr")
## Please install "ggplot2" package: install.packages("ggplot2")
################################################################################
# Script for following along in Introduction to dplyr
# Copy-paste line by line or use the "Run" button in R Studio
#Set the working directory, example: setwd("directory/dataset folder")

install.packages("dplyr")
install.packages("ggplot2")
                 
library(dplyr)
library(ggplot2)
setwd("C:/Users/Arham/Desktop/Files/Introduction to dplyr")                 
#Reading the dataset from the working directory. 
#Setting string values as characters
#loading the greek characters
wine = read.csv("wine.csv", 
                stringsAsFactors = FALSE, 
                encoding = 'UTF-8')
                 
View (wine)
                 
#Removing columns from dataset
wine = wine[,-c(1,3)]
                 
#Creating a dataset by counting all observations grouped by country and then creating a new variable called count
wine %>% 
  group_by(country)%>% 
  summarize(count=n()) %>% 
  arrange(desc(count))
                 
#Creating a new variable which contains the top 10 countries
selected_countries = wine %>% 
  group_by(country) %>% 
  summarize(count=n()) %>% 
  arrange(desc(count)) %>% 
  top_n(10) %>% 
  select(country)
                 
selected_countries
                 
                 
#Changing the format from data frame to vector as.character referencing the country column
selected_countries = as.character(selected_countries$country)

class(selected_countries)
                 
#Subsetting data selecting top ten countries and their points from wine
select_points=wine %>% 
  filter(country %in% selected_countries) %>%
  select(country, points) %>% 
  arrange(country)
                 
#Scatterplot with smooth line
ggplot(wine, aes(points,price)) + 
  geom_point() + 
  geom_smooth()
                 
#Boxplot between country and points, reordered by median of points. Center aligning the Title of the boxplot
ggplot(select_points, 
       aes(x=reorder(country,points,median),
           y=points)) +
  geom_boxplot(aes(fill=country)) +
  xlab("Country") +
  ylab("Points") + 
  ggtitle("Distribution of Top 10 Wine Producing Countries") + 
  theme(plot.title = element_text(hjust = 0.5))
                 
#Filter by countries that do not appear on the selected_countries dataset
wine %>% 
  filter(!(country %in% selected_countries)) %>%
  group_by(country) %>%
  summarize(median=median(points)) %>%
  arrange(desc(median))
                 
#Creating a new variable called top using country and points to rate them based on points
top=wine %>%
  group_by(country) %>%
  summarize(median=median(points)) %>%
  arrange(desc(median))

class(top)
                 
#Changing the format from data frame to vector as.character referencing the country column
top=as.character(top$country)
top
                 
#Using intersect  function to select the common values in both datasets
both=intersect(top,selected_countries)
both
                 
#Using setdiff to select the non-overlapping values in both datasets
not = setdiff(top, selected_countries)
not
                 
#Creating a subset based on variety using group by and summarize
topwine = wine %>%
  group_by(variety) %>%
  summarize(number=n()) %>%
  arrange(desc(number)) %>%
  top_n(10)

topwine=as.character(topwine$variety)

topwine
                 
#Plot based on variety and points using group by and summarize
wine %>%
  filter(variety %in% topwine) %>%
  group_by(variety)%>%
  summarize(median=median(points)) %>%
  ggplot(aes(reorder(variety,median),median)) +
  geom_col(aes(fill=variety)) +
  xlab('Variety') + ylab('Median Point') +
  scale_x_discrete(labels=abbreviate)
                 
#Creating top 15 percent cheapest wines with high rating using intersect function
top15percent=wine %>%
  arrange(desc(points)) %>%
  filter(points > quantile(points, prob = 0.85))

cheapest15percent=wine %>%
  arrange(price) %>%
  head(nrow(top15percent))

goodvalue = intersect(top15percent,cheapest15percent)

goodvalue

#Feature Engineering

wine = read.csv('wine.csv',
                stringsAsFactors = FALSE,
                encoding = 'UTF-8')

save(wine, file = "wine.rda")
load("wine.rda")

#Omiting one column from the wine dataset
wine = wine[,-c(3)]  

View(wine)

#Using transmute and mutate functions to append a new column
wine1 = wine %>%
  mutate(PPratio = points/price)

wine2 = wine %>%
  transmute(PPratio = points/price)

#Aggregation by country using group by and summarize
wine  %>%
  group_by(country) %>%
  summarize(total = n())

#Missing country values
wine[wine$country == "",]

#Adding missing values in the dataset
wine$country = 
  ifelse(wine$designation == "Askitikos",
         "Greece", wine$country)
wine$country =
  ifelse(wine$designation == "Piedra Feliz",
         "Chile", wine$country)
wine$country =
  ifelse(wine$variety == "Red Blend",
         "Turkey", wine$country)

#Combining Datasets

#Creating a new subset by total number of rows by country
newwine = wine  %>%
  group_by(country) %>%
  summarize(total = n()) %>%
  arrange(desc(total))

#Creating subsets with the head of wine and newwine
subset1=head(wine)
subset2=head(newwine)

#Combining two data frames using full join function
full = full_join(subset1, subset2)
full

#Combining two data frames using inner join function
inner = inner_join(subset1, subset2)
inner

#Combining two data frames using left join function
left = left_join(subset1, subset2)
left

#Combining two data frames using right join function
right = right_join(subset1, subset2)
right

