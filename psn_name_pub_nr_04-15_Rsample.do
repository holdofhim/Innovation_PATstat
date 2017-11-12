
clear all
cd D:\KDI\Innovation\Data\PATSTAT\table\dta

use appln_id_pat_publn_id, clear
joinby pat_publn_id using publn_id_04_15
gen pub_nr = publn_auth+publn_nr+publn_kind

* keep if publn_auth=="KR"		// KR patents only -> save as "psn_name_pub_nr_04-15_KR_Rsample.dta"
gsort appln_id -publn_date publn_nr
bysort appln_id: gen n=_n
keep if n==1
drop n

joinby appln_id using semi_table_04_15
gsort psn_name -publn_date publn_nr
bysort psn_name: gen n=_n
keep if n==1

merge 1:1 psn_name using person_id_group_foreign_firms
keep if _merge==1		// keep only Korean firms

compress
keep  psn_name pat_publn_id pub_nr
order psn_name pat_publn_id pub_nr
save psn_name_pub_nr_04-15_Rsample, replace
*save psn_name_pub_nr_04-15_KR_Rsample, replace
