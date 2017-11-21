
clear all
cd D:\KDI\Innovation\Data
gl Rterm_path "C:\Program Files\Microsoft\R Open\R-3.4.0\bin\x64\R.exe"
gl version "v1"

use KIS_All_FirmList, clear
joinby name_kor using PAT_KORname_Standardized_${version}_matched
contract business pub_nr psn_name
drop _f
joinby pub_nr using PATSTAT\table\dta\psn_name_pub_nr_04-15_Rsample
joinby pat_publn_id using PATSTAT\table\dta\appln_id_pat_publn_id
joinby appln_id using PATSTAT\table\dta\Concordance_appln_id_person_id
joinby person_id using PATSTAT\table\dta\person_id_group_04-15
contract business psn_name person_id
drop _f

sort person_id business
qui unique business, by(person_id) gen(n_firms)
drop if n_firms==1



use PAT_KORname_Standardized_${version}_matched, clear
