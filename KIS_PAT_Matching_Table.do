

clear all
cap log close
set more off
cd D:\KDI\Innovation\Data

use PAT_Matching_Firmlist, clear
contract psn_name stn*
joinby stn_name* stn_entity stn_address using KIS_Matching_Firmlist

save reviewlist\KIS_PAT_Matching_Table1, replace
