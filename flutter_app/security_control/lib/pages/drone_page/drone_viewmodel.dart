import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/service_locator.dart';

import 'drone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DroneViewModel extends ChangeNotifier{
  String _appBarTitle = "Drone";
  String _droneConnectionLabel = "Drone connection";
  bool _droneConnected = false;
  String _droneOnlineText = "Online";
  String _droneOfflineText = "Offline";
  double _labelFontSize = 25.0;
  String _droneStatusLabel = "Drone status";
  String _droneStatusText = "Unknown"; // ...on patrol, standby etc.
  String _droneControlHeadline = "Drone control";
  String _goHomeLabel = "GO HOME";
  String _startPatrolLabel = "START PATROL";
  String _emergencyStopLabel = "EMERGENCY LAND";


  String get appBarTitle => _appBarTitle;
  String get droneConnectionLabel => _droneConnectionLabel;
  bool get droneConnected => _droneConnected;
  String get droneOnlineText => _droneOnlineText;
  String get droneOfflineText => _droneOfflineText;
  double get labelFontSize => _labelFontSize;
  String get droneStatusLabel => _droneStatusLabel;
  String get droneStatusText => _droneStatusText;
  String get droneControlHeadline => _droneControlHeadline;
  String get goHomeLabel => _goHomeLabel;
  String get startPatrolLabel => _startPatrolLabel;
  String get emergencyStopLabel => _emergencyStopLabel;

  sendGoHome(){

  }

  sendStartPatrol(){

  }

  sendEmergencyStop(){

  }

}