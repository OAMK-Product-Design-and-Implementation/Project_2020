import 'dart:convert';

import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';


// Service for storing and retrieving data from SharedPreferences.
// Used for settings and simple data.

// Source: https://medium.com/flutter-community/shared-preferences-service-in-flutter-for-code-maintainability-1dbd015b5bbd

// Source for STREAMING: https://pub.dev/packages/streaming_shared_preferences

// The following plan is DEPRECATED, please disregard:
// This is how we will do the actual data handling:
// We have a class, e.g. GoPiGo, which will have all the data we need for GoPiGo's.
// Each class will handle the conversion from/to Json, since the data we get from
//    the server will always be in Json form...

// When the user retrieves a value from SharedPreferences, it uses the methods
//    in the LocalPreferencesService (defined for each class)
//    and the Json conversion will happen in
//    the class defined in this file.

// NOTE: LOCAL configuration for the app doesn't have to be in Json format.
// For example if we define local nicknames for GoPiGo's, we should not include
//    them in the Json.

class LocalStorageService {
  static LocalStorageService _instance = null;
  static StreamingSharedPreferences _preferences = null;

  static const String ServerUpdateIntervalKey = 'updateinterval';
  static const String ServerAddressKey = 'serveraddress';


  static Future<LocalStorageService> getInstance() async{
    if (_instance == null){
      _instance = LocalStorageService();
    }

    if(_preferences == null){
      _preferences = await StreamingSharedPreferences.instance;
    }
    return _instance;
  }

  Preference<int> get serverUpdateInterval => _getFromDisk(ServerUpdateIntervalKey, 5);
  //set serverUpdateInterval(int value) => _saveToDisk(ServerUpdateIntervalKey, value);
  Preference<String> get serverAddress => _getFromDisk(ServerAddressKey, "195.148.21.106");


  // //TODO:remove later
  // Preference<String> get goPiGoExampleString {
  //   Preference<String> gopigoJson = _getFromDisk(GoPiGoExampleKey, "");
  //   return gopigoJson;
  // }

  // GoPiGoExample get goPiGoExample {
  //   Preference<String> gopigoJson = _getFromDisk(GoPiGoExampleKey, "");
  //   if(gopigoJson.getValue() == ""){
  //       return GoPiGoExample(id: "",battery: 0,location: 0);
  //   }
  //   return GoPiGoExample.fromJson(json.decode(gopigoJson.getValue()));
  // }
  // set goPiGoExample(GoPiGoExample goPiGo){
  //   _saveToDisk(GoPiGoExampleKey, json.encode(goPiGo.toJson()));
  // }

  // Generic get method:
  dynamic _getFromDisk(String key, var defaultVal) {
    var value;
    if(defaultVal is String) {
      value = _preferences.getString(key, defaultValue: defaultVal);
      print('(TRACE) LocalStorageService:_getFromDisk. key: $key value:'+value.getValue());
    }
    else if(defaultVal is int){
      value = _preferences.getInt(key, defaultValue: defaultVal);
    }
    else if(defaultVal is double){
      value = _preferences.getDouble(key, defaultValue: defaultVal);
    }
    else if(defaultVal is List<String>){
      value = _preferences.getStringList(key, defaultValue: defaultVal);
    }
    else if(defaultVal is bool){
      value = _preferences.getBool(key, defaultValue: defaultVal);
    }
    print('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    return value;
  }

  // generic save method:
  void _saveToDisk<T>(String key, T content){
    print('(TRACE) LocalStorageService:_saveStringToDisk. key: $key value: $content');

    if(content is String) {
      _preferences.setString(key, content);
      print('(TRACE) LocalStorageService:_saveStringToDisk. key: $key value:' + content);
    }
    if(content is bool) {
      _preferences.setBool(key, content);
    }
    if(content is int) {
      _preferences.setInt(key, content);
    }
    if(content is double) {
      _preferences.setDouble(key, content);
    }
    if(content is List<String>) {
      _preferences.setStringList(key, content);
    }
  }

}
//
//
// // TODO: This is an example of saved data, remove/change
// // {"id": "unique","battery": -108228463,"location": 1}
// class GoPiGoExample {
//   final String id;
//   final int battery;
//   final int location;
//   GoPiGoExample({this.id, this.battery, this.location});
//
//   GoPiGoExample.fromJson(Map<String, dynamic> json)
//       : id = json['id'],
//         battery = json['battery'],
//         location = json['location'];
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['battery'] = this.battery;
//     data['location'] = this.location;
//     return data;
//   }
// }
//
