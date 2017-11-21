
clear all
cd D:\KDI\Innovation\Data\PATSTAT\table\dta

use Unique_person_id_appln_id_04-15, clear
merge 1:1 person_id using person_id_group, nogen keep(match)

bysort psn_name: egen freq = count(person_id)

joinby appln_id using appln_id_pat_publn_id
joinby pat_publn_id using psn_name_pub_nr_04-15_Rsample
joinby person_id using person_id_group_04-15
