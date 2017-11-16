
clear all
cd D:\KDI\Innovation\Data\PATSTAT\table\dta

use publn_id_04_15, clear
joinby pat using appln_id_pat_publn_id
gen pub_nr=publn_auth+publn_nr+publn_kind
contract pub_nr appln_id
drop _freq
joinby appln_id using semi_table_04_15


noi list appln_id pub_nr person_id psn_name if inlist(pub_nr,"KR20130006133A","KR20140039792A","KR20100110051A","KR100627642B1","WO2013180351A1","WO2010030118A3")
