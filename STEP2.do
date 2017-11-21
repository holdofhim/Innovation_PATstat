

clear all
cd D:\KDI\Innovation\Data\PATSTAT

import delimit using Patinfo_app_nr_04-15_KR_unique.txt, delim(",[") enc("UTF-8") clear
contract *
keep v1 v2
drop if v2==""
rename (v1 v2) (app_nr assignee)
replace assignee = trim(itrim(assignee))
replace assignee = regexr(assignee, "\[", "")
split assignee, parse("),")
drop assignee

** Data Parse

nvars assignee
forval i=1/`r(nvars)' {
	replace assignee`i' = trim(itrim(assignee`i'))
	gen fname_kr`i' = regexs(2) if regexm(assignee`i', "(^\('?)(.+)( \\n )")
	replace assignee`i' = subinstr(assignee`i', regexs(1)+regexs(2)+regexs(3), "", .) if regexm(assignee`i', "(^\([']?)(.+)( \\n )")
	replace fname_kr`i' = subinstr(fname_kr`i',char(34), "", .)
	replace fname_kr`i' = subinstr(fname_kr`i', " \n", "", .)
	gen fname_en`i' = regexs(1) if regexm(assignee`i', "(^.+)(\\n)")	
	replace assignee`i' = subinstr(assignee`i', regexs(1)+regexs(2), "", .) if regexm(assignee`i', "(^.+)(\\n)")
	gen fid`i' = regexs(2) if regexm(assignee`i', "(^\()([0-9]+)(\))")
	replace assignee`i' = subinstr(assignee`i', regexs(1)+regexs(2)+regexs(3), "", .) if regexm(assignee`i', "(^\()([0-9]+)(\))")
	gen faddress`i' = regexs(2) if regexm(assignee`i', "(, ')(.+)([ ]?...')")
	replace assignee`i' = subinstr(assignee`i', regexs(1)+regexs(2)+regexs(3), "", .) if regexm(assignee`i', "(, ')(.+)([ ]?...')")
	}


** Reshape and Standardize Name & Address

drop assignee*
reshape long fname_kr fname_en fid faddress, i(app_nr) j(seq)
drop if fid==""
foreach x of varlist fname_kr-faddress {
	replace `x' = trim(itrim(`x'))
	}

	* Standardize KOREAN firm name 
	gen entity1 = regexs(1) if regexm(fname_kr, ///
			"(주식회사|\(주\)|\( 주 \)|\[주\]|㈜|유한(책임)?회사|\(유\)|리미티드|엘티디|합자회사|합명회사|(기술)?지주회사)")
	replace fname_kr = subinstr(fname_kr, entity1, "", .)
	replace entity1 = trim(itrim(entity1))
	replace fname_kr = trim(itrim(fname_kr))
	replace entity1 = "(주)" if regexm(entity1, "(주식회사|\( 주 \)|\[주\]|㈜)")
	replace entity1 = "(유)" if regexm(entity1, "(유한(책임)?회사|\(유\)|리미티드|엘티디)")

	gen entity2 = regexs(1) if regexm(fname_kr, ///
			"(^.*법인 | [.?][.?][.][.][ ?]법인$|\(사\)|\(자\)|\(재\)|\(합\))")
	replace entity2 = regexs(1) if entity2=="" & regexm(fname_kr, ///
			"(농업(회사)?법인|농업회사|영농(조합)?법인|어업(회사)?법인|영어(조합)?법인|사단법인|재단법인|한국법인)")
	replace fname_kr = subinstr(fname_kr, entity2, "", .)
	replace entity2 = subinstr(entity2, " ", "", .)
	replace entity2 = trim(itrim(entity2))
	gen entity= trim(entity2+" "+entity1) if entity1~="" | entity2~=""

	replace fname_kr = regexr(fname_kr,"\(.*\)","")
	replace fname_kr = regexr(fname_kr,"\(.*\)","")
	replace fname_kr = subinstr(fname_kr,"\.","",.)
	replace fname_kr = subinstr(fname_kr,",","",.)
	replace fname_kr = trim(itrim(fname_kr))

  * Standardize KOREAN address
	gen dongeup = regexs(1) if regexm(faddress, "([,.*-\(].*$)")
	replace faddress = trim(subinstr(faddress, dongeup, "", .))

	gen sigungu = regexs(1) if regexm(faddress, "( .+$)")
	replace faddress = trim(subinstr(faddress, sigungu, "", .))
	replace sigungu = trim(sigungu)
	replace sigungu = regexs(1)+" "+sigungu if regexm(faddress, ///
																						 "(구미시|김포시|군포시|부천|순창군|안양시|천안시|포항시)")
	replace faddress = trim(subinstr(faddress, regexs(1), "", .)) if regexm(faddress, ///
																						 "(구미시|김포시|군포시|부천|순창군|안양시|천안시|포항시)")

	gen sido = ""
	replace sido = regexs(1) if regexm(faddress, "(서울|부산|대구|광주|울산|대전|세종|경기|강원|제주)")
	replace sido = "인천" if regexm(faddress, "(인천|인청)")
	replace faddress = subinstr(faddress, regexs(1), "", .) if regexm(faddress, ///
																			 "(서울|부산|대구|광주|인천|인청|울산|대전|세종|경기|강원|제주)")
	replace sido = "경북" if regexm(faddress, "(경상북|경북)")
	replace faddress = subinstr(faddress, regexs(1), "", .) if regexm(faddress, "(경상북도|경상북|경북)")
	replace sido = "경남" if regexm(faddress, "(경상남|경남)")
	replace faddress = subinstr(faddress, regexs(1), "", .) if regexm(faddress, "(경상남도|경상남|경남)")
	replace sido = "전북" if regexm(faddress, "(전라북|전북)")
	replace faddress = subinstr(faddress, regexs(1), "", .) if regexm(faddress, "(전라북도|전라북|전북)")
	replace sido = "전남" if regexm(faddress, "(전라남|전남)")
	replace faddress = subinstr(faddress, regexs(1), "", .) if regexm(faddress, "(전라남도|전라남|전남)")
	replace sido = "충북" if regexm(faddress, "(충청북|충북)")
	replace faddress = subinstr(faddress, regexs(1), "", .) if regexm(faddress, "(충청북도|충청북|충북)")
	replace sido = "충남" if regexm(faddress, "(충청남|충남)")
	replace faddress = subinstr(faddress, regexs(1), "", .) if regexm(faddress, "(충청남도|충청남|경남)")

	gen address = sido+" "+sigungu


** Save the result
keep  app_nr seq fid fname_kr entity address
order app_nr seq fid fname_kr entity address
sort app_nr seq
save STEP2_PATSTAT_KORname_Standardized, replace

