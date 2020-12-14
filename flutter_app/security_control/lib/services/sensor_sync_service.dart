import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:http/http.dart' as http;
import 'package:security_control/models/ruuvitag.dart';
import 'package:security_control/services/local_storage_service.dart';
import 'package:security_control/services/service_locator.dart';

class SensorSyncService {
  ReceivePort _receivePort;
  Stream _receiveBroadcastStream;
  SendPort _sendPort;
  SendPort get sendPort => _sendPort;
  LocalStorageService _localStorageService;

  // Ruuvitag data:
  StreamController<Map> _ruuviTagListMapStreamControl =
      new StreamController.broadcast();
  Stream<Map> get ruuviTagListMapStream => _ruuviTagListMapStreamControl.stream;

  Map<int, RuuviTag> _ruuviTagListMap = Map();
  Map<int, RuuviTag> get ruuviTagListMap => _ruuviTagListMap;

  SensorSyncService() {
    print('(TRACE) SensorSyncService:constructor.');
    _receivePort = ReceivePort();
    _receiveBroadcastStream = _receivePort.asBroadcastStream();
    _localStorageService = locator<LocalStorageService>();

    _receiveBroadcastStream.listen((message) {
      // Register the sendPort when the other isolate tells us so:
      if (message is List) {
        switch (message[0]) {
          case "register":
            _sendPort = message[1];
            print('(TRACE) SensorSyncService:constructor: Registered sender');
            _registerSettingListeners();
            _sendPort.send([
              "setinterval",
              _localStorageService.serverUpdateInterval.getValue()
            ]);
            _sendPort.send(
                ["setaddress", _localStorageService.serverAddress.getValue()]);
            break;
          case "ruuvitag":
            // Message[1] = id
            // message[2] = ruuvitagJSON: "[[data]]"
            //message[3] = ruuvitaglimitJSON

            if (jsonDecode(message[2]).length > 0) {
              _ruuviTagListMap[message[1]] = RuuviTag.fromJson(message[2],
                  message[1], message[3], setRuuviTagName, setRuuviTagLimits);
              _ruuviTagListMapStreamControl.add(_ruuviTagListMap);
            }
        }
      }
    });

    FlutterIsolate.spawn(entryPoint, _receivePort.sendPort);
  }

  setRuuviTagName(int id, String name) {
    _sendPort.send(["setruuvitagname", id, name]);
  }

  setRuuviTagLimits(
      double upperTemp,
      double lowerTemp,
      double upperHumi,
      double lowerHumi,
      double upperPres,
      double lowerPres,
      double lowerBattery,
      int id) {
    _sendPort.send([
      "setruuvitaglimits",
      upperTemp,
      lowerTemp,
      upperHumi,
      lowerHumi,
      upperPres,
      lowerPres,
      lowerBattery,
      id
    ]);
  }

  // Listen to server update interval and address, change when needed:
  void _registerSettingListeners() {
    _localStorageService.serverUpdateInterval.listen((value) {
      _sendPort.send(["setinterval", value]);
    });

    _localStorageService.serverAddress.listen((value) {
      _sendPort.send(["setaddress", value]);
    });
  }

  void stopSync() {
    _sendPort.send("stop");
  }

  void startSync() {
    _sendPort.send("syncruuvitags");
  }
}

void entryPoint(SendPort sendPort) {
  // Entry function for the new isolate. Define actions in listen method of
  //    receivePort.

  ReceivePort receivePort = ReceivePort();
  _SyncRuuviTagIsolate _syncRuuviTagIsolate =
      new _SyncRuuviTagIsolate(sendPort, receivePort);

  receivePort.listen((message) {
    if (message is List) {
      print('(TRACE) SyncRuuviTagIsolate:entryPoint.receivePort.listen:' +
          message[0]);

      switch (message[0]) {
        case "setinterval":
          _syncRuuviTagIsolate.setDelay(message[1]);
          break;
        case "setaddress":
          _syncRuuviTagIsolate.setAddress(message[1]);
          break;
        case "setruuvitagname":
          // message [1] = id
          // message [2] = name
          _syncRuuviTagIsolate.setRuuviTagName(message[1], message[2]);
          break;
        // case
        case "setruuvitaglimits":
          //message[1] = uppertemp, message[2] = lowertemp
          //message[3] = upperhumi, message[4] = lowerhumi
          //message[5] = upperpres, message[6] = lowerpres
          //message[7] = lowerbattery, message[8] = id
          _syncRuuviTagIsolate.setRuuviTagLimits(
              message[1],
              message[2],
              message[3],
              message[4],
              message[5],
              message[6],
              message[7],
              message[8]);
          break;
      }
    } else if (message is String) {
      print('(TRACE) SyncRuuviTagIsolate:entryPoint.receivePort.listen:' +
          message);
      if (message == "stop") {
        _syncRuuviTagIsolate.stopSync();
      } else if (message == "syncruuvitags") {
        _syncRuuviTagIsolate.startSync();
      }
    }
  });

  sendPort.send(["register", receivePort.sendPort]);
}

class _SyncRuuviTagIsolate {
  final String _debugTag = "(TRACE) _SyncRuuviTagIsolate: ";

  SendPort _sendPort;
  Timer _syncTimer;
  Duration _syncDelay;
  String _address;
  http.Client _client;

  String _ruuviTagIDListString;
  List _ruuviTagIDList;

  _SyncRuuviTagIsolate(SendPort sPort, ReceivePort rPort) {
    _sendPort = sPort;
    _syncDelay = Duration(seconds: 5);
    _ruuviTagIDList = List();
  }

  void setDelay(int value) {
    _syncDelay = Duration(seconds: value);
    if (!(_syncTimer == null)) {
      if (_syncTimer.isActive == true) {
        stopSync();
        startSync();
      }
    }
  }

  void setAddress(String address) {
    _address = "http://" + address;
    if (!(_syncTimer == null)) {
      if (_syncTimer.isActive == true) {
        stopSync();
        startSync();
      }
    }
  }

  stopSync() {
    if (!(_syncTimer == null)) {
      _syncTimer.cancel();
      _client.close();
    }
  }

  startSync() {
    // Ensure we don't start multiple of these
    stopSync();
    _client = http.Client();
    _syncTimer = Timer.periodic(_syncDelay, _sync);
  }

  _sync(Timer timer) {
    syncRuuviTagIDList();
    syncRuuviTags();
    for (var i in _ruuviTagIDList) {
      print(_debugTag + i.toString());
    }
  }

  // Function to get ruuvitag id JSON from server:
  syncRuuviTagIDList() async {
    // Get RuuviTag ID's and compare them with local values
    var response;
    try {
      response = await _client.get(_address + "/api/devices/get/ruuvitagid");
      _ruuviTagIDListString = response.body;
    } catch (err) {
      print(_debugTag +
          "ERROR: Unable to fetch RuuviTagIDs from server: " +
          err.toString());
    } finally {
      print(_debugTag + "RUUVITAG JSON RESPONSE: " + _ruuviTagIDListString);

      // Returned is a list of lists with one element each: [[1],[2],[3],...]
      List tempRuuviTagIDList = jsonDecode(_ruuviTagIDListString);

      // Loop through list of ID's, add if needed
      for (var i in tempRuuviTagIDList) {
        if (_ruuviTagIDList.indexOf(i[0]) == -1) {
          _ruuviTagIDList.add(i[0]);
        }
      }
    }
  }

  // Sync ruuvitag from id list:
  void syncRuuviTags() async {
    for (var id in _ruuviTagIDList) {
      var response;
      var limitresponse;
      try {
        response = await _client
            .get(_address + "/api/doordetail/get/" + id.toString());
      } catch (err) {
        print(_debugTag +
            "ERROR: Unable to fetch RuuviTag details with id:" +
            id.toString() +
            ": " +
            err.toString());
      }

      try {
        limitresponse = await _client
            .get(_address + "/api/ruuvilimit/get/" + id.toString());
      } catch (err) {
        print(_debugTag +
            "ERROR: Unable to fetch RuuviTag limits with id:" +
            id.toString() +
            ": " +
            err.toString());
      } finally {
        print(_debugTag +
            "Got ruuvitag details with id " +
            id.toString() +
            " " +
            response.body);
        print(_debugTag +
            "Got ruuvitag limits with id " +
            id.toString() +
            " " +
            limitresponse.body);
        _sendPort.send(["ruuvitag", id, response.body, limitresponse.body]);
      }
    }
  }

  // Set RuuviTag name by id. Called separately, not from timer.
  void setRuuviTagName(int id, String name) async {
    var response;
    String body;
    try {
      body = '{"DeviceName":"' + name + '","idDevice":"' + id.toString() + '"}';
      print(_debugTag +
          "Sending POST to set ruuvitag name with id: " +
          id.toString() +
          ". Body to send: " +
          body);
      response = await _client.post(
          _address + "/api/devices/post/newdevicename",
          headers: {"Content-Type": "application/json"},
          body: body);
    } catch (err) {
      print(_debugTag +
          "ERROR: Unable to POST RuuviTagName with id: " +
          id.toString() +
          ": " +
          err.toString());
    } finally {
      print(_debugTag +
          "POST response set ruuvitag name with id: " +
          id.toString() +
          ": " +
          response.body);
    }
  }

  void setRuuviTagLimits(
      double upperTemp,
      double lowerTemp,
      double upperHumi,
      double lowerHumi,
      double upperPres,
      double lowerPres,
      double lowerBattery,
      int id) async {
    var response;
    String body;
    try {
      body = '{"Temperature_max": "' +
          upperTemp.toString() +
          '", "Temperature_min": "' +
          lowerTemp.toString() +
          '", "Humidity_max": "' +
          upperHumi.toString() +
          '", "Humidity_min": "' +
          lowerHumi.toString() +
          '", "AirPressure_max": "' +
          upperPres.toString() +
          '", "AirPressure_min": "' +
          lowerPres.toString() +
          '", "Batterylimit": "' +
          lowerBattery.toString() +
          '", "Devices_idDevice": "' +
          id.toString() +
          '"}';
      print(_debugTag +
          "Sending POST to set ruuvitag limits with id: " +
          id.toString() +
          ". Body to send: " +
          body);
      response = await _client.post(
          _address + "/api/ruuvilimit/post/ruuvilimits",
          headers: {"Content-Type": "application/json"},
          body: body);
    } catch (err) {
      print(_debugTag +
          "ERROR: Unable to POST RuuviTagLimits with id: " +
          id.toString() +
          ": " +
          err.toString());
    } finally {
      print(_debugTag +
          "POST response set ruuvitag limits with id: " +
          id.toString() +
          ": " +
          response.body);
    }
  }
}
