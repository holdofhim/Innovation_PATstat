
clear all
set more off

cd D:\KDI\Innovation\Data
import delimited using D:\OneDrive\OECD_Patent\HAN_201609\201609_HAN_NAME.txt, delimit("|")
merge 1:n han_id using C:\KDI\Innovation\Data\kr
drop if _merge==1 & person_ctry~="KR"
sort psn_name person_id han_id _merge
compress
