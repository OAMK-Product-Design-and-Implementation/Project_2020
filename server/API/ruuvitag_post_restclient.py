
# A simple example post client
# Tables are in TestDataBase (configured by RestApi.py and databaseConnect.py)

import requests
import json
import time

local = False

if local == False:
    postUrl = 'http://195.148.21.106/api/devices/post/newdevicename'
    postUrl2 = 'http://195.148.21.106/api/ruuvi/post/details'
else:
    postUrl = 'http://127.0.0.1:5000/api/devices/post/location'
    postUrl2 = 'http://127.0.0.1:5000/api/devices/post/status'

while(True):

    # Example json data to post
    j_file = {
        "DeviceName": "autooooo",
        "idDevice": "2"}

    print("Posting the data to: ", postUrl)
    x = requests.post(postUrl, json = j_file)

    if x.status_code == 200:
        print("Code 200, success!")
    else:
        print("Error", x)
        print("The post was unsuccessful.\n")
        time.sleep(1)
        break


    j_file2 = {
        "Devices_idDevice": "2",
        "Temperature": "22", 
        "Humidity": "22", 
        "AirPressure": "22"}

    print("Posting the data to: ", postUrl2)
    x2 = requests.post(postUrl2, json = j_file2)

    if x2.status_code == 200:
        print("Code 200, success!")
    else:
        print("Error", x2)
        print("The post was unsuccessful.\n")
        time.sleep(1)
        break

    time.sleep(2) 
    break       
