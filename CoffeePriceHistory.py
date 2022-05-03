#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


# In[127]:


#load data from the csv file into a pandas dataframe
df = pd.read_csv(r'C:/Users/rielp/Downloads/rice_beef_coffee_price_changes.csv')

#check the structure of the data
#df

#rename Price_coffee_infl to Price_change_%
df.rename({'Price_coffee_infl': 'Price_change_%'}, axis=1, inplace=True)

#drop NaN values if predictive analytics are not going to be used [it will be used later]
#df.dropna()

df


# In[ ]:





# In[148]:


#create a dataframe for only the coffee related data
coffee_only_df = df[['Year', 'Month', 'Price_coffee_kilo', 'Price_change_%']]

#check the new dataframe
coffee_only_df


# In[150]:


#price change takes into account the coffee, beef and rice columns
#recalculate the price changes values for just the coffee values

#first place the price values in a list
coffee_price_list = []
for i in coffee_only_df['Price_coffee_kilo']:
    coffee_price_list.append(i)
    
#use a for loop to calculate the price difference
v = np.diff(coffee_price_list) #use numpy to get the difference in the values in the list


coffee_price_diff = []
for i, j in zip(v, coffee_price_list):
   a = round(i/j*100,2)
   coffee_price_diff.append(a)
    
#add the first value of the price change value [no values before Feb 1992, goig to assume that it is correct]
coffee_price_diff.insert(0, df['Price_change_%'].iloc[0])

coffee_price_diff


# In[151]:


#change the variables type to that of the pandas price column 
#check column data type
coffee_only_df['Price_change_%'].dtype


# In[152]:


#change list variables data type to float64
coffee_price_diff_float64 = list(np.array(coffee_price_diff, dtype = 'float64'))

#check random indexes for data type
#coffee_price_diff_float64[0].dtype
#coffee_price_diff_float64[22].dtype
#coffee_price_diff_float64[100].dtype


# In[153]:


#replace the values in the price_change column with the calculated price changes
coffee_only_df['Price_change_%'] = coffee_price_diff_float64


# In[173]:


# check if the changes were made in the dataframe

coffee_only_df[coffee_only_df['Year']==2006]


# In[176]:


#place the average price change and price per kg in a pivot table
pd.pivot_table(coffee_only_df, index=('Year'), values=('Price_coffee_kilo', 'Price_change_%'), aggfunc=np.average)


# In[216]:


# gain the average price and inflation rate of coffee for each year
# use the groupby method and then calculate the mean
#as_index=False

price_per_year = coffee_only_df.groupby(['Year'],as_index=False)['Price_coffee_kilo'].mean()
avg_price_change_per_year = coffee_only_df.groupby(['Year'],as_index=False)['Price_change_%'].mean()

#check values for each
#price_per_year


# In[215]:


price_per_year.set_index('Year').plot(legend=None)
plt.ylabel('Price per kg ($)')
plt.ylim(0,)
plt.xlabel('Year')
plt.title('Average price per kg coffee from 1992 to 2022.')


# In[214]:


# use a line graph to illustate the price change %

avg_price_change_per_year.set_index('Year').plot(legend=None)
plt.ylabel('Price chance (%)')
plt.ylim(-6,8) #min and max for the data set
plt.xlabel('Year')
plt.title('Average price change from 1992 to 2022.')
plt.axhline(y = 0, color = 'black', linestyle = '-') #illustrate 0% line for better insight into price changes


# In[ ]:


# predict what the average price and price change will be for 2022


# In[218]:


#first calculate coefecient
coef = np.polyfit(price_per_year['Year'], price_per_year['Price_coffee_kilo'], 1)

coef


# In[225]:


#predict what the average price in 2022 will be [only Jan 2022 data is included]
#based on the assumption that it will follow past trends

coffee_2022_predicted_price = round(np.polyval(coef, 2022),3)
coffee_2022_predicted_price

