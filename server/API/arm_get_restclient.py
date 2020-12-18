
# Works with RestApi.py, new address routes should be added there (server side)
# Tables are in TestDataBase in mysql (configured by RestApi.py and databaseConnect.py)

import requests
import json
import os, os.path
import time

# Set a folder where program saves a file into which GET json data is stored
saveget_directory = "D:\\OneDrive - Oulun ammattikorkeakoulu\\S2020_Projekti\\savejson\\"
file_name = "location_status"
file_name2 = "chargestation"

getUrl = 'http://195.148.21.106/api/devices/get/devicelocationsstatus'
getUrl2 = 'http://195.148.21.106/api/devices/get/latestcaratchargestation'

while(True):
    # Gets json data from url specified above
    getData = requests.get(getUrl)
    # converts the data to json
    response = getData.json()
    
    fullpath = os.path.join(saveget_directory, file_name+".json")
    with open(fullpath, "w") as json_file:
        json.dump(response, json_file)
        print("Get data received and saved to: ", saveget_directory)


    getData = requests.get(getUrl2)
    response = getData.json()
    
    fullpath = os.path.join(saveget_directory, file_name2+".json")
    with open(fullpath, "w") as json_file:
        json.dump(response, json_file)
        print("Get data received and saved to: ", saveget_directory)

    time.sleep(5)