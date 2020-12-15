import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:security_control/models/message.dart';
import 'package:security_control/router.gr.dart';
import 'package:security_control/services/messages_sync_service.dart';
import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/sensor_sync_service.dart';
import 'package:security_control/services/server_sync_service.dart';
import 'package:security_control/services/service_locator.dart';

class HomeViewModel extends ChangeNotifier {
  NavigationService _navigationService = locator<NavigationService>();
  MessagesSyncService _messagesSyncService = locator<MessagesSyncService>();
  ServerSyncService _serverSyncService = locator<ServerSyncService>();
  SensorSyncService _sensorSyncService = locator<SensorSyncService>();

  String _appBarTitle = "Security Control";
  String _accountName = "Test User";
  String _accountEmail = "TestUser@email.com";
  double _avatarFontSize = 40.0;
  String _serverConnectionLabel = "Server connection";
  String _securityStatusLabel = "Security Status";
  double _labelFontSize = 25.0;
  String _serverOnline = "Online";
  String _serverOffline = "Offline";
  bool _serverConnected = true;
  String _noIntruders = "No intruders";
  String _intruders = "Intruder!";
  String _actionRequiredLabel = " notification(s)";
  String _noActionRequiredLabel = "Everything OK";
  bool _intruderAlert = false;
  int _criticalActionsCount = 0;
  String _deviceConnected = "CONNECTED";
  String _deviceDisconnected = "DISCONNECTED";

  String get appBarTitle => _appBarTitle;

  String get accountName => _accountName;

  String get accountEmail => _accountEmail;

  double get avatarFontSize => _avatarFontSize;

  String get serverConnectionLabel => _serverConnectionLabel;

  String get securityStatusLabel => _securityStatusLabel;

  double get labelFontSize => _labelFontSize;

  String get serverOnline => _serverOnline;

  String get serverOffline => _serverOffline;

  bool get serverConnected => _serverConnected;

  String get noIntruders => _noIntruders;

  String get intruders => _intruders;

  bool get intruderAlert => _intruderAlert;

  String get actionRequiredLabel => _actionRequiredLabel;

  String get noActionRequiredLabel => _noActionRequiredLabel;

  int get criticalActionsCount => _criticalActionsCount;

  String get deviceConnected => _deviceConnected;

  String get deviceDisconnected => _deviceDisconnected;

  List _goPiGoList;
  List _sensorList;

  List get goPiGoList => _goPiGoList;

  List get sensorList => _sensorList;

  List<MyDrawerItems> drawerItems = <MyDrawerItems>[
    const MyDrawerItems('Drifters', Icon(Icons.directions_car_rounded)),
    const MyDrawerItems('Drone', Icon(Icons.airplanemode_active_rounded)),
    const MyDrawerItems('Sensors', Icon(Icons.ac_unit)),
    const MyDrawerItems('Pictures', Icon(Icons.photo)),
    const MyDrawerItems(
        'Charge Station', Icon(Icons.airline_seat_legroom_extra)),
    const MyDrawerItems('Settings', Icon(Icons.settings)),
    const MyDrawerItems('Logout', Icon(Icons.logout)),
  ];

  void drawerItemOnPressed(int i) {
    switch (i) {
      case 0:
        _navigationService.navigateTo(Routes.driftersPage);
        break;
      case 1:
        _navigationService.navigateTo(Routes.dronePage);
        break;
      case 2:
        _navigationService.navigateTo(Routes.sensorsPage);
        break;
      case 3:
        _navigationService.navigateTo(Routes.picturesPage);
        break;
      case 4:
        _navigationService.navigateTo(Routes.batteryStationPage);
        break;
      case 5:
        _navigationService.navigateTo(Routes.settingsPage);
        break;
      case 6:
        stopSync();
        _navigationService.navigateTo(Routes.loginPage);
        break;
    }
  }

  List actionsRequired;

  initialise() {
    _messagesSyncService.messageListStream.listen((event) {
      actionsRequired = event;
      _intruderAlert = false;
      _criticalActionsCount = 0;
      for (Message action in actionsRequired) {
        if (action.messageType == "Intruder") {
          _intruderAlert = true;
          _criticalActionsCount++;
        } else if (action.messageType == "Error") {
          _criticalActionsCount++;
        }
      }
      notifyListeners();
    });

    _serverSyncService.goPiGoListMapStream.listen((event) {
      _goPiGoList = event.values.toList();
      notifyListeners();
    });
    _goPiGoList = _serverSyncService.goPiGoListMap.values.toList();
    actionsRequired = _messagesSyncService.messageList;

    _sensorSyncService.ruuviTagListMapStream.listen((event) {
      _sensorList = event.values.toList();
      notifyListeners();
    });

    _sensorList = _sensorSyncService.ruuviTagListMap.values.toList();
  }

  stopSync() {
    _serverSyncService.stopSync();
    _messagesSyncService.stopSync();
    _sensorSyncService.stopSync();
  }

  showRequiredActionsDialog(BuildContext context) {
    Widget clearButton = FlatButton(
      child: Text("CLEAR ALL"),
      onPressed: () {
        for (var msg in actionsRequired) {
          msg.clear();
        }
        Navigator.of(context).pop();
        //clear actionsrequired
      },
    );
    Widget backButton = FlatButton(
      child: Text("BACK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog actions = AlertDialog(
      scrollable: true,
      title: Text("Notifications"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              itemCount: actionsRequired.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    child: InkWell(
                        onTap: () {
                          //POST MESSAGE CLEARED WITH ID
                          clearMessageDialog(context, actionsRequired[index]);
                        },
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    actionsRequired[index].deviceName +
                                        ": " +
                                        actionsRequired[index].messageType,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Text(actionsRequired[index].explanation),
                                  Divider(),
                                  Text(actionsRequired[index].timestamp,
                                      style: TextStyle(color: Colors.grey)),
                                ]))));
              },
            ),
          ),
        ],
      ),
      actions: [
        backButton,
        clearButton,
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return actions;
      },
    );
  }

  clearMessageDialog(BuildContext context, Message msg) {
    Widget noButton = FlatButton(
      child: Text("NO"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget yesButton = FlatButton(
      child: Text("YES"),
      onPressed: () {
        msg.clear(); // CLEAR MESSAGE
        Navigator.of(context).pop();
      },
    );
    AlertDialog clearMessage = AlertDialog(
      content: Text('Are you sure you want to clear this message?'),
      actions: [
        noButton,
        yesButton,
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return clearMessage;
      },
    );
  }
}

class MyDrawerItems {
  const MyDrawerItems(this.name, this.icon);

  final String name;
  final Icon icon;
}

class Devices {
  Devices(this.id, this.name, this.batterylevel, this.connected);

  final int id;
  final String name;
  final int batterylevel;
  final bool connected;
}
