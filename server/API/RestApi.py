import sys
sys.path.insert(0, "/var/www/RestApi/API/venv/lib/python2.7/site-packages")
import flask
from flask import request, jsonify, Flask
import sqlite3
from flask_restful import Resource, Api, abort
import databaseConnect as db
from datetime import date, datetime
import re, json

import imageFileHandler as ifh

app = flask.Flask(__name__)
#app.config["DEBUG"] = True

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


@app.route('/', methods=['GET'])
def home():
    return '''<h1>Product Implementation Project</h1>
<p>Contact Admin for API access</p>'''

# New queries for TestDatabase start
#
################### Images ######################

# Post an image by idDevice (image base64 included to db)
@app.route('/api/devices/post/image64', methods=['POST'])
def postDevicesImage64():
    content = request.get_json()
    query = '''INSERT INTO Images (Devices_idDevice, Names, images) 
                VALUES ("{}", "{}", "{}")'''.format(
                    content['Devices_idDevice'],
                    content['Names'],
                    content['images']) 
    db.sqlInsert(query)
    return "Post successful"

# Post an image by idDevice (base64 decoded and saved to a directory)
@app.route('/api/devices/post/image', methods=['POST'])
def postDevicesImage():
    content = request.get_json()
    devID = content["Devices_idDevice"] 
    fileName = content["Names"]
    fileData = content["images"]
    # Save image
    ifh.saveImage(fileName, fileData)
    query = '''INSERT INTO Images (Devices_idDevice, Names) 
                VALUES ("{}", "{}")'''.format(devID, fileName)
    db.sqlInsert(query)
    return "Post successful"

@app.route('/api/imagesbytime/get/<timest>', methods=['GET']) 
def getImageByTime(timest):
    content = request.get_json()
    query = '''SELECT Devices.DeviceName, Images.Names, Devices_idDevice, date_format(Images.Timestamp, '%Y-%m-%d %T') FROM Devices LEFT JOIN Images 
                ON Devices.idDevice = Images.Devices_idDevice WHERE Images.Timestamp > "{}"'''.format(timest)
    
    fileNames = db.sqlQuery(query)
    img_rawdata = ifh.getMultipleImages(fileNames) # TODO: fix internal server errors: imageFileHandler.py
    try:
        i = 0 # TO DO: FIX This part has issues
        wholeData = []
        for image in img_rawdata:
            imageData = fileNames[i][:4] + (img_rawdata[i],)
            wholeData.append(imageData)
            i = i + 1
        print(imageData)
        return jsonify(wholeData)
    except:
        return "Image handling failed"

@app.route('/api/images/get/<deviceid>', methods=['GET'])
def getImage(deviceid):
    content = request.get_json()
    query = '''SELECT Names FROM Images WHERE Devices_idDevice = "{}" ORDER BY Timestamp DESC LIMIT 1'''.format(deviceid)
    fileName = db.sqlQuery(query)
    img_rawdata = ifh.getImage(fileName)       
    return jsonify(img_rawdata) 

# Get image table
@app.route('/api/images/get/table', methods=['GET'])
def getImageTable():
    content = request.get_json()
    query = "SELECT Names, Timestamp, Devices_idDevice FROM Images ORDER BY Timestamp DESC"
    data = db.sqlQuery(query)
    return jsonify(data)


##################################################
################### General ######################

# Post a message by idDevice
@app.route('/api/devices/post/message', methods=['POST'])
def postDevicesMessage():
    content = request.get_json()
    query = '''INSERT INTO Message (Messagetype, Explanation, Devices_idDevice) 
                VALUES ("{}", "{}", "{}")'''.format(
                    content['Messagetype'],
                    content['Explanation'],
                    content['Devices_idDevice']) 
    db.sqlInsert(query)
    return "Post successful"

# Get messages
@app.route('/api/messages/get/messages', methods=['GET'])
def getMessages():
    content = request.get_json()
    query = "SELECT * FROM Message"
    data = db.sqlQuery(query)
    return jsonify(data)

# Post a new device
@app.route('/api/devices/post/newdevice', methods=['POST'])
def postNewDevice():
    content = request.get_json()
    query = '''INSERT INTO Devices (DeviceName, 
                DeviceType) 
                values ('{}','{}')'''.format(
                    content['DeviceName'], 
                    content['DeviceType'])
    db.sqlInsert(query)

    return "Post successful"

# GET Devices
@app.route('/api/devices/get/devices', methods=['GET'])
def getDevices():
    content = request.get_json()
    query = "SELECT * FROM Devices"
    data = db.sqlQuery(query)
    return jsonify(data)

# GET latest locations
@app.route('/api/devices/get/locations', methods=['GET'])
def getLocations():
    content = request.get_json()
    query = "SELECT * FROM Location ORDER BY Timestamp DESC"
    data = db.sqlQuery(query)
    return jsonify(data)

# Example GET
@app.route('/api/devices/get/devicelocationsstatus', methods=['GET'])
def getDeviceLocationStatus():
    content = request.get_json()
    query = "SELECT * FROM DeviceLocationsStatus"
    data = db.sqlQuery(query)
    return jsonify(data)

# Example GET
@app.route('/api/devices/get/latestcaratchargestation', methods=['GET'])
def getDeviceLatestCarAtChargeStation():
    content = request.get_json()
    query = "SELECT * FROM LatestCarAtChargeStation"
    data = db.sqlQuery(query)
    return jsonify(data)


##################################################
############## Android app start #################

# Messages
# Get messages where active is set to 1 (which is a default value upon creating a new Message)
@app.route('/api/devices/get/activemessages', methods=['GET'])  
def getActiveMessages():
    content = request.get_json()
    query = '''SELECT Message.idMessage, Message.Messagetype, Message.Explanation, date_format(Message.Timestamp, '%Y-%m-%d %T'), Devices.Devicename
    FROM Devices INNER JOIN Message ON Devices.idDevice = Message.Devices_idDevice WHERE Message.Active = "1"'''
    data = db.sqlQuery(query)
    return jsonify(data)

# Post update to set message to 0 (inactive) by message id
@app.route('/api/message/post/messageinactive', methods=['POST'])
def postInactive():
    content = request.get_json()
    query = '''UPDATE Message SET Active = "0" 
               WHERE idMessage = {}'''.format(content['idMessage']) 
    db.sqlInsert(query)
    return "Post successful"

# Sensors
# Get all ruuvitag id's
@app.route('/api/devices/get/ruuvitagid', methods=['GET'])
def getRuuvitagID():
    content = request.get_json()
    query = '''SELECT DISTINCT idDevice FROM Devices WHERE DeviceType = "ruuvitag"'''
    data = db.sqlQuery(query)
    return jsonify(data)

# Get latest details of ruuvitag by id
@app.route('/api/doordetail/get/<deviceid>', methods=['GET'])
def getRuuvitagLatest(deviceid):                                                                  
    content = request.get_json()
    query = '''SELECT Battery.BatteryStatus, Devices.DeviceName, Location.Segment, Door_status.OpenOrNot, 
    Measurements.Temperature, Measurements.Humidity, Measurements.AirPressure, Devices.Connected
    FROM Door LEFT JOIN Devices ON Door.Devices_idDevice = Devices.idDevice 
    LEFT JOIN Door_status ON Door.idDoor = Door_status.Door_idDoor
    LEFT JOIN Measurements ON Devices.idDevice = Measurements.Devices_idDevice
    LEFT JOIN Battery ON Devices.idDevice = Battery.Devices_idDevice 
    LEFT JOIN Location ON Devices.idDevice = Location.Devices_idDevice 
    WHERE Devices.idDevice = {} AND Devices.DeviceType = "ruuvitag" 
    ORDER BY Measurements.Timestamp DESC, Door_status.Timestamp DESC, Battery.Timestamp DESC, Location.Timestamp DESC LIMIT 1'''.format(deviceid)
    data = db.sqlQuery(query)
    return jsonify(data)

# Get limits of ruuvitag by id
@app.route('/api/ruuvilimit/get/<deviceid>', methods=['GET']) 
def getRuuvitagLimits(deviceid):
    content = request.get_json()
    query = '''SELECT Measurements_Limits.Temperature_max, Measurements_Limits.Temperature_min, Measurements_Limits.Humidity_max, Measurements_Limits.Humidity_min, 
            Measurements_Limits.AirPressure_max, Measurements_Limits.AirPressure_min, Measurements_Limits.Batterylimit FROM Devices
            LEFT JOIN Measurements_Limits ON Measurements_Limits.Devices_idDevice = Devices.idDevice WHERE Devices.idDevice = "{}"'''.format(deviceid)
    data = db.sqlQuery(query)
    return jsonify(data)

# Post ruuvitag measure limits
@app.route('/api/ruuvilimit/post/ruuvilimits', methods=['POST'])
def postRuuvitagLimits():
    content = request.get_json()
    query = '''UPDATE Measurements_Limits SET Temperature_max = "{}", Temperature_min = "{}", Humidity_max = "{}", Humidity_min = "{}", 
                AirPressure_max = "{}", AirPressure_min = "{}", Batterylimit = "{}" WHERE Devices_idDevice = "{}"'''.format(
                    content['Temperature_max'],
                    content['Temperature_min'],
                    content['Humidity_max'],
                    content['Humidity_min'],
                    content['AirPressure_max'],
                    content['AirPressure_min'],
                    content['Batterylimit'],
                    content['Devices_idDevice']) 
    db.sqlInsert(query)
    return "Post successful"

# Gopigos
# Get Gopigo IDs
@app.route('/api/devices/get/gopigoids', methods=['GET'])
def getCarIDs():
    content = request.get_json()
    query = '''SELECT DISTINCT idDevice FROM Devices WHERE DeviceType = "gopigo"'''
    data = db.sqlQuery(query)
    return jsonify(data)

# Get latest details of gopigo by ID
@app.route('/api/gopigoid/get/<deviceid>', methods=['GET'])
def getGopigoDetails(deviceid):
    content = request.get_json()
    query = '''SELECT Devices.DeviceName, Battery.BatteryStatus, Location.Segment, Devices.Connected FROM Devices 
                LEFT JOIN Battery ON Devices.idDevice = Battery.Devices_idDevice LEFT JOIN Location ON Devices.idDevice = Location.Devices_idDevice
                WHERE idDevice = "{}" ORDER BY Battery.Timestamp DESC, Location.Timestamp DESC LIMIT 1'''.format(deviceid)
    data = db.sqlQuery(query)
    return jsonify(data)

# Post a new name for a device by id
@app.route('/api/devices/post/newdevicename', methods=['POST'])
def postNewDeviceName():
    content = request.get_json()
    query = '''UPDATE Devices SET DeviceName = "{}" 
               WHERE idDevice = "{}"'''.format(content['DeviceName'],
                    content['idDevice']) 
    db.sqlInsert(query)
    return "Post successful"

# Charging station
# Get current status
@app.route('/api/devices/get/stationstatus', methods=['GET'])
def getStationStatus():
    content = request.get_json()
    query = '''SELECT Charger_Status.Status, Devices.DeviceName FROM Devices LEFT JOIN Charger_Status 
                ON Devices.idDevice = Charger_Status.Devices_idDevice ORDER BY Timestamp DESC LIMIT 1'''
    data = db.sqlQuery(query)
    return jsonify(data)

# Get history of 10 older than timestamp
@app.route('/api/charge/get/<timest>', methods=['GET'])
def getStationHistory(timest):
    content = request.get_json()
    query = '''SELECT Devices.DeviceName, date_format(Charger_Status.Timestamp, '%Y-%m-%d %T')
                FROM Devices INNER JOIN Charger_Status ON Devices.idDevice = Charger_Status.Devices_idDevice 
                WHERE Charger_Status.Timestamp < "{}" ORDER BY Charger_Status.Timestamp DESC LIMIT 10'''.format(timest)
    data = db.sqlQuery(query)   # 2020-12-01 12:12:12 (yyyy-mm-dd hh:mm:ss) timestamp format as input
    return jsonify(data)

##################################################
############## Ruuvitag start ####################

# Get doors
@app.route('/api/ruuvi/get/doors', methods=['GET'])
def getDoors():
    content = request.get_json()
    query = "SELECT * FROM Door"
    data = db.sqlQuery(query)
    return jsonify(data)

# Get door status
@app.route('/api/ruuvi/get/doorstatus', methods=['GET'])
def getDoorsStatus():
    content = request.get_json()
    query = "SELECT * FROM Door_status ORDER BY Timestamp DESC"
    data = db.sqlQuery(query)
    return jsonify(data)

# Get measurements
@app.route('/api/ruuvi/get/measurements', methods=['GET'])
def getDoorMeasurements():
    content = request.get_json()
    query = "SELECT * FROM Measurements ORDER BY Timestamp DESC"
    data = db.sqlQuery(query)
    return jsonify(data)

# Assign a door for Ruuvitag
@app.route('/api/ruuvi/post/newdoor', methods=['POST'])
def postNewDoor():
    content = request.get_json()
    query = '''INSERT INTO Door (DoorName, 
                Devices_idDevice) 
                values ('{}','{}')'''.format(
                    content['DoorName'], 
                    content['Devices_idDevice'])
    db.sqlInsert(query)

    return "Post successful"

# Update a door for Ruuvitag
@app.route('/api/ruuvi/post/updatedoor', methods=['POST'])
def postUpdateDoor():
    content = request.get_json()
    query = '''UPDATE Door SET Devices_idDevice = "{}" WHERE DoorName = "{}"'''.format(
                    content['Devices_idDevice'], 
                    content['DoorName'])
    db.sqlInsert(query)

    return "Post successful"    

# Post message 
@app.route('/api/ruuvi/post/message', methods=['POST'])
def postRuuvitagMessage():
    content = request.get_json()
    query = '''INSERT INTO Message (Messagetype, Explanation, Devices_idDevice) 
                VALUES ("{}", "{}", "{}")'''.format(
                    content['Messagetype'],
                    content['Explanation'],
                    content['Devices_idDevice']) 
    db.sqlInsert(query)
    return "Post successful"

# Post door status
@app.route('/api/ruuvi/post/doorstatus', methods=['POST'])
def postRuuvitagDoor():
    content = request.get_json()
    query = '''INSERT INTO Door_status (OpenOrNot, Door_idDoor) 
                VALUES ("{}", "{}")'''.format(
                    content['OpenOrNot'],
                    content['Door_idDoor']) 
    db.sqlInsert(query)
    return "Post successful"

# Post ruuvitag measurements
@app.route('/api/ruuvi/post/details', methods=['POST'])
def postRuuvitagDetails():
    content = request.get_json()
    query = '''INSERT INTO Measurements (Devices_idDevice, Temperature, Humidity, AirPressure) 
                VALUES ("{}", "{}", "{}", "{}")'''.format(
                    content['Devices_idDevice'],
                    content['Temperature'],
                    content['Humidity'],
                    content['AirPressure']) 
    db.sqlInsert(query)
    return "Post successful"

##################################################
################# Drone start ####################

# Post message: /api/devices/post/message (see first app.route)

# Post a drone status & measurements by idDevice
@app.route('/api/drone/post/details', methods=['POST'])
def postDroneDetails():
    content = request.get_json()
    query = '''INSERT INTO Drone_Status (Status, Speed, FlyHeight, Acceleration, Devices_idDevice) 
                VALUES ("{}", "{}", "{}", "{}", "{}")'''.format(
                    content['Status'],
                    content['Speed'],
                    content['FlyHeight'],
                    content['Acceleration'],
                    content['Devices_idDevice']) 
    db.sqlInsert(query)
    return "Post successful"

# Get drone info
@app.route('/api/drone/get/details', methods=['GET'])
def getDroneDetails():
    content = request.get_json()
    query = '''SELECT Devices.DeviceName, Drone_Status.Status, Drone_Status.Speed, Drone_Status.FlyHeight, Drone_Status.Acceleration, date_format(Drone_Status.Timestamp, '%Y-%m-%d %T') 
                FROM Devices LEFT JOIN Drone_Status ON Devices.idDevice = Drone_Status.Devices_idDevice WHERE DeviceType = "drone" 
                ORDER BY Drone_Status.Timestamp DESC'''
    data = db.sqlQuery(query)
    return jsonify(data)


##################################################
################# Gopigo start ###################

# Post message: /api/devices/post/message (see first app.route)

# Gopigo (and Ruuvitag?) location POST
@app.route('/api/devices/post/location', methods=['POST'])
def postLocation():
    content = request.get_json()
    query = '''INSERT INTO Location (Segment, 
                Devices_idDevice) 
                values ('{}','{}')'''.format(
                    content['Segment'], 
                    content['Devices_idDevice'])
    db.sqlInsert(query)

    return "Post successful"

# Gopigo charger status POST
@app.route('/api/devices/post/status', methods=['POST'])
def postStatus():
    content = request.get_json()
    query = '''INSERT INTO Charger_Status (Status, 
                Devices_idDevice) 
                values ('{}','{}')'''.format(
                    content['Status'], 
                    content['Devices_idDevice'])
    db.sqlInsert(query)

    return "Post successful"

# Gopigo battery POST
@app.route('/api/devices/post/battery', methods=['POST'])
def postBattery():
    content = request.get_json()
    query = '''INSERT INTO Battery (BatteryStatus, 
                Devices_idDevice) 
                values ('{}','{}')'''.format(
                    content['BatteryStatus'], 
                    content['Devices_idDevice'])
    db.sqlInsert(query)

    return "Post successful"

#Post battery limits
@app.route('/api/devices/post/batterylimits', methods=['POST'])
def postGopigoBatteryLimits():
    content = request.get_json()
    query = '''UPDATE Measurements_Limits SET Batterylimit = "{}" WHERE Devices_idDevice = "{}"'''.format(
                    content['Batterylimit'],
                    content['Devices_idDevice']) 
    db.sqlInsert(query)
    return "Post successful"

@app.route('/api/devices/get/batterylimits/<deviceID>', methods=['GET'])
def getGopigoBatteryLimits(deviceID):
    content = request.get_json()
    query = '''Select Batterylimit from Measurements_Limits WHERE Devices_idDevice = "{}"'''.format(deviceID)
    data = db.sqlQuery(query)
    return jsonify(data)

# Gopigo set OpenOrNot active event into inactive POST
@app.route('/api/gopigo/post/eventinactive', methods=['POST'])
def postEventInactive():
    content = request.get_json()
    query = '''UPDATE Door_status 
                JOIN Door ON Door_status.Door_idDoor = Door.idDoor
                JOIN Devices ON Door.Devices_idDevice = Devices.idDevice
                JOIN Location ON Devices.idDevice = Location.Devices_idDevice
                SET Door_status.Active = "0" WHERE Door_status.Active = "1" AND Location.Segment = "{}"'''.format(
                    content['Segment'])
    db.sqlInsert(query)
    return "Post successful"

# Get active OpenOrNots
@app.route('/api/gopigo/get/actives', methods=['GET'])
def getGopigoActives():
    content = request.get_json()
    query = '''SELECT Location.Segment, Door_status.Timestamp
                FROM Door LEFT JOIN Devices ON Door.Devices_idDevice = Devices.idDevice
                LEFT JOIN Door_status ON Door.idDoor = Door_status.Door_idDoor
                LEFT JOIN Location ON Devices.idDevice = Location.Devices_idDevice
                WHERE Door_status.OpenOrNot = "1" AND Door_status.Active = "1" ORDER BY Door_status.Timestamp DESC LIMIT 1'''
    data = db.sqlQuery(query)
    return jsonify(data)

#
# End

@app.errorhandler(404)
def page_not_found(e):
    return "<h1>404</h1><p>The resource could not be found.</p>", 404

if __name__ == "__main__":
	app.run()
