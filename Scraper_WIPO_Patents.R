

# version: 2017-11-11

rm(list = ls())
setwd("D:/KDI/Innovation/Data/PATSTAT/table/raw")
dtafile <- "D:/KDI/Innovation/Data/PATSTAT/table/dta/psn_name_pub_nr_04-15_WO_Rsample.dta"

library(rvest)
library(haven)
library(RCurl)
library(stringr)
library(magrittr)
library(parallel)
library(foreach)
library(doParallel)



## Set url address and Import data for patent publication number

url    <- "https://patentscope.wipo.int/search/en/detail.jsf?docId="
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
#save(urlexists, file="publn_id_pub_nr_04-15_KR_urlexists.Rdata")


# 2. Scrap firm name, address, and designated states

n_cores <- detectCores()-1
cl <- makeCluster(n_cores)

clusterEvalQ(cl, library(RCurl))
clusterEvalQ(cl, library(rvest))
clusterEvalQ(cl, library(magrittr))
clusterExport(cl, c('url','pub_nr','urlexists'))

system.time ({ pctds <- parSapply(cl, pub_nr,
                                         function(x) {
                                               paste0(url,x) %>%
                                               read_html(.) %>%
                                               html_nodes(".PCTds") %>%
                                               html_text 
                                         } ) })

stopCluster(cl)   # Stop Cluster

