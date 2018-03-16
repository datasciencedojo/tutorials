#=======================================================================================
#
# File:        CustomerVisualizations.R
# Author:      Dave Langer
# Description: This code illustrates R visualizaions used in the "Introduction to R 
#              Visualization with Power BI " Meetup dated 03/15/2017. More details on 
#              the Meetup are available at:
#
#                 https://www.meetup.com/Data-Science-Dojo-Toronto/events/237952698/
#
#              The code in this file leverages data from Microsoft's Wide World
#              Importers sample Data Warehouse available at:
#
#                 https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
#
# NOTE - This file is provided "As-Is" and no warranty regardings its contents are
#        offered nor implied. USE AT YOUR OWN RISK!
#
#=======================================================================================


# Uncomment and run these lines of code to install required packages
#install.packages("dplyr")
#install.packages("lubridate")
#install.packages("ggplot2")
#install.packages("scales")
#install.packages("qcc")


# NOTE - Change your working directory as needed
load("CustomerData.RData")


# Preprocessing to make dataset look like Power BI
library(dplyr)
library(lubridate)
dataset <- dataset %>% 
  mutate(Year = year(dataset$OrderDate),
         Month = month(dataset$OrderDate, label = TRUE))


#=============================================================================
#
# Visualization #1 - Aggregaed dynamic bar charts by Customer Category
#
#=============================================================================

library(dplyr)
library(ggplot2)
library(scales)


# Get total revenue by Buying Group, Supplier Category and Customer Catetory
customer.categories <- dataset %>%
  group_by(BuyingGroupName, SupplierCategoryName, CustomerCategoryName) %>%
  summarize(TotalRevenue = sum(LineTotal))

# Aggregate data across all supplier categories
all.suppliers <- dataset %>%
  group_by(BuyingGroupName, CustomerCategoryName) %>%
  summarize(TotalRevenue = sum(LineTotal))
all.suppliers$SupplierCategoryName <- "All Suppliers"

# Add aggregated data
customer.categories <- rbind(customer.categories,
                             all.suppliers)


# Format visualization title string dynamically
title.str.1 <- paste("Total Revenue for",
                     dataset$Year[1],
                     "by Buying Group and Supplier/Customer Categories for",
                     nrow(dataset),
                     "Rows of Data",
                     sep = " ")


# Plot 
ggplot(customer.categories, aes(x = CustomerCategoryName, y = TotalRevenue, fill = BuyingGroupName)) +
  theme_bw() +
  coord_flip() +
  facet_grid(BuyingGroupName ~ SupplierCategoryName) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = comma) +
  theme(text = element_text(size = 18),
        axis.text.x = element_text(size = 12, angle=90, hjust=1)) +
  labs(x = "Customer Category",
       y = "Total Revenue",
       fill = "Buying Group",
       title = title.str.1)







#=============================================================================
#
# Visualization #2 - Aggregated Process Behavior Charts
#
#=============================================================================


# Add artificial filtering for example
dataset <- dataset %>%
  filter(is.na(BuyingGroupName) & 
         (Year == 2013 | Year == 2014))


# Power BI code starts here
library(dplyr)
library(qcc)

# Grab year variables
Year1 <- min(dataset$Year)
Year2 <- max(dataset$Year)

# Accumulate totals
totals <- dataset %>%
  filter(Year == Year1| Year == Year2 ) %>%
  mutate(Month = substr(Month, 1, 3),
         MonthNum =  match(Month, month.abb)) %>%
  group_by(Year, MonthNum, Month) %>%
  summarize(TotalRevenue = sum(LineTotal)) %>%
  mutate(Label = paste(Month, Year, sep = "-")) %>%
  arrange(Year, MonthNum)

# Make labels pretty with dummy vars
Revenue.Group.1 <- totals$TotalRevenue[1:12]
Revenue.Group.2 <- totals$TotalRevenue[13:24]

title.str <- paste("Process Behavior Chart - ", Year1, " and ", Year2, " ",
                   dataset$CustomerCategoryName[1], " Total Revenue for Buying Group '",
                   dataset$BuyingGroupName[1], "'", sep = "")

# Plot
blank.super.qcc <- qcc(Revenue.Group.1, type = "xbar.one",
                       newdata = Revenue.Group.2,
                       labels = totals$Label[1:12], 
                       newlabels = totals$Label[13:24],
                       title = title.str,
                       ylab = "Total Revenue", xlab = "Month-Year")
