import requests
import json

#install requests library (pip install requests)
#install json/flask library (pip install Flask)


#Calling this function give the devicename and type
#Devie types: drone, gopigo, ruuvitag, battery
def CreateNewDevice(Name, deviceType):
    postUrl = "http://195.148.21.106/api/devices/post/newdevice"
    jsonData = {
                "DeviceName": Name,
                "DeviceType": deviceType
                }

    try:
        x = requests.post(postUrl, json = jsonData)
        return "post success"
    except:
        return "post failed"

#Sends a message to database message table
# Message types are: Error, Warning, Info & Intruder 
def CreateMessage(type, message, deviceID):
    postUrl = "http://195.148.21.106/api/devices/post/message"
    jsonData = {
                "MessageType": type,
                "Explanation": message,
                "Devices_idDevice": deviceID
                }

    try:
        x = requests.post(postUrl, json = jsonData)
        return "post success"
    except:
        return "post failed"

#Posts the device location to the database table
def PostLocation(location, deviceID):
    postUrl = "http://195.148.21.106/api/devices/post/location"
    jsonData = {
                "Segment": location,
                "Devices_idDevice": deviceID
                }
    try:
        x = requests.post(postUrl, json = jsonData)
        return "post success"
    except:
        return "post failed"
  
# Image needs to be in string format so encode it first before calling this.
# Image name should be in format of deviceName+timestamp+.jpg
def PostImage(imageName, image, deviceID):
    postUrl = "http://195.148.21.106/api/devices/post/image"
    jsonData = {
                "Devices_idDevice": deviceID,
                "Names": imageName,
                "images": image
                }
    try:
        x = requests.post(postUrl, json = jsonData)
        return "post success"
    except:
        return "post failed"

# Charginstation status. Post if device should be on the chargin station
def postDeviceStatus(status, deviceID):
    postUrl = "http://195.148.21.106/api/devices/post/status"
    jsonData = {
                "Status": status,
                "deviceID": deviceID,
                }
    try:
        x = requests.post(postUrl, json = jsonData)
        return "post success"
    except:
        return "post failed"

#Use to post battery status to database table.
def PostBatteryStatus(BatteryStatus, deviceID):
    postUrl = "http://195.148.21.106/api/devices/post/battery"
    jsonData = {
                "BatteryStatus": BatteryStatus,
                "deviceID": deviceID,
                }
    try:
        x = requests.post(postUrl, json = jsonData)
        return "post success"
    except:
        return "post failed"

#use to get deviceid by devicename
def getDevices():
    getData = requests.get("http://195.148.21.106/api/devices/get/devices")
    response = getData.json()
    return response