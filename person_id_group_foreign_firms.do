

clear all
cap log close
set more off
cd D:\KDI\Innovation\Data

use PATSTAT\table\dta\person_id_group, clear
replace psn_name = trim(itrim(upper(psn_name)))
contract psn_name person_ctry

drop if inlist(person_ctry,"")
gsort psn_name -_freq
bysort psn_name: gen r_ctry=_n
keep if r_ctry==1 & person_ctry~="KR"
drop if _freq<2
drop _f r_ctry
sort person psn_name

save PATSTAT\table\dta\person_id_group_foreign_firms, replace
