
clear all
cap log close
set more off
gl path "D:\KDI\Innovation\Data"
cd $path

* 0. Prepare KIS data
	use D:\KDI\JMDATA\finaldata\gaeyo2017, clear
	rename (upchecd-upche_eng addr1_eng sanupcd) (kis_id kis_kor kis_eng kis_add ksic9_5d)
	destring *_no listed type ksic9, replace
	
	gen ksic9_2d = int(ksic9_5d/1000)
	drop if business_no==. | kis_eng=="" | ksic9_2d==.	// drop some missing data
	keep if inrange(ksic9_2d,1,39) | inrange(ksic9_2d,60,63) | inrange(ksic9_2d,70,73) 
	keep if inlist(type,1,4)														// keep only corporate companies
	replace kis_add = upper(kis_add)
	keep  nice_id business_no kis_*
	order nice_id business_no kis_*
	save KIS_All_FirmList, replace
	*keep if inrange(ksic9_2d,10,34)										// keep only manufacturing firms
	*save KIS_MFC_FirmList, replace
	*/

use KED_Firmlist_withPatents, clear
noi merge 1:1 business_no using KIS_All_FirmList, nogen update
*keep in 1/2000

* 1. Parse LTD or LIMITED, treat them as the 2nd entity type
	replace kis_eng = trim(itrim(kis_eng))
	gen stn_entity2 = regexs(1) if regexm(kis_eng, "(L[I]?[M]?[I]?T[E]?D)")
	gen tmp_name = subinstr(kis_eng, stn_entity2, "", .)
	replace stn_entity2 = "LTD" if stn_entity2~=""		// LIMITED ==> LTD
	replace tmp_name = regexr(tmp_name, "[ ]*-[ ]*", "")	// Remove "-" without space

* 2. Parse English name using -stnd_compname-
	stnd_compname tmp_name, gen(stn_name stn_dbaname stn_fkaname stn_entity1 stn_attn) p($path)
	replace stn_name = trim(itrim(stn_name))
	std_common_words stn_name, p($path)
	replace stn_name = regexr(stn_name, " & ", "&") 		// AB & CD ==> AB&CD
	gen stn_entity = trim(stn_entity1+" "+stn_entity2)	// Merge two entities
	keep nice_id kis_* business_no stn_name stn_entity
	
/* 3. Manually save some frequent words in common_words_extract.csv (relatively frequent words on the top)
	split stn_name
	contract stn_name?
	keep stn_name?
	stack stn_name?, into(stn_names)
	contract stn_names
	drop if strlen(stn_names)<2
	gsort -_freq
	*/
	
* 4. Parse frequent words and put them in the back
	preserve
	import delim using common_words_extract.csv, clear
	valuesof v1
	loc commonword "`r(values)'"
	restore
	*noi dis "`commonword'"
	gen stn_name1 = stn_name
	gen stn_name2 = ""
	gen stn_name3 = ""
	foreach x of loc commonword {
		replace stn_name3 = trim(regexs(1)) if regexm(stn_name1,"( `x'[A-Z]*$)") & stn_name3==""
		replace stn_name1 = trim(subinword(stn_name1, stn_name3, "", .))
		replace stn_name2 = trim(regexs(1)) if regexm(stn_name1,"( `x'[A-Z]*$)") & stn_name3~="" & stn_name2==""	
		replace stn_name1 = trim(subinword(stn_name1, stn_name2, "", .))
		}
	order stn_name1 stn_name2 stn_name3, after(stn_name)
	
compress
save KIS_ENGname_Standardized, replace 


