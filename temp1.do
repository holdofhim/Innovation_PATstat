
clear all
cd D:\KDI\Innovation\Data

import excel using ReviewList\45000\KIS_PATSTAT_Matchinglist_45000.xlsx, firstrow
merge n:1 psn_name using N_Patents_04_15
keep if _m==3
gsort -n_patents -n_cites
*drop if n_patents==1 & n_cites==0
*replace matched_name="" if matched_name=="0"
count if matched_name==""
