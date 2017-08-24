clear all
cap log close
set more off

*gl log C:\Users\master\Desktop\a.log
gl csv D:\KDI\Innovation\Data\kr4.csv
gl path D:\KDI\Innovation\Data

cd $path

*log using $log, replace
import delimited $csv
keep person_id psn_name han_id
egen c_name=sieve(psn_name), keep(alpha numeric space) //egenmore 설치해야함
replace c_name=strupper(c_name)

*LTD LIMITED => 삭제 추가작업필요함
replace c_name=subinstr(c_name, "LTD" , "", .)
replace c_name=subinstr(c_name, "LIMITED" , "", .)

*CORPORTAION => CO
replace c_name=subinstr(c_name, "CORPORATION" , "CO", .)

*기업명 중 co가 앞자리에 있는것을 뒤로 보내기, 중간것들은 어떻게 처리해야할지 고민
split c_name, g(a) l(100) p(" ")
replace c_name=subinstr(c_name, "CO", "", .) if a1=="CO"
replace c_name=c_name+"CO" if a1=="CO"

*공백지우기
replace c_name=subinstr(c_name, " ", "", .) 

/*
**기업명중 이상한 것들 로그파일로 체크해보기
generate var25 = 1 in 1
replace var25=1 in 1/35000
tab a1 if var25==1
replace var25=2 in 35001/70000
tab a1 if var25==2
replace var25=3 in 70001/105000
tab a1 if var25==3
replace var25=4 in 105001/135007
tab a1 if var25==4
forvalue i=2/19{
tab a`i'
}
log close
*/
drop a*


save kr.dta, replace
