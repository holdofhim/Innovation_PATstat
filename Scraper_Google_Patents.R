

# version: 2017-11-11

rm(list = ls())
setwd("D:/KDI/Innovation/Data/PATSTAT/table/raw")
dtafile <- "D:/KDI/Innovation/Data/PATSTAT/table/dta/psn_name_pub_nr_04-15_Rsample.dta"

library(rvest)
library(haven)
library(RCurl)
library(stringr)
library(magrittr)
library(parallel)
library(foreach)
library(doParallel)

## Set url address and Import data for patent publication number

url    <- "https://patents.google.com/patent/"
sample <- read_dta(dtafile)
pub_nr <- as.matrix(sample[,"pub_nr"])



## Preferred Method: do the parallel computing using all sample

# 1. Obtain the list of urls that are alive

n_cores <- detectCores()-1
cl <- makeCluster(n_cores)

clusterEvalQ(cl, library(RCurl))
clusterEvalQ(cl, library(rvest))
clusterEvalQ(cl, library(magrittr))
clusterExport(cl, c('url','pub_nr'))

system.time ({ urlexists <- parSapply(cl, paste0(url,pub_nr), url.exists) })

stopCluster(cl)   # Stop Cluster
save(urlexists, file="urlexists_04-15.Rdata")


# 2. Scrap firm names in Korean using RCurl & rvest package save them in firmname_04-15.Rdata

n_cores <- detectCores()-1
cl <- makeCluster(n_cores)

clusterEvalQ(cl, library(RCurl))
clusterEvalQ(cl, library(rvest))
clusterEvalQ(cl, library(magrittr))
clusterExport(cl, c('url','pub_nr','urlexists'))

system.time ({ firmnames_kr <- parSapply(cl, pub_nr[urlexists==TRUE],
                                         function(x) {
                                               paste0(url,x) %>%
                                                     read_html(.) %>%
                                                     html_nodes("dd") %>%
                                                     .[which(substr(.,15,30)=="assigneeOriginal")] %>%
                                                     html_text
                                         } ) })

stopCluster(cl)   # Stop Cluster
save(firmnames_kr, file="firmnames_04-15.Rdata") 



## Coerce to a dataframe (change duplicated values into blank) and save firmnames in csv file

n_cols <- sapply(firmnames_kr, function(x) length(as.vector(x))) %>% max      # max number of publn_numbr+firmnames
pub_nr_fname_kr <- sapply(firmnames_kr, function(x) c(as.vector(x), rep("",n_cols-length(x)))) %>% t()
write.csv(pub_nr_fname_kr, "D:/KDI/Innovation/Data/PATSTAT/firmnames_04-15.csv")



# # Alternative Method: Divide sample by grid size and do the same parallel computing
# 
# 
# n_cores <- detectCores()-1
# cl <- makeCluster(n_cores)
# 
# clusterEvalQ(cl, library(RCurl))
# clusterEvalQ(cl, library(rvest))
# clusterEvalQ(cl, library(magrittr))
# clusterExport(cl, c('url','pub_nr'))
# 
# n_obs  <- length(pub_nr)
# grid   <- 100
# n_rep  <- round(n_obs/grid)+1
# urlexists_kr <- data.frame()
# firmnames_kr <- data.frame()
# 
# for (i in 1:n_rep) {
# 
#       if (i<n_rep) publn_numbr <- pub_nr[((i-1)*grid+1):(i*grid)]
#       else publn_numbr <- pub_nr[((i-1)*grid+1):n_obs]
# 
#       urlexists <- parSapply(cl, paste0(url,publn_numbr), url.exists)
#       firmname_kr <- parSapply(cl, publn_numbr[urlexists==TRUE],
#                                function(x) {
#                                      paste0(url,x) %>%
#                                            read_html(.) %>%
#                                            html_nodes("dd") %>%
#                                            .[which(substr(.,15,30)=="assigneeOriginal")] %>%
#                                            html_text
#                                }
#       )
#       urlexists_kr <- rbind(urlexists_kr, urlexists)
#       firmnames_kr <- rbind(firmnames_kr, firmname_kr)
# }
# 
# stopCluster(cl)   # Stop Cluster



## Additional Information
#
#prior_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,32)=="priorityDate")] %>% .[1] %>% html_text)
#appln_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,30)=="filingDate")] %>% .[1] %>% html_text)
#publn_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,35)=="publicationDate")] %>% .[1] %>% html_text)
#grant_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,29)=="grantDate")] %>% .[1] %>% html_text)


## Use the following code for a single Patent Scraping
# 
# goopat <- read_html(paste0(url,"KR20100132724"))
# bio  <- goopat %>% html_nodes("dd")
# info <- goopat %>% html_nodes("h2") %>% html_text
# family <- goopat %>% html_nodes("span .display:")
# 
# publn_numbr <- bio[which(substr(bio,15,31)=="publicationNumber")] %>% html_text
# firmname_kr <- bio[which(substr(bio,15,30)=="assigneeOriginal")] %>% html_text
# prior_date  <- bio[which(substr(bio,21,32)=="priorityDate")] %>% .[1] %>% html_text
# appln_date  <- bio[which(substr(bio,21,30)=="filingDate")] %>% .[1] %>% html_text
# publn_date  <- bio[which(substr(bio,21,35)=="publicationDate")] %>% .[1] %>% html_text
# grant_date  <- bio[which(substr(bio,21,29)=="grantDate")] %>% .[1] %>% html_text
# n_citation  <- as.integer(str_extract(info[which(substr(info,1,15)=="Families Citing")], "[0-9]+"))

