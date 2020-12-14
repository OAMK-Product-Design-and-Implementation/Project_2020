import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:intl/intl.dart';
import 'package:security_control/services/local_storage_service.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:security_control/models/history.dart';

class HistorySyncService {
  ReceivePort _receivePort;
  Stream _receiveBroadcastStream;
  SendPort _sendPort;
  SendPort get sendPort => _sendPort;
  LocalStorageService _localStorageService;

// History data:
  StreamController<List> _historyListStreamControl =
      StreamController.broadcast();
  Stream<List> get historyListStream => _historyListStreamControl.stream;
// Current status data:
  StreamController<List> _statusListStreamControl =
      StreamController.broadcast();
  Stream<List> get statusListStream => _statusListStreamControl.stream;

  HistorySyncService() {
    print('(TRACE) HistorySyncService:constructor.');
    _receivePort = ReceivePort();
    _receiveBroadcastStream = _receivePort.asBroadcastStream();
    _localStorageService = locator<LocalStorageService>();

    _receiveBroadcastStream.listen((message) {
      // Register the sendPort when the other isolate tells us so:
      if (message is List) {
        switch (message[0]) {
          case "register":
            _sendPort = message[1];
            print('(TRACE) HistorySyncService:constructor: Registered sender');
            //_sendPort.send(["register", locator]);
            _registerSettingListeners();
            _sendPort.send([
              "setinterval",
              _localStorageService.serverUpdateInterval.getValue()
            ]);
            _sendPort.send(
                ["setaddress", _localStorageService.serverAddress.getValue()]);
            break;
          case "history":
            // print('(TRACE) HistorySyncService:history');
            List _tempList = jsonDecode(message[1]);
            List _tempHistoryList = List();
            for (var item in _tempList) {
              // print('(TRACE) History added: {[${item[0]}],[${item[1]}]}');
              _tempHistoryList.add(History.fromJson(item[0], item[1]));
            }
            _historyListStreamControl.add(_tempHistoryList.toList());
            break;
          case "status":
            _statusListStreamControl.add(jsonDecode(message[1])[0]);
        }
      }
    });

    FlutterIsolate.spawn(_entryPoint, _receivePort.sendPort);
  }

  getHistory(DateTime timestamp) {
    _sendPort.send(["gethistory", timestamp]);
  }

  getStatus() {
    _sendPort.send(["getstatus"]);
  }

  // Listen to server update interval and address, change when needed:
  void _registerSettingListeners() {
    _localStorageService.serverUpdateInterval.listen((value) {
      _sendPort.send(["registerSettingsSetinterval", value]);
    });

    _localStorageService.serverAddress.listen((value) {
      _sendPort.send(["registerSettingsSetaddress", value]);
    });
  }

  void stopSync() {
    _sendPort.send("stop");
  }

  void startSync() {
    _sendPort.send("start");
  }

  void setUpdateInterval(double seconds) {
    _sendPort.send(["setinterval", seconds]);
  }
}

void _entryPoint(SendPort sendPort) {
  // Entry function for the new isolate. Define actions in listen method of
  //    receivePort.

  ReceivePort receivePort = ReceivePort();
  _HistoryIsolate _syncIsolate = new _HistoryIsolate(sendPort, receivePort);

  receivePort.listen((message) {
    if (message is List) {
      print(
          '(TRACE) HistoryIsolate:entryPoint.receivePort.listen:' + message[0]);

      switch (message[0]) {
        case "setinterval":
          _syncIsolate.setDelay(message[1]);
          break;
        case "setaddress":
          _syncIsolate.setAddress(message[1]);
          break;
        case "gethistory":
          _syncIsolate.getHistory(message[1]);
          break;
        case "getstatus":
          _syncIsolate.getStatus();
          break;
      }
    } else if (message is String) {
      // print('(TRACE) History: HistoryIsolate:entryPoint.receivePort.listen:' +
      //     message);
      if (message == "stop") {
        _syncIsolate.stopSync();
      } else if (message == "start") {
        _syncIsolate.startSync();
      }
    }
  });

  sendPort.send(["register", receivePort.sendPort]);
}

class _HistoryIsolate {
  final String _debugTag = "(TRACE) _HistoryIsolate: ";

  SendPort _sendPort;
  Timer _syncTimer;
  Duration _syncDelay;
  String _address;
  http.Client _client = http.Client();

  //History
  DateFormat timeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  _HistoryIsolate(SendPort sPort, ReceivePort rPort) {
    _sendPort = sPort;
    _syncDelay = Duration(seconds: 5);
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
    getStatus();
  }

  //Get Current status of batterystation
  void getStatus() async {
    var response;
    try {
      print(_debugTag +
          "Sending GET to get Status: [" +
          _address +
          "/api/devices/get/stationstatus]");
      response = await _client.get(_address + "/api/devices/get/stationstatus");
    } catch (err) {
      print(_debugTag + "ERROR: Unable to GET Status:  " + err.toString());
    } finally {
      print(_debugTag + "GOPIGO JSON RESPONSE: " + response.body);
      _sendPort.send(["status", response.body]);
    }
  }

  void getHistory(DateTime timestamp) async {
    var response;
    String timeString = timeFormat.format(timestamp);
    try {
      print(_debugTag +
          "Sending GET to get History older than: [" +
          _address +
          "/api/charge/get/" +
          timeString +
          "]");
      response = await _client.get(_address + "/api/charge/get/" + timeString);
    } catch (err) {
      // print(_debugTag +
      //     "ERROR: Unable to GET History with DateTime: [" +
      //     timeFormat.format(timestamp) +
      //     "] : " +
      //     err.toString());
    } finally {
      print(_debugTag +
          "GOPIGO JSON RESPONSE: " +
          timeFormat.format(timestamp) +
          ": " +
          response.body);
      _sendPort.send(["history", response.body]);
    }
  }
}
