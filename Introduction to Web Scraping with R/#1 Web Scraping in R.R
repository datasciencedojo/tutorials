# install.packages("rvest")
library(rvest)
library(stringr)

#################################################################################
# ingress
#################################################################################
# scrape date, now
now <- Sys.time()

# url to scrape, then download page
url <- "https://www.newegg.com/Desktop-Graphics-Cards/SubCategory/ID-48"
webpage <- read_html(url)



#################################################################################
# parsing elements
#################################################################################

############
# feature: card name
############
card_name <- webpage %>% html_nodes(".item-title") %>% html_text()

################
# feature: current price
################
cur_price <- webpage %>% html_nodes(".price-current strong") %>% html_text()

################
# feature: brand
################
brand <- webpage %>% html_nodes(".item-brand img") %>% html_attr("title")

################
# feature: shipping
################
shipping <- webpage %>% html_nodes(".price-ship") %>% html_text(trim=TRUE)
shipping <- str_replace_all(string = shipping, pattern = " Shipping", replacement = "")



#################################################################################
# data binding
#################################################################################
graphics_cards <- as.data.frame(card_name)
graphics_cards$scrape_date <- now
graphics_cards$cur_price <- cur_price
graphics_cards$brand <- brand
graphics_cards$shipping <- shipping



#################################################################################
# egress
#################################################################################

# change this to your own working folder
setwd("C:/Users/Phuc H Duong/Downloads/newegg")

# write file out as a csv
write.csv(
    x = graphics_cards,
    file = "graphics_card_report.csv",
    row.names = FALSE
)

