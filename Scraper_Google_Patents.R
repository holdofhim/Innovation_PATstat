

# version: 2017-11-10

rm(list = ls())
setwd("D:/KDI/Innovation/Data/PATSTAT/table/raw")
dtafile <- "D:/KDI/Innovation/Data/PATSTAT/table/dta/publn_id_04_15_Rsample.dta"

library(rvest)
library(haven)
library(RCurl)
library(stringr)


# Import CSV file for Publication Numbers

#publn_id <- read.csv("publn_id_04_15.csv")
#save(publn_id, file="publn_id_04_15.Rdata")


# Set-up and import dta file

url    <- "https://patents.google.com/patent/"
sample <- read_dta(dtafile)
pub_nr <- as.matrix(sample[,"pub_nr"])


# WEB scrapping with rvest package

urlexists  <- sapply(paste0(url,pub_nr), url.exists)
googlepats <- lapply(paste0(url,pub_nr[urlexists==TRUE]), read_html)


# Extract data using lapply

bios  <- lapply(googlepats, function(x) x %>% html_nodes("dd"))
infos <- lapply(googlepats, function(x) x %>% html_nodes("h2") %>% html_text())

publn_numbrs <- lapply(bios, function(x) x[which(substr(x,15,31)=="publicationNumber")] %>% html_text())
firmnames_kr <- lapply(bios, function(x) x[which(substr(x,15,30)=="assigneeOriginal")] %>% html_text())
#prior_dates <- lapply(bios, function(x) x[which(substr(x,21,32)=="priorityDate")] %>% .[1] %>% html_text())
#appln_dates <- lapply(bios, function(x) x[which(substr(x,21,30)=="filingDate")] %>% .[1] %>% html_text())
#publn_dates <- lapply(bios, function(x) x[which(substr(x,21,35)=="publicationDate")] %>% .[1] %>% html_text())
#grant_dates <- lapply(bios, function(x) x[which(substr(x,21,29)=="grantDate")] %>% .[1] %>% html_text())

save(publn_numbrs,firmnames_kr, file="firmnames_kr.Rdata") 



## Single Patent Scrapping
# 
# goopat <- read_html(paste0(url,"KR20100132724"))
# bio  <- goopat %>% html_nodes("dd")
# info <- goopat %>% html_nodes("h2") %>% html_text()
# family <- goopat %>% html_nodes("span .display:")
# 
# publn_numbr <- bio[which(substr(bio,15,31)=="publicationNumber")] %>% html_text()
# firmname_kr <- bio[which(substr(bio,15,30)=="assigneeOriginal")] %>% html_text()
# prior_date  <- bio[which(substr(bio,21,32)=="priorityDate")] %>% .[1] %>% html_text()
# appln_date  <- bio[which(substr(bio,21,30)=="filingDate")] %>% .[1] %>% html_text()
# publn_date  <- bio[which(substr(bio,21,35)=="publicationDate")] %>% .[1] %>% html_text()
# grant_date  <- bio[which(substr(bio,21,29)=="grantDate")] %>% .[1] %>% html_text()
# n_citation  <- as.integer(str_extract(info[which(substr(info,1,15)=="Families Citing")], "[0-9]+"))

