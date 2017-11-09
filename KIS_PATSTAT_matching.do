
clear all
cap log close
set more off
cd D:\KDI\Innovation\Data

* Global names
gl version "r2"
gl kisdata "KIS_ENGname_Standardized_r2"
gl patstat "PAT_ENGname_Standardized_r2"
gl codepath "D:\KDI\Innovation\Code"


* This do file uses -parallel- with multi-core clusters (CPUs).
gl n_clusters = 24
parallel setclusters $n_clusters, force


/* 1. Run KIS_ and PAT_ENGname_Standardized.do files
	timer on 1
	parallel do $codepath\"$kisdata.do"
	parallel do $codepath\"$patstat.do"
	timer off 1
	noi timer list
	timer clear
	*/


* 2. Merge $kisdata.dta (master) with $patstat.dta (using) using -reclink2-
	
	* Option 1: Split the sample, match by subsamples, and then combine them together
	
	* Define the program for parallel matching by each splited subsample
	qui forval i=1/$n_clusters {
		use $patstat, clear
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
	parallel do $codepath\"KIS_PATSTAT_matching_by_Subsamples.do"
	timer off 1
	noi timer list
	
	* Combine all matched subsamples
	clear all
	forval i=1/`n_clusters' {
		append using Temp\KIS_PAT_merged`i'_forreview_$version
		}
	gsort -score
	order psn_name, after(name_eng)
	save KIS_PAT_merged_forreview_$version, replace
	*/

	
	/* Option 2: Match the samples all at once
	use $kisdata, clear
	timer on 1
	parallel: reclink2 stn_name1 stn_name2 stn_entity stn_address stn_zip using $patstat, ///
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
