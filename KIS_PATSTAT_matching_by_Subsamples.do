

clear all
cap log close
set more off
cd D:\KDI\Innovation\Data

forval i=1/$n_clusters {
	use KIS_ENGname_Standardized, clear
	reclink2 stn_name1 stn_name2 stn_entity stn_address stn_zip using Temp\PAT_ENGname_Standardized`i', ///
					 idm(fid_kis) idu(fid_pat) wmatch(10 8 2 6 4) gen(score) minscore(0.8) many npairs(2)
	gsort -score
	order psn_name, after(name_eng)
	save Temp\KIS_PAT_merged`i'_forreview_$version, replace
	}
