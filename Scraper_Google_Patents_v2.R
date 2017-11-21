

# version: 2017-11-11

rm(list = ls())
setwd("D:/KDI/Innovation/Data/PATSTAT/table/raw")
dtafile <- "D:/KDI/Innovation/Data/PATSTAT/table/dta/psn_name_pub_nr_04-15_KR_Rsample.dta"

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
pub_nr <- as.matrix(sample[1:10,"pub_nr"])



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
#save(urlexists, file="publn_id_pub_nr_04-15_KR_urlexists.Rdata")


# 2. Scrap firm names (in Korean)

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
                                               grep("applicationNumber|assigneeOriginal", ., value=TRUE) %>%
                                               html_text 
                                         } ) })

stopCluster(cl)   # Stop Cluster
#save(firmnames_kr, file="publn_id_pub_nr_04-15_KR_firmnames.Rdata") 


# Coerce to a dataframe (change duplicated values into blank) and save firmnames in csv file

# n_cols <- sapply(firmnames_kr, function(x) length(as.vector(x))) %>% max      # max number of firmnames
# fname_kr <- sapply(firmnames_kr, function(x) c(as.vector(x), rep("",n_cols-length(x)))) %>% t()
# write.csv(fname_kr, "D:/KDI/Innovation/Data/PATSTAT/pub_nr_04-15_KR_firmnames.csv")


# 3. Scrap patent family

n_cores <- detectCores()-1
cl <- makeCluster(n_cores)

clusterEvalQ(cl, library(RCurl))
clusterEvalQ(cl, library(rvest))
clusterEvalQ(cl, library(magrittr))
clusterExport(cl, c('url','pub_nr','urlexists'))

system.time ({ family <- parSapply(cl, pub_nr[urlexists==TRUE],
                                         function(x) {
                                               paste0(url,x) %>%
                                               read_html(.) %>%
                                               html_nodes("a span") %>% 
                                               .[html_attr(.,"itemprop")=="representativePublication"] %>% 
                                               html_text %>% 
                                               unique 
                                         } ) })

stopCluster(cl)   # Stop Cluster
#save(family, file="publn_id_pub_nr_04-15_KR_family.Rdata") 


# 4. Scrap # of family citations

n_cores <- detectCores()-1
cl <- makeCluster(n_cores)

clusterEvalQ(cl, library(RCurl))
clusterEvalQ(cl, library(rvest))
clusterEvalQ(cl, library(magrittr))
clusterEvalQ(cl, library(stringr))
clusterExport(cl, c('url','pub_nr','urlexists'))

system.time ({ citation <- parSapply(cl, pub_nr[urlexists==TRUE],
                                         function(x) {
                                               paste0(url,x) %>%
                                               read_html(.) %>%
                                               html_nodes("h2") %>% 
                                               html_text %>% 
                                               grep("Cited By|Families Citing", ., value=TRUE)
                                         } ) })

direct_citation <- parSapply(cl, citation, function(x) x[substr(x,1,8)=="Cited By"] %>% 
                                                       str_extract(.,"[0-9]+") %>%
                                                       as.integer %>% 
                                                       .[1])
family_citation <- parSapply(cl, citation, function(x) x[substr(x,1,15)=="Families Citing"] %>% 
                                                       str_extract(.,"[0-9]+") %>%
                                                       as.integer %>% 
                                                       .[1])
n_citations <- cbind(direct_citation, family_citation) %>% rowSums(., TRUE)

stopCluster(cl)   # Stop Cluster
# save(citation, file="publn_id_pub_nr_04-15_KR_citations.Rdata") 
# write.csv(cbind(direct_citation,family_citation,n_citations), 
#           "D:/KDI/Innovation/Data/PATSTAT/pub_nr_04-15_KR_n_citations.csv")




## Alternative Method: Divide sample by grid size and do the same parallel computing
# 
# n_obs  <- length(pub_nr)
# grid   <- 100
# n_rep  <- round(n_obs/grid)+1
# initial <- 0
# firmnames_kr <- {}
# 
# for (i in 1:n_rep) {
#       
#       if (i<n_rep) publn_numbr <- pub_nr[((i-1)*grid+1):(i*grid)]
#       else publn_numbr <- pub_nr[((i-1)*grid+1):n_obs]
#       
#       urlexists <- parSapply(cl, paste0(url,publn_numbr), url.exists)
#       firmname_kr <- parLapply(cl, publn_numbr[urlexists==TRUE],
#                                function(x) {
#                                      paste0(url,x) %>%
#                                            read_html(.) %>%
#                                            html_nodes("dd") %>%
#                                            .[which(substr(.,15,30)=="assigneeOriginal")] %>%
#                                            html_text %>%
#                                            c(x, .) 
#                                } 
#       )
#       firmnames_kr <- rbind(firmnames_kr, firmname_kr)
# }



## Additional Information
#
#prior_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,32)=="priorityDate")] %>% .[1] %>% html_text)
#appln_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,30)=="filingDate")] %>% .[1] %>% html_text)
#publn_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,35)=="publicationDate")] %>% .[1] %>% html_text)
#grant_dates <- parLapply(cl, bios, function(x) x[which(substr(x,21,29)=="grantDate")] %>% .[1] %>% html_text)


# Use the following code for a single Patent Scraping

goopat <- read_html(paste0(url,"KR101375232B1"))
bio  <- goopat %>% html_nodes("dd")
info <- goopat %>% html_nodes("h2") %>% html_text
family <- goopat %>% html_nodes("a span") %>%
          .[html_attr(.,"itemprop")=="representativePublication"] %>%
          html_text %>%
          unique
citation <- goopat %>% html_nodes("h2") %>%
            html_text %>%
            grep("Cited By|Families Citing", ., value=TRUE) %>%
            str_extract(., "[0-9]+") %>%
            as.integer
n_citiation <- sum(citation[1:2])
abstract <- goopat %>% html_nodes("div .abstract") %>% html_text
citation_url <- goopat %>% html_nodes("a") %>% html_attr("href")

publn_numbr <- bio[which(substr(bio,15,31)=="publicationNumber")] %>% html_text
firmname_kr <- bio[which(substr(bio,15,30)=="assigneeOriginal")] %>% html_text
prior_date  <- bio[which(substr(bio,21,32)=="priorityDate")] %>% .[1] %>% html_text
appln_date  <- bio[which(substr(bio,21,30)=="filingDate")] %>% .[1] %>% html_text
publn_date  <- bio[which(substr(bio,21,35)=="publicationDate")] %>% .[1] %>% html_text
grant_date  <- bio[which(substr(bio,21,29)=="grantDate")] %>% .[1] %>% html_text
n_citation  <- as.integer(str_extract(info[substr(info,1,15)=="Families Citing"], "[0-9]+"))

