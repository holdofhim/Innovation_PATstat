

clear all
cap log close
set more off
cd D:\KDI\Innovation\Data

use PATSTAT\table\dta\person_id_group, clear
replace psn_name = trim(itrim(upper(psn_name)))
drop if inlist(person_ctry,"","KR")
sort person_id psn_name

save PATSTAT\table\dta\person_id_group_foreign_firms, replace
