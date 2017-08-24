
clear all
cap log close
set more off
gl path "D:\KDI\Innovation\Data"
cd $path

import delimited PATSTAT_KOR_FirmList_wAddress&ZIP.csv, clear
keep in 1/1000

* 1. Parse LTD or LIMITED, treat them as the 2nd entity type
	replace psn_name = strupper(psn_name)							// Capitalize
	replace psn_name = trim(itrim(psn_name))	 				// Trim inner & outer blanks
	gen stn_entity2 = regexs(1) if regexm(psn_name, "(L\I?\M?\I?T\E?D)")
	gen tmp_name = subinstr(psn_name, stn_entity2, "", .)
	replace stn_entity2 = "LTD" if stn_entity2~=""		// LIMITED ==> LTD
	replace tmp_name = regexr(tmp_name, "[ ]*-[ ]*", "")	// Remove "-" without space
	replace tmp_name = regexs(2)+regexs(1) if regexm(tmp_name, "(^\(.+\))(.*)")==1	// Put "( )" in the back

	
* 2. Parse English name using -stnd_compname-
	stnd_compname tmp_name, gen(stn_name stn_dbaname stn_fkaname stn_entity1 stn_attn) p($path)
	replace stn_name = trim(itrim(stn_name))
	std_common_words stn_name, p($path)
	replace stn_name = regexr(stn_name, " & ", "&") 		// AB & CD ==> AB&CD
	gen stn_entity = trim(stn_entity1+" "+stn_entity2)	// Merge two entities
	*gen needcheck = regexm(stn_name,"( CO )")==1 | regexm(stn_name,"( CORP )")==1	// need to check if " CO " is inside the firm name
	*if needcheck==1 {
	*	}
	keep person_id psn_name stn_name stn_entity

* 3. Manually save some frequent words in common_words_extract.csv (relatively frequent words on the top)
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
save PAT_ENGname_Standardized, replace

