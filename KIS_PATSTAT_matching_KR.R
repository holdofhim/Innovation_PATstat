

rm(list = ls())                     # Remove all
setwd("D:/KDI/Innovation/Data/")    # Working Directory
version <- "v1"

library(rio)
library(openxlsx)
library(matlab)
library(stringi)
library(stringr)
library(stringdist)
library(parallel)


# Define list2df functions

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

KISname <- import(paste0("KIS_KORname_Standardized.dta"))
stdname.KIS <- trimws(KISname[,1])
stdname.KIS <- stri_unique(stdname.KIS)

PATname <- import(paste0("PAT_KORname_Standardized_",version,"_unmatched.dta"))
stdname.PAT <- trimws(PATname[,3])
writeDataTable(wb, 1, as.data.frame(cbind(PATname[,1], stdname.PAT)))



# Match by Jaro-Winkler &  Generalized Levenshtein method

n_cores <- detectCores()-1
cl <- makeCluster(n_cores)

clusterEvalQ(cl, library(stringdist))
clusterExport(cl, c('stdname.KIS','stdname.PAT'))

result.jw <- parSapply(cl, stdname.PAT, function(PAT) {
                                                mscore <- stringdist(stdname.KIS, PAT, method='jw', p=0.1)
                                                best.match <- stdname.KIS[mscore==min(mscore) & mscore<1]
                                                } )

result.lv <- parSapply(cl, stdname.PAT, function(PAT) {
                                                mscore <- stringdist(stdname.KIS, PAT, method="lv")
                                                best.match <- stdname.KIS[mscore==min(mscore) & mscore<=3]
                                                } )

# result.lcs <- parSapply(cl, stdname.PAT, function(PAT) {
#                                                 mscore <- stringdist(stdname.KIS, PAT, method="lcs")
#                                                 best.match <- stdname.KIS[mscore==min(mscore) & mscore<=3]
#                                                 } )

stopCluster(cl)   # Stop Cluster



## Change datatype and write the data in excel format

result.jw <- list2df(result.jw)
result.jw$KISname <- as.character(result.jw$KISname)
result.jw$KISname <- gsub("[c()\"]", "", result.jw$KISname)
colnames(result.jw) <- c("KISname_jw","PATname")
writeDataTable(wb, 1, as.data.frame(result.jw$KISname), startCol=6, withFilter=FALSE)

result.lv  <- list2df(result.lv)
result.lv$KISname <- as.character(result.lv$KISname)
result.lv$KISname <- gsub("[c()\"]", "", result.lv$KISname)
colnames(result.lv) <- c("KISname_lv","PATname")
writeDataTable(wb, 1, as.data.frame(result.lv$KISname), startCol=7, withFilter=FALSE)

# result.lcs  <- list2df(result.lcs)
# result.lcs$KISname <- as.character(result.lcs$KISname)
# result.lcs$KISname <- gsub("[c()\"]", "", result.lcs$KISname)
# colnames(result.lcs) <- c("KISname_lcs","PATname")
# writeDataTable(wb, 1, as.data.frame(result.lcs$KISname), startCol=8, withFilter=FALSE)



# Save the results in excel file

saveWorkbook(wb, paste0("KIS_PATSTAT_Rmatched_KOR_",version,".xlsx"), overwrite=TRUE)

