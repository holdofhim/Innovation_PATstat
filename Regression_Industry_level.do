
clear all
cd d:\KDI\TradeDB\KOR_trade

use ksic5_kosis_2010.dta, clear
append using ksic5_kosis_2015

cd D:\KDI\Innovation\Data
rename (ksic5 사업체수 종사자수 매출액 경상연구개발비) (ind5 n_plants emp sales rnd)
destring ind5, replace
replace income = strlower(income)
replace income = subinstr(income," income","",.)
replace income = "low" if income=="lower middle"
replace income = "low" if income=="upper middle"

collapse n_plants emp sales rnd (sum) exports imports, by(year ind5 income_group)
gen ind2 = int(ind5/1000)
gen ind3 = int(ind5/100)
gen ind4 = int(ind5/10)
bysort year ind5: egen exports_tot = total(exports)
bysort year ind5: egen imports_tot = total(imports)

drop if income==""
rename (exports imports) (exports_ imports_)
rename *_tot *
reshape wide exports_ imports_, i(year ind5) j(income_group) s
collapse (sum) n_plants emp sales rnd exports* imports*, by(year ind5 ind2-ind4)
joinby year ind5 using Patent_by_Industry_2005-2015
merge 1:1 year ind5 using HHI_by_Industry_2010, nogen

keep if sales>exports
gen lp = sales/emp
gen domsales = sales-exports
gen rndsales = rnd/sales*100
gen patsales = utilpat/sales*100
gen patshare = utilpat/n_plants
gen impen = domsales/sales*imports/(domsales+imports)*100
gen impen_low = domsales/sales*imports_low/(domsales+imports)*100
gen impen_high = domsales/sales*imports_high/(domsales+imports)*100
gen expsales = exports/sales*100
gen expshare = n_exporters/n_plants*100
keep if inrange(impen,1,99) & inrange(expsales,1,99)

foreach x of varlist n_plants-expshare {
	gen ln`x' = log(`x')
	}
gen lnimpen2 = lnimpen^2
	
*two scatter lnrndsales lnimpen || lfit lnrndsales lnimpen
two scatter lnpatsales lnimpen || lfit lnpatsales lnimpen
*two scatter lnrndsales lnexpsales || lfit lnrndsales lnexpsales


sort ind5 year
replace year=2011 if year==2015
xtset ind5 year
foreach y of varlist ln* {
	bysort ind5: g d`y' = d.`y'
	bysort ind5: g `y'_lag = l.`y'
	}

gen interact = lnexpsales*lnlp

eststo: xtreg lnpatsales lnimpen_low lnimpen_high, fe robust cluster(ind2)
eststo: xtreg lnrndsales lnimpen_low lnimpen_high, fe robust cluster(ind2)
eststo: xtreg lnn_plants lnimpen_low lnimpen_high, fe robust cluster(ind2)
eststo: xtreg lnemp lnimpen_low lnimpen_high, fe robust cluster(ind2)

cd D:\KDI\Innovation\Analysis
forvalue i=1/4 {
	est restore est`i'
	if `i'==1 noi outreg2 using table1, bdec(3) nocons noni replace
	else if `i'>1 & `i'<4 noi outreg2 using table1, bdec(3) nocons noni append
	else  noi outreg2 using table1, bdec(3) nocons noni append tex
	}

