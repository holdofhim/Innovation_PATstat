
clear all
cd D:\KDI\Innovation\Data\PATSTAT

/** Generate Concordance btw appln_id & pat_publn_id for the peiod of 2004-2015
use table\dta\Concordance_appln_id_pat_publn_id, clear
merge 1:1 table\dta\pat_publn_id using publn_id_04_15, nogen keep(match)
merge m:1 table\dta\appln_id using appln_id_04_15, nogen keep(match)
order appln* pat_publn_id publn*
gen publn_year = substr(publn_date,1,4)
destring publn_year, replace
drop publn_date
sort appln_id pat_publn_id
save appln_id_pat_publn_id_04-15, replace
gsort appln_id -pat_publn_id
by appln_id: gen seq=_n
keep if seq==1
drop seq
save appln_id_pat_publn_id_04-15_unique, replace
*/


** Sample for KR --> KIPRIS

use table\dta\appln_id_pat_publn_id_04-15_unique, clear
merge 1:m appln_id using table\dta\Concordance_appln_id_person_id, nogen keep(match)
merge m:1 person_id using table\dta\person_id_group_foreign_firms, nogen keep(master)
keep if appln_auth=="KR"
drop if strlen(appln_nr)==10		// If publn_auth=="WO", String length==10 --> go to Google Patents
gen app_nr = "10"+appln_nr			// Original patent application number
drop if appln_id==274774968			// Odd (duplicated) observation (person_id=32733082)
destring app_nr, replace
keep  person_id appln_id pat_publn_id app_nr
order person_id appln_id pat_publn_id app_nr
save person_id_appln_id_app_nr_04-15_KR, replace
contract app_nr
drop _f
export delimited using app_nr_04-15_KR.csv, replace


** Extract UNIQUE person_id for KR KIPRIS Sample

use person_id_appln_id_app_nr_04-15_KR, clear
bysort appln_id: egen n_assignees = count(person_id)
bysort person_id: egen n_applns = count(appln_id)

forval i=1/4 {
	
	preserve
	keep if n_assignees==1
	gsort person_id -appln_id
	by person_id: gen seq=_n
	keep if seq==1
	keep person_id appln_id pat_publn_id app_nr
	gen rep=`i'
	tempfile firm`i'
	save `firm`i''
	restore

	drop if n_assignees==1
	merge m:1 person_id using `firm`i'', nogen keepusing(person_id) keep(master)
	drop n_assignees
	bysort appln_id: egen n_assignees = count(person_id)
	sort n_assignees n_applns person_id 
	}

gsort person_id -appln_id
by person_id: gen seq=_n
keep if seq==1
keep appln_id person_id pat_publn_id app_nr
gen rep=5

forval i=1/4 {
	append using `firm`i''
	}
sort rep person_id pat_publn_id appln_id
save person_id_appln_id_app_nr_04-15_KR_unique, replace
contract app_nr
drop _f
export delimited using app_nr_04-15_KR_unique.csv, replace
*/


** Sample for WO --> Google Patent

cd D:\KDI\Innovation\Data\PATSTAT
use table\dta\appln_id_pat_publn_id_04-15_unique, clear
merge 1:m appln_id using table\dta\Concordance_appln_id_person_id, nogen keep(match)
merge m:1 person_id using table\dta\person_id_group_foreign_firms, nogen keep(master)
keep if appln_auth=="KR"
keep if strlen(appln_nr)==10
gen pub_nr = publn_auth + publn_nr + publn_kind
keep  person_id appln_id pat_publn_id pub_nr
order person_id appln_id pat_publn_id pub_nr
save person_id_appln_id_pub_nr_04-15_WO, replace
contract pub_nr
drop _f
export delimited using pub_nr_04-15_WO.csv, replace


** Extract UNIQUE person_id for WO Google Sample

use person_id_appln_id_pub_nr_04-15_WO, clear
bysort appln_id: egen n_assignees = count(person_id)
bysort person_id: egen n_applns = count(appln_id)

forval i=1/4 {
	
	preserve
	keep if n_assignees==1
	gsort person_id -appln_id
	by person_id: gen seq=_n
	keep if seq==1
	keep person_id appln_id pat_publn_id pub_nr
	gen rep=`i'
	tempfile firm`i'
	save `firm`i''
	restore

	drop if n_assignees==1
	merge m:1 person_id using `firm`i'', nogen keepusing(person_id) keep(master)
	drop n_assignees
	bysort appln_id: egen n_assignees = count(person_id)
	sort n_assignees n_applns person_id 
	}

gsort person_id -appln_id
by person_id: gen seq=_n
keep if seq==1
keep appln_id person_id pat_publn_id pub_nr
gen rep=5

forval i=1/4 {
	append using `firm`i''
	}
sort rep person_id pat_publn_id appln_id
save person_id_appln_id_pub_nr_04-15_WO_unique, replace
contract pub_nr
drop _f
export delimited using pub_nr_04-15_WO_unique.csv, replace
*/

