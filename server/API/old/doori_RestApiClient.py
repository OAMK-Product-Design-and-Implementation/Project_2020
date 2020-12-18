
#   todo: just read a json instead of asking for a manual input
#   Table is in mydb, not in TestDataBase
#   works only with test_API.py

import requests
from flask import json

# Don't change these urls, they are example http method urls and they can be changed on the server side
# also more can be made for more specific use cases
LINUX = False

if LINUX == False:
    getUrl = 'http://195.148.21.106/api/doori/get/all'
    getSpecificUrl = 'http://195.148.21.106/api/doori/get/'
    postUrl = 'http://195.148.21.106/api/doori/post/newDoori'
else:
    getUrl = 'http://127.0.0.1:5000/api/doori/get/all'
    getSpecificUrl = 'http://127.0.0.1:5000/api/doori/get/'
    postUrl = 'http://127.0.0.1:5000/api/doori/post/newDoori'

def getDoori():
    #Example gets json data from url specified above
    getData = requests.get(getUrl)
    
    #converts the data to json
    response = getData.json()
    print(response)

    #example how to get more specific info with get method
def getSpecificColumn():
    columnName = input("Give Column name\n(DoorName, OpenOrNot, TimeStamp)")

    # url + variable name combines them to one string which is then handled on the API side
    print(getSpecificUrl + columnName)
    getData = requests.get(getSpecificUrl + columnName)
    response = getData.json()
    print(response)

def postDoori():

    #anything regarding inputs can be changed but try to match the amount of data sent in the json Example
    uInput = {}

    for i in range(2):
        if i == 0:
            uInput[i] = input("Give the door's name: ")
        if i == 1:
            uInput[i] = input("Is it open or not 0/1 tinyint: ")
            
    # Example for a json object. For compatibility with server don't change the strings between " "
    jsonExample = {
                    "DoorName": uInput[0],
                    "OpenOrNot": uInput[1],
                  }
    
    #Sends a post request to url specified in the beginning, that is the server url, don't change
    x = requests.post(postUrl, json = jsonExample)
    print(x)
    return "post success"

    # just a ui type of way to use the methods
while(True):
    x = input("1: Get all method \n2: Get specific table\n3: Post method ")

    if int(x) == 2:
        getSpecificColumn()
    if int(x) == 3:
        postDoori()
    if int(x) == 1:
        getDoori()
    else:
        continue