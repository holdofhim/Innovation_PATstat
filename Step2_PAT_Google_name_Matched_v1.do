
clear all
cd D:\KDI\Innovation\Data
gl version "v1"

import delimit using PATSTAT\firmnames_04-15.csv, clear varnames(1) enc("EUC_KR")
contract *
drop _freq

** Merge input (to R) data with output data

merge 1:m pub_nr using PATSTAT\table\dta\psn_name_pub_nr_04-15_Rsample.dta
keep if _m==3
drop _m pat_publn
keep if inlist(substr(pub_nr,1,2),"KR","WO")


** Reshape and Standardize Korean Name

reshape long v, i(psn_name pub_nr) j(seq)
order pub_nr psn_name v
drop if v==""
drop seq
rename v fname

gen entity1 = regexs(1) if regexm(fname, ///
		"(주식회사|\(주\)|\( 주 \)|\[주\]|㈜|유한(책임)?회사|\(유\)|리미티드|엘티디|합자회사|합명회사|(기술)?지주회사)")
replace fname = subinstr(fname, entity1, "", .)
replace entity1 = trim(itrim(entity1))
replace fname = trim(itrim(fname))
replace entity1 = "(주)" if regexm(entity1, "(주식회사|\( 주 \)|\[주\]|㈜)")
replace entity1 = "(유)" if regexm(entity1, "(유한(책임)?회사|\(유\)|리미티드|엘티디)")

gen entity2 = regexs(1) if regexm(fname, ///
		"(^.*법인 | [.?][.?][.][.][ ?]법인$|\(사\)|\(자\)|\(재\)|\(합\))")
replace entity2 = regexs(1) if entity2=="" & regexm(fname, ///
		"(농업(회사)?법인|농업회사|영농(조합)?법인|어업(회사)?법인|영어(조합)?법인|사단법인|재단법인|한국법인)")
replace fname = subinstr(fname, entity2, "", .)
replace entity2 = subinstr(entity2, " ", "", .)
replace entity2 = trim(itrim(entity2))
gen entity= trim(entity2+" "+entity1) if entity1~="" | entity2~=""

replace fname = regexr(fname,"\(.*\)","")
replace fname = regexr(fname,"\(.*\)","")
replace fname = trim(itrim(fname))


** Exporting single matched names to Excel file

bysort psn_name: egen freq=count(pub_nr)
preserve
keep if freq==1
gen name_kor = fname
replace name_kor = fname+" "+entity if entity~=""
keep pub_nr psn_name name_kor
export excel using PAT_Google_name_Matched_$version.xlsx, sh("Single_Match") sheetrep first(var)
restore
*/


** Drop some names

drop if freq==1
drop if regexm(fname,"(^[a-zA-Z].*[a-zA-Z.,&]$)")	// drop if fname is only in English
drop if regexm(fname,"(^[0-9.]+[0-9a-zA-Z.,/ ]+[a-zA-Z.,]$)")
drop if regexm(fname,"(<.+>)")											// drop Chinese or Japanese characters

drop if regexm(fname,"(^(한국|고등).*(연구원|연구소))") & entity==""
drop if regexm(fname,"(공단|과학기술|기술센터|과학원|평가원|기술원|의학원|진흥원|개발원|시험원|정보원)")
drop if regexm(fname,"(대학교|산학협력)")
drop if regexm(fname,"(대한민국|서울메트로|자치도|특별시|광역시|경기도|경상북도|경상남도|전라북도|전라남도|충청북도|충청남도)")
drop if regexm(fname,"(^(한국|대한|서울|경기|부산|대구|인천|광주|대전|농수산).*공사$)")
drop if regexm(fname,"(^(한국|국제).+(공사|조합|은행|협회|재단|중앙회|거래소)$)")
drop if regexm(fname,"(도 (.+군|.+시)$)")
drop if regexm(fname,"((가메다|가부시|고쿠리츠|나고야|나까무라|닛폰|와타나베|찌꼬|가이샤|쥬츠켄|히토미|후쿠이|미합중국))")
drop if strlen(fname)<=9 & entity==""


** Reshaping and Exporting Multiple matched names to Excel file

gen name_kor = fname
replace name_kor = fname+" "+entity if entity~=""
keep pub_nr psn_name name_kor
sort psn_name name_kor
bysort psn_name: gen seq=_n
reshape wide name_kor, i(pub_nr psn_name) j(seq)
gsort name_kor24 name_kor14 name_kor10 name_kor9 name_kor8 name_kor7 name_kor6 ///
      name_kor5 name_kor4 name_kor3 name_kor2 name_kor1 pub_nr

preserve
keep if name_kor2==""
rename name_kor1 name_kor
export excel using PAT_Google_name_Matched_$version.xlsx, sh("Single_Match_add") sheetrep first(var)
restore
drop if name_kor2==""
export excel using PAT_Google_name_Matched_$version.xlsx, sh("Multi_Match") sheetrep first(var)

