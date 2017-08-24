
clear all
cd D:\KDI\Innovation\Data

set obs 14
gen year = 2001+_n
tempfile year
save `year'

use D:\KDI\JMDATA\KED\FirmID_2002-2015, clear
noi merge m:1 business using SME_FirmID_MFC, nogen
noi merge m:1 business using KIS_FirmID_MFC, nogen
cross using `year'

noi merge m:1 year kedid using Patent_Registration_2002-2015, nogen
noi merge m:1 year kedid using KED_R&D_2002-2014, nogen
noi merge m:1 year business using SME_R&D_2008-2011, nogen keepusing(rnd) update replace
noi merge m:1 year business using KIS_R&D_2002-2015, nogen update
keep if year>=2005

noi merge m:1 year business using exporter_2005-2015, nogen
drop kedid
gsort year business -utilpat
bysort year business: gen seq=_n
drop if seq>1
bysort year business: egen freq=count(year)
noi tab freq
drop seq freq 
save Patent_R&D_Exporters_2005-2015, replace
