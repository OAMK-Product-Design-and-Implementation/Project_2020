import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:security_control/services/local_storage_service.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:security_control/models/gopigo.dart';

class ServerSyncService {
  ReceivePort _receivePort;
  Stream _receiveBroadcastStream;
  SendPort _sendPort;
  SendPort get sendPort => _sendPort;
  LocalStorageService _localStorageService;

  // Gopigo data:
  StreamController<Map> _goPiGoListMapStreamControl =
      new StreamController.broadcast();
  Stream<Map> get goPiGoListMapStream => _goPiGoListMapStreamControl.stream;

  Map<int, GoPiGo> _goPiGoListMap = Map();
  Map<int, GoPiGo> get goPiGoListMap => _goPiGoListMap;

  ServerSyncService() {
    print('(TRACE) ServerSyncService:constructor.');
    _receivePort = ReceivePort();
    _receiveBroadcastStream = _receivePort.asBroadcastStream();
    _localStorageService = locator<LocalStorageService>();

    _receiveBroadcastStream.listen((message) {
      // Register the sendPort when the other isolate tells us so:
      if (message is List) {
        switch (message[0]) {
          case "register":
            _sendPort = message[1];
            print('(TRACE) ServerSyncService:constructor: Registered sender');
            _registerSettingListeners();
            _sendPort.send([
              "setinterval",
              _localStorageService.serverUpdateInterval.getValue()
            ]);
            _sendPort.send(
                ["setaddress", _localStorageService.serverAddress.getValue()]);
            break;
          case "gopigoids":
            for (var item in message[1]) {
              if (_goPiGoListMap[item]?.id == null)
                _goPiGoListMap[item] = GoPiGo.loading();
            }
            _goPiGoListMapStreamControl.add(_goPiGoListMap);
            break;
          case "gopigo":
            // Message[1] = id
            // message[2] = gopigoJSON: "[[data]]"
            // message[3] = gopigolimitJSON
            if (jsonDecode(message[2]).length > 0) {
              _goPiGoListMap[message[1]] = GoPiGo.fromJson(message[2],
                  message[1], message[3], setGoPiGoName, setGoPiGoLimits);
              _goPiGoListMapStreamControl.add(_goPiGoListMap);
            }
        }
      }
    });

    FlutterIsolate.spawn(entryPoint, _receivePort.sendPort);
  }

  setGoPiGoName(int id, String name) {
    _sendPort.send(["setgopigoname", id, name]);
  }

  setGoPiGoLimits(int id, double lowerBattery) {
    _sendPort.send(["setbatterylimit", id, lowerBattery]);
  }

  void updateGoPiGoIDlist() {
    _sendPort.send("updategopigoidlist");
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
    _sendPort.send("syncgopigos");
  }
}

void entryPoint(SendPort sendPort) {
  // Entry function for the new isolate. Define actions in listen method of
  //    receivePort.

  ReceivePort receivePort = ReceivePort();
  _SyncIsolate _syncIsolate = new _SyncIsolate(sendPort, receivePort);

  receivePort.listen((message) {
    if (message is List) {
      print('(TRACE) SyncIsolate:entryPoint.receivePort.listen:' + message[0]);

      switch (message[0]) {
        case "setinterval":
          _syncIsolate.setDelay(message[1]);
          break;
        case "setaddress":
          _syncIsolate.setAddress(message[1]);
          break;
        case "updategopigoidlist":
          _syncIsolate.syncGoPiGoIDList();
          break;
        case "setbatterylimit":
          _syncIsolate.setGoPiGoBatteryLimit(message[1], message[2]);
          break;
        case "setgopigoname":
          // message [1] = id
          // message [2] = name
          _syncIsolate.setGoPiGoName(message[1], message[2]);
          break;
      }
    } else if (message is String) {
      print('(TRACE) SyncIsolate:entryPoint.receivePort.listen:' + message);
      if (message == "stop") {
        _syncIsolate.stopSync();
      } else if (message == "syncgopigos") {
        _syncIsolate.startSync();
      }
    }
  });

  sendPort.send(["register", receivePort.sendPort]);
}

class _SyncIsolate {
  final String _debugTag = "(TRACE) _SyncIsolate: ";

  SendPort _sendPort;
  Timer _syncTimer;
  Duration _syncDelay;
  String _address;
  http.Client _client;

  String _goPiGoIDListString;
  List _goPiGoIDList;

  _SyncIsolate(SendPort sPort, ReceivePort rPort) {
    _sendPort = sPort;
    _syncDelay = Duration(seconds: 5);
    _goPiGoIDList = List();
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
    syncGoPiGoIDList();
    syncGoPiGos();
  }

  // Function to get gopigo id JSON from server:
  syncGoPiGoIDList() async {
    // Get GoPiGo ID's and compare them with local values
    var response;
    try {
      response = await _client.get(_address + "/api/devices/get/gopigoids");
      _goPiGoIDListString = response.body;
    } catch (err) {
      print(_debugTag +
          "ERROR: Unable to fetch GoPiGoIDs from server: " +
          err.toString());
    } finally {
      print(_debugTag + "GOPIGO JSON RESPONSE: " + _goPiGoIDListString);

      // Returned is a list of lists with one element each: [[1],[2],[3],...]
      List tempGoPiGoIDList = jsonDecode(_goPiGoIDListString);

      // Loop through list of ID's, add if needed
      for (var i in tempGoPiGoIDList) {
        if (_goPiGoIDList.indexOf(i[0]) == -1) {
          _goPiGoIDList.add(i[0]);
        }
      }
      _sendPort.send(["gopigoids", _goPiGoIDList]);
    }
  }

  // Sync gopigos from id list:
  void syncGoPiGos() async {
    for (var id in _goPiGoIDList) {
      var response;
      var limitresponse;
      try {
        response =
            await _client.get(_address + "/api/gopigoid/get/" + id.toString());
      } catch (err) {
        print(_debugTag +
            "ERROR: Unable to fetch GoPiGo details with id:" +
            id.toString() +
            ": " +
            err.toString());
      }

      try {
        limitresponse = await _client
            .get(_address + "/api/devices/get/batterylimits/" + id.toString());
      } catch (err) {
        print(_debugTag +
            "ERROR: Unable to fetch GoPiGo battery limits with id:" +
            id.toString() +
            ": " +
            err.toString());
      } finally {
        print(_debugTag +
            "Got GoPiGo details with id " +
            id.toString() +
            " " +
            response.body);
        print(_debugTag +
            "Got GoPiGo limits with id " +
            id.toString() +
            " " +
            limitresponse.body);
        _sendPort.send(["gopigo", id, response.body, limitresponse.body]);
      }
    }
  }

  // Set gopigo name by id. Called separately, not from timer.
  void setGoPiGoName(int id, String name) async {
    var response;
    String body;
    try {
      body = '{"DeviceName":"' + name + '","idDevice":"' + id.toString() + '"}';
      print(_debugTag +
          "Sending POST to set gopigo name with id: " +
          id.toString() +
          ". Body to send: " +
          body);
      response = await _client.post(
          _address + "/api/devices/post/newdevicename",
          headers: {"Content-Type": "application/json"},
          body: body);
    } catch (err) {
      print(_debugTag +
          "ERROR: Unable to POST GoPiGoName with id: " +
          id.toString() +
          ": " +
          err.toString());
    } finally {
      print(_debugTag +
          "POST response set gopigo name with id: " +
          id.toString() +
          ": " +
          response.body);
    }
  }

  void setGoPiGoBatteryLimit(int id, double limit) async {
    var response;
    String body;
    try {
      body = '{"Batterylimit": "' +
          limit.toString() +
          '", "Devices_idDevice": "' +
          id.toString() +
          '"}';
      print(_debugTag +
          "Sending POST to set gopigo battery limit with id: " +
          id.toString() +
          ". Body to send: " +
          body);
      response = await _client.post(
          _address + "/api/devices/post/batterylimits",
          headers: {"Content-Type": "application/json"},
          body: body);
    } catch (err) {
      print(_debugTag +
          "ERROR: Unable to POST Batterylimit with id: " +
          id.toString() +
          ": " +
          err.toString());
    } finally {
      print(_debugTag +
          "POST response set gopigo battery limit with id: " +
          id.toString() +
          ": " +
          response.body);
    }
  }
}
