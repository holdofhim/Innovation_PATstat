

clear all
cd D:\KDI\TradeDB\KOR_trade

use ksic8_kosis_0714.dta, clear
collapse (sum) *ports, by(year partner)


rename (사업체수 출하금액) (nplants shipment)


rename (사업체수_ksic8 출하금액_ksic8) (nplants shipment)
collapse (sum)  nplants shipment *ports, by(year partner ksic5 income eu28 oecd)

*append using ksic5_kosis_2015

gen impen = imports/(sales-exports+imports)*100
