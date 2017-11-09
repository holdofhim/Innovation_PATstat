
clear all
cap log close
set more off

cd D:\KDI\Innovation\Data
import excel using KIS_PATSTAT_Rmatched_v1.xlsx, first clear

* KISnames by Matching Method
rename result*$KISname * 
rename *KISname KISname_*

* Find the perfect Matches: 1 if perfect match
foreach x of varlist KISname* {
	gen matched`x' = 1 if stdnamePAT==`x'
	}
rename matchedKISname* matched*

* Export the Results in Excel file
export excel using KIS_PATSTAT_Rmatched_v1_checked.xlsx, first(var) sheetmodify
