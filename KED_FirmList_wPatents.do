

clear all
cap log close
set more off
gl path "D:\KDI\Innovation\Data"
cd $path

tempfile zipold zipnew
use D:\KDI\JMDATA\KED\KED_2002-2012, clear
contract KID Name_F Name_E ZipCode Address_1 Phone
drop _freq
rename (KID-Phone) (ked_id name_kor name_eng zipcode address phone)
save `zipold'

import delimited using D:\Datasets\KED\KED2010_2015\KED5002.txt, delim("|") encoding("EUC-KR") clear
rename (v1 v2 v4 v34 v35 v37 v41) (ked_id name_kor name_eng zipcode address phone ksic9_5d)
replace ksic9_5d = substr(ksic9_5d,2,5)
destring ksic9_5d, replace
drop v*
save `zipnew'

use Patent_Registration_2002-2015, clear
collapse (sum) utilpat, by(kedid)
drop if utilpat==0
joinby kedid using D:\KDI\JMDATA\KED\FirmID_2002-2015
rename kedid ked_id
noi merge 1:1 ked_id using `zipold'
drop if _m==2
drop _m
noi merge 1:1 ked_id using `zipnew', update
drop if _m==2
drop _m ipocode

gen name_len = strlen(name_eng)
gsort business_no -name_len ked_id
bysort business: gen freq=_n
drop if freq>1			// keep only the first obs. if the same firm has multiple ked_ids
drop freq

tostring zipcode, replace
replace zipcode = "" if strlen(zipcode)<4
replace zipcode = "0"+zipcode if strlen(zipcode)==4

compress
format business_no %10.0f
order utilpat, after(phone)
replace name_eng = upper(name_eng)
save KED_Firmlist_wPatents, replace

* Insert some missing English names
import excel using Firms_ENGname_Missing_Fillout.xlsx, clear firstrow
merge 1:1 business_no using KED_Firmlist_wPatents, update nogen
sort business_no
save KED_Firmlist_wPatents, replace
