
clear all
cd D:\KDI\Innovation\Data

use PATSTAT\table\dta\semi_table_04_15, clear
replace psn_name = trim(itrim(upper(psn_name)))
collapse (count)n_patents=appln_id (sum)n_cites=count_citing_, by(psn_name)

noi merge m:1 psn_name using PATSTAT\table\dta\person_id_group_foreign_firms
keep if _merge==1
drop _m person_ctry

gsort -n_patents -n_cites psn_name
save N_Patents_04_15, replace
