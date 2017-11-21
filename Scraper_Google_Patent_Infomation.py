# -*- coding: utf-8 -*-

import csv
import time
import pandas as pd
import requests
from multiprocessing import Pool
from bs4      import BeautifulSoup


## Designate Input & Output data

csvfile = pd.read_csv(r"D:\KDI\Innovation\Data\PATSTAT\pub_nr_04-15_WO_unique.csv")
pub_nr = csvfile.values.flatten()
txtoutput = r"D:\KDI\Innovation\Data\PATSTAT\Patinfo_pub_nr_04-15_WO_unique.txt"
url_google = "https://patents.google.com/patent/"


## Define scraper function using requests and Beautifulsoup

def scraper(pub_nr):
    html = requests.get(url_google+pub_nr)
    html.encoding = 'UTF-8'
    soup = BeautifulSoup(html.text, 'html.parser')
    
    assignee_element = soup.select('dd[itemprop="assigneeOriginal"]')
    inventor_element = soup.select('dd[itemprop="inventor"]')
    assignee = [x.text.strip() for x in assignee_element]
    inventor = [x.text.strip() for x in inventor_element]
    
    data = (pub_nr, assignee, inventor)
    return data


## Execute the scraper function using multiprocessing pool

if __name__=='__main__':
    start_time = time.time()
    pool = Pool(processes=46)
    mypatent = pool.map(scraper, pub_nr)
    with open(txtoutput, 'w', encoding='UTF-8') as output:
        writer = csv.writer(output, lineterminator='\n')
        writer.writerows(mypatent)
    print("--- %s seconds ---" % (time.time() - start_time))
