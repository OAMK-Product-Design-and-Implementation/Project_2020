import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:security_control/models/gopigo.dart';
import 'package:security_control/router.gr.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/server_sync_service.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:security_control/services/local_storage_service.dart';

class SubSettingsViewModel extends ChangeNotifier {

  NavigationService _navigationService = locator<NavigationService>();
  LocalStorageService _localStorageService = locator<LocalStorageService>();

  String _serverSettingsLabel = "Server settings";
  String _notificationSettingsLabel = "Notifications";
  String _sensorSettingsLabel = "Sensor settings";
  String _appearanceSettingsLabel = "Appearance settings";

  String get serverSettingsLabel => _serverSettingsLabel;
  String get notificationSettingsLabel => _notificationSettingsLabel;
  String get sensorSettingsLabel => _sensorSettingsLabel;
  String get appearanceSettingsLabel => _appearanceSettingsLabel;

  // Notifications
  bool _receiveNotifications = true;
  bool _receiveIntruderAlerts = true;
  bool _receiveLowBatteryAlerts = true;
  String _receiveNotificationsLabel = "Receive push notifications";
  String _intruderAlertsLabel = "Intruder alerts";
  String _lowBatteryAlertsLabel = "Low battery alerts";

  bool get receiveNotifications => _receiveNotifications;
  bool get receiveIntruderAlerts => _receiveIntruderAlerts;
  bool get receiveLowBatteryAlerts => _receiveLowBatteryAlerts;
  String get receiveNotificationsLabel => _receiveNotificationsLabel;
  String get intruderAlertsLabel => _intruderAlertsLabel;
  String get lowBatteryAlertsLabel => _lowBatteryAlertsLabel;

  setReceiveNotifications(bool enabled){
    _receiveNotifications = enabled;
    notifyListeners();
  }

  setReceiveIntruderAlerts(bool enabled){
    _receiveIntruderAlerts = enabled;
    notifyListeners();
  }

  setReceiveLowBatteryAlerts(bool enabled){
    _receiveLowBatteryAlerts = enabled;
    notifyListeners();
  }

  // Server settings:
  String _serverUpdateIntervalLabel = "Update interval (s)";
  double _serverUpdateInterval = 5;
  double _maxServerUpdateInterval = 120;
  double _minServerUpdateInterval = 1;
  TextEditingController _serverAddressEditingController = TextEditingController();
  String _serverAddress = "192.168.0.1";
  String _serverAddressDialogTitle = "Set server address";
  String _serverAddressDialogHintLabel = "E.g. 192.168.0.1";
  String _serverAddressDialogConfirmButtonLabel = "APPLY";
  String _serverAddressDialogCancelButtonLabel = "CANCEL";
  String _serverAddressLabel = "Server address";

  String get serverUpdateIntervalLabel => _serverUpdateIntervalLabel;
  double get serverUpdateInterval => _serverUpdateInterval;
  double get maxServerUpdateInterval => _maxServerUpdateInterval;
  double get minServerUpdateInterval => _minServerUpdateInterval;
  TextEditingController get serverAddressEditingController => _serverAddressEditingController;
  String get serverAddressDialogTitle => _serverAddressDialogTitle;
  String get serverAddressDialogHintLabel => _serverAddressDialogHintLabel;
  String get serverAddressDialogConfirmButtonLabel => _serverAddressDialogConfirmButtonLabel;
  String get serverAddressDialogCancelButtonLabel => _serverAddressDialogCancelButtonLabel;
  String get serverAddressLabel => _serverAddressLabel;
  String get serverAddress => _serverAddress;

  //TODO: Demo, remove:
  String _goPiGoId;
  int _goPiGoBattery;
  int _goPiGoLocation;
  List _goPiGoIDList;
  List _goPiGoList;
  GoPiGoExample _goPiGo;
  GoPiGoExample get goPiGo => _goPiGo;

  ServerSyncService _serverSyncService = locator<ServerSyncService>();
  String _serverString;
  String get serverString => _serverString;

  void initialise() {


    _localStorageService.serverAddress.listen((value) {
      _serverAddress = value;
      notifyListeners();
    });

    // // Monitor for changes in list of gopigo's:
    // _localStorageService.goPiGoExampleIDString.listen{
    //   _goPiGoIDList = _localStorageService.goPiGoExampleIDList;
    //   // Call for function to rebuild listeners for each GoPiGo
    // }
    //
    // // Get initial list of goPiGo's:
    // _goPiGoIDList = _localStorageService.goPiGoExampleIDList;
    //
    // // Get goPiGo's by ID:
    // for(var i=0; i< _goPiGoIDList.length; i++){
    //
    //   // Assemble list of GoPiGo's:
    //   _goPiGoList[i] = (_localStorageService.getGoPiGoByID);
    //
    //   // Set listeners for changes in each GoPiGo:
    //   _localStorageService.getStringByID(_goPiGoIDList(i)).listen{
    //     _goPiGoList[i] = (_localStorageService.getGoPiGoByID(_goPiGoIDList(i)));
    //   }
    // }

    _serverString =  "initialised";
    // TODO: How do we unsubscribe when we dispose of viewmodel?
    // Now this is causing errors after viewmodel is disposed, since it is
    //   still listening...
    // _serverSyncService.receiveBroadcastStream.listen((message) {
    //   _serverString = message;
    //   notifyListeners();
    // });

    // _serverSyncService.goPiGoListMap.listen((gopigomap) {
    //   if(gopigomap is Map){
    //     for(GoPiGo drifter in gopigomap.values){
    //       print(drifter.name);
    //     }
    //   }
    // });

    //TODO: Demo, remove:
    _localStorageService.goPiGoExampleString.listen((value) {
      _goPiGo = _localStorageService.goPiGoExample;
      notifyListeners();
    });
    print('(TRACE) SubSettingsViewModel:initialise.'+ _localStorageService.goPiGoExampleString.getValue());
    _goPiGo = _localStorageService.goPiGoExample;
    //_localStorageService.goPiGoExample = _goPiGo;
    //setServerAddress();
    _serverUpdateInterval = _localStorageService.serverUpdateInterval.getValue().toDouble();
  }

  setServerAddress(){
    _serverAddress = _serverAddressEditingController.text;
    _localStorageService.serverAddress.setValue(_serverAddress);
    _serverSyncService.stopSync();
    //notifyListeners(); //not needed I think
  }

  // Call this to update the interval to viewmodel
  // YOU MUST CALL saveServerUpdateInterval() later to save to preferences!
  setServerUpdateInterval(double value){
    _serverUpdateInterval = value;
    notifyListeners();
  }
  // Save value to preferences
  saveServerUpdateInterval(){
    _localStorageService.serverUpdateInterval.setValue(_serverUpdateInterval.round());
    //_serverSyncService.setUpdateInterval(_serverUpdateInterval);
    notifyListeners();
  }

  stopSync(){
    _serverSyncService.stopSync();
  }

  startSync(){
    _serverSyncService.startSync();
  }

}