import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:security_control/router.gr.dart';
import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/service_locator.dart';

class SettingsViewModel extends ChangeNotifier {

  NavigationService _navigationService = locator<NavigationService>();

  String _appBarLabel = "Settings";
  String _serverSettingsLabel = "Server settings";
  String _notificationSettingsLabel = "Notifications";
  String _sensorSettingsLabel = "Sensor settings";
  String _appearanceSettingsLabel = "Appearance settings";

  String get serverSettingsLabel => _serverSettingsLabel;
  String get notificationSettingsLabel => _notificationSettingsLabel;
  String get sensorSettingsLabel => _sensorSettingsLabel;
  String get appearanceSettingsLabel => _appearanceSettingsLabel;
  String get appBarLabel => _appBarLabel;


  void openServerSettings(){
    _navigationService.navigateTo(Routes.serverSettingsPage);
  }

  void openNotificationSettings(){
    _navigationService.navigateTo(Routes.notificationSettingsPage);
  }

  void openSensorSettings(){

  }

  void openAppearanceSettings(){

  }

}