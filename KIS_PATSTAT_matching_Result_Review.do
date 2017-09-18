
clear all
cap log close
set more off
cd D:\KDI\Innovation\Data

	
* Save checked file
use KIS_PAT_merged_forreview_v2, clear
keep if _merge==3 & score>0.95
drop if score==1
save KIS_PAT_merged_forreview_v2_checked, replace
*/


* Review Process
clear
clrevmatch using KIS_PAT_merged_forreview_v2_checked, idm(fid_kis) idu(fid_pat) ///
	varM(name_eng stn_*) varU(psn_name U*) reclinkscore(score) clrev_result(result) clrev_note(notes) replace


/*
clear all
save KIS_PAT_merged_forreview_v2_checked, replace
*/
