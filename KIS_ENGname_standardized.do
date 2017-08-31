
clear all
cap log close
set more off
gl codepath "D:\KDI\Innovation\Code"
cd D:\KDI\Innovation\Data

/* 0. Prepare KIS data
	use D:\KDI\JMDATA\finaldata\gaeyo2008, clear
	noi merge 1:1 upchecd using D:\KDI\JMDATA\finaldata\gaeyo2017, nogen update
	rename (upchecd-upche_eng addr1_eng zipcd1 tel1 sanupcd) ///
				 (firm_id name_kor name_eng address zipcode phone ksic9_5d)
	destring *_no listed type ksic9, replace force
	drop if business==. | name_eng==""	// drop some missing data
	replace address = upper(address)
	sort business_no firm_id
	keep  firm_id business ksic9 listed type name_kor name_eng address zipcode phone
	order firm_id business ksic9 listed type name_kor name_eng address zipcode phone
	save KIS_All_FirmList, replace
	*keep if inrange(ksic9,10000,34000)	// keep only manufacturing firms
	*save KIS_MFC_FirmList, replace
*/

*
use KED_Firmlist_wPatents, clear
gen firm_id = "KED"+string(ked_id)
noi merge 1:m business_no using KIS_All_FirmList, update replace
drop if ksic9==. | ksic9>94000 | inrange(ksic9,80000,90000)	// drop if GOV., UNIV., HOSP., & NPO
keep if _m~=2 | inrange(ksic9,10000,34000)	// keep only manufacturing companies
keep if _m~=2 | inrange(listed,10,40)				// keep only existing companies
keep if _m~=2 | inrange(type,1,4)						// keep only corporate companies
sort business_no listed type 
bysort business: gen freq = _n
drop if freq>1									// keep only the first obs. if the same firm has multiple firm_ids
keep  firm_id business_no name_kor name_eng address zipcode
order firm_id business_no name_kor name_eng address zipcode
*/


* 1. Parse Company Name

	* 1-1. Parse LTD or LIMITED, treat them as the 2nd entity type
	replace name_eng = trim(itrim(name_eng))
	gen stn_entity2 = regexs(1) if regexm(name_eng, "([ .,;]L[I]?[M]?[I]?T[E]?D)")
	gen tmp_name = subinstr(name_eng, stn_entity2, "", .)
	replace stn_entity2 = "" if stn_entity2~=""				    // Remove LIMITED
	replace tmp_name = regexr(tmp_name, "[ ]*-[ ]*", "")	// Remove "-" without space

	* 1-2. Parse English name using -stnd_compname- & -std_common_words-
	* -std_common_words- captures common word variations using regular expression
	stnd_compname tmp_name, gen(stn_name stn_dbaname stn_fkaname stn_entity1 stn_attn) p($codepath)
	replace stn_name = trim(itrim(stn_name))
	std_common_words stn_name, p($codepath)
	replace stn_name = regexr(stn_name, " & ", "&") 		// AB & CD ==> AB&CD
	gen stn_entity = trim(stn_entity1+" "+stn_entity2)	// Merge two entities
	keep  firm_id firm_id business_no name_* stn_name stn_entity address zipcode
	order firm_id firm_id business_no name_* stn_name stn_entity address zipcode
	
	/* 1-3. Manually save some frequent words in csv files (relatively frequent words on the top)
	* Type 1: sector-specific words (e.g., fashion, eletronics...) ==> common_words_sectoral.csv
	* Type 2: general words (e.g., enterprises, industry...) ==> common_words_general.csv
	split stn_name
	contract stn_name?
	keep stn_name?
	stack stn_name?, into(stn_names)
	contract stn_names
	drop if strlen(stn_names)<2
	gsort -_freq
	*/
	
	* 1-4. Locate the frequent words behind the company-specific names
	preserve
	foreach x in general sectoral {
		import delim using common_words_`x'.csv, clear
		valuesof v1
		loc `x' "`r(values)'"
		}
	restore
	*noi dis "`commonword'"
	gen stn_name1 = stn_name
	gen stn_name2 = ""
	gen stn_name3 = ""
	foreach z of loc general {
		replace stn_name3 = trim(regexs(1)) if regexm(stn_name1,"( `z'[A-Z]*$)") & stn_name3==""
		replace stn_name1 = trim(subinword(stn_name1, stn_name3, "", .))
		}
	foreach z of loc sectoral {
		replace stn_name2 = trim(regexs(1)) if regexm(stn_name1,"( `z'[A-Z]*$)") & stn_name2==""
		replace stn_name1 = trim(subinword(stn_name1, stn_name2, "", .))
		}
	replace stn_name2 = trim(itrim(stn_name2+" "+stn_name3))
	drop stn_name stn_name3
	order stn_name1 stn_name2, after(name_eng)
*/

	
* 2. Parse Address

	* 2-1. Remove Dong, Myeon, Eup, and some other redundant names
	gen kis_add = trim(itrim(address))
	replace kis_add = subinstr(kis_add, " -" ,"-", .)
	replace kis_add = subinstr(kis_add, "- " ,"-", .)
	replace kis_add = regexr(kis_add, "METRO[A-Z]*[ ,]|UNIV[A-Z]*[ ,]|INDUS[A-Z]*[ ,]", "")	
	replace kis_add = regexr(kis_add, "[GK]WANGY[EOU]?[OU][A-Z]+[ ,]|COMPL[A-Z]*[ ,]|PARK[ ,]", "")	
	gen dongeup = regexs(1)+regexs(2)+regexs(3) if regexm(kis_add, "(^.*)([D[OU]NG|MY[EO]?[OU]N|[E]?U[BP]|RO|[GK]A)([ ,]+)")
	replace kis_add = trim(subinstr(kis_add, dongeup, "", .))
	
	* 2-2. Standardize Zipcode
	gen stn_zip = trim(itrim(zipcode))
	replace stn_zip = regexs(1)+"-"+regexs(2) if regexm(stn_zip, "([0-9][0-9][0-9])[ ]?([0-9][0-9][0-9])")
		
	* 2-3. Parse Gu or Gun
	gen GuGun = trim(regexs(1)) if regexm(kis_add, "([A-Z]+[ -]?[1-9]?[ -][GK]U[N]?)[ ,]?")
	replace GuGun = trim(regexs(1)) if regexm(kis_add, "([A-Z]+[ -]?[1-9]?[GK]U[N]?)[ ,]?") & GuGun==""
	replace kis_add = trim(subinstr(kis_add, GuGun, "", .))
	replace GuGun = subinstr(GuGun, " ", "", .)
	replace GuGun = subinstr(GuGun, "-", "", .)
	replace GuGun = regexr(GuGun, "[GK]U$", "-GU")
	replace GuGun = regexr(GuGun, "[GK]UN$", "-GUN")
			
	* 2-4. Parse Si
	gen Si = trim(regexs(1)+regexs(2)) if regexm(kis_add, "([A-Z]+)(-SI|-CITY)")
	replace kis_add = trim(itrim(subinstr(kis_add, ",", " ", .)))
	replace Si = trim(regexs(1)) if regexm(kis_add, "([A-Z]+[ -]?SI)([ ,])") & Si==""
	replace Si = trim(regexs(1)) if regexm(kis_add, "([A-Z]+[ -]?SI$)") & Si==""	// double check
	replace Si = trim(regexs(1)) if regexm(kis_add, "([A-Z]+[ -]?CITY)") & Si==""	
	replace kis_add = trim(subinstr(kis_add, Si, "", .))
	replace Si = regexr(Si, "[ -]?SI$|[ -]?CITY$", "")
		
	* 2-5. Parse Do
	gen Do = trim(regexs(1)) if regexm(kis_add, "([A-Z-]+[ ]?DO$)")
	replace kis_add = trim(itrim(kis_add))
	replace Do = trim(regexs(1)) if regexm(kis_add, "([A-Z-]+[ ]?[D]O$)") & Do==""	
	replace Do = trim(regexs(1)) if regexm(kis_add, "([A-Z-]+[ ]?DO)") & Do==""	// double check
	replace Do = trim(regexs(1)) if regexm(kis_add, "([A-Z-]+[ ]?BUK$|[A-Z]+[ ]?NAM$|[A-Z]+[ ]?GI$)") & Do==""	
	replace kis_add = trim(subinstr(kis_add, Do, "", .))
	replace Do = regexr(Do, " |-", "")
	replace Do = regexr(Do, "DO$", "-DO")
	replace Do = regexs(1)+"-DO" if regexm(Do, "(.*BUK$|.*NAM$|.*GI$)")
	
	* 2-6. Parse the remaining city-level address using District_Si.csv
	preserve
	import delim using District_Si.csv, clear encoding("utf-8")
	qui sum v1
	loc N = `r(N)'
	tempfile city
	save `city'
	restore
	merge 1:1 _n using `city', nogen
	qui forval i=1/`N' {
		replace Si = v3[`i'] if regexm(kis_add, v3[`i']) & Si==""		// v3= cityname in English
		replace Si = v3[`i'] if regexm(kis_add, v2[`i']) & Si==""		// v2= cityname in Korean
		}	
	
	* 2-7. Generate one address based on Si, Gun, Gu, & Do
	gen stn_address = trim(Si+" "+GuGun)
	replace stn_address = trim(Do+" "+GuGun) if stn_address==""
*/

	
* 3. Clean data and save the result
	keep firm_id business_no name_* stn_*
	compress
	save KIS_Matching_FirmList, replace
	contract name_eng stn_*
	drop _f
	gen fid_kis=_n
	order fid_kis
	save KIS_ENGname_Standardized, replace 
*/

