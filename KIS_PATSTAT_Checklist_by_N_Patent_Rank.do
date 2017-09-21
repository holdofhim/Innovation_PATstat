clear all

import excel "D:\KDI\Innovation\Data\KIS_PATSTAT_Rmatched_v1_checked.xlsx", sheet("Sheet1") cellrange(A1:R83512) firstrow clear
merge 1:1 psn_name using "D:\KDI\Innovation\Data\PATSTAT\table\dta\person_id_group_foreign_firms.dta"
keep if _merge==1
drop _merge person_ctry_code
merge 1:1 psn_name using "D:\KDI\Innovation\Data\N_Patents_by_psnname.dta"
keep if _merge==3

gsort -n_patents
drop _merge
export excel using "D:\KDI\Innovation\Data\KIS_PATSTAT_checklist_by_N_patent_rank.xlsx",first(var)
