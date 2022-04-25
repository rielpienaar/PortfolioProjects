#!/usr/bin/env python
# coding: utf-8

# In[3]:


#load all the required libraries
from bs4 import BeautifulSoup
import requests
import time
import datetime
import smtplib


# In[4]:


# connect to the website
url = "https://www.amazon.co.uk/Callaway-Strata-Complete-Piece-Package/dp/B07H2CKPJV/ref=sr_1_1?dchild=1&keywords=golf%2Bsets%2Bmens%2Bright%2Bhand%2Bfull%2Bset&qid=1635089931&sprefix=golf%2Bset%2Caps%2C245&sr=8-1&th=1"

# create headers from httpbin.org/get
headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"}

# send get information request to the website
page = requests.get(url, headers = headers)

soup1 = BeautifulSoup(page.content, "html.parser") #obtain the data from the website
soup2 = BeautifulSoup(soup1.prettify(), "html.parser") #put the html data into a better format

title = soup2.find(id='productTitle').get_text() #get the title of the product
price = soup2.find(id='corePriceDisplay_desktop_feature_div').get_text() #get the price for the object [id for price is not available, had to use the overarching id (get the full price and the parts its consists of)]


# In[5]:


price = price.strip()[1:7] #only included the end range due to the chracters imported in the price object 
#price value will change per execution of code in this block
title = title.strip()


# In[6]:


# add a timestamp to show when the data was scraped
today = datetime.date.today()
#print(today)


# In[7]:


#create a csv file with the data from the website
import csv

# place the desired headers and data (already saved above) in seperate lists
header = ['Product Title', 'Price', 'Date']
data = [title, price, today]

#create a new csv file and writing the above lists' data onto the file
with open('AmazonWebScraping.csv', 'w', newline='', encoding = 'UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)


# In[37]:


#install pandas library [got a ModuleError]
get_ipython().system('pip install pandas')


# In[11]:


#check if data is appended without opening the csv file
import pandas as pd
file = pd.read_csv(r"C:/Users/rielp/Data Analytics Projects/AmazonWebScraping.csv")
print(file)


# In[10]:


#append data to the csv file
with open('AmazonWebScraping.csv', 'a+', newline='', encoding = 'UTF8') as f:
    writer = csv.writer(f)
    writer.writerow(data)


# In[12]:


#create function to update the price daily

def check_price():
    url = "https://www.amazon.co.uk/Callaway-Strata-Complete-Piece-Package/dp/B07H2CKPJV/ref=sr_1_1?dchild=1&keywords=golf%2Bsets%2Bmens%2Bright%2Bhand%2Bfull%2Bset&qid=1635089931&sprefix=golf%2Bset%2Caps%2C245&sr=8-1&th=1"
    headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"}
    page = requests.get(url, headers = headers)
    soup1 = BeautifulSoup(page.content, "html.parser") 
    soup2 = BeautifulSoup(soup1.prettify(), "html.parser") 
    title = soup2.find(id='productTitle').get_text()
    price = soup2.find(id='corePriceDisplay_desktop_feature_div').get_text()
    today = datetime.date.today()
    header = ['Product Title', 'Price', 'Date']
    data = [title, price, today]
    with open('AmazonWebScraping.csv', 'a+', newline='', encoding = 'UTF8') as f:
        writer = csv.writer(f)
        writer.writerow(data)


# In[ ]:


# run the function every 24h (86400 seconds) to update the price to ensure that it's up to date
while True:
    check_price()
    time.sleep(86400)


# In[ ]:




