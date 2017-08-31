
clear all
set more off
cd D:\KDI\Innovation\Data

* 1. Manually Copy & Paste the date from 행정구역분류 총괄표_170101.xlsx

/* 2. Data cleaning and save 
	rename var* v*
	drop if v1==.
	recode v3 v5 (.=0)
	gen district_id = v1
	replace district_id = v3 if v3>district_id
	replace district_id = v5 if v5>district_id
	replace v6 = v4 if v6==""
	replace v6 = v2 if v6==""

	keep v6 v7 district_id
	rename (v6 v7) (district_kor district_eng)
	replace district_eng = "Sejong" if district_id==29
	replace district_eng = trim(district_eng)
	order district_id
	save Admin_Districts_Classification_170101, replace
	*/
	
* 3. Generate Si and save the result in csv file
	use Admin_Districts_Classification_170101, clear
	keep if district_id<100000
	replace district_eng = upper(district_eng)
	drop if regexm(district_eng, "-GU[N]?|-DO")
	replace district_eng = subinstr(district_eng, "-SI","",.)
	contract district_*
	drop _freq
	replace district_kor = regexr(district_kor, "광역시|특별시", "")
	export delim using District_Si.csv, novarnames replace
	*/

/* 4. Generate Gun and save the result in csv file
	use Admin_Districts_Classification_170101, clear
	keep if district_id<100000
	replace district_eng = upper(district_eng)
	keep if regexm(district_eng, "-GUN")
	replace district_eng = subinstr(district_eng, "-GUN","",.)
	contract district_eng
	drop _freq
	export delim using District_Gun.csv, novarnames replace
	*/
	
/* 5. Generate Si_Gu & Do_Gun and save the result in csv file
	use Admin_Districts_Classification_170101, clear
	keep if district_id<100000
	contract district_eng
	drop _freq
	export delim using District_SiGU_DoGun.csv, novarnames replace
	*/

/* 6. Generate Si, Gun, & Gu and save the result in csv file
	use Admin_Districts_Classification_170101, clear
	keep if inrange(district_id,1000,100000)
	export delim district_eng using District_Gun_Gu.csv, novarnames replace
	*/
