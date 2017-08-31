
clear all
cap log close
set more off
gl version "v2"
cd D:\KDI\Innovation\Code



* 1. Run KIS_ and PAT_ENGname_Standardized.do files
	run KIS_ENGname_Standardized.do
	run PAT_ENGname_Standardized.do
	*/


/* 2. Merge KIS_ENG_Standardized (master) with PAT_ENG_Standardized (using) using -reclink2-
	use KIS_ENGname_Standardized, clear
	reclink2 stn_name1 stn_name2 stn_entity stn_address stn_zip using PAT_ENGname_Standardized, ///
					 idm(firm_id) idu(person_id) wmatch(12 10 5 5 1) gen(score) minscore(0.8) many npairs(2)
	compress
	save KIS_PAT_merged_forreview_$version, replace
	*/ 


/* 3. Clerical Review
	clear
	clrevmatch using KIS_PAT_merged_forreview_$version, idm(firm_id) idu(person_id) ///
		varM(stn_*) varU(U*) reclinkscore(score) clrev_result(result) clrev_note(notes) replace
	*/
