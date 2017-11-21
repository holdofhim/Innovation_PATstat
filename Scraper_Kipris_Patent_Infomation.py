# -*- coding: utf-8 -*-

import csv
import time
import pandas as pd
from multiprocessing import Pool
from selenium import webdriver
from bs4      import BeautifulSoup


## Designate Input & Output data

csvinput = pd.read_csv(r"D:\KDI\Innovation\Data\PATSTAT\app_nr_04-15_KR_unique.csv")
app_nr = csvinput.values.flatten()
txtoutput = r"D:\KDI\Innovation\Data\PATSTAT\Patinfo_app_nr_04-15_KR_unique.txt"


## Designate URL and launch PhantomJS as webdriver
 
url_kipris = "http://kpat.kipris.or.kr/kpat/"
mainsearch = "searchLogina.do?next=MainSearch"
biblioview = "biblioa.do?method=biblioMain_biblio&next=biblioViewSub02&applno="
gettype ="&getType=Sub02"
phantom_path = r"D:\Onedrive\Scraper\phantomjs-2.1.1-windows\bin\phantomjs.exe"
driver = webdriver.PhantomJS(phantom_path)
driver.get(url_kipris+mainsearch)


## define scraper function

def scraper(app_nr):
    driver.get(url_kipris+biblioview+str(app_nr)+gettype)
    html = driver.page_source
    soup = BeautifulSoup(html, 'html.parser')
    
    assignee_element = soup.select('tbody:nth-of-type(1) > tr > td.name')
    assignee_address_element  = soup.select('tbody:nth-of-type(1) > tr > td.txt_left')
    inventor_element = soup.select('tbody:nth-of-type(2) > tr > td.name')
    inventor_address_element = soup.select('tbody:nth-of-type(2) > tr > td.txt_left')
    
    assignee = [x.text.strip() for x in assignee_element]
    assignee_address = [x.text.strip() for x in assignee_address_element]
    inventor = [x.text.strip() for x in inventor_element]
    inventor_address = [x.text.strip() for x in inventor_address_element]
    
    data = (app_nr, list(zip(assignee,assignee_address)), list(zip(inventor,inventor_address)))
    return data


## Execute the scraper function using multiprocessing pool
    
if __name__=='__main__':
    #__spec__ = "ModuleSpec(name='builtins', loader=<class '_frozen_importlib.BuiltinImporter'>)"
    start_time = time.time()
    pool = Pool(processes=46)
    mypatent = pool.map(scraper, app_nr)
    with open(txtoutput, 'w', encoding='UTF-8') as output:
        writer = csv.writer(output, lineterminator='\n')
        writer.writerows(mypatent)
    print("--- %s seconds ---" % (time.time() - start_time))



## Some other trials

#    txtfile = r"D:\KDI\Innovation\Data\PATSTAT\Patent_Information_04-15_KR_from_KIPRIS.txt"
#    with open(txtfile, 'w') as output:
#        output.writelines('\n'.join('%s %s %s' % x for x in mypatent))


#if __name__=='__main__':
#    start_time = time.time()
#    mypatent = {}
#    for app_nr in patent:
#        data = scraper(app_nr)
#        mypatent[app_nr]=data 
#    print("--- %s seconds ---" % (time.time() - start_time))


## Use Chromedriver as webdriver

#chrome_path = r"D:\Onedrive\Scraper\chromedriver.exe"
#
#options = webdriver.ChromeOptions()
#options.add_argument('--incognito')
#options.add_argument('--ignore-certificate-errors')
#options.add_argument('--ignore-ssl-errors')
#options.add_argument('--disable-infobars')
#
#driver = webdriver.Chrome(chrome_path, chrome_options=options)
#driver.get(url_kipris)
#driver.get(url_patent)
#
#html = driver.page_source
#soup = BeautifulSoup(html, 'html.parser')
#
#assignee_element = soup.select('tbody:nth-of-type(1) > tr > td.name')
#address_element  = soup.select('tbody:nth-of-type(1) > tr > td.txt_left')
#
#assignee = [x.text.strip() for x in assignee_element]
#address  = [x.text.strip() for x in address_element]
#
#driver.quit()

#divBiblioContent > table:nth-child(4) > tbody > tr:nth-child(1) > td.num
#divBiblioContent > table:nth-child(4) > tbody > tr:nth-child(1) > td.txt_left
#driver.find_element_by_id("queryText").send_keys(patent)
#time.sleep(2)
#driver.find_element_by_xpath('//*[@id="SearchPara"]/fieldset/span[1]/a/img').click()
#time.sleep(2)
#driver.find_element_by_xpath('//*[@id="divViewSel1020080062675"]/div[1]/h1/a').click()
#time.sleep(2)
#driver.switch_to_window(driver.window_handles[1])
#driver.find_element_by_xpath('//*[@id="liViewSub02"]/a').click()
#time.sleep(2)