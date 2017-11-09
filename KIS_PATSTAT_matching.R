

rm(list = ls())                     # Remove all
setwd("D:/KDI/Innovation/Data/")    # Working Directory
version <- "r2"

library(rio)
library(openxlsx)
library(matlab)
library(stringi)
library(stringr)
library(stringdist)

# Define functions
match.jw <- function(PAT) {
      mscore <- stringdist(stdname.KIS, PAT, method='jw', p=0.1)
      best.match <- stdname.KIS[mscore==min(mscore) & mscore<1]
      }

match.jaccard <- function(PAT) {
      mscore <- stringdist(stdname.KIS, PAT, method="jaccard", q=2)
      best.match <- stdname.KIS[mscore==min(mscore) & mscore<1]
      }

match.qgram <- function(PAT) {
      mscore <- stringdist(stdname.KIS, PAT, method="qgram", q=2)
      best.match <- stdname.KIS[mscore==min(mscore) & mscore<5]
      }

match.levenshtein <- function(PAT) {
      mscore <- stringdist(stdname.KIS, PAT, method="lv")
      best.match <- stdname.KIS[mscore==min(mscore) & mscore<=3]
      }

match.lcs <- function(PAT) {
      mscore <- stringdist(stdname.KIS, PAT, method="lcs")
      best.match <- stdname.KIS[mscore==min(mscore) & mscore<=3]
      }

list2df <- function(argument) {
      var <- list(KISname = argument)
      class(var) <- c("tbl_df", "data.frame")
      attr(var, "row.names") <- .set_row_names(length(argument))
      if (!is.null(names(argument))) {
            var$PATname <- names(argument)
            }
      as.data.frame(var)
      }


# Setup Excel file 
wb <- createWorkbook()
addWorksheet(wb, "Matched_Sample")


# Import data
KISname <- import(paste0("KIS_ENGname_Standardized_",version,".dta"))
stdname.KIS <- trimws(paste0(trimws(paste0(KISname[,3]," ",KISname[,4]))," ",KISname[,5]))
stdname.KIS <- stri_unique(stdname.KIS)

PATname <- import(paste0("PAT_ENGname_Standardized_",version,".dta"))
stdname.PAT <- trimws(paste0(trimws(paste0(PATname[,3]," ",PATname[,4]))," ",PATname[,5]))
writeDataTable(wb, 1, cbind(PATname, stdname.PAT))


# Match by Jaro-Winkler method
result.jw <- list()
result.jw <- sapply(stdname.PAT, match.jw)
result.jw <- list2df(result.jw)
result.jw$KISname <- as.character(result.jw$KISname)
result.jw$KISname <- gsub("[c()\"]", "", result.jw$KISname)
colnames(result.jw) <- c("KISname_jw","PATname")
writeDataTable(wb, 1, as.data.frame(result.jw$KISname), startCol=9, withFilter=FALSE)


# Match by Jaccard method
result.jaccard <- list()
result.jaccard <- sapply(stdname.PAT, match.jaccard)
result.jaccard  <- list2df(result.jaccard)
result.jaccard$KISname <- as.character(result.jaccard$KISname)
result.jaccard$KISname <- gsub("[c()\"]", "", result.jaccard$KISname)
colnames(result.jaccard) <- c("KISname_jac","PATname")
writeDataTable(wb, 1, as.data.frame(result.jaccard$KISname), startCol=10, withFilter=FALSE)


# Match by Generalized Levenshtein method
result.levenshtein <- list()
result.levenshtein <- sapply(stdname.PAT, match.levenshtein)
result.levenshtein  <- list2df(result.levenshtein)
result.levenshtein$KISname <- as.character(result.levenshtein$KISname)
result.levenshtein$KISname <- gsub("[c()\"]", "", result.levenshtein$KISname)
colnames(result.levenshtein) <- c("KISname_lv","PATname")
writeDataTable(wb, 1, as.data.frame(result.levenshtein$KISname), startCol=11, withFilter=FALSE)


# Match by qgram method
result.qgram <- list()
result.qgram <- sapply(stdname.PAT, match.qgram)
result.qgram  <- list2df(result.qgram)
result.qgram$KISname <- as.character(result.qgram$KISname)
result.qgram$KISname <- gsub("[c()\"]", "", result.qgram$KISname)
colnames(result.qgram) <- c("KISname_qgram","PATname")
writeDataTable(wb, 1, as.data.frame(result.qgram$KISname), startCol=12, withFilter=FALSE)


# Match by LCS method
result.lcs <- list()
result.lcs <- sapply(stdname.PAT, match.lcs)
result.lcs  <- list2df(result.lcs)
result.lcs$KISname <- as.character(result.lcs$KISname)
result.lcs$KISname <- gsub("[c()\"]", "", result.lcs$KISname)
colnames(result.lcs) <- c("KISname_lcs","PATname")
writeDataTable(wb, 1, as.data.frame(result.lcs$KISname), startCol=13, withFilter=FALSE)


# Export to excel file
saveWorkbook(wb, paste0("KIS_PATSTAT_Rmatched_",version,".xlsx"), overwrite=TRUE)

