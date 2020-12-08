

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:get_it/get_it.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:security_control/services/local_storage_service.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:security_control/models/gopigo.dart';
import 'package:security_control/models/message.dart';

class MessagesSyncService{

  var _isolate;
  ReceivePort _receivePort;
  Stream _receiveBroadcastStream;
  SendPort _sendPort;
  //Stream get receiveBroadcastStream => _receiveBroadcastStream;
  SendPort get sendPort => _sendPort;
  StreamSubscription _tempStreamSubscription;
  LocalStorageService _localStorageService;

  // Gopigo data:
  StreamController<List> _messageListController = new StreamController.broadcast();
  Stream<List> get messageListStream => _messageListController.stream;

  List _messageList = List();
  List get messageList => _messageList;


  MessagesSyncService(){
    print('(TRACE) MessagesSyncService:constructor.');
    //final isolates = IsolateHandler();
    _receivePort = ReceivePort();
    _receiveBroadcastStream = _receivePort.asBroadcastStream();
    _localStorageService = locator<LocalStorageService>();


    _tempStreamSubscription = _receiveBroadcastStream.listen((message) {
      // Register the sendPort when the other isolate tells us so:
      if(message is List){

        switch(message[0]){
          case "register":
            _sendPort = message[1];
            print('(TRACE) MessagesSyncService:constructor: Registered sender');
            //_sendPort.send(["register", locator]);
            _registerSettingListeners();
            _sendPort.send([
              "setinterval",
              _localStorageService.serverUpdateInterval.getValue()
            ]);
            _sendPort.send(
                ["setaddress", _localStorageService.serverAddress.getValue()]);
            break;

          case "messages":
            // message[1] = messageJSON: "[[messagetype, explanation, devicename], [messagetype, explanation, devicename]]"

            List _tempList = jsonDecode(message[1]);
            List _tempMessagesList = List();
            for(var msg in _tempList){
              _tempMessagesList.add(Message(msg[0], msg[4], msg[1], msg[3] , msg[2], clearMessage));
              print("(TRACE): MESSAGE from MessagesSyncService: " + msg.toString());
            }
            _messageList = _tempMessagesList;
            _messageListController.add(_messageList);
        }
      }
    });

    FlutterIsolate.spawn(entryPoint, _receivePort.sendPort);

  }

  clearMessage(int id){
    _sendPort.send(["clearmessage", id]);
  }

  // Listen to server update interval and address, change when needed:
  void _registerSettingListeners(){
    _localStorageService.serverUpdateInterval.listen((value) {
      _sendPort.send(["setinterval", value]);
    });

    _localStorageService.serverAddress.listen((value) {
      _sendPort.send(["setaddress", value]);
    });
  }

  void stopSync(){
    _sendPort.send("stop");
  }

  void startSync(){
    _sendPort.send("start");
  }

// void setUpdateInterval(double seconds){
//   _sendPort.send(["setinterval", seconds]);
// }

}



void entryPoint(SendPort sendPort) {
  // Entry function for the new isolate. Define actions in listen method of
  //    receivePort.

  Timer syncTimer;

  ReceivePort receivePort = ReceivePort();
  _SyncMessageIsolate _syncMessageIsolate = new _SyncMessageIsolate(sendPort, receivePort);
  GetIt _locator;

  receivePort.listen((message) {

    // TODO: Define different get methods to perform when receiving messages

    if(message is List){
      print('(TRACE) MessagesSyncService:entryPoint.receivePort.listen:' + message[0]);

      switch(message[0]){
        case "setinterval":
          _syncMessageIsolate.setDelay(message[1]);
          break;
        case "setaddress":
          _syncMessageIsolate.setAddress(message[1]);
          break;
        case "clearmessage":
        // message [1] = id
          _syncMessageIsolate.clearMessage(message[1]);
          break;
      // case
      }

    }
    else if (message is String) {
      print('(TRACE) SyncMessageIsolate: entryPoint.receivePort.listen:' + message);
      if (message == "stop") {
        _syncMessageIsolate.stopSync();
      }
      else if (message == "start") {
        _syncMessageIsolate.startSync();
      }
    }
  });

  sendPort.send(["register", receivePort.sendPort]);

}

class _SyncMessageIsolate {

  final String _debugTag = "(TRACE) _SyncMessageIsolate (messages): ";

  SendPort _sendPort;
  ReceivePort _receivePort;
  Timer _syncTimer;
  Duration _syncDelay;
  String _address;
  http.Client _client;

  String _goPiGoIDListString;
  List _goPiGoIDList;

  String _sensorIDListString;
  List _sensorIDList;

  _SyncMessageIsolate(SendPort sPort, ReceivePort rPort){
    _sendPort = sPort;
    _receivePort = rPort;
    _syncDelay = Duration(seconds: 5);
    _goPiGoIDList = List();
    _sensorIDList = List();
  }

  void setDelay(int value){
    _syncDelay = Duration(seconds: value);
    if(!(_syncTimer == null)) {
      if(_syncTimer.isActive == true) {
        stopSync();
        startSync();
      }
    }
  }

  void setAddress(String address){
    _address = "http://" + address;
    if(!(_syncTimer == null)) {
      if(_syncTimer.isActive == true) {
        stopSync();
        startSync();
      }
    }
  }

  stopSync(){
    if(!(_syncTimer == null)) {
      _syncTimer.cancel();
      _client.close();
    }
  }

  startSync(){
    // Ensure we don't start multiple of these
    stopSync();
    _client = http.Client();
    _syncTimer = Timer.periodic(_syncDelay, _sync);
  }

  _sync(Timer timer){
    _syncMessages();
  }


  // Sync gopigos from id list:
  void _syncMessages() async{
    var response;
    try{
      response =
      await _client.get(_address + "/api/devices/get/activemessages");
    }
    catch(err){
      print(_debugTag + "ERROR: Unable to fetch messages from server:" + err.toString());
    }
    finally{
      print(_debugTag + "Got messages from server: " + response.body);
      _sendPort.send(["messages", response.body]);
    }
  }

  // Set gopigo name by id. Called separately, not from timer.
  void clearMessage(int id)async{
    var response;
    String body;
    // TODO: Uncomment clear message POST method
    // try{
      body = '{"idMessage":"' + id.toString() + '"}';
      print(_debugTag + "Sending POST to clear message with id: " + id.toString() + ". Body to send: " + body);
    //   response = await _client.post(_address + "/api/message/post/messageinactive",
    //       headers: {"Content-Type": "application/json"},
    //       body: body);
    // }
    // catch(err){
    //   print(_debugTag + "ERROR: Unable to POST clear message with id: " + id.toString() + ": " + err.toString());
    // }
    // finally{
    //   print(_debugTag + "POST response clear message with id: " +id.toString() + ": " + response.body);
    // }
  }

  void setGoPiGoIDList(List IDList){
    _goPiGoIDList = IDList;
    stopSync();
    startSync();
  }

  void setSensorIDList(List IDList){
    _sensorIDList = IDList;
    stopSync();
    startSync();
  }


}

