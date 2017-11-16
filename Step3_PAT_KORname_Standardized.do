
clear all
cd D:\KDI\Innovation\Data
gl Rterm_path "C:\Program Files\Microsoft\R Open\R-3.4.0\bin\x64\R.exe"
gl version "v1"

** Import PAT & Google Matched names
tempfile m1 m2
import excel using PAT_Google_name_Matched_v1_reviewed.xlsx, sheet("Single_Match") firstrow clear
save `m1'
import excel using PAT_Google_name_Matched_v1_reviewed.xlsx, sheet("Single_Match_add") firstrow clear
save `m2'
import excel using PAT_Google_name_Matched_v1_reviewed.xlsx, sheet("Multi_Match_chosen") firstrow clear
append using `m1' `m2'


** Standardization of Korean name

gen entity1 = regexs(1) if regexm(name_kor, "(\(주\)|\(유\)|합자회사|합명회사|\(합\))")
replace name_kor = subinstr(name_kor, entity1, "", .)
replace entity1 = trim(itrim(entity1))
replace name_kor = trim(itrim(name_kor))

gen entity2 = regexs(1) if regexm(name_kor, ///
	"((농업|농업회사|어업|어업회사|영농|영농조합|영어조합|사단|재단|한국)법인$|\(사\)|\(자\)|\(재\))")
replace name_kor = subinstr(name_kor, entity2, "", .)
replace entity2 = trim(itrim(entity2))
replace name_kor = regexr(name_kor,"\(.*\)","")
replace name_kor = subinstr(name_kor, " ", "", .)
replace name_kor = trim(itrim(name_kor))


gen entity= trim(entity2+" "+entity1) if entity1~="" | entity2~=""
drop entity?

save PAT_KORname_Standardized_${version}, replace



** Merge with KIS_KORnames and then Save matched and unmatched names, respectively.

run D:\KDI\Innovation\Code\Step3_KIS_ENG&KORname_Standardized.do
use KIS_ENG&KORname_Standardized, clear
merge 1:m name_kor using PAT_KORname_Standardized_${version}

preserve
keep if _m==2
drop _m
drop if regexm(name_kor,"(^[a-zA-Z].*[a-zA-Z.,&]$)")	// drop if fname is only in English
drop if regexm(name_kor,"(^[0-9.]+[0-9a-zA-Z.,/ ]+[a-zA-Z.,]$)")
order pub_nr psn_name name_kor
sort psn_name name_kor
save PAT_KORname_Standardized_${version}_unmatched, replace
restore

keep if _m==3
drop _m
order pub_nr psn_name name_kor
sort psn_name name_kor
save PAT_KORname_Standardized_${version}_matched, replace


/** Run R matching program

shell $Rterm_path CMD BATCH D:\KDI\Innovation\Code\KIS_PATSTAT_matching_KR.R
*rsource using D:\KDI\Innovation\Code\temp.R
*/
