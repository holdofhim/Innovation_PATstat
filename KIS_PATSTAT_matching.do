
clear all
cap log close
set more off
gl version "v3"
cd D:\KDI\Innovation\Data

* This do file uses -parallel- with multi-core clusters (CPUs).
gl n_clusters = 24
parallel setclusters $n_clusters, force


/* 1. Run KIS_ and PAT_ENGname_Standardized.do files
	timer on 1
	parallel do D:\KDI\Innovation\Code\KIS_ENGname_Standardized.do
	parallel do D:\KDI\Innovation\Code\PAT_ENGname_Standardized.do
	timer off 1
	noi timer list
	timer clear
	*/


* 2. Merge KIS_ENGname_Standardized (master) with PAT_ENGname_Standardized (using) using -reclink2-
	
	* Define the program for parallel matching by each splited subsample
	qui forval i=1/$n_clusters {
		use PAT_ENGname_Standardized, clear
		loc n_obs = int(_N/$n_clusters)+1
		qui gen sample_id = .
		loc j = (`i'-1)*`n_obs'+1
		loc k = `i'*`n_obs'
		loc l = _N
		if `i'<$n_clusters  replace sample_id=`i' in `j'/`k'
		if `i'==$n_clusters replace sample_id=`i' in `j'/`l'
		keep if sample_id==`i'
		save Temp\PAT_ENGname_Standardized`i', replace
		}
	
	* Run the program for parallel matchings
	timer on 1
	parallel do D:\KDI\Innovation\Code\KIS_PATSTAT_matching_by_Subsamples.do
	timer off 1
	noi timer list
	
	/*
	clear all
	forval i=1/`n_clusters' {
		append using KIS_PAT_merged`i'_forreview_$version
		}
	gsort -score
	order psn_name, after(name_eng)
	save KIS_PAT_merged_forreview_$version, replace
	*/

	/*
	use KIS_ENGname_Standardized, clear
	timer on 1
	parallel: reclink2 stn_name1 stn_name2 stn_entity stn_address stn_zip using PAT_ENGname_Standardized, ///
	 				 idm(fid_kis) idu(fid_pat) wmatch(10 8 2 6 4) gen(score) minscore(0.8) many npairs(2)
	timer off 1
	gsort -score
	order psn_name, after(name_eng)
	compress
	save KIS_PAT_merged_forreview_$version, replace
	*/ 


/* 3. Clerical Review
	clear
	clrevmatch using KIS_PAT_merged_forreview_$version, idm(firm_id) idu(person_id) ///
		varM(stn_*) varU(U*) reclinkscore(score) clrev_result(result) clrev_note(notes) replace
	*/
