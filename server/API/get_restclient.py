
# Scans a folder for json or txt-files, POSTs them, and moves them to an archive folder
# Other files, that are not intended for the DB, should not be kept at the designated folders
# Works with RestApi.py, new address routes should be added there
# Tables are in mydb in mysql (configured by RestApi.py and databaseConnect.py)

import requests
import json
import os, os.path
import time

saveget_directory = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\savejson\\"
file_name = "newest_data"

local = False

if local == False:
    getUrl = 'http://195.148.21.106/api/doori/get/all'
else:
    getUrl = 'http://127.0.0.1:5000/api/doori/get/all'

while(True):
   # Gets json data from url specified above
    getData = requests.get(getUrl)
    # converts the data to json
    response = getData.json()
    
    fullpath = os.path.join(saveget_directory, file_name+".json")
    with open(fullpath, "w") as json_file:
        json.dump(response, json_file)
        print("Get data received and saved to: ", saveget_directory)
    time.sleep(5)