import 'package:security_control/router.gr.dart';
import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:security_control/services/server_sync_service.dart';
import 'package:security_control/services/messages_sync_service.dart';
import 'package:security_control/services/sensor_sync_service.dart';

import 'login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier{

  NavigationService _navigationService = locator<NavigationService>();
  ServerSyncService _serverSyncService = locator<ServerSyncService>();
  MessagesSyncService _messagesSyncService = locator<MessagesSyncService>();
  SensorSyncService _sensorSyncService = locator<SensorSyncService>();

  bool _loginSuccess = false;
  bool _errorVisible = false;
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  String _title = "Security Control";
  String _loginFieldHint = "Username/E-mail";
  String _passwordFieldHint = "Password";
  String _loginLabel = "LOGIN";
  String _registerLabel = "REGISTER";
  String _loginDataErrorLabel = "Wrong username or password";

  // This is the correct way of getting a reference to a private member variable
  TextEditingController get userNameController{
    return _userNameController;
  }
  // Alternative notation is:
  TextEditingController get passwordController => _passwordController;
  String get title => _title;
  String get loginLabel => _loginLabel;
  String get registerLabel => _registerLabel;
  String get loginDataErrorLabel => _loginDataErrorLabel;
  String get loginFieldHint => _loginFieldHint;
  String get passwordFieldHint => _passwordFieldHint;
  bool get errorVisible => _errorVisible;

  void _setErrorVisibility(bool visible){
    _errorVisible = true;
    notifyListeners();
  }

  void login(){
    String username = _userNameController.text;
    String password = _passwordController.text;

    //TODO: implement actual login logic
    if(username == ""){
      _loginSuccess = true;
      _navigationService.navigateToAndReplace(Routes.homePage);
      startSync();

    }
    else{
      _loginSuccess = false;
      _setErrorVisibility(true);
    }

  }

  startSync() {
    _serverSyncService.startSync();
    _messagesSyncService.startSync();
    _sensorSyncService.startSync();
  }


}