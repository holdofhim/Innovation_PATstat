
clear all
cd D:\KDI\Innovation\Data

import excel using "D:\Mega\광공업통계\HHI\산업집중률(2009-2011).xlsx", sheet("2010년") cellrange(A2) clear
keep A C E F
rename (A C E F) (ind5 n_firms cr3 hhi)
destring ind5, replace
keep if inrange(ind5,10000,34000)
gen year=2010
order year
sort year ind5

save HHI_by_Industry_2010, replace
