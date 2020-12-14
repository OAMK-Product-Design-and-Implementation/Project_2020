import requests
import json

# Don't change these urls, they are example http method urls and they can be changed on the server side
# also more can be made for more specific use cases
LINUX = True

if LINUX == True:
    getUrl = 'http://195.148.21.106/api/imagesbytime/get/2020-12-09 06:39:04'
    getSpecificUrl = 'http://195.148.21.106/api/testi/get/'
    postUrl = 'http://195.148.21.106/api/devices/post/batterylimits'
else:
    getUrl = 'http://127.0.0.1:5000/api/imagesbytime/get/2020-12-09 19:21:33'
    getSpecificUrl = 'http://127.0.0.1:5000/api/testi/get/'
    postUrl = 'http://127.0.0.1:5000/api/testi/post/newDevice'

def getExample():
    #Example gets json data from url specified above
    getData = requests.get(getUrl)
    
    #converts the data to json
    response = getData.json()
    print(response)

    #example how to get more specific info with get method
def getSpecificColumn():
    columnName = raw_input("Give Column name\n(testinumeroINT, testichar, testiTeksti, testiTeksti2)")

    # url + variable name combines them to one string which is then handled on the API side
    print(getSpecificUrl + columnName)
    getData = requests.get(getSpecificUrl + columnName)
    response = getData.json()
    print(response)

def postExample():

    # Example for a json object. For compatibility with server don't change the strings between " "
    jsonExample = {
                    "Batterylimit": 25,
                    "DeviceId": 4,
                  }
    try:
    #Sends a post request to url specified in the beginning, that is the server url, don't change
        x = requests.post(postUrl, json = jsonExample)
        return "post success"
    except:
        return "Post failed"
    # just a ui type of way to use the methods
while(True):
    x = raw_input("1: Get all method \n2: Get specific table\n3: Post method ")

    if int(x) == 2:
        getSpecificColumn()
    if int(x) == 3:
        postExample()
    if int(x) == 1:
        getExample()
    else:
        continue