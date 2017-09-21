
clear all
cap log close
set more off

cd D:\KDI\Innovation\Data
import excel using KIS_PATSTAT_Rmatched_v1.xlsx, first clear
rename result*$KISname * 
rename *KISname KISname_*

foreach x of varlist KISname* {
	gen matched`x' = 1 if stdnamePAT==`x'
	}
rename matchedKISname* matched*
export excel using KIS_PATSTAT_Rmatched_v1_checked.xlsx, first(var) sheetmodify
