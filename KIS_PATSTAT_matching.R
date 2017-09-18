

rm(list = ls())                                 # Remove all
setwd("D:/KDI/Innovation/Data/Temp/")            # Working Directory

library(rio)
library(matlab)
library(stringi)
library(stringr)
library(stringdist)


KISname <- import("D:/KDI/Innovation/Data/KIS_ENGname_Standardized.dta")
engname.KIS <- trimws(paste0(trimws(paste0(KISname[,3]," ",KISname[,4]))," ",KISname[,5]))
engname.KIS <- stri_unique(engname.KIS)

match.jaccard <- function(PAT) {
    mscore <- stringdist(engname.KIS, PAT, method="jaccard", q=2)
    best.match <- c(PAT, engname.KIS[mscore==min(mscore)])
    }

match.jw <- function(PAT) {
  mscore <- stringdist(engname.KIS, PAT, method='jw', p=0.1)
  best.match <- c(PAT, engname.KIS[mscore==min(mscore)])
}

#for (i in 1:24) {
    PATname <- import(paste0("PAT_ENGname_Standardized",1,".dta"))
    engname.PAT <- trimws(paste0(trimws(paste0(PATname[,3]," ",PATname[,4]))," ",PATname[,5]))
    result.jaccard <- lapply(engname.PAT[11:21], match.jaccard)
    #result.jw <- lapply(engname.PAT[11:21], match.jw)
#    }

