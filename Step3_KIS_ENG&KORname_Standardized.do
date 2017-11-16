
clear all
cd D:\KDI\Innovation\Data

use KED_Firmlist_wPatents, clear
format ked_id %12.0f
gen firm_id = "KED"+string(ked_id)
noi merge 1:m business_no using KIS_All_FirmList, update replace
sort business_no listed type 
keep  firm_id business_no name_kor name_eng address zipcode
order firm_id business_no name_kor name_eng address zipcode



** 1. Standardize English Firm Name

	* 1-1. Parse LTD or LIMITED, treat them as the 2nd entity type
	replace name_eng = trim(itrim(name_eng))
	gen stn_entity2 = regexs(1) if regexm(name_eng, "([ .,;]L[I]?[M]?[I]?T[E]?D)")
	gen tmp_name = subinstr(name_eng, stn_entity2, "", .)
	replace stn_entity2 = "" if stn_entity2~=""				    // Remove LIMITED
	replace tmp_name = regexr(tmp_name, "^\(.*\)", "")		// Remove contents in ()
	replace tmp_name = regexr(tmp_name, "\(.*\)$", "")		// Remove contents in ()	
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


	
** Standardize English Address

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


** 3. Standardize Korean Firm Name

  * 3-1. Parse entity1
	gen entity1 = regexs(1) if regexm(name_kor, "(주식회사|\(주\)|유한회사|\(유\)|합자회사|합명회사|\(합\))")
	replace name_kor = subinstr(name_kor, entity1, "", .)
	replace entity1 = trim(itrim(entity1))
	replace name_kor = trim(itrim(name_kor))

	* 3-2. Parse entity2: 
	gen entity2 = regexs(1) if regexm(name_kor, ///
		"((농업|농업회사|어업|어업회사|영농|영농조합|영어조합|사단|재단|한국)법인$|\(사\)|\(자\)|\(재\))")
	replace name_kor = subinstr(name_kor, en	tity2, "", .)
	replace entity2 = trim(itrim(entity2))
	replace name_kor = regexr(name_kor,"\(.*\)","")
	replace name_kor = subinstr(name_kor, " ", "", .)
	replace name_kor = trim(itrim(name_kor))

	gen entity= trim(entity2+" "+entity1) if entity1~="" | entity2~=""
	drop entity?
*/
	
	
** 4. Clean data and save the result

	* 4-1. Save Standardized Matching Firm List
	compress
	save KIS_Matching_FirmList, replace
	
	* 4-2. Save English Names
	preserve
	contract name_eng stn_*
	drop _f
	gen fid_kis=_n
	order fid_kis
	save KIS_ENGname_Standardized, replace 

	* 4-3. Save Korean Names
	preserve
	contract name_kor
	drop _f
	save KIS_KORname_Standardized, replace
	restore
