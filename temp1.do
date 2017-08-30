
clear all
cap log close
set more off
gl path "c:\KDI\Innovation\Data"
cd $path

use Patent_registration_2002-2015, clear
collapse (sum)patent, by(kedid)
drop if patent==0
rename kedid ked_id

joinby ked_id using KED_Firmlist_withPatents
format business_no %10.0f
sort business_no ked_id
bysort business: gen freq = _n
drop if freq>1			// keep only the first obs. if the same firm has multiple ked_ids

noi merge 1:1 business_no using KIS_All_FirmList, update replace
drop if _merge==2
drop _merge freq

replace ked_eng = kis_eng if ked_eng=="" & kis_eng~=""




use KIS_All_FirmList, clear
gen ksic9_2d = int(ksic9_5d/1000)
order ksic9_2d, before(ksic9_5d)
keep if inrange(ksic9_2d,10,33) | inrange(ksic9_2d,60,63) | inrange(ksic9_2d,70,73) 
keep if inrange(listed,10,40)					// keep only existing companies
keep if inrange(type,1,4)							// keep only corporate companies
drop if kis_eng==""

noi merge 1:1 business_no using KED_Firmlist_wPatents, nogen
foreach x in "eng" "zip" "add" "phone" {
	replace kis_`x'=ked_`x' if kis_`x'==""
	}
drop ked_eng-ked_phone
format business_no %10.0f
