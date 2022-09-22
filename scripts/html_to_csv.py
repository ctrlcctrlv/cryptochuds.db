# This file is not my work.
# Origin: https://www.geeksforgeeks.org/convert-html-table-into-csv-file-in-python/
# Slightly modified.

# Importing the required modules
import os
import sys
import pandas as pd
from bs4 import BeautifulSoup

path = sys.argv[1]
out = sys.argv[2]

# empty list
data = []

# for getting the header from
# the HTML file
list_header = []
soup = BeautifulSoup(open(path),'html.parser')
header = soup.find_all("table")[0].find("tr")

for items in header:
    try:
        list_header.append(items.get_text().strip())
    except:
        continue

# for getting the data
HTML_data = soup.find_all("table")[0].find_all("tr")[1:]

for element in HTML_data:
    sub_data = []
    for sub_element in element:
        try:
            sub_data.append(sub_element.get_text().strip())
        except:
            continue
    data.append(sub_data)

# Storing the data into Pandas
# DataFrame
dataFrame = pd.DataFrame(data = data, columns = list_header)

# Converting Pandas DataFrame
# into CSV file
dataFrame.to_csv(out)
