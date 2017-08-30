
clear all
cap log close
set more off
gl codepath "D:\KDI\Innovation\Code"
cd D:\KDI\Innovation\Data

import delimited PATSTAT_KOR_FirmList_wAddress.csv, clear
replace psn_name = trim(itrim(upper(psn_name)))
replace person_add = trim(itrim(upper(person_add)))
gen addlen = strlen(person_add)
gsort psn_name -addlen
bysort psn_name: replace person_add = person_add[1]
contract person_id psn_name person_add
drop _freq
keep in 1/5000


* 1. Parse Company Name

	* 1-1. Parse LTD or LIMITED, treat them as the 2nd entity type
	replace psn_name = strupper(psn_name)							// Capitalize
	replace psn_name = trim(itrim(psn_name))	 				// Trim inner & outer blanks
	gen stn_entity2 = regexs(1) if regexm(psn_name, "(L\I?\M?\I?T\E?D)")
	gen tmp_name = subinstr(psn_name, stn_entity2, "", .)
	replace stn_entity2 = "LTD" if stn_entity2~=""		// LIMITED ==> LTD
	replace tmp_name = regexr(tmp_name, "[ ]*-[ ]*", "")	// Remove "-" without space
	replace tmp_name = regexs(2)+regexs(1) if regexm(tmp_name, "(^\(.+\))(.*)")==1	// Put "( )" in the back
	
	* 1-2. Parse English name using -stnd_compname- & -std_common_words-
	* -std_common_words- captures common word variations using regular expression
	stnd_compname tmp_name, gen(stn_name stn_dbaname stn_fkaname stn_entity1 stn_attn) p($codepath)
	replace stn_name = trim(itrim(stn_name))
	std_common_words stn_name, p($codepath)
	replace stn_name = regexr(stn_name, " & ", "&") 		// AB & CD ==> AB&CD
	gen stn_entity = trim(stn_entity1+" "+stn_entity2)	// Merge two entities
	*gen needcheck = regexm(stn_name,"( CO )")==1 | regexm(stn_name,"( CORP )")==1	// need to check if " CO " is inside the firm name
	*if needcheck==1 {
	*	}
	keep person_id psn_* stn_name stn_entity

	* 1-3. Manually save some frequent words in common_words_extract.csv (relatively frequent words on the top)
	* Type 1: industry-specific words (e.g., fashion, eletronics...)
	* Type 2: general words (e.g., enterprises, industry...)
	preserve
	split stn_name
	contract stn_name?
	keep stn_name?
	stack stn_name?, into(stn_names)
	contract stn_names
	drop if strlen(stn_names)<2
	gsort -_freq
	
	* 1-4. Parse frequent words and put them in the back
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
	*/

	
* 2. Parse Address

	* 2-1. Remove Dong, Eup, Myeon, and some other redundant names
	replace person_add = subinstr(person_add, " -" ,"-", .)
	replace person_add = subinstr(person_add, "- " ,"-", .)
	replace person_add = subinstr(person_add, "--" ,"-", .)
	replace person_add = regexr(person_add, "METRO[A-Z]*[ ,]|UNIV[A-Z]*[ ,]|INDUS[A-Z]*[ ,]", "")	
	replace person_add = regexr(person_add, "[GK]WANGY[EOU]?[OU][A-Z]+[ ,]|COMPL[A-Z]*[ ,]|PARK[ ,]", "")	
	gen dongeup = regexs(1)+regexs(2)+regexs(3) if regexm(person_add, "(^.*)([D[OU]NG|MY[EO]?[OU]N|[E]?U[BP]|RO|[GK]A)([ ,]+)")
	replace person_add = trim(subinstr(person_add, dongeup, "", .))
		
	* 2-2. Parse Zipcode
	gen stn_zip = trim(regexs(1)) if regexm(person_add, "([0-9][0-9][0-9][-][0-9][0-9][0-9])")	// This format first!
	replace stn_zip = trim(regexs(1)) if regexm(person_add, "([0-9][0-9][0-9][ ]?[0-9][0-9][0-9])") & stn_zip==""
	replace stn_zip = zip_code if stn_zip==""
	replace person_add = trim(subinstr(person_add, stn_zip, "", .))
	replace stn_zip = regexs(1)+"-"+regexs(2) if regexm(person_add, "([0-9][0-9][0-9])[ ]?([0-9][0-9][0-9])")
		
	* 2-3. Parse Gu or Gun
	gen GuGun = trim(regexs(1)) if regexm(person_add, "([A-Z]+[ -]?[1-9]?[ -][GKQ]U[N]?)[ ,]?")
	replace GuGun = trim(regexs(1)) if regexm(person_add, "([A-Z]+[ -]?[1-9]?[GKQ]U[N]?)[ ,]?") & GuGun==""
	replace person_add = trim(subinstr(person_add, GuGun, "", .))
	replace GuGun = subinstr(GuGun, " ", "", .)
	replace GuGun = subinstr(GuGun, "-", "", .)
	replace GuGun = regexr(GuGun, "[GKQ]U$", "-GU")
	replace GuGun = regexr(GuGun, "[GKQ]UN$", "-GUN")
			
	* 2-4. Parse Si
	gen Si = trim(regexs(1)+regexs(2)) if regexm(person_add, "([A-Z]+)(-S[H]?I|-CITY)")
	replace person_add = trim(itrim(subinstr(person_add, ",", " ", .)))
	replace Si = trim(regexs(1)) if regexm(person_add, "([A-Z]+[ -]?S[H]?I)([ ,])") & Si==""
	replace Si = trim(regexs(1)) if regexm(person_add, "([A-Z]+[ -]?S[H]?I$)") & Si==""	// double check
	replace Si = trim(regexs(1)) if regexm(person_add, "([A-Z]+[ -]?CI[T]?[Y]?)") & Si==""	
	replace person_add = trim(subinstr(person_add, Si, "", .))
	replace Si = regexr(Si, "[ -]?S[H]?I$|[ -]?CI[T]?[Y]?$", "")
		
	* 2-5. Parse Do
	gen Do = trim(regexs(1)) if regexm(person_add, "([A-Z-]+[ ]?DO$)")
	replace person_add = trim(itrim(person_add))
	replace Do = trim(regexs(1)) if regexm(person_add, "([A-Z-]+[ ]?[DG]O$)") & Do==""	
	replace Do = trim(regexs(1)) if regexm(person_add, "([A-Z-]+[ ]?DO)") & Do==""	// double check
	replace Do = trim(regexs(1)) if regexm(person_add, "([A-Z-]+[ ]?PRO[BV]IN[CS]E)") & Do==""	
	replace Do = trim(regexs(1)) if regexm(person_add, "([A-Z-]+[ ]?BUK$|[A-Z]+[ ]?NAM$|[A-Z]+[ ]?GI$)") & Do==""	
	replace person_add = trim(subinstr(person_add, Do, "", .))
	replace Do = subinstr(Do, " ", "", .)
	replace Do = subinstr(Do, "-", "", .)
	replace Do = regexr(Do, "[DG]O$|PRO[BV]IN[CS]E$", "-DO")
	replace Do = regexs(1)+"-DO" if regexm(Do, "(.*BUK$|.*NAM$|.*GI$)")
	
	* 2-6. Parse the remaining city-level address using District_Si.csv
	preserve
	import delim using District_Si.csv, clear
	valuesof v1
	loc si "`r(values)'"
	restore
	qui foreach x of loc si {
		replace Si = regexs(1) if regexm(person_add, "(`x')") & Si==""
		tempvar cityname
		gen cityname = "`x'"
		jarowinkler person_add cityname
		replace Si = person_add if jarowinkler>0.8 & Si==""
		replace person_add = trim(subinstr(person_add, Si, "", .))
		drop cityname jarowinkler
		}	
	
	* 2-7. Generate one address based on Si, Gun, Gu, & Do
	gen stn_address = trim(Si+" "+GuGun)
	replace stn_address = trim(Do+" "+GuGun) if stn_address==""
	*/
	
	
* 3. Clean data and save the result
	keep person_id psn_* stn_*
	compress
	*save PAT_ENGname_Standardized, replace

