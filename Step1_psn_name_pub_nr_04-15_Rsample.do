
clear all
cd D:\KDI\Innovation\Data\PATSTAT\table\dta

use appln_id_pat_publn_id, clear
joinby pat_publn_id using publn_id_04_15
gen pub_nr = publn_auth+publn_nr+publn_kind

* keep if publn_auth=="KR"		// KR patents only -> save as "psn_name_pub_nr_04-15_KR_Rsample.dta"
gen priority=1 if publn_auth=="KR"
replace priority=2 if publn_auth=="WO"
replace priority=3 if publn_auth=="US"
replace priority=4 if publn_auth=="EP"
replace priority=5 if publn_auth=="DE"
replace priority=6 if publn_auth=="CA"
replace priority=7 if publn_auth=="JP"
replace priority=8 if publn_auth=="CN"
replace priority=9 if publn_auth=="TW"
replace priority=10 if priority==.

bysort pub_nr: egen copat = count(publn_nr)
gsort appln_id priority copat -pub_nr
by appln_id: gen n=_n
keep if n==1
drop n copat

joinby appln_id using semi_table_04_15
bysort pub_nr: egen copat = count(publn_nr)
gsort psn_name priority copat -pub_nr
by psn_name: gen n=_n
keep if n==1
drop n copat count*

merge 1:1 psn_name using person_id_group_foreign_firms
keep if _merge==1		// keep only Korean firms

compress
contract psn_name pat_publn_id pub_nr
drop _freq
order psn_name pat_publn_id pub_nr
save psn_name_pub_nr_04-15_Rsample, replace
*save psn_name_pub_nr_04-15_KR_Rsample, replace

use psn_name_pub_nr_04-15_Rsample, clear
keep if substr(pub_nr,1,2)=="WO"
replace pub_nr = regexs(1)+regexs(2) if regexm(pub_nr, "(^[A-Z][A-Z])([0-9]+)([A-Z][0-9]*$)")
save psn_name_pub_nr_04-15_WO_Rsample, replace
