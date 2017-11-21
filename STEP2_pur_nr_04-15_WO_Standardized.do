

clear all
cd D:\KDI\Innovation\Data\PATSTAT

import delimit using Patinfo_pub_nr_04-15_WO_unique.txt, enc("UTF-8") clear
keep v1 v2
rename (v1 v2) (pub_nr assignee)
replace assignee = regexr(assignee, "\[", "")
replace assignee = regexr(assignee, "\]", "")
replace assignee = subinstr(assignee, char(34), "", .)
replace assignee = subinstr(assignee, "'", "|", .)
replace assignee = trim(itrim(assignee))
replace assignee = upper(assignee)
split assignee, parse("|,")
drop assignee


** Data Parse

nvars assignee
forval i=1/`r(nvars)' {
	replace assignee`i' = subinstr(assignee`i', "|", " ", .)
	replace assignee`i' = subinstr(assignee`i', ",", " ", .)
	replace assignee`i' = subinstr(assignee`i', ".", " ", .)
	replace assignee`i' = "" if regexm(assignee`i', "\\X")
	replace assignee`i' = trim(itrim(assignee`i'))
	replace assignee`i' = "" if regexm(assignee`i', "(^[A-Z].*\)$|^[A-Z0-9].*[A-Z]+$)")	
	gen fname_kr`i' = assignee`i'
	replace fname_kr`i' = regexs(2) if regexm(assignee`i', "(^[A-Z ]+)(.+$)")
	}


** Reshape and Standardize Name

drop assignee*
reshape long fname_kr, i(pub_nr) j(seq)
drop if fname_kr==""
replace fname_kr = regexs(1) if regexm(fname_kr, "(^.+)(\([A-Z]+\)$)")
replace fname_kr = trim(fname_kr)
contract pub_nr fname_kr
drop _f
by pub_nr: gen seq=_n
save STEP2_pur_nr_04-15_WO_Standardized, replace


/*
replace assignee1 = subinstr(assignee1, "|", " ", .)
replace assignee1 = subinstr(assignee1, ",", " ", .)
replace assignee1 = subinstr(assignee1, ".", " ", .)
replace assignee1 = "" if regexm(assignee1, "\\X")
replace assignee1 = regexs(1) if regexm(assignee1, "([A-Z0-9 -&@]+)(\(.*\)$)")	
replace assignee1 = trim(itrim(assignee1))
replace assignee1 = "" if regexm(assignee1, "(^[A-Z0-9].*[ A-Z0-9]+$)")	
gen fname_kr1 = assignee1
replace fname_kr1 = regexs(2) if regexm(assignee1, "(^[A-Z ]+)(.+$)")
*/
