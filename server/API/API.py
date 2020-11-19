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

@app.route('/api/testi/post/newDevice', methods=['POST'])
def postDeviceID():
    print (request.is_json)
    content = request.get_json()
    print (content['testinumeroINT'])
    print (content['testichar'])
    query = '''INSERT INTO Testi (testinumeroInt, testichar) values ('{}','{}')'''.format(content['testinumeroINT'], content['testichar'])
    db.sqlInsert(query)
    return "Post successful"

#endregion

@app.errorhandler(404)
def page_not_found(e):
    return "<h1>404</h1><p>The resource could not be found.</p>", 404

app.run()