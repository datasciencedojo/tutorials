#=======================================================================================
#
# File:        CustomerQuery.R
# Author:      Dave Langer
# Description: This code illustrates querying a SQL Server database via the RODBC 
#              package for the "Introduction to R Visualization with Power BI " Meetup 
#              dated 03/15/2017. More details on the Meetup are available at:
#
#                 https://www.meetup.com/Data-Science-Dojo-Toronto/events/237952698/
#
#              The code in this file leverages data from Microsoft's Wide World
#              Importers sample database available at:
#
#                 https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
#
# NOTE - This file is provided "As-Is" and no warranty regardings its contents are
#        offered nor implied. USE AT YOUR OWN RISK!
#
#=======================================================================================


# Uncomment and run these lines of code to install required packages
#install.packages("RODBC")

library(RODBC)

# Open connection using Windows ODBC DSN
dbhandle <- odbcConnect("RConnection")

# Query database for a denormalized view of [Fact][Sale] data
dataset <- sqlQuery(dbhandle, 
                    "SELECT [C].[CustomerID]
                    ,[C].[CustomerName]
                    ,[C].[BuyingGroupID]
                    ,[C].[DeliveryMethodID]
                    ,[C].[DeliveryCityID]
                    ,[C].[DeliveryAddressLine1]
                    ,[C].[DeliveryAddressLine2]
                    ,[CITY].[CityName]
                    ,[P].[StateProvinceCode]
                    ,[C].[DeliveryPostalCode]
                    ,[CC].[CustomerCategoryName]
                    ,[BG].[BuyingGroupName]
                    ,[O].[OrderID]
                    ,[O].[OrderDate]
                    ,[OL].[OrderLineID]
                    ,[OL].[Quantity]
                    ,[OL].[UnitPrice]
                    ,[OL].[Quantity] * [OL].[UnitPrice] AS [LineTotal]
                    ,[SC].[SupplierCategoryName]
                     FROM [WideWorldImporters].[Sales].[Customers] C
                        INNER JOIN [WideWorldImporters].[Sales].[CustomerCategories] CC ON ([C].[CustomerCategoryID] = [CC].[CustomerCategoryID])
                          LEFT OUTER JOIN [WideWorldImporters].[Sales].[BuyingGroups] BG ON ([C].[BuyingGroupID] = [BG].[BuyingGroupID])
                             INNER JOIN [WideWorldImporters].[Sales].[Orders] O ON ([C].[CustomerID] = [O].[CustomerID])
                                INNER JOIN [WideWorldImporters].[Sales].[OrderLines] OL ON ([O].[OrderID] = [OL].[OrderID])
                                   INNER JOIN [WideWorldImporters].[Warehouse].[StockItems] SI ON ([OL].[StockItemID] = [SI].[StockItemID])
                                      INNER JOIN [WideWorldImporters].[Purchasing].[Suppliers] S ON ([SI].[SupplierID] = [S].[SupplierID])
                                         INNER JOIN [WideWorldImporters].[Purchasing].[SupplierCategories] SC ON ([S].[SupplierCategoryID] = [SC].[SupplierCategoryID])
                                            INNER JOIN [WideWorldImporters].[Application].[Cities] CITY ON ([C].[DeliveryCityID] = [CITY].[CityID])
                                               INNER JOIN [WideWorldImporters].[Application].[StateProvinces] P ON ([CITY].[StateProvinceID] = [P].[StateProvinceID])",
                  stringsAsFactors = FALSE)

#Close DB connection
odbcClose(dbhandle)


# Save off data frame in .RData binary format
save(dataset, file = "CustomerData.RData")



