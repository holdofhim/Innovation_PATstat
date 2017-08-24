
clear all
cd D:\KDI\Innovation\Data
use Patent_RnD_Exporters_05-15, clear

rename ksic9_5d ind5
gen ind4 = int(ind5/10)
gen n_exporters=1 if partner1~=""
collapse (sum) pat util* n_countries n_exporters, by(year ind5)
keep if inrange(ind5,10000,34000)

save Patent_by_Industry_2005-2015, replace



use Patent_by_Industry_2005-2015, clear
gen ind2 = int(ind5/1000) 
collapse (sum) pat util* n_countries n_exporters, by(year)

foreach x of varlist patent utility {
	bysort year: egen `x'_tot = total(`x')
	}

keep if year==2015

