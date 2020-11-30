import sys
sys.path.insert(0, "/var/www/RestApi/API/venv/lib/python2.7/site-packages")
import flask
from flask import request, jsonify, Flask
import sqlite3
from flask_restful import Resource, Api, abort
import databaseConnect as db
from datetime import date, datetime
import re, json

app = flask.Flask(__name__)
#app.config["DEBUG"] = True

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


@app.route('/', methods=['GET'])
def home():
    return '''<h1>Distant Reading Archive</h1>
<p>A prototype API for distant reading of science fiction novels.</p>'''


#region Testmethods

@app.route('/api/testi/get/all', methods=['GET'])
def test_all():
    query = "SELECT * FROM Testi"
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/testi/get/deviceID', methods=['GET'])
def getDeviceID():
    query = "SELECT idTest FROM Testi"
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/testi/get/<variable>', methods=['GET'])
def getDevice(variable):
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = "SELECT {} FROM Testi".format(variable)
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/testi/post/newDevice', methods=['POST'])
def postDeviceID():
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = '''INSERT INTO Testi (testinumeroInt, 
                testichar,
                testiTeksti,
                testiTeksti2) 
                values ('{}','{}','{}','{}')'''.format(
                    content['testinumeroINT'], 
                    content['testichar'],
                    content['testiTeksti'],
                    content['testiTeksti2'])
    db.sqlInsert(query)

    return "Post successful"

@app.route('/api/doori/get/all', methods=['GET'])
def doori_all():
    query = "SELECT * FROM doori ORDER BY iddoori DESC LIMIT 500"
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/doori/get/deviceID', methods=['GET'])
def getDooriID():
    query = "SELECT iddoori FROM doori"
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/doori/get/<variable>', methods=['GET'])
def getDoori(variable):
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = "SELECT {} FROM doori".format(variable)
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/doori/post/newDoori', methods=['POST'])
def postDooriID():
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = '''INSERT INTO doori (DoorName, 
                OpenOrNot) 
                values ('{}','{}')'''.format(
                    content['DoorName'], 
                    content['OpenOrNot'],)
    db.sqlInsert(query)

    return "Post successful"

#endregion

@app.route('/api/devices/get/all', methods=['GET'])
def getDeviceAll():
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = "SELECT * FROM Testi"
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/devices/get/<devicename>', methods=['GET'])
def getDeviceName(devicename):
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = "SELECT * FROM Testi where DeviceName = {}".format(devicename)
    data = db.sqlQuery(query)
    return jsonify(data)

# New queries for TestDatabase start
#
@app.route('/api/devices/get/devicelocationsstatus', methods=['GET'])
def getDeviceLocationStatus():
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = "SELECT * FROM DeviceLocationsStatus"
    data = db.sqlQuery(query)
    return jsonify(data)

@app.route('/api/devices/get/latestcaratchargestation', methods=['GET'])
def getDeviceLatestCarAtChargeStation():
    print (request.is_json)
    content = request.get_json()
    print(content)
    query = "SELECT * FROM LatestCarAtChargeStation"
    data = db.sqlQuery(query)
    return jsonify(data)

#
# End

@app.errorhandler(404)
def page_not_found(e):
    return "<h1>404</h1><p>The resource could not be found.</p>", 404

if __name__ == "__main__":
	app.run()
